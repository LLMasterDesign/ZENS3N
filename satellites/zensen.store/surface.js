window.ZENSEN = window.ZENSEN || {
  home: "https://zens3n-production.up.railway.app",
  live: "https://zensen-live-production.up.railway.app",
  solutions: "https://zensen-solutions-production.up.railway.app",
  systems: "https://zensen-systems-production.up.railway.app",
  store: "https://zensen-store-production.up.railway.app",
  operatorNotepad: "http://corbato-en0.billfish-sirius.ts.net:7075/"
};

function zensenApplyLinks(root) {
  const scope = root || document;
  scope.querySelectorAll("[data-link]").forEach((el) => {
    const key = el.getAttribute("data-link");
    const base = window.ZENSEN[key];
    if (!base) return;
    const path = el.getAttribute("data-path") || "";
    el.setAttribute("href", base.replace(/\/$/, "") + path);
  });
}

document.addEventListener("DOMContentLoaded", () => zensenApplyLinks(document));
document.addEventListener("zensenchrome:ready", () => zensenApplyLinks(document));
