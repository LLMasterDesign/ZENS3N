# /sparkjournal Command
▛//▞▞ ⟦⎊⟧ :: ⧗-26.160 // SPARK.JOURNAL ▞▞
▛//▞ Purpose:: Ignite project sparkfile and create journal entry

▛▞ Usage::
- /spark (questionnaire)
- /sparkfile (starter)
- /spark {ProjectName} (all files)
- /spark.journal
- /spark.task
- /spark.plan
- /spark.notes
- /spark sync

//▞ All commands create /update journal files with date and Sirius time.

:: ∎

## Behavior

**Sparkfile Naming:**
When creating a new sparkfile with `/sparkfile`, once the file knows its location, it gets renamed based on context:
- `vault.sparkfile` - For vault-level sparkfiles
- `folder.sparkfile` - For folder-level sparkfiles
- `project.sparkfile` - For project-level sparkfiles
- `{filefocus}.sparkfile` - For file-focused sparkfiles (uses current file focus name)

**For `/spark` (liminal questionnaire):**
- Present interactive checklist/questionnaire
- Determine what files to create based on responses
- Guide user through sparkfile creation process

**For `/sparkfile`:**
- Create starter sparkfile template
- Auto-rename based on location context (see Sparkfile Naming above)

**For `/spark {ProjectName}`:**
1. **Get Project Context:**
   - Use provided project name
   - Detect project structure

2. **Get Current Date & Time:**
   - Date: `YYYY.MM.DD` format
   - Sirius time: Run `ruby sirius.clock.rb` → `⧗-YY.SSS`

3. **Create All Files:**
   - `Journal/Daily/YYYY.MM.DD.ProjectName.Journal.md` (main journal)
   - `Journal/Daily/YYYY.MM.DD.ProjectName.plan.md` (planning)
   - `Journal/Daily/YYYY.MM.DD.ProjectName.task` (tasks - format from vault.sparkfile)
   - `Journal/Daily/YYYY.MM.DD.ProjectName.notes` (versioning)

4. **Use Templates:**
   - Journal: Read `Templates/journal.template`
   - Task: Read `Templates/task.template` (format matches vault.sparkfile)
   - Fill with: Project name, date, Sirius time
   - Add banner with Sirius time imprint

5. **Link to Project:**
   - If project exists → link to `Projects/{Project}/`
   - Update project `meta.note` with journal entry
   - Link to `tasks/`, `plans/`, `notes/` directories

**For `/spark.journal`, `/spark.task`, `/spark.plan`, `/spark.notes`:**
- Create/update only the specified file type
- Follow same date/time and template patterns
- Link to project structure if exists

**For `/spark sync`:**
- Manually sync all files (journal, plan, task, notes)
- Update timestamps and links
- Integrate changes across all file types

## Journal Format

```markdown
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-YY.SSS // JOURNAL :: {Project} ▞▞

# JOURNAL :: {Project} ::

[Project]
{Project}

[Now]
- {Current activity or status}

[Next]
- TASK: {Task description} @{Project}
- PLAN: {Plan description} @{Project}

[Done]
- {Completed item}

[Links]
Notes: notes/{note-filename}.note
Tasks: tasks/{Project}.{active}.task
Plans: plans/{plan-filename}.plan

:: ∎
```

## Task File Format (.task)

Based on `vault.sparkfile` format:
- Banner with Sirius time imprint
- Project sections with 🔷 headers
- Task lines with status symbols:
  - 🔺 Critical: Must be done now (only one per project)
  - ⚫︎ Active: Currently in progress
  - ⚪︎ Pending: Backlog/future
  - ✅ Completed: Done
- :: ∎ terminators between sections
- Legend at bottom

## Integration

- Journal integrates .plan, .task, .notes during builds
- Plans are consumable (checked off as executed)
- All files link to project structure
- Journal feeds into MCP plan tool

