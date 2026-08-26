/**
 * ZEN.HUB/website/chrome.js — inject header/footer chrome into [data-chrome] mounts.
 * Base: script directory, or data-chrome-base / window.ZENSEN_CHROME_BASE.
 */
(function () {
  "use strict";

  const SCRIPT = document.currentScript;
  const DEFAULT_BRAND_HTML =
    '<strong>3OX</strong> <span class="sl">//</span> <span class="brk">〔</span> <span>Zensen</span><span class="rail-dot">·</span><span>Ender</span> <span class="brk">〕</span>';
  const SIRIUS_EPOCH_UTC = new Date(2025, 7, 8, 3, 35, 0).getTime();

  function scriptBase() {
    if (window.ZENSEN_CHROME_BASE) {
      return String(window.ZENSEN_CHROME_BASE).replace(/\/?$/, "/");
    }
    const fromDoc = document.documentElement.getAttribute("data-chrome-base");
    if (fromDoc) return fromDoc.replace(/\/?$/, "/");
    if (SCRIPT && SCRIPT.src) {
      try {
        const u = new URL(SCRIPT.src, location.href);
        u.pathname = u.pathname.replace(/\/[^/]*$/, "/");
        return u.href;
      } catch (_) {
        /* fall through */
      }
    }
    return new URL("/chrome/", location.origin).href;
  }

  function fail(msg) {
    console.error("[chrome]", msg);
    const status = document.getElementById("status");
    if (status) {
      status.textContent = "chrome: " + msg;
      status.classList.add("err");
    }
    document.querySelectorAll("[data-chrome]").forEach((el) => {
      if (!el.querySelector("[data-chrome-root]")) {
        const err = document.createElement("p");
        err.className = "zh-chrome-err";
        err.textContent = "chrome load failed: " + msg;
        el.appendChild(err);
      }
    });
  }

  async function fetchText(url) {
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) throw new Error(res.status + " " + url);
    return res.text();
  }

  async function fetchJson(url) {
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) throw new Error(res.status + " " + url);
    return res.json();
  }

  function attr(el, name) {
    const v = el.getAttribute(name);
    return v == null || v === "" ? null : v;
  }

  function fillSlot(root, name, htmlOrText, asHtml) {
    const slot = root.querySelector('[data-slot="' + name + '"]');
    if (!slot) return;
    if (htmlOrText == null || htmlOrText === "") {
      if (name === "eyebrow" || name === "title") {
        slot.hidden = true;
        return;
      }
      return;
    }
    slot.hidden = false;
    if (asHtml) slot.innerHTML = htmlOrText;
    else slot.textContent = htmlOrText;
  }

  function parseNav(raw) {
    if (!raw) return [];
    try {
      const data = JSON.parse(raw);
      return Array.isArray(data) ? data : [];
    } catch (_) {
      return [];
    }
  }

  function renderNav(navEl, items) {
    navEl.innerHTML = "";
    items.forEach((item) => {
      if (!item || !item.href || !item.label) return;
      const a = document.createElement("a");
      a.href = item.href;
      a.textContent = item.label;
      if (item.current) a.setAttribute("aria-current", "page");
      if (item["data-link"]) a.setAttribute("data-link", item["data-link"]);
      if (item["data-path"]) a.setAttribute("data-path", item["data-path"]);
      navEl.appendChild(a);
    });
  }

  function contactFor(contacts, surface) {
    if (!contacts || !contacts.surfaces) return null;
    const key = surface || "home";
    const map = contacts.surfaces[key] || contacts.surfaces.home;
    if (!map || !map.primary) return null;
    const group = contacts.groups[map.primary];
    if (!group) return null;
    return group;
  }

  function renderContact(slot, group) {
    if (!group) {
      slot.innerHTML = "";
      return;
    }
    const a = document.createElement("a");
    a.href = "mailto:" + group.email;
    a.textContent = group.email;
    slot.innerHTML = "";
    slot.appendChild(a);
  }

  function crcLine(value) {
    let token = value && value !== "" ? String(value) : "∅";
    if (token.indexOf("crc:") === 0) token = token.slice(4);
    return "⋮⋮" + token + ":crc⋮⋮";
  }

  function metaFloor(meta) {
    const lead = meta.querySelector(".meta-lead");
    const segs = Array.from(meta.querySelectorAll(".path .seg"));
    const prevMin = meta.style.minWidth;
    meta.style.minWidth = "0px";
    if (lead) lead.hidden = true;
    segs.forEach(function (s) { s.hidden = true; });
    const w = meta.scrollWidth;
    if (lead) lead.hidden = false;
    segs.forEach(function (s) { s.hidden = false; });
    meta.style.minWidth = prevMin;
    return w;
  }

  function foldMeta(meta) {
    if (!meta) return;
    const lead = meta.querySelector(".meta-lead");
    const segs = Array.from(meta.querySelectorAll(".path .seg"));
    const floor = metaFloor(meta);
    meta.style.minWidth = floor + "px";
    const frame = meta.closest(".foot-frame");
    const title = frame && frame.querySelector(".foot-title");
    if (frame && title) {
      const inner = frame.clientWidth - 34;
      meta.style.flexBasis = (title.offsetWidth + floor > inner) ? "100%" : "";
    }
    if (lead) lead.hidden = false;
    segs.forEach(function (s) { s.hidden = false; });
    function overflow() {
      return meta.scrollWidth > meta.clientWidth + 1;
    }
    var i = 0;
    while (overflow() && i < segs.length) {
      segs[i].hidden = true;
      i += 1;
    }
    if (overflow() && lead) lead.hidden = true;
  }

  function watchMeta(root) {
    const meta = root.querySelector(".foot-meta");
    if (!meta) return;
    const run = function () { foldMeta(meta); };
    run();
    if (typeof ResizeObserver !== "undefined") {
      const ro = new ResizeObserver(run);
      ro.observe(meta);
      const frame = root.classList && root.classList.contains("foot-frame") ? root : root.querySelector(".foot-frame");
      if (frame) ro.observe(frame);
    }
    window.addEventListener("resize", run);
  }

  function fillBanner(fill) {
    if (!fill) return;
    var n = 220;
    fill.textContent = "▂".repeat(n);
    var w = fill.clientWidth;
    if (!w) return;
    while (n > 6 && fill.scrollWidth > w) {
      n--;
      fill.textContent = "▂".repeat(n);
    }
    while (n < 800 && fill.scrollWidth <= w) {
      n++;
      fill.textContent = "▂".repeat(n);
      if (fill.scrollWidth > fill.clientWidth) {
        n--;
        fill.textContent = "▂".repeat(n);
        break;
      }
    }
  }

  function watchBanner(root) {
    var banner = root.querySelector(".head-banner");
    var fill = root.querySelector(".head-banner .rf");
    if (!banner || !fill) return;
    var run = function () { fillBanner(fill); };
    run();
    if (typeof ResizeObserver !== "undefined") {
      var ro = new ResizeObserver(run);
      ro.observe(banner);
      var frame = root.classList && root.classList.contains("zh-header") ? root : root.querySelector(".zh-header");
      if (frame) ro.observe(frame);
    }
    window.addEventListener("resize", run);
  }

  function applyHeader(mount, html) {
    mount.innerHTML = html;
    const root = mount.querySelector("[data-chrome-root]") || mount;
    fillSlot(root, "eyebrow", attr(mount, "data-slot-eyebrow"), false);
    fillSlot(root, "title", attr(mount, "data-slot-title"), false);
    var hex = attr(mount, "data-slot-hex");
    if (hex) {
      var hexEl = root.querySelector('[data-slot="hex"]');
      if (hexEl) hexEl.textContent = "⋮⋮[" + hex + "]⋮⋮";
    }
    watchBanner(root);
  }

  function siriusStamp() {
    const elapsed = Date.now() - SIRIUS_EPOCH_UTC;
    const days = Math.floor(elapsed / 864e5);
    const remainder = elapsed - days * 864e5;
    const fff = String(Math.min(999, Math.floor((remainder * 1000) / 864e5))).padStart(3, "0");
    return "⌾-26." + days + "." + fff;
  }

  function applyFooter(mount, html, contacts) {
    mount.innerHTML = html;
    const root = mount.querySelector("[data-chrome-root]") || mount;
    const copyRaw = attr(mount, "data-slot-copy");
    if (copyRaw) fillSlot(root, "copy", copyRaw, true);

    const navEl = root.querySelector('[data-slot="nav"]');
    if (navEl) renderNav(navEl, parseNav(attr(mount, "data-slot-nav")));

    const brandRaw = attr(mount, "data-slot-brand");
    const brandEl = root.querySelector('[data-slot="brand"]');
    if (brandEl && brandRaw) {
      brandEl.innerHTML = brandRaw;
    } else {
      const run = root.querySelector(".title-run");
      if (run) run.innerHTML = DEFAULT_BRAND_HTML;
    }

    const contactEl = root.querySelector('[data-slot="contact"]');
    if (contactEl) {
      const surface = attr(mount, "data-surface") || attr(document.documentElement, "data-surface");
      renderContact(contactEl, contactFor(contacts, surface));
    }

    const crcEl = root.querySelector('[data-slot="crc"]');
    if (crcEl) {
      crcEl.textContent = crcLine(attr(mount, "data-slot-crc") || "∅");
    }

    const stampEl = root.querySelector('[data-slot="stamp"]');
    if (stampEl) {
      const frozen = attr(mount, "data-slot-stamp");
      if (frozen) {
        stampEl.textContent = frozen;
      } else {
        const tick = function () {
          stampEl.textContent = siriusStamp();
        };
        tick();
        if (window.__zhSirius) clearInterval(window.__zhSirius);
        window.__zhSirius = setInterval(tick, 1000);
      }
    }

    watchMeta(root);

    var portEl = root.querySelector(".port");
    var syncDot = root.querySelector(".sync-dot");
    if (portEl && syncDot) {
      var port = portEl.textContent.trim();
      var syncUrl = "http://127.0.0.1" + port + "/api/health";
      var lead = root.querySelector(".meta-lead");
      if (lead) {
        var syncLink = document.createElement("a");
        syncLink.href = syncUrl;
        syncLink.textContent = "sync";
        syncLink.style.cssText = "color:inherit;text-decoration:none;";
        var firstText = lead.firstChild;
        if (firstText && firstText.nodeType === 3 && firstText.textContent.indexOf("sync") !== -1) {
          firstText.textContent = firstText.textContent.replace("sync", "");
          lead.insertBefore(syncLink, lead.firstChild);
        }
      }
    }
  }

  async function boot() {
    const mounts = Array.from(document.querySelectorAll("[data-chrome]"));
    if (!mounts.length) return;

    const base = scriptBase();
    let headerHtml;
    let footerHtml;
    let contacts;
    try {
      [headerHtml, footerHtml, contacts] = await Promise.all([
        fetchText(base + "header/imprint.html"),
        fetchText(base + "footer/footer.html"),
        fetchJson(base + "contacts/contacts.json"),
      ]);
    } catch (err) {
      fail(String(err && err.message ? err.message : err));
      return;
    }

    mounts.forEach((mount) => {
      const kind = mount.getAttribute("data-chrome");
      if (kind === "header") applyHeader(mount, headerHtml);
      else if (kind === "footer") applyFooter(mount, footerHtml, contacts);
    });

    document.dispatchEvent(new CustomEvent("zensenchrome:ready"));
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
