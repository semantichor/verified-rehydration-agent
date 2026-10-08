# Inconsistencies log — AGT-VRA-001 — paradigm: prolog

Only differences that persist after reading all cited cross-references are listed. Differences that
reconcile under complete reading are treated as normal cross-document derivation and are not listed
here (for example, the Whitepaper §05 four-guarantee summary at
`Verified_Rehydration_Agent_Whitepaper.html:1128` versus the seven core invariants at
`Verified_Rehydration_Agent_Specification.md:47`: the Whitepaper is declared non-normative positioning
at `Verified_Rehydration_Agent_README.md:54`, and the two sit at different granularity, so they
reconcile).

## Observation 1 — `authority_release` (TR-008) destination: `S0` in the Semantic Index vs `{S0, S1}` in the Specification and Conformance Tests

- **Discrepancy**: The Semantic Index (D1) describes the `authority_release` trigger as moving the
  workflow to a single destination `S0 STARTUP_READONLY`, whereas the Specification §12 transition model
  and the Conformance Tests give the destination as the two-element set `{S0 STARTUP_READONLY,
  S1 SNAPSHOT_LOCKED}`.
- **Locations**:
  - Semantic Index D1: `Verified_Rehydration_Agent_Semantic_Index.md:2259` (TR-008 `definition_short`,
    "from S8 READMISSION_PENDING to S0 STARTUP_READONLY") and `:2261` (`definition_operational`, same
    single destination). The 1:1 D2 forms carry the same text
    (`Verified_Rehydration_Agent_Semantic_Index.yaml`, `Verified_Rehydration_Agent_Semantic_Index.json`).
  - Specification §12 transition model: `Verified_Rehydration_Agent_Specification.md:236`
    (`S8 | authority_release | Readmission approved | S0 or S1 | Remain blocked`).
  - Conformance Tests: `Verified_Rehydration_Agent_Conformance_Tests.md:378` (PT-024 expected "either
    S0 STARTUP_READONLY or S1 SNAPSHOT_LOCKED") and `:502` (OR-20 "Result ∈ {S0 STARTUP_READONLY,
    S1 SNAPSHOT_LOCKED}").
- **Cross-references read while reconciling**: The README states that the Semantic Index is a derived
  view of the specification's own vocabulary and that where a derived view diverges the specification
  controls (`Verified_Rehydration_Agent_README.md:56`). Reading §12 and OR-20 together fixes the
  destination as the set `{S0, S1}`, and the parameterized record PT-024 is satisfied by any member of
  that set. Reconciliation by precedence points the implementation to `{S0, S1}` (which the baseline
  uses), but the difference in the destination text between the D1/D2 Semantic Index (`S0` only) and
  §12 / OR-20 (`{S0, S1}`) itself persists in the documents as they stand on disk.
- This entry states only what was observed; it does not characterize the difference further. The
  baseline follows the Specification and Conformance Tests destination set `{S0, S1}` (see PT-024,
  `pt_results.json`).
