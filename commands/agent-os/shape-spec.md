# Shape Spec

Gather context and structure planning for significant work. **Run this command while in plan mode.**

## Important Guidelines

- **Use the available user-input/question tool** when one exists. If none exists, ask one concise question in chat.
- **Offer suggestions** — Present options the user can confirm, adjust, or correct
- **Keep it lightweight** — This is shaping, not exhaustive documentation
- **This command ONLY creates the plan. It does NOT implement anything.** Implementation begins only after the user approves the plan and exits plan mode.
- **One question at a time** — NEVER ask more than one question per message. NEVER proceed before receiving the user's answer.
- **State is on disk, not in memory** — The executing agent must always re-read `plan.md` before updating markers. Never assume task status from conversation history.
- **Use balanced execution discipline** — Significant implementation tasks get state markers, recovery rules, Ponytail YAGNI, and verification. Documentation-only tasks and tiny quick edits should stay lightweight.

## Prerequisites

This command **must be run in plan mode**.

**Before proceeding, check if you are currently in plan mode.**

If NOT in plan mode, **stop immediately** and tell the user:

```
Shape-spec must be run in plan mode. Please enter plan mode first, then run /shape-spec again.
```

Do not proceed with any steps below until confirmed to be in plan mode.

## Process

### Step 1: Clarify What We're Building

Use the available question tool or chat to understand the scope:

```
What are we building? Please describe the feature or change.

(Be as specific as you like — I'll ask follow-up questions if needed)
```

Based on their response, ask 1-2 clarifying questions if the scope is unclear. Examples:
- "Is this a new feature or a change to existing functionality?"
- "What's the expected outcome when this is done?"
- "Are there any constraints or requirements I should know about?"

### Step 2: Gather Visuals

Use the available question tool or chat:

```
Do you have any visuals to reference?

- Mockups or wireframes
- Screenshots of similar features
- Examples from other apps

(Paste images, share file paths, or say "none")
```

If visuals are provided, note them for inclusion in the spec folder.

### Step 3: Identify Reference Implementations

Use the available question tool or chat:

```
Is there similar code in this codebase I should reference?

Examples:
- "The comments feature is similar to what we're building"
- "Look at how src/features/notifications/ handles real-time updates"
- "No existing references"

(Point me to files, folders, or features to study)
```

If references are provided, read and analyze them to inform the plan.

### Step 4: Check Product Context

Check if `agent-os/product/` exists and contains files.

If it exists, read key files (like `project-brief.md`, `mission.md`, `roadmap.md`, `tech-stack.md`) and surface SPECIFIC alignment points or conflicts — don't just ask if alignment is needed. Use the available question tool or chat:

```
I found product context in agent-os/product/:
- Project brief says: [summarize the project purpose and key careful areas in 1-2 lines]
- Mission targets: [summarize the mission focus in 1 line]
- Roadmap includes: [list any roadmap items that relate to this feature]
- Tech stack: [note any tech constraints relevant to this feature]

Does this feature affect or conflict with any of these? (yes — describe / no / not sure)
```

If no product folder exists, skip this step.

### Step 5: Surface Relevant Standards

Read `agent-os/standards/index.yml` to identify relevant standards based on the feature being built.

Use the available question tool or chat to confirm:

```
Based on what we're building, these standards may apply:

[List ONLY standards actually found in index.yml that are relevant to this feature.
Format each as: N. **folder/name** — [description from index.yml]
If no standards in the index are relevant, say so and skip this step.]

Should I include these in the spec? (yes / adjust: remove N, add folder/name)
```

Read the confirmed standards files to include their content in the plan context.

### Step 6: Generate Spec Folder Name

Create a folder name using this format:
```
YYYY-MM-DD-HHMM-{feature-slug}/
```

Where:
- Date/time is current timestamp
- Feature slug is derived from the feature description (lowercase, hyphens, max 40 chars)

Example: `2026-01-15-1430-user-comment-system/`

**Note:** If `agent-os/specs/` doesn't exist, create it when saving the spec folder.

### Step 7: Structure the Plan

Now build the plan with **Task 1 always being "Save spec documentation"**.

Present this structure to the user:

```
Here's the plan structure. Task 1 saves all our shaping work before implementation begins.

---

# Plan: [Feature Name]

## ⚡ Session Start Protocol (Read This First)
Before doing ANY work in this session:
1. Read `standards.md` in this spec folder — all rules there are mandatory for every task
2. Scan this file for any `[/] In Progress` tasks → apply RECOVERY RULE below
3. Read `agent-os/specs/CHANGELOG.md` if it exists to understand recent project history
4. Do NOT begin any implementation until steps 1–3 are complete

## State Tracking & Execution Rules
Future agents MUST strictly update this file during execution.
- `[ ]` Pending
- `[/] In Progress` — update to this BEFORE writing any code
- `[x] Completed: [comma-separated modified files]`

**PONYTAIL RULE (YAGNI & MINIMIZATION):** Before writing any new code or creating new files, stop at the first rung that holds:
  1. Does this need to exist at all? Speculative need = skip it. (YAGNI)
  2. Does the standard library already do this? Use it.
  3. Does a native platform feature cover it? (`<input type="date">` over a picker lib, CSS over JS, DB constraint over app code.) Use it.
  4. Does an already-installed dependency solve it? Use it. Never add a new one for what a few lines can do.
  5. Can it be one line? Make it one line.
  6. Only then: write the minimum code that works.
  Mark deliberate simplifications with a `ponytail:` comment — if the shortcut has a known ceiling, name it and the upgrade path.
  NEVER simplify away: input validation, error handling that prevents data loss, security, or accessibility.
  Output: code first, then at most three short lines on what was skipped and when to add it.

**VERIFICATION GATE:** Before changing any implementation task to `[x]`, you MUST:
  1. Read the project manifest (package.json, pyproject.toml, Cargo.toml, go.mod, etc.) to find the defined lint/check/typecheck script.
  2. Run ONLY scripts explicitly defined in that manifest. NEVER invent commands.
  3. If no lint script exists → run a syntax-only check (e.g., `node --check file.js` or `python -m py_compile file.py`). Use OS-appropriate commands.
  4. If no manifest exists → skip and note: "No manifest detected — manual review advised."
  5. Scan output for: "error", "Error", "FAILED", "Cannot find". Exit code 0 with zero errors required. Warnings are acceptable but must be noted.
  6. If errors exist → remain in `[/]` and fix. Mark `[x]` ONLY upon a clean result.
  Documentation-only tasks may record "Documentation-only task — verification not required."

**RECOVERY RULE:** If you find a `[/] In Progress` item at session start, re-read the files from the previous `[x]` completed entries, verify the partial work, then decide: resume or reset to `[ ]`.

**POST-TASK MANDATE:** After completing each task, you MUST:
1. Use a file-edit tool to write the updated marker directly into `plan.md` on disk.
   - First re-read `plan.md` to get current content — never rely on conversation memory.
   - Change `[/] In Progress` → `[x] Completed: [comma-separated modified files]`
2. Record the Verification Gate result inline in the `[x]` entry.
3. Refresh `agent-os/specs/CHANGELOG.md` with /spec-changelog after completing or materially updating spec work.

Never mark a task complete only in conversation — the mutation MUST be written to disk.
Do NOT rewrite task text. Only mutate the state markers.

## Task 1: Save Spec Documentation

Create `agent-os/specs/{folder-name}/` with:

- [ ] **plan.md** — This full plan
- [ ] **shape.md** — Shaping notes (scope, decisions, context from our conversation)
- [ ] **standards.md** — Relevant standards that apply to this work
- [ ] **references.md** — Pointers to reference implementations studied
- [ ] **visuals/** — Any mockups or screenshots provided (skip if none)
- [ ] **Update `agent-os/specs/CHANGELOG.md`** — Run /spec-changelog after saving this spec

## Task 2: [First implementation task]

- [ ] [Description based on the feature]

## Task 3: [Next task]

...

---

Does this plan structure look right? I'll fill in the implementation tasks next.
```

### Step 8: Complete the Plan

After Task 1 is confirmed, continue building out the remaining implementation tasks based on:
- The feature scope from Step 1
- Patterns from reference implementations (Step 3)
- Constraints from standards (Step 5)
- Project understanding from `project-brief.md` if present

Each task should be specific and actionable.

### Step 9: Ready for Execution

When the full plan is ready:

```
Plan complete. When you approve and execute:

1. Task 1 will save all spec documentation first
2. Then implementation tasks will proceed

IMPORTANT: This plan was created in plan mode. To implement it:
- Exit plan mode
- Approve this plan
- The executing agent must re-read plan.md before starting — never assume task status from this conversation

Ready to start? (approve / adjust)
```

## Output Structure

The spec folder will contain:

```
agent-os/specs/{YYYY-MM-DD-HHMM-feature-slug}/
├── plan.md           # The full plan
├── shape.md          # Shaping decisions and context
├── standards.md      # Which standards apply and key points
├── references.md     # Pointers to similar code
└── visuals/          # Mockups, screenshots (if any)
```

The project spec history will be maintained in:

```
agent-os/specs/CHANGELOG.md
```

## shape.md Content

The shape.md file should capture:

```markdown
# {Feature Name} — Shaping Notes

## Scope

[What we're building, from Step 1]

## Decisions

- [Key decisions made during shaping]
- [Constraints or requirements noted]

## Context

- **Visuals:** [List of visuals provided, or "None"]
- **References:** [Code references studied]
- **Product alignment:** [Notes from product context, or "N/A"]

## Standards Applied

- api/response-format — [why it applies]
- api/error-handling — [why it applies]
```

## standards.md Content

Include the full content of each relevant standard:

```markdown
# Standards for {Feature Name}

The following standards apply to this work.

---

## api/response-format

[Full content of the standard file]

---

## api/error-handling

[Full content of the standard file]
```

## references.md Content

```markdown
# References for {Feature Name}

## Similar Implementations

### {Reference 1 name}

- **Location:** `src/features/comments/`
- **Relevance:** [Why this is relevant]
- **Key patterns:** [What to borrow from this]

### {Reference 2 name}

...
```

## Tips

- **Keep shaping fast** — Don't over-document. Capture enough to start, refine as you build.
- **Visuals are optional** — Not every feature needs mockups.
- **Standards guide, not dictate** — They inform the plan but aren't always mandatory.
- **Specs are discoverable** — Months later, someone can find this spec and understand what was built and why.
