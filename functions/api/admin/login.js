// POST /api/admin/login
// Body: { pin: "xxxx" }
// Returns: { token: "..." } valid for session

export async function onRequestPost({ request, env }) {
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  };

  try {
    const { pin } = await request.json();

    if (pin !== env.ADMIN_PIN) {
      return new Response(JSON.stringify({ error: "PIN ไม่ถูกต้อง" }), {
        status: 401,
        headers,
      });
    }

    const ts = Date.now().toString();
    const secret = env.ADMIN_SECRET;
    if (!secret) throw new Error("ADMIN_SECRET not configured");
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      encoder.encode(secret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const sig = await crypto.subtle.sign("HMAC", key, encoder.encode(ts));
    const token = ts + "." + btoa(String.fromCharCode(...new Uint8Array(sig)));

    return new Response(JSON.stringify({ token }), { headers });
  } catch (err) {
    console.error("login error:", err);
    return new Response(JSON.stringify({ error: "เกิดข้อผิดพลาด กรุณาลองใหม่" }), {
      status: 500,
      headers,
    });
  }
}

export async function onRequestOptions() {
  return new Response(null, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    },
  });
}
