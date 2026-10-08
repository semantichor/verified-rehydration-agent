# Clarifying questions — AGT-VRA-001 (bash)

Each block records an interpretation choice made during R5 or R6, with the full
search trail through the pack's normative sources before a resolution status is
declared. Structured and prose forms of each source were searched.

---

### Q1. What does `next_state` return for a (state, trigger) pair not enumerated in the §12 transition table?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:226` — the §12 transition model enumerates specific rows; a runtime pair outside them (e.g. `S2` + `AuthorityRelease`) needed a defined outcome for the `case` dispatch default.

**Searched in (in order, stop at first resolution)**:
1. Specification — §7 ordering + §8 failure semantics + §12 on-failure column + §16 conformance requirements — resolved: the Core safety model and §16 fix the outcome as fail-closed. `Verified_Rehydration_Agent_Specification.md:11` states any blocking failure denies restoration and suppresses injection; `Verified_Rehydration_Agent_Specification.md:284` requires fail-closed semantics; every §12 on-failure cell routes to `S5 FAIL_SAFE`.
2. Conformance Tests — not reached (resolved at source 1).
3. Semantic Index — not reached.
4. Coverage Matrix — not reached.
5. Ambiguity Register (D4) — not reached.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:11`
**Resolution text**: An unenumerated pair routes to `S5 FAIL_SAFE` (fail-closed); the baseline's `case` default returns `S5`.

---

### Q2. On `S8` `authority_release` success, does the surface return `S0` or `S1`?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:236` — the §12 row names two admissible targets ("S0 or S1") without fixing one.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 transition row + §16 deployment obligations + §18 dual-control readmission — the target set is bounded to {`S0`,`S1`} but the specific target is left to the readmission authority workflow; not fixed in the Specification prose.
2. Conformance Tests — PT-024 procedure + OR-20 PASS condition (`Verified_Rehydration_Agent_Conformance_Tests.md:502`) — confirms either member of {`S0`,`S1`} satisfies the oracle; the exact target is operator-declared.
3. Semantic Index — TR-008 `authority_release` entry — names the transition; no single target enumerated.
4. Coverage Matrix — TR-008 row maps only to §12; no closing value.
5. Ambiguity Register (D4) — no AR-* entry governs the target selection.

**Resolution status**: `deployment_obligation`
**Resolution citation**: `Verified_Rehydration_Agent_README.md:91`
**Resolution text**: The readmission release target is buyer-side (deployment artifact 5, the readmission authority workflow), bounded to {`S0`,`S1`}; the baseline declares `S0 STARTUP_READONLY` as its envelope value.

---

### Q3. What mechanism signals a failed critical validator / fail-closed handling?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:284` — the conformance requirement fixes fail-closed semantics but names no mechanism.

**Searched in (in order, stop at first resolution)**:
1. Specification — §8 failure semantics + §16 conformance requirements + §19 reuse note — the SEMANTICS are fixed (fail-closed, no downgrade of `DENY`/`QUARANTINE`/`ESCALATE`) while the return mechanism is left open, consistent with the execution-neutral posture (`Verified_Rehydration_Agent_Specification.md:5`).
2. Conformance Tests — oracles assert result states and evidence fields, not a mechanism.
3. Semantic Index — CT-001 `Fail-safe suppression` prose describes the control, not a mechanism.
4. Coverage Matrix — CT-001 maps to §8/§13; no mechanism named.
5. Ambiguity Register (D4) — AR-004 keeps the control, state, and decision object distinct; no mechanism fixed.

**Resolution status**: `implementation_flexibility`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:284`
**Resolution text**: The pack constrains fail-closed semantics but not the mechanism; the baseline expresses it with `trap ... ERR`, a `case` default routing to `S5`, and a non-zero exit for an unknown command — the bash-idiomatic fail-closed form.

---

### Q4. On the `S3` → `S6` tool-state route, does `validator_passed` gate the outcome?

**Triggered by**: `Verified_Rehydration_Agent_Conformance_Tests.md:222` — PT-013/PT-027 pass `validator_passed=true` yet expect `S6 TOOL_QUARANTINE`, which appeared to conflict with the boolean gate used on the mainline path.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 row `S3 | tool-state invalid | Tool restrictions failed | S6` (`Verified_Rehydration_Agent_Specification.md:232`) + §8 tool-state restriction failure row (`:155`) — resolved: the `ToolStateInvalid` trigger itself carries the tool-restriction failure; the boolean gate governs the mainline eligibility path, not the tool-state branch.
2. Conformance Tests — PT-014 split-boundary oracle OR-10 confirms the tool-state branch and the mainline branch are independent.
3. Semantic Index — not reached (resolved at source 1).
4. Coverage Matrix — not reached.
5. Ambiguity Register (D4) — AR-006 keeps `Tool-state`, `tool_state_activation`, and the activation path distinct, corroborating the independent branch.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:232`
**Resolution text**: `ToolStateInvalid` routes `S3` → `S6` regardless of the mainline boolean gate; the baseline's `case` maps both boolean values of that trigger to `S6`.

---

### Q5. Does the evidence field `tool_activation_status` reflect the restoration verdict?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:250` — the minimum bundle lists `tool_activation_status` for every relevant decision, raising whether its value tracks the `ALLOW`/`DENY` verdict.

**Searched in (in order, stop at first resolution)**:
1. Specification — §2 invariant (`Verified_Rehydration_Agent_Specification.md:53`: tool-state inactive unless a separate activation gate and required approval both succeed) + §9 OBS-04 + §14 — the field tracks the tool-state trajectory, separate from the restoration verdict.
2. Conformance Tests — PT-017/OR-13 assert presence and non-emptiness only, not a verdict-coupled value.
3. Semantic Index — EV-008 `tool_activation_status` prose separates restoration from tool-state activation.
4. Coverage Matrix — EV-008 maps to §4/§9/§14; no verdict coupling.
5. Ambiguity Register (D4) — AR-006 (object vs decision vs optional path distinct) and AR-007 (request vs verdict distinct) — the presupposition that the verdict fixes the field is ill-formed.

**Resolution status**: `resolved_in_d4`
**Resolution citation**: `Verified_Rehydration_Agent_Ambiguity_Register.md:12`
**Resolution text**: The presupposed verdict→field relationship does not hold; the field reflects the independent tool-state trajectory, so the baseline emits `tool_activation_status=inactive` by default per the §2 invariant.

---

### Q6. What concrete values should the evidence digest/id fields carry (e.g. `verified_head_digest`, `snapshot_id`, `policy_id`)?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:254` — §14 marks these fields Required=Yes but their values originate outside the agent-logic surface.

**Searched in (in order, stop at first resolution)**:
1. Specification — §14 Produced-by column + §16 deployment obligations — the fields are mandatory but their values come from the stable snapshot facility, the anti-rollback anchor, and the local policy bundle.
2. Conformance Tests — the evidence oracles (OR-12/OR-13) assert presence and non-emptiness, not specific values.
3. Semantic Index — EV-002/EV-004/EV-005 prose defines meaning, not concrete values.
4. Coverage Matrix — EV rows map to §5/§9/§14/§16; values not enumerated.
5. Ambiguity Register (D4) — AR-011 keeps `policy bundle`, `policy_id`, and `V_POLICY` distinct; no values fixed.

**Resolution status**: `deployment_obligation`
**Resolution citation**: `Verified_Rehydration_Agent_README.md:85`
**Resolution text**: Digest/id values are deployment-substrate (buyer artifacts 1–3); the baseline emits representative non-empty placeholders sufficient for the presence oracles.

---

### Q7. Does rollback detection override the `S6` isolation state (an `S6` + `RollbackDetected` pair)?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md:233` — the §12 "Any state" rollback row and the `S6` terminality (PT-015) both apply to an `S6` + `RollbackDetected` pair, which no PT exercises.

**Searched in (in order, stop at first resolution)**:
1. Specification — §7 priority statement (`Verified_Rehydration_Agent_Specification.md:142`: rollback detection has blocking priority over every other restoration rule) + §12 "Any state" row (`:233`) — resolved: rollback priority is over EVERY other restoration rule, which includes `S6` terminality; the pair routes to `S5`.
2. Conformance Tests — PT-011 (rollback from a nontrivial state → `S5`) and PT-015 (`S6` stable under a non-rollback trigger) are consistent with rollback-first ordering.
3. Semantic Index — TR-005 `rollback_detected` prose maps to §12; no exception for `S6`.
4. Coverage Matrix — TR-005 maps only to §12.
5. Ambiguity Register (D4) — no AR-* entry narrows the rollback priority.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md:142`
**Resolution text**: Rollback priority is global; the baseline checks `ROLLBACK_DETECTED` first and returns `S5` from any state, including `S6`. Both `S5` and `S6` are non-restoring, so the outcome stays fail-closed.

---

## Summary

- `resolved_in_spec`: Q1, Q4, Q7
- `resolved_in_d4`: Q5
- `deployment_obligation`: Q2, Q6
- `implementation_flexibility`: Q3
- `real_residual`: none (0)
