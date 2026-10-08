# Comprehension Quote-Back — AGT-VRA-001 / paradigm c

Proof of R1 integral read. 18 blocks: 11 pack files + S1–S4 structural cross-checks + AP1–AP3 application probes. Quotes are verbatim (backslash-escaped underscores preserved exactly as the markdown source stores them).

## Pack files (11)

- FILE: Verified_Rehydration_Agent_License.md
  LOC: Zone A — What this package is
  QUOTE: "The Verified Rehydration Agent specification is a ready-to-build, execution-neutral normative document."

- FILE: Verified_Rehydration_Agent_README.md
  LOC: What this package is, and is not
  QUOTE: "self-contained, normative, execution-neutral single agent specification, delivered as-is, sufficient for an engineering team to build the agent without further design decisions about agent logic, evidence shape, validator behavior, or failure semantics"

- FILE: Verified_Rehydration_Agent_Whitepaper.html
  LOC: §04 What we built
  QUOTE: "The agent does not create state, modify state, or make domain decisions."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §6 Verdict Semantics
  QUOTE: "A conformant implementation must not downgrade DENY, QUARANTINE, or ESCALATE into non-blocking warnings and must not extend ALLOW beyond the declared eligible context."

- FILE: Verified_Rehydration_Agent_Semantic_Index.md
  LOC: DE-010 ALLOW definition_operational
  QUOTE: "Means restoration may be executed only from the verified head and only for the context declared eligible."

- FILE: Verified_Rehydration_Agent_Semantic_Index.yaml
  LOC: metadata.excluded_sources_statement
  QUOTE: "Only the authorized public corpus is used for source_refs and textual attestation."

- FILE: Verified_Rehydration_Agent_Semantic_Index.json
  LOC: entries[0] ID-001 definition_operational
  QUOTE: "Names the agent whose role is to allow restoration only after complete verification and otherwise block, suppress, or isolate persistent context."

- FILE: Verified_Rehydration_Agent_Coverage_Matrix.md
  LOC: Column schema header row
  QUOTE: "term\_id | preferred\_label | category | normative\_status | source\_refs | attested"

- FILE: Verified_Rehydration_Agent_Ambiguity_Register.md
  LOC: AR-001 decision_rule
  QUOTE: "Use Head for the candidate boundary, Accepted head for IRR-visible eligibility, and verified head for post-verification replay and release."

- FILE: Verified_Rehydration_Agent_Conformance_Tests.md
  LOC: §4 Minimal Run Note — Suite PASS condition
  QUOTE: "Suite PASS condition: every runnable test passes, the parameterized authority-release branch lands only in the permitted state set, and both declarative bounded external-enforcement checks are satisfied by implementation evidence."

- FILE: Verified_Rehydration_Agent_Manifest.sha256
  LOC: Specification hash line
  QUOTE: "558fd8a2c235774ca304a258d3ccea46e79734f39eff29194b400448dc755017  Verified_Rehydration_Agent_Specification.md"

## Structural cross-checks (S1–S4)

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §12 Transition model — Any-state catch-all row
  QUOTE: "Any state | rollback\_detected | V\_ANCHOR or V\_COUNTER\_CONT FAIL | S5 | QUARANTINE + ESCALATE"

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §7 Ordering and Verification Sequence — failure-ordering rule
  QUOTE: "No later step may execute if a prior critical step has failed."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §14 Evidence Contract — mandatory bundle for every decision
  QUOTE: "Every relevant decision produces a minimum evidence bundle that is independently verifiable."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §16 Precedence rules
  QUOTE: "A failed critical validator prevails over operational utility considerations."

## Application probes (AP1–AP3)

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §2 Core invariants
  QUOTE: "No restoration is permitted before the full verification sequence completes successfully."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §5 Output Contract — DENY row minimum content
  QUOTE: "Any critical validator FAILS | failure\_code, failed\_validator, suppression\_status"

- FILE: Verified_Rehydration_Agent_README.md
  LOC: Front matter — precedence between README and specification
  QUOTE: "Where this README and the specification appear to differ, the specification controls."
