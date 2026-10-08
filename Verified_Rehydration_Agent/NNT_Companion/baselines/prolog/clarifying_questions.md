# Clarifying questions — AGT-VRA-001 — paradigm: prolog

Each interpretation choice made during R5/R6, with its full 5-source search trail. Citations are
`<filename>:<int>` (1-based line in the file on disk). No `real_residual` was observed in this run.

---

### Q1. On the transition projection surface, does an S0 startup guard-failure land in S5 or in ESCALATE?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:228` — the S0 transition row states the On-failure target as "S5 or ESCALATE", but `next_state/4` must return a single state.

**Searched in (in order, stop at first resolution)**:
1. Specification — full tables + paragraphs: §12 transition row `S0 | startup_complete | V_BOOT_MODE PASS | S1 | S5 or ESCALATE` at `Verified_Rehydration_Agent_Specification.md:228` lists `S5` as an admissible failure target; §12 S5 state row at `:219`; §10 `V_BOOT_MODE` failure produces ESCALATE at `:186`; §11 `startup_environment` yields ESCALATE at `:205`; §17 "Startup not read-only" expected result ESCALATE at `:322` — resolved: `S5` is a spec-listed admissible target for the state transition, while ESCALATE is the verdict-level effect.
2. Conformance Tests — PT-010 procedure `current_state=S0, trigger=StartupComplete, validator_passed=false` at `:180`, OR-06 PASS `Result state = S5 FAIL_SAFE` at `:488` — localizer: the projection surface returns `S5`.
3. Semantic Index — TR-001 `definition_operational` "On failure: S5 FAIL_SAFE or ESCALATE" at `Verified_Rehydration_Agent_Semantic_Index.md:2079` — same disjunction in prose.
4. Coverage Matrix — TR-001 term→section mapping at `Verified_Rehydration_Agent_Coverage_Matrix.md:84` — points back to §12.
5. Ambiguity Register — AR-002 keeps verdict labels and workflow-state labels distinct at `Verified_Rehydration_Agent_Ambiguity_Register.md:8` — confirms the state (`S5`) and the verdict (ESCALATE) are two distinct projections, so no contradiction.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:228`
**Resolution text**: The state-transition surface returns `S5 FAIL_SAFE` (a spec-listed admissible target); ESCALATE is the distinct verdict-level effect. `next_state(s0_startup_readonly, startup_complete, false, s5_fail_safe)`.

---

### Q2. What does `next_state/4` do for a (state, trigger) combination that the transition table does not enumerate?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:226` — the transition model enumerates specific rows; a runtime combination outside them (e.g., `authority_release` from `S2`) has no listed edge.

**Searched in (in order, stop at first resolution)**:
1. Specification — §7 ordering "No later step may execute if a prior critical step has failed" at `:138`; §16 conformance requirement "must preserve fail-closed semantics for every failed critical validator" at `:284`; §3 Authority budget "Strictly bounded to restore / deny / quarantine / escalate" at `:68`; Core safety model "On any blocking failure, the agent denies restoration, suppresses persistent-state injection, or quarantines" at `:11` — the SEMANTICS are fixed (fail-closed, bounded authority) but no single mechanism/return shape is prescribed.
2. Conformance Tests — no PT exercises a non-enumerated combination; the Minimal Run Note fixes the surface signature only at `:510` — not resolved to a mechanism.
3. Semantic Index — TR-001..TR-008 enumerate only the listed triggers (e.g., `Verified_Rehydration_Agent_Semantic_Index.md:2075`); no default-edge term — not found.
4. Coverage Matrix — Transition Terms TR-001..TR-008 map only listed rows at `Verified_Rehydration_Agent_Coverage_Matrix.md:84` — not found.
5. Ambiguity Register — no AR-* entry governs an unmapped transition — not found.

**Resolution status**: `implementation_flexibility`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:284`
**Resolution text**: The pack fixes fail-closed semantics and bounds authority (§16, §3) but leaves the mechanism to the paradigm; the Prolog baseline expresses this by having `next_state/4` yield no solution for an unmapped pair (no admissible edge = no restore emitted = fail-closed), which is the paradigm-idiomatic form of the fail-closed constraint. Prescribing a specific return token would force one paradigm's idiom on all.

---

### Q3. What concrete VALUES do the evidence-bundle fields carry (e.g., `snapshot_id`, `policy_id`, `validator_bundle_id`)?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:250` — §14 fixes the minimum-bundle fields and their presence, but the bundle-emission oracles check presence/non-emptiness, not specific values.

**Searched in (in order, stop at first resolution)**:
1. Specification — §14 Evidence Contract fields + producers at `:252`–`:263`; §16 Deployment obligations table at `:294`–`:298` binds `snapshot_id`, `policy_id`, anti-rollback anchor, writer-lock evidence to the deployment substrate — the field VALUES originate in deployment artifacts.
2. Conformance Tests — OR-12/OR-13 require fields "present and non-empty" at `:494`–`:495`, never a specific value except discrete tags — not a value source.
3. Semantic Index — EV-004 `snapshot_id` `allowed_values` null, prose "stable snapshot identifier" at `Verified_Rehydration_Agent_Semantic_Index.md:1521` — no enumerated value set.
4. Coverage Matrix — EV-004 maps to §14/§16 at `Verified_Rehydration_Agent_Coverage_Matrix.md:63` — points to deployment obligations.
5. Ambiguity Register — no AR-* fixes a field value — not found.

**Resolution status**: `deployment_obligation`
**Resolution text**: The field values are buyer-side deployment substrate (`Verified_Rehydration_Agent_README.md:85`; §16 obligations). The baseline emits representative non-empty tokens for the presence/non-emptiness oracles; a deployment binds the real values from its snapshot facility, policy bundle, and anti-rollback anchor.
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:294`

---

### Q4. What exact string form do the producer tags take (e.g., `ExecutionLayer` vs "Execution layer")?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:256` — §14 names producers as "Execution layer", "Gate logic", "Tool gate", "V_WAL_PHASE"; PT-021/PT-026 assert exact camel-case tokens.

**Searched in (in order, stop at first resolution)**:
1. Specification — §14 producer column: `validator_bundle_id` by "Execution layer" at `:256`, `failure_code + failed_validator` by "Gate logic" at `:260`, `tool_activation_status` by "Tool gate" at `:261`, `recovery_phase` by "V_WAL_PHASE" at `:262` — fixes producer IDENTITY, not the token spelling.
2. Conformance Tests — OR-17 `validator_bundle_id_producer=ExecutionLayer; failure_explanation_producer=GateLogic; tool_activation_status_producer=ToolGate` at `:499`; OR-22 `recovery_phase_producer = V_WAL_PHASE` at `:504` — fixes the exact token form.
3. Semantic Index — EV-001/EV-008/EV-009 name producers in prose (e.g., `Verified_Rehydration_Agent_Semantic_Index.md:1625`) — identity, not token form.
4. Coverage Matrix — EV-001/EV-008/EV-009 map to §9/§14 at `Verified_Rehydration_Agent_Coverage_Matrix.md:60` — no token form.
5. Ambiguity Register — no AR-* governs producer-tag spelling — not found.

**Resolution status**: `resolved_in_ct`
**Resolution citation**: `Verified_Rehydration_Agent_Conformance_Tests.md:499`
**Resolution text**: The producer identity is grounded in §14; the exact token spelling that the acceptance oracle checks is fixed by OR-17/OR-22 (`ExecutionLayer`, `GateLogic`, `ToolGate`, `V_WAL_PHASE`), which the baseline emits verbatim.

---

### Q5. From which state does the "Recovery path" `wal_replay_needed` transition originate?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:234` — the transition From-field is "Recovery path", not a specific `Sx` state.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 recovery row `Recovery path | wal_replay_needed | V_WAL_PHASE indicates recovery | S7 | S5` at `:234`; §12 S5 state exit condition "Authorized recovery path starts" at `:219` — the recovery path begins where fail-safe (`S5`) is entered.
2. Conformance Tests — WF-08 fixture `current_state=S5 FAIL_SAFE; trigger=WalReplayNeeded` at `:463`, PT-012 expected `S7 RECOVERY_REPLAY` at `:210` — confirms origin `S5`.
3. Semantic Index — TR-006 `wal_replay_needed` "from Recovery path to S7 RECOVERY_REPLAY" at `Verified_Rehydration_Agent_Semantic_Index.md:2207`; ST-006 S5 exit "Authorized recovery path starts" at `:1971` — same.
4. Coverage Matrix — TR-006 maps to §12 at `Verified_Rehydration_Agent_Coverage_Matrix.md:89` — points to §12.
5. Ambiguity Register — AR-010 keeps WAL, `wal_replay_needed`, `S7 RECOVERY_REPLAY`, `recovery_phase` distinct at `Verified_Rehydration_Agent_Ambiguity_Register.md:16` — confirms the trigger is not the state.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:219`
**Resolution text**: The recovery path begins at `S5 FAIL_SAFE` (its exit condition is "Authorized recovery path starts"); the baseline routes `next_state(s5_fail_safe, wal_replay_needed, true, s7_recovery_replay)`, matching WF-08.

---

### Q6. Is `S6 TOOL_QUARANTINE` stable/terminal on the exposed projection surface for non-rollback triggers?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:220` — S6 exit condition is "Separate approval or discard", which is not a workflow transition trigger; the projection surface still needs a defined result for a trigger arriving at S6.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 S6 state row exit "Separate approval or discard" at `:220`; §12 transition model lists no ordinary-trigger edge out of S6 (`:226`–`:236`) — no workflow trigger exits S6.
2. Conformance Tests — PT-015 `current_state=S6, trigger=StartupComplete, validator_passed=true` at `:250`, OR-11 "S6 remains stable / terminal on the exposed projection surface" at `:493` — fixes projection-surface terminality.
3. Semantic Index — ST-007 S6 exit "Separate approval or discard" at `Verified_Rehydration_Agent_Semantic_Index.md:1997` — same.
4. Coverage Matrix — ST-007 maps to §12 at `Verified_Rehydration_Agent_Coverage_Matrix.md:81` — points to §12.
5. Ambiguity Register — AR-003 keeps QUARANTINE / `S6 TOOL_QUARANTINE` / MRF-TOOL-QUARANTINE distinct at `Verified_Rehydration_Agent_Ambiguity_Register.md:9` — confirms S6 is a state label, handled on the state surface.

**Resolution status**: `resolved_in_ct`
**Resolution citation**: `Verified_Rehydration_Agent_Conformance_Tests.md:493`
**Resolution text**: On the exposed projection surface S6 is stable/terminal (OR-11), grounded in the §12 S6 exit being a separate approval/discard rather than a workflow trigger; the baseline keeps S6 for any non-rollback trigger.

---

### Q7. When rollback is detected from `S6`, does the rollback override or does S6 terminality hold?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:233` — the "Any state, rollback_detected -> S5" row can co-apply with S6 terminality; the two must be ordered.

**Searched in (in order, stop at first resolution)**:
1. Specification — §7 "Rollback detection has blocking priority over every other restoration rule" at `:142`; §12 rollback row "Any state | rollback_detected | ... | S5" at `:233` — rollback prevails over every other rule, including S6 terminality.
2. Conformance Tests — no PT exercises (S6, rollback); PT-011 shows rollback overriding from S3 at `:194` — consistent with priority.
3. Semantic Index — TR-005 `rollback_detected` "from Any state to S5 FAIL_SAFE" at `Verified_Rehydration_Agent_Semantic_Index.md:2181` — same.
4. Coverage Matrix — TR-005 maps to §12 at `Verified_Rehydration_Agent_Coverage_Matrix.md:88` — points to §12.
5. Ambiguity Register — no AR-* alters the priority — not found.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:142`
**Resolution text**: Rollback blocking priority prevails over every other restoration rule, so the baseline places the `rollback_detected -> s5_fail_safe` clause first with a cut, ahead of the S6-terminality clause.

---

### Q8. Does the DENY restoration verdict determine `tool_activation_status` on a deny-path evidence bundle?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:88` — a DENY bundle must still carry `tool_activation_status`; a naive reading presupposes the restoration verdict sets that field's value. (Presupposition of a relationship between two terms — checked against D4 as a decision rule.)

**Searched in (in order, stop at first resolution)**:
1. Specification — §2 core invariant "Tool-state remains untrusted and inactive unless a separate activation gate and required approval both succeed" at `:53`; §16 precedence "Conversational restoration does not imply or compensate for tool-state activation" at `:308`; §5 DENY min content lists `suppression_status` etc., not a tool-state coupling, at `:88` — the field tracks an independent tool-state trajectory.
2. Conformance Tests — PT-014 shows the tool-state path and mainline eligibility as non-inheriting at `:238` — the two are independent.
3. Semantic Index — EV-008 `tool_activation_status` "separating restoration from tool-state activation" at `Verified_Rehydration_Agent_Semantic_Index.md:1625` — independence in prose.
4. Coverage Matrix — EV-008 maps to §4/§9/§14 at `Verified_Rehydration_Agent_Coverage_Matrix.md:67` — no verdict coupling.
5. Ambiguity Register — AR-006 keeps `Tool-state` / `tool_state_activation` / `Tool-state activation path` distinct (object vs decision vs optional feature) at `Verified_Rehydration_Agent_Ambiguity_Register.md:12`; AR-007 keeps `restoration_request` and `restoration_verdict` distinct at `:13` — the presupposed "verdict sets the field" relationship does not hold.

**Resolution status**: `resolved_in_d4`
**Resolution citation**: `Verified_Rehydration_Agent_Ambiguity_Register.md:12`
**Resolution text**: The presupposition is ill-formed: AR-006 and AR-007, with the §2 invariant, keep tool-state, its activation decision, and the restoration verdict distinct, so `tool_activation_status` reflects the independent tool-state trajectory (the baseline emits `inactive` on the deny-path bundle), not the DENY verdict.
