# Anchor attestation — AGT-VRA-001 — paradigm rust

Answered after the R3.1 integral read of all 11 buyer-facing files, before R4 paradigm constraint.

## Q1. What does the buyer-contract promise as delivered?

The pack delivers a self-contained, execution-neutral agent-logic specification for a pre-operation restoration gate, sufficient to build without further agent-logic design decisions. Per README §"What the specification guarantees" it names 7 structural properties (`Verified_Rehydration_Agent_README.md`:69-77) elaborated in Specification §2 core invariants, and per Whitepaper §05 four structural properties (state verified before use, failures suppressed, freshness confirmed, safe mode on failure). Concretely the delivered agent-logic surface is: the controlled verdict vocabulary ALLOW / DENY / QUARANTINE / ESCALATE / READMISSION_PENDING (§6), the ordered verification sequence of 12 steps (§7), the failure semantics table (§8), the validator catalogue with severities (§10), the decision table (§11), the workflow state model S0–S8 and its transition surface (§12), the gate logic (§13), the minimum evidence bundle contract (§14), and the machine-readable forms (§15). A conformant implementation derived from this surface answers every runnable conformance record from any paradigm.

## Q2. What does the buyer-contract explicitly delegate to deployment?

Per README §"What your team must produce" (`Verified_Rehydration_Agent_README.md`:83-93) and Specification §16 deployment obligations, five companion artifacts are built by the buyer's engineering team and are NOT in the pack, so I do not implement them: (1) a stable snapshot facility (snapshot lock or deterministic equivalent with binding evidence); (2) an anti-rollback mechanism (non-regressing counter or equivalent anchor); (3) a local, versioned policy bundle binding `policy_id`, `V_POLICY`, and `V_COMPAT`; (4) a single-writer persistence control plane emitting writer-lock and contention evidence; (5) a readmission authority workflow (`approver_set`, recovery workflow, readmission-token evidence, release procedure).

## Q3. How does the conformance test suite partition?

The suite has 29 records (`Verified_Rehydration_Agent_Conformance_Tests.md`:14-44, Minimal Run Note §4). Partition: 26 runnable (PT-001..PT-023, PT-025, PT-026, PT-027), 1 parameterized (PT-024, authority-release branch under an operator-declared envelope), and 2 declarative bounded-external checks (PT-028 for V_COMPAT, PT-029 for V_WRITER_LOCK). README §"How to verify" states the same 26 / 1 / 2 split.

## Q4. Where is the boundary between spec-derivable and deployment-substrate PTs?

The Minimal Run Note fixes the boundary: "Bounded external obligations not locally runnable" names V_COMPAT (bounded in import_admissibility / policy-compatibility enforcement) and V_WRITER_LOCK (bounded in the persistence control plane / deployment conformance layer). PT-028 and PT-029 are attested by architecture evidence rather than by the local transition surface, so they are the two legitimate SKIPs, each binding a deployment-substrate subsystem from Q2. The runnable workflow records (PT-001..PT-015, PT-024, PT-027) exercise the agent-logic transition surface `next_state(current_state, trigger, validator_passed)` and are fully spec-derivable. The evidence records (PT-016..PT-021, PT-025, PT-026) assert field PRESENCE and producer tags of representative bundles; the field STRUCTURE is spec-derivable and locally runnable, while the concrete field VALUES (digests, ids) originate in deployment substrate. Only PT-028 and PT-029 are non-locally-runnable by design.
