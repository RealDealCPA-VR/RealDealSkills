---
name: project-operating-system
description: >-
  Run an AI-assisted coding project as a controlled, multi-session operating system instead of
  improvised one-off edits. Use this whenever working in a codebase across more than one session,
  whenever the user says things like "pick up where we left off", "what's next", "continue the
  project", "start the next task", "run the next todo", "set up project rules", "keep this from
  drifting", or hands off work between sessions/agents. It bootstraps and maintains seven control
  files (HANDOFF, Todo, ARCHITECTURE, DECISIONS, REQUIREMENTS, REGRESSION_CHECKLIST,
  ACCEPTANCE_CRITERIA) and automatically runs the PICKUP, WORK, VERIFY, and HANDOFF lifecycle so
  state lives in files, not in model memory. Trigger it proactively at the start of any coding
  session in an established project, even if the user only describes a feature or fix and never
  names this system, because continuity and verification are exactly what prevents AI sessions from
  silently breaking prior work and drifting architecturally over time.
---

# Project Operating System

This is a single-file operating system for AI-assisted software development. Everything needed —
the lifecycle, the seven control-file templates, and the governance rules — is inlined below, so no
external scripts or bundled files are required. Read it top to bottom the first time you touch a
project, then run the lifecycle every session.

## Why this exists

A powerful model is a fast contributor but not a reliable owner. Across many sessions it will drift,
duplicate logic, quietly break prior work, and erode architecture — not from malice but because each
session starts with no memory of the last. The fix is to keep continuity in **files, not memory**,
and to make every session follow the same loop without being asked:

> Treat each session like a replaceable contractor. It reads the brief, verifies the prior
> contractor's work still functions, completes **one bounded task**, proves it works, and leaves
> clean written state for the next contractor.

When this system is active, do not wait for the user to walk you through the steps. Run the whole
lifecycle end to end on your own. The user invoking this system *is* the instruction to self-govern.
Keep narration light — the value is in the work and the written state, not a play-by-play.

## The seven control files

They live at the project root by default (a subfolder like `docs/project-os/` is fine — just record
the choice in `ARCHITECTURE.md` so future sessions look in the right place). Each has one job and a
distinct time horizon.

| File | Horizon | Job |
|---|---|---|
| `HANDOFF.md` | short | What the last session did, what to verify first, the exact next task |
| `Todo.md` | short | Ordered, checkbox task queue — sequenced execution, no feature jumping |
| `REGRESSION_CHECKLIST.md` | medium | Build/render/route/data sanity checks to catch silent breakage |
| `ACCEPTANCE_CRITERIA.md` | medium | Observable, behavioral definition of "done" per task |
| `ARCHITECTURE.md` | long | Stable structure, boundaries, and the project's conventions. Changes rarely |
| `DECISIONS.md` | long | Why meaningful choices were made, alternatives rejected, tradeoffs |
| `REQUIREMENTS.md` | long | Product truth: what the system must do for users (not how it's sequenced) |

The split that prevents the most damage: `REQUIREMENTS.md` is *what the product must do*, `Todo.md`
is *how today's work is sequenced*, `ARCHITECTURE.md` is *how the system is structured*. Never let
code or the todo list silently become the only place product behavior is defined.

## Step 0 — Bootstrap if needed (one time per project)

Before anything else, check whether these seven files exist at the root (or the chosen subfolder).
If they're absent, the project isn't initialized — scaffold it:

1. **Detect the stack yourself** by inspecting the repo. Look at `package.json` (scripts +
   dependencies → languages, frameworks, build/test/lint commands, package manager via lockfile),
   `tsconfig.json`, `pyproject.toml`/`requirements.txt`/`setup.py` (Python + pytest/ruff/framework),
   `*.sln`/`*.csproj` (.NET → `dotnet build`/`dotnet test`), `go.mod` (Go), `Cargo.toml` (Rust), and
   the top-level directory layout (`src/`, `client/`, `server/`, `app/`, `tests/`, etc.).
2. **Create each of the seven files** from the templates in the "Templates" section below, filling
   in: today's date, the detected languages/frameworks/directories into `ARCHITECTURE.md`, and the
   detected build/test/lint commands into `REGRESSION_CHECKLIST.md`.
3. **Never overwrite a file that already exists** — only create the missing ones. This makes
   bootstrap safe to run anytime to fill gaps.
4. Treat detection as a strong guess, not gospel: skim what you inferred, correct anything wrong,
   then tell the user the system is initialized and ask for the first requirement/task if
   `REQUIREMENTS.md`/`Todo.md` are still empty. **Conventions are per project** — follow what
   `ARCHITECTURE.md` records; don't hardcode a stack.

## The automatic session lifecycle

Once bootstrapped, every session runs these four phases in order, continuously, without prompting
between them.

### 1. PICKUP — read state before writing code

Read in this order, only as far as the task requires:

1. `HANDOFF.md` — always.
2. `Todo.md` — always.
3. `ARCHITECTURE.md` — if the task touches structure, data flow, routes, or subsystem boundaries.
4. `DECISIONS.md` — if the task touches a previously debated area.
5. `REQUIREMENTS.md` — if the task affects core behavior or a user workflow.

**Mandatory verification gate:** if `HANDOFF.md` has a `Verify Before Continuing` section, those
checks are the top priority. Do not start new work until they pass. If prior work is broken, fix it
first, update the handoff, *then* continue. This is what stops new features from being stacked on a
silently broken foundation.

### 2. WORK — implement one bounded task

Take the task from `## Next Task` in `HANDOFF.md`, or the next unchecked item in `Todo.md`. Then:

- Work sequentially within the current section; one logical feature or fix per step.
- Reuse existing patterns before inventing new ones — consistency beats cleverness here.
- Don't wander into unrelated cleanup unless it blocks the task.
- If the task forces an architectural change, change it *intentionally*: update `ARCHITECTURE.md`
  and log it in `DECISIONS.md`. If implementation reveals a requirement is wrong, fix
  `REQUIREMENTS.md` — don't let the code quietly become the source of product truth.

### 3. VERIFY — prove it actually works

A task is never "done because the code looks done." It's done when the behavior works to the defined
standard. Run three layers, scaled to what the change could affect (never skip the build):

- **Local:** the thing you changed works — page renders, route returns expected response, function
  behaves on normal and edge inputs, any spawned process completes. Prefer actually exercising it
  over reasoning that it should work.
- **Regression:** prior work still works — run `REGRESSION_CHECKLIST.md`, at minimum the build/test
  commands it records plus the rows your change touches. This layer is the whole reason the system
  exists; long projects die from undetected regressions, not the feature you're writing now.
- **Structural:** the code still matches `ARCHITECTURE.md` — logic in the right layer, files in the
  right place per the placement rules, state handled per convention, no new hidden coupling.

Then check the task against its block in `ACCEPTANCE_CRITERIA.md`. If criteria changed during
implementation, edit them there deliberately rather than silently moving the goalposts.

### 4. HANDOFF — write state before stopping

At any natural stopping point (a task done, a section boundary, or context starting to compress),
write state so the next session resumes in under two minutes:

1. Update `Todo.md` — check off only what is fully working and verified; leave partial work
   unchecked with its state described in the handoff.
2. Rewrite (don't append to) `HANDOFF.md` using its template.
3. Log meaningful design changes in `DECISIONS.md`; update `ARCHITECTURE.md` if a stable rule
   changed.
4. Make the next verification state explicit in the `Verify Before Continuing` section.

## Completion standard

Mark a task complete only when: implementation is finished, behavior works as intended, acceptance
criteria are satisfied, no obvious regressions were introduced, conventions were followed, and the
build passes (unless the task explicitly can't be build-verified yet).

## Governance — when to touch the long-horizon files

Keep these files trustworthy by changing them only on purpose.

**Architecture.** Don't silently invent a new pattern when an existing one works, move logic across
layers without reason, or create hidden coupling. Update `ARCHITECTURE.md` only when a core data flow
changes, a subsystem is added, routing or state-management strategy changes, backend responsibilities
shift materially, or a prior rule is intentionally replaced — and pair every such change with a
`DECISIONS.md` entry. The architecture says *what*; the decision log says *why*.

**Decisions.** Don't log trivia. Log when a meaningful tradeoff was made, a pattern was rejected, a
constraint forced something unusual, or future sessions would otherwise repeat a debate. Each entry
answers four things: what was chosen, why, what was rejected, what it now costs.

**Requirements.** `REQUIREMENTS.md` is product truth; `Todo.md` is sequencing — they must not merge.
If feature work changes what the product does, reflect it in `REQUIREMENTS.md`. If a requirement is
wrong, fix it there; implementation must never become the hidden sole source of product truth.

**Acceptance criteria.** Good criteria are observable, behavioral, testable, and specific. Prefer
outcome-based phrasing ("X appears; doing Y produces Z; failure shows W; existing feature still
works; build passes") over effort-based phrasing ("implement X"). Tie each task's criteria to the
requirement(s) it serves.

Followed consistently, this reduces context loss across sessions, feature-stacking on broken
foundations, architectural drift, checkbox inflation without working behavior, undocumented
decisions, hallucinated continuity, hidden regressions, and general entropy. It does not replace
human judgment, architectural thinking, product prioritization, or security awareness — surface
those to the user rather than deciding them silently.

---

# Templates

When bootstrapping, create each file below. Replace `{{...}}` placeholders (date, detected stack,
build/test commands). Leave the guidance prompts in place until real content replaces them.

## HANDOFF.md

```markdown
# Handoff State

> Short-term memory. Rewritten at the end of every session so the next one resumes in under two
> minutes. If you read nothing else, read this.

## Last Session Summary
- _(Initialized by Project Operating System on {{DATE}}.)_
- _(Replace with what was accomplished, plus any important fix or decision.)_

## Verify Before Continuing
- [ ] _(What the next session must confirm still works, and exactly how. Leave empty only if nothing is at risk.)_

## Next Task
_(The exact next `Todo.md` item to work on. Specific enough that no guessing is required.)_

## Context Notes
- _(Gotchas, the pattern to follow, key file/function references the next session will need.)_
```

## Todo.md

```markdown
# Todo

> Ordered implementation queue. This is *how work is sequenced*, not *what the product must do*
> (that's `REQUIREMENTS.md`). Work top to bottom within a section. Check off only what is fully
> working and verified — an item with failing tests or partial behavior stays unchecked.

## In Progress
- [ ] _(The one task currently being worked. Keep this to a single bounded item.)_

## Next Up
- [ ] _(Next bounded task.)_

## Backlog
- [ ] _(Unsequenced future work. Promote into "Next Up" when it's time.)_

## Done
- [x] Project Operating System initialized ({{DATE}})
```

## ARCHITECTURE.md

```markdown
# Architecture

> Long-term system memory. The stable structural rules and conventions of this project. Changes
> *rarely* and only *intentionally* — when it changes, log why in `DECISIONS.md`.

{{LOCATION_NOTE — e.g. "Control files live at the project root."}}

## System Overview
_(One or two paragraphs: what this system is, its major subsystems, and how data flows through it.)_

## Conventions (auto-detected on {{DATE}} — verify and edit)
Inferred from the repo; treat as defaults and correct anything wrong. New code follows them unless a
documented decision changes them.

**Languages:** {{LANGUAGES}}
**Frameworks / libraries:** {{FRAMEWORKS}}
**Notable directories:** {{NOTABLE_DIRS}}
**Package manager:** {{PACKAGE_MANAGER}}

### Placement rules
_(Where new things go — e.g. "New routes -> src/routes/, new shared components -> ...". Fill in from
the directories above so future sessions don't scatter files.)_

### Data flow & state
_(How server/client state is managed, how persistence works, how layers talk to each other.)_

## System Boundaries
_(What must NOT couple to what. The seams that keep the system maintainable.)_

## Architectural Rules
_(Standing rules, e.g. "business logic stays out of the view layer". Update only on intentional
change, paired with a DECISIONS.md entry.)_
```

## DECISIONS.md

```markdown
# Decisions

> Long-term memory of *why*. Log when a meaningful tradeoff was made, a pattern was rejected, a
> constraint forced an unusual implementation, or future sessions would otherwise re-litigate a
> debate. Small, obvious choices don't need an entry.

---

## {{DATE}} — Adopted the Project Operating System
**Chosen:** Run this codebase through the Project Operating System (seven control files + automatic
PICKUP/WORK/VERIFY/HANDOFF lifecycle).
**Why:** Keep continuity in files rather than model memory; prevent drift, duplicated logic, and
silent regressions across many AI-assisted sessions.
**Alternatives rejected:** Ad-hoc prompting per session (no continuity); a single README (blurs
short- and long-term concerns).
**Tradeoffs:** A little bookkeeping per session in exchange for resumability and trust.

---

## <YYYY-MM-DD> — <decision title>
**Chosen:**
**Why:**
**Alternatives rejected:**
**Tradeoffs:**
```

## REQUIREMENTS.md

```markdown
# Requirements

> Product truth: *what the system must do for its users.* The source of behavior, not the code and
> not `Todo.md`. If implementation reveals a requirement is wrong, fix it here.

## Product Goal
_(One or two sentences: who this is for and the core value it delivers.)_

## Functional Requirements
_(User-facing behavior. Number them so tasks and acceptance criteria can reference them.)_
- **R1:**
- **R2:**

## Non-Functional Requirements
_(Performance, reliability, security, compatibility constraints.)_
- **N1:**

## Explicitly Out of Scope
_(What this system intentionally does NOT do.)_
-
```

## REGRESSION_CHECKLIST.md

```markdown
# Regression Checklist

> Medium-term build control. Run the relevant rows before marking any task complete, to catch the
> failure mode where new work quietly damages something that used to work. Run the rows your change
> could affect, plus the build.

## Build / Compile
- [ ] Build passes: `{{BUILD_CMD}}`
- [ ] Tests pass: `{{TEST_CMD}}`
- [ ] Lint clean (if applicable): `{{LINT_CMD}}`
- [ ] No new syntax or import errors

## Frontend (if applicable)
- [ ] The changed page/view renders
- [ ] Navigation still works
- [ ] No obvious layout breakage
- [ ] No new console errors

## Backend / Services (if applicable)
- [ ] The changed route/handler responds correctly
- [ ] Error handling still functions
- [ ] No new runtime failures in logs

## Data / Persistence (if applicable)
- [ ] New fields handled properly
- [ ] Prior data shape still works
- [ ] Storage changes documented in `ARCHITECTURE.md`

## Prior Feature Verification
- [ ] A previously completed, related feature still works
- [ ] No silent behavior changes introduced elsewhere

## Handoff Readiness
- [ ] `Todo.md` updated truthfully (only working items checked)
- [ ] `HANDOFF.md` rewritten clearly
- [ ] Partial work documented
```

## ACCEPTANCE_CRITERIA.md

```markdown
# Acceptance Criteria

> Medium-term build control. Defines what "done" means *per task*, in observable behavioral terms,
> so completion is outcome-based. A task is done when the listed behavior actually works, not when
> the code looks done. If criteria change mid-implementation, update them here.

A good criterion is observable, behavioral, testable, and specific.
- **Weak:** "Add export button."
- **Strong:** "Export button appears on the report page; clicking it calls the export route;
  success downloads the correct file; failure shows a visible error; existing report features still
  work; build passes."

---

## <Task name> (refs: R# from REQUIREMENTS.md)
- [ ] _(observable behavior 1)_
- [ ] _(observable behavior 2)_
- [ ] No regression in _(related existing feature)_
- [ ] Build passes
```
