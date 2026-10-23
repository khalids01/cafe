import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { queryKeys } from "@/constants/query-keys";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { ecommerceApi } from "../apiCall";
import type { Order } from "../types";
import { formatDate, readError } from "../ui";
import { DeliveryStatusBadge } from "./status";

export function FulfillmentCard({
  order,
  canFulfill,
}: {
  order: Order;
  canFulfill: boolean;
}) {
  const queryClient = useQueryClient();
  const [note, setNote] = useState("");
  const update = useMutation({
    mutationFn: (
      action: "preparing" | "ready_to_ship" | "out_for_delivery" | "delivered",
    ) => {
      const body = { note: note.trim() || null };
      if (action === "out_for_delivery")
        return ecommerceApi.orders.markShipped(order.id, body);
      if (action === "delivered")
        return ecommerceApi.orders.markDelivered(order.id, body);
      return ecommerceApi.orders.updateStatuses(order.id, {
        deliveryStatus: action,
        note: body.note,
      });
    },
    onSuccess: () => {
      toast.success("Order updated");
      setNote("");
      void queryClient.invalidateQueries({
        queryKey: queryKeys.admin.ecommerce.orders.all(),
      });
    },
    onError: (error) =>
      toast.error(readError(error, "Could not update the order")),
  });
  const active =
    canFulfill &&
    !["cancelled", "completed"].includes(order.orderStatus) &&
    order.inventoryStatus === "committed";
  const action =
    order.deliveryStatus === "unfulfilled"
      ? "preparing"
      : order.deliveryStatus === "preparing"
        ? "ready_to_ship"
        : order.deliveryStatus === "ready_to_ship"
          ? "out_for_delivery"
          : ["shipped", "out_for_delivery"].includes(order.deliveryStatus)
            ? "delivered"
            : null;
  const labels = {
    preparing: "Start preparing",
    ready_to_ship: "Mark ready",
    out_for_delivery: "Mark out for delivery",
    delivered: "Mark delivered",
  };
  return (
    <section className="space-y-3 rounded-lg border p-4 sm:p-5">
      <h2 className="font-medium">Order preparation & delivery</h2>
      <DeliveryStatusBadge status={order.deliveryStatus} />
      <p className="text-sm text-muted-foreground">
        Update delivery manually after confirming with your delivery team.
      </p>
      {active && action ? (
        <>
          <label className="block space-y-2 text-sm">
            Optional note
            <Textarea
              value={note}
              maxLength={2000}
              onChange={(event) => setNote(event.target.value)}
            />
          </label>
          <Button
            disabled={update.isPending}
            onClick={() => update.mutate(action)}
          >
            {update.isPending ? "Saving…" : labels[action]}
          </Button>
        </>
      ) : null}
      {canFulfill &&
      order.inventoryStatus !== "committed" &&
      order.orderStatus !== "cancelled" ? (
        <p className="text-sm text-muted-foreground">
          Accept the order before starting preparation.
        </p>
      ) : null}
      {order.shippedAt ? (
        <p className="text-sm">
          Out for delivery: {formatDate(order.shippedAt)}
        </p>
      ) : null}
      {order.deliveredAt ? (
        <p className="text-sm">Delivered: {formatDate(order.deliveredAt)}</p>
      ) : null}
      {order.fulfillmentNote ? (
        <p className="text-sm">{order.fulfillmentNote}</p>
      ) : null}
    </section>
  );
}
