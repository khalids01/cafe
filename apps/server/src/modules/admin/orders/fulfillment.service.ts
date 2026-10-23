import { orderHasUnsafeCommittedStock } from "../../ecommerce/inventory/stock-policy";
import prisma from "@db/server";
import type {
  MarkOrderDeliveredInput,
  MarkOrderShippedInput,
} from "./orders.dto";
import { AdminOrdersServiceError } from "./orders.service";

type FulfillmentActor = { userId?: string };

function text(value: string | null | undefined) {
  const normalized = value?.trim();
  return normalized || null;
}

function fulfillmentResult(order: any) {
  return {
    id: order.id,
    deliveryStatus: order.deliveryStatus,
    fulfillmentNote: order.fulfillmentNote,
    shippedAt: order.shippedAt?.toISOString?.() ?? order.shippedAt ?? null,
    deliveredAt: order.deliveredAt?.toISOString?.() ?? order.deliveredAt ?? null,
  };
}

export const orderFulfillmentService = {
  async markShipped(id: string, input: MarkOrderShippedInput, actor: FulfillmentActor) {
    return prisma.$transaction(async (tx) => {
      const current = await tx.order.findUnique({ where: { id } });
      if (!current) throw new AdminOrdersServiceError("Order not found", 404);
      if (current.orderStatus === "cancelled") {
        throw new AdminOrdersServiceError("A cancelled order cannot be shipped", 409);
      }
      if (current.inventoryStatus !== "committed") {
        throw new AdminOrdersServiceError("Confirm the order and commit its stock before shipping", 409);
      }
      if (current.deliveryStatus !== "ready_to_ship") {
        throw new AdminOrdersServiceError("Mark the order ready before handing it over for delivery", 409);
      }

      if (await orderHasUnsafeCommittedStock(tx, id)) throw new AdminOrdersServiceError("Inventory expired or is unavailable; review before shipping", 409);
      const note = text(input.note);
      const shippedAt = new Date();
      const updated = await tx.order.update({
        where: { id },
        data: {
          fulfillmentNote: note,
          deliveryStatus: "out_for_delivery",
          shippedAt,
        },
      });
      await tx.orderStatusEvent.create({
        data: {
          orderId: id,
          type: "delivery",
          previousValue: current.deliveryStatus,
          newValue: "out_for_delivery",
          note,
          actorUserId: actor.userId ?? null,
          metadata: { action: "out_for_delivery" },
        },
      });
      return fulfillmentResult(updated);
    }, { isolationLevel: "Serializable" });
  },

  async markDelivered(id: string, input: MarkOrderDeliveredInput, actor: FulfillmentActor) {
    return prisma.$transaction(async (tx) => {
      const current = await tx.order.findUnique({ where: { id } });
      if (!current) throw new AdminOrdersServiceError("Order not found", 404);
      if (current.orderStatus === "cancelled") throw new AdminOrdersServiceError("A cancelled order cannot be marked delivered", 409);
      if (!["shipped", "out_for_delivery"].includes(current.deliveryStatus)) {
        throw new AdminOrdersServiceError("Only a shipped order can be marked delivered", 409);
      }
      const note = text(input.note);
      const deliveredAt = new Date();
      const updated = await tx.order.update({
        where: { id },
        data: { deliveryStatus: "delivered", deliveredAt },
      });
      await tx.orderStatusEvent.create({
        data: {
          orderId: id,
          type: "delivery",
          previousValue: current.deliveryStatus,
          newValue: "delivered",
          note,
          actorUserId: actor.userId ?? null,
          metadata: { action: "mark_delivered", deliveredAt: deliveredAt.toISOString() },
        },
      });
      return fulfillmentResult(updated);
    }, { isolationLevel: "Serializable" });
  },
};
