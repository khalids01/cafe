/** Prepare and remove a fictional COD example without calling a courier provider. */
import { request } from "@playwright/test";
import { resolve } from "node:path";
import { assertTestEnvironment } from "../../tests/setup/assert-test-environment";
import { runOrderFixture, type OrderFixtureSpec } from "../shared/order-fixtures";
const mode = process.argv[2];
if (!["prepare", "cleanup"].includes(mode ?? "")) throw new Error("Usage: fixtures.ts prepare|cleanup");
const environment = assertTestEnvironment();
if (environment.isRemote || process.env.COURIER_WORKERS_ENABLED !== "false" || process.env.ENABLE_POLAR !== "false") throw new Error("Local isolated environment with integrations disabled required");
const marker = "tutorial-courier-cod-collections";
const spec: OrderFixtureSpec = { marker, sku: "TUTCOD031", locationCode: "TUTCOD031", receiptPath: resolve(import.meta.dir, "artifacts/fixtures.receipt.json"), orders: [{ key: "order", customerName: `${marker}-order`, steps: ["confirm"], verify: { orderStatus: "confirmed" } }] };
const { default: db } = await import("../../packages/db/src/client.server");
const api = await request.newContext({ baseURL: "http://localhost:3000", storageState: "tests/e2e/.auth/owner.json" });
try {
  const orders = await db.order.findMany({ where: { customerName: `${marker}-order` }, select: { id: true } });
  const owned = { orderId: { in: orders.map(order => order.id) } };
  await db.orderPayment.deleteMany({ where: owned });
  const consignments = await db.courierConsignment.findMany({ where: owned, select: { id: true } });
  const ownedConsignments = { consignmentId: { in: consignments.map(item => item.id) } };
  await db.courierSettlement.deleteMany({ where: ownedConsignments });
  await db.courierException.deleteMany({ where: ownedConsignments });
  await db.courierEvent.deleteMany({ where: ownedConsignments });
  await db.courierReturn.deleteMany({ where: ownedConsignments });
  await db.courierOperation.deleteMany({ where: ownedConsignments });
  await db.courierConsignment.deleteMany({ where: owned });
  await db.courierShipmentClaim.deleteMany({ where: owned });
  await db.courierDispatch.deleteMany({ where: owned });
  await runOrderFixture(spec, mode as "prepare" | "cleanup");
  if (mode === "prepare") {
    // Reuse only the explicitly fictional lab connection prepared for 26–30.
    const original = await db.courierConsignment.findFirstOrThrow({ where: { order: { adminNotes: "tutorial-courier-lab" } } });
    const receipt = await Bun.file(spec.receiptPath).json();
    const orderId = receipt.orders.order;
    const order = await db.order.findUniqueOrThrow({ where: { id: orderId } });
    const response = await api.post(`/admin/delivery/orders/${orderId}/confirm`, { data: { connectionId: original.connectionId, serviceId: original.serviceId } });
    if (!response.ok()) throw new Error(`Fixture route confirmation failed: ${response.status()}`);
    const dispatch = await response.json();
    // Prepared delivery state is fictional; no booking, worker queue or provider call.
    const consignment = await db.courierConsignment.create({ data: { orderId, dispatchId: dispatch.id, connectionId: original.connectionId, serviceId: original.serviceId, invoice: order.orderNumber, state: "delivered", externalId: marker, providerState: "fictional-delivered", deliveredAt: new Date(), codAmount: order.totalAmount, currency: order.currency, requestSnapshot: dispatch.routingSnapshot.reviewedRequest } });
    await db.order.update({ where: { id: orderId }, data: { deliveryStatus: "delivered" } });
    const collected = await api.post("/admin/delivery/settlements", { data: { consignmentId: consignment.id, externalId: `${marker}-gross`, amount: String(order.totalAmount), currency: order.currency, note: `${marker} prepared fictional collection evidence` } });
    if (!collected.ok()) throw new Error(`Fixture collection failed: ${collected.status()}`);
    const detail = await (await api.get(`/admin/orders/${orderId}`)).json();
    if (detail.paymentStatus !== "paid") throw new Error("Fictional collection was not reconciled");
    const fixtures = await Bun.file(resolve(import.meta.dir, "fixtures.example.json")).json();
    fixtures.values = { orderId, shipmentReference: order.orderNumber };
    await Bun.write(resolve(import.meta.dir, "fixtures.local.json"), JSON.stringify(fixtures, null, 2) + "\n");
  }
} finally { await api.dispose(); await db.$disconnect(); }
