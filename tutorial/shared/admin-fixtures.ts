/** Marker-owned, isolated records for tutorials 35, 37, 38, 40 and 42. */
import { assertTestEnvironment } from "../../tests/setup/assert-test-environment";
import { resolve } from "node:path";
const mode = process.argv[2];
if (!["prepare", "cleanup"].includes(mode ?? "")) throw new Error("Usage: admin-fixtures.ts prepare|cleanup");
const environment = assertTestEnvironment();
if (environment.isRemote || process.env.COURIER_WORKERS_ENABLED !== "false" || process.env.ENABLE_POLAR !== "false") throw new Error("Local isolated environment with integrations disabled required");
const { default: db } = await import("../../packages/db/src/client.server");
const root = resolve(import.meta.dir, "..");
const names = {
  customer: "tutorial-customer-records-customer",
  email: "tutorial-customer-records@northstar.example.test",
  role: "tutorial-roles-permissions-role",
  feedback: "tutorial-feedback-moderation-fictional-feedback",
  activity: "tutorial-activity-audit-configuration-updated",
  webhook: "tutorial-webhook-events-event",
};
try {
  if (mode === "cleanup") {
    await db.feedback.deleteMany({ where: { message: names.feedback } });
    await db.activityEvent.deleteMany({ where: { message: names.activity } });
    await db.webhookEvent.deleteMany({ where: { provider: "tutorial", eventId: names.webhook } });
    await db.rbacRole.deleteMany({ where: { slug: names.role, name: names.role, isSystem: false, isProtected: false } });
    await db.ecommerceCustomer.deleteMany({ where: { normalizedEmail: names.email, name: names.customer, orders: { none: {} } } });
    const remaining = await Promise.all([
      db.feedback.count({ where: { message: names.feedback } }),
      db.activityEvent.count({ where: { message: names.activity } }),
      db.webhookEvent.count({ where: { provider: "tutorial", eventId: names.webhook } }),
      db.rbacRole.count({ where: { slug: names.role } }),
      db.ecommerceCustomer.count({ where: { normalizedEmail: names.email } }),
    ]);
    if (remaining.some(Boolean)) throw new Error("Tutorial fixture cleanup incomplete");
    console.log("Marker-owned admin fixtures removed");
  } else {
    const owner = await db.user.findUniqueOrThrow({ where: { email: "owner@northstar.example.test" } });
    const customer = await db.ecommerceCustomer.upsert({ where: { normalizedEmail: names.email }, create: { name: names.customer, email: names.email, normalizedEmail: names.email, phone: "01700000000", adminNote: "Fictional tutorial example" }, update: {} });
    const role = await db.rbacRole.upsert({ where: { slug: names.role }, create: { name: names.role, slug: names.role, isSystem: false, isProtected: false }, update: {} });
    if (customer.name !== names.customer || role.name !== names.role || role.isSystem || role.isProtected) throw new Error("Existing fixture identity mismatch");
    if (!await db.feedback.findFirst({ where: { message: names.feedback } })) await db.feedback.create({ data: { userId: owner.id, message: names.feedback, status: "open", severity: "low" } });
    if (!await db.activityEvent.findFirst({ where: { message: names.activity } })) await db.activityEvent.create({ data: { actorUserId: owner.id, type: "configuration.updated", message: names.activity, metadata: { fictional: true } } });
    await db.webhookEvent.upsert({ where: { provider_eventId: { provider: "tutorial", eventId: names.webhook } }, create: { provider: "tutorial", eventId: names.webhook, eventType: "tutorial.fixture", status: "processed", processedAt: new Date() }, update: {} });
    for (const [folder, values] of [
      ["35-customer-records", { customerId: customer.id, customerName: customer.name }],
      ["37-roles-permissions", { roleId: role.id }],
      ["38-feedback-moderation", { feedbackText: names.feedback }],
      ["40-activity-audit", { activityMessage: names.activity }],
      ["42-webhook-events", { webhookReference: names.webhook }],
    ] as const) {
      const file = resolve(root, folder, "fixtures.example.json");
      const fixtures = await Bun.file(file).json();
      fixtures.values = values;
      await Bun.write(resolve(root, folder, "fixtures.local.json"), JSON.stringify(fixtures, null, 2) + "\n");
    }
    console.log("Marker-owned admin fixtures prepared");
  }
} finally { await db.$disconnect(); }
