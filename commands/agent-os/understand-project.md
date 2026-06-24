# Understand Project

Create a developer-readable project brief before planning or implementing work. This command helps agents and humans understand an unfamiliar project without loading the entire codebase.

## Important Guidelines

- **Explore before asking** — inspect project facts first, then ask only about intent, priorities, or risky areas that cannot be inferred.
- **Use the available user-input/question tool** when one exists. If none exists, ask one concise question in chat.
- **Read selectively** — do not load the whole codebase. Read manifests, README/docs, routing/entrypoints, config files, and 2-5 representative source files.
- **Separate facts from assumptions** — mark inferred architecture or uncertain behavior clearly.
- **Optimize for onboarding and execution** — the brief should help a new developer understand the project and help an agent work safely.

## Process

### Step 1: Map the Project

Run OS-appropriate commands to identify:

- Manifests: `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, `.csproj`, `composer.json`, `pom.xml`, `build.gradle`, etc.
- Existing docs: `README*`, `docs/`, `CONTRIBUTING*`, architecture notes.
- Main directories and likely entrypoints.
- Test, build, and run scripts from manifests only.
- Existing `agent-os/product/` files, if any.

Do not read generated/vendor/build folders such as `node_modules`, `dist`, `build`, `.git`, `.venv`, `target`, `coverage`.

### Step 2: Read Representative Files

Read only what is needed to understand structure:

- Manifest files and README/docs summaries.
- Primary app/server/CLI entrypoints.
- Routing or module registration files.
- Configuration files that reveal integrations.
- 2-5 representative source files from the main areas.

If the project is large or has multiple apps/packages, note that and propose creating `architecture.md` in addition to `project-brief.md`.

### Step 3: Ask Targeted Questions

After exploration, ask only questions that materially improve the brief. Use these defaults unless exploration suggests better ones:

```
I mapped the project and can create the brief. A few details would improve it:

1. Is this brief mainly for onboarding, agent execution, or both?
2. What parts of the project are most important to understand first?
3. Are there areas agents should avoid or treat carefully?
```

Ask one question at a time if the available tool or chat interface works best that way.

### Step 4: Generate Files

Create `agent-os/product/` if needed.

Generate `agent-os/product/project-brief.md`:

```markdown
# Project Brief

## What This Project Is

[Plain-language summary of the product/tool/library and its purpose.]

## How It Runs

- **Install:** [commands from manifests/docs, or "Not documented"]
- **Develop:** [dev command, or "Not documented"]
- **Test:** [test command, or "Not documented"]
- **Build:** [build command, or "Not documented"]

## Main Structure

- `[path]` — [what lives here]
- `[path]` — [what lives here]

## Data Flow / Request Flow

[How input moves through the system. Mark as inferred if not explicit.]

## Key Integrations

- [Database, external APIs, queues, auth, payments, hosting, analytics, etc.]

## Current Project Docs

- [Existing docs found and what each covers]

## Known Risks / Careful Areas

- [Security, data-loss paths, migrations, generated files, fragile modules, unknowns]

## Where To Start

- For new developers: [first files/docs to read]
- For agents: [first context files to load before work]

## Open Questions

- [Unknowns that could not be answered from the repository]
```

For large projects, also create `agent-os/product/architecture.md`:

```markdown
# Architecture Notes

## System Overview

[High-level architecture.]

## Major Components

- `[component/path]` — [responsibility]

## Boundaries

- [Frontend/backend/package/service boundaries]

## Important Flows

- [Critical user/system flows]

## Operational Notes

- [Deployment, jobs, queues, migrations, observability if discoverable]
```

### Step 5: Confirm Completion

After writing files, output:

```
Project understanding created:

  agent-os/product/project-brief.md
  [agent-os/product/architecture.md if created]

Next steps:
- Run /create-tech-stack to document the factual stack
- Run /discover-standards to capture conventions
- Run /plan-product if product mission or roadmap are missing
```
