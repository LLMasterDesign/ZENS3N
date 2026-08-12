window.ZENSEN = window.ZENSEN || {
  home: "http://127.0.0.1:7120",
  live: "http://127.0.0.1:6061",
  solutions: "http://127.0.0.1:6062",
  systems: "http://127.0.0.1:6063",
  store: "http://127.0.0.1:6064",
  operatorNotepad: "http://corbato-en0.billfish-sirius.ts.net:7075/"
};
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-link]").forEach((el) => {
    const key = el.getAttribute("data-link");
    const base = window.ZENSEN[key];
    if (!base) return;
    const path = el.getAttribute("data-path") || "";
    el.setAttribute("href", base.replace(/\/$/, "") + path);
  });
});
