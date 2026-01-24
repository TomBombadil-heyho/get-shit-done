# Project Evaluation Primer

<purpose>
A meta-method for evaluating completed project workflows to extract automation opportunities using Claude Code features. Designed for retrospective analysis that produces actionable improvements for future similar projects.
</purpose>

---

## Core Philosophy

**Evaluation Goal**: Transform hindsight into foresight by analyzing what actually happened versus what was planned, identifying friction points that Claude Code can automate.

**Key Principle**: Every manual step in a completed project is a potential automation candidate. Every context switch is a subagent boundary. Every repeated pattern is a template waiting to be extracted.

---

## The Meta-Method: 5-Phase Evaluation

### Phase 1: Artifact Inventory

<objective>
Catalog all artifacts produced during the project to understand the actual workflow shape.
</objective>

<evaluation_checklist>
- [ ] List all `.planning/` files created (PROJECT.md, PLAN.md, STATE.md, etc.)
- [ ] Count git commits and categorize by type (feat, fix, refactor, docs)
- [ ] Identify which templates were used vs. created ad-hoc
- [ ] Note files that were created but never referenced again
- [ ] Catalog external resources fetched (APIs researched, docs read)
</evaluation_checklist>

<claude_code_automation>
Use the Task tool with Explore agent to automatically catalog:

```
/gsd:evaluate-artifacts
├── Spawn Explore agent to glob *.md in .planning/
├── Parse git log for commit patterns
├── Cross-reference PLAN.md tasks with actual commits
└── Output: ARTIFACT-INVENTORY.md
```

**Suggested command structure**:
```yaml
---
name: gsd:evaluate-artifacts
description: Catalog project artifacts for retrospective analysis
allowed-tools: [Read, Glob, Bash, Write, Task]
---
```
</claude_code_automation>

---

### Phase 2: Decision Point Analysis

<objective>
Identify where decisions were made, how long they took, and whether they could be pre-answered.
</objective>

<evaluation_questions>
1. **Gray Area Decisions**: What implementation choices required human input?
   - Layout/structure decisions
   - API format choices
   - Naming conventions
   - Technology selections

2. **Blockers**: Where did work stop waiting for information?
   - External API documentation
   - Credential setup
   - Environment configuration
   - Dependency conflicts

3. **Reversals**: What decisions were made then changed?
   - Scope changes
   - Architecture pivots
   - Library replacements
</evaluation_questions>

<pattern_extraction>
For each decision type, determine:

| Decision Type | Frequency | Resolution Method | Automation Potential |
|--------------|-----------|-------------------|---------------------|
| Tech stack selection | Once per project | Research + user preference | Template with pre-filled options |
| File structure | Once per phase | Convention-based | Infer from existing codebase |
| API format | Per endpoint | Context-dependent | Extract from similar projects |
| Error handling | Per module | Framework conventions | Lint rules + templates |
</pattern_extraction>

<claude_code_automation>
Use `checkpoint:decision` pattern analysis:

```
Scan STATE.md and *-CONTEXT.md files for:
├── Sections marked with decision outcomes
├── Questions posed to user
├── Time gaps between plan creation and execution
└── Output: DECISION-ANALYSIS.md with automation recommendations
```

**Future automation**: Create decision libraries per project type that pre-answer common choices.
</claude_code_automation>

---

### Phase 3: Context Flow Mapping

<objective>
Trace how context moved through the project to identify fragmentation and redundancy.
</objective>

<context_flow_patterns>

**Healthy Context Flow**:
```
PROJECT.md (stable core)
    ↓
ROADMAP.md (phase structure)
    ↓
{phase}-CONTEXT.md (implementation vision)
    ↓
{phase}-{N}-PLAN.md (executable tasks)
    ↓
Git commits (atomic implementation)
    ↓
STATE.md (accumulated knowledge)
```

**Context Rot Indicators**:
- Plans that reference outdated PROJECT.md sections
- SUMMARY.md files that duplicate PLAN.md content without new information
- STATE.md entries that were never read by subsequent phases
- Orphaned research files that informed no decisions
</context_flow_patterns>

<evaluation_metrics>
| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Plan → Commit alignment | >90% tasks have matching commits | 70-90% | <70% |
| Context file freshness | All files updated within milestone | Some stale | Major drift |
| Subagent utilization | Each phase uses 2-4 subagents | 1 or 5+ | 0 (monolithic) |
| STATE.md update frequency | After each plan completion | After each phase | Rarely |
</evaluation_metrics>

<claude_code_automation>
Create a context flow validator:

```yaml
---
name: gsd:validate-context-flow
description: Check context health and identify fragmentation
allowed-tools: [Read, Glob, Grep, Task]
---

<process>
1. Parse @-references in all workflow files
2. Build dependency graph of context files
3. Check for orphaned files (referenced 0 times)
4. Check for over-referenced files (>10 references)
5. Output: CONTEXT-FLOW.md with health score
</process>
```
</claude_code_automation>

---

### Phase 4: Dependency Wave Analysis

<objective>
Understand the actual execution order versus planned order to optimize future parallelization.
</objective>

<wave_extraction>
From completed project, extract:

**Wave 0** (No dependencies):
- Project scaffolding
- Configuration files
- Initial documentation

**Wave 1** (Foundation dependencies):
- Core data models
- Base components
- Utility functions

**Wave 2** (Integration dependencies):
- Feature implementations
- API endpoints
- UI components

**Wave 3** (Verification dependencies):
- Tests
- Documentation updates
- Integration verification
</wave_extraction>

<parallelization_opportunities>
Analyze git timestamps to find:

1. **Sequential work that could be parallel**:
   - Multiple independent features implemented one after another
   - Tests written after all features (could interleave)

2. **Parallel work that caused conflicts**:
   - Merge conflicts indicating dependency violations
   - Rework commits showing wave miscategorization

3. **Blocking bottlenecks**:
   - Long gaps between related commits
   - Checkpoint pauses that could be async
</parallelization_opportunities>

<claude_code_automation>
Wave dependency optimizer:

```
Task agent with analysis prompt:
├── Parse PLAN.md files for <dependencies> sections
├── Compare to actual git commit order
├── Identify wave violations (dependent work started before prerequisite)
├── Calculate theoretical speedup from optimal parallelization
└── Output: WAVE-ANALYSIS.md with optimized wave structure
```

**Automated wave detection** for future projects:
- Glob for file patterns → categorize by wave
- Parse imports → build dependency graph
- Suggest wave assignments in PLAN.md generation
</claude_code_automation>

---

### Phase 5: Automation Opportunity Synthesis

<objective>
Consolidate findings into actionable Claude Code automation specifications.
</objective>

<automation_categories>

#### A. Template Automation
Extract reusable templates from ad-hoc artifacts:

| Source | Template Candidate | Abstraction Level |
|--------|-------------------|-------------------|
| Repeated file structures | Directory scaffold template | Project type |
| Similar API endpoints | Endpoint template with placeholders | Domain |
| Common test patterns | Test template per framework | Technology |
| Error handling blocks | Error handling snippet | Language |

#### B. Workflow Automation
Convert manual sequences into orchestrated workflows:

```xml
<workflow_candidate>
  <trigger>Manual sequence detected in git history</trigger>
  <pattern>Create file → Edit config → Run command → Verify</pattern>
  <automation>
    Single command that:
    1. Uses Write tool for file creation
    2. Uses Edit tool for config modification
    3. Uses Bash tool for command execution
    4. Uses Task with verifier agent for verification
  </automation>
</workflow_candidate>
```

#### C. Agent Specialization
Identify tasks that benefit from dedicated subagents:

| Task Pattern | Agent Candidate | Key Capability |
|--------------|-----------------|----------------|
| Research before implementation | Phase researcher | WebSearch, WebFetch |
| Complex refactoring | Refactoring specialist | Multi-file Edit |
| Test generation | Test writer | Framework-aware generation |
| Documentation updates | Doc updater | Markdown, API doc patterns |

#### D. Checkpoint Optimization
Reduce human touchpoints:

```
For each checkpoint:human-verify in completed project:
├── Could verification be automated?
│   ├── Yes → Convert to automated assertion
│   └── No → Document why human required
├── Could action before checkpoint be automated?
│   ├── Yes → Add to automation scope
│   └── No → Document blocker
└── Output: Optimized checkpoint specification
```
</automation_categories>

---

## Claude Code Feature Mapping

<feature_matrix>

### Tool-Based Automations

| Friction Point | Claude Code Tool | Automation Pattern |
|----------------|------------------|-------------------|
| Manual file creation | Write | Template with variable substitution |
| Repetitive edits | Edit with replace_all | Batch transformation |
| Research gathering | WebSearch + WebFetch | Structured research workflow |
| Code exploration | Task with Explore agent | Codebase understanding |
| Multi-step verification | Task with verification agent | Automated checking |
| Parallel operations | Multiple Tool calls in single response | Wave execution |

### Agent-Based Automations

| Workflow Pattern | Agent Type | Configuration |
|------------------|------------|---------------|
| Deep research | gsd-phase-researcher | WebSearch, WebFetch, Read |
| Plan creation | gsd-planner | Read, Write, Task (Explore) |
| Execution | gsd-executor | Full tool access |
| Verification | gsd-verifier | Read, Grep, Glob, Bash |
| Debugging | gsd-debugger | Full tool access |

### Workflow Orchestration

| Multi-Phase Pattern | Orchestration Method |
|---------------------|---------------------|
| Sequential phases | STATE.md tracking + phase transitions |
| Parallel plan execution | Wave-based Task spawning |
| Conditional branching | Mode-based execution (yolo vs interactive) |
| Recovery from failure | Checkpoint system + debugger agent |

</feature_matrix>

---

## Evaluation Output Template

After completing the 5-phase evaluation, produce:

```markdown
# Project Retrospective: [Project Name]

## Artifact Summary
- Total files created: X
- Templates used: Y
- Ad-hoc artifacts: Z (candidates for templating)

## Decision Analysis
- Major decisions: X
- Blocked time: Y hours
- Reversals: Z (root causes identified)

## Context Health Score
- Flow integrity: X%
- Orphaned files: Y
- Context fragmentation incidents: Z

## Wave Optimization
- Actual waves: X
- Optimal waves: Y
- Potential speedup: Z%

## Automation Recommendations

### High Impact (Implement First)
1. [Specific automation with Claude Code implementation]
2. [...]

### Medium Impact
1. [...]

### Low Impact (Consider for v2)
1. [...]

## Template Extraction Candidates
1. [Template name]: [Source files] → [Abstraction]
2. [...]

## New Agent Candidates
1. [Agent name]: [Specialized capability]
2. [...]
```

---

## Meta-Method Application

<usage_pattern>
Apply this primer after completing any significant project:

1. **Immediate** (within 1 day of completion):
   - Run artifact inventory while context is fresh
   - Note decision points from memory

2. **Short-term** (within 1 week):
   - Complete full 5-phase evaluation
   - Draft automation recommendations

3. **Integration** (within 1 month):
   - Implement highest-impact automations
   - Add templates to project type library
   - Update agent configurations

4. **Continuous**:
   - Reference this primer at project start for similar projects
   - Compare new project friction to previous evaluations
   - Evolve automation library based on patterns
</usage_pattern>

<success_criteria>
Evaluation is successful when:
- [ ] Next similar project has fewer manual decision points
- [ ] Template usage increases, ad-hoc file creation decreases
- [ ] Wave execution is optimized from day 1
- [ ] Context flow remains healthy throughout project
- [ ] Human checkpoints are only for genuinely human-required verification
</success_criteria>

---

## Quick Reference: Automation Patterns

### Pattern 1: Research → Decision → Implementation
```
Before: Manual research, ask user, implement
After:  gsd-phase-researcher → structured options → user selects → gsd-executor
```

### Pattern 2: Create → Configure → Verify
```
Before: Write file, edit config, manually check
After:  Write + Edit in sequence → Task with verifier agent
```

### Pattern 3: Multi-file Transformation
```
Before: Manual edit of each file
After:  Glob → parallel Edit with replace_all → Grep to verify
```

### Pattern 4: Dependency-Aware Execution
```
Before: Serial execution of all tasks
After:  Wave analysis → parallel Task spawning per wave
```

### Pattern 5: Context Preservation
```
Before: Context degrades over long project
After:  STATE.md updates + fresh subagent contexts + atomic commits
```

---

<closing_principle>
The best project is one where you spend less time managing the project and more time building. Every evaluation should produce at least one automation that makes the next project faster.
</closing_principle>
