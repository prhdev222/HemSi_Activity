// GET /api/admin/config  — get all config
// PUT /api/admin/config  — update a config key

import { createTursoClient } from "../../../lib/turso.js";
import { verifyToken } from "../../../lib/auth.js";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, PUT, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json",
};

export async function onRequestOptions() {
  return new Response(null, { headers: CORS });
}

export async function onRequestGet({ request, env }) {
  if (!await verifyToken(request, env))
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: CORS });

  const db = createTursoClient(env);
  const { rows } = await db.execute("SELECT key, value_th, value_en FROM config");
  const config = rows.map(r => ({ key: r[0], value_th: r[1], value_en: r[2] }));
  return new Response(JSON.stringify({ config }), { headers: CORS });
}

export async function onRequestPut({ request, env }) {
  if (!await verifyToken(request, env))
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: CORS });

  const body = await request.json();
  const db = createTursoClient(env);
  await db.execute({
    sql: "INSERT INTO config (key, value_th, value_en) VALUES (?,?,?) ON CONFLICT(key) DO UPDATE SET value_th=excluded.value_th, value_en=excluded.value_en",
    args: [body.key, body.value_th, body.value_en],
  });
  return new Response(JSON.stringify({ ok: true }), { headers: CORS });
}
