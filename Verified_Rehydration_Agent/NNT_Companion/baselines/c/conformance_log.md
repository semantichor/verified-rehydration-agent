# Conformance Log — AGT-VRA-001 / paradigm c

In this NNT test run, the c paradigm-restricted reconstruction's baseline produced `PASS` status against 27 of the agent's 27 locally-runnable Conformance Tests records (26 runnable plus the 1 parameterized `PT-024`), and recorded `SKIP` for the 2 declarative records the Minimal Run Note designates as bounded external obligations. Final acceptance run totals: total=29, pass=27, fail=0, skip=2, error=0.

## Envelopes

- `PT-024` (parameterized, `A_TSET`) — declared bounded envelope: an approved `authority_release` from `S8 READMISSION_PENDING` returns to `S0 STARTUP_READONLY`. Value declared by the buyer: `S0`. Admissible target set bounding the declaration: `{S0 STARTUP_READONLY, S1 SNAPSHOT_LOCKED}` per the transition row `S8 | authority_release | Readmission approved | S0 or S1` (`Verified_Rehydration_Agent_Specification.md`:236) and the oracle `OR-20` result set (`Verified_Rehydration_Agent_Conformance_Tests.md`:502). The Semantic Index `TR-008` states the canonical target as `S0 STARTUP_READONLY` (`Verified_Rehydration_Agent_Semantic_Index.md`:2259), which is within the admissible set. Recorded observation: `result_state_id=S0`, a member of the permitted set.

## Attestations

- `PT-028` (declarative, `V_COMPAT`) — recorded `SKIP`; buyer obligation: provide a policy-compatibility enforcement point for `import_admissibility` and record compatibility evidence (`Verified_Rehydration_Agent_Conformance_Tests.md`:434, oracle `OR-23`:505). Architecture-evidence path: the deployment `Local policy bundle` obligation binding `policy_id` / `V_POLICY` / `V_COMPAT` (`Verified_Rehydration_Agent_Specification.md`:296). Canonical attestation home: `pt_results.json` `notes` for `PT-028`.
- `PT-029` (declarative, `V_WRITER_LOCK`) — recorded `SKIP`; buyer obligation: enforce single-writer discipline and emit `writer_lock_status` / `contention_status` evidence in the persistence control plane (`Verified_Rehydration_Agent_Conformance_Tests.md`:448, oracle `OR-24`:506). Architecture-evidence path: the deployment `Single-writer enforcement` obligation (`Verified_Rehydration_Agent_Specification.md`:297). Canonical attestation home: `pt_results.json` `notes` for `PT-029`.

## Corrections

Conformant on first execution; zero corrections.
