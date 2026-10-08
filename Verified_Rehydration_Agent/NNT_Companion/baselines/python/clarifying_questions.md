# Clarifying questions — AGT-VRA-001 — python

Each block records an interpretation choice made during R5/R6 and its full 5-source
search trail before a resolution status is declared. Citation format: `<filename>:<int>`.

### Q1. Which member of {S0, S1} does the authority-release branch resolve to?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:236 — §12 gives the `S8` `authority_release` target as "S0 or S1", a disjunction the transition surface must resolve to a single result for PT-024.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 transition table + §7 ordering prose — the target is stated as the two-member disjunction "S0 or S1" at `Verified_Rehydration_Agent_Specification.md`:236; no single member is fixed.
2. Conformance Tests — PT-024 purpose/procedure/oracle + OR-20 — `Verified_Rehydration_Agent_Conformance_Tests.md`:378 and :502 fix the admissible set to {S0, S1} and admit no other, but leave the member open (Kind = Parameterized).
3. Semantic Index — `authority_release` (TR-008) and the two state terms — definitions carry no member-selection rule (structured `allowed_values` null; prose describes the transition only).
4. Coverage Matrix — TR-008 `authority_release` maps to §12 only — `Verified_Rehydration_Agent_Coverage_Matrix.md`:91 — no additional closing section.
5. Ambiguity Register (D4) — no AR-* entry constrains the member selection.

**Resolution status**: `deployment_obligation`
**Resolution citation**: `Verified_Rehydration_Agent_README.md`:91
**Resolution text**: The set {S0, S1} is spec-fixed; the concrete member is closed by the buyer's readmission authority workflow (deployment artifact #5, README "What your team must produce"; §16 "Separate readmission authority"), so it is declared as a bounded parameter envelope (PT-024) rather than derived from the pack; this run declares `S0 STARTUP_READONLY`.

### Q2. What does the transition surface do for a (state, trigger) pair not enumerated in §12?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:226 — the §12 transition model enumerates a finite set of rows; runtime could present a pair outside it.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 table + §7 + §16 — §7 states the failure-ordering rule at `Verified_Rehydration_Agent_Specification.md`:138, §16 states fail-closed at :284, and §3 bounds authority at :68; none prescribes a return mechanism.
2. Conformance Tests — every PT fixture uses an enumerated pair; no PT exercises an unmapped pair, and the Minimal Run Note names only the enumerated surface (`Verified_Rehydration_Agent_Conformance_Tests.md`:510).
3. Semantic Index — transition terms define triggers, not out-of-table behavior (structured slots + prose both silent on mechanism).
4. Coverage Matrix — transition terms map to §12 only.
5. Ambiguity Register (D4) — no AR-* entry addresses unmapped transitions.

**Resolution status**: `implementation_flexibility`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:284
**Resolution text**: The pack fixes the SEMANTICS (fail-closed for a failed critical step, §16:284; authority bounded to restore/deny/quarantine/escalate, §3:68) but not the MECHANISM; prescribing a specific return would force one paradigm's idiom. The python idiom chosen is a custom `UnmappedTransitionError` raised at the boundary (with `assert` guards), never a silent fallback.

### Q3. How is a failed critical validator signalled — exception, error code, or return value?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:284 — §16 mandates fail-closed handling for every failed critical validator but names no signalling mechanism.

**Searched in (in order, stop at first resolution)**:
1. Specification — §8 failure semantics (`:150`) and §16 (`:284`) fix the effect (DENY / QUARANTINE / ESCALATE, suppression) but not the code-level form.
2. Conformance Tests — oracles assert result states and evidence-field presence, not exception types or error codes (`Verified_Rehydration_Agent_Conformance_Tests.md`:483).
3. Semantic Index — `Validation Terms` define severities/effects, not the host-language signal.
4. Coverage Matrix — `Validation Terms` map to §4/§10/§11 only.
5. Ambiguity Register (D4) — no AR-* entry on signalling mechanism.

**Resolution status**: `implementation_flexibility`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:150
**Resolution text**: The fail-closed effect is normative; the signalling form is paradigm-idiomatic. The baseline routes failed pass-path gates to `S5 FAIL_SAFE` on the transition surface and represents deny-class outcomes with `failure_code` / `failed_validator` / `suppression_status` in the evidence bundle; boundary faults use `Exception` subclasses.

### Q4. What concrete values fill the evidence-bundle fields (digests, ids, freshness_value)?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:250 — §14 names the fields and their producers but supplies no field values; PT-016/017 need non-empty values.

**Searched in (in order, stop at first resolution)**:
1. Specification — §14 evidence contract (`:250`) + §5 output contract (`:85`) name fields and producers; no substrate values are given.
2. Conformance Tests — OR-12/OR-13 assert presence and non-emptiness only, not specific values (`Verified_Rehydration_Agent_Conformance_Tests.md`:494).
3. Semantic Index — EV-* terms define meaning; structured `allowed_values` are null and the `definition_operational` prose fixes no literal value (e.g. EV-012 `freshness_value` at `Verified_Rehydration_Agent_Semantic_Index.md`:1729).
4. Coverage Matrix — EV-012 maps to §14 only (`Verified_Rehydration_Agent_Coverage_Matrix.md`:71).
5. Ambiguity Register (D4) — no AR-* entry fixes field values.

**Resolution status**: `deployment_obligation`
**Resolution citation**: `Verified_Rehydration_Agent_README.md`:85
**Resolution text**: Field values originate from the five deployment artifacts (snapshot facility, anti-rollback anchor, policy bundle, single-writer plane, readmission workflow), which the pack delegates to the buyer; the oracles check presence/non-emptiness, so representative non-empty placeholders satisfy the projection surface.

### Q5. Does the restoration verdict determine `tool_activation_status` on a deny/restore path?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:261 — §14 marks `tool_activation_status` Required=Yes on every bundle, raising the question whether the verdict sets it.

**Searched in (in order, stop at first resolution)**:
1. Specification — §2 invariant at `Verified_Rehydration_Agent_Specification.md`:53 ("Tool-state remains untrusted and inactive unless a separate activation gate and required approval both succeed") and §16 precedence at :308 ("Conversational restoration does not imply or compensate for tool-state activation").
2. Conformance Tests — PT-014 keeps the tool path (`S6`) and mainline path (`S4`) distinct (`Verified_Rehydration_Agent_Conformance_Tests.md`:238); no oracle ties the field to the verdict.
3. Semantic Index — EV-008 `tool_activation_status` at `Verified_Rehydration_Agent_Semantic_Index.md`:1625 ("Separates restoration from tool-state activation"); related terms keep object/decision/path distinct.
4. Coverage Matrix — EV-008 maps to §4/§9/§14 (`Verified_Rehydration_Agent_Coverage_Matrix.md`:67).
5. Ambiguity Register (D4) — AR-006 (`:12`) keeps Tool-state, `tool_state_activation`, and Tool-state activation path distinct; AR-007 (`:13`) keeps request and verdict distinct.

**Resolution status**: `resolved_in_d4`
**Resolution citation**: `Verified_Rehydration_Agent_Ambiguity_Register.md`:12
**Resolution text**: The presupposition is ill-formed: AR-006 + AR-007 with the §2 invariant establish that the field reflects an independent tool-state trajectory, not the restoration verdict; the baseline emits `tool_activation_status = "inactive"` by default, decoupled from the transition result.

### Q6. Does the S0 non-read-only failure land in `S5 FAIL_SAFE` or `ESCALATE`?

**Triggered by**: `Verified_Rehydration_Agent_Specification.md`:228 — §12 row `S0`/`startup_complete` gives the on-failure target as "S5 or ESCALATE"; §17 lists "Startup not read-only" as ESCALATE.

**Searched in (in order, stop at first resolution)**:
1. Specification — §12 on-failure column "S5 or ESCALATE" (`:228`); §10 `V_BOOT_MODE` failure produces ESCALATE (`:186`); §11 `startup_environment` verdict ESCALATE (`:205`); §8 operator/config deficiency → ESCALATE (`:157`).
2. Conformance Tests — PT-010 expects `S5 FAIL_SAFE` (`Verified_Rehydration_Agent_Conformance_Tests.md`:182) and OR-06 fixes the result state to `S5 FAIL_SAFE` (`:488`).
3. Semantic Index — state vs verdict terms are separate categories (State Terms vs Decision Terms).
4. Coverage Matrix — `S5 FAIL_SAFE` (ST-006) maps to §12; ESCALATE (DE-013) maps to §5/§6/§8/§11 — different surfaces.
5. Ambiguity Register (D4) — AR-002/AR-003/AR-004 keep verdict labels and state labels distinct.

**Resolution status**: `resolved_in_spec`
**Resolution citation**: `Verified_Rehydration_Agent_Specification.md`:228
**Resolution text**: The two are different layers, not a contradiction: the workflow-state projection lands in `S5 FAIL_SAFE` (§12 authorizes S5 as an on-failure target; OR-06 fixes it), while the verdict/escalation layer carries ESCALATE. The transition surface returns `S5 FAIL_SAFE` for `(S0, StartupComplete, false)`.

---

**Open real-residual questions: 0.** All interpretation choices resolve within the pack's five normative sources or fall inside intentional openness — two `deployment_obligation` (buyer-side substrate), two `implementation_flexibility` (paradigm-idiomatic mechanism preserved for execution-neutrality), one `resolved_in_d4`, one `resolved_in_spec`.
