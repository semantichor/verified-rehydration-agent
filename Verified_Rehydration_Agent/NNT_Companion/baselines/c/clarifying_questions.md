# Clarifying Questions — AGT-VRA-001 / paradigm c

Each block records an interpretation choice made during R5/R6, with the full 5-source search trail (each source consulted in both structured and prose form), before a resolution status is declared.

### Q1. What does the transition surface return for a (state, trigger) pair not enumerated in the §12 transition table?

**Triggered by**: `Verified_Rehydration_Agent_Conformance_Tests.md`:250 — `PT-015` calls `next_state(S6 TOOL_QUARANTINE, StartupComplete, true)`, a pair the §12 table does not enumerate, so the baseline needed a defined default.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 transition table rows plus §7 ordering prose and §2 core-invariant prose — the table enumerates specific rows and one `Any state` row; §2 states restoration occurs only after the full sequence completes (`Verified_Rehydration_Agent_Specification.md`:47); the mechanism for an unenumerated pair is not itself named. Partial.
2. Conformance Tests — `PT-015` purpose/procedure/oracle `OR-11` — localizes the tested pair: `S6` remains `S6` on the exposed projection surface (`Verified_Rehydration_Agent_Conformance_Tests.md`:493). Localizer only.
3. Semantic Index — `ST-007 S6 TOOL_QUARANTINE` structured slots and `definition_operational` prose: exit condition `Separate approval or discard` (`Verified_Rehydration_Agent_Semantic_Index.md`:1997). Supports terminality.
4. `Coverage Matrix` — `ST-007` term→section mapping to §12 (`Verified_Rehydration_Agent_Coverage_Matrix.md`:81). No further constraint.
5. Ambiguity Register — no `AR-*` entry addresses unenumerated transition pairs. Not found.

**Resolution status**: `implementation_flexibility`
**Resolution citation** (semantic boundary): `Verified_Rehydration_Agent_Specification.md`:47
**Resolution text**: The pack fixes the semantics (no advance toward `S4`/`ALLOW` without the full sequence; a terminal state such as `S6` stays put, confirmed by `PT-015`) but leaves the mechanism for an unenumerated pair to the paradigm. The c baseline implements a fail-closed identity default (remain in the current state) in `next_state`; prescribing a specific mechanism would force one paradigm's idiom on all implementations.

### Q2. On a guard-failure at `S0 | startup_complete`, does the surface return `S5 FAIL_SAFE` or an `ESCALATE`-class outcome?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:228 — the §12 row `S0 | startup_complete | V_BOOT_MODE PASS | S1 | S5 or ESCALATE` names two on-failure possibilities.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 row prose (`:228`), §11 `startup_environment` → `ESCALATE` (`:205`), §10 `V_BOOT_MODE` → `ESCALATE` (`:186`), and the §12 state model, which enumerates states `S0`–`S8` with no dedicated `ESCALATE` state; `ESCALATE` is a verdict in §6, not a workflow state. The state-returning surface therefore lands the failure at `S5 FAIL_SAFE`. Resolved.
2. Conformance Tests — `PT-010` / `OR-06`: result state `S5 FAIL_SAFE` on the projection surface (`Verified_Rehydration_Agent_Conformance_Tests.md`:488). Localizer, consistent.
3. Semantic Index — `DE-013 ESCALATE` is a verdict, `ST-006 S5 FAIL_SAFE` is the state; structured and prose slots keep them separate (`Verified_Rehydration_Agent_Semantic_Index.md`:915, 1967). Consistent.
4. `Coverage Matrix` — `DE-013` maps to §5/§6/§8/§11, not §12 (`Verified_Rehydration_Agent_Coverage_Matrix.md`:40). Consistent.
5. Ambiguity Register — not reached.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:228
**Resolution text**: The workflow surface returns a state; the §12 state model has no `ESCALATE` state, so a `startup_complete` guard-failure lands at `S5 FAIL_SAFE`, which the §12 row lists as an admissible on-failure target.

### Q3. For the `ToolStateInvalid` trigger, does `validator_passed=true` change the outcome away from `S6 TOOL_QUARANTINE`?

**Triggered by**: `Verified_Rehydration_Agent_Conformance_Tests.md`:222 — `PT-013` passes `validator_passed=true` yet the oracle expects `S6`.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 row `S3 | tool-state invalid | Tool restrictions failed | S6` (`:232`) and the §2 invariant that Tool-state stays inactive unless a separate gate and approval succeed (`:53`); the mainline `validator_passed` gate concerns conversational eligibility. Partial (relationship between the two gates not stated in one place).
2. Conformance Tests — `PT-013`, `PT-014`, `PT-027` show the tool-state path landing in `S6` independent of the mainline eligibility path (`Verified_Rehydration_Agent_Conformance_Tests.md`:228-240). Localizer.
3. Semantic Index — `DE-004 tool_state_activation` and `BD-006 Tool-state` prose keep the tool-state path separate from conversational restoration (`Verified_Rehydration_Agent_Semantic_Index.md`:685, 261). Supports separation.
4. `Coverage Matrix` — `BD-006` maps to §11/§18 (`Verified_Rehydration_Agent_Coverage_Matrix.md`:15). Consistent.
5. Ambiguity Register — `AR-006` keeps `Tool-state`, `tool_state_activation`, and `Tool-state activation path` distinct (`Verified_Rehydration_Agent_Ambiguity_Register.md`:12). Resolved.

**Resolution status**: `resolved_in_d4`
**Resolution citation**: `Verified_Rehydration_Agent_Ambiguity_Register.md`:12
**Resolution text**: The presupposition that the mainline `validator_passed` gate governs the tool-state route does not hold; `AR-006` keeps the tool-state path distinct, so the `ToolStateInvalid` trigger routes to `S6` regardless of the conversational-eligibility gate. The baseline routes `ToolStateInvalid` to `S6` unconditionally.

### Q4. On a `DENY`-class bundle, does the restoration verdict determine `tool_activation_status`?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:250 — the minimum evidence bundle lists `tool_activation_status` as a mandatory field, and `PT-017` requires it present on a deny-path bundle (`Verified_Rehydration_Agent_Conformance_Tests.md`:280).

**Searched in (in order, stop at first resolution)**:
1. Specification — §14 bundle prose (`:250`), §9 `OBS-04` (`:168`), and the §2 invariant that Tool-state stays inactive unless a separate gate and approval succeed (`:53`); the field tracks tool-state trajectory, not the restoration verdict. Partial.
2. Conformance Tests — `PT-017` requires the field present and non-empty on a deny bundle; no oracle ties its value to the verdict (`Verified_Rehydration_Agent_Conformance_Tests.md`:280). Consistent.
3. Semantic Index — `EV-008 tool_activation_status` prose: separates restoration from tool-state activation (`Verified_Rehydration_Agent_Semantic_Index.md`:1627). Supports independence.
4. `Coverage Matrix` — `EV-008` maps to §4/§9/§14 (`Verified_Rehydration_Agent_Coverage_Matrix.md`:67). Consistent.
5. Ambiguity Register — `AR-007` keeps `restoration_request` and `restoration_verdict` distinct, and `AR-006` keeps the tool-state objects distinct (`Verified_Rehydration_Agent_Ambiguity_Register.md`:13, 12). Resolved.

**Resolution status**: `resolved_in_d4`
**Resolution citation**: `Verified_Rehydration_Agent_Ambiguity_Register.md`:12
**Resolution text**: The presupposition that the restoration verdict fixes `tool_activation_status` does not hold; `AR-006`/`AR-007` plus the §2 invariant make the field reflect an independent tool-state trajectory. The baseline emits `tool_activation_status=inactive` on deny bundles, reflecting the separate, inactive tool-state path.

### Q5. From which workflow state does the `wal_replay_needed` trigger apply, given the §12 `From` cell reads `Recovery path`?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:234 — the §12 recovery row names `Recovery path`, not a specific `S`-state, as its origin.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 recovery row (`:234`) plus the §12 state-model exit condition for `S5 FAIL_SAFE`: `Authorized recovery path starts` (`:219`); the recovery path begins at fail-safe. Resolved.
2. Conformance Tests — `PT-012` uses `current_state=S5 FAIL_SAFE` + `WalReplayNeeded` → `S7 RECOVERY_REPLAY` (`Verified_Rehydration_Agent_Conformance_Tests.md`:208). Localizer, consistent.
3. Semantic Index — `TR-006 wal_replay_needed` prose: moves from `Recovery path` to `S7 RECOVERY_REPLAY` (`Verified_Rehydration_Agent_Semantic_Index.md`:2207). Consistent.
4. `Coverage Matrix` — `TR-006` maps to §12 (`Verified_Rehydration_Agent_Coverage_Matrix.md`:89). Consistent.
5. Ambiguity Register — not reached.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:219
**Resolution text**: The `S5 FAIL_SAFE` exit condition `Authorized recovery path starts` identifies the recovery path as beginning at fail-safe, so the baseline maps `wal_replay_needed` from `S5` to `S7 RECOVERY_REPLAY`.

### Q6. How should the implementation signal an invalid input contract (unknown state or trigger token)?

**Triggered by**: R5 construction of the input boundary — the projection surface accepts a state, a trigger, and a boolean gate, and the baseline must handle a malformed token.

**Searched in (in order, stop at first resolution)**:
1. Specification — §16 fail-closed requirement (`:284`), §3 authority budget `restore / deny / quarantine / escalate` (`:68`), §6 verdict prose; the pack constrains the semantics (fail-closed, no restoration) but names no return mechanism. Partial (mechanism absent by design).
2. Conformance Tests — no record exercises a malformed token; the Minimal Run Note names the input types only (`Verified_Rehydration_Agent_Conformance_Tests.md`:512). Not found.
3. Semantic Index — no entry prescribes an error mechanism; structured slots carry no such field. Not found.
4. `Coverage Matrix` — no term→section mapping for an error-return mechanism. Not found.
5. Ambiguity Register — no `AR-*` entry addresses it. Not found.

**Resolution status**: `implementation_flexibility`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:284
**Resolution text**: Prescribing a specific signal (exit code, exception, `Result`, trap) would force one paradigm's idiom on all implementations and contradict execution-neutrality; the pack fixes only the fail-closed semantics. The c baseline signals an invalid contract by a non-zero process exit code plus a `stderr` diagnostic, and an unknown trigger is treated as unmapped (fail-closed identity), never advancing toward `S4`.
