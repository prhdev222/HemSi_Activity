// PUT    /api/admin/items/[id]  — update item
// DELETE /api/admin/items/[id]  — delete item

import { createTursoClient } from "../../../../lib/turso.js";
import { verifyToken } from "../../../../lib/auth.js";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json",
};

export async function onRequestOptions() {
  return new Response(null, { headers: CORS });
}

export async function onRequestPut({ request, env, params }) {
  if (!await verifyToken(request, env))
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: CORS });

  const id = params.id;
  const body = await request.json();
  const db = createTursoClient(env);

  await db.execute({
    sql: "UPDATE items SET tag_th=?, tag_en=?, keywords_th=?, keywords_en=?, answer_th=?, answer_en=?, visible_th=?, visible_en=?, sort_order=? WHERE id=?",
    args: [body.tag_th, body.tag_en, body.keywords_th, body.keywords_en, body.answer_th, body.answer_en, body.visible_th, body.visible_en, body.sort_order, id],
  });

  return new Response(JSON.stringify({ ok: true }), { headers: CORS });
}

export async function onRequestDelete({ request, env, params }) {
  if (!await verifyToken(request, env))
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: CORS });

  const id = params.id;
  const db = createTursoClient(env);
  await db.execute({ sql: "DELETE FROM items WHERE id=?", args: [id] });

  return new Response(JSON.stringify({ ok: true }), { headers: CORS });
}
