# Plan Product

Establish foundational product documentation through an interactive conversation. Creates mission and roadmap files in `agent-os/product/`.

## Important Guidelines

- **Use the available user-input/question tool** when one exists. If none exists, ask one concise question in chat.
- **Keep it lightweight** - gather enough to create useful docs without over-documenting.
- **One question at a time** - NEVER ask more than one question per message. NEVER proceed to the next question before receiving the user's answer. If the answer is unclear, ask ONE clarifying follow-up before moving on.
- **Product docs are context, not execution logs** - Do not add task-state machinery to high-level product roadmaps unless the user explicitly wants the roadmap used as an execution checklist.
- **Ask artifact-driven questions** - Every answer should help fill `mission.md` or `roadmap.md`.

## Process

### Step 1: Check Existing Context

Before asking questions, inspect whether these files exist:

- `README*`
- `docs/`
- `agent-os/product/project-brief.md`
- `agent-os/product/mission.md`
- `agent-os/product/roadmap.md`
- `agent-os/product/tech-stack.md`

If relevant docs exist, summarize what they already say and ask whether to use them as source context, update existing Agent OS product docs, or replace the product docs.

### Step 2: Determine Lifecycle State

Use the available question tool or chat:

```
Are we documenting a new product idea or an existing project?

Choose one: New / Existing
```

**Mandate waiting for the user's response before proceeding.**

### Step 3: Gather Product Vision (for mission.md)

Branch based on the answer from Step 2. Ask questions sequentially, waiting for an answer after each.

#### Path: NEW Project

Ask sequentially, waiting for a response after each question:

1. **What are we building, in one or two plain-language sentences?**
2. **Who is it for, and what problem should it solve for them?**
3. **What would make the first version useful enough to launch?**
4. **What constraints must shape the product? Include technical, business, compliance, UX, budget, or timeline constraints.**
5. **What should we intentionally leave out of the first version?**

#### Path: EXISTING Project

Ask sequentially, waiting for a response after each question:

1. **What does this project do today, in plain language?**
2. **What phase, change, or upgrade are we planning now?**
3. **What must keep working exactly as it does today?**
4. **Which areas are risky, fragile, constrained, or sensitive?**
5. **What concrete outcome means this phase is done?**

### Step 4: Gather Roadmap (for roadmap.md)

Branch based on the answer from Step 2. Ask sequentially, waiting for an answer after each.

#### Path: NEW Project

Ask sequentially, waiting for a response after each question:

1. **Which outcomes or features are required for the first launch?**
2. **Which useful ideas are explicitly post-launch or out of scope for now?**

#### Path: EXISTING Project

Ask sequentially, waiting for a response after each question:

1. **Which major features, fixes, or architecture changes are required for this phase?**
2. **What acceptance criteria would prove this phase is complete?**

### Step 5: Generate Files

Create the `agent-os/product/` directory if it doesn't exist.

Generate each file based on the information gathered:

#### mission.md

```markdown
# Product Mission

## Background & Problem

[Insert background, problem, or current situation from the answers above]

## Scope / Audience

[Insert target audience or scope of upgrade from the answers above]

## Solution & Constraints

[Insert solution description and any constraints/considerations from the answers above]

## Related Context

[Reference `project-brief.md` or `tech-stack.md` if present, otherwise "No existing Agent OS project context found."]
```

#### roadmap.md

```markdown
# Product Roadmap

WARNING: GENERATE ONLY ONE of the two sections below based on the lifecycle answer from Step 2.
Write only the matching section into roadmap.md. Delete the other section AND this instruction entirely from the generated file.

--- IF NEW PROJECT ---

## Phase 1: MVP

- [ ] [Insert required launch outcomes/features from Step 4]

## Phase 2: Post-Launch

- [ ] [Insert post-launch or out-of-scope ideas from Step 4, or "To be determined" if none were provided]

--- IF EXISTING PROJECT ---

## Current State

- [ ] [Insert current stage / situation description from Step 3]

## New Phase

- [ ] [Insert major feature / fix / architecture change required from Step 4]
- [ ] [Insert acceptance criteria from Step 4]
```

### Step 6: Confirm Completion

After creating all files, output to user:

```
Product documentation created:

  agent-os/product/mission.md
  agent-os/product/roadmap.md

Review these files to ensure they accurately capture your product vision.
You can edit them directly or run /plan-product again to update.

Next steps:
- Run /understand-project if project-brief.md does not exist
- Run /create-tech-stack to document your technology choices
- Run /shape-spec (in plan mode) when you're ready to plan a feature
```

## Tips

- If the user provides very brief answers, that's fine - the docs can be expanded later.
- If they want to skip a section, create the file with a placeholder like "To be defined".
- The `/shape-spec` command will read these files when planning features, so having them populated helps with context.
