export class NichePolicyError extends Error {
  constructor(message: string, readonly status = 409) { super(message); }
}
export type CategoryPolicy = { fulfillmentKind: "standard" | "packaged_food" | "fresh_food" };
export function categoryPolicy(input: Partial<CategoryPolicy>): CategoryPolicy {
  return { fulfillmentKind: input.fulfillmentKind ?? "standard" };
}
