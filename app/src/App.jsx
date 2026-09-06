import { useState, useEffect } from "react";
import { base44 } from "@/api/base44Client";

// ── TPR profile door · the war-room ledger ──
const C = {
  page: "#10141C", card: "#1A2029", border: "#262D3A",
  ink: "#EDF1F7", dim: "#8B94A8", gold: "#F2C14E",
  ok: "#58D6A9", bad: "#E4574F",
};
const mono = '"DM Mono", ui-monospace, SFMono-Regular, Menlo, monospace';

const BOT = "tpr_zenbot";

function Shell({ user, agents }) {
  const [copied, setCopied] = useState(false);
  const copy = () => {
    navigator.clipboard?.writeText(user.telegram_id);
    setCopied(true); setTimeout(() => setCopied(false), 1200);
  };
  const signed = user.last_seen
    ? new Date(user.last_seen).toLocaleString()
    : "just now";
  return (
    <div style={{ maxWidth: 520, margin: "0 auto", padding: "22px 16px" }}>
      <div style={{ display: "flex", justifyContent: "space-between",
        alignItems: "baseline", marginBottom: 18 }}>
        <span style={{ color: C.gold, fontWeight: 700, letterSpacing: 1 }}>
          ▛▞ TelePromptR
        </span>
        <span style={{ color: C.dim, fontSize: 12 }}>your door</span>
      </div>

      {/* THE SHAPE — identity */}
      <div style={cardS}>
        <Row k="name" v={user.first_name || user.username || "—"} />
        <Row k="telegram id" v={
          <span>
            <span style={{ color: C.ink }}>{user.telegram_id}</span>
            <button onClick={copy} style={copyBtn}>
              {copied ? "copied" : "copy"}
            </button>
          </span>
        } />
        {user.username && <Row k="handle" v={"@" + user.username} />}
        <Row k="signed in" v={signed} />
      </div>

      {/* CONNECTED AGENTS */}
      <div style={{ ...cardS, marginTop: 14 }}>
        <div style={{ color: C.dim, fontSize: 12, marginBottom: 10,
          textTransform: "uppercase", letterSpacing: 1 }}>
          Connected agents
        </div>
        {agents && agents.length ? agents.map((a) => (
          <div key={a.id || a.handle} style={agentRow}>
            <span style={{ color: C.gold, width: 22 }}>{a.glyph || "▷"}</span>
            <span style={{ flex: 1 }}>
              <span style={{ color: C.ink, fontWeight: 600 }}>{a.name}</span>
              <span style={{ color: C.dim, marginLeft: 8, fontSize: 12 }}>
                {a.handle}{a.kind ? " · " + a.kind : ""}
              </span>
            </span>
            <span style={{ color: a.status === "connected" ? C.ok : C.dim,
              fontSize: 12 }}>{a.status || "—"}</span>
          </div>
        )) : (
          <div style={{ color: C.dim, fontSize: 13 }}>
            No agents yet. Add one to your room.
          </div>
        )}
      </div>
    </div>
  );
}

const cardS = { background: C.card, border: `1px solid ${C.border}`,
  borderRadius: 14, padding: 16 };
const agentRow = { display: "flex", alignItems: "center", gap: 6,
  padding: "8px 0", borderTop: `1px solid ${C.border}` };
const copyBtn = { marginLeft: 10, background: "transparent", color: C.gold,
  border: `1px solid ${C.border}`, borderRadius: 8, padding: "2px 8px",
  fontFamily: mono, fontSize: 11, cursor: "pointer" };

function Row({ k, v }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between",
      padding: "7px 0", fontSize: 14 }}>
      <span style={{ color: C.dim }}>{k}</span>
      <span style={{ color: C.ink, textAlign: "right" }}>{v}</span>
    </div>
  );
}

function Door({ reason }) {
  return (
    <div style={{ minHeight: "70vh", display: "grid", placeItems: "center",
      padding: 16 }}>
      <div style={{ ...cardS, maxWidth: 360, textAlign: "center" }}>
        <div style={{ color: C.gold, fontWeight: 700, marginBottom: 8 }}>
          ▛▞ TelePromptR
        </div>
        <div style={{ color: C.ink, marginBottom: 6 }}>
          {reason || "TelePromptR opens from Telegram"}
        </div>
        <a href={`https://t.me/${BOT}`} style={{
          display: "inline-block", marginTop: 12, background: C.gold,
          color: C.page, fontWeight: 700, textDecoration: "none",
          padding: "10px 18px", borderRadius: 10 }}>
          Open in Telegram
        </a>
      </div>
    </div>
  );
}

export default function App() {
  const [state, setState] = useState({ phase: "checking" });

  useEffect(() => {
    const tg = window.Telegram?.WebApp;
    try { tg?.ready(); tg?.expand(); } catch {}
    const initData = tg?.initData || "";
    if (!initData) { setState({ phase: "door" }); return; }
    (async () => {
      try {
        const res = await base44.functions.invoke("auth", { initData });
        const d = res.data;
        if (d?.ok) setState({ phase: "in", user: d.user, agents: d.agents || [] });
        else setState({ phase: "door", reason: "This link could not be verified. Open TPR again from Telegram." });
      } catch (e) {
        const reason = e?.response?.data?.reason
          || "This link could not be verified. Open TPR again from Telegram.";
        setState({ phase: "door", reason });
      }
    })();
  }, []);

  return (
    <div style={{ minHeight: "100dvh", background: C.page, color: C.ink,
      fontFamily: mono }}>
      {state.phase === "checking" && (
        <div style={{ minHeight: "70vh", display: "grid", placeItems: "center",
          color: C.dim }}>checking signature</div>
      )}
      {state.phase === "door" && <Door reason={state.reason} />}
      {state.phase === "in" && <Shell user={state.user} agents={state.agents} />}
    </div>
  );
}
