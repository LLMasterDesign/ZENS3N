Yes. I translated what’s in your screenshots into a clean, viewport locked console layout that works on:

  

- PC browser
- Xbox Edge
- Cursor browser preview
- Telegram WebApp (embedded)

  

  

Core requirements you gave, implemented:

  

- No page scrolling: the page itself never scrolls. Only inner panels (status list, log, chat history) scroll if they overflow.
- Xbox Edge space priority: the left nav auto collapses to icons on Xbox or smaller widths, so the center dashboard gets room, and the chat stays on the right unless the screen is truly tight.
- Spacey obsidian theme: subtle star specks + slow shimmer drift, low intensity, respects reduced motion.
- Same overall structure as your screenshots: left nav, center dashboard with service status and quick actions, right agent list plus chat.

  

  

Tooling note: I tried to package this into a zip inside the environment, but the file service threw an error. So I’m giving you the complete drop in file set below. Create these files in a folder and you are live.

  

  

  

  

File tree

  

  

Create a folder like control-center/ and add:

control-center/

  index.html

  styles.css

  app.js

  manifest.webmanifest

  sw.js

  

  

  

  

index.html

  

<!doctype html>

<html lang="en">

  <head>

    <meta charset="UTF-8" />

    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />

    <title>3OX.AI Control Center</title>

  

    <!-- Optional: Telegram WebApp bridge (safe to leave in) -->

    <script src="https://telegram.org/js/telegram-web-app.js"></script>

  

    <link rel="stylesheet" href="./styles.css" />

    <link rel="manifest" href="./manifest.webmanifest" />

  </head>

  

  <body>

    <div class="app" id="appRoot">

      <!-- Left navigation -->

      <aside class="nav" id="nav">

        <div class="nav__top">

          <div class="brand">

            <div class="brand__title">3OX.AI</div>

            <div class="brand__subtitle">CONTROL CENTER</div>

          </div>

  

          <button class="iconBtn nav__collapse" id="navToggle" aria-label="Toggle navigation">

            <span class="iconBtn__glyph">☰</span>

          </button>

        </div>

  

        <nav class="nav__sections" aria-label="Primary navigation">

          <div class="nav__section">

            <div class="nav__sectionTitle">CORE SYSTEMS</div>

            <a class="nav__item isActive" href="#dashboard" data-route="dashboard">

              <span class="nav__icon">▣</span>

              <span class="nav__label">Dashboard</span>

            </a>

            <a class="nav__item" href="#gatekeeper" data-route="gatekeeper">

              <span class="nav__icon">🔒</span>

              <span class="nav__label">Gatekeeper</span>

            </a>

            <a class="nav__item" href="#tape" data-route="tape">

              <span class="nav__icon">🗄</span>

              <span class="nav__label">TAPE</span>

            </a>

            <a class="nav__item" href="#pulse" data-route="pulse">

              <span class="nav__icon">⚡</span>

              <span class="nav__label">PULSE</span>

            </a>

          </div>

  

          <div class="nav__section">

            <div class="nav__sectionTitle">AGENTS</div>

            <a class="nav__item" href="#agents" data-route="agents">

              <span class="nav__icon">🤖</span>

              <span class="nav__label">Agents</span>

            </a>

            <a class="nav__item" href="#metatron" data-route="metatron">

              <span class="nav__icon">🌐</span>

              <span class="nav__label">MetaTron</span>

            </a>

          </div>

  

          <div class="nav__section">

            <div class="nav__sectionTitle">INFRASTRUCTURE</div>

            <a class="nav__item" href="#services" data-route="services">

              <span class="nav__icon">🧩</span>

              <span class="nav__label">Services</span>

            </a>

          </div>

        </nav>

  

        <div class="nav__footer">

          <div class="pill pill--muted">

            <span class="pill__dot"></span>

            <span class="pill__text">Connected</span>

          </div>

          <div class="nav__hint">

            Xbox Edge: nav auto collapses to icons for max dashboard space.

          </div>

        </div>

      </aside>

  

      <!-- Main content -->

      <main class="main" id="main">

        <header class="main__header">

          <div>

            <h1 class="h1">Dashboard</h1>

            <div class="sub">System overview and quick actions</div>

          </div>

  

          <div class="headerActions">

            <button class="iconBtn" id="themeHint" title="Background is intentionally subtle">

              <span class="iconBtn__glyph">✦</span>

            </button>

          </div>

        </header>

  

        <section class="grid2">

          <!-- Service status list -->

          <div class="panel panel--tall">

            <div class="panel__title">SERVICE STATUS</div>

  

            <div class="statusList" id="statusList"></div>

  

            <div class="divider"></div>

  

            <div class="metaBlock">

              <div class="metaRow">

                <div class="metaKey">MERKLE ROOT</div>

                <div class="metaVal" id="merkleRoot">Pending</div>

              </div>

              <div class="metaRow">

                <div class="metaKey">CHAIN HEAD</div>

                <div class="metaVal mono" id="chainHead">2fe66ea403e87df6096e...</div>

              </div>

            </div>

          </div>

  

          <!-- Quick actions -->

          <div class="panel panel--tall">

            <div class="panel__title">QUICK ACTIONS</div>

  

            <div class="cardRow">

              <div class="card">

                <div class="card__title">

                  <span class="badge badge--gold">🔒</span>

                  Gatekeeper

                </div>

                <button class="btn btn--violet" data-action="gatekeeperPing">Test Ping</button>

              </div>

  

              <div class="card">

                <div class="card__title">

                  <span class="badge badge--neutral">🗄</span>

                  TAPE

                </div>

                <button class="btn btn--orange" data-action="tapeStats">Get Stats</button>

              </div>

  

              <div class="card">

                <div class="card__title">

                  <span class="badge badge--neutral">⚡</span>

                  PULSE

                </div>

                <button class="btn btn--teal" data-action="pulseStats">Get Stats</button>

              </div>

            </div>

  

            <div class="cardWide">

              <div class="cardWide__title">

                <span class="badge badge--neutral">🧪</span>

                Full System Test

              </div>

              <button class="btn btn--rainbow" data-action="fullTest">Run Full Test</button>

            </div>

  

            <div class="divider"></div>

  

            <div class="panel__title">SYSTEM STATUS</div>

            <div class="log" id="systemLog" aria-live="polite"></div>

          </div>

        </section>

  

        <section class="bottomBar">

          <div class="pill pill--ok">

            <span class="pill__dot"></span>

            <span class="pill__text">Gatekeeper: Online</span>

          </div>

          <div class="pill pill--ok">

            <span class="pill__dot"></span>

            <span class="pill__text">TAPE: Online</span>

          </div>

          <div class="pill pill--ok">

            <span class="pill__dot"></span>

            <span class="pill__text">PULSE: Online</span>

          </div>

        </section>

      </main>

  

      <!-- Right chat panel -->

      <aside class="chat" id="chat">

        <div class="chat__top">

          <div class="chat__title">ACTIVE AGENTS</div>

          <button class="iconBtn chat__collapse" id="chatToggle" aria-label="Toggle chat panel">

            <span class="iconBtn__glyph">≡</span>

          </button>

        </div>

  

        <div class="agentList" id="agentList"></div>

  

        <div class="divider"></div>

  

        <div class="chat__title">AGENT CHAT</div>

  

        <div class="chatBox" id="chatBox">

          <div class="chatHint">Chat ready. Select an agent and start a session.</div>

        </div>

  

        <form class="chatInputRow" id="chatForm" autocomplete="off">

          <input class="chatInput" id="chatInput" placeholder="Message an agent..." />

          <button class="btn btn--ghost" type="submit">Send</button>

        </form>

      </aside>

    </div>

  

    <script src="./app.js"></script>

  

    <script>

      if ("serviceWorker" in navigator) {

        navigator.serviceWorker.register("./sw.js").catch(() => {});

      }

    </script>

  </body>

</html>

  

  

  

  

styles.css

  

  

This is the layout lock. The key bits are body { overflow:hidden; } and .app { height:100dvh; } plus min-height:0 on nested flex and grid children so the browser is allowed to shrink them inside the viewport.

:root{

  --bg0: #05060a;

  --bg1: #070a12;

  --panel: rgba(14, 16, 26, 0.70);

  --panel2: rgba(10, 12, 18, 0.55);

  --stroke: rgba(255, 255, 255, 0.10);

  --stroke2: rgba(255, 255, 255, 0.06);

  --text: rgba(245, 248, 255, 0.92);

  

  --cyan: #34e4ff;

  --teal: #2ee7b6;

  --violet: #9b7bff;

  --orange: #ff8b3d;

  --red: #ff4b5e;

  

  --navW: 248px;

  --navWCollapsed: 76px;

  --chatW: 356px;

  --chatWCompact: 300px;

  

  --radius: 16px;

  --shadow: 0 14px 50px rgba(0,0,0,0.45);

  --blur: blur(10px);

  

  --font: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;

  --fontUi: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;

}

  

*{ box-sizing:border-box; }

html, body { height:100%; }

  

body{

  margin:0;

  color:var(--text);

  background: radial-gradient(1000px 700px at 18% 20%, rgba(52, 228, 255, 0.12), transparent 60%),

              radial-gradient(800px 600px at 80% 12%, rgba(155, 123, 255, 0.10), transparent 65%),

              radial-gradient(900px 700px at 45% 85%, rgba(46, 231, 182, 0.07), transparent 60%),

              linear-gradient(180deg, var(--bg1), var(--bg0));

  overflow:hidden;

  font-family: var(--fontUi);

}

  

/* Subtle shimmer */

body::before{

  content:"";

  position:fixed;

  inset:-20%;

  background:

    radial-gradient(500px 300px at 20% 20%, rgba(52, 228, 255, 0.08), transparent 60%),

    radial-gradient(520px 340px at 70% 30%, rgba(155, 123, 255, 0.07), transparent 65%),

    radial-gradient(560px 360px at 45% 75%, rgba(46, 231, 182, 0.05), transparent 65%),

    linear-gradient(110deg, rgba(255,255,255,0.03), transparent 40%, rgba(255,255,255,0.02), transparent 70%);

  opacity: 0.85;

  pointer-events:none;

  animation: drift 34s linear infinite;

}

  

body::after{

  content:"";

  position:fixed;

  inset:0;

  background:

    radial-gradient(1px 1px at 14% 22%, rgba(255,255,255,0.32), transparent 55%),

    radial-gradient(1px 1px at 33% 64%, rgba(255,255,255,0.22), transparent 55%),

    radial-gradient(1px 1px at 77% 18%, rgba(255,255,255,0.18), transparent 55%),

    radial-gradient(1px 1px at 82% 72%, rgba(255,255,255,0.14), transparent 55%),

    radial-gradient(1px 1px at 58% 40%, rgba(255,255,255,0.10), transparent 55%),

    radial-gradient(1px 1px at 22% 78%, rgba(255,255,255,0.12), transparent 55%),

    radial-gradient(1px 1px at 46% 52%, rgba(255,255,255,0.10), transparent 55%);

  opacity: 0.55;

  pointer-events:none;

}

  

@keyframes drift{

  0%{ transform: translate3d(0,0,0); }

  50%{ transform: translate3d(2.5%, -1.5%, 0); }

  100%{ transform: translate3d(0,0,0); }

}

  

@media (prefers-reduced-motion: reduce){

  body::before{ animation:none; }

}

  

/* App layout */

.app{

  height:100dvh;

  width:100%;

  display:grid;

  grid-template-columns: var(--navW) minmax(0, 1fr) var(--chatW);

  gap: 14px;

  padding: 14px;

}

  

.nav, .main, .chat{

  background: rgba(14, 16, 26, 0.70);

  border: 1px solid rgba(255, 255, 255, 0.10);

  border-radius: var(--radius);

  box-shadow: var(--shadow);

  backdrop-filter: var(--blur);

  overflow:hidden;

  position:relative;

}

  

/* Buttons and atoms */

.iconBtn{

  border: 1px solid rgba(255,255,255,0.10);

  background: rgba(0,0,0,0.18);

  color: rgba(245,248,255,0.86);

  border-radius: 12px;

  padding: 10px 12px;

  cursor:pointer;

  display:inline-flex;

  align-items:center;

  justify-content:center;

}

.iconBtn:hover{

  border-color: rgba(52,228,255,0.22);

  background: rgba(52,228,255,0.06);

}

.iconBtn__glyph{ font-family: var(--font); letter-spacing:0.06em; }

  

.btn{

  width: 100%;

  border: 1px solid rgba(255,255,255,0.10);

  background: rgba(255,255,255,0.04);

  color: rgba(245,248,255,0.88);

  border-radius: 14px;

  padding: 12px 12px;

  cursor:pointer;

  font-family: var(--font);

  letter-spacing: 0.08em;

  font-size: 12px;

}

.btn:hover{ border-color: rgba(255,255,255,0.16); }

  

.btn--violet{ background: rgba(155,123,255,0.18); border-color: rgba(155,123,255,0.28); }

.btn--orange{ background: rgba(255,139,61,0.16); border-color: rgba(255,139,61,0.28); }

.btn--teal{ background: rgba(46,231,182,0.14); border-color: rgba(46,231,182,0.24); }

.btn--ghost{ width:auto; padding: 10px 14px; border-radius: 12px; background: rgba(0,0,0,0.22); }

.btn--rainbow{

  background: linear-gradient(90deg, rgba(155,123,255,0.24), rgba(52,228,255,0.22), rgba(46,231,182,0.22), rgba(255,139,61,0.20));

  border-color: rgba(255,255,255,0.12);

}

  

/* Pills */

.pill{

  display:inline-flex;

  align-items:center;

  gap: 8px;

  padding: 8px 12px;

  border-radius: 999px;

  border: 1px solid rgba(255,255,255,0.10);

  background: rgba(0,0,0,0.18);

  font-family: var(--font);

  font-size: 11px;

  letter-spacing: 0.06em;

  color: rgba(245,248,255,0.80);

}

.pill__dot{

  width: 9px;

  height: 9px;

  border-radius: 999px;

  background: rgba(245,248,255,0.30);

}

.pill--ok{ border-color: rgba(46,231,182,0.22); background: rgba(46,231,182,0.06); }

.pill--ok .pill__dot{ background: rgba(46,231,182,0.92); }

.pill--muted{ border-color: rgba(52,228,255,0.18); background: rgba(52,228,255,0.05); }

.pill--muted .pill__dot{ background: rgba(52,228,255,0.82); }

  

/* NAV */

.nav{

  display:flex;

  flex-direction:column;

  min-width:0;

}

.nav__top{

  display:flex;

  align-items:center;

  justify-content:space-between;

  padding: 14px 14px 10px;

  border-bottom: 1px solid rgba(255,255,255,0.06);

}

.brand__title{

  font-family: var(--font);

  font-weight: 900;

  letter-spacing: 0.18em;

  font-size: 18px;

  color: var(--cyan);

  text-shadow: 0 0 18px rgba(52,228,255,0.25);

}

.brand__subtitle{

  font-family: var(--font);

  letter-spacing: 0.12em;

  font-size: 11px;

  color: rgba(245,248,255,0.65);

  margin-top: 2px;

}

  

.nav__sections{

  padding: 12px 10px;

  overflow:auto;

}

.nav__section{ margin-bottom: 14px; }

.nav__sectionTitle{

  font-family: var(--font);

  font-size: 11px;

  letter-spacing: 0.14em;

  color: rgba(245,248,255,0.55);

  padding: 10px 10px 8px;

}

.nav__item{

  display:flex;

  align-items:center;

  gap: 10px;

  padding: 10px 10px;

  margin: 4px 6px;

  border-radius: 12px;

  text-decoration:none;

  color: rgba(245,248,255,0.80);

  border: 1px solid transparent;

}

.nav__item:hover{

  border-color: rgba(52,228,255,0.18);

  background: rgba(52,228,255,0.06);

}

.nav__item.isActive{

  border-color: rgba(52,228,255,0.32);

  background: rgba(52,228,255,0.08);

}

.nav__icon{ width: 22px; text-align:center; }

.nav__label{ font-family: var(--font); font-size: 13px; letter-spacing: 0.04em; }

  

.nav__footer{

  margin-top:auto;

  padding: 12px 12px 14px;

  border-top: 1px solid rgba(255,255,255,0.06);

  display:grid;

  gap: 10px;

}

.nav__hint{ font-size: 12px; color: rgba(245,248,255,0.55); line-height: 1.35; }

  

/* MAIN */

.main{

  display:flex;

  flex-direction:column;

  min-width:0;

}

.main__header{

  display:flex;

  align-items:flex-start;

  justify-content:space-between;

  padding: 16px 18px 8px;

  border-bottom: 1px solid rgba(255,255,255,0.06);

}

.h1{

  margin: 0;

  font-family: var(--font);

  letter-spacing: 0.10em;

  font-size: 22px;

}

.sub{

  margin-top: 4px;

  color: rgba(245,248,255,0.62);

  font-size: 12px;

}

  

.grid2{

  flex: 1;

  display:grid;

  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);

  gap: 14px;

  padding: 14px;

  min-height:0;

}

  

.panel{

  background: rgba(10, 12, 18, 0.55);

  border: 1px solid rgba(255,255,255,0.06);

  border-radius: var(--radius);

  padding: 12px;

  min-width:0;

  min-height:0;

  overflow:hidden;

}

.panel--tall{ display:flex; flex-direction:column; }

.panel__title{

  font-family: var(--font);

  letter-spacing: 0.14em;

  font-size: 12px;

  color: rgba(245,248,255,0.70);

  margin: 4px 4px 10px;

}

  

.divider{ height:1px; background: rgba(255,255,255,0.06); margin: 12px 0; }

  

.statusList{

  display:grid;

  gap: 10px;

  overflow:auto;

  padding: 4px;

  min-height:0;

}

  

.statusItem{

  display:grid;

  grid-template-columns: 10px 1fr auto;

  align-items:center;

  gap: 10px;

  padding: 10px 10px;

  border-radius: 14px;

  border: 1px solid rgba(255,255,255,0.06);

  background: rgba(0,0,0,0.18);

}

.statusItem__bar{ width: 4px; height: 100%; border-radius: 999px; background: rgba(255,255,255,0.10); }

.statusItem__name{ font-family: var(--font); letter-spacing: 0.08em; font-size: 12px; }

.statusItem__state{

  font-family: var(--font);

  font-size: 12px;

  letter-spacing: 0.06em;

  padding: 6px 10px;

  border-radius: 999px;

  border: 1px solid rgba(255,255,255,0.08);

  background: rgba(255,255,255,0.03);

}

  

.statusItem.isOnline .statusItem__bar{ background: rgba(46,231,182,0.85); }

.statusItem.isOffline .statusItem__bar{ background: rgba(255,75,94,0.85); }

  

.metaBlock{ display:grid; gap: 10px; padding: 4px; }

.metaKey{ font-family: var(--font); font-size: 11px; letter-spacing: 0.14em; color: rgba(245,248,255,0.55); }

.metaVal{ font-size: 13px; color: rgba(245,248,255,0.82); }

.mono{ font-family: var(--font); letter-spacing: 0.04em; }

  

/* Cards */

.cardRow{

  display:grid;

  grid-template-columns: repeat(3, minmax(0, 1fr));

  gap: 12px;

  margin-bottom: 12px;

}

.card, .cardWide{

  background: rgba(0,0,0,0.20);

  border: 1px solid rgba(255,255,255,0.07);

  border-radius: var(--radius);

  padding: 12px;

  display:grid;

  gap: 10px;

}

.card__title, .cardWide__title{

  font-family: var(--font);

  letter-spacing: 0.10em;

  font-size: 12px;

  display:flex;

  align-items:center;

  gap: 10px;

}

  

/* Log */

.log{

  flex: 1;

  min-height: 0;

  overflow:auto;

  border-radius: var(--radius);

  border: 1px solid rgba(255,255,255,0.06);

  background: rgba(0,0,0,0.20);

  padding: 12px;

  font-family: var(--font);

  font-size: 12px;

  color: rgba(245,248,255,0.75);

  line-height: 1.55;

}

.logLine{ padding: 6px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }

.logLine:last-child{ border-bottom:none; }

.logTag{ display:inline-block; min-width: 86px; color: rgba(52,228,255,0.86); }

  

.bottomBar{

  display:flex;

  gap: 10px;

  padding: 0 14px 14px;

  overflow:hidden;

}

  

/* CHAT */

.chat{

  display:flex;

  flex-direction:column;

  min-width:0;

}

.chat__top{

  display:flex;

  align-items:center;

  justify-content:space-between;

  padding: 14px 14px 10px;

  border-bottom: 1px solid rgba(255,255,255,0.06);

}

.chat__title{

  font-family: var(--font);

  letter-spacing: 0.14em;

  font-size: 12px;

  color: rgba(245,248,255,0.70);

}

.agentList{

  padding: 10px;

  display:grid;

  gap: 10px;

  overflow:auto;

  min-height:0;

}

.agentPill{

  display:flex;

  align-items:center;

  justify-content:space-between;

  gap: 10px;

  padding: 10px 10px;

  border-radius: 14px;

  border: 1px solid rgba(255,255,255,0.07);

  background: rgba(0,0,0,0.18);

  cursor:pointer;

}

.agentPill:hover{ border-color: rgba(52,228,255,0.18); background: rgba(52,228,255,0.05); }

.agentPill.isActive{ border-color: rgba(52,228,255,0.30); background: rgba(52,228,255,0.07); }

.agentName{ font-family: var(--font); letter-spacing: 0.08em; font-size: 12px; }

.agentRole{ font-size: 11px; color: rgba(245,248,255,0.55); }

.agentTag{

  font-family: var(--font);

  font-size: 11px;

  letter-spacing:0.06em;

  padding: 6px 10px;

  border-radius: 999px;

  border: 1px solid rgba(255,255,255,0.08);

  background: rgba(255,255,255,0.03);

}

  

.chatBox{

  flex: 1;

  min-height: 0;

  margin: 10px;

  overflow:auto;

  border-radius: var(--radius);

  border: 1px solid rgba(255,255,255,0.06);

  background: rgba(0,0,0,0.20);

  padding: 12px;

  display:flex;

  flex-direction:column;

  gap: 10px;

}

.chatHint{ color: rgba(245,248,255,0.55); font-size: 12px; line-height: 1.45; }

  

.bubble{

  max-width: 92%;

  border-radius: 14px;

  padding: 10px 10px;

  border: 1px solid rgba(255,255,255,0.08);

  background: rgba(255,255,255,0.04);

  font-size: 12px;

  line-height: 1.45;

}

.bubble.me{ margin-left:auto; border-color: rgba(52,228,255,0.20); background: rgba(52,228,255,0.06); }

.bubble.agent{ border-color: rgba(155,123,255,0.18); background: rgba(155,123,255,0.06); }

.bubbleMeta{ font-family: var(--font); letter-spacing: 0.06em; font-size: 10px; opacity: 0.72; margin-bottom: 4px; }

  

.chatInputRow{

  display:flex;

  gap: 10px;

  padding: 10px;

  border-top: 1px solid rgba(255,255,255,0.06);

}

.chatInput{

  flex: 1;

  border-radius: 12px;

  border: 1px solid rgba(255,255,255,0.10);

  background: rgba(0,0,0,0.20);

  padding: 12px 12px;

  color: rgba(245,248,255,0.88);

  outline:none;

  font-size: 13px;

}

.chatInput:focus{

  border-color: rgba(52,228,255,0.22);

  box-shadow: 0 0 0 3px rgba(52,228,255,0.10);

}

  

/* Collapsed nav */

.app.isNavCollapsed{

  grid-template-columns: var(--navWCollapsed) minmax(0, 1fr) var(--chatW);

}

.app.isNavCollapsed .nav__label,

.app.isNavCollapsed .nav__sectionTitle,

.app.isNavCollapsed .nav__hint,

.app.isNavCollapsed .brand__subtitle{ display:none; }

.app.isNavCollapsed .brand__title{ font-size: 14px; letter-spacing: 0.12em; }

.app.isNavCollapsed .nav__item{ justify-content:center; }

.app.isNavCollapsed .nav__top{ padding: 14px 10px 10px; }

.app.isNavCollapsed .nav__collapse{ width: 100%; }

  

/* Collapsed chat */

.app.isChatCollapsed{

  grid-template-columns: var(--navW) minmax(0, 1fr) 64px;

}

.app.isChatCollapsed .chat__title,

.app.isChatCollapsed .agentList,

.app.isChatCollapsed .chatBox,

.app.isChatCollapsed .chatInputRow,

.app.isChatCollapsed .divider{ display:none; }

.app.isChatCollapsed .chat__top{ justify-content:center; }

.app.isChatCollapsed .chat__collapse{ width: 100%; }

  

/* Responsive tuning */

@media (max-width: 1400px){

  .app{ grid-template-columns: var(--navW) minmax(0, 1fr) var(--chatWCompact); }

  .cardRow{ grid-template-columns: 1fr; }

  .grid2{ grid-template-columns: 1fr; }

}

  

@media (max-width: 1180px){

  .app{ grid-template-columns: var(--navWCollapsed) minmax(0, 1fr) var(--chatWCompact); }

  .nav__label, .nav__sectionTitle, .nav__hint, .brand__subtitle{ display:none; }

  .nav__item{ justify-content:center; }

}

  

@media (max-width: 860px){

  .app{

    grid-template-columns: 1fr;

    grid-template-rows: auto 1fr;

    gap: 12px;

  }

  .chat{ display:none; }

  .bottomBar{ flex-wrap: wrap; }

}

  

  

  

  

app.js

  

  

This is the auto collapse brain plus demo actions. It also calls Telegram WebApp expand when running inside Telegram.

(function(){

  const root = document.getElementById("appRoot");

  const statusList = document.getElementById("statusList");

  const systemLog = document.getElementById("systemLog");

  const agentList = document.getElementById("agentList");

  const chatBox = document.getElementById("chatBox");

  const chatForm = document.getElementById("chatForm");

  const chatInput = document.getElementById("chatInput");

  

  const navToggle = document.getElementById("navToggle");

  const chatToggle = document.getElementById("chatToggle");

  

  const merkleRoot = document.getElementById("merkleRoot");

  const chainHead = document.getElementById("chainHead");

  

  const state = {

    selectedAgent: null,

    services: [

      { key:"gatekeeper", name:"GATEKEEPER", state:"Online" },

      { key:"tape", name:"TAPE", state:"Online" },

      { key:"pulse", name:"PULSE", state:"Online" }

    ],

    agents: [

      { name:"MetaTron", tag:"m3", role:"Orchestrator" },

      { name:"Zens3n", tag:"z3", role:"Base Identity" },

      { name:"Obsidian", tag:"o3", role:"System Base" },

      { name:"Citadel", tag:"c3", role:"System Base" }

    ]

  };

  

  function el(tag, cls){

    const n = document.createElement(tag);

    if(cls) n.className = cls;

    return n;

  }

  

  function nowStamp(){

    const d = new Date();

    const hh = String(d.getHours()).padStart(2, "0");

    const mm = String(d.getMinutes()).padStart(2, "0");

    const ss = String(d.getSeconds()).padStart(2, "0");

    return `${hh}:${mm}:${ss}`;

  }

  

  function log(tag, msg){

    const line = el("div", "logLine");

    const t = el("span", "logTag");

    t.textContent = `[${tag}]`;

    const m = el("span");

    m.textContent = ` ${nowStamp()}  ${msg}`;

    line.appendChild(t);

    line.appendChild(m);

    systemLog.prepend(line);

  }

  

  function setSelectedAgent(name){

    state.selectedAgent = name;

    [...agentList.querySelectorAll(".agentPill")].forEach(p => {

      p.classList.toggle("isActive", p.dataset.name === name);

    });

  

    const hint = chatBox.querySelector(".chatHint");

    if(hint) hint.remove();

  

    const bubble = el("div", "bubble agent");

    const meta = el("div", "bubbleMeta");

    meta.textContent = `${name}  :: session.open`;

    const body = el("div");

    body.textContent = "Connected. Send a message.";

    bubble.appendChild(meta);

    bubble.appendChild(body);

    chatBox.appendChild(bubble);

    chatBox.scrollTop = chatBox.scrollHeight;

  }

  

  function pushChatBubble(kind, who, text){

    const b = el("div", `bubble ${kind}`);

    const meta = el("div", "bubbleMeta");

    meta.textContent = `${who}  :: ${nowStamp()}`;

    const body = el("div");

    body.textContent = text;

    b.appendChild(meta);

    b.appendChild(body);

    chatBox.appendChild(b);

    chatBox.scrollTop = chatBox.scrollHeight;

  }

  

  function renderStatus(){

    statusList.innerHTML = "";

    state.services.forEach(s => {

      const row = el("div", "statusItem");

      row.classList.add(s.state === "Online" ? "isOnline" : "isOffline");

  

      const bar = el("div", "statusItem__bar");

      const name = el("div", "statusItem__name");

      name.textContent = s.name;

  

      const st = el("div", "statusItem__state");

      st.textContent = s.state;

  

      row.appendChild(bar);

      row.appendChild(name);

      row.appendChild(st);

  

      statusList.appendChild(row);

    });

  }

  

  function renderAgents(){

    agentList.innerHTML = "";

    state.agents.forEach(a => {

      const pill = el("div", "agentPill");

      pill.dataset.name = a.name;

  

      const left = el("div");

      const nm = el("div", "agentName");

      nm.textContent = `${a.name} [${a.tag}]`;

      const rl = el("div", "agentRole");

      rl.textContent = a.role;

  

      left.appendChild(nm);

      left.appendChild(rl);

  

      const tag = el("div", "agentTag");

      tag.textContent = "Online";

  

      pill.appendChild(left);

      pill.appendChild(tag);

  

      pill.addEventListener("click", () => setSelectedAgent(a.name));

      agentList.appendChild(pill);

    });

  }

  

  function isXboxEdge(){

    const ua = navigator.userAgent || "";

    return /Xbox/i.test(ua);

  }

  

  function syncAutoCollapse(){

    const w = window.innerWidth;

  

    if(isXboxEdge() || w < 1200){

      root.classList.add("isNavCollapsed");

    } else {

      root.classList.remove("isNavCollapsed");

    }

  

    if(w < 1050){

      root.classList.add("isChatCollapsed");

    } else {

      root.classList.remove("isChatCollapsed");

    }

  }

  

  navToggle?.addEventListener("click", () => root.classList.toggle("isNavCollapsed"));

  chatToggle?.addEventListener("click", () => root.classList.toggle("isChatCollapsed"));

  

  function action(name){

    if(name === "gatekeeperPing"){

      log("gatekeeper", "Ping ok");

      return;

    }

    if(name === "tapeStats"){

      log("tape", "Stats: receipts=128, queues=3, latency=14ms");

      return;

    }

    if(name === "pulseStats"){

      log("pulse", "Stats: heartbeat=stable, drift=0.02, last_pulse=2s");

      return;

    }

    if(name === "fullTest"){

      log("system", "Full test started");

      setTimeout(() => log("system", "Gatekeeper ok"), 500);

      setTimeout(() => log("system", "TAPE ok"), 900);

      setTimeout(() => log("system", "PULSE ok"), 1200);

      setTimeout(() => {

        log("system", "Merkle root computed");

        merkleRoot.textContent = "Ready";

        chainHead.textContent = "2fe66ea403e87df6096e... (updated)";

      }, 1500);

      return;

    }

  }

  

  document.querySelectorAll("[data-action]").forEach(btn => {

    btn.addEventListener("click", () => action(btn.dataset.action));

  });

  

  chatForm?.addEventListener("submit", (e) => {

    e.preventDefault();

    const txt = (chatInput.value || "").trim();

    if(!txt) return;

  

    if(!state.selectedAgent){

      pushChatBubble("me", "me", txt);

      pushChatBubble("agent", "system", "Select an agent first.");

      chatInput.value = "";

      return;

    }

  

    pushChatBubble("me", "me", txt);

    chatInput.value = "";

  

    setTimeout(() => {

      pushChatBubble("agent", state.selectedAgent, "Ack. Message queued to TAPE and stamped in _TRON.");

      log("chat", `msg -> ${state.selectedAgent} queued`);

    }, 240);

  });

  

  document.querySelectorAll(".nav__item[data-route]").forEach(a => {

    a.addEventListener("click", () => {

      document.querySelectorAll(".nav__item").forEach(x => x.classList.remove("isActive"));

      a.classList.add("isActive");

    });

  });

  

  try{

    if(window.Telegram && Telegram.WebApp){

      Telegram.WebApp.ready();

      Telegram.WebApp.expand();

      Telegram.WebApp.setHeaderColor && Telegram.WebApp.setHeaderColor("#05060a");

      Telegram.WebApp.setBackgroundColor && Telegram.WebApp.setBackgroundColor("#05060a");

    }

  }catch(err){}

  

  renderStatus();

  renderAgents();

  log("system", "UI booted");

  log("system", "Viewport locked: no page scroll, panels scroll internally");

  

  syncAutoCollapse();

  window.addEventListener("resize", syncAutoCollapse);

})();

  

  

  

  

manifest.webmanifest

  

{

  "name": "3OX.AI Control Center",

  "short_name": "3OX.AI",

  "start_url": "./index.html",

  "display": "standalone",

  "background_color": "#05060a",

  "theme_color": "#05060a",

  "icons": []

}

  

  

  

  

sw.js

  

self.addEventListener("install", (event) => {

  event.waitUntil(

    caches.open("3ox-ui-v1").then((cache) => {

      return cache.addAll([

        "./",

        "./index.html",

        "./styles.css",

        "./app.js",

        "./manifest.webmanifest"

      ]);

    })

  );

});

  

self.addEventListener("fetch", (event) => {

  event.respondWith(

    caches.match(event.request).then((resp) => resp || fetch(event.request))

  );

});

  

  

  

  

How to run it fast (local, WSL, Cursor preview)

  

  

  

Local quick run

  

  

From the control-center/ folder:

python3 -m http.server 8080

Open:

http://localhost:8080

  

Deploy to 1n3ox.ai (static hosting)

  

  

This is static front end. Any of these works:

  

- Nginx serving the folder
- Caddy serving the folder
- Phoenix endpoint serving static
- A tiny Node server

  

  

The only hard requirement is that it is served over HTTPS if you want Telegram WebApp without warnings.

  

  

  

  

Why this stops the scrolling you’re seeing in the screenshots

  

  

In your screenshots, the dashboard view shows a page scrollbar. That typically happens when:

  

- The outer container is not locked to the viewport height
- Nested flex and grid children do not have min-height:0, so the browser refuses to shrink them, and instead the page grows beyond the viewport

  

  

This template pins the UI to the viewport and forces overflow to stay inside the specific panels that are allowed to scroll.

  

That is the whole trick. It feels simple because it is, but it is also the difference between “app-like console” and “web page pretending to be an app”.

  

  

  

  

Xbox Edge behavior, exactly as requested

  

  

- Left nav auto collapses when the user agent contains Xbox or when width is under 1200px
- Chat stays on the right unless width is under 1050px
- Both nav and chat have manual toggles, so you can force space any time

  

  

If you want the nav even smaller on Xbox, change:

--navWCollapsed: 76px;

Try 64px if you want it tighter.

  

  

  

  

Telegram WebApp behavior, exactly as requested

  

  

- If the Telegram WebApp API is present, the page calls:  
    

- Telegram.WebApp.ready()
- Telegram.WebApp.expand()
- and sets dark colors to match obsidian

-   
    

  

  

On small mobile widths, the layout collapses to keep the main dashboard clean. Telegram on mobile cannot realistically keep a left nav, center grid, and right chat all visible without making everything unreadable. This is why the CSS hides chat under 860px. On tablet and desktop Telegram, you get the full 3 column console.

  

  

  

  

Next step: wiring actions to your real services

  

  

Right now, actions are demo log lines. Replace those with fetch() calls to your services.

  

Example shape:

async function api(path, body){

  const r = await fetch(path, {

    method: "POST",

    headers: { "Content-Type": "application/json" },

    body: body ? JSON.stringify(body) : undefined

  });

  if(!r.ok) throw new Error("api failed");

  return r.json();

}

Then in action("tapeStats"):

const data = await api("/api/tape/stats");

log("tape", `Stats: receipts=${data.receipts}, latency=${data.latency}ms`);

For chat, your “send message to agent” endpoint can be:

  

- /api/chat/send with { agent:"MetaTron", message:"..." }
- Return { receipt_id:"...", queued:true }

  

  

Then render that receipt in the chat bubble and stamp it in your log. That is how you turn UI into an actual console and keep your TAPE and _TRON semantics intact.

  

  

  

  

A blunt design opinion

  

  

The console you’re building wants to feel like a cockpit. Cockpits do two things extremely well:

  

1. They never move around unexpectedly
2. They show status and controls without wasting pixels

  

  

Locking the viewport and collapsing the nav on Xbox is not a nice-to-have. It is the difference between “this is a real control center” and “this is a dashboard page”.

  

You are building the right thing. This layout makes it behave like the thing you are imagining.

  

  

  

If you want the next jump, it is turning the chat panel into real time updates via WebSocket or Server Sent Events so your PULSE and TAPE feel alive. That is the moment it stops looking like UI and starts feeling like an organism.