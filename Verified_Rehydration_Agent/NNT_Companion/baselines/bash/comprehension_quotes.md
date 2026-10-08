# R1.5 Comprehension quote-back — AGT-VRA-001 (bash)

## The 11 pack files

- FILE: Verified_Rehydration_Agent_README.md
  LOC: Front matter (intro paragraph)
  QUOTE: "It defines the normative boundary and decision logic for controlled rehydration of persistent context, permitting restoration only after complete verification."

- FILE: Verified_Rehydration_Agent_Whitepaper.html
  LOC: §04 What we built / Principle P.01 Bounded authority
  QUOTE: "The agent verifies and gates. It does not repair, modify, or generate state"

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §6 Verdict Semantics
  QUOTE: "ALLOW means restoration may be executed only from the verified head and only for the context declared eligible."

- FILE: Verified_Rehydration_Agent_Semantic_Index.md
  LOC: §Identity Terms / ID-001 definition_operational
  QUOTE: "Names the agent whose role is to allow restoration only after complete verification and otherwise block, suppress, or isolate persistent context."

- FILE: Verified_Rehydration_Agent_Semantic_Index.yaml
  LOC: entries[0] ID-001 definition_short
  QUOTE: "Canonical name of the agent defined by the public specification."

- FILE: Verified_Rehydration_Agent_Semantic_Index.json
  LOC: entries[0] ID-001 definition_operational
  QUOTE: "Names the agent whose role is to allow restoration only after complete verification and otherwise block, suppress, or isolate persistent context."

- FILE: Verified_Rehydration_Agent_Coverage_Matrix.md
  LOC: D3 header line
  QUOTE: "Coverage matrix for all indexed entries against category, semantic status, and public source sections."

- FILE: Verified_Rehydration_Agent_Ambiguity_Register.md
  LOC: AR-001 decision_rule
  QUOTE: "Use Head for the candidate boundary, Accepted head for IRR-visible eligibility, and verified head for post-verification replay and release."

- FILE: Verified_Rehydration_Agent_Conformance_Tests.md
  LOC: §4 Minimal Run Note / Suite PASS condition
  QUOTE: "every runnable test passes, the parameterized authority-release branch lands only in the permitted state set, and both declarative bounded external-enforcement checks are satisfied by implementation evidence."

- FILE: Verified_Rehydration_Agent_License.md
  LOC: Subject
  QUOTE: "This package is distributed free of charge. No payment is required, now or ever, for anything this license permits."

- FILE: Verified_Rehydration_Agent_Manifest.sha256
  LOC: Specification.md digest line
  QUOTE: "558fd8a2c235774ca304a258d3ccea46e79734f39eff29194b400448dc755017  Verified_Rehydration_Agent_Specification.md"

## Four structural cross-checks

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: Core safety model (catch-all/default handling statement)
  QUOTE: "On any blocking failure, the agent denies restoration, suppresses persistent-state injection, or quarantines the relevant artefacts until the required closure conditions are met."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §7 Ordering and Verification Sequence (failure-ordering rule)
  QUOTE: "No later step may execute if a prior critical step has failed."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §14 Evidence Contract (mandatory-field requirement, all outcomes)
  QUOTE: "Every relevant decision produces a minimum evidence bundle that is independently verifiable."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §16 Precedence rules (precedence rule)
  QUOTE: "A failed critical validator prevails over operational utility considerations."

## Three application probes

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §16 Conformance requirements (non-enumerated state/trigger → fail-closed)
  QUOTE: "The agent must preserve fail-closed semantics for every failed critical validator."

- FILE: Verified_Rehydration_Agent_Specification.md
  LOC: §14 Evidence Contract (negative-outcome bundle mandatory fields)
  QUOTE: "The minimum bundle for the principal verdict contains validator\_bundle\_id, verified\_head\_digest, snapshot\_id, policy\_id, source\_id, freshness\_value, irr\_digest, failed\_validator (if any), failure\_code, suppression\_status, tool\_activation\_status, recovery\_phase, and readmission\_token\_id (if any)."

- FILE: Verified_Rehydration_Agent_README.md
  LOC: Front matter (document-precedence rule)
  QUOTE: "Where this README and the specification appear to differ, the specification controls."
