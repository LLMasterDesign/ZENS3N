# DNS cutover packet · awaiting Lucius approval

Staging is green. Custom domains are **not** attached until you approve.

## Staging URLs (live now)

| Domain role | Railway staging |
|---|---|
| home | https://zens3n-production.up.railway.app |
| try | https://zensen-live-production.up.railway.app |
| educate | https://zensen-systems-production.up.railway.app |
| own | https://zensen-store-production.up.railway.app |
| hire | https://zensen-solutions-production.up.railway.app |

## Attach order (when approved)

1. `zensen.systems` → service `ZENSEN-SYSTEMS` (`07ba293a-8192-4a2e-8d9c-ca7fc5617c6c`)
2. `zensen.live` → `ZENSEN-LIVE` (`fe751cb8-5f56-472a-a931-a8b7740ea902`)
3. `zensen.store` → `ZENSEN-STORE` (`82d74313-30ef-4f9f-bbb2-985d2cee6418`)
4. `zensen.solutions` → `ZENSEN-SOLUTIONS` (`0364a017-1547-4df6-9935-62ea2d779766`)
5. `zensensystems.com` → `ZENSEN-SYSTEM-SUITE` (`8eee7a22-8094-49b5-ab5a-7631eab79f86`)

Command shape (MCP / CLI): `generate-domain` with `domain` set to the owned hostname; apply **only** Railway-returned DNS records; keep `noindex` until production cutover verifier passes.

## Notepad loop proof

- Educate: https://zensen-systems-production.up.railway.app/Notepad/
- Try: https://zensen-live-production.up.railway.app/Notepad/
- Own: https://zensen-store-production.up.railway.app/Notepad/
- Hire: https://zensen-solutions-production.up.railway.app/

:: ∎
