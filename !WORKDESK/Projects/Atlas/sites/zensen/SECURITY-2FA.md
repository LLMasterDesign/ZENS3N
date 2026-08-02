# Security and 2FA boundary

Do not implement 2FA inside a static HTML file. HTML can display a login screen, but it cannot safely store secrets, validate one-time codes, manage sessions, or enforce authorization.

## Decide the boundary

- Public marketing/read-only pages: no login required.
- Admin/editor tools: login required, with passkey or TOTP 2FA.
- Sensitive operations: server-side authorization and re-authentication.

## Minimum safe plan

1. Choose an identity provider that supports passkeys or TOTP, recovery codes, session expiry, and account recovery.
2. Keep secrets and verification server-side or in the provider. Never commit them to HTML, JavaScript, or the repository.
3. Protect admin routes at the server/hosting layer, not only with hidden buttons.
4. Test wrong codes, replayed codes, recovery, logout, expired sessions, and direct access to protected URLs.
5. Record the provider, protected routes, emergency recovery owner, and last test date.

Status: **design decision needed** — identify which routes are public and which are private before building authentication.
