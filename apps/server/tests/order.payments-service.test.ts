import { beforeEach, describe, expect, it, mock } from "bun:test";
import {
  minorUnitsString,
  orderMoney,
} from "../src/modules/ecommerce/orders/payment-accounting";
let order: any;
let payments: any[];
let refunds: any[];
let events: any[];
const db: any = {
  order: {
    findUnique: mock(async () => ({ ...order, payments, refunds })),
    update: mock(async ({ data }: any) => Object.assign(order, data)),
  },
  orderPayment: {
    findUnique: mock(
      async ({ where }: any) =>
        payments.find((entry) =>
          Object.entries(where).every(([key, value]) => entry[key] === value),
        ) ?? null,
    ),
    create: mock(async ({ data }: any) => {
      const entry = { id: `payment-${payments.length + 1}`, ...data };
      payments.push(entry);
      return entry;
    }),
  },
  orderStatusEvent: {
    create: mock(async ({ data }: any) => {
      events.push(data);
      return data;
    }),
  },
};
db.$transaction = mock(async (work: any) => {
  const original = structuredClone({ order, payments, refunds, events });
  try {
    return await work(db);
  } catch (error) {
    ({ order, payments, refunds, events } = original);
    throw error;
  }
});
mock.module("@db/server", () => ({ default: db }));
mock.module("@env/server", () => ({ env: {} }));
const { orderPaymentsService } =
  await import("../src/modules/admin/orders/order-payments.service");
const input = {
  amount: "30.00",
  currency: "BDT",
  method: "manual_bank" as const,
  reference: "TX-1",
  note: "Bank statement confirmed",
};
function evidenced() {
  return { ...order, payments, refunds };
}
beforeEach(() => {
  order = {
    id: "order-1",
    orderNumber: "ORD-1",
    totalAmount: "100.00",
    currency: "BDT",
    paymentStatus: "unpaid",
    paymentMethod: "cash_on_delivery",
    orderStatus: "confirmed",
    deliveryStatus: "delivered",
    inventoryStatus: "committed",
    addresses: [
      {
        type: "shipping",
        fullName: "Fictional customer",
        phone: "01700000000",
        line1: "Fictional warehouse",
      },
    ],
  };
  payments = [];
  refunds = [];
  events = [];
});

describe("confirmed payment ledger", () => {
  it("records a deposit then final collection with exact outstanding COD", async () => {
    await orderPaymentsService.receive(order.id, input, "admin-1");
    expect(order.paymentStatus).toBe("partially_paid");
    expect(minorUnitsString(orderMoney(evidenced()).outstanding)).toBe("70.00");
    await orderPaymentsService.receive(
      order.id,
      { ...input, amount: "70", reference: "TX-2" },
      "admin-1",
    );
    expect(order.paymentStatus).toBe("paid");
    expect(minorUnitsString(orderMoney(evidenced()).outstanding)).toBe("0.00");
    expect(events).toHaveLength(2);
  });
  it("canonical duplicate reference replays once and conflicts on changed money or order", async () => {
    await orderPaymentsService.receive(order.id, input, "admin-1");
    await orderPaymentsService.receive(
      order.id,
      { ...input, reference: " tx-1 " },
      "admin-2",
    );
    expect(payments).toHaveLength(1);
    expect(events).toHaveLength(1);
    await expect(
      orderPaymentsService.receive(
        order.id,
        { ...input, amount: "31" },
        "admin-1",
      ),
    ).rejects.toMatchObject({ status: 409 });
    await expect(
      orderPaymentsService.receive("other-order", input, "admin-1"),
    ).rejects.toMatchObject({ status: 409 });
  });
  it.each([
    { amount: "100.01" },
    { currency: "USD" },
    { amount: "-1" },
    { amount: "0" },
    { amount: "1.001" },
  ])("rejects inconsistent collection %j", async (change) => {
    await expect(
      orderPaymentsService.receive(
        order.id,
        { ...input, ...change },
        "admin-1",
      ),
    ).rejects.toThrow();
    expect(payments).toHaveLength(0);
    expect(events).toHaveLength(0);
  });
  it("reverses mistaken evidence once without refunding", async () => {
    const receipt = await orderPaymentsService.receive(
      order.id,
      input,
      "admin-1",
    );
    await orderPaymentsService.reverse(
      order.id,
      receipt.id,
      "Bank reference belonged to another customer",
      "admin-1",
    );
    expect(order.paymentStatus).toBe("unpaid");
    expect(orderMoney(evidenced()).received).toBe(0n);
    expect(refunds).toHaveLength(0);
    await expect(
      orderPaymentsService.reverse(order.id, receipt.id, "Repeat", "admin-1"),
    ).rejects.toMatchObject({ status: 409 });
  });
  it("does not reverse refunded receipts or accept unevidenced legacy paid rows", async () => {
    const receipt = await orderPaymentsService.receive(
      order.id,
      input,
      "admin-1",
    );
    refunds.push({ amount: "10", currency: "BDT" });
    order.paymentStatus = "partially_refunded";
    await expect(
      orderPaymentsService.reverse(
        order.id,
        receipt.id,
        "Correction",
        "admin-1",
      ),
    ).rejects.toThrow("Refund exceeds");
    expect(payments).toHaveLength(1);
    payments = [];
    refunds = [];
    order.paymentStatus = "paid";
    await expect(
      orderPaymentsService.receive(order.id, input, "admin-1"),
    ).rejects.toThrow("Legacy payment status");
  });
  it("refunds do not create COD and partial-deposit refunds never exceed received", () => {
    payments = [
      { id: "p1", entryType: "receipt", amount: "100", currency: "BDT" },
    ];
    refunds = [{ amount: "20", currency: "BDT" }];
    order.paymentStatus = "partially_refunded";
    expect(minorUnitsString(orderMoney(evidenced()).outstanding)).toBe("0.00");
    payments[0].amount = "30";
    expect(minorUnitsString(orderMoney(evidenced()).outstanding)).toBe("70.00");
    refunds[0].amount = "31";
    expect(() => orderMoney(evidenced())).toThrow("Refund exceeds");
  });
});

it("records COD once without courier settlement evidence", async () => {
  const cash = {
    ...input,
    method: "cash_on_delivery" as const,
    amount: "100",
    reference: "CASH-ORDER-1",
    note: "Cash received from customer",
  };
  await orderPaymentsService.receive(order.id, cash, "staff");
  await orderPaymentsService.receive(order.id, cash, "staff");
  expect(order.paymentStatus).toBe("paid");
  expect(payments).toHaveLength(1);
  expect(orderMoney(evidenced()).outstanding).toBe(0n);
});
