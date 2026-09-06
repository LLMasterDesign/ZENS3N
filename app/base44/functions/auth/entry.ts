// TPR · auth — verify Telegram's Mini App signature, server side.
// Telegram is the only identity. This checks the proof; it never
// trusts initDataUnsafe. Token comes from the secret, never logged.
import { createClientFromRequest } from "npm:@base44/sdk";

const enc = new TextEncoder();

async function hmac(keyBytes: Uint8Array, msg: string): Promise<Uint8Array> {
  const key = await crypto.subtle.importKey(
    "raw", keyBytes, { name: "HMAC", hash: "SHA-256" }, false, ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, enc.encode(msg));
  return new Uint8Array(sig);
}

function toHex(b: Uint8Array): string {
  return Array.from(b).map((x) => x.toString(16).padStart(2, "0")).join("");
}

// constant-time hex compare
function sameHex(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}

export default async function (req: Request): Promise<Response> {
  const token = Deno.env.get("TELEGRAM_BOT_TOKEN");
  if (!token) {
    return Response.json({ ok: false, reason: "server not configured" }, { status: 500 });
  }

  let initData = "";
  try {
    const body = await req.json();
    initData = (body?.initData ?? "").toString();
  } catch {
    return Response.json({ ok: false, reason: "bad request" }, { status: 400 });
  }
  if (!initData) {
    return Response.json({ ok: false, reason: "no initData" }, { status: 400 });
  }

  // 1-2 · pull hash, build the data_check_string
  const params = new URLSearchParams(initData);
  const hash = params.get("hash") ?? "";
  params.delete("hash");
  const pairs: string[] = [];
  for (const [k, v] of params) pairs.push(`${k}=${v}`);
  pairs.sort();
  const dataCheckString = pairs.join("\n");

  // 3-4 · secret = HMAC("WebAppData", token); expected = HMAC(secret, dcs)
  const secret = await hmac(enc.encode("WebAppData"), token);
  const expected = toHex(await hmac(secret, dataCheckString));

  // 5 · constant-time compare
  if (!hash || !sameHex(expected, hash)) {
    return Response.json({ ok: false, reason: "signature does not match" }, { status: 401 });
  }

  // 6 · freshness + presence
  const authDate = Number(params.get("auth_date") ?? "0");
  const now = Math.floor(Date.now() / 1000);
  if (!authDate) {
    return Response.json({ ok: false, reason: "no auth_date" }, { status: 401 });
  }
  if (now - authDate > 3600) {
    return Response.json({ ok: false, reason: "expired — log in again" }, { status: 401 });
  }
  if (authDate - now > 300) {
    return Response.json({ ok: false, reason: "auth_date in the future" }, { status: 401 });
  }
  let user: any = null;
  try { user = JSON.parse(params.get("user") ?? "null"); } catch { /* ignore */ }
  if (!user?.id) {
    return Response.json({ ok: false, reason: "no user" }, { status: 401 });
  }

  // 7 · upsert User by telegram_id — one person, one row, forever.
  // Service role: the caller is a Telegram user with no Base44 auth,
  // so the login itself must write past RLS.
  const client = createClientFromRequest(req);
  const db = (client as any).asServiceRole ?? client;
  const tgId = String(user.id);
  const nowIso = new Date(now * 1000).toISOString();
  let row;
  try {
    const existing = await db.entities.Member.filter({ telegram_id: tgId });
    if (existing?.length) {
      row = await db.entities.Member.update(existing[0].id, {
        username: user.username ?? "",
        first_name: user.first_name ?? "",
        last_seen: nowIso,
      });
    } else {
      row = await db.entities.Member.create({
        telegram_id: tgId,
        username: user.username ?? "",
        first_name: user.first_name ?? "",
        created_at: nowIso,
        last_seen: nowIso,
      });
    }
  } catch (e) {
    return Response.json(
      { ok: false, reason: "user upsert failed", detail: String((e as any)?.message ?? e) },
      { status: 500 },
    );
  }

  // The connected agents shown on the profile door. Read past RLS
  // for the same reason the upsert is: the caller has no Base44 auth.
  let agents: any[] = [], stations: any[] = [], services: any[] = [];
  try { agents = await db.entities.Agent.list(); } catch { agents = []; }
  try { stations = await db.entities.Station.list(); } catch { stations = []; }
  try { services = await db.entities.Service.list(); } catch { services = []; }

  return Response.json({
    ok: true,
    user: {
      telegram_id: tgId,
      username: row.username,
      first_name: row.first_name,
      created_at: row.created_at,
      last_seen: row.last_seen,
    },
    agents, stations, services,
  });
}
