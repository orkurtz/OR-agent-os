# Continue Roadmap

Transition the next pending phase from the product roadmap into a shaped specification. **Run this command while in plan mode.**

## Important Guidelines

- **Use the available user-input/question tool** when one exists. If none exists, ask one concise question in chat.
- **This command creates a spec for the next roadmap phase.** It does NOT implement anything.

## Prerequisites

This command **must be run in plan mode**.

**Before proceeding, check if you are currently in plan mode.**

If NOT in plan mode, **stop immediately** and tell the user:

```
continue-roadmap must be run in plan mode. Please enter plan mode first, then run /continue-roadmap again.
```

## Process

### Step 1: Read the Roadmap

Check if `agent-os/product/roadmap.md` exists. 

If it does not exist, tell the user:
```
I couldn't find a roadmap at `agent-os/product/roadmap.md`. Please run `/plan-product` first to generate your product roadmap.
```
Then stop.

If it exists, read its contents.

### Step 2: Identify the Next Phase

Find the very first uncompleted (`- [ ]`) item in the roadmap.

If all items are completed (`- [x]` or similar), inform the user:
```
All phases in the roadmap appear to be completed! If you'd like to add more phases, you can edit `agent-os/product/roadmap.md` or run `/plan-product` again.
```
Then stop.

### Step 3: Trigger Shape-Spec

Extract the description of the next uncompleted item. Tell the user:
```
The next phase in the roadmap is:
"[Insert the description of the uncompleted item]"

I will now transition this into a detailed plan.
```

Then, **internally trigger the `/shape-spec` process**. 
Treat the description of the uncompleted item as the user's answer to `/shape-spec` Step 1 (What feature or change are we planning?). 

**Proceed immediately with `/shape-spec` Step 2 (Gather Visuals) and follow the rest of the `/shape-spec` flow to create the plan.** You do not need to ask the user what we are building, as the roadmap item provides that context.

### Step 4: Inject Spec & Roadmap Completion Task

While building the plan structure during `/shape-spec` (Step 7), you MUST ensure the final implementation task in the plan is to update both the spec's `plan.md` and the roadmap:

`Task: Update the spec's plan.md (marking this final task as completed) and agent-os/product/roadmap.md to mark this phase as completed (e.g. change [ ] to [x]) and summarize the files changed or what was built, just like we do in shape-spec.`

