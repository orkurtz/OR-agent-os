# Plan Product

Establish foundational product documentation through an interactive conversation. Creates mission and roadmap files in `agent-os/product/`.

## Important Guidelines

- **Always use AskUserQuestion tool** when asking the user anything
- **Keep it lightweight** — gather enough to create useful docs without over-documenting
- **One question at a time** — don't overwhelm with multiple questions

## Process

### Step 1: Determine Lifecycle State

Use AskUserQuestion:

```
Is this a brand new project or an existing project? (Choose: New / Existing)
```

**Mandate waiting for the user's response before proceeding.**

### Step 2: Gather Product Vision (for mission.md)

Update the process to branch based on the answer from Step 1. Ensure questions are asked sequentially, waiting for an answer after each.

#### Path: NEW Project
Use AskUserQuestion sequentially, waiting for a response after each question:

1. **What is the idea you want to develop?**
2. **What problem are you trying to solve?**
3. **Who is the target audience?**
4. **How do you intend to solve it?**

#### Path: EXISTING Project
Use AskUserQuestion sequentially, waiting for a response after each question:

1. **What upgrade do you want to make / build?**
2. **Do you have an idea of how to build it?**
3. **What stage are you at / describe your current situation.**
4. **Are there things to consider that might affect the implementation?**

### Step 3: Gather Roadmap (for roadmap.md)

Update the process to branch based on the answer from Step 1. Ask sequentially, waiting for an answer after each.

#### Path: NEW Project
Use AskUserQuestion sequentially, waiting for a response after each question:

1. **What are the must-have features for launch (MVP)?**
2. **What features are planned for post-launch?**

#### Path: EXISTING Project
Use AskUserQuestion sequentially, waiting for a response after each question:

1. **What are the major features or architectural changes required for this new phase?**
2. **What are the exact technical or business acceptance criteria for this new phase to be considered "Complete"?**

### Step 4: Generate Files

Create the `agent-os/product/` directory if it doesn't exist.

Generate each file based on the information gathered:

#### mission.md

```markdown
# Product Mission

## Background & Problem

[Insert background, problem, or current situation from Step 2]

## Scope / Audience

[Insert target audience or scope of upgrade from Step 2]

## Solution & Constraints

[Insert solution description and any constraints/considerations from Step 2]
```

#### roadmap.md

```markdown
# Product Roadmap

## State Tracking & Execution Rules
CRITICAL: Future agents MUST strictly update this file during execution.
- `[ ]` Pending
- `[/] In Progress` (Must update to this BEFORE writing code)
- `[x] Completed: [comma-separated modified files]`
**VERIFICATION GATE:** Before changing to `[x]`, you MUST verify the specific files you modified:
  1. Analyze the extensions of the touched files.
  2. Dynamically infer and execute the appropriate local syntax/lint check in the terminal. Use OS-appropriate terminal commands. Read local manifests to find the correct project-specific command. Do NOT hallucinate global commands.
  3. If the terminal outputs compilation or syntax errors, you must remain in `[/]` and fix the code. Mark `[x]` ONLY upon a clean exit code.
Do NOT rewrite the tasks, only mutate the state markers.

[Depending on Step 1, generate the appropriate section below]

### For NEW Projects:
## Phase 1: MVP

- [ ] [Insert must-have features for launch - from Step 3]

## Phase 2: Post-Launch

- [ ] [Insert planned future features - from Step 3, or "To be determined" if they said none yet]

### For EXISTING Projects:
## Current State

- [ ] [Insert current stage / situation description from Step 2]

## New Phase

- [ ] [Insert major feature / architectural change required - from Step 3]
- [ ] [Insert acceptance criteria - from Step 3]
```


### Step 5: Confirm Completion

After creating all files, output to user:

```
✓ Product documentation created:

  agent-os/product/mission.md
  agent-os/product/roadmap.md

Review these files to ensure they accurately capture your product vision.
You can edit them directly or run /plan-product again to update.
```

## Tips

- If the user provides very brief answers, that's fine — the docs can be expanded later
- If they want to skip a section, create the file with a placeholder like "To be defined"
- The `/shape-spec` command will read these files when planning features, so having them populated helps with context
