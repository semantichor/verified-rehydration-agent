# Conformance log — AGT-VRA-001 (bash)

Final acceptance run: 29 records — 27 PASS, 2 SKIP, 0 FAIL, 0 ERROR.
Suite PASS condition (Conformance Tests §4 Minimal Run Note) met: every runnable
test passes, the parameterized authority-release branch lands only in the
permitted state set, and both declarative bounded external-enforcement checks
carry attestation.

## Envelopes

- **PT-024 (parameterized, authority-release branch)** — declared envelope:
  the readmission release target lands in the set {`S0 STARTUP_READONLY`,
  `S1 SNAPSHOT_LOCKED`}. Declared value emitted by the baseline:
  `S0 STARTUP_READONLY`. Bounding citations:
  `Verified_Rehydration_Agent_Specification.md:236` (§12 transition row
  `S8 | authority_release | Readmission approved | S0 or S1`) and
  `Verified_Rehydration_Agent_Conformance_Tests.md:502` (OR-20 PASS condition
  `Result ∈ {S0 STARTUP_READONLY, S1 SNAPSHOT_LOCKED}`). Observed result:
  `S0 STARTUP_READONLY` ∈ envelope → PASS.

## Attestations

- **PT-028 (declarative, `V_COMPAT`)** — SKIP. Attestation note recorded in
  `pt_results.json` results[PT-028].notes: buyer obligation is the local policy
  bundle binding `policy_id`/`V_POLICY`/`V_COMPAT` (README artifact 3; Spec §16
  Local policy bundle), evidenced by the deployment policy-compatibility
  enforcement point (fixture DC-01 architecture evidence), not the local
  projection surface (Conformance Tests §4 "Bounded external obligations not
  locally runnable", `Verified_Rehydration_Agent_Conformance_Tests.md:518`).
- **PT-029 (declarative, `V_WRITER_LOCK`)** — SKIP. Attestation note recorded in
  `pt_results.json` results[PT-029].notes: buyer obligation is the single-writer
  persistence control plane emitting writer-lock/contention evidence (README
  artifact 4; Spec §16 Single-writer enforcement), evidenced by the persistence
  control plane (fixture DC-02 architecture evidence), not the local projection
  surface (`Verified_Rehydration_Agent_Conformance_Tests.md:518`).

## Corrections

Conformant on first execution; zero corrections.

## Runner note (non-baseline; transparency)

The first execution of `run_pts.sh` reported FAIL on the invocation-based
records because the runner referenced the interpreter path through the shell
variable `$BASH`, whose value on this host contains a space
(`bash`) and was used unquoted, so the token
split on the space. This was a fault in the test-runner harness, not in
`baseline.sh` (the same transitions returned the correct states under direct
invocation during the R5 health-probe and smoke tests). The runner was changed
to invoke the interpreter as `bash` on PATH; `baseline.sh` was not modified.
This is recorded here for transparency and is outside the R6 correction
protocol, which governs baseline transcription corrections resolved from the
specification.
