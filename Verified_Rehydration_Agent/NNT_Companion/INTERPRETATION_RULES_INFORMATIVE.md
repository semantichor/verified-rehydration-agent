# Interpretation Rules — Informative (NNT)

> **Read this first.** These rules govern how observations in this NNT companion may and may not be read. They are not commentary; they are binding on any consumer of the artifacts in this companion. If an observation appears to permit a conclusion these rules disallow, the rules control.

---

## 1. The fundamental distinction

This companion contains **observations**. It does not contain **findings**, **judgments**, **conclusions**, **certifications**, **diagnoses**, or **defects**.

An **observation** is a statement of the form:
> "Under the specified NNT protocol, with declared contamination axes, on this version of the agent pack, at this timestamp, the harness recorded [X]."

A **judgment** is a statement of the form:
> "The agent pack [is/is not] [good/sufficient/complete/correct]."

The companion produces the first kind. The reader must not produce the second kind from the first.

---

## 2. Required phrasing patterns

Every observation in the per-paradigm reports and the aggregate report is written in one of the following frames. When you re-state an observation outside the companion (e.g., in your own notes, in internal review, in any communication), you must preserve the frame.

### Frame A — Per-paradigm observation
> "In this NNT test run, the {LANG} paradigm-restricted reconstruction {VERB-PHRASE}."

Examples:
- "In this NNT test run, the Rust paradigm-restricted reconstruction produced a baseline that passed all of the agent's listed runnable Conformance Tests records."
- "In this NNT test run, the Prolog paradigm-restricted reconstruction raised 3 clarifying questions, of which 2 resolved in the Ambiguity Register and 1 did not."

### Frame B — Cross-paradigm observation
> "In this NNT test run, {N} of 5 paradigm-restricted reconstructions {VERB-PHRASE-CONSISTENT}, while {M} {VERB-PHRASE-DIVERGENT}."

Examples:
- "In this NNT test run, 5 of 5 paradigm-restricted reconstructions produced semantically equivalent state transitions on the workflow surface."
- "In this NNT test run, 3 of 5 paradigm-restricted reconstructions implemented the report-finalization gate as a single check, while 2 implemented it as a chain of two checks."

### Frame C — Auto-disclosure observation
> "In this NNT test run, the harness observed that {COUNT/CATEGORY} clarifying questions raised by paradigm-restricted reconstructions {STATUS-AGAINST-D4}."

Examples:
- "In this NNT test run, the harness observed that 12 of 14 distinct clarifying questions raised across the 5 reconstructions resolved within the Ambiguity Register, and 2 did not."
- "In this NNT test run, the harness observed that the Semantic Index covered all terms used in the reconstructions' clarifying questions."

### Frame D — Coverage trace observation
> "In this NNT test run, the harness traced {SOURCE-ITEM} to {TARGET-ITEM} via {INTERMEDIATE-ITEMS}; this trace was {COMPLETE/PARTIAL/BROKEN}."

Examples:
- "In this NNT test run, the harness traced Whitepaper guarantee G.02 to a README guarantee item to a Spec clause to the corresponding Conformance Tests record; this trace was complete."
- "In this NNT test run, the harness traced Whitepaper guarantee G.04 to README guarantee item 5; the harness did not identify a corresponding spec clause."

---

## 3. Forbidden vocabulary

The following words and phrases must not appear in any companion artifact, nor in any restated form of a companion observation. They import normative claims the companion is not entitled to make.

| Forbidden | Why |
|---|---|
| "defect" | Implies a fault diagnosed in the spec. The companion observes, does not diagnose. |
| "gap" (in spec or in tests) | Same as defect. |
| "weakness" | Same. |
| "validates" / "validated" / "validation" | Reserved for processes the companion is explicitly not. |
| "certifies" / "certification" | Same. |
| "verifies" (the spec) | Same. The companion verifies build/run mechanics of its own reconstruction outputs, not the spec. |
| "proves" / "demonstrates" (a property of the spec) | Companion observations do not entail spec properties. |
| "epistemic redundancy" | Hyperbolic framing imported from earlier methodology drafts. Forbidden. |
| "formal verification" | The companion does not perform formal verification. |
| "{N} paradigms" where N is not exactly 5 and where 5 is not literally meant | Avoids implying a broader test than was actually performed. |
| "industry standard" | Companion makes no comparative claims. |
| "best practice" | Same. |
| "recommended" / "should implement" | Companion does not direct implementation. |
| "we suggest" / "we recommend" | Same. |
| "kill rate" / "pass rate" (as quality metric) | These numbers exist in the run record but may not be used as quality measures. |
| "mutation score" / "kill score" / "mutation kill rate" | Forbidden in every form. The mutation matrix  records raw counts only; no aggregation into a score is permitted. |
| "survival rate" / "survived mutants" / "live mutants" (as quality framing) | Forbidden as quality framing. Counts of mutants whose PT status did not change vs the baseline exist in the matrix; they must not be re-described as "survival" or "evasion." |
| "detection rate" / "% detected" / "% killed" | Forbidden. No percentage of mutants outcomes may be computed. |
| "coverage" (as a numerical quality measure) | Permitted only in the technical sense of the coverage trace report, never as a score. |

**Note on automated checking.** The harness performs a substring self-check (an automated substring self-check) covering the vocabulary table above. Two items require contextual judgement and are NOT machine-enforced:
- "verifies" — the harness verifies *build/run mechanics of its own reconstruction outputs* (legitimate use), but the companion may not "verify the spec" (forbidden use). The substring is shared; the reader must judge context.
- "{N} paradigms" where N ≠ 5 — flagged by reader inspection; the substring check would either over-trigger or under-trigger.

Reports that pass the automated check are still bound by the rules above; the reader is the final authority.

---

## 4. Required attribution to the protocol

Every numerical observation must be qualified by the protocol that produced it. Bare numbers, even if technically accurate, are forbidden because they invite normative reading.

| Forbidden bare form | Required protocol-qualified form |
|---|---|
| "27 tests passed" | "In this NNT test run, the {LANG} reconstruction's baseline produced PASS status against 27 of the agent's 27 listed Conformance Tests records." |
| "5 paradigms converged" | "In this NNT test run, 5 of 5 paradigm-restricted reconstructions produced semantically equivalent outputs on {SPECIFIC-SURFACE}." |
| "2 ambiguities undisclosed" | "In this NNT test run, 2 of {TOTAL} clarifying questions raised by paradigm-restricted reconstructions did not resolve within the agent pack's Ambiguity Register." |
| "12 mutants killed" | "In this NNT test run, the {LANG} reconstruction's mutation pass recorded 12 mutants in category {CATEGORY} whose PT status on PT-{N} differed from the unmutated baseline's status on the same PT." |
| "spec is robust to mutation" | Forbidden under any framing. The mutation matrix carries no implication about specification robustness. |

---

## 5. Conclusions that are not permitted from any observation

The following conclusions, no matter how strongly the observations might appear to suggest them, are **not permitted** to be drawn within this companion or by any reader of it as a reading of this companion:

- **About the agent specification:**
  - That the specification is correct, incorrect, complete, incomplete, sufficient, insufficient, ambiguous, unambiguous, well-formed, or ill-formed.
  - That any clause should or should not be modified.
  - That the specification author should or should not have done anything differently.

- **About the agent's Conformance Tests:**
  - That the test suite is adequate, inadequate, exhaustive, incomplete, well-designed, or poorly designed.
  - That additional tests should or should not be written.
  - That existing tests should or should not be modified.

- **About implementations derived from the specification:**
  - That any particular implementation choice is correct, incorrect, recommended, or discouraged.
  - That a buyer should or should not implement the agent in any particular paradigm.
  - That the baseline implementations included (if present) are usable, partially usable, or unusable as references.

- **About paradigms in general:**
  - That any paradigm is superior, inferior, more suitable, or less suitable for any class of agent.
  - That paradigm choice has any normative bearing on agent quality.

- **About the SEMANTICHOR library:**
  - That the library is mature, immature, production-ready, or not production-ready.
  - That the library's methodology is sound, unsound, complete, or incomplete.

---

## 6. Conclusions that are permitted

The following conclusions are permitted, with the indicated frame and bounds:

- **About the NNT run itself**:
  > "This NNT run, under the methodology declared in the NNT methodology and the contamination axes there listed, produced the observations recorded in the per-paradigm and aggregate reports."

  This is permitted because it states what the run did, not what the run means.

- **About the reproducibility of the run**:
  > "Re-running NNT against this same version of the agent pack, under the same methodology, would produce comparably-structured observations, modulo the residual contamination axes (model-level bias, prompt-author bias)."

  This is permitted because it bounds reproducibility appropriately.

- **About what the companion does not address**:
  > "This companion does not address {CATEGORY}. {CATEGORY} is outside the scope of NNT."

  This is permitted and encouraged where it clarifies scope.

---

## 7. When in doubt

If a statement under consideration cannot be confidently framed in one of Frames A–D, with no forbidden vocabulary, with full protocol attribution, and within the permitted-conclusions set in §6, **the statement may not appear**. Removing the statement is always the correct resolution to interpretive doubt.

The agent specification is the authoritative source. This companion is not.

---

*These rules are part of the SEMANTICHOR NNT package and travel with every NNT companion regardless of agent.*
