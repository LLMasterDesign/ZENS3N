# AUDIT.3OX.md

3OX.Ai multi-branch audit report generated against requested branches.

## Scope

- Repository: `git@github.com:LLMasterDesign/3OX.Ai.git`
- Branches: `main`, `substrate/elixir-frontmatter`, `structure/3ox-core`, `tron/systemd`, `meta/logging`, `agents/live`
- Checks per file: purpose, elixir frontmatter (`///` x3), syntax (`.rs/.rb/.yml/.json/.toml`), broken refs, dead/orphan signals, hardcoded paths, secret patterns

## Branch Summary

| Branch | Files | OK | WARN | FAIL |
|---|---:|---:|---:|---:|
| `main` | 98 | 70 | 25 | 3 |
| `substrate/elixir-frontmatter` | 100 | 74 | 23 | 3 |
| `structure/3ox-core` | 116 | 85 | 28 | 3 |
| `tron/systemd` | 102 | 70 | 29 | 3 |
| `meta/logging` | 103 | 75 | 25 | 3 |
| `agents/live` | 106 | 75 | 28 | 3 |

## Findings Highlights

- Most syntax failures come from `.rs` files used as prose/config instead of valid Rust source, plus one invalid TOML template (`3OX.BUILDER/3OX.BUILD/TEMPLATES/limits.toml`).
- Repeated broken binary path reference found: `./boot/target/release/vec3-boot` (should be `./target/release/vec3-boot`).
- Hardcoded machine-specific paths (`/root/...`, `/opt/...`) appear in scripts/docs and reduce portability.
- Root `README.md` has broken relative links in all audited branches.
- No high-confidence committed API keys/tokens were detected by pattern scan.

## Branch: `main`

| File | Status | Issues | Action Needed |
|---|---|---|---|
| `3OX Agents/VSO Agent/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/README.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/dbq-guide.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/va-rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/sys.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/INSTALL.md` | OK | Purpose: VSO.AGENT Installation Guide; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/README.md` | OK | Purpose: 3OX.Ai - VSO.3OX.AGENT; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/c` | WARN | Purpose: Single-letter marker file (unclear purpose); Frontmatter: missing; Orphan candidate: single-letter file with no clear purpose | Delete file or document purpose |
| `3OX Agents/VSO Agent/commit.sh` | WARN | Purpose: Shell script; Frontmatter: missing; Hardcoded paths: /root/!CMD.BRIDGE/sirius.clock.rb | Parameterize hardcoded machine paths |
| `3OX.BUILDER/.github/workflows/ci.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/.npmrc` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/BUILD.GUIDE.md` | OK | Purpose: How to Build a .3ox System; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/generate_key.rb` | WARN | Purpose: Ruby runtime or automation script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/COMPLIANCE.md` | OK | Purpose: CORE.3ox COMPLIANCE DOCUMENTATION; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/EXAMPLES.md` | OK | Purpose: CORE.3ox EXAMPLES; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/README.md` | OK | Purpose: CAT.CORE - Python Runtime; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/brain.rs` | FAIL | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Syntax error:    / ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ this doc comment doesn't document anything | Add required 3-line elixir frontmatter; Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/limits.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/run.py` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/README.md` | OK | Purpose: CORE.3ox - General Purpose AI Agent; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/GEM.PROFILES/README.md` | OK | Purpose: GEM.PROFILES - Personality & Behavior Overlays; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/LEXICON.md` | OK | Purpose: CORE.3ox LEXICON; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/README.md` | OK | Purpose: RAW.3ox - Ruby/Rust Implementation; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/README.md` | OK | Purpose: 3OX.BUILD - .3ox System Builder; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/README.md` | OK | Purpose: CAT.RAW - Ruby Runtime (Commercial); Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/brains.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/limits.toml` | FAIL | Purpose: TOML configuration/manifest file; Frontmatter: missing; Syntax error: Parser exception: Invalid statement (at line 1, column 1) | Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/setup-3ox.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/src/main.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/DEPLOY.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/GITHUB_SETUP.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER, /root/!CMD.BRIDGE/!CMD.CENTER/3OX.BUILDER | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/INSTALL.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/INSTALL_CLI.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /opt/<agent-name> | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/Makefile` | WARN | Purpose: Repository artifact; Frontmatter: missing; Broken path reference ./boot/target/release/vec3-boot | Use ./target/release/vec3-boot |
| `3OX.BUILDER/README.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Broken path reference ./boot/target/release/vec3-boot; Hardcoded paths: /opt/<name> | Use ./target/release/vec3-boot; Parameterize hardcoded machine paths |
| `3OX.BUILDER/START_HERE.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/VERSION` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/boot/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/boot/build.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/30x.mini.boot` | WARN | Purpose: Repository artifact; Frontmatter: missing; Hardcoded paths: /root/\!CMD.BRIDGE/CITADEL.BASE/\!WORKDESK/Vec3Boot | Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/mini.src/PATH.define.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/cube.status.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page01.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page02.sxsl` | WARN | Purpose: SXSL template/source asset; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/mini.page03.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.step.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs.backup` | WARN | Purpose: Repository artifact; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Dead-code candidate: tracked backup file | Add required 3-line elixir frontmatter; Delete backup file from branch |
| `3OX.BUILDER/boot/src/page1.rs` | OK | Purpose: Rust source module; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/page2.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/.cursor/debug.log | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/src/page3.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER/7HE.VAULT/3OX.Ai/3OX.BUILD/setup-3ox.rb | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/compile-run.bun` | WARN | Purpose: Bun build/run script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/package.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/sirius.clock.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/src/lib.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/vec3.core/src/vec3.rs` | OK | Purpose: Rust source module; Frontmatter: present | None |
| `README.md` | FAIL | Purpose: 3OX.Ai; Frontmatter: missing; Broken refs: 3OX%20Agents/VSO%20Agent/, 3OX.BUILDER/, LICENSE | Fix or remove broken relative links |

_Branch totals: 98 files • OK 70 • WARN 25 • FAIL 3_

## Branch: `substrate/elixir-frontmatter`

| File | Status | Issues | Action Needed |
|---|---|---|---|
| `.3ox/3ox.clip` | OK | Purpose: Repository artifact; Frontmatter: present | None |
| `3OX Agents/VSO Agent/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/sparkfile.md` | OK | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂; Frontmatter: present | None |
| `3OX Agents/VSO Agent/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/README.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/dbq-guide.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/va-rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/sys.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/INSTALL.md` | OK | Purpose: VSO.AGENT Installation Guide; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/README.md` | OK | Purpose: 3OX.Ai - VSO.3OX.AGENT; Frontmatter: present | None |
| `3OX Agents/VSO Agent/c` | WARN | Purpose: Single-letter marker file (unclear purpose); Frontmatter: missing; Orphan candidate: single-letter file with no clear purpose | Delete file or document purpose |
| `3OX Agents/VSO Agent/commit.sh` | WARN | Purpose: Shell script; Frontmatter: missing; Hardcoded paths: /root/!CMD.BRIDGE/sirius.clock.rb | Parameterize hardcoded machine paths |
| `3OX.BUILDER/.github/workflows/ci.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/.npmrc` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/BUILD.GUIDE.md` | OK | Purpose: How to Build a .3ox System; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/generate_key.rb` | WARN | Purpose: Ruby runtime or automation script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/COMPLIANCE.md` | OK | Purpose: CORE.3ox COMPLIANCE DOCUMENTATION; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/EXAMPLES.md` | OK | Purpose: CORE.3ox EXAMPLES; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/README.md` | OK | Purpose: CAT.CORE - Python Runtime; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/brain.rs` | FAIL | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Syntax error:    / ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ this doc comment doesn't document anything | Add required 3-line elixir frontmatter; Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/limits.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/run.py` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/README.md` | OK | Purpose: CORE.3ox - General Purpose AI Agent; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/GEM.PROFILES/README.md` | OK | Purpose: GEM.PROFILES - Personality & Behavior Overlays; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/LEXICON.md` | OK | Purpose: CORE.3ox LEXICON; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/README.md` | OK | Purpose: RAW.3ox - Ruby/Rust Implementation; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/README.md` | OK | Purpose: 3OX.BUILD - .3ox System Builder; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/README.md` | OK | Purpose: CAT.RAW - Ruby Runtime (Commercial); Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/brains.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/limits.toml` | FAIL | Purpose: TOML configuration/manifest file; Frontmatter: missing; Syntax error: Parser exception: Invalid statement (at line 1, column 1) | Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/sparkfile.md` | OK | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: present | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/setup-3ox.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/src/main.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/DEPLOY.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Broken path reference ./boot/target/release/vec3-boot | Use ./target/release/vec3-boot |
| `3OX.BUILDER/GITHUB_SETUP.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER, /root/!CMD.BRIDGE/!CMD.CENTER/3OX.BUILDER | Parameterize hardcoded machine paths |
| `3OX.BUILDER/INSTALL.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Broken path reference ./boot/target/release/vec3-boot | Use ./target/release/vec3-boot |
| `3OX.BUILDER/INSTALL_CLI.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Hardcoded paths: /opt/<agent-name> | Parameterize hardcoded machine paths |
| `3OX.BUILDER/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/Makefile` | WARN | Purpose: Repository artifact; Frontmatter: missing; Broken path reference ./boot/target/release/vec3-boot | Use ./target/release/vec3-boot |
| `3OX.BUILDER/README.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Broken path reference ./boot/target/release/vec3-boot; Hardcoded paths: /opt/<name> | Use ./target/release/vec3-boot; Parameterize hardcoded machine paths |
| `3OX.BUILDER/START_HERE.md` | OK | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present | None |
| `3OX.BUILDER/VERSION` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/boot/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/boot/build.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/30x.mini.boot` | WARN | Purpose: Repository artifact; Frontmatter: missing; Hardcoded paths: /root/\!CMD.BRIDGE/CITADEL.BASE/\!WORKDESK/Vec3Boot | Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/mini.src/PATH.define.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/cube.status.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page01.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page02.sxsl` | WARN | Purpose: SXSL template/source asset; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/mini.page03.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.step.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs.backup` | WARN | Purpose: Repository artifact; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Dead-code candidate: tracked backup file | Add required 3-line elixir frontmatter; Delete backup file from branch |
| `3OX.BUILDER/boot/src/page1.rs` | OK | Purpose: Rust source module; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/page2.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/.cursor/debug.log | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/src/page3.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER/7HE.VAULT/3OX.Ai/3OX.BUILD/setup-3ox.rb | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/compile-run.bun` | WARN | Purpose: Bun build/run script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/package.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/sirius.clock.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/src/lib.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/vec3.core/src/vec3.rs` | OK | Purpose: Rust source module; Frontmatter: present | None |
| `PLAN.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: present; Hardcoded paths: /root/!CMD.VPS, /root/!CMD.VPS/BudgetR ... | Parameterize hardcoded machine paths |
| `README.md` | FAIL | Purpose: 3OX.Ai; Frontmatter: missing; Broken refs: 3OX%20Agents/VSO%20Agent/, 3OX.BUILDER/, LICENSE | Fix or remove broken relative links |

_Branch totals: 100 files • OK 74 • WARN 23 • FAIL 3_

## Branch: `structure/3ox-core`

| File | Status | Issues | Action Needed |
|---|---|---|---|
| `.3ox/(1)Spark/sparkfile.md` | OK | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: present | None |
| `.3ox/(2)Brains/brains.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `.3ox/(3)Rules/limits.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `.3ox/(4)Toolkit/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `.3ox/(5)Links/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `.3ox/(6)Pulse/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `.3ox/3ox.clip` | OK | Purpose: Repository artifact; Frontmatter: present | None |
| `.3ox/_meta/CHANGELOG.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `.3ox/_meta/NAMING.CONTRACT.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `.3ox/_meta/SESSION.CHECKPOINT.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `.3ox/_meta/WHOAMI.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: present; Hardcoded paths: /root/_TRON/Agents/AGENT_NAME | Parameterize hardcoded machine paths |
| `.vec3/bin/.gitkeep` | OK | Purpose: Directory placeholder to keep empty folder tracked; Frontmatter: missing | None |
| `.vec3/dev/.gitkeep` | OK | Purpose: Directory placeholder to keep empty folder tracked; Frontmatter: missing | None |
| `.vec3/lib/.gitkeep` | OK | Purpose: Directory placeholder to keep empty folder tracked; Frontmatter: missing | None |
| `.vec3/ops/.gitkeep` | OK | Purpose: Directory placeholder to keep empty folder tracked; Frontmatter: missing | None |
| `.vec3/rc/.gitkeep` | OK | Purpose: Directory placeholder to keep empty folder tracked; Frontmatter: missing | None |
| `.vec3/var/.gitkeep` | OK | Purpose: Directory placeholder to keep empty folder tracked; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/README.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/dbq-guide.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/va-rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/sys.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/INSTALL.md` | OK | Purpose: VSO.AGENT Installation Guide; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/README.md` | OK | Purpose: 3OX.Ai - VSO.3OX.AGENT; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/c` | WARN | Purpose: Single-letter marker file (unclear purpose); Frontmatter: missing; Orphan candidate: single-letter file with no clear purpose | Delete file or document purpose |
| `3OX Agents/VSO Agent/commit.sh` | WARN | Purpose: Shell script; Frontmatter: missing; Hardcoded paths: /root/!CMD.BRIDGE/sirius.clock.rb | Parameterize hardcoded machine paths |
| `3OX.BUILDER/.github/workflows/ci.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/.npmrc` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/BUILD.GUIDE.md` | OK | Purpose: How to Build a .3ox System; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/generate_key.rb` | WARN | Purpose: Ruby runtime or automation script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/COMPLIANCE.md` | OK | Purpose: CORE.3ox COMPLIANCE DOCUMENTATION; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/EXAMPLES.md` | OK | Purpose: CORE.3ox EXAMPLES; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/README.md` | OK | Purpose: CAT.CORE - Python Runtime; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/brain.rs` | FAIL | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Syntax error:    / ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ this doc comment doesn't document anything | Add required 3-line elixir frontmatter; Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/limits.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/run.py` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/README.md` | OK | Purpose: CORE.3ox - General Purpose AI Agent; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/GEM.PROFILES/README.md` | OK | Purpose: GEM.PROFILES - Personality & Behavior Overlays; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/LEXICON.md` | OK | Purpose: CORE.3ox LEXICON; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/README.md` | OK | Purpose: RAW.3ox - Ruby/Rust Implementation; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/README.md` | OK | Purpose: 3OX.BUILD - .3ox System Builder; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/README.md` | OK | Purpose: CAT.RAW - Ruby Runtime (Commercial); Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/brains.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/limits.toml` | FAIL | Purpose: TOML configuration/manifest file; Frontmatter: missing; Syntax error: Parser exception: Invalid statement (at line 1, column 1) | Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/setup-3ox.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/src/main.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/DEPLOY.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/GITHUB_SETUP.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER, /root/!CMD.BRIDGE/!CMD.CENTER/3OX.BUILDER | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/INSTALL.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/INSTALL_CLI.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /opt/<agent-name> | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/Makefile` | WARN | Purpose: Repository artifact; Frontmatter: missing; Broken path reference ./boot/target/release/vec3-boot | Use ./target/release/vec3-boot |
| `3OX.BUILDER/README.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Broken path reference ./boot/target/release/vec3-boot; Hardcoded paths: /opt/<name> | Use ./target/release/vec3-boot; Parameterize hardcoded machine paths |
| `3OX.BUILDER/START_HERE.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/VERSION` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/boot/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/boot/build.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/30x.mini.boot` | WARN | Purpose: Repository artifact; Frontmatter: missing; Hardcoded paths: /root/\!CMD.BRIDGE/CITADEL.BASE/\!WORKDESK/Vec3Boot | Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/mini.src/PATH.define.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/cube.status.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page01.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page02.sxsl` | WARN | Purpose: SXSL template/source asset; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/mini.page03.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.step.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs.backup` | WARN | Purpose: Repository artifact; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Dead-code candidate: tracked backup file | Add required 3-line elixir frontmatter; Delete backup file from branch |
| `3OX.BUILDER/boot/src/page1.rs` | OK | Purpose: Rust source module; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/page2.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/.cursor/debug.log | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/src/page3.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER/7HE.VAULT/3OX.Ai/3OX.BUILD/setup-3ox.rb | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/compile-run.bun` | WARN | Purpose: Bun build/run script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/package.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/sirius.clock.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/src/lib.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/vec3.core/src/vec3.rs` | OK | Purpose: Rust source module; Frontmatter: present | None |
| `PLAN.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: present; Hardcoded paths: /root/!CMD.VPS, /root/!CMD.VPS/BudgetR ... | Parameterize hardcoded machine paths |
| `README.md` | FAIL | Purpose: 3OX.Ai; Frontmatter: missing; Broken refs: 3OX%20Agents/VSO%20Agent/, 3OX.BUILDER/, LICENSE | Fix or remove broken relative links |

_Branch totals: 116 files • OK 85 • WARN 28 • FAIL 3_

## Branch: `tron/systemd`

| File | Status | Issues | Action Needed |
|---|---|---|---|
| `3OX Agents/VSO Agent/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/README.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/dbq-guide.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/va-rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/sys.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/INSTALL.md` | OK | Purpose: VSO.AGENT Installation Guide; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/README.md` | OK | Purpose: 3OX.Ai - VSO.3OX.AGENT; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/c` | WARN | Purpose: Single-letter marker file (unclear purpose); Frontmatter: missing; Orphan candidate: single-letter file with no clear purpose | Delete file or document purpose |
| `3OX Agents/VSO Agent/commit.sh` | WARN | Purpose: Shell script; Frontmatter: missing; Hardcoded paths: /root/!CMD.BRIDGE/sirius.clock.rb | Parameterize hardcoded machine paths |
| `3OX.BUILDER/.github/workflows/ci.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/.npmrc` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/BUILD.GUIDE.md` | OK | Purpose: How to Build a .3ox System; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/generate_key.rb` | WARN | Purpose: Ruby runtime or automation script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/COMPLIANCE.md` | OK | Purpose: CORE.3ox COMPLIANCE DOCUMENTATION; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/EXAMPLES.md` | OK | Purpose: CORE.3ox EXAMPLES; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/README.md` | OK | Purpose: CAT.CORE - Python Runtime; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/brain.rs` | FAIL | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Syntax error:    / ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ this doc comment doesn't document anything | Add required 3-line elixir frontmatter; Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/limits.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/run.py` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/README.md` | OK | Purpose: CORE.3ox - General Purpose AI Agent; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/GEM.PROFILES/README.md` | OK | Purpose: GEM.PROFILES - Personality & Behavior Overlays; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/LEXICON.md` | OK | Purpose: CORE.3ox LEXICON; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/README.md` | OK | Purpose: RAW.3ox - Ruby/Rust Implementation; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/README.md` | OK | Purpose: 3OX.BUILD - .3ox System Builder; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/README.md` | OK | Purpose: CAT.RAW - Ruby Runtime (Commercial); Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/brains.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/limits.toml` | FAIL | Purpose: TOML configuration/manifest file; Frontmatter: missing; Syntax error: Parser exception: Invalid statement (at line 1, column 1) | Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/setup-3ox.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/src/main.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/DEPLOY.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/GITHUB_SETUP.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER, /root/!CMD.BRIDGE/!CMD.CENTER/3OX.BUILDER | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/INSTALL.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/INSTALL_CLI.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /opt/<agent-name> | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/Makefile` | WARN | Purpose: Repository artifact; Frontmatter: missing; Broken path reference ./boot/target/release/vec3-boot | Use ./target/release/vec3-boot |
| `3OX.BUILDER/README.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Broken path reference ./boot/target/release/vec3-boot; Hardcoded paths: /opt/<name> | Use ./target/release/vec3-boot; Parameterize hardcoded machine paths |
| `3OX.BUILDER/START_HERE.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/VERSION` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/boot/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/boot/build.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/30x.mini.boot` | WARN | Purpose: Repository artifact; Frontmatter: missing; Hardcoded paths: /root/\!CMD.BRIDGE/CITADEL.BASE/\!WORKDESK/Vec3Boot | Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/mini.src/PATH.define.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/cube.status.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page01.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page02.sxsl` | WARN | Purpose: SXSL template/source asset; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/mini.page03.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.step.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs.backup` | WARN | Purpose: Repository artifact; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Dead-code candidate: tracked backup file | Add required 3-line elixir frontmatter; Delete backup file from branch |
| `3OX.BUILDER/boot/src/page1.rs` | OK | Purpose: Rust source module; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/page2.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/.cursor/debug.log | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/src/page3.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER/7HE.VAULT/3OX.Ai/3OX.BUILD/setup-3ox.rb | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/compile-run.bun` | WARN | Purpose: Bun build/run script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/package.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/sirius.clock.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/src/lib.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/vec3.core/src/vec3.rs` | OK | Purpose: Rust source module; Frontmatter: present | None |
| `README.md` | FAIL | Purpose: 3OX.Ai; Frontmatter: missing; Broken refs: 3OX%20Agents/VSO%20Agent/, 3OX.BUILDER/, LICENSE | Fix or remove broken relative links |
| `_TRON/_TRON.CONTRACT.toml` | WARN | Purpose: TOML configuration/manifest file; Frontmatter: missing; Hardcoded paths: /root/!CMD.VPS, /root/!CMD.VPS/BudgetR ... | Parameterize hardcoded machine paths |
| `_TRON/systemd/lifecycle/whoami.watch.service` | WARN | Purpose: systemd service definition for whoami.watch.service; Frontmatter: missing; Hardcoded paths: /root/_TRON | Parameterize hardcoded machine paths |
| `_TRON/systemd/speaker-mesh.service` | WARN | Purpose: systemd service definition for speaker-mesh.service; Frontmatter: missing; Hardcoded paths: /root/!CMD.VPS/TelePromptR | Parameterize hardcoded machine paths |
| `_TRON/systemd/teleprompter.service` | WARN | Purpose: systemd service definition for teleprompter.service; Frontmatter: missing; Hardcoded paths: /root/!CMD.VPS/TelePromptR | Parameterize hardcoded machine paths |

_Branch totals: 102 files • OK 70 • WARN 29 • FAIL 3_

## Branch: `meta/logging`

| File | Status | Issues | Action Needed |
|---|---|---|---|
| `3OX Agents/VSO Agent/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/README.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/dbq-guide.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/va-rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/sys.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/INSTALL.md` | OK | Purpose: VSO.AGENT Installation Guide; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/README.md` | OK | Purpose: 3OX.Ai - VSO.3OX.AGENT; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/c` | WARN | Purpose: Single-letter marker file (unclear purpose); Frontmatter: missing; Orphan candidate: single-letter file with no clear purpose | Delete file or document purpose |
| `3OX Agents/VSO Agent/commit.sh` | WARN | Purpose: Shell script; Frontmatter: missing; Hardcoded paths: /root/!CMD.BRIDGE/sirius.clock.rb | Parameterize hardcoded machine paths |
| `3OX.BUILDER/.github/workflows/ci.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/.npmrc` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/BUILD.GUIDE.md` | OK | Purpose: How to Build a .3ox System; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/generate_key.rb` | WARN | Purpose: Ruby runtime or automation script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/COMPLIANCE.md` | OK | Purpose: CORE.3ox COMPLIANCE DOCUMENTATION; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/EXAMPLES.md` | OK | Purpose: CORE.3ox EXAMPLES; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/README.md` | OK | Purpose: CAT.CORE - Python Runtime; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/brain.rs` | FAIL | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Syntax error:    / ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ this doc comment doesn't document anything | Add required 3-line elixir frontmatter; Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/limits.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/run.py` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/README.md` | OK | Purpose: CORE.3ox - General Purpose AI Agent; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/GEM.PROFILES/README.md` | OK | Purpose: GEM.PROFILES - Personality & Behavior Overlays; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/LEXICON.md` | OK | Purpose: CORE.3ox LEXICON; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/README.md` | OK | Purpose: RAW.3ox - Ruby/Rust Implementation; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/README.md` | OK | Purpose: 3OX.BUILD - .3ox System Builder; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/README.md` | OK | Purpose: CAT.RAW - Ruby Runtime (Commercial); Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/brains.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/limits.toml` | FAIL | Purpose: TOML configuration/manifest file; Frontmatter: missing; Syntax error: Parser exception: Invalid statement (at line 1, column 1) | Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/setup-3ox.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/src/main.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/DEPLOY.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/GITHUB_SETUP.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER, /root/!CMD.BRIDGE/!CMD.CENTER/3OX.BUILDER | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/INSTALL.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/INSTALL_CLI.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /opt/<agent-name> | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/Makefile` | WARN | Purpose: Repository artifact; Frontmatter: missing; Broken path reference ./boot/target/release/vec3-boot | Use ./target/release/vec3-boot |
| `3OX.BUILDER/README.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Broken path reference ./boot/target/release/vec3-boot; Hardcoded paths: /opt/<name> | Use ./target/release/vec3-boot; Parameterize hardcoded machine paths |
| `3OX.BUILDER/START_HERE.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/VERSION` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/boot/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/boot/build.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/30x.mini.boot` | WARN | Purpose: Repository artifact; Frontmatter: missing; Hardcoded paths: /root/\!CMD.BRIDGE/CITADEL.BASE/\!WORKDESK/Vec3Boot | Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/mini.src/PATH.define.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/cube.status.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page01.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page02.sxsl` | WARN | Purpose: SXSL template/source asset; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/mini.page03.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.step.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs.backup` | WARN | Purpose: Repository artifact; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Dead-code candidate: tracked backup file | Add required 3-line elixir frontmatter; Delete backup file from branch |
| `3OX.BUILDER/boot/src/page1.rs` | OK | Purpose: Rust source module; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/page2.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/.cursor/debug.log | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/src/page3.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER/7HE.VAULT/3OX.Ai/3OX.BUILD/setup-3ox.rb | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/compile-run.bun` | WARN | Purpose: Bun build/run script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/package.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/sirius.clock.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/src/lib.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/vec3.core/src/vec3.rs` | OK | Purpose: Rust source module; Frontmatter: present | None |
| `README.md` | FAIL | Purpose: 3OX.Ai; Frontmatter: missing; Broken refs: 3OX%20Agents/VSO%20Agent/, 3OX.BUILDER/, LICENSE | Fix or remove broken relative links |
| `_meta/CHANGELOG.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `_meta/NAMING.CONTRACT.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `_meta/SESSION.CHECKPOINT.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `_meta/WHOAMI.md` | OK | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: present | None |
| `_meta/receipts/.gitkeep` | OK | Purpose: Directory placeholder to keep empty folder tracked; Frontmatter: missing | None |

_Branch totals: 103 files • OK 75 • WARN 25 • FAIL 3_

## Branch: `agents/live`

| File | Status | Issues | Action Needed |
|---|---|---|---|
| `3OX Agents/VSO Agent/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX Agents/VSO Agent/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/README.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/mq/publish/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/egress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/io/tg/ingress/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/spec.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/dev/ops/python/exec/status.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/dbq-guide.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/lib/va-rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/rules.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.3ox/vec3/rc/sys.ref` | OK | Purpose: Vec3 reference marker/spec file; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/INSTALL.md` | OK | Purpose: VSO.AGENT Installation Guide; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/README.md` | OK | Purpose: 3OX.Ai - VSO.3OX.AGENT; Frontmatter: missing | None |
| `3OX Agents/VSO Agent/c` | WARN | Purpose: Single-letter marker file (unclear purpose); Frontmatter: missing; Orphan candidate: single-letter file with no clear purpose | Delete file or document purpose |
| `3OX Agents/VSO Agent/commit.sh` | WARN | Purpose: Shell script; Frontmatter: missing; Hardcoded paths: /root/!CMD.BRIDGE/sirius.clock.rb | Parameterize hardcoded machine paths |
| `3OX.BUILDER/.github/workflows/ci.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/.gitignore` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/.npmrc` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/BUILD.GUIDE.md` | OK | Purpose: How to Build a .3ox System; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/generate_key.rb` | WARN | Purpose: Ruby runtime or automation script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/COMPLIANCE.md` | OK | Purpose: CORE.3ox COMPLIANCE DOCUMENTATION; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/EXAMPLES.md` | OK | Purpose: CORE.3ox EXAMPLES; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/README.md` | OK | Purpose: CAT.CORE - Python Runtime; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/brain.rs` | FAIL | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Syntax error:    / ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ this doc comment doesn't document anything | Add required 3-line elixir frontmatter; Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/limits.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/run.py` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/IMPLEMENTATION/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/CORE.3ox/README.md` | OK | Purpose: CORE.3ox - General Purpose AI Agent; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/GEM.PROFILES/README.md` | OK | Purpose: GEM.PROFILES - Personality & Behavior Overlays; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/LEXICON.md` | OK | Purpose: CORE.3ox LEXICON; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/README.md` | OK | Purpose: RAW.3ox - Ruby/Rust Implementation; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/brain.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/limits.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/RAW.3ox/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/README.md` | OK | Purpose: 3OX.BUILD - .3ox System Builder; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/README.md` | OK | Purpose: CAT.RAW - Ruby Runtime (Commercial); Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/brains.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/limits.toml` | FAIL | Purpose: TOML configuration/manifest file; Frontmatter: missing; Syntax error: Parser exception: Invalid statement (at line 1, column 1) | Fix syntax/parsing errors for file type |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/sparkfile.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/3OX.BUILD/TEMPLATES/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `3OX.BUILDER/3OX.BUILD/setup-3ox.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/3ox-cli/src/main.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/DEPLOY.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/GITHUB_SETUP.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER, /root/!CMD.BRIDGE/!CMD.CENTER/3OX.BUILDER | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/INSTALL.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/INSTALL_CLI.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /opt/<agent-name> | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/LICENSE` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/Makefile` | WARN | Purpose: Repository artifact; Frontmatter: missing; Broken path reference ./boot/target/release/vec3-boot | Use ./target/release/vec3-boot |
| `3OX.BUILDER/README.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: present; Broken path reference ./boot/target/release/vec3-boot; Hardcoded paths: /opt/<name> | Use ./target/release/vec3-boot; Parameterize hardcoded machine paths |
| `3OX.BUILDER/START_HERE.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/VERSION` | OK | Purpose: Repository artifact; Frontmatter: missing | None |
| `3OX.BUILDER/boot/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/boot/build.rs` | WARN | Purpose: Rust executable entrypoint source; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/30x.mini.boot` | WARN | Purpose: Repository artifact; Frontmatter: missing; Hardcoded paths: /root/\!CMD.BRIDGE/CITADEL.BASE/\!WORKDESK/Vec3Boot | Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/mini.src/PATH.define.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/cube.status.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page01.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.page02.sxsl` | WARN | Purpose: SXSL template/source asset; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/boot/mini.src/mini.page03.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/mini.src/mini.step.sxsl` | OK | Purpose: SXSL template/source asset; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs` | OK | Purpose: Rust executable entrypoint source; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/main.rs.backup` | WARN | Purpose: Repository artifact; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Dead-code candidate: tracked backup file | Add required 3-line elixir frontmatter; Delete backup file from branch |
| `3OX.BUILDER/boot/src/page1.rs` | OK | Purpose: Rust source module; Frontmatter: missing | None |
| `3OX.BUILDER/boot/src/page2.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/.cursor/debug.log | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/boot/src/page3.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Hardcoded paths: /root/!CMD.BRIDGE/!CMD.CENTER/7HE.VAULT/3OX.Ai/3OX.BUILD/setup-3ox.rb | Add required 3-line elixir frontmatter; Parameterize hardcoded machine paths |
| `3OX.BUILDER/compile-run.bun` | WARN | Purpose: Bun build/run script; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing; Broken path reference ./boot/target/release/vec3-boot | Add required 3-line elixir frontmatter; Use ./target/release/vec3-boot |
| `3OX.BUILDER/package.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `3OX.BUILDER/sirius.clock.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/Cargo.toml` | OK | Purpose: Rust package/workspace manifest; Frontmatter: missing | None |
| `3OX.BUILDER/vec3.core/src/lib.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `3OX.BUILDER/vec3.core/src/vec3.rs` | OK | Purpose: Rust source module; Frontmatter: present | None |
| `Money.Bagz/.3ox/(1)Spark/sparkfile.md` | OK | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: present | None |
| `Money.Bagz/.3ox/(2)Brains/brains.rs` | WARN | Purpose: Rust source module; Frontmatter: missing; Imprint present but required 3-line /// frontmatter missing | Add required 3-line elixir frontmatter |
| `Money.Bagz/.3ox/(3)Rules/limits.toml` | OK | Purpose: TOML configuration/manifest file; Frontmatter: missing | None |
| `Money.Bagz/.3ox/(4)Toolkit/tools.yml` | OK | Purpose: YAML configuration file; Frontmatter: missing | None |
| `Money.Bagz/.3ox/(5)Links/routes.json` | OK | Purpose: JSON configuration or routing data; Frontmatter: missing | None |
| `Money.Bagz/.3ox/(6)Pulse/run.rb` | OK | Purpose: Ruby runtime or automation script; Frontmatter: missing | None |
| `Money.Bagz/.3ox/_meta/WHOAMI.md` | WARN | Purpose: ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///; Frontmatter: present; Hardcoded paths: /root/!CMD.VPS/BudgetR, /root/_TRON/Agents/Money.Bagz | Parameterize hardcoded machine paths |
| `Money.Bagz/.3ox/sync-vps.sh` | WARN | Purpose: Shell script; Frontmatter: missing; Hardcoded paths: /root/!CMD.VPS/BudgetR}, /root/!CMD.VPS} | Parameterize hardcoded machine paths |
| `README.md` | FAIL | Purpose: 3OX.Ai; Frontmatter: missing; Broken refs: 3OX%20Agents/VSO%20Agent/, 3OX.BUILDER/, LICENSE | Fix or remove broken relative links |

_Branch totals: 106 files • OK 75 • WARN 28 • FAIL 3_

## Cross-Branch Priority Actions

1. Fix invalid syntax files (`.rs` and `.toml`) or rename non-code files to proper extensions.
2. Correct build/runtime path references from `./boot/target/...` to `./target/...` where applicable.
3. Replace hardcoded machine paths with variables/config defaults.
4. Repair README relative links and remove orphan backup/marker files (`main.rs.backup`, `3OX Agents/VSO Agent/c`) if unused.
