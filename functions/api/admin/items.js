// GET  /api/admin/items  — list all items (including hidden)
// POST /api/admin/items  — create new item

import { createTursoClient } from "../../../lib/turso.js";

async function verifyToken(request, env) {
  const auth = request.headers.get("Authorization") || "";
  const token = auth.replace("Bearer ", "").trim();
  if (!token) return false;
  try {
    const [ts, sigB64] = token.split(".");
    if (!ts || !sigB64) return false;
    if (Date.now() - parseInt(ts) > 8 * 60 * 60 * 1000) return false;
    const secret = env.ADMIN_SECRET || "elective-secret-change-me";
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey("raw", encoder.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["verify"]);
    const sigBytes = Uint8Array.from(atob(sigB64), (c) => c.charCodeAt(0));
    return await crypto.subtle.verify("HMAC", key, sigBytes, encoder.encode(ts));
  } catch { return false; }
}

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
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
  const { rows } = await db.execute(
    "SELECT id, sort_order, tag_th, tag_en, keywords_th, keywords_en, answer_th, answer_en, visible FROM items ORDER BY sort_order ASC"
  );

  const items = rows.map((r) => ({
    id: r[0], sort_order: r[1],
    tag_th: r[2], tag_en: r[3],
    keywords_th: r[4], keywords_en: r[5],
    answer_th: r[6], answer_en: r[7],
    visible: r[8],
  }));

  return new Response(JSON.stringify({ items }), { headers: CORS });
}

export async function onRequestPost({ request, env }) {
  if (!await verifyToken(request, env))
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: CORS });

  const body = await request.json();
  const db = createTursoClient(env);

  const { rows: maxRows } = await db.execute("SELECT COALESCE(MAX(sort_order),0) FROM items");
  const nextOrder = (maxRows[0][0] || 0) + 1;

  const { lastInsertRowid } = await db.execute({
    sql: "INSERT INTO items (sort_order, tag_th, tag_en, keywords_th, keywords_en, answer_th, answer_en, visible) VALUES (?,?,?,?,?,?,?,?)",
    args: [nextOrder, body.tag_th, body.tag_en, body.keywords_th, body.keywords_en, body.answer_th, body.answer_en, body.visible ?? 1],
  });

  return new Response(JSON.stringify({ id: Number(lastInsertRowid) }), { headers: CORS });
}
