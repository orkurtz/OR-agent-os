# Agent OS Fork

Agent OS is a lightweight project operating layer for AI-assisted development. This fork keeps the original Agent OS idea of standards and spec shaping, then adds stronger support for real project onboarding, multi-agent usage, execution tracking, Windows/PowerShell workflows, and developer-readable project history.

It is designed for Claude Code, Codex, Cursor, Windsurf, Antigravity, and any coding agent that can read markdown files.

## What This Fork Adds

- **Multi-tool commands**: Command docs no longer assume one specific agent tool. They instruct agents to use the available question/input tool, or ask concise chat questions when no tool exists.
- **Project understanding**: `/understand-project` creates `agent-os/product/project-brief.md` so humans and agents can quickly understand an unfamiliar codebase.
- **Project review**: `/review-project` creates `agent-os/product/project-review.md` with docs, setup, standards, spec history, risks, and recommended next actions.
- **Spec Changelog**: `/spec-changelog` creates `agent-os/specs/CHANGELOG.md`, the human-readable history of what changed, why, status, files touched, standards used, and incomplete work.
- **Factual tech stack**: `/create-tech-stack` discovers real project manifests instead of relying on fictional defaults.
- **Better product planning**: `/plan-product` asks sharper questions for new and existing projects and keeps roadmaps as product context, not noisy execution logs.
- **Better standards discovery**: `/discover-standards` separates real project conventions from framework defaults and records rule, why, example, anti-patterns, and exceptions.
- **Balanced spec execution**: `/shape-spec` keeps strict task state, recovery, Ponytail/YAGNI, and verification for meaningful implementation work.
- **Native PowerShell support**: Windows users can install and sync profiles without Git Bash or WSL.

## Install Into a Project

From a target project directory on macOS/Linux/Git Bash/WSL:

```bash
~/agent-os/scripts/project-install.sh
```

From PowerShell on Windows:

```powershell
~/agent-os/scripts/project-install.ps1
```

Preview first:

```bash
~/agent-os/scripts/project-install.sh --dry-run
```

```powershell
~/agent-os/scripts/project-install.ps1 -DryRun
```

The installer creates:

- `agent-os/standards/`
- `agent-os/standards/index.yml`
- `agent-os/product/README.md`
- `.claude/commands/agent-os/`

Existing standards are backed up before overwrite. Use `--commands-only` or `-CommandsOnly` to refresh commands without touching standards.

## How To Use It

Agent OS works best when you treat it as durable project memory. The files in `agent-os/` are meant to be read by both humans and agents before important work starts.

### First-Time Users

Use this flow when installing Agent OS into a project for the first time, especially a project you or your agent do not fully understand yet.

1. Install Agent OS with `project-install.sh` or `project-install.ps1`.
2. Run `/understand-project` first. This creates the project brief and gives everyone a shared map of the codebase.
3. Run `/create-tech-stack` so the stack is documented from real manifests instead of guesses.
4. Run `/discover-standards` for one important area at a time, such as API routes, UI components, database, testing, or auth.
5. Run `/plan-product` if mission and roadmap docs are missing or stale.
6. Use `/continue-roadmap` to transition the next roadmap phase into a shaped spec.
7. Use `/shape-spec` before building a meaningful feature or risky change.
8. Run `/spec-changelog` after specs are created or updated so project history stays readable.
9. Run `/review-project` when you want a health check and a prioritized list of gaps.

For a brand-new project, start with `/plan-product` after `/understand-project` if there is not much code yet. For an existing project, start with `/understand-project`, then `/discover-standards`.

### Regular Users

Use Agent OS during normal development to keep agents aligned and keep project history understandable.

- **Quick bug fix or small edit**: run `/inject-standards` or directly reference the relevant standard, then implement.
- **New feature or risky change**: run `/shape-spec` first, save the spec, then implement from the plan.
- **After completing spec work**: run `/spec-changelog` so `agent-os/specs/CHANGELOG.md` shows what changed.
- **After discovering a repeated convention**: run `/discover-standards` and update `agent-os/standards/index.yml`.
- **After improving project standards**: run `sync-to-profile.sh` or `sync-to-profile.ps1` to reuse them in future projects.
- **When onboarding a developer or agent**: point them to `project-brief.md`, `tech-stack.md`, `standards/index.yml`, and `specs/CHANGELOG.md`.
- **When the project feels unclear**: run `/review-project` and work through its recommended next actions.

### Agents

Agents should not treat the current chat as the only source of truth. They should read the durable files first.

Before quick implementation:

```text
Read agent-os/standards/index.yml.
Select and read only the relevant standards.
Apply those standards while changing code.
```

Before meaningful implementation:

```text
Read agent-os/product/project-brief.md.
Read agent-os/product/tech-stack.md.
Read agent-os/specs/CHANGELOG.md if it exists.
Run or follow /shape-spec before editing.
During execution, update plan task markers on disk.
After material progress, refresh /spec-changelog.
```

Before reviewing or auditing:

```text
Read agent-os/product/project-brief.md.
Read agent-os/product/mission.md and roadmap.md if present.
Read agent-os/standards/index.yml.
Read agent-os/specs/CHANGELOG.md.
Then run or follow /review-project.
```

Agents should keep changes minimal, follow the Ponytail/YAGNI standard, avoid inventing dependencies or commands, and verify with scripts that actually exist in the project manifests.

## Recommended First-Time Flow

1. `/understand-project` - create the project brief.
2. `/create-tech-stack` - document the factual stack from manifests.
3. `/discover-standards` - extract real conventions from the codebase.
4. `/plan-product` - create or update mission and roadmap.
5. `/continue-roadmap` - transition the next roadmap phase into a shaped spec.
6. `/shape-spec` - plan meaningful work in plan mode.
7. `/spec-changelog` - maintain the project history from specs.
8. `/review-project` - audit readiness, risks, and gaps.

## Commands

- `/understand-project`: Use when entering a new or poorly understood repo. Builds `agent-os/product/project-brief.md`.
- `/create-tech-stack`: Use after install or when dependencies change. Scans manifests and writes `agent-os/product/tech-stack.md`.
- `/discover-standards`: Use when conventions are undocumented or have changed. Extracts standards into `agent-os/standards/`.
- `/index-standards`: Use after manually adding/removing standards. Maintains `agent-os/standards/index.yml`.
- `/inject-standards`: Use before quick implementation. Loads relevant standards into the current context.
- `/plan-product`: Use when product mission or roadmap is missing/stale. Creates or updates `mission.md` and `roadmap.md`.
- `/continue-roadmap`: Use when you want to proceed with the next phase of the product roadmap.
- `/shape-spec`: Use before meaningful, multi-step, or risky work. Creates persistent specs for implementation.
- `/spec-changelog`: Use after specs are created or completed. Creates or updates `agent-os/specs/CHANGELOG.md`.
- `/review-project`: Use for audits, onboarding readiness, and gap finding. Creates `agent-os/product/project-review.md`.

If slash commands are unavailable, reference command files directly:

```text
@.claude/commands/agent-os/understand-project.md run this command
@.claude/commands/agent-os/shape-spec.md shape this feature
@.claude/commands/agent-os/spec-changelog.md update spec history
```

## Generated Project Structure

```text
agent-os/
  product/
    README.md
    project-brief.md
    project-review.md
    mission.md
    roadmap.md
    tech-stack.md
  standards/
    index.yml
    global/
      minimalist-code.md
  specs/
    CHANGELOG.md
    YYYY-MM-DD-HHMM-feature-slug/
      plan.md
      shape.md
      standards.md
      references.md
      visuals/
.claude/
  commands/
    agent-os/
      *.md
```

## Profiles

Profiles let you reuse standards across projects. Install a specific profile:

```bash
~/agent-os/scripts/project-install.sh --profile rails
```

```powershell
~/agent-os/scripts/project-install.ps1 -Profile rails
```

After improving standards in a project, sync them back:

```bash
~/agent-os/scripts/sync-to-profile.sh --profile rails --all --overwrite
```

```powershell
~/agent-os/scripts/sync-to-profile.ps1 -Profile rails -All -Overwrite
```

## Philosophy

This fork is intentionally not a heavyweight agent runtime. It gives agents and developers durable project memory:

- what the project is
- how it runs
- what standards matter
- what has been planned
- what changed over time
- where agents must be careful

The goal is better code, better agents, and better understanding for developers joining a project they have never seen before.

## Credits

Based on [Agent OS](https://buildermethods.com/agent-os) by Brian Casel and Builder Methods. This fork adds a more opinionated workflow for multi-tool agents, project understanding, Spec Changelog history, PowerShell support, and stronger execution discipline.
