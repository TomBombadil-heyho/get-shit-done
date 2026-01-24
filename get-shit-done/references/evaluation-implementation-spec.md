# Evaluation Primer: Implementation Spec

<purpose>
Comparative analysis of implementing project evaluation as skill, command, agent,
and hybrid orchestration patterns. Focus on non-obvious automation opportunities
and creative information processing approaches.
</purpose>

---

## The Core Challenge

The evaluation primer requires:
1. **Retrospective analysis** - examining completed artifacts
2. **Pattern extraction** - identifying recurring structures
3. **Synthesis** - producing actionable automation specs
4. **Accumulation** - building on prior evaluations

Each implementation approach handles these differently.

---

## Implementation 1: As a Skill (CLAUDE.md injection)

### Structure

```markdown
# In CLAUDE.md or project instructions

## Project Evaluation Skill

When the user asks to evaluate a completed project or phase:

1. Inventory artifacts using this mental model:
   - Planned artifacts (from ROADMAP.md phases)
   - Actual artifacts (glob .planning/**/*)
   - Delta = automation candidates

2. For each artifact type, extract:
   - Creation context (what triggered it)
   - Consumption context (what read it)
   - Transformation (how it evolved)

3. Output structured evaluation in conversational response
```

### Non-Obvious Advantages

**Implicit invocation**: No explicit command needed. User says "let's review what we built" and skill activates. This catches organic evaluation moments that explicit commands miss.

**Context accumulation**: Skill lives in main context. Across a session, it can notice patterns: "This is the third time you created an ad-hoc error handler. Candidate for template extraction."

**Conversational refinement**: User can steer evaluation mid-stream. "Focus more on the API patterns" → skill adapts without re-running.

### Creative Pattern: Ambient Evaluation

```markdown
## Ambient Evaluation Skill

After completing any /gsd:* command, silently note:
- Files created vs files in plan
- Time between plan creation and execution
- Checkpoint types encountered

Accumulate in mental model. When user asks "how's the project going?"
or "what should we improve?", synthesize accumulated observations.

This creates passive instrumentation without explicit evaluation runs.
```

### Limitation Workaround

Skills can't spawn subagents directly. But they can **recommend** subagent use:

```markdown
When evaluation requires deep artifact analysis:
"I should spawn an Explore agent to catalog all artifacts systematically.
Let me do that now."

Then use Task tool with Explore subagent.
```

**The skill becomes an orchestration layer** that decides when to escalate to subagents.

---

## Implementation 2: As a Command

### Structure

```yaml
---
name: gsd:evaluate-project
description: Retrospective analysis of completed project/phase
allowed-tools: [Read, Glob, Grep, Bash, Write, Task]
---

<objective>
Extract automation opportunities from completed work artifacts.
</objective>

<execution_context>
@~/.claude/get-shit-done/references/project-evaluation-primer.md
@~/.claude/get-shit-done/templates/evaluation-output.md
</execution_context>

<process>
... structured steps ...
</process>
```

### Non-Obvious Advantages

**Explicit tool access**: Commands declare allowed-tools. This enables:
- `Task` for subagent spawning (skills can't declare this)
- `Write` for creating evaluation output artifacts
- `Bash` for git log analysis, file stats

**Structured output guarantee**: Commands can enforce output format via template reference. Evaluation always produces machine-readable `EVALUATION.md`.

**Composability**: Commands can invoke other commands conceptually (via workflow references).

### Creative Pattern: Self-Modifying Evaluation

```yaml
<process>
<step name="evaluate_phase">
  Run 5-phase evaluation per primer
  Output: EVALUATION.md with automation recommendations
</step>

<step name="generate_automation">
  For each HIGH IMPACT recommendation:
    IF recommendation is "create template":
      Generate template file in get-shit-done/templates/
    IF recommendation is "add command":
      Generate command skeleton in commands/gsd/
    IF recommendation is "add agent":
      Generate agent definition in agents/

  Output: List of generated files
</step>

<step name="self_improve">
  Read this command file
  Check if any recommendations apply to THIS command
  If so, propose Edit to improve this evaluation command
</step>
</process>
```

**The command improves itself** based on evaluation findings. Each run can add new evaluation dimensions discovered in prior projects.

### Creative Pattern: Differential Evaluation

```yaml
<step name="differential_analysis">
  IF prior EVALUATION.md exists:
    Compare current evaluation to prior
    Focus on: What's NEW that wasn't in prior evaluation?

    Output delta:
    - New friction points discovered
    - Friction points that were automated away
    - Automation effectiveness score

  This prevents re-discovering known issues and tracks improvement.
</step>
```

---

## Implementation 3: As a Sub-Agent

### Structure

```markdown
---
name: gsd-evaluator
description: Deep retrospective analysis specialist
tools: Read, Glob, Grep, Bash
model: sonnet (analysis-heavy, not generation-heavy)
---

<role>
You are a project evaluation specialist. You analyze completed work
to extract patterns, identify automation opportunities, and produce
structured recommendations.
</role>

<philosophy>
- Every manual step is a potential automation
- Every repeated pattern is a template candidate
- Every context switch is a subagent boundary
- Every decision delay is a pre-computation opportunity
</philosophy>

<execution_flow>
... analysis steps ...
</execution_flow>

<output_format>
Return structured YAML evaluation that orchestrator can parse and act upon.
</output_format>
```

### Non-Obvious Advantages

**Fresh 200k context**: Agent gets full context window for deep analysis. Can load ALL artifacts without degradation concerns.

**Specialized model routing**: Evaluation is analysis-heavy, not generation-heavy. Route to Sonnet (or even Haiku for pattern matching). Save Opus for synthesis.

**Parallel spawning**: Multiple evaluator agents can analyze different phases simultaneously.

### Creative Pattern: Evaluator Swarm

```
Orchestrator spawns 4 evaluators in parallel:

gsd-evaluator (artifact-focus)
├── Analyzes: File creation patterns, naming, structure
├── Model: haiku (fast pattern matching)
└── Returns: ARTIFACT-PATTERNS.yaml

gsd-evaluator (decision-focus)
├── Analyzes: STATE.md, CONTEXT.md for decision patterns
├── Model: sonnet (reasoning about decisions)
└── Returns: DECISION-PATTERNS.yaml

gsd-evaluator (flow-focus)
├── Analyzes: Git history, timestamps, execution order
├── Model: haiku (timeline analysis)
└── Returns: FLOW-PATTERNS.yaml

gsd-evaluator (context-focus)
├── Analyzes: @ references, file dependencies
├── Model: sonnet (dependency reasoning)
└── Returns: CONTEXT-PATTERNS.yaml

Orchestrator receives all 4, synthesizes into EVALUATION.md
```

**Why this works**: Each evaluator is specialized. Haiku handles mechanical analysis (file patterns, timelines). Sonnet handles reasoning (decisions, dependencies). Parallel execution = 4x faster than sequential with same quality.

### Creative Pattern: Recursive Evaluation

```
gsd-evaluator analyzes project → produces EVALUATION.md

THEN

gsd-evaluator analyzes EVALUATION.md → produces META-EVALUATION.md
├── What patterns appear across multiple evaluations?
├── What recommendations keep recurring?
├── What's the ROI on prior automations?

This creates evaluation-of-evaluations for long-running projects.
```

---

## Implementation 4: Parallel Sub-Agents from Command

### Orchestration Structure

```yaml
---
name: gsd:evaluate-parallel
allowed-tools: [Read, Glob, Bash, Task, Write]
---

<process>
<step name="discover_scope">
  phases=$(ls .planning/phases/)
  phase_count=$(echo "$phases" | wc -l)
</step>

<step name="spawn_evaluators">
  IF phase_count <= 3:
    Single evaluator for all phases
  ELIF phase_count <= 6:
    Two evaluators (split phases)
  ELSE:
    One evaluator per 3 phases (parallel)

  # Spawn all in single Task block:
  Task(prompt="Evaluate phases 01-03...", subagent="gsd-evaluator")
  Task(prompt="Evaluate phases 04-06...", subagent="gsd-evaluator")
  Task(prompt="Evaluate phases 07-09...", subagent="gsd-evaluator")
</step>

<step name="synthesize">
  Read all PHASE-EVALUATION.yaml returns
  Merge patterns, deduplicate recommendations
  Rank by frequency × impact
  Output: EVALUATION.md
</step>
</process>
```

### Non-Obvious Pattern: Wave-Grouped Evaluation

Instead of per-phase evaluation, evaluate by execution wave:

```
Wave 1 artifacts (foundation):
├── Models, schemas, configs
├── Evaluate for: Naming consistency, structure patterns
└── Spawns: gsd-evaluator (structure-focus)

Wave 2 artifacts (features):
├── API endpoints, UI components
├── Evaluate for: Implementation patterns, reuse opportunities
└── Spawns: gsd-evaluator (implementation-focus)

Wave 3 artifacts (integration):
├── Tests, docs, verification
├── Evaluate for: Coverage patterns, verification gaps
└── Spawns: gsd-evaluator (verification-focus)

Benefits:
- Evaluators see similar artifact types together
- Pattern extraction is cleaner (comparing apples to apples)
- Recommendations are wave-specific (foundation templates vs feature templates)
```

### Creative Pattern: Streaming Synthesis

```
Problem: Parallel agents complete at different times.
         Waiting for all wastes time.

Solution: Streaming synthesis

Agent 1 completes → Orchestrator starts partial synthesis
Agent 2 completes → Orchestrator integrates, refines synthesis
Agent 3 completes → Orchestrator finalizes

Implementation:
<step name="streaming_synthesis">
  partial_eval = {}

  for each completed agent result:
    partial_eval = merge(partial_eval, agent_result)

    # Can start generating output before all complete:
    if confidence(partial_eval) > 0.7:
      Write preliminary EVALUATION.md
      Mark as "preliminary, N agents pending"

  Final write when all complete
</step>

Benefit: User sees preliminary results faster.
         Useful for large projects with many phases.
```

---

## Implementation 5: Sequential Sub-Agents from Command

### When Sequential Beats Parallel

```
Parallel: Good when phases are independent
Sequential: Good when evaluation builds on itself

Example: Dependency chain evaluation

Phase 01 evaluation discovers: "User model pattern"
Phase 02 evaluation needs to know: "Does Phase 02 follow the User model pattern?"
Phase 03 evaluation needs to know: "Pattern drift from Phase 01→02→03?"

Sequential enables:
Agent 1 (Phase 01) → returns patterns
Agent 2 (Phase 02) → receives Phase 01 patterns, extends/validates
Agent 3 (Phase 03) → receives accumulated patterns, measures drift
```

### Creative Pattern: Context Accumulation Chain

```yaml
<step name="chained_evaluation">
  accumulated_patterns = {}

  for phase in phases:
    # Each agent receives prior patterns
    result = Task(
      prompt="""
        Evaluate phase: {phase}

        Prior discovered patterns:
        {accumulated_patterns}

        Your task:
        1. Evaluate this phase
        2. Note which prior patterns this phase follows
        3. Note which prior patterns this phase violates
        4. Identify NEW patterns not in prior list

        Return: {
          follows: [...],
          violates: [...],
          new_patterns: [...]
        }
      """,
      subagent="gsd-evaluator"
    )

    # Accumulate for next agent
    accumulated_patterns.merge(result.new_patterns)
    pattern_adherence.track(result.follows, result.violates)
</step>
```

**Why this matters**: Sequential agents build shared understanding. The final agent has full pattern history. Can identify drift, inconsistency, evolution.

### Creative Pattern: Backpropagation Evaluation

```
Forward pass (sequential):
  Phase 01 → 02 → 03 → 04 → 05
  Each phase evaluated forward

Backward pass (sequential):
  Phase 05 → 04 → 03 → 02 → 01
  Each phase re-evaluated with knowledge of what came after

  Questions answered in backward pass:
  - Did Phase 01 decisions cause problems in Phase 05?
  - Which Phase 02 patterns were abandoned later?
  - What would we do differently in Phase 03 knowing Phase 04-05?

Implementation:
<step name="backprop_evaluation">
  # Forward pass
  forward_results = []
  for phase in phases:
    forward_results.append(evaluate_forward(phase))

  # Backward pass with hindsight
  backward_results = []
  hindsight = final_outcome
  for phase in reversed(phases):
    result = Task(
      prompt="""
        Re-evaluate phase: {phase}

        Forward evaluation: {forward_results[phase]}
        What happened after: {hindsight}

        With hindsight:
        - What decisions were good?
        - What decisions caused later problems?
        - What should be done differently?
      """,
      subagent="gsd-evaluator"
    )
    backward_results.append(result)
    hindsight = result.hindsight_insights
</step>
```

**This discovers causal chains** that forward-only evaluation misses.

---

## Implementation 6: Hybrid Orchestration

### The Full Pattern

```
┌─────────────────────────────────────────────────────────────────┐
│ SKILL (Ambient Layer)                                           │
│ - Passive observation during normal work                        │
│ - Accumulates micro-observations                                │
│ - Triggers explicit evaluation when patterns emerge             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ COMMAND (Orchestration Layer)                                   │
│ - Explicit /gsd:evaluate invocation                             │
│ - Decides parallel vs sequential based on project structure     │
│ - Manages agent lifecycle and result synthesis                  │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ AGENT (Parallel)│ │ AGENT (Parallel)│ │ AGENT (Parallel)│
│ Wave 1 analysis │ │ Wave 2 analysis │ │ Wave 3 analysis │
│ Structure focus │ │ Feature focus   │ │ Verify focus    │
└─────────────────┘ └─────────────────┘ └─────────────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ AGENT (Sequential - Synthesis)                                  │
│ - Receives all parallel results                                 │
│ - Performs cross-cutting analysis                               │
│ - Identifies patterns that span waves                           │
│ - Produces final EVALUATION.md                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ COMMAND (Self-Improvement Layer)                                │
│ - Reads EVALUATION.md recommendations                           │
│ - Generates templates, commands, agents as needed               │
│ - Updates own evaluation criteria for next run                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Creative Automation Patterns

### Pattern A: Evaluation-Driven Template Generation

```yaml
<automation name="template_extraction">
  trigger: Evaluation finds 3+ similar file structures

  action:
    1. Extract common structure
    2. Identify variable portions (mark with placeholders)
    3. Generate template file
    4. Add to templates/ directory
    5. Update evaluation criteria to check template usage

  example:
    Found: api/users.ts, api/products.ts, api/orders.ts
    Common: Express router, CRUD operations, validation
    Variable: Resource name, schema, specific validations

    Generated: templates/api-resource.md
    Placeholders: {resource}, {schema}, {validations}
</automation>
```

### Pattern B: Decision Pre-Computation

```yaml
<automation name="decision_library">
  trigger: Evaluation finds repeated decision patterns

  action:
    1. Extract decision type and common options
    2. Create decision template with pre-filled options
    3. Add to project-type decision library
    4. Future projects auto-suggest based on type

  example:
    Found: 5 projects chose "JWT vs Sessions"
    Common options: JWT (4), Sessions (1)
    Common rationale: "Stateless for scaling"

    Generated: decisions/auth-token-type.md
    Pre-filled: JWT recommended for API-first projects
</automation>
```

### Pattern C: Context Flow Optimization

```yaml
<automation name="context_preloading">
  trigger: Evaluation finds consistent file reference patterns

  action:
    1. Identify files always read together
    2. Create composite context file
    3. Update @ references to use composite
    4. Measure context size reduction

  example:
    Found: Every executor reads STATE.md + PROJECT.md + ROADMAP.md
    Total: 3 file reads, potential duplication

    Generated: PROJECT-CONTEXT.md (composite)
    Content: Synthesized view of all three
    Result: 1 read instead of 3, smaller context
</automation>
```

### Pattern D: Wave Boundary Learning

```yaml
<automation name="wave_optimization">
  trigger: Evaluation finds wave boundary violations

  action:
    1. Analyze actual execution order vs planned waves
    2. Identify dependencies that weren't captured
    3. Update planner heuristics for wave assignment
    4. Add file-ownership rules to prevent future violations

  example:
    Found: Wave 2 task modified Wave 1 file (conflict)
    Root cause: Shared utility not tracked in dependencies

    Generated: Rule in planner
    "If task touches utils/*.ts, bump to wave after all utils creators"
</automation>
```

### Pattern E: Checkpoint Elimination

```yaml
<automation name="checkpoint_automation">
  trigger: Evaluation finds checkpoint:human-verify that always passes

  action:
    1. Analyze what user verified
    2. Determine if verification is automatable
    3. Create automated verification step
    4. Convert checkpoint to automated assertion

  example:
    Found: "Verify API returns correct format" - passed 8/8 times
    Verification: User checked JSON structure

    Generated: Automated step
    "Run: curl endpoint | jq 'has(\"data\") and has(\"meta\")'"
    Checkpoint removed, assertion added to verify-phase
</automation>
```

---

## Information Processing Pipeline

### The Accumulation Architecture

```
┌──────────────────────────────────────────────────────────────┐
│ RAW LAYER (Git + Files)                                      │
│ - Commit history with timestamps                             │
│ - File creation/modification events                          │
│ - Checkpoint encounters                                       │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼ Extract
┌──────────────────────────────────────────────────────────────┐
│ PATTERN LAYER (Structured YAML)                              │
│ - Artifact patterns: {type, frequency, structure}            │
│ - Decision patterns: {type, options, chosen, rationale}      │
│ - Flow patterns: {sequence, timing, dependencies}            │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼ Synthesize
┌──────────────────────────────────────────────────────────────┐
│ INSIGHT LAYER (Recommendations)                              │
│ - Template candidates ranked by extraction value             │
│ - Automation candidates ranked by time saved                 │
│ - Process improvements ranked by friction reduced            │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼ Generate
┌──────────────────────────────────────────────────────────────┐
│ ARTIFACT LAYER (Executable Improvements)                     │
│ - New templates in templates/                                │
│ - New commands in commands/gsd/                              │
│ - New agents in agents/                                      │
│ - Updated workflows with optimizations                       │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼ Validate
┌──────────────────────────────────────────────────────────────┐
│ FEEDBACK LAYER (Next Project)                                │
│ - Compare next project metrics to baseline                   │
│ - Track which automations were used                          │
│ - Measure actual time savings                                │
│ - Feed back into pattern layer for refinement                │
└──────────────────────────────────────────────────────────────┘
```

### Frontmatter as Graph Database

```yaml
# Every generated artifact includes machine-readable metadata

# EVALUATION.md frontmatter
---
evaluated_project: my-app
evaluated_phases: [01, 02, 03, 04, 05]
patterns_found: 12
templates_generated: 3
commands_generated: 1
automation_coverage: 0.67  # 67% of recommendations implemented
prior_evaluation: 2025-01-10  # For differential analysis
---

# Generated template frontmatter
---
source_evaluation: 2025-01-24
source_artifacts: [api/users.ts, api/products.ts]
usage_count: 0  # Incremented when template used
effectiveness_score: null  # Calculated after first use
---

# This creates queryable evaluation history:
grep -l "automation_coverage" .planning/evaluations/*.md |
  xargs head -20 |
  # Parse YAML, track improvement over time
```

---

## Comparison Matrix

| Aspect | Skill | Command | Agent | Parallel Agents | Sequential Agents |
|--------|-------|---------|-------|-----------------|-------------------|
| **Invocation** | Implicit/ambient | Explicit `/gsd:` | Via Task() | Via multiple Task() | Via chained Task() |
| **Context** | Shares main context | Owns command context | Fresh 200k each | Fresh 200k × N | Fresh 200k × N |
| **State** | Accumulates in session | Writes to files | Returns structured | Returns N results | Returns accumulated |
| **Parallelism** | None | Orchestrates | Single | True parallel | Builds on prior |
| **Best for** | Passive observation | Explicit analysis | Deep single-focus | Independent phases | Dependent analysis |
| **Cost** | Minimal | Moderate | Per-agent | N × per-agent | N × per-agent |
| **Latency** | Zero (always on) | On-demand | Task overhead | Parallel = fast | Sequential = slower |

---

## Recommended Implementation

For the project evaluation primer specifically:

```
PHASE 1: Skill for passive observation
- Add ambient evaluation skill to CLAUDE.md
- Accumulates observations during normal work
- Low overhead, high signal

PHASE 2: Command for explicit evaluation
- Create /gsd:evaluate-project command
- Orchestrates parallel wave-grouped agents
- Produces structured EVALUATION.md

PHASE 3: Self-improving loop
- Evaluation generates automation artifacts
- Next project uses generated artifacts
- Next evaluation measures effectiveness
- Loop refines automation library

PHASE 4: Meta-evaluation
- After 5+ projects, run meta-evaluation
- Identify cross-project patterns
- Generate project-type-specific evaluation profiles
```

This creates a **learning system** that improves with each project evaluated.
