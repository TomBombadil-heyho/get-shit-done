# GSD Meta-Patterns

**Extracted from:** get-shit-done v1.20.5
**Purpose:** Document the recurring structural patterns that make GSD work — patterns about patterns, the engineering principles beneath the surface — and explore how they could inform a native Claude Code skill.

---

## Part 1: The 15 Meta-Patterns

These patterns don't exist as named concepts anywhere in the GSD codebase. They are the *implicit* architectural decisions that recur across every agent, workflow, and template. Extracting them reveals a coherent system design philosophy that transcends any single feature.

---

### 1. Thin Orchestrator / Fat Agent

**Where it appears:** `execute-phase.md`, `plan-phase.md`, `new-project.md`, `audit-milestone.md`

**The pattern:** Orchestrators coordinate but never do heavy work. They discover state, route to agents, collect results, and present to the user. Each agent gets a fresh 200k context window and does the real work.

**Why it matters:** This is the fundamental answer to context rot. The orchestrator stays at ~10-15% context usage. Agents get peak-quality execution in fresh windows. The system scales to arbitrary complexity without quality degradation because no single context window accumulates garbage.

**The rule:** If an orchestrator is doing implementation, something is wrong. Orchestrators spawn, wait, parse, route.

```
Orchestrator (lean):     Agent 1 (fresh 200k):     Agent 2 (fresh 200k):
  discover plans    →      execute plan 01      |     execute plan 02
  group into waves  →      commit per task      |     commit per task
  spawn agents      →      create SUMMARY       |     create SUMMARY
  collect results   ←      return structured     |     return structured
  present to user
```

---

### 2. Goal-Backward Verification

**Where it appears:** `gsd-verifier.md`, `gsd-planner.md` (must_haves), `gsd-plan-checker.md`, roadmap success criteria

**The pattern:** Never verify by checking "did tasks complete?" Instead, start from the desired outcome and work backwards:

1. **What must be TRUE?** (observable behaviors from user's perspective)
2. **What must EXIST?** (specific files, functions, models)
3. **What must be WIRED?** (connections between artifacts)
4. **What are KEY LINKS?** (critical connections where breakage causes cascading failure)

**Why it matters:** Task completion and goal achievement are fundamentally different. A task "create chat component" can be marked done when the component is a placeholder `<div>`. The task was completed — a file exists — but the goal "working chat interface" was not achieved.

**The insight:** 80% of stubs hide at the wiring level. Components exist. APIs exist. But Component doesn't call API. API doesn't query database. State isn't rendered. Goal-backward catches what task-forward misses.

```
Forward (common):                    Backward (GSD):
  Task 1: Create model    ✓           Goal: "User can chat"
  Task 2: Create API      ✓             Truth: "Can see messages"
  Task 3: Create UI       ✓               Artifact: Chat.tsx (EXISTS? SUBSTANTIVE?)
  All tasks done! Ship it!                   Wiring: fetch → /api/chat (CONNECTED?)
  ...but chat doesn't work                     Key link: API → prisma.message (REAL QUERY?)
```

---

### 3. Plans Are Prompts

**Where it appears:** `gsd-planner.md`, `phase-prompt.md` template, every PLAN.md file

**The pattern:** PLAN.md files are not documentation that gets *transformed into* prompts. They ARE the prompts. XML-structured tasks with precise fields (`<files>`, `<action>`, `<verify>`, `<done>`) that executor agents consume directly.

**Why it matters:** This eliminates the translation layer. There's no lossy conversion from "planning document" to "execution instruction." The planner writes exactly what the executor reads. The format IS the interface contract.

**The test:** "Could a different Claude instance execute this without asking clarifying questions?" If yes, the plan is specific enough. If no, add specificity.

```xml
<!-- This is both the plan AND the execution prompt -->
<task type="auto">
  <name>Create login endpoint</name>
  <files>src/app/api/auth/login/route.ts</files>
  <action>
    Use jose for JWT (not jsonwebtoken - CommonJS issues with Edge runtime).
    Validate credentials against users table.
    Return httpOnly cookie on success.
  </action>
  <verify>curl -X POST localhost:3000/api/auth/login returns 200 + Set-Cookie</verify>
  <done>Valid credentials return cookie, invalid return 401</done>
</task>
```

---

### 4. Context Engineering as Architecture

**Where it appears:** Every sizing decision, the quality degradation curve, plan splitting rules, summary templates

**The pattern:** The entire system is designed around a single constraint: LLM quality degrades as context fills. Every architectural decision flows from this:

| Context Usage | Quality | GSD Response |
|---------------|---------|--------------|
| 0-30% | PEAK | Target zone for orchestrators |
| 30-50% | GOOD | Target zone for plan execution |
| 50-70% | DEGRADING | Plans must complete before here |
| 70%+ | POOR | System failure — context rot |

**Design consequences:**
- Plans are 2-3 tasks max (stay under 50%)
- Each agent gets fresh 200k context
- Orchestrators stay at 10-15%
- SUMMARYs compress execution history into frontmatter
- STATE.md is kept under 150 lines
- History digests replace full SUMMARY reads

**The insight:** Context window management isn't a feature — it's THE architecture. Every file size limit, every agent boundary, every compression decision exists because of the degradation curve.

---

### 5. Deviation Rules as Autonomous Decision Framework

**Where it appears:** `gsd-executor.md`, `execute-plan.md`

**The pattern:** Instead of a binary "ask the user about everything" or "do whatever you want," GSD defines a four-tier autonomy framework:

| Rule | Trigger | Action | Permission |
|------|---------|--------|------------|
| 1: Bug | Broken behavior, errors | Fix inline | Auto |
| 2: Missing Critical | No validation, no auth, no error handling | Add it | Auto |
| 3: Blocking | Can't continue without fix | Unblock | Auto |
| 4: Architectural | New DB table, switching libraries | STOP and ask | Requires user |

**Priority:** Rule 4 > Rules 1-3 > Unsure → Rule 4

**Why it matters:** This solves the fundamental tension in AI-assisted development: too much autonomy produces surprises, too little produces friction. The deviation rules draw the line at "structural changes that affect the system's shape" — everything else is auto-handled.

**The heuristic:** "Does this affect correctness, security, or ability to complete the task?" YES → auto-fix. "Does this change the system's architecture?" → ask.

---

### 6. Wave-Based Parallel Execution

**Where it appears:** `execute-phase.md`, `gsd-planner.md` (dependency graph), plan frontmatter (`wave`, `depends_on`)

**The pattern:** Work is organized into dependency waves. Independent work runs in parallel within a wave. Waves execute sequentially. File ownership prevents conflicts.

```
Wave 1 (parallel):    Wave 2 (parallel):    Wave 3 (sequential):
  Plan 01 (User)        Plan 03 (Orders)      Plan 05 (Checkout)
  Plan 02 (Product)     Plan 04 (Cart)
```

**Key design choice:** Vertical slices over horizontal layers. "User feature end-to-end" parallelizes. "All models, then all APIs, then all UI" serializes.

**Why it matters:** This is how GSD achieves "walk away, come back to completed work." Multiple agents execute simultaneously, each with fresh context, each committing atomically. The orchestrator only needs to know the dependency graph.

---

### 7. File-Based State Machine

**Where it appears:** STATE.md, ROADMAP.md, SUMMARY.md, config.json, VERIFICATION.md, UAT.md, debug sessions

**The pattern:** All state lives in files, not in context. The system is designed around the assumption that context WILL be lost (user runs `/clear`, starts new session, context compresses). Everything important is written to disk immediately.

**State files and their roles:**

| File | Survives | Purpose |
|------|----------|---------|
| STATE.md | Context loss, session boundaries | Current position, decisions, blockers |
| ROADMAP.md | Entire project lifecycle | Phase progress, completion status |
| SUMMARY.md | Individual plan execution | What was built, key decisions, commit hashes |
| config.json | Everything | User preferences, model profiles, workflow toggles |
| VERIFICATION.md | Gap closure cycles | What passed, what failed, structured gaps |

**Why it matters:** This makes the system resumable at every level. `/gsd:resume-work` reads STATE.md. `/gsd:execute-phase` reads SUMMARY files to skip completed plans. Verifier reads previous VERIFICATION.md for re-verification mode.

---

### 8. Structured Returns as Inter-Agent Protocol

**Where it appears:** Every agent's `<structured_returns>` section, checkpoint_return_format, completion_format

**The pattern:** Every agent returns a structured markdown document with a predefined format. The orchestrator parses these to determine next steps. This is effectively an inter-agent communication protocol using markdown as the wire format.

**Examples:**
- `## RESEARCH COMPLETE` with confidence levels → orchestrator routes to planning
- `## CHECKPOINT REACHED` with completed tasks table → orchestrator presents to user, spawns continuation
- `## PLAN COMPLETE` with commit hashes → orchestrator advances to next wave
- `## VERIFICATION Complete` with status → orchestrator routes to gap closure or completion

**Why it matters:** Structured returns make the system predictable. The orchestrator doesn't need to "understand" what an agent did — it parses a known format and routes accordingly. This enables the thin orchestrator pattern.

---

### 9. Trust Nothing, Verify Everything

**Where it appears:** `gsd-verifier.md`, self-check protocol, spot-check in execute-phase, three-level artifact verification

**The pattern:** The system builds in distrust at every level:

- **Verifier doesn't trust SUMMARY claims.** "SUMMARYs document what Claude SAID it did. You verify what ACTUALLY exists."
- **Self-check verifies commits exist.** After writing SUMMARY, executor checks files exist on disk and commits are in git log.
- **Orchestrator spot-checks agents.** After execution, verify first 2 files from SUMMARY exist, check git log for commits.
- **Three-level artifact verification:** EXISTS → SUBSTANTIVE → WIRED. Existence alone proves nothing.

**Why it matters:** LLMs can confidently claim things they didn't do. The verification pattern catches hallucinated completions, placeholder implementations, and broken wiring. Every layer double-checks the layer below it.

---

### 10. Decision Cascade with Fidelity Preservation

**Where it appears:** CONTEXT.md → RESEARCH.md → PLAN.md → execution, the `<context_fidelity>` section in gsd-planner

**The pattern:** User decisions flow through the entire system with explicit fidelity checks at each stage:

```
/gsd:discuss-phase → CONTEXT.md
  ├── ## Decisions (LOCKED — non-negotiable)
  ├── ## Claude's Discretion (free choice)
  └── ## Deferred Ideas (OUT OF SCOPE)
         ↓
Researcher reads CONTEXT.md
  → Researches LOCKED decisions deeply, ignores deferred
         ↓
Planner reads CONTEXT.md + RESEARCH.md
  → Self-check: every locked decision has a task
  → Self-check: no task implements a deferred idea
         ↓
Executor reads PLAN.md
  → "If plan references CONTEXT.md: Honor user's vision throughout"
```

**Why it matters:** Without explicit fidelity checks, user intent degrades through the pipeline. "User wants cards" becomes "researcher explored tables too" becomes "planner used tables because research mentioned them." The cascade prevents this drift.

---

### 11. Honest Uncertainty Propagation

**Where it appears:** `gsd-phase-researcher.md`, `gsd-project-researcher.md`, confidence levels throughout

**The pattern:** Research findings carry explicit confidence levels that propagate through the system:

| Level | Sources | Usage |
|-------|---------|-------|
| HIGH | Context7, official docs | State as fact |
| MEDIUM | Verified WebSearch | State with attribution |
| LOW | Unverified single source | Flag for validation |

**Key principles:**
- "I couldn't find X" is valuable signal, not failure
- "Sources contradict" surfaces real ambiguity
- "Training data as hypothesis" — Claude's knowledge is 6-18 months stale
- LOW confidence findings get validation gates before planning proceeds

**Why it matters:** Most AI systems hide uncertainty behind confident language. GSD makes uncertainty a first-class data type. When the planner sees LOW confidence, it adds validation checkpoints. When the verifier sees uncertain findings, it flags for human verification.

---

### 12. Automation-First Checkpoints

**Where it appears:** `references/checkpoints.md`, checkpoint types, authentication gates

**The pattern:** Checkpoints are NOT "please do this manual work." They are "I automated everything I could — here's what requires human judgment."

**The golden rule:** If Claude CAN do it via CLI/API, Claude MUST do it.

**Checkpoint distribution:**
- **human-verify (90%):** Claude automated everything, human confirms visual/functional correctness
- **decision (9%):** Human makes architectural choice
- **human-action (1%):** Truly unavoidable (email verification, 2FA)

**Authentication gates:** Dynamic checkpoints created when Claude encounters auth errors. Not pre-planned — Claude automates first, asks for credentials only when blocked.

**Why it matters:** This inverts the typical human-in-the-loop pattern. Instead of "human does work, AI assists," it's "AI does all automatable work, human verifies and decides." Users visit URLs and evaluate — they never run CLI commands.

---

### 13. Atomic Commits as Observability

**Where it appears:** task_commit_protocol, execute-plan, SUMMARY frontmatter

**The pattern:** Every task gets its own commit immediately after completion. Commit format: `{type}({phase}-{plan}): {description}`.

**Benefits:**
- `git bisect` finds exact failing task
- Each task independently revertable
- Clear history for Claude in future sessions
- SUMMARY.md records commit hashes for verification
- Self-check validates commits exist in git log

**Why it matters:** In an AI-automated workflow, commits are the primary observability mechanism. They're how you know what happened, when, and in what order. They're how you roll back surgically when something goes wrong. They're how future Claude sessions understand what was built.

---

### 14. Research → Plan → Execute → Verify Pipeline

**Where it appears:** The entire workflow: `new-project`, `plan-phase`, `execute-phase`, `verify-work`

**The pattern:** Every unit of work follows the same pipeline at every scale:

| Stage | Project Level | Phase Level | Plan Level |
|-------|--------------|-------------|------------|
| Research | 4 parallel researchers | Phase researcher | Mandatory discovery |
| Plan | Roadmapper | Planner + checker | Task breakdown |
| Execute | Phase-by-phase | Wave-based parallel | Task-by-task |
| Verify | Milestone audit | Verifier + UAT | Self-check |

**Why it matters:** This is a fractal pattern. The same understand → plan → do → check cycle repeats at every level of granularity. This makes the system predictable and learnable — once you understand the pattern at one level, you understand it at all levels.

---

### 15. Anti-Enterprise Philosophy

**Where it appears:** README, questioning guide, planner philosophy, every design decision

**The pattern:** Explicit rejection of enterprise theater:

- No team structures, RACI matrices, stakeholder management
- No sprint ceremonies, change management processes
- No human dev time estimates (hours, days, weeks)
- No documentation for documentation's sake
- NEVER ask about user's technical experience — Claude builds

**The workflow is:** Solo developer (visionary) + Claude (builder). That's it.

**Why it matters:** This isn't just aesthetic — it's architectural. Every pattern above is designed for ONE person making decisions and ONE AI doing implementation. The thin orchestrator doesn't need coordination meetings. The deviation rules don't need approval committees. The checkpoint protocol has one human, not a review board.

---

## Part 2: How These Patterns Could Create a Native Claude Code Skill

The meta-patterns above aren't GSD-specific — they're solutions to fundamental problems in AI-assisted software development. Here's how they could inform a native Claude Code skill.

### The Core Insight

GSD is essentially a **context engineering runtime** bolted onto Claude Code via slash commands, markdown files, and a CLI tool. A native skill could internalize these patterns, making them invisible infrastructure rather than explicit workflow.

### Skill Architecture

A native skill built on these patterns would have three layers:

```
┌─────────────────────────────────────────────────┐
│  Layer 3: Workflow Orchestration                 │
│  (R→P→E→V pipeline, wave execution, milestones) │
├─────────────────────────────────────────────────┤
│  Layer 2: Context Management                     │
│  (budgeting, splitting, state persistence,       │
│   structured returns, decision cascade)          │
├─────────────────────────────────────────────────┤
│  Layer 1: Execution Primitives                   │
│  (atomic commits, deviation rules, checkpoints,  │
│   goal-backward verification, self-check)        │
├─────────────────────────────────────────────────┤
│  Claude Code Runtime                             │
│  (Task tool, Bash, Read/Write/Edit, Git)         │
└─────────────────────────────────────────────────┘
```

### Pattern → Native Capability Mapping

#### 1. Thin Orchestrator / Fat Agent → **Native Context Splitting**

**Current GSD:** Manual agent spawning via Task tool with explicit prompts, file references, and structured return parsing.

**Native skill:** Claude Code could natively detect when a task will exceed the quality threshold (~50% context) and automatically split into subagent execution. The orchestrator pattern would be invisible — Claude just "knows" when to delegate.

```
# Instead of explicit orchestration:
/gsd:execute-phase 3

# The skill would detect complexity and auto-split:
"Build the auth system"
→ Claude detects: 3 independent features, each ~30% context
→ Automatically spawns parallel agents
→ Collects results, presents summary
→ User sees: "Auth system built. 3 commits. Verify at localhost:3000/login"
```

**Key API need:** A `context_budget` primitive that agents can query to know their remaining quality headroom.

#### 2. Goal-Backward Verification → **Built-in Verification Protocol**

**Current GSD:** Separate verifier agent with explicit must_haves in plan frontmatter, manual three-level checks.

**Native skill:** Every piece of work would carry implicit verification criteria. When Claude finishes a task, it automatically runs goal-backward verification before reporting completion.

```
# Instead of:
/gsd:verify-work 3

# The skill would auto-verify:
Claude: "Built the dashboard. Running verification..."
  ✓ 5/5 observable truths verified
  ✓ All artifacts exist and are substantive
  ✓ All key links wired
  ⚠ 2 items need human verification:
    1. Visit localhost:3000/dashboard — does the layout match your vision?
    2. Try the filter dropdown — does it feel responsive?
```

**Key API need:** A `verify_goal()` primitive that takes desired outcomes and checks codebase state.

#### 3. Plans Are Prompts → **Native Task Format**

**Current GSD:** XML-structured PLAN.md files that agents read and execute.

**Native skill:** Claude Code could have a native task format that combines planning and execution. Instead of writing PLAN.md files to disk, the skill would maintain an in-memory task graph with the same structure.

```xml
<!-- The skill would internally represent work as: -->
<task_graph>
  <task id="1" wave="1" type="auto">
    <goal>User can log in with email</goal>
    <artifacts>src/app/api/auth/login/route.ts</artifacts>
    <key_links>LoginForm → /api/auth/login → prisma.user</key_links>
    <verify>curl returns 200 + Set-Cookie</verify>
  </task>
  <task id="2" wave="1" type="auto" parallel_with="1">
    <goal>User can register</goal>
    ...
  </task>
</task_graph>
```

**Key API need:** A structured `work_plan` type that the runtime understands natively.

#### 4. Context Engineering → **Automatic Context Budgeting**

**Current GSD:** Manual rules ("2-3 tasks per plan," "stay under 50%," "150 line STATE.md limit").

**Native skill:** The runtime would automatically manage context budgets. When approaching quality degradation thresholds, it would auto-compress, auto-split, or auto-delegate.

```
# The skill would track:
Context budget: 47% used
Quality estimate: GOOD
Action: Continue in current context

# And automatically react:
Context budget: 63% used
Quality estimate: DEGRADING
Action: Spawn fresh agent for remaining work, pass structured state
```

**Key API need:** Real-time context usage metrics and quality estimation exposed to the skill.

#### 5. Deviation Rules → **Native Autonomy Framework**

**Current GSD:** Rules 1-4 documented in executor agent prompts.

**Native skill:** Claude Code could have built-in autonomy tiers that any skill can use. The framework would be configurable per-project.

```json
{
  "autonomy": {
    "auto_fix": ["bugs", "missing_validation", "blocking_issues"],
    "ask_user": ["architectural_changes", "new_dependencies", "schema_changes"],
    "never_touch": ["auth_approach", "deployment_config"]
  }
}
```

**Key API need:** A `decision_gate()` primitive that classifies changes by impact and routes to auto-fix or user confirmation.

#### 6. File-Based State → **Native Session Persistence**

**Current GSD:** STATE.md, SUMMARY.md, config.json written to disk manually.

**Native skill:** Session state would persist natively across `/clear`, session boundaries, and context compressions. The skill would maintain a project graph that survives everything.

```
# Instead of:
/gsd:pause-work → writes continue-here.md
/gsd:resume-work → reads continue-here.md

# The skill would natively:
"Where was I?"
→ Claude: "You're on Phase 3 (Dashboard), Plan 2 of 3 complete.
   Last commit: feat(03-02): add chart components.
   Next: Plan 03 — user settings page.
   Ready to continue?"
```

**Key API need:** A persistent `project_state` store that the skill reads/writes automatically.

#### 7. Structured Returns → **Native Agent Communication**

**Current GSD:** Markdown-formatted structured returns parsed by orchestrators.

**Native skill:** Agent-to-agent communication would use typed messages instead of markdown parsing.

```typescript
// Instead of parsing markdown:
// "## RESEARCH COMPLETE\n**Confidence:** HIGH"

// The skill would use typed returns:
interface ResearchResult {
  status: "complete" | "blocked";
  confidence: "HIGH" | "MEDIUM" | "LOW";
  findings: Finding[];
  open_questions: string[];
}
```

**Key API need:** Typed inter-agent message passing in the Claude Code runtime.

#### 8. Wave Execution → **Native Parallel Task Scheduling**

**Current GSD:** Manual wave grouping in plan frontmatter, orchestrator spawns agents per wave.

**Native skill:** The runtime would understand task dependencies and automatically parallelize.

```
# Instead of manual wave assignment:
wave: 1, depends_on: []
wave: 2, depends_on: [plan-01]

# The skill would:
"Build the e-commerce backend"
→ Analyzes: User, Product, Order features
→ Detects: User and Product independent, Order depends on both
→ Executes: User + Product in parallel, then Order
→ Reports: "3 features built. 6 commits. 12 minutes."
```

**Key API need:** A `task_scheduler` that takes a dependency graph and manages parallel execution.

### What a Native Skill Would Actually Look Like

Instead of 30+ slash commands, the user interaction collapses to:

```
User: "I want to build a real-time chat app with auth"

Claude: [Questions — dream extraction, not interrogation]
        "What makes this different from Slack/Discord?"
        "Who's chatting? Teams? Strangers? 1:1 or groups?"

User: [Answers]

Claude: [Research — automatic, invisible]
        "Researching real-time patterns... WebSocket vs SSE vs polling"

Claude: [Plan — presented for approval]
        "Here's the build plan:
         Wave 1: Auth system + Message model (parallel)
         Wave 2: Chat UI + Real-time layer (parallel)
         Wave 3: Polish + deploy

         Approve? Or adjust?"

User: "Go"

Claude: [Executes — wave by wave, atomic commits]
        Wave 1 complete: auth + models (4 commits)
        Wave 2 complete: chat UI + WebSocket (3 commits)

        Verification:
        ✓ Can register and log in
        ✓ Can send messages
        ✓ Messages appear in real-time
        ⚠ Visit localhost:3000 — does the chat feel responsive?

User: "Looks great but the message list scrolls weirdly"

Claude: [Gap closure — automatic]
        "Fixed scroll behavior. Commit: fix(02-01): smooth scroll on new messages.
         Try again?"
```

The 15 meta-patterns are all present — they're just invisible. Context is managed. Work is parallelized. Verification is goal-backward. Deviations are auto-fixed. State persists. The user just describes what they want and watches it get built.

### The Gap Between GSD and Native

| Capability | GSD Today | Native Skill |
|-----------|-----------|--------------|
| Context management | Manual rules, file size limits | Runtime-level budget tracking |
| Agent spawning | Explicit Task() calls with prompts | Automatic splitting when needed |
| State persistence | Markdown files on disk | Native session store |
| Verification | Separate verifier agent | Built-in post-execution check |
| Parallelization | Manual wave assignment | Automatic dependency analysis |
| Deviation handling | Rules in agent prompts | Configurable autonomy framework |
| User interaction | Slash commands + AskUserQuestion | Conversational with auto-checkpoints |
| Inter-agent comms | Markdown parsing | Typed message passing |

### What Would Need to Exist in Claude Code

For this native skill to work, the Claude Code runtime would need:

1. **Context budget API** — Real-time quality estimation, not just token count
2. **Persistent project state** — Survives `/clear`, sessions, context compression
3. **Typed agent communication** — Beyond markdown parsing
4. **Automatic task scheduling** — Dependency-aware parallel execution
5. **Built-in verification primitives** — Goal-backward checking as a first-class operation
6. **Configurable autonomy tiers** — Per-project decision routing
7. **Native plan format** — Work graphs the runtime understands
8. **Hooks for quality degradation** — Automatic intervention when context fills

### The Deeper Point

GSD proves that the raw capability of Claude Code is sufficient for reliable software development. The missing piece isn't model intelligence — it's **context engineering infrastructure**. Every meta-pattern above is a workaround for the same gap: the runtime doesn't manage context, so GSD does it manually with files, agents, and conventions.

A native skill would eliminate the workarounds by building the infrastructure into the runtime. The patterns wouldn't disappear — they'd become invisible. And that's exactly what good infrastructure does: it makes the patterns you need so natural that you stop noticing them.

---

*Extracted by analyzing the complete GSD codebase: 11 agents, 30+ workflows, 20+ templates, 12 reference docs, and the architectural decisions that connect them.*
