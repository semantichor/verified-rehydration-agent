# Conformance log — AGT-VRA-001 — paradigm rust

Final acceptance run: total 29, pass 27, fail 0, skip 2, error 0. `execution_mode` = `live`; `protocol` = `buyer-conformance`. Suite PASS condition of the Minimal Run Note (`Verified_Rehydration_Agent_Conformance_Tests.md`:516) is met: every runnable record passes, the parameterized authority-release branch lands only in the permitted state set, and both declarative bounded-external checks are attested.

## Envelopes

- PT-024 (parameterized, authority-release branch). Fixture WF-12: `current_state=S8 READMISSION_PENDING`, `trigger=AuthorityRelease`, `validator_passed=true`. Declared envelope: the permitted landing set is `{S0 STARTUP_READONLY, S1 SNAPSHOT_LOCKED}`; the baseline's declared value is `S1 SNAPSHOT_LOCKED` (an operator declaration exposed through the `VRA_READMISSION_TARGET` environment parameter, whose alternate admissible value `S0` also lands inside the set). Bounding citations: `Verified_Rehydration_Agent_Specification.md`:236 (§12 transition row `S8 | authority_release | Readmission approved | S0 or S1`) and `Verified_Rehydration_Agent_Conformance_Tests.md`:502 (OR-20 `Result ∈ {S0 STARTUP_READONLY, S1 SNAPSHOT_LOCKED}`). Observed result: `S1`, inside the set — PASS.

## Attestations

- PT-028 (declarative, `V_COMPAT`): SKIP. Cross-reference to `pt_results.json` `notes`. Bounded external obligation named by the Minimal Run Note (`Verified_Rehydration_Agent_Conformance_Tests.md`:518) as `V_COMPAT` enforcement in `import_admissibility` / policy-compatibility; the buyer attests it through architecture evidence of the local, versioned policy bundle (§16 deployment obligation "Local policy bundle", `Verified_Rehydration_Agent_Specification.md`:296), not by the local transition surface.
- PT-029 (declarative, `V_WRITER_LOCK`): SKIP. Cross-reference to `pt_results.json` `notes`. Bounded external obligation named by the Minimal Run Note (`Verified_Rehydration_Agent_Conformance_Tests.md`:518) as `V_WRITER_LOCK` enforcement in the persistence control plane / deployment conformance; the buyer attests it through architecture evidence of single-writer enforcement (§16 deployment obligation "Single-writer enforcement", `Verified_Rehydration_Agent_Specification.md`:297).

## Corrections

Conformant on first execution; zero corrections.
