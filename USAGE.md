# Agent OS Usage

This fork is multi-tool by default. Claude slash commands are still supported, but any coding agent that can read files can use the same command instructions and standards.

## Install Into a Project

From the target project directory on macOS/Linux/Git Bash/WSL:

```bash
~/agent-os/scripts/project-install.sh
```

From PowerShell on Windows:

```powershell
~/agent-os/scripts/project-install.ps1
```

Use `--dry-run` to preview what will be installed. Use `--commands-only` to refresh command files without touching standards.

PowerShell equivalents use `-DryRun`, `-CommandsOnly`, and `-NoStandardsOverwrite`.

Use `--no-standards-overwrite` when you want the install to fail instead of prompting if `agent-os/standards/` already exists.

The installer creates:

- `agent-os/standards/` — project standards copied from the selected profile
- `agent-os/standards/index.yml` — matching index used by `/inject-standards`
- `agent-os/product/README.md` — guide to product/context docs
- `.claude/commands/agent-os/` — command markdown files

## First-Time Project Workflow

1. `/understand-project` — create `agent-os/product/project-brief.md`
2. `/create-tech-stack` — document the factual stack from manifests
3. `/discover-standards` — capture conventions from real code
4. `/plan-product` — create or update mission and roadmap
5. `/continue-roadmap` — transition the next roadmap phase into a shaped spec
6. `/shape-spec` — plan meaningful feature work
7. `/spec-changelog` — maintain `agent-os/specs/CHANGELOG.md`
8. `/review-project` — audit project readiness and improvement gaps

## Using Other Agents

If slash commands are unavailable, reference command files directly:

```text
@.claude/commands/agent-os/understand-project.md run this command
@.claude/commands/agent-os/inject-standards.md inject relevant standards
@.claude/commands/agent-os/spec-changelog.md update spec history
@.claude/commands/agent-os/review-project.md review project readiness
```

You can also reference standards directly:

```text
@agent-os/standards/index.yml choose relevant standards
@agent-os/standards/global/minimalist-code.md follow this standard
```

## Standards vs Commands

- Standards describe conventions: what the project expects.
- Commands describe procedures: how the agent should perform a workflow.
- Skills or custom agents can reference standards when a repeated procedure should be automatic.
