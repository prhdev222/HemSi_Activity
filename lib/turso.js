import { createClient } from "@libsql/client/http";

function cleanEnv(value, name) {
  let cleaned = String(value || "").trim().replace(/^['"]|['"]$/g, "");

  if (cleaned.toUpperCase().startsWith(`${name}=`)) {
    cleaned = cleaned.slice(name.length + 1).trim().replace(/^['"]|['"]$/g, "");
  }

  return cleaned;
}

function cleanUrl(value) {
  const cleaned = cleanEnv(value, "TURSO_URL");
  const match = cleaned.match(/(?:libsql|https?):\/\/[^\s'"]+/i);
  return match ? match[0] : cleaned;
}

function cleanAuthToken(value) {
  let cleaned = cleanEnv(value, "TURSO_AUTH_TOKEN");
  if (cleaned.toLowerCase().startsWith("bearer ")) {
    cleaned = cleaned.slice("bearer ".length).trim();
  }
  return cleaned;
}

function readEnv(env, name) {
  if (env && env[name] !== undefined) return env[name];

  const expected = name.trim().toUpperCase();
  for (const [key, value] of Object.entries(env || {})) {
    if (key.trim().toUpperCase() === expected) return value;
  }

  if (typeof process !== "undefined" && process.env) {
    return process.env[name];
  }

  return undefined;
}

export function createTursoClient(env) {
  const url = cleanUrl(readEnv(env, "TURSO_URL"));
  const authToken = cleanAuthToken(readEnv(env, "TURSO_AUTH_TOKEN"));

  if (!url || !authToken) {
    throw new Error("Missing TURSO_URL or TURSO_AUTH_TOKEN");
  }

  return createClient({ url, authToken });
}
