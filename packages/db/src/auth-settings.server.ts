import prisma from "./client.server";

const AUTH_SETTINGS_ID = "default";

export type AuthMethod = "github" | "google" | "magic-link" | "password";

export type AuthSettingsInput = {
  passwordSignInEnabled: boolean;
  passwordSignUpEnabled: boolean;
  githubSignInEnabled: boolean;
  githubSignUpEnabled: boolean;
  googleSignInEnabled: boolean;
  googleSignUpEnabled: boolean;
  magicLinkSignInEnabled: boolean;
  magicLinkSignUpEnabled: boolean;
};

const defaults: AuthSettingsInput = {
  passwordSignInEnabled: true,
  passwordSignUpEnabled: true,
  githubSignInEnabled: true,
  githubSignUpEnabled: true,
  googleSignInEnabled: true,
  googleSignUpEnabled: true,
  magicLinkSignInEnabled: true,
  magicLinkSignUpEnabled: true,
};

export async function getAuthSettings() {
  return prisma.authSettings.upsert({
    where: { id: AUTH_SETTINGS_ID },
    update: {},
    create: { id: AUTH_SETTINGS_ID, ...defaults },
  });
}

export async function updateAuthSettings(input: AuthSettingsInput) {
  return prisma.authSettings.upsert({
    where: { id: AUTH_SETTINGS_ID },
    update: input,
    create: { id: AUTH_SETTINGS_ID, ...input },
  });
}

export async function recordUserAuthMethod(userId: string, method: AuthMethod) {
  return prisma.userAuthMethod.upsert({
    where: { userId_method: { userId, method } },
    update: {},
    create: { userId, method },
  });
}
