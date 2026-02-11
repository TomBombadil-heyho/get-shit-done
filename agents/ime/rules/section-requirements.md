---
description: Required elements for each IME report section. Generator agents check completeness; validator agents verify compliance.
globs: REPORTS/**/*.md
---

# Section Requirements

These are baseline structural requirements. The section templates in `.claude/skills/report-template/sections/` provide detailed subsection specifications. These rules establish the minimum that every section must contain.

## S12 — History of Present Illness

**Required elements:**
- Chief complaint or presenting problem
- History of the current episode/condition
- Relevant psychiatric history (prior diagnoses, treatments, hospitalisations)
- Relevant medical history bearing on psychiatric condition
- Medication history (current and relevant past medications with dosages)
- Substance use history
- Social and occupational history relevant to the presenting condition
- Review of relevant symptoms
- Source attribution for all historical facts

**Structure:** Typically chronological within each subsection, following template order.

## S22 — Review of File Material

**Required elements:**
- Complete document inventory (every provided document accounted for)
- Source attribution for every factual statement (document name, author, date)
- Chronological or provider-based organisation per template
- Verbatim preservation of clinical terminology from source documents
- Explicit flagging of contradictions between sources
- No clinical interpretation or opinion (factual summary only)

**Structure:** Per template — typically chronological or by provider. Consistent throughout.

**Completeness standard:** Every document in the source file inventory must appear in the review. Omission of a provided document is a deficiency.

## S23 — Summary and Opinion

**Required elements:**
- Response to each referral question
- For each opinion: evidence citation → clinical analysis → opinion statement
- Appropriate certainty qualifier for forensic opinions
- DSM-5-TR diagnostic formulation with criteria mapping
- Causation analysis using precise medicolegal language
- Discussion of symptom validity/malingering considerations (if in referral scope)
- Prognosis (if in referral scope)
- Treatment recommendations (if in referral scope)
- Clear separation of factual summary from clinical opinion
- Clinician review flags on all opinion statements

**Structure:** Per template — typically organised by referral question.

## S24 — Mental Status Examination

**Required elements:**
- Appearance and behaviour
- Psychomotor activity
- Speech (rate, rhythm, volume, tone)
- Mood (patient's self-report)
- Affect (clinician's observation — range, reactivity, congruence)
- Thought process (form of thought)
- Thought content (suicidal ideation, homicidal ideation, delusions, obsessions)
- Perceptual disturbances (hallucinations)
- Cognition (orientation, attention, memory, as assessed)
- Insight and judgment
- Source attribution (clinical interview, formal testing, behavioural observation)

**Structure:** Per template — typically follows a standard MSE format.

**Note:** S24 is based primarily on direct examination findings. The draft agent works from the clinician's examination notes and observation records, not from file material.

## Cross-Section Requirements

All sections must:
- [ ] Include all subsections specified in the section template
- [ ] Maintain voice consistency with exemplar sections
- [ ] Use DSM-5-TR terminology for diagnostic references
- [ ] Follow the project's citation format
- [ ] Flag missing information with bracketed placeholders
- [ ] Avoid fabrication of any clinical content
- [ ] Stay within ±20% of exemplar section length
