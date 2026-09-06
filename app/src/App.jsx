import { useState, useEffect } from "react";
import { base44 } from "@/api/base44Client";

const C = { page:"#10141C", card:"#1A2029", border:"#262D3A", ink:"#EDF1F7",
  dim:"#8B94A8", gold:"#F2C14E", ok:"#58D6A9", bad:"#E4574F" };
const mono = '"DM Mono", ui-monospace, SFMono-Regular, Menlo, monospace';
const BOT = "tpr_zenbot";
const cardS = { background:C.card, border:`1px solid ${C.border}`, borderRadius:14, padding:16 };
const goldBtn = { background:C.gold, color:C.page, fontWeight:700, border:"none",
  borderRadius:10, padding:"11px 18px", fontFamily:mono, cursor:"pointer", fontSize:14 };
const ghostBtn = { background:"transparent", color:C.gold, border:`1px solid ${C.border}`,
  borderRadius:10, padding:"7px 12px", fontFamily:mono, cursor:"pointer", fontSize:13 };
const inputS = { background:C.page, color:C.ink, border:`1px solid ${C.border}`,
  borderRadius:8, padding:"9px 11px", fontFamily:mono, fontSize:16, width:"100%", marginBottom:8 };

function Row({ k, v }) {
  return (<div style={{ display:"flex", justifyContent:"space-between", padding:"7px 0", fontSize:14 }}>
    <span style={{ color:C.dim }}>{k}</span><span style={{ color:C.ink, textAlign:"right" }}>{v}</span></div>);
}

function AddForm({ kind, onAdd, onCancel }) {
  const [name, setName] = useState(""); const [handle, setHandle] = useState("");
  const [busy, setBusy] = useState(false); const [err, setErr] = useState("");
  const submit = async () => {
    if (!name.trim()) { setErr("name is required"); return; }
    setBusy(true); setErr("");
    const r = await onAdd({ name: name.trim(), handle: handle.trim() });
    setBusy(false);
    if (r?.ok) { setName(""); setHandle(""); onCancel(); } else setErr(r?.reason || "failed");
  };
  return (
    <div style={{ padding:"10px 0" }}>
      <input style={inputS} placeholder={`${kind} name`} value={name} onChange={e=>setName(e.target.value)} />
      <input style={inputS} placeholder="handle / port / address (optional)" value={handle} onChange={e=>setHandle(e.target.value)} />
      {err && <div style={{ color:C.bad, fontSize:12, marginBottom:8 }}>{err}</div>}
      <div style={{ display:"flex", gap:8 }}>
        <button style={{ ...goldBtn, opacity:busy?0.6:1 }} disabled={busy} onClick={submit}>{busy?"adding…":"add"}</button>
        <button style={ghostBtn} onClick={onCancel}>cancel</button>
      </div>
    </div>
  );
}

function Section({ title, kind, items, onAdd }) {
  const [adding, setAdding] = useState(false);
  return (
    <div style={{ ...cardS, marginTop:14 }}>
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:6 }}>
        <span style={{ color:C.dim, fontSize:12, textTransform:"uppercase", letterSpacing:1 }}>{title}</span>
        {!adding && <button style={ghostBtn} onClick={()=>setAdding(true)}>+ add</button>}
      </div>
      {items && items.length ? items.map(a => (
        <div key={a.id||a.handle||a.name} style={{ display:"flex", alignItems:"center", gap:6, padding:"8px 0", borderTop:`1px solid ${C.border}` }}>
          <span style={{ color:C.gold, width:22 }}>{a.glyph||"▷"}</span>
          <span style={{ flex:1 }}>
            <span style={{ color:C.ink, fontWeight:600 }}>{a.name}</span>
            {(a.handle||a.kind) && <span style={{ color:C.dim, marginLeft:8, fontSize:12 }}>{a.handle}{a.kind?" · "+a.kind:""}</span>}
          </span>
          <span style={{ color:a.status==="connected"?C.ok:C.dim, fontSize:12 }}>{a.status||"—"}</span>
        </div>
      )) : !adding && <div style={{ color:C.dim, fontSize:13, paddingTop:6 }}>None yet.</div>}
      {adding && <AddForm kind={kind} onAdd={onAdd} onCancel={()=>setAdding(false)} />}
    </div>
  );
}

function Profile({ initData, user, data, refresh }) {
  const [copied, setCopied] = useState(false);
  const copy = () => { navigator.clipboard?.writeText(user.telegram_id); setCopied(true); setTimeout(()=>setCopied(false),1200); };
  const add = (kind) => async (fields) => {
    try {
      const r = await base44.functions.invoke("connect", { initData, kind, ...fields });
      if (r.data?.ok) { await refresh(); return { ok:true }; }
      return { ok:false, reason:r.data?.reason };
    } catch (e) { return { ok:false, reason: e?.response?.data?.reason || "failed" }; }
  };
  return (
    <div style={{ maxWidth:520, margin:"0 auto", padding:"22px 16px" }}>
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"baseline", marginBottom:18 }}>
        <span style={{ color:C.gold, fontWeight:700, letterSpacing:1 }}>▛▞ TelePromptR</span>
        <span style={{ color:C.dim, fontSize:12 }}>your door</span>
      </div>
      <div style={cardS}>
        <Row k="name" v={user.first_name || user.username || "—"} />
        <Row k="telegram id" v={<span><span style={{color:C.ink}}>{user.telegram_id}</span>
          <button onClick={copy} style={{ marginLeft:10, ...ghostBtn, padding:"2px 8px", fontSize:11 }}>{copied?"copied":"copy"}</button></span>} />
        {user.username && <Row k="handle" v={"@"+user.username} />}
      </div>
      <Section title="Agents"   kind="agent"   items={data.agents}   onAdd={add("agent")} />
      <Section title="Stations" kind="station" items={data.stations} onAdd={add("station")} />
      <Section title="Services" kind="service" items={data.services} onAdd={add("service")} />
    </div>
  );
}

function Landing({ name, onEnter }) {
  return (
    <div style={{ minHeight:"70vh", display:"grid", placeItems:"center", padding:16 }}>
      <div style={{ ...cardS, maxWidth:340, textAlign:"center" }}>
        <div style={{ color:C.gold, fontWeight:700, marginBottom:10, fontSize:18 }}>▛▞ TelePromptR</div>
        <div style={{ color:C.dim, marginBottom:4, fontSize:13 }}>signed in as</div>
        <div style={{ color:C.ink, marginBottom:16, fontWeight:600 }}>{name}</div>
        <button style={goldBtn} onClick={onEnter}>Enter your door</button>
      </div>
    </div>
  );
}

function Door({ reason }) {
  return (
    <div style={{ minHeight:"70vh", display:"grid", placeItems:"center", padding:16 }}>
      <div style={{ ...cardS, maxWidth:340, textAlign:"center" }}>
        <div style={{ color:C.gold, fontWeight:700, marginBottom:8 }}>▛▞ TelePromptR</div>
        <div style={{ color:C.ink, marginBottom:6 }}>{reason || "TelePromptR opens from Telegram"}</div>
        <a href={`https://t.me/${BOT}`} style={{ display:"inline-block", marginTop:12, ...goldBtn, textDecoration:"none" }}>Open in Telegram</a>
      </div>
    </div>
  );
}

export default function App() {
  const [phase, setPhase] = useState("checking");
  const [initData, setInitData] = useState("");
  const [user, setUser] = useState(null);
  const [data, setData] = useState({ agents:[], stations:[], services:[] });
  const [reason, setReason] = useState("");

  const runAuth = async (idata) => {
    const res = await base44.functions.invoke("auth", { initData: idata });
    return res.data;
  };
  const refresh = async () => {
    try { const d = await runAuth(initData);
      if (d?.ok) setData({ agents:d.agents||[], stations:d.stations||[], services:d.services||[] }); } catch {}
  };

  useEffect(() => {
    const tg = window.Telegram?.WebApp;
    try { tg?.ready(); tg?.expand(); } catch {}
    const idata = tg?.initData || "";
    if (!idata) { setPhase("door"); return; }
    setInitData(idata);
    (async () => {
      try {
        const d = await runAuth(idata);
        if (d?.ok) { setUser(d.user); setData({ agents:d.agents||[], stations:d.stations||[], services:d.services||[] }); setPhase("landing"); }
        else { setReason("This link could not be verified. Open TPR again from Telegram."); setPhase("door"); }
      } catch (e) { setReason(e?.response?.data?.reason || "This link could not be verified. Open TPR again from Telegram."); setPhase("door"); }
    })();
  }, []);

  return (
    <div style={{ minHeight:"100dvh", background:C.page, color:C.ink, fontFamily:mono }}>
      {phase==="checking" && <div style={{ minHeight:"70vh", display:"grid", placeItems:"center", color:C.dim }}>checking signature</div>}
      {phase==="door" && <Door reason={reason} />}
      {phase==="landing" && <Landing name={user?.first_name || user?.username || "you"} onEnter={()=>setPhase("in")} />}
      {phase==="in" && <Profile initData={initData} user={user} data={data} refresh={refresh} />}
    </div>
  );
}
