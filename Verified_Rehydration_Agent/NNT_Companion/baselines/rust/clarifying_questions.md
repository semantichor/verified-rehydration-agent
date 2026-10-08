# Clarifying questions — AGT-VRA-001 — paradigm rust

Each block records an interpretation choice made during R5/R6 with the full five-source search trail through the pack's normative sources before a resolution status is declared.

### Q1. What does the transition surface return for a `(state, trigger)` combination not enumerated in §12?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:226 — the §12 transition model enumerates specific rows; the projection surface `next_state(current_state, trigger, validator_passed)` must also answer inputs outside those rows.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 transition model tables (rows + the `Any state | rollback_detected` row) and §16 conformance requirements + precedence prose — the semantic constraint is fixed at `Verified_Rehydration_Agent_Specification.md`:284 ("preserve fail-closed semantics for every failed critical validator") and §2 invariant `Verified_Rehydration_Agent_Specification.md`:47 ("No restoration is permitted before the full verification sequence completes successfully"); the concrete return mechanism is not fixed.
2. Conformance Tests — PT-015 + OR-11 (`Verified_Rehydration_Agent_Conformance_Tests.md`:242, 493) fix that `S6 TOOL_QUARANTINE` stays isolated for a trigger it does not consume; no record prescribes a return type for the general non-enumerated case.
3. Semantic Index — state/transition entries (ST-001..ST-009, TR-001..TR-008) define the vocabulary; structured slots (`allowed_values`) and prose carry no return-mechanism enumeration.
4. Coverage Matrix — ST/TR term rows map only to §12; no additional closing section.
5. Ambiguity Register (D4) — no AR-* entry addresses the transition function's return mechanism.

**Resolution status**: `implementation_flexibility`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:284
**Resolution text**: The SEMANTIC is fixed (fail-closed: no restoration proceeds), so my baseline routes any non-enumerated non-terminal `(state, trigger)` to `S5 FAIL_SAFE` and keeps `S6 TOOL_QUARANTINE` absorbing; the MECHANISM (a total function returning a state vs. an error/`Result`/panic) is left open to preserve execution-neutrality, and rust expresses it as an exhaustive `match` with a fail-closed `_` arm.

### Q2. When `authority_release` fires from `S8`, does the workflow return to `S0` or `S1`?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:236 — the §12 row states the target as "S0 or S1", leaving the specific landing open at emission time.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 transition row `Verified_Rehydration_Agent_Specification.md`:236 fixes the admissible set as `S0 or S1`; §11 `readmission_request` `Verified_Rehydration_Agent_Specification.md`:206 confirms the readmission gate context without narrowing the target.
2. Conformance Tests — PT-024 (Parameterized) + OR-20 (`Verified_Rehydration_Agent_Conformance_Tests.md`:376, 502) fix the pass set as `{S0 STARTUP_READONLY, S1 SNAPSHOT_LOCKED}` and mark the record parameterized against operator-declared inputs.
3. Semantic Index — TR-008 `authority_release` (`Verified_Rehydration_Agent_Semantic_Index.md`:2257) prose names only `S0 STARTUP_READONLY` in both `definition_short` and `definition_operational`; structured slots carry no `allowed_values` set (see R9 observation on the narrower SI phrasing).
4. Coverage Matrix — TR-008 (`Verified_Rehydration_Agent_Coverage_Matrix.md`:91) maps only to §12; adds no target detail.
5. Ambiguity Register (D4) — AR-002 (`Verified_Rehydration_Agent_Ambiguity_Register.md`:8) keeps the `READMISSION_PENDING` verdict distinct from the `S8` state but does not fix the release target.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:236
**Resolution text**: The specification fixes the admissible target set to `{S0, S1}`; the exact landing within that set is the operator-declared envelope (recorded under conformance_log Envelopes, default `S1`), which is why PT-024 is parameterized rather than a fixed-equality record.

### Q3. What is `tool_activation_status` on a DENY-path evidence bundle?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:250 — §14 lists `tool_activation_status` as an unconditional bundle field, and the freshness-downgrade evidence record (PT-017) asserts it non-empty even though the verdict is a denial.

**Searched in (in order, stop at first resolution)**:
1. Specification — §14 field table (`Verified_Rehydration_Agent_Specification.md`:261, `tool_activation_status` produced by the Tool gate, Required Yes) plus the §2 invariant `Verified_Rehydration_Agent_Specification.md`:53 ("Tool-state remains untrusted and inactive unless a separate activation gate and required approval both succeed") and §11 `tool_state_activation` `Verified_Rehydration_Agent_Specification.md`:203; the field tracks the tool-state trajectory, separate from the restoration verdict.
2. Conformance Tests — PT-017/OR-13 and PT-021/OR-17 (`Verified_Rehydration_Agent_Conformance_Tests.md`:280, 336) assert the field present and produced by `ToolGate`; oracle prose does not tie its value to the restoration verdict.
3. Semantic Index — EV-008 `tool_activation_status` (`Verified_Rehydration_Agent_Semantic_Index.md`:1625) `definition_operational` prose: "Shows whether tool-state activation remains inactive, quarantined, or otherwise separately gated from conversational restoration."
4. Coverage Matrix — EV-008 (`Verified_Rehydration_Agent_Coverage_Matrix.md`:67) maps to §4, §9, §14, keeping it in the tool-state boundary rather than the verdict.
5. Ambiguity Register (D4) — AR-006 (`Verified_Rehydration_Agent_Ambiguity_Register.md`:12) keeps `Tool-state`, `tool_state_activation`, and the activation path distinct; AR-007 (`Verified_Rehydration_Agent_Ambiguity_Register.md`:13) keeps `restoration_request` distinct from `restoration_verdict`.

**Resolution status**: `resolved_in_d4`
**Resolution citation**: `Verified_Rehydration_Agent_Ambiguity_Register.md`:12
**Resolution text**: The presupposition that the restoration verdict fixes the field is ill-formed: AR-006 and AR-007 with the §2 invariant establish that tool-state is an independent trajectory, so on a DENY path the field reflects the separate tool-state gate — my baseline emits `INACTIVE` (non-empty) by default, not a value derived from the denial.

### Q4. On the projection surface, does a non-read-only startup return `S5` or the `ESCALATE` verdict?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:322 — §17 lists the startup-not-read-only scenario as `ESCALATE`, while the workflow surface is tested for a returned state.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 row `Verified_Rehydration_Agent_Specification.md`:228 gives the S0 failure column as "S5 or ESCALATE"; §11 `startup_environment` `Verified_Rehydration_Agent_Specification.md`:205 gives verdict `ESCALATE`; §13 escalation gate `Verified_Rehydration_Agent_Specification.md`:245 is the gate view. The state view and the verdict view coexist.
2. Conformance Tests — PT-010 + OR-06 (`Verified_Rehydration_Agent_Conformance_Tests.md`:180, 488) fix the transition-surface result as `S5 FAIL_SAFE` for `S0 + StartupComplete + validator_passed=false`.
3. Semantic Index — ST-006 `S5 FAIL_SAFE` and DE-013 `ESCALATE` are separate entries (State Terms vs Decision Terms); the projection surface returns a State term.
4. Coverage Matrix — ST-006 maps to §12; DE-013 maps to §5/§6/§8/§11 — different categories, consistent with the state/verdict split.
5. Ambiguity Register (D4) — AR-004 (`Verified_Rehydration_Agent_Ambiguity_Register.md`:10) keeps `Fail-safe suppression`, `S5 FAIL_SAFE`, and `fail_safe_release` distinct, so the fail-safe state label is not the same object as an escalation verdict.

**Resolution status**: `resolved_in_ct`
**Resolution citation**: `Verified_Rehydration_Agent_Conformance_Tests.md`:488
**Resolution text**: The projection surface returns the workflow state `S5 FAIL_SAFE` (PT-010/OR-06); `ESCALATE` is the concurrent operator-visible verdict/gate view of the same failure, not the value of the transition surface — my baseline returns `S5` and projects a verdict view separately.

### Q5. Should `next_state` distinguish which structural validator (V_FRAME..V_SIG) failed?

**Triggered by**: `Verified_Rehydration_Agent_Conformance_Tests.md`:459 — WF-04 drives PT-004..PT-007 (framing, parse, chain, signature) with a single `validator_passed=false` boolean, collapsing four distinct validators onto one gate input.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 row `Verified_Rehydration_Agent_Specification.md`:230 groups `V_FRAME..V_SIG PASS` as one structural guard; §7 ordering `Verified_Rehydration_Agent_Specification.md`:138 makes any prior critical failure block later steps identically.
2. Conformance Tests — Minimal Run Note `Verified_Rehydration_Agent_Conformance_Tests.md`:510 declares the surface as `next_state(current_state, trigger, validator_passed)` with a boolean gate; WF-04 (`Verified_Rehydration_Agent_Conformance_Tests.md`:459) is shared by PT-004..PT-007, so the same input yields the same `S5`.
3. Semantic Index — VA-001..VA-005 are distinct validator entries, but the workflow-surface input vocabulary is the boolean gate, not a per-validator identifier.
4. Coverage Matrix — VA-001..VA-005 map to §4/§10/§11 (catalogue + decision), not to §12; the per-validator identity lives in the evidence surface (`failed_validator`), not the transition surface.
5. Ambiguity Register (D4) — no AR-* entry requires the transition surface to carry per-validator identity.

**Resolution status**: `resolved_in_ct`
**Resolution citation**: `Verified_Rehydration_Agent_Conformance_Tests.md`:510
**Resolution text**: The transition surface is a boolean-gated function by design; the specific failed validator is carried on the evidence surface (`failed_validator`, exercised by PT-018/PT-025), so my baseline abstracts the structural group to one `validator_passed` gate and records the per-validator identity in the evidence bundle.

### Q6. What mechanism signals a malformed CLI argument (unknown state/trigger/verdict token)?

**Triggered by**: `Verified_Rehydration_Agent_Conformance_Tests.md`:512 — the Minimal Run Note fixes the input TYPES (workflow state, transition trigger, boolean gate) but not how a conforming implementation must reject an out-of-vocabulary token.

**Searched in (in order, stop at first resolution)**:
1. Specification — §6 verdict semantics and §12 vocabulary fix the admissible token sets, and §16 fail-closed prose `Verified_Rehydration_Agent_Specification.md`:284 fixes the semantic; no return-code or exception mechanism is prescribed.
2. Conformance Tests — all fixtures supply in-vocabulary tokens; no record fixes error-signalling for malformed input.
3. Semantic Index — vocabulary entries enumerate the admissible tokens; no error-mechanism slot.
4. Coverage Matrix — no term maps to an input-rejection mechanism.
5. Ambiguity Register (D4) — no AR-* entry addresses input-error mechanism.

**Resolution status**: `implementation_flexibility`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:284
**Resolution text**: The pack constrains the admissible vocabulary and the fail-closed semantic but leaves the rejection mechanism open; my baseline parses tokens through `Result<T, String>` and exits with a non-zero code on an unknown token, an idiom native to rust and consistent with fail-closed behavior.
