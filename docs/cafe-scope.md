# Cafe ordering scope

The application handles the menu, customer orders and staff order handling. Delivery is arranged outside the application. Checkout currently accepts cash on delivery only.

Staff accept an order, prepare it, mark it ready, record handover for delivery, and confirm delivery. Delivery updates are manual; the application does not book, track or pay delivery companies. Cash collection is recorded separately from delivery. An order is completed only after delivery and full payment evidence.

The order payment ledger, references, receipt reversals, currency and refund records remain available for future online payments. No online payment provider is configured. Recording a receipt or refund records evidence; it does not transfer money.

Removed: courier adapters/connections, assignment rules, dispatch/tracking workers, courier webhooks, parcel tracking identifiers, courier returns and COD payout settlements; gadget serial/IMEI registration and warranties; delivery-slot scheduling; Polar subscriptions, plan onboarding and billing; tutorial production and YouTube management; legacy non-food demo seeds. Their dedicated tests and simulator/load fixtures were retired with them.

Retained: menu categories and variants, item availability, stock reservation/expiry safeguards, customer addresses, delivery fees, discounts, account authentication and admin access controls. Inventory checks remain part of checkout. Prepared food cannot be restocked; cancellation and refunds do not automatically make food saleable again.

Only Prisma schema definitions changed. No migration SQL is created and no database changes are applied by this cleanup. Existing deployments need their schema synchronized through the operator's chosen process before running this version. Historical migrations remain unchanged. Review any existing courier settlement-linked receipts before discarding old courier data; their amounts and receipt history remain in the order ledger.

The remaining browser and database tests require a separately provisioned test environment. Build and isolated unit tests do not verify live delivery, cash receipt or online payment services.
