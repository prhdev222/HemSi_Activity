import { createClient } from "@libsql/client/http";

function cleanEnv(value) {
  return String(value || "").trim().replace(/^['"]|['"]$/g, "");
}

export function createTursoClient(env) {
  const url = cleanEnv(env.TURSO_URL);
  const authToken = cleanEnv(env.TURSO_AUTH_TOKEN);

  if (!url || !authToken) {
    throw new Error("Missing TURSO_URL or TURSO_AUTH_TOKEN");
  }

  return createClient({ url, authToken });
}
