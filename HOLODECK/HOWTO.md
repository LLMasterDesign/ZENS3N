# ▞ HOLODECK MANUAL ▞

Welcome to the Holodeck, your visual command center for managing tasks and files across your Obsidian vault.

## 1. The Protocol (Flowstate)

The Holodeck parses your markdown files for specific symbols to track tasks. You can add these symbols to *any* file to make it trackable.

### Task Symbols
| Symbol | Status | Meaning |
| :--- | :--- | :--- |
| `🔺` | **CRITICAL** | Must be done now. Only one primary critical task per project. |
| `⚫︎` | **ACTIVE** | Currently in progress or queued for this session. |
| `⚪︎` | **PENDING** | Backlog, ideas, or future tasks. |
| `✅` | **DONE** | Completed tasks. |

### Structure Symbols
| Symbol | Name | Usage |
| :--- | :--- | :--- |
| `🔷` | **Project** | `🔷 Project Name ::` - Defines a project block. |
| `:: ∎` | **Terminator** | Ends a project block. |

---

## 2. The Dashboard

The Holodeck interface is divided into several views:

- **🔷 Projects:** The main view. Groups tasks by their `🔷 Project` header. Shows 1 Critical task per project, with others stacked.
- **📑 Data Grid:** A raw table view of all tasks, sortable and filterable.
- **📊 Board View:** A Kanban-style board (Critical / Active / Pending / Done).
- **🔍 Chaos Map:** Scans your vault for "lost" files (files with no task symbols) so you can pin them.
- **🧠 Brainstorm:** Shows tasks from your Inbox (`!1N.3OX OBSIDIAN`).
- **🤖 Agents:** Shows tasks assigned to AI Agents (found in `!OBSIDIAN.OPS`).
- **🏛 Bases:** Shows tasks from your Knowledge Bases (`OBSIDIAN.BASE`).

### Quick Actions (Hover over Project Banner)
- `+T` **Add Task:** Quickly add a task to this project (Simulation).
- `📂` **Go to File:** Copy the file path or open it directly in Cursor.
- `🗺` **Show Route:** See which Zone (Vault, Transit, System) this file belongs to.

---

## 3. Workflow: Taming the Chaos

### Pinning Files
1. Go to **🔍 Chaos Map**.
2. You will see a list of files that are not currently tracked.
3. Click **📌 Pin**.
4. Enter a task name (e.g., "Refactor this script").
5. The system creates a task wrapper for that file, adding it to your dashboard.

### Moving Files
1. Go to **🔍 Chaos Map**.
2. Click **📂 Move**.
3. Enter the destination folder (e.g., `Projects/NewApp`).
4. The file is moved instantly.

---

## 4. Architecture

For the technical maintainer:

- **Server:** `HOLODECK/server.py` - Python HTTP server (No Flask/Django).
    - Port: `8080`
    - Config: `config.json` (or defaults in script).
    - Scans `../OBSIDIAN.BASE` for markdown files.
- **Frontend:** `HOLODECK/dashboard.html` - Single Page App (SPA).
    - Uses vanilla JS + CSS.
    - Fetches JSON from `/api/data`.
- **Watcher:** `HOLODECK/watcher.py` - Optional script for auto-regeneration (superseded by live API).

### Git Workflow

**Commit Message Format:**
```
[Type] Brief description

- Detailed change 1
- Detailed change 2
- Testing: What was verified
- Tracking: Updated Notepad.md and tasker.cfg
```

**Types:** `FEAT` (new features), `FIX` (bug fixes), `REFACTOR` (code cleanup), `DOCS` (documentation), `TEST` (testing), `CHORE` (maintenance)

**Before Committing:**
1. Update `HOLODECK/lib/Notes/Notepad.md` with task status
2. Update `HOLODECK/lib/Notes/tasker.cfg` with changes
3. Run `./verify.sh` to test system health
4. Commit with descriptive message

### Troubleshooting
- **Server not running?** Run `python3 server.py` in the `HOLODECK` folder.
- **Tasks not showing?** Ensure you used the exact symbols (`🔷`, `🔺`, `⚪︎`, `⚫︎`).
- **Port in use?** Kill the old process: `fuser -k 8080/tcp`.

