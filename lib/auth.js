export async function verifyToken(request, env) {
  const auth = request.headers.get("Authorization") || "";
  const token = auth.replace("Bearer ", "").trim();
  if (!token) return false;
  try {
    const [ts, sigB64] = token.split(".");
    if (!ts || !sigB64) return false;
    if (Date.now() - parseInt(ts) > 8 * 60 * 60 * 1000) return false;
    const secret = env.ADMIN_SECRET;
    if (!secret) return false;
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw", encoder.encode(secret),
      { name: "HMAC", hash: "SHA-256" }, false, ["verify"]
    );
    const sigBytes = Uint8Array.from(atob(sigB64), (c) => c.charCodeAt(0));
    return await crypto.subtle.verify("HMAC", key, sigBytes, encoder.encode(ts));
  } catch { return false; }
}
