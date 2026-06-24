# Plan Product

Establish foundational product documentation through an interactive conversation. Creates mission and roadmap files in `agent-os/product/`.

## Important Guidelines

- **Use the available user-input/question tool** when one exists. If none exists, ask one concise question in chat.
- **Keep it lightweight** — gather enough to create useful docs without over-documenting
- **One question at a time** — NEVER ask more than one question per message. NEVER proceed to the next question before receiving the user's answer. If the answer is unclear, ask ONE clarifying follow-up before moving on.
- **Product docs are context, not execution logs** — Do not add task-state machinery to high-level product roadmaps unless the user explicitly wants the roadmap used as an execution checklist.

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
Is this a brand new project or an existing project? (Choose: New / Existing)
```

**Mandate waiting for the user's response before proceeding.**

### Step 3: Gather Product Vision (for mission.md)

Update the process to branch based on the answer from Step 2. Ensure questions are asked sequentially, waiting for an answer after each.

#### Path: NEW Project
Ask sequentially, waiting for a response after each question:

1. **What product are you building? What should it do in plain language?**
2. **Who is the target user, and what problem are we solving for them?**
3. **What is the smallest useful v1 that would be worth launching?**
4. **What constraints are non-negotiable? (technical, business, compliance, UX, budget, timeline)**
5. **What should be intentionally deferred until after v1?**

#### Path: EXISTING Project
Ask sequentially, waiting for a response after each question:

1. **What does this project currently do, in plain language?**
2. **What phase, change, or upgrade are you planning now?**
3. **What already works and should be preserved?**
4. **What is risky, constrained, broken, or sensitive?**
5. **What does "done" mean for this phase?**

### Step 4: Gather Roadmap (for roadmap.md)

Update the process to branch based on the answer from Step 2. Ask sequentially, waiting for an answer after each.

#### Path: NEW Project
Ask sequentially, waiting for a response after each question:

1. **Which v1 outcomes or features are required for launch?**
2. **Which features are explicitly post-launch or "not yet"?**

#### Path: EXISTING Project
Ask sequentially, waiting for a response after each question:

1. **What major features, fixes, or architecture changes are required for this phase?**
2. **What acceptance criteria prove this phase is complete?**

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

⚠️ GENERATE ONLY ONE of the two sections below based on the lifecycle answer from Step 2.
Write only the matching section into roadmap.md. Delete the other section AND this instruction entirely from the generated file.

--- IF NEW PROJECT ---

## Phase 1: MVP

- [ ] [Insert must-have features for launch - from Step 4]

## Phase 2: Post-Launch

- [ ] [Insert planned future features - from Step 4, or "To be determined" if they said none yet]

--- IF EXISTING PROJECT ---

## Current State

- [ ] [Insert current stage / situation description from Step 3]

## New Phase

- [ ] [Insert major feature / architectural change required - from Step 4]
- [ ] [Insert acceptance criteria - from Step 4]
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

- If the user provides very brief answers, that's fine — the docs can be expanded later
- If they want to skip a section, create the file with a placeholder like "To be defined"
- The `/shape-spec` command will read these files when planning features, so having them populated helps with context
