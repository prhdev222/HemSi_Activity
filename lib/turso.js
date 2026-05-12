import { createClient } from "@libsql/client/http";

function cleanEnv(value) {
  return String(value || "").trim().replace(/^['"]|['"]$/g, "");
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
  const url = cleanEnv(readEnv(env, "TURSO_URL"));
  const authToken = cleanEnv(readEnv(env, "TURSO_AUTH_TOKEN"));

  if (!url || !authToken) {
    throw new Error("Missing TURSO_URL or TURSO_AUTH_TOKEN");
  }

  return createClient({ url, authToken });
}
