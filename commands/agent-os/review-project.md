# Review Project

Create a project health review for developers and agents. This command audits whether the project is understandable, safe to work in, and well prepared for AI-assisted development.

## Important Guidelines

- **Inspect before asking** — read available project context first, then ask only about priorities or unclear risks that cannot be inferred.
- **Use the available user-input/question tool** when one exists. If none exists, ask one concise question in chat.
- **Read selectively** — do not load the whole codebase. Prefer durable docs, manifests, standards index, recent specs, and 2-5 representative source files.
- **Review, do not rewrite** — this command creates `project-review.md`; it does not automatically modify standards, product docs, or source code.
- **Separate facts, risks, and recommendations** — make it easy for a new developer to see what is solid and what needs attention.

## Process

### Step 1: Gather Existing Context

Inspect these files and folders if present:

- `agent-os/product/project-brief.md`
- `agent-os/product/tech-stack.md`
- `agent-os/product/mission.md`
- `agent-os/product/roadmap.md`
- `agent-os/standards/index.yml`
- `agent-os/specs/CHANGELOG.md`
- Recent `agent-os/specs/*/plan.md`, `shape.md`, `references.md`, `standards.md`
- `README*`, `docs/`, `CONTRIBUTING*`
- Dependency manifests and scripts

Also map the top-level project structure and read 2-5 representative files only when docs do not explain the project enough.

### Step 2: Identify Review Findings

Review these areas:

- **Project understanding** — can a new developer explain what this is and where to start?
- **Setup clarity** — are install/dev/test/build commands documented and discoverable?
- **Product context** — are mission, roadmap, and tech stack present and current?
- **Standards health** — are standards indexed, concise, and relevant?
- **Spec history** — does the Spec Changelog explain what changed over time?
- **Execution safety** — are risky files, migrations, generated folders, secrets, or data-loss paths obvious?
- **Verification** — are checks/tests discoverable from manifests?
- **Gaps** — what is missing, stale, contradictory, or too vague?

### Step 3: Ask Only If Needed

If priorities are unclear after inspection, ask:

```text
I can create the project review. What should I prioritize?

1. Onboarding clarity
2. Agent execution safety
3. Standards/spec health
4. Overall project readiness
```

Skip this question if the user's request already makes the priority clear.

### Step 4: Generate `project-review.md`

Create `agent-os/product/project-review.md`:

```markdown
# Project Review

## Summary

[Short assessment of project readiness for developers and agents.]

## What Is Clear

- [Strong existing docs, structure, standards, scripts, or specs.]

## Gaps / Risks

- [Missing, stale, ambiguous, risky, or contradictory areas.]

## Setup & Verification

- **Install:** [documented command or "Not clear"]
- **Develop:** [documented command or "Not clear"]
- **Test:** [documented command or "Not clear"]
- **Build:** [documented command or "Not clear"]
- **Verification risk:** [what agents should watch for]

## Standards Health

- [Index status, missing descriptions, standards that look stale, missing standards.]

## Spec History Health

- [Whether `agent-os/specs/CHANGELOG.md` exists and explains the project evolution.]

## Recommended Next Actions

1. [Highest-value improvement]
2. [Next improvement]
3. [Next improvement]

## Notes For Agents

- [What to read before work]
- [Where to be careful]
- [What not to touch without confirmation]
```

### Step 5: Confirm Completion

After creating the file, output:

```text
Project review created:

  agent-os/product/project-review.md

Recommended next command:
- Run /spec-changelog if spec history is missing or stale
```
