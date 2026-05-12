// GET /api/items — public, no auth required
// Returns all visible items from Turso

import { createClient } from "@libsql/client/web";

function turso(env) {
  return createClient({
    url: env.TURSO_URL,
    authToken: env.TURSO_AUTH_TOKEN,
  });
}

export async function onRequestGet({ env }) {
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  };

  try {
    const db = turso(env);

    const { rows } = await db.execute(
      "SELECT id, sort_order, tag_th, tag_en, keywords_th, keywords_en, answer_th, answer_en FROM items WHERE visible = 1 ORDER BY sort_order ASC"
    );

    const items = rows.map((r) => ({
      id: r[0],
      sort_order: r[1],
      tag: { th: r[2], en: r[3] },
      keywords: {
        th: r[4] ? r[4].split(",").map((k) => k.trim()) : [],
        en: r[5] ? r[5].split(",").map((k) => k.trim()) : [],
      },
      answer: { th: r[6], en: r[7] },
    }));

    const cfg = await db.execute(
      "SELECT key, value_th, value_en FROM config"
    );
    const config = {};
    cfg.rows.forEach((r) => {
      config[r[0]] = { th: r[1], en: r[2] };
    });

    return new Response(JSON.stringify({ items, config }), { headers });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers,
    });
  }
}
