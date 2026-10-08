# R1.5 Comprehension quote-back — AGT-VRA-001 — paradigm: prolog

Eighteen verbatim quote blocks proving the R1 integral read of all 11 buyer-facing files,
plus four structural cross-checks (S1–S4) and three application probes (AP1–AP3).

## Per-file load-bearing quotes (11)

- FILE: Verified_Rehydration_Agent_README.md
  LOC: §How to verify your implementation conforms
  QUOTE: "A fully conformant implementation passes the 26 runnable tests, satisfies the 1 parameterized test under your declared parameter envelopes, and attests the 2 declarative checks at your release-acceptance gate."

- FILE: Verified_Rehydration_Agent_Whitepaper.html
  LOC: §04 What we built (lede)
  QUOTE: "The Verified Rehydration Agent is a specification for a pre-operation verification gate that stands between saved state and active operation."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §6 Verdict Semantics
  QUOTE: "A conformant implementation must not downgrade DENY, QUARANTINE, or ESCALATE into non-blocking warnings and must not extend ALLOW beyond the declared eligible context."

- FILE: Verified_Rehydration_Agent_Semantic_Index.md
  LOC: Method framing
  QUOTE: "preferred labels are limited to terms textually attested in the public specification."

- FILE: Verified_Rehydration_Agent_Semantic_Index.yaml
  LOC: metadata.excluded_sources_statement
  QUOTE: "Only the authorized public corpus is used for source_refs and textual attestation."

- FILE: Verified_Rehydration_Agent_Semantic_Index.json
  LOC: entries[0] ID-001 definition_operational
  QUOTE: "Names the agent whose role is to allow restoration only after complete verification and otherwise block, suppress, or isolate persistent context."

- FILE: Verified_Rehydration_Agent_Coverage_Matrix.md
  LOC: D3 header line
  QUOTE: "Coverage matrix for all indexed entries against category, semantic status, and public source sections."

- FILE: Verified_Rehydration_Agent_Ambiguity_Register.md
  LOC: AR-001 decision_rule cell
  QUOTE: "Use Head for the candidate boundary, Accepted head for IRR-visible eligibility, and verified head for post-verification replay and release."

- FILE: Verified_Rehydration_Agent_License.md
  LOC: Zone A §What this package is
  QUOTE: "The engineering team does not need to make design decisions about what the agent should do, how its logic should work, what it should record, or how it should fail."

- FILE: Verified_Rehydration_Agent_Conformance_Tests.md
  LOC: §4 Minimal Run Note (Suite PASS condition)
  QUOTE: "every runnable test passes, the parameterized authority-release branch lands only in the permitted state set, and both declarative bounded external-enforcement checks are satisfied by implementation evidence."

- FILE: Verified_Rehydration_Agent_Manifest.sha256
  LOC: Specification artifact hash line
  QUOTE: "558fd8a2c235774ca304a258d3ccea46e79734f39eff29194b400448dc755017 Verified_Rehydration_Agent_Specification.md"

## Structural cross-checks (S1–S4)

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: S1 — §7 catch-all / any-state rollback default statement
  QUOTE: "Rollback detection has blocking priority over every other restoration rule."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: S2 — §7 failure-ordering rule
  QUOTE: "No later step may execute if a prior critical step has failed."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: S3 — §14 Evidence Contract mandatory-field requirement (every decision, all outcomes)
  QUOTE: "Every relevant decision produces a minimum evidence bundle that is independently verifiable."

- FILE: Verified_Rehydration_Agent_README.md
  LOC: S4 — §How to read the package when a question arises (specification rules first)
  QUOTE: "If the specification, decision table, gate logic, evidence contract, or validator catalogue resolves the case"

## Application probes (AP1–AP3)

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: AP1 — Core safety model (governs a non-enumerated state/trigger via default blocking)
  QUOTE: "On any blocking failure, the agent denies restoration, suppresses persistent-state injection, or quarantines the relevant artefacts until the required closure conditions are met."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: AP2 — §14 Evidence Contract (fixes negative-outcome bundle mandatory fields)
  QUOTE: "failed\_validator (if any), failure\_code, suppression\_status, tool\_activation\_status, recovery\_phase, and readmission\_token\_id (if any)."

- FILE: Verified_Rehydration_Agent_README.md
  LOC: AP3 — README header (decides which prevails when two documents disagree)
  QUOTE: "Where this README and the specification appear to differ, the specification controls."
