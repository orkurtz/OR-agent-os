# Create Tech Stack

Establish the factual tech stack by checking global standards and scanning local project manifests before engaging the user.

## Important Guidelines
- **Always use AskUserQuestion tool** when interacting.
- **Merge context** — Compare global standards against local CLI findings.
- **Execute OS-appropriate terminal commands** to achieve this goal. Dynamically translate standard Unix concepts (`tree`, `grep`, `cat`, `ls`) into the native commands of the user's current host operating system.

## Process

### Step 1: Check Global Standards
Check if `agent-os/standards/global/tech-stack.md` exists. If it does, read it to extract the baseline technologies.

### Step 2: Deterministic Local Discovery
Do NOT rely on a hardcoded list of files. You must dynamically discover the project type.
1. Execute OS-appropriate terminal commands (translating Unix concepts like `ls -la` or `tree -L 2`) in the project root to identify which dependency manifest files exist (e.g., `package.json`, `Cargo.toml`, `pom.xml`, `requirements.txt`, `composer.json`, `build.gradle`, `.csproj`, `go.mod`, etc.).
2. Execute OS-appropriate terminal commands (translating concepts like `cat` or `grep`) to read ONLY the identified dependency manifest files. Do NOT read source code.
3. Analyze the raw output to identify the core frameworks, libraries, and database drivers actually installed.

### Step 3: Present and Confirm
Synthesize the findings and use AskUserQuestion based on what was found:

**Scenario A: Global Standard EXISTS**
```
I found a global tech stack standard:
[Summarize global tech]

I also scanned your local manifests and found:
[Summarize local CLI findings, or "No local manifests detected"]

How should we establish the tech stack for this project?

1. Use the Global Standard exactly as-is
2. Use the Local CLI findings
3. Different (I'll specify manually)

(Choose 1, 2, or 3)
```

**Scenario B: NO Global Standard, but Local CLI data FOUND**
```
I scanned the project manifests and identified the following tech stack:

Frontend: [Extracted tech or N/A]
Backend: [Extracted tech or N/A]
Database: [Extracted tech or N/A]
Other: [Extracted tools]

Is this accurate and complete?
(Respond "yes" or provide corrections/additions)
```

**Scenario C: NO Global Standard AND NO Local Manifests FOUND**
```
I couldn't detect existing global standards or local project manifests.
What technologies does this project use?

Please describe:
- Frontend: (e.g., React, Vue, vanilla JS, or N/A)
- Backend: (e.g., Rails, Node, Django, or N/A)
- Database: (e.g., PostgreSQL, MongoDB, or N/A)
- Other: (hosting, APIs, tools, etc.)
```

### Step 4: Generate File
Create `agent-os/product/tech-stack.md` using the selected/provided data:

```markdown
# Tech Stack

## Frontend
[Data]

## Backend
[Data]

## Database
[Data]

## Other
[Data]
```
