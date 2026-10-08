# Verified Rehydration Agent — Convergence Exhibit (Non Normative Tests)

> Buyer-facing synthesis of the cross-paradigm convergence evidence in this NNT companion.
> **Observational and demonstration-only; non-normative.** Read `INTERPRETATION_RULES_INFORMATIVE.md` first.
> Every figure below is bounded to this single NNT run on agent pack `AGT-VRA-001`
> (manifest_ref `4b3bf7d83c9aea06b0e6d894df556d9716c61ab3ff7f2ebc95991cc92e3ad072`).

## What this exhibit shows

Five paradigm-isolated reconstruction contexts of the same model independently built the
Verified Rehydration Agent **from the buyer-facing specification pack alone** — in Python, Rust, Prolog, C, and Bash —
and ran the agent's 29 Conformance Tests records against each reconstruction, under live
toolchains with hash-attested binary provenance. This exhibit summarizes where the reconstructions converged.
It is **evidence of derivability and self-sufficiency** of the specification, not a certification,
not a quality score, and not a set of implementations to follow.

## Convergence summary (this run)

- In this NNT test run, **29 of 29** Conformance Tests records had **convergent** outcomes
  across all five observed paradigms — convergent **PASS** (27 records): `PT-001`, `PT-002`, `PT-003`, `PT-004`, `PT-005`, `PT-006`, `PT-007`, `PT-008`, `PT-009`, `PT-010`, `PT-011`, `PT-012`, `PT-013`, `PT-014`, `PT-015`, `PT-016`, `PT-017`, `PT-018`, `PT-019`, `PT-020`, `PT-021`, `PT-022`, `PT-023`, `PT-024`, `PT-025`, `PT-026`, `PT-027`; convergent **SKIP** (2 records): `PT-028`, `PT-029`.
- In this NNT test run, **0 of 29** records had **divergent** outcomes across the five observed paradigms.

## Per-paradigm outcome (execution_mode = live)

| Paradigm | pass | fail | skip | error |
|---|---|---|---|---|
| python | 27 | 0 | 2 | 0 |
| rust   | 27 | 0 | 2 | 0 |
| prolog | 27 | 0 | 2 | 0 |
| c      | 27 | 0 | 2 | 0 |
| bash   | 27 | 0 | 2 | 0 |

All five reconstructions completed (none halted).

## Mutation sensitivity (observational — raw counts only)

Six shared semantic categories (`MS-01`..`MS-06`); each paradigm applied 8 deterministic mutation
operators to its baseline. The cross-paradigm matrix of `(category, PT) → per-paradigm status-change
counts` is in `mutation_observations.md`. **No kill rate, mutation score, survival rate, or detection
rate is computed or implied** (see `INTERPRETATION_RULES_INFORMATIVE.md` §3).

## Auto-disclosure (this run)

In this NNT test run, the reconstructions raised 33 clarifying questions; resolution partition:
`deployment_obligation`=5, `implementation_flexibility`=8, `resolved_in_ct`=4, `resolved_in_d4`=6, `resolved_in_spec`=10. Detail in `auto_disclosure_audit.md`.

## Coverage trace (this run)

29 PT records partitioned as 26 runnable / 1 parameterized / 2 declarative; bidirectional
keyword-overlap trace between buyer-facing guarantees and PT prose is in `coverage_trace.md`
(coarse-matcher counts, not normative coverage scores).

## Reproducibility

Sources, run scripts, binaries, and their hashes are included so the run can be re-verified two ways:
(a) `sha256sum -c` against the package Manifest on the delivered artifacts (all paradigms); and
(b) rebuild from source with the documented flags. See `baselines/{lang}/toolchain_selfcheck.txt`
for the per-paradigm rebuild story and the documented reproducibility mode (byte-exact where the
toolchain is deterministic; behavioral equivalence otherwise).

## How to read this exhibit

This exhibit is **evidence of derivability**, NOT an obligation, a recommendation, a certification,
or a measure of quality. The `baselines/` are study artifacts produced under restricted conditions;
they are **not reference implementations** and must not be used as implementation patterns.
Implementation is performed solely from the Zone A specification in the agent pack.
