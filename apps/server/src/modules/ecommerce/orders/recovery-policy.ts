export function manualShipmentNeedsRecovery(order: Readonly<{
  shippedAt: Date | null;
  deliveredAt: Date | null;
  deliveryStatus: string;
  statusEvents: readonly Readonly<{ newValue: string }>[];
}>) {
  return Boolean(order.shippedAt || order.deliveredAt)
    || !["unfulfilled", "preparing", "ready_to_ship"].includes(order.deliveryStatus)
    || order.statusEvents.some((event) =>
      ["shipped", "out_for_delivery", "delivered", "returned", "failed"].includes(event.newValue),
    );
}
