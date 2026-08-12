/**
 * ZEN.HUB/website/chrome.js — inject header/footer chrome into [data-chrome] mounts.
 * Base: script directory, or data-chrome-base / window.ZENSEN_CHROME_BASE.
 */
(function () {
  "use strict";

  const SCRIPT = document.currentScript;
  const DEFAULT_BRAND_HTML =
    "<strong>ORION</strong><span>ÆON // ÆGIS // ÆGen</span>";

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
    const token = value && value !== "" ? value : "∅";
    if (token.indexOf("crc:") === 0) return "⋮⋮[" + token + "]⋮⋮";
    return "⋮⋮[crc:" + token + "]⋮⋮";
  }

  function applyHeader(mount, html) {
    mount.innerHTML = html;
    const root = mount.querySelector("[data-chrome-root]") || mount;
    fillSlot(root, "eyebrow", attr(mount, "data-slot-eyebrow"), false);
    fillSlot(root, "title", attr(mount, "data-slot-title"), false);
  }

  function applyFooter(mount, html, contacts) {
    mount.innerHTML = html;
    const root = mount.querySelector("[data-chrome-root]") || mount;
    fillSlot(root, "copy", attr(mount, "data-slot-copy"), false);

    const navEl = root.querySelector('[data-slot="nav"]');
    if (navEl) renderNav(navEl, parseNav(attr(mount, "data-slot-nav")));

    const brandRaw = attr(mount, "data-slot-brand");
    const brandEl = root.querySelector('[data-slot="brand"]');
    if (brandEl) {
      if (brandRaw) brandEl.innerHTML = brandRaw;
      else if (!brandEl.innerHTML.trim()) brandEl.innerHTML = DEFAULT_BRAND_HTML;
    }

    const contactEl = root.querySelector('[data-slot="contact"]');
    if (contactEl) {
      const surface = attr(mount, "data-surface") || attr(document.documentElement, "data-surface");
      renderContact(contactEl, contactFor(contacts, surface));
    }

    const crcEl = root.querySelector('[data-slot="crc"]');
    if (crcEl) {
      const crc = attr(mount, "data-slot-crc") || "∅";
      crcEl.textContent = crcLine(crc);
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
