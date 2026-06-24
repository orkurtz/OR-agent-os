# Spec Changelog

Build the human-readable history of project changes from Agent OS specs. This command creates or updates `agent-os/specs/CHANGELOG.md`.

## Important Guidelines

- **Spec Changelog is the source of spec history** — do not create a separate spec index.
- **Read specs, not the whole project** — scan spec folders and only follow file references when needed to understand a recorded change.
- **Facts over guesses** — use status markers, task text, changed-file notes, shape notes, standards, and references. Mark unknowns clearly.
- **Newest first** — changelog entries should be ordered by spec folder timestamp descending.
- **Readable by humans first** — this file should help a developer understand what changed and why.

## Process

### Step 1: Locate Specs

Scan `agent-os/specs/` for timestamped spec folders.

For each folder, read files if present:

- `plan.md`
- `shape.md`
- `references.md`
- `standards.md`

If no specs exist, create `agent-os/specs/CHANGELOG.md` with a short empty-state note.

### Step 2: Extract Changelog Facts

For each spec, extract:

- **Date / folder** — from `YYYY-MM-DD-HHMM-feature-slug`
- **Feature/change name** — from `# Plan: ...`, `shape.md`, or folder slug
- **Why it was done** — from `shape.md` scope/decisions/context
- **Status**:
  - `Completed` when all implementation tasks are `[x]`
  - `In Progress` when any task is `[/]`
  - `Planned` when tasks are only `[ ]`
  - `Partial` when some tasks are `[x]` and some remain `[ ]`
  - `Unknown` when status cannot be inferred
- **Completed tasks** — task names marked `[x]`
- **Files changed** — parse `[x] Completed: ...` entries when present
- **Relevant standards** — from `standards.md`
- **References used** — from `references.md`
- **Open questions / incomplete work** — unfinished tasks, unknowns, or notes from `shape.md`

### Step 3: Write `CHANGELOG.md`

Create or replace `agent-os/specs/CHANGELOG.md`:

```markdown
# Spec Changelog

Developer-readable history generated from `agent-os/specs/`.

## [YYYY-MM-DD HH:MM] [Feature / Change Name]

- **Spec:** `agent-os/specs/[folder]/`
- **Status:** [Planned / In Progress / Completed / Partial / Unknown]
- **Why:** [why this work exists]
- **Completed tasks:** [summary or "None recorded"]
- **Files changed:** [files from completed markers, or "Not recorded"]
- **Standards used:** [standards, or "None recorded"]
- **References:** [references, or "None recorded"]
- **Open / incomplete:** [remaining tasks or unknowns]
```

### Step 4: Confirm Completion

After creating or updating the file, output:

```text
Spec Changelog updated:

  agent-os/specs/CHANGELOG.md

Use this file to understand what changed in the project over time.
```
