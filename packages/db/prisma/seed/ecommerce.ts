import { seedBrandCatalog } from "./brand-catalog";
import prisma from "../../src/client.server";

export async function seedEcommerce() {
  return seedBrandCatalog(prisma, process.env);
}

if (import.meta.main) {
  if (process.argv.includes("--help") || process.argv.includes("-h")) {
    console.log("Usage: bun db:seed:ecommerce (local FoodShop demo menu only)");
  } else {
    try {
      await seedEcommerce();
    } finally {
      await prisma.$disconnect();
    }
  }
}
