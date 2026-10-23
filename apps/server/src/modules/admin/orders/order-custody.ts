import type { Prisma } from "@db/server";
import { manualShipmentNeedsRecovery } from "../../ecommerce/orders/recovery-policy";

export async function orderNeedsPhysicalRecovery(
  tx: Prisma.TransactionClient,
  order: {
    id: string;
    shippedAt: Date | null;
    deliveredAt: Date | null;
    deliveryStatus: string;
  },
) {
  const statusEvents = await tx.orderStatusEvent.findMany({
    where: { orderId: order.id, type: "delivery" },
    select: { newValue: true },
  });
  return manualShipmentNeedsRecovery({ ...order, statusEvents });
}
