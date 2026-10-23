import "dotenv/config";
import { createEnv } from "@t3-oss/env-core";
import { getE2eServerEnvDefaults } from "@config";
import { z } from "zod";

if (process.env.E2E_MODE === "true" && process.env.NODE_ENV === "production") {
  throw new Error("E2E_MODE cannot be enabled in production");
}

const e2eDefaults =
  process.env.E2E_MODE === "true" ? getE2eServerEnvDefaults() : {};

export const env = createEnv({
  server: {
    BRAND: z.string().trim().pipe(z.enum(["foodshop", "bestsky", "airshop"])),
    DATABASE_URL: z.string().min(1),
    REDIS_URL: z.string().url(),
    REDIS_KEY_PREFIX: z.string().default("ts-starter:"),
    BETTER_AUTH_SECRET: z.string().min(32),
    BETTER_AUTH_URL: z.url(),
    GITHUB_CLIENT_ID: z.string().min(1),
    GITHUB_CLIENT_SECRET: z.string().min(1),
    GOOGLE_CLIENT_ID: z.string().min(1),
    GOOGLE_CLIENT_SECRET: z.string().min(1),
    AUTH_SESSION_COOKIE_NAME: z.string().min(1).default("better-auth.session_token"),
    AUTH_COOKIE_DOMAIN: z.string().min(1).optional(),
    E2E_MODE: z
      .string()
      .default("false")
      .transform((val) => val === "true"),
    CORS_ORIGIN: z.url(),
    NODE_ENV: z
      .enum(["development", "production", "test"])
      .default("development"),
    SMTP_HOST: z.string().optional(),
    SMTP_PORT: z.string().optional(),
    EMAIL: z.email().optional(),
    EMAIL_PASSWORD: z.string().optional(),
    EMAIL_FROM: z.string().optional(),
    FILE_SERVER_URL: z.string().url().optional(),
    FILE_SERVER_PUBLIC_URL: z.string().url().optional(),
    FILE_SERVER_API_KEY: z.string().optional(),
  },
  runtimeEnv: {
    ...process.env,
    ...e2eDefaults,
  },
  emptyStringAsUndefined: true,
});
