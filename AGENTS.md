# AGENTS.md

## Cursor Cloud specific instructions

### Codebase Overview

This is the **ZENS3N** monorepo containing the **3OX.BUILDER** AI agent framework (Rust workspace + Bun orchestrator + Ruby setup scripts). The primary buildable project lives at `3OX.Ai/3OX.BUILDER/`.

### Required Toolchain

- **Rust** (stable, edition 2021) — core build system
- **Bun** (>=1.0.0) — for `compile-run.bun` orchestrator script
- **Ruby** (>=3.2.0) — for `setup-3ox.rb` and agent runtime scripts

### Build & Test Commands

All commands run from `3OX.Ai/3OX.BUILDER/`:

| Action | Command |
|--------|---------|
| Build all | `cargo build --release` |
| Build CLI only | `cargo build --release --bin 3ox` |
| Run tests | `cargo test` |
| Run Vec3Boot | `./target/release/vec3-boot [cube_path]` |
| Run 3ox CLI | `./target/release/3ox help` |
| Makefile targets | `make build`, `make test`, `make clean` |

See `3OX.Ai/3OX.BUILDER/README.md` for full documentation.

### Gotchas

- **`compile-run.bun` path bug**: The script references `./boot/target/release/vec3-boot` but cargo workspace places the binary at `./target/release/vec3-boot`. Use direct `cargo build --release` + `./target/release/vec3-boot` instead.
- **`std::fs::exists` API**: Requires `.unwrap_or(false)` on Rust 1.81+ since it returns `Result<bool>`. This fix was applied to `boot/src/page3.rs`.
- **Vec3Boot is interactive**: It has a 5-second animated splash screen and interactive prompts. When testing non-interactively, pipe input or use `timeout`.
- **No lockfiles**: There is no `Cargo.lock` or `bun.lockb` committed. Dependency resolution happens fresh on each build.
- **`package.json` has zero JS dependencies**: `bun install` / `npm install` is effectively a no-op but won't error.
- **Directories with special characters**: Several directories use `!` prefix (e.g., `!ZEN.HUB`). Always quote paths in shell commands.
- **Rust toolchain**: Must be recent enough (>=1.81) for `std::fs::exists`. The default Rust on the VM may need `rustup default stable` to get a recent version.
