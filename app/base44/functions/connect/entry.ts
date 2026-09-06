// TPR · connect — add an agent, station, or service to your door.
// Gated by the SAME Telegram signature check as login: no valid
// signature, no write. Service-role create since the caller has no
// Base44 auth.
import { createClientFromRequest } from "npm:@base44/sdk";

const enc = new TextEncoder();
async function hmac(k: Uint8Array, m: string) {
  const key = await crypto.subtle.importKey("raw", k, { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  return new Uint8Array(await crypto.subtle.sign("HMAC", key, enc.encode(m)));
}
const hex = (b: Uint8Array) => Array.from(b).map((x) => x.toString(16).padStart(2, "0")).join("");
function eq(a: string, b: string) { if (a.length !== b.length) return false; let d = 0; for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i); return d === 0; }

const KINDS: Record<string, string> = { agent: "Agent", station: "Station", service: "Service" };

export default async function (req: Request): Promise<Response> {
  const token = Deno.env.get("TELEGRAM_BOT_TOKEN");
  if (!token) return Response.json({ ok: false, reason: "server not configured" }, { status: 500 });

  let body: any = {};
  try { body = await req.json(); } catch { return Response.json({ ok: false, reason: "bad request" }, { status: 400 }); }
  const initData = (body?.initData ?? "").toString();
  const kind = (body?.kind ?? "").toString().toLowerCase();
  const entity = KINDS[kind];
  if (!initData) return Response.json({ ok: false, reason: "no initData" }, { status: 400 });
  if (!entity) return Response.json({ ok: false, reason: "kind must be agent, station, or service" }, { status: 400 });
  if (!body?.name) return Response.json({ ok: false, reason: "name is required" }, { status: 400 });

  // verify signature (same as login)
  const params = new URLSearchParams(initData);
  const hash = params.get("hash") ?? ""; params.delete("hash");
  const pairs: string[] = []; for (const [k, v] of params) pairs.push(`${k}=${v}`); pairs.sort();
  const secret = await hmac(enc.encode("WebAppData"), token);
  const expected = hex(await hmac(secret, pairs.join("\n")));
  if (!hash || !eq(expected, hash)) return Response.json({ ok: false, reason: "signature does not match" }, { status: 401 });
  const authDate = Number(params.get("auth_date") ?? "0");
  const now = Math.floor(Date.now() / 1000);
  if (!authDate || now - authDate > 3600) return Response.json({ ok: false, reason: "expired — log in again" }, { status: 401 });
  let user: any = null; try { user = JSON.parse(params.get("user") ?? "null"); } catch {}
  if (!user?.id) return Response.json({ ok: false, reason: "no user" }, { status: 401 });

  const client = createClientFromRequest(req);
  const db = (client as any).asServiceRole ?? client;
  try {
    const row = await db.entities[entity].create({
      name: String(body.name),
      handle: String(body.handle ?? ""),
      kind: String(body.kind_label ?? ""),
      node: String(body.node ?? ""),
      status: "connected",
      glyph: String(body.glyph ?? "▷"),
      owner: String(user.id),
    });
    return Response.json({ ok: true, kind, item: row });
  } catch (e) {
    return Response.json({ ok: false, reason: "create failed", detail: String((e as any)?.message ?? e) }, { status: 500 });
  }
}
