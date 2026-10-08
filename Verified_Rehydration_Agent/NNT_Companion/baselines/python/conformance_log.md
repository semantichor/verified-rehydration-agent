# Conformance log — AGT-VRA-001 — python

Final acceptance run: total 29, pass 27, fail 0, skip 2, error 0. `execution_mode`
is `live`; every `PASS`/`FAIL` status is backed by captured stdout in
`pt_run_log.txt`.

## Envelopes

### PT-024 — Authority-release branch (parameterized)

- Declared envelope: `next_state(S8 READMISSION_PENDING, AuthorityRelease, validator_passed=true)`
  resolves within the package-authorized target set `{S0 STARTUP_READONLY, S1 SNAPSHOT_LOCKED}`.
- Value declared for this run: `S0 STARTUP_READONLY` — the more conservative full
  read-only re-entry; carried by the constant `AUTHORITY_RELEASE_TARGET` in `baseline.py`.
- Bounding citation: `Verified_Rehydration_Agent_Specification.md`:236 (§12 transition
  row — `S8` `authority_release` guarded by "Readmission approved" resolves to "S0 or S1");
  `Verified_Rehydration_Agent_Conformance_Tests.md`:502 (OR-20 — Result ∈ {S0 STARTUP_READONLY, S1 SNAPSHOT_LOCKED}).
- Observed result: `S0 STARTUP_READONLY`, a member of the declared set. OR-20 membership holds.

## Attestations

- PT-028 (declarative, `V_COMPAT`) — SKIP attested in `pt_results.json` `notes` (canonical home).
  Buyer obligation: a policy-compatibility enforcement point for `import_admissibility` that
  records compatibility evidence, proved by architecture evidence — the local, versioned policy
  bundle binding `policy_id`, `V_POLICY`, and `V_COMPAT`. Citations:
  `Verified_Rehydration_Agent_Conformance_Tests.md`:518 (Minimal Run Note bounded external
  obligations); `Verified_Rehydration_Agent_Specification.md`:296 (§16 Deployment obligation
  "Local policy bundle").
- PT-029 (declarative, `V_WRITER_LOCK`) — SKIP attested in `pt_results.json` `notes` (canonical home).
  Buyer obligation: single-writer enforcement emitting writer-lock / contention evidence without
  semantic drift, proved by architecture evidence — the single-writer persistence control plane.
  Citations: `Verified_Rehydration_Agent_Conformance_Tests.md`:518 (Minimal Run Note bounded
  external obligations); `Verified_Rehydration_Agent_Specification.md`:297 (§16 Deployment
  obligation "Single-writer enforcement").

## Corrections

Conformant on first execution; zero corrections.
