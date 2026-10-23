import { beforeEach, describe, expect, it, mock } from "bun:test";
let order: any;
let events: any[];
const db: any = {
  order: {
    findUnique: mock(async () => ({ ...order })),
    update: mock(async ({ data }: any) => Object.assign(order, data)),
  },
  stockReservation: { findFirst: mock(async () => null) },
  orderStatusEvent: {
    create: mock(async ({ data }: any) => {
      events.push(data);
      return data;
    }),
  },
};
db.$transaction = mock(async (work: any) => work(db));
mock.module("@db/server", () => ({ default: db }));
const { orderFulfillmentService } =
  await import("../src/modules/admin/orders/fulfillment.service");
beforeEach(() => {
  events = [];
  order = {
    id: "order-1",
    orderStatus: "confirmed",
    inventoryStatus: "committed",
    deliveryStatus: "ready_to_ship",
    shippedAt: null,
    deliveredAt: null,
    paymentStatus: "unpaid",
  };
  db.stockReservation.findFirst.mockReset();
  db.stockReservation.findFirst.mockResolvedValue(null);
});
describe("manual cafe delivery", () => {
  it("hands a ready order over without carrier credentials or tracking", async () => {
    const result = await orderFulfillmentService.markShipped(
      order.id,
      { note: " Collected by delivery team " },
      { userId: "staff" },
    );
    expect(result.deliveryStatus).toBe("out_for_delivery");
    expect(result.shippedAt).toBeString();
    expect(order.paymentStatus).toBe("unpaid");
    expect(events[0]).toMatchObject({
      type: "delivery",
      previousValue: "ready_to_ship",
      newValue: "out_for_delivery",
      actorUserId: "staff",
      note: "Collected by delivery team",
    });
  });
  it.each(["unfulfilled", "preparing", "delivered"])(
    "rejects handover from %s",
    async (status) => {
      order.deliveryStatus = status;
      await expect(
        orderFulfillmentService.markShipped(order.id, {}, { userId: "staff" }),
      ).rejects.toThrow("Mark the order ready");
      expect(events).toHaveLength(0);
    },
  );
  it("rejects unavailable inventory", async () => {
    db.stockReservation.findFirst.mockResolvedValue({ id: "unsafe" });
    await expect(
      orderFulfillmentService.markShipped(order.id, {}, { userId: "staff" }),
    ).rejects.toThrow("Inventory expired");
  });
  it("rejects handover before the order is accepted", async () => {
    order.inventoryStatus = "reserved";
    await expect(
      orderFulfillmentService.markShipped(order.id, {}, {}),
    ).rejects.toThrow("Confirm the order");
  });
  it("records delivery without inventing a COD payment", async () => {
    await orderFulfillmentService.markShipped(
      order.id,
      {},
      { userId: "staff" },
    );
    const result = await orderFulfillmentService.markDelivered(
      order.id,
      { note: "Received by customer" },
      { userId: "staff" },
    );
    expect(result.deliveryStatus).toBe("delivered");
    expect(result.deliveredAt).toBeString();
    expect(order.paymentStatus).toBe("unpaid");
  });
  it("rejects delivery before handover and after cancellation", async () => {
    await expect(
      orderFulfillmentService.markDelivered(order.id, {}, {}),
    ).rejects.toThrow("Only a shipped order");
    order.orderStatus = "cancelled";
    await expect(
      orderFulfillmentService.markShipped(order.id, {}, {}),
    ).rejects.toThrow("cancelled order");
    await expect(
      orderFulfillmentService.markDelivered(order.id, {}, {}),
    ).rejects.toThrow("cancelled order");
  });
});
