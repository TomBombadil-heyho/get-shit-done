# IME Report Project — CLAUDE.md Template

> Copy this file to your IME project root as `CLAUDE.md` and customise it.
> This file is loaded at every Claude Code session start and provides
> cross-cutting rules that all agents inherit via filesystem access.

---

## Project Structure

```
{PROJECT_ROOT}/
├── .claude/
│   ├── agents/           ← Copy agent .md files here from agents/ime/
│   ├── rules/            ← Copy rules .md files here from agents/ime/rules/
│   ├── settings.json     ← Merge hooks from hooks-template.json
│   └── skills/
│       ├── report-template/
│       │   └── sections/     ← Your S01-S27 section templates
│       └── voice-matching/   ← Voice sample cards per section type
├── REPORTS/
│   ├── exemplars/            ← 3-5 completed reports as reference
│   │   ├── case-a/
│   │   ├── case-b/
│   │   └── ...
│   ├── VOICE_SAMPLES/        ← Voice profile cards per section
│   └── {case-name}/          ← Active case directories
│       ├── source-files/     ← All provided documents
│       ├── drafts/           ← Generated drafts land here
│       └── referral-questions.md
├── TEMPLATES/                ← Alternative template location
└── CLAUDE.md                 ← This file
```

## Absolute Rules

These rules apply to ALL agents and ALL report sections without exception:

1. **Never fabricate clinical content.** Every clinical fact, finding, diagnosis, medication reference, and timeline must trace to a specific source document. If source material is insufficient, use a bracketed placeholder — never fill gaps with plausible-sounding content.

2. **Always cite sources.** Every factual statement in a report draft must include attribution to the source document by name, author, and date. Include page numbers where the exemplar convention includes them.

3. **The clinician decides.** Agents produce drafts. The examining psychiatrist reviews, modifies, and owns the final report. Flag areas requiring clinical judgment with `[CLINICIAN: ...]` brackets.

4. **Match the voice.** The clinician's established writing voice — as documented in VOICE_SAMPLES and exemplar reports — takes precedence over generic medical writing conventions. If a voice sample contradicts general style rules, follow the voice sample.

5. **DSM-5-TR terminology** is mandatory for all diagnostic references. Use the exact diagnostic names, specifiers, and severity levels from DSM-5-TR.

## Agent Team

| Agent | Role | Sections | Has Write Access |
|-------|------|----------|-----------------|
| `ime-section-generator` | General section drafting | S12, S24, others | Yes |
| `ime-file-review-writer` | File material review | S22 | Yes |
| `ime-opinion-writer` | Forensic opinion synthesis | S23 | Yes |
| `ime-section-validator` | Quality validation | All sections | **No** |

## Orchestration Patterns

### Single section generation + validation
```
Use the section-generator agent to draft S12 for the {case} case.
Then use the section-validator agent to validate it.
```

### Full report generation (parallel + sequential)
```
Run these in parallel:
- section-generator: draft S12 and S24 for {case}
- file-review-writer: draft S22 for {case}
- opinion-writer: draft S23 for {case}

After all drafts complete, validate each with section-validator.
```

### Revision after validation failure
```
The validator found these issues with S22: {paste findings}.
Use the file-review-writer agent to revise S22 addressing these specific issues.
Then re-validate with section-validator.
```

## Customisation Points

### Voice Samples
Place voice profile cards in `REPORTS/VOICE_SAMPLES/` with filenames matching section identifiers:
- `S12-voice.md` — History of Present Illness voice profile
- `S22-voice.md` — Review of File Material voice profile
- `S23-voice.md` — Summary and Opinion voice profile
- `S24-voice.md` — Mental Status Examination voice profile

Each card should describe: sentence patterns, preferred terminology, attribution verbs, hedging conventions, paragraph rhythm, and any section-specific stylistic features.

### Section Templates
Place section templates in `.claude/skills/report-template/sections/` with the section identifier as filename:
- `S12.md`, `S22.md`, `S23.md`, `S24.md`, etc.

Templates define required subsections, their order, and any standard language.

### Exemplar Reports
Place 3-5 completed, clinician-approved reports in `REPORTS/exemplars/`. Each should contain the section files that agents will study for voice and structure matching. More exemplars = better voice matching accuracy.
