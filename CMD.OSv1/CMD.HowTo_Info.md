# CMD How-To & Information

**Reference:** 
- `CMD.Folder_Map.md` - Minimal folder structure (quick visual reference)
- `CMD.System_Map.toml` - Conceptual architecture, registry schemas, flows, guardrails

> **Detailed Information:** This file contains all descriptions, migration notes, and explanations. Use `CMD.Folder_Map.md` for quick structure reference and `CMD.System_Map.toml` for understanding the conceptual architecture.

---

## Stratos 5-Layer Cycle vs Stack 3-Layer Triad

### Stratos 5-Layer Cycle
Stratos is the layering cycle that organizes system structure by naming convention:

- **Stratos 1 (.CMD):** !CMD.BRIDGE → !CMD.CENTER, !*.CMD, !7HE.VAULT
- **Stratos 2 (.BASE):** !LAUNCH.PAD → !N.3OX, !*.OPS, !WORKDESK
- **Stratos 3 (.OPS):** !OPERATIONS → !0UT.3OX, !AGENTS, !TOOLCASE
- **Stratos 4 (.AGENT):** !BRIEFCASE → .3ox, Instructions, Memory, Wiki
- **Stratos 5 (.3ox):** brains.rs, run.rb, tools.yml, routes.yml, limits.toml, 3ox.log

### Stack Layers (Triad)
Separate from Stratos, the Stack has three functional layers:

- **Layer 1 (Substrates):** OS, Docker, volumes, core data stores on Zens3n_Base
- **Layer 2 (Services):** brains_rs, TelePromptR, Raven_Core, storage services, workers
- **Layer 3 (Interface):** Telegram, CMD.BRIDGE, WebApps, dashboards

**Note:** Stratos describes structure organization, Stack describes functional layers.

---

## Top-Level Structure

### !CMD.BRIDGE/ (symlink to `/mnt/r/!CMD.BRIDGE`)
- **Role:** Shared command room where Raven.Operator and Zens3n.CMD meet
- **Contains:** 
  - !CMD.CENTER (coordination hub)
  - Base directories (CITADEL, OBSIDIAN, RVNx, SYNTH, ZENS3N)
  - Integration points for Raven.Core and Zens3n services
- **Note:** Authoritative location is on Windows R: drive, mounted in WSL at `/mnt/r/!CMD.BRIDGE`
- **Stratos:** Stratos 1 (.CMD)
- **Stack:** Layer 3 (Interface)

### !LAUNCH.PAD/
- **Role:** ZENS3N.BASE workspace - where Zens3n/brains.rs lives
- **Contains:**
  - ZEN.LAB TEST CHAMBER (development/testing)
  - ZEN.SILO VPS.k (Docker deployment platform)
- **Architecture:** Docker container platform for GlyphBit system, agents launch from here
- **Stratos:** Stratos 2 (.BASE)
- **Stack:** Layer 1 (Substrates)

### _runtime/
- **Role:** Runtime environment for compiled binaries, logs, models, and services
- **Contains:**
  - bin/ - Compiled binaries (executables)
  - logs/ - Runtime logs from services
  - models/ - ML models, embeddings, vector stores
  - services/ - Runtime service files
  - forge/ - Machine scratchpad (temp files, per-job directories, partial outputs)
- **Note:** Different from CORE - CORE has tools/compilers, _runtime has runtime artifacts
- **Migration:** bin/, models/, services/ may need migration; logs/ and forge/ can be recreated
- **Stack:** Layer 1 (Substrates)

### CORE/
- **Role:** Core tools, services, and infrastructure (persistent)
- **Contains:**
  - brains.exe - Core brain binary (compiled from brains.rs)
  - ruby/ - Ruby runtime and tools
  - rust/ - Rust runtime and tools (where brains.rs, Raven.Core are compiled)
  - pcloud/ - pCloud sync utilities
  - tdlib/ - TDLib services (Telegram library for RVNx account)
  - postgresql/ - PostgreSQL database (data and configuration)
  - redis/ - Redis cache and session store
  - REGISTRY/ - Base and service registries
    - BASE.REGISTRY.yml - Base registry (see CMD.System_Map.toml for schema)
    - SERVICE.REGISTRY.yml - Service registry (see CMD.System_Map.toml for schema)
- **Services:**
  - brains.exe - Core compiled brain binary
  - TDLib - Telegram library service (used by both Zens3n and Raven)
  - PostgreSQL - Database for persistent data
  - Redis - Cache and session storage
- **Relationship to _runtime:** CORE has tools/services, _runtime has runtime artifacts (binaries, logs, models)
- **Stack:** Layer 1 (Substrates) and Layer 2 (Services)

### .ssh/
- **SSH keys and configuration**
  - **CRITICAL for migration** - must be preserved and migrated to new VPS
  - Contains authentication keys for server access

### Other System Directories (NOT in map - auto-generated)
The following system directories exist but are **NOT needed for migration** - they are auto-generated and will be recreated on new VPS:
- `.cache/`, `.config/`, `.cursor/`, `.cursor-server/`, `.docker/`, `.gem/`, `.local/`, `.npm/`, `.nvm/`, `snap/`

---

## !CMD.BRIDGE Structure

### Stratos 1 (.CMD stations - operational layer)

#### !CMD.CENTER/
- **Role:** Bus station and Telegram superchannel commo ground - monitors and has handlers that move files
- **NOT a workspace** - actions happen in a chain, CMD coordinates but doesn't do work
- **Contains:**
  - 7HE.VAUL7/ - Memory and thoughts storage (was CAPTAINS_VAULT)
    - Configs/ - .3ox blueprints (centralized config location for all services/agents)
    - Tasks/ - Task tracking folder (CMD needs visibility into what's happening)
    - Logs/, Memories/, Thoughts/, Archives/
  - AGENTS/ - Most agents are non-canon
    - SPEC.WRITER.3ox_agent/ - Canon agent (prompt analysis)
  - Toolkit/ - Discovery and routing tools
  - Logbook/ - Operational logs (separate from Captains Log)
  - LandingZone/ - Git, Local, MCP integrations
  - R&D/ - Research documents
  - PromptBook/
- **Stratos:** Stratos 1 (.CMD)
- **Stack:** Layer 3 (Interface)

#### RAVEN.CMD/
- **Role:** Raven.Operator - Operational Brain (Von Neumann architecture)
- **Type:** Stratos station (.CMD) - operational layer, NOT a base
- **Contains:**
  - .git/ - Version control (independent repo)
  - memory/ - Von Neumann memory-dependent storage
  - persona/ - Raven persona versions (can grow/evolve)
  - core/ - Raven.Core service
  - telegram/ - Raven.TelegramFace
- **.3ox configs:** Located in 7HE.VAUL7/Configs/ (centralized blueprint location)
- **Characteristics:**
  - Memory-dependent (Von Neumann architecture)
  - Self-modifying (can grow and evolve)
  - Independent (own git repo)
  - Operational (not just coordination like !CMD.CENTER)
  - Connects to !CMD.BRIDGE but operates independently
- **Stratos:** Stratos 1 (.CMD)
- **Stack:** Layer 2 (Services) and Layer 3 (Interface)

#### ZENS3N.CMD/
- **Role:** Zens3n Operations - Workspace operations
- **Type:** Stratos station (.CMD) - operational layer
- **Contains:** Links to ZENS3N.BASE (WSL) and ZENS3N.VPS (Hetzner)
- **Note:** Umbrella for Zens3n operations across locations
- **Stratos:** Stratos 1 (.CMD)
- **Stack:** Layer 1 (Substrates) and Layer 2 (Services)

### Bases (Stratos 2 - storage/knowledge layer)

#### CITADEL.BASE/
- **Role:** Mirrored from Windows R:\!LAUNCH.PAD
- **Stratos:** Stratos 2 (.BASE)
- **Stack:** Layer 1 (Substrates)

#### OBSIDIAN.BASE/
- **Role:** Knowledge base vaults
- **Stratos:** Stratos 2 (.BASE)
- **Stack:** Layer 1 (Substrates)

#### SYNTH.BASE/
- **Role:** Synthesis operations
- **Stratos:** Stratos 2 (.BASE)
- **Stack:** Layer 1 (Substrates)

### Important Notes

- **CMD.BRIDGE is NOT a workspace** - it's a monitoring/coordination hub
- **Files don't come to CMD first** - CMD monitors and has handlers that move files
- **Captains Log is separate** - Logbook is for operational logs only
- **Tasks folder needed** - CMD needs visibility into what's happening
- **Most agents non-canon** - Only SPEC.WRITER.3ox_agent is confirmed canon
- **.3ox configs location:** Centralized in 7HE.VAUL7/Configs/ (blueprint location)
  - All .3ox configs for services/agents go here
  - RAVEN.CMD, AGENTS, and other services reference configs from this central location

---

## !LAUNCH.PAD Structure (ZENS3N.BASE)

### ZEN.LAB TEST CHAMBER/
- **Role:** Testing and development zone for Zens3n
- **Contains:**
  - GLYPH.BIT/ - Bot source code (Trinity: Noctua, Vulpes, Trickoon)
  - Test runs and exploration tools
  - Performance testing
  - Archived tests
- **Note:** Development happens here before deployment to ZEN.SILO VPS.k
- **Stratos:** Stratos 2 (.BASE)

### ZEN.SILO VPS.k/
- **Role:** Docker deployment platform - containerized agents launch from here
- **Architecture:**
  - Container 1: MUNINN (Redis) - Memory & State Storage
  - Container 2: GLYPHBIT-CORE - Forge, Shared Mind, Core Logic
  - Container 3: GLYPHBIT-TELEGRAM - Trinity bots
- **Contains:**
  - glyphbit-core/ - Core engine container
  - glyphbit-telegram/ - Telegram bots container
  - zens3n-vps/ - Zens3n VPS services (includes raven.arc)
- **Note:** Production deployment environment
- **Stratos:** Stratos 2 (.BASE)

### VpsWalletPanel/
- **Role:** Web application for VPS wallet management
- **Contains:** Server, frontend source, user uploads
- **Stack:** Layer 3 (Interface)

### Important Notes

- **.3ox configs:** Should be in 7HE.VAUL7/Configs/ (centralized blueprint location), not in !LAUNCH.PAD/.3ox/
- **Docker deployment:** Uses docker-compose.yml for orchestration
- **Development flow:** ZEN.LAB TEST CHAMBER → ZEN.SILO VPS.k (development to production)
- **Version control:** Has .git repo for tracking changes

---

## CORE Structure

### brains.exe
- **Role:** Core brain binary - compiled from brains.rs
- **Location:** CORE/brains.exe
- **Note:** Core compiled brain executable
- **Stack:** Layer 2 (Services)

### ruby/
- **Role:** Ruby runtime and package management
- **Contains:**
  - bundle/ - Bundler cache for Ruby dependencies
  - gems/ - Installed Ruby gems and libraries
- **Note:** Ruby tools and services use this runtime
- **Stack:** Layer 1 (Substrates)

### rust/
- **Role:** Rust runtime and toolchain
- **Contains:**
  - cargo/ - Cargo package manager (Rust's build system)
  - rustup/ - Rust toolchain installer and version manager
    - settings.toml - Rustup configuration
- **Note:** Where Rust services (brains.rs, Raven.Core) are compiled
- **Compiled output:** Produces brains.exe in CORE/
- **Stack:** Layer 1 (Substrates)

### pcloud/
- **Role:** pCloud sync utilities
- **Contains:** pCloud synchronization tools
- **Note:** Used for syncing between Windows R: drive and cloud storage
- **Stack:** Layer 1 (Substrates)

### tdlib/
- **Role:** TDLib services - Telegram library
- **Contains:** TDLib implementation for Telegram integration
- **Usage:** Used by both Zens3n and Raven (logged in as RVNx account)
- **Note:** TelePromptR service lives here (see CMD.System_Map.toml for TelePromptR details)
- **Stack:** Layer 2 (Services)

### postgresql/
- **Role:** PostgreSQL database
- **Contains:** Database data files and configuration
- **Usage:** Persistent data storage for services
- **Stack:** Layer 1 (Substrates)

### redis/
- **Role:** Redis cache and session store
- **Contains:** Redis data and configuration
- **Usage:** Cache, session storage, and state management
- **Stack:** Layer 1 (Substrates)

### REGISTRY/
- **Role:** Base and service registry (see CMD.System_Map.toml for full registry schema)
- **Contains:**
  - BASE.REGISTRY.yml - Base registry (required fields: name, root_path, station_brain, rules_file, bus_exchange_prefix, cmd_bridge_topic, status)
  - SERVICE.REGISTRY.yml - Service registry (required fields: name, base, code_path, runtime_binding, bus_queues, cmd_bridge_alias, health_check, log_path, status)
- **Note:** No Base or service is real until registered. See CMD.System_Map.toml for registry rules and contracts.
- **Stack:** Layer 1 (Substrates)

### Important Notes

- **CORE contains core infrastructure** - brains.exe, runtime tools, and services (TDLib, PostgreSQL, Redis)
- **brains.exe** - Core compiled brain binary lives in CORE/
- **Services:** TDLib, PostgreSQL, and Redis are core infrastructure services
- **Migration:** Preserve brains.exe, database data, Redis data, and configuration files
- **Relationship to _runtime:** CORE has tools/services, _runtime has runtime artifacts (binaries in bin/, logs, models)

---

## Workflow Directories (Expected Locations)

Based on architecture, these directories should exist within the workspace structure:

- **!1N.3OX** - Raw intake (write once bucket, static ground truth) [Stratos 2]
- **_runtime/forge** - Machine scratchpad (temp files, per-job dirs, safe to wipe)
- **!WORKDESK** - Human workbench (board.yml, plans/, jobs/, archive/) [Stratos 2]
- **!OPS/!0ut.3ox** - Accepted outputs shelf (stable, indexed, canonical) [Stratos 3]

---

## Three Core Locations & Sync Directions

The system operates across three primary locations with specific sync directions:

### 1. ZENS3N.CMD (Umbrella - includes both locations)
**ZENS3N.CMD** encompasses both:
- **ZENS3N.BASE** at WSL: `/root/!LAUNCH.PAD/` (WSL /root mapping)
  - Where Zens3n/brains.rs development and testing happens
  - Contains: ZEN.LAB TEST CHAMBER, ZEN.SILO VPS.k
- **ZENS3N.VPS** on Hetzner: VPS server deployment
  - Production runtime environment on Hetzner VPS
  - Receives deployments from ZENS3N.BASE

**Sync Direction:** 
- **Outbound:** WSL (ZENS3N.BASE) → VPS (ZENS3N.VPS) → Hetzner (deployments, compiled services)
- **Inbound:** Hetzner (ZENS3N.VPS) → WSL (ZENS3N.BASE) (runtime logs, status updates)
- **Bidirectional:** With !CMD.BRIDGE (coordination, commands)

### 2. !CMD.BRIDGE at VPS
**Location:** `/root/!CMD.BRIDGE/` (symlink to `/mnt/r/!CMD.BRIDGE`)  
**Role:** Shared command room where Raven and Zens3n.CMD meet  
**Sync Direction:**
- **Outbound:** VPS → R: (mirrors to Windows authoritative location)
- **Inbound:** R: → VPS (receives updates from Windows)
- **Bidirectional:** With ZENS3N.CMD (coordination, commands)
- **Note:** Authoritative location is Windows R: drive, VPS has symlink/mount

### 3. THE.CITADEL at R:
**Location:** `R:\!LAUNCH.PAD\` (Windows pCloud drive)  
**Role:** CITADEL.BASE - Windows-native storage, pCloud synced  
**Sync Direction:**
- **Outbound:** R: → pCloud → other devices (automatic pCloud sync)
- **Inbound:** pCloud → R: (syncs from cloud/other devices)
- **Bidirectional:** With !CMD.BRIDGE (authoritative source)
- **Note:** pCloud syncs `R:\` → `P:` cloud storage automatically

### Sync Flow Summary
```
WSL (ZENS3N.BASE) → Hetzner (ZENS3N.VPS)
     ↓                      ↓
     └──── ZENS3N.CMD ──────┘
              ↕
     VPS (!CMD.BRIDGE) ←→ Windows R: (THE.CITADEL) → pCloud
     /mnt/r/!CMD.BRIDGE      R:\!LAUNCH.PAD
```

---

## Migration Notes

### Must Migrate
- **!CMD.BRIDGE** - Ensure `/mnt/r/!CMD.BRIDGE` is accessible on new VPS (or recreate symlink)
- **!LAUNCH.PAD** - Contains Docker deployments, preserve docker-compose.yml and .env files
- **CORE/** - Contains compiled services, may need rebuild on new VPS (preserve source/config)
  - Preserve: brains.exe, database data (PostgreSQL), Redis data, configuration files
  - REGISTRY/ - Must preserve BASE.REGISTRY.yml and SERVICE.REGISTRY.yml
- **.ssh/** - **CRITICAL** - Must preserve SSH keys for server access

### Will Be Recreated (No Migration Needed)
- **_runtime/** - Temporary scratchpad, will be recreated automatically
  - bin/, models/, services/ may need migration if they contain important artifacts
  - logs/ and forge/ can be recreated
- System directories (`.cache`, `.config`, `.cursor`, etc.) - Auto-generated, no migration needed

### Optional Organization
- **CORE/** could optionally live under `_runtime/CORE/` but is kept separate to distinguish:
  - Persistent tools/services (CORE) vs ephemeral runtime files (_runtime/forge)

---

## Cross-References

- **CMD.System_Map.toml** - Conceptual architecture, registry schemas, flows, guardrails
- **CMD.Folder_Map.md** - Minimal folder structure reference
- **This file** - Detailed descriptions and migration information

:: ∎

