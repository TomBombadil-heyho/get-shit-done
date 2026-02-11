---
description: Checklist items the section-validator agent checks against. Defines PASS/FAIL criteria for each validation dimension.
globs: REPORTS/**/drafts/*.md
---

# Validation Criteria

The section-validator agent evaluates drafts against these criteria. Each dimension is scored independently. The overall verdict follows the grading rules in the validator agent specification.

## Dimension 1: Structural Compliance

**PASS requires ALL of:**
- Every required subsection from the section template is present
- Subsections appear in the order specified by the template
- No subsections added that the template does not specify
- Heading hierarchy matches template (H2, H3, etc.)
- Required standard/boilerplate language is present where template specifies it

**FAIL if ANY of:**
- A required subsection is missing entirely
- Subsection order deviates from template
- Template-specified standard language is altered or missing

## Dimension 2: Voice Match

**PASS requires ALL of:**
- Sentence structure patterns match exemplar sections (declarative vs. complex, length distribution)
- Attribution verbs match those found in exemplars (no substituted synonyms)
- Hedging level matches exemplar conventions
- Clinician's preferred terminology used (not generic synonyms)
- Register and formality match exemplar
- Paragraph length proportionate to exemplar paragraphs
- Transition patterns between subsections match exemplar style

**FAIL if ANY of:**
- Systematic use of attribution verbs not found in exemplars
- Hedging level consistently differs from exemplar (more or less hedged)
- Terminology substitutions that change the clinician's characteristic voice
- Register shift (too informal or too formal relative to exemplars)

**Evaluation method:** The validator must cite specific examples from the draft alongside counterexamples from exemplars to justify voice match findings.

## Dimension 3: Content Integrity

**PASS requires ALL of:**
- Every clinical fact has source attribution
- No clinical findings appear fabricated (not traceable to source material)
- Placeholder brackets present where source material was insufficient
- DSM-5-TR terminology correct for diagnostic references
- Medication names, dosages, timelines match source documents
- No internal contradictions between subsections
- Chronological sequences internally consistent

**FAIL if ANY of:**
- Any clinical fact lacks source attribution
- Any finding appears fabricated or not traceable to provided source material
- Diagnostic terminology incorrect or non-standard
- Factual errors in medication, dosage, or timeline information

**Fabrication is an automatic FAIL** regardless of all other dimensions. Any content that cannot be traced to provided source material must be flagged.

## Dimension 4: Length and Proportion

**PASS requires:**
- Overall section length within ±20% of exemplar average for that section type
- Subsection proportions roughly match exemplar patterns (no subsection dramatically over- or under-represented)

**PASS WITH NOTES if:**
- Length deviates 20-30% from exemplar average (may be justified by case complexity)
- Subsection proportions differ but each subsection has substantive content

**FAIL if:**
- Length deviates >30% from exemplar average without clear justification
- Any required subsection is trivially brief (placeholder-like)

## Dimension 5: Citation Format

**PASS requires:**
- Citation format matches exemplar convention exactly
- Source documents referenced by correct names/titles
- Page numbers included where exemplars include them
- Date format consistent and matches exemplar convention

**PASS WITH NOTES if:**
- Format is correct but a small number of citations (<5%) are incomplete

**FAIL if:**
- Systematic deviation from exemplar citation format
- Source documents referenced by incorrect names
- Dates formatted inconsistently

## Section-Specific Criteria

### S22 Additional Checks
- [ ] Every document in the source inventory appears in the review
- [ ] No clinical interpretation or opinion present (factual summary only)
- [ ] Contradictions between sources explicitly flagged

### S23 Additional Checks
- [ ] Every referral question receives a direct response
- [ ] Evidence-before-opinion ordering maintained for each question
- [ ] Certainty qualifiers present for forensic opinion statements
- [ ] Fact clearly distinguished from opinion throughout
- [ ] Clinician review flags present on all opinion statements and diagnostic formulations

### S24 Additional Checks
- [ ] All standard MSE domains covered
- [ ] Observations attributed to appropriate source (examination vs. records)
- [ ] Affect and mood clearly distinguished (patient report vs. clinician observation)

## Overall Verdict Rules

| Condition | Verdict |
|-----------|---------|
| All dimensions PASS | **PASS** |
| Dimensions 1-3 PASS, 4 or 5 has notes | **PASS WITH NOTES** |
| Any of dimensions 1, 2, or 3 FAIL | **FAIL** |
| Fabrication detected (any dimension) | **FAIL** |
| Only dimension 4 or 5 FAIL | **PASS WITH NOTES** (with strong revision recommendation) |
