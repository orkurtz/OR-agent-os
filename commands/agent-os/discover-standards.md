# Discover Standards

Extract tribal knowledge from your codebase into concise, documented standards.

## Important Guidelines

- **Use the available user-input/question tool** when one exists. If none exists, ask one concise question in chat.
- **Write concise standards** - Use minimal words. Standards must be scannable by AI agents without bloating context windows.
- **Offer suggestions** - Present options the user can confirm, choose between, or correct. Don't make them think harder than necessary.
- **Execute OS-appropriate commands** - Dynamically translate standard Unix concepts (`tree`, `grep`, `cat`, `ls`) into the native commands of the user's current host operating system.
- **Read ONLY what you need** - Limit deep reads to 2-5 files per area. Do NOT load entire directories. Do NOT re-read files already in context.
- **Document project conventions, not generic framework defaults** - A standard should capture something repeated, local, opinionated, or risky enough that future agents need to know it.

## Process

### Step 1: Determine Focus Area

Check if the user specified an area when running this command. If they did, skip to Step 2.

If no area was specified:

1. Run terminal commands to map the codebase. Specifically, execute `tree -d` (for full directory architecture) and `tree -L 4 -I 'node_modules|dist|.git|venv'` (for file mapping). Execute OS-appropriate terminal commands to achieve this goal by dynamically translating these Unix concepts into native commands of your host operating system.
2. Identify 3-5 major areas. Examples:
   - **Frontend areas:** UI components, styling/CSS, state management, forms, routing
   - **Backend areas:** API routes, database/models, authentication, background jobs
   - **Cross-cutting:** Error handling, validation, testing, naming conventions, file structure
3. Use the available question tool or chat to present the areas:

```
I've identified these areas in your codebase:

1. **API Routes** (src/api/) - Request handling, response formats
2. **Database** (src/models/, src/db/) - Models, queries, migrations
3. **React Components** (src/components/) - UI patterns, props, state
4. **Authentication** (src/auth/) - Login, sessions, permissions

Which area should I inspect for project-specific conventions?

Choose one number, or name a different area. Good standards usually come from code that repeats across several files.
```

Wait for user response before proceeding.

### Step 2: Analyze & Present Findings

Once an area is determined:

1. Perform a two-part analysis of the selected area to extract patterns:
   a) **Skeleton Extraction:** Mandate fast terminal searches (e.g., `grep -r "class\|interface\|extends\|export\|return {" [selected_area] | head -n 50`) to identify macro-patterns. Dynamically translate standard Unix concepts (`grep`, `head`) into native commands of your host operating system.
   b) **Deep Reading:** Limit yourself to fully reading ONLY 2-5 specific files that clearly represent the patterns found in the grep/skeleton output.
2. Look for patterns that are:
   - **Unusual or unconventional** - Not standard framework/library patterns
   - **Opinionated** - Specific choices that could have gone differently
   - **Tribal** - Things a new developer wouldn't know without being told
   - **Consistent** - Patterns repeated across multiple files
   - **Risk-reducing** - Patterns that prevent data loss, security bugs, regressions, or confusion
   - **Not framework defaults** - Avoid documenting behavior that the framework already clearly dictates
3. Use the available question tool or chat to present findings and let user select:

```
I analyzed [area] and found these repeated project-specific patterns:

1. **API Response Envelope** - All responses use { success, data, error } - seen in src/api/users.ts, src/api/projects.ts
2. **Error Codes** - Custom codes like AUTH_001 and DB_002 - seen in src/api/errors.ts, src/lib/errors.ts
3. **Pagination Pattern** - Cursor pagination with `cursor` and `limit` params - seen in src/api/users.ts, src/api/audit-log.ts

Which patterns should become standards?

Answer: all / numbers only / add: [pattern] / skip
```

Wait for user selection before proceeding.

### Step 3: Confirm Rule, Then Draft Each Standard

**IMPORTANT:** For each selected standard, you MUST complete this full loop before moving to the next standard:

1. **Confirm it is worth documenting:**
   ```
   For **[standard name]**, is this truly a project convention?

   Answer: yes / no, framework default / not sure
   ```
2. **Wait for user response.** If the answer is "no, framework default", skip this standard.
3. **Ask what agents should always do:**
   ```
   When this convention applies, what should an agent always do?
   ```
4. **Ask what agents should never do:**
   ```
   What mistakes should an agent avoid here?
   ```
5. **Ask for the strongest local example:**
   ```
   What is the strongest code example for this standard?

   Provide a file path, function, component, or flow if you know one. If not, say "use the examples you found".
   ```
6. **Ask the exception question:**
   ```
   When should this convention not apply, if ever?
   ```
7. **Draft the standard** with the rule, why, example, anti-patterns, and exceptions.
8. **Confirm with user** before creating the file:
   ```
   Does this draft capture the rule correctly?

   Answer: yes / edit: [changes] / skip
   ```
9. **Create the file** if approved.

**Do NOT batch all questions upfront.** Process one standard at a time through the full loop.

### Step 4: Create the Standard File

For each standard (after completing Step 3's Q&A):

1. Determine the appropriate folder (create if needed):
   - `api/`, `database/`, `javascript/`, `css/`, `backend/`, `testing/`, `global/`

2. Check if a related standard file already exists - append to it if so.

3. Draft the content and use the available question tool or chat to confirm:

```
Here's the draft for api/response-format.md:

---
# API Response Format

All API responses use this envelope:

\`\`\`json
{ "success": true, "data": { ... } }
{ "success": false, "error": { "code": "...", "message": "..." } }
\`\`\`

- **Rule:** Always return the response envelope.
- **Why:** Frontend code checks one predictable shape.
- **Local example:** `src/api/users.ts`
- **Anti-patterns:** Never return raw arrays or unwrapped objects.
- **Exceptions:** None unless explicitly documented in this standard.
---

Does this draft capture the rule correctly?

Answer: yes / edit: [changes] / skip
```

4. Create or update the file in `agent-os/standards/[folder]/`
5. **Then repeat Steps 3-4 for the next selected standard**

### Step 5: Update the Index

After all standards are created:

1. Scan `agent-os/standards/` for all `.md` files
2. For each new file without an index entry, use the available question tool or chat:

```
New standard needs an index entry:
  File: api/response-format.md

Suggested description: "API response envelope structure and error format"

Accept this description?

Answer: yes / edit: [better one-line description]
```

3. Update `agent-os/standards/index.yml`:

```yaml
api:
  response-format:
    description: API response envelope structure and error format
```

Alphabetize by folder, then by filename.

### Step 6: Offer to Continue

Use the available question tool or chat:

```
Standards created for [area]:
- api/response-format.md
- api/error-codes.md

Would you like to discover standards in another area?

Answer: yes: [area] / no, done
```

## Output Location

All standards: `agent-os/standards/[folder]/[standard].md`
Index file: `agent-os/standards/index.yml`

## Writing Concise Standards

Standards will be injected into AI context windows. Every word costs tokens. Follow these rules:

- **Lead with the rule** - State what to do first, explain why second (if needed).
- **Use code examples** - Show, don't tell.
- **Skip the obvious** - Don't document what the code already makes clear.
- **One standard per concept** - Don't combine unrelated patterns.
- **Bullet points over paragraphs** - Scannable beats readable.
- **Include the full decision** - Each standard should capture the rule, why it exists, examples, anti-patterns, and when it does not apply.

**Good:**
```markdown
# Error Responses

Use error codes: `AUTH_001`, `DB_001`, `VAL_001`.

\`\`\`json
{ "success": false, "error": { "code": "AUTH_001", "message": "..." } }
\`\`\`

- Always include both code and message.
- Log full error server-side, return safe message to client.
- Local example: `src/api/errors.ts`
```

**Bad:**
```markdown
# Error Handling Guidelines

When an error occurs in our application, we have established a consistent pattern for how errors should be formatted and returned to the client. This helps maintain consistency across our API and makes it easier for frontend developers to handle errors appropriately...
[continues for 3 more paragraphs]
```

## Example: Full Loop for One Standard

Here's how to process a single standard through the complete workflow:

**1. Present findings (Step 2):**
```
I found these patterns in your API code:
1. **Response Envelope** - All responses use { success, data, error } - seen in src/api/users.ts, src/api/projects.ts
2. **Error Codes** - Custom codes like AUTH_001 - seen in src/api/errors.ts

Which patterns should become standards?

Answer: all / numbers only / add: [pattern] / skip
```

User: "Both"

**2. Confirm the first standard is real (Step 3):**
```
For **Response Envelope**, is this truly a project convention?

Answer: yes / no, framework default / not sure
```

User: "Yes"

**3. Ask what agents should always do:**
```
When this convention applies, what should an agent always do?
```

User: "Always return success plus data or error, so frontend code can read one predictable shape."

**4. Ask anti-pattern question:**
```
What mistakes should an agent avoid here?
```

User: "Never return raw arrays or unwrapped objects. Never omit the success key."

**5. Ask for the strongest local example:**
```
What is the strongest code example for this standard?

Provide a file path, function, component, or flow if you know one. If not, say "use the examples you found".
```

User: "Use src/api/users.ts."

**6. Ask exception question:**
```
When should this convention not apply, if ever?
```

User: "No exceptions."

**7. Draft, confirm, create file, then move to the next standard.**

**Key point:** Complete the full ask -> draft -> confirm -> create cycle for each standard before starting the next one.
