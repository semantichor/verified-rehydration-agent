Verified Rehydration Agent

## Public Library Specification

Public release v1 • English-only • Operationally complete and standalone

Purpose\
This specification defines the normative boundary and decision logic for controlled rehydration of persistent context. Restoration is permitted only after complete verification.

Core safety model\
On any blocking failure, the agent denies restoration, suppresses persistent-state injection, or quarantines the relevant artefacts until the required closure conditions are met.

Implementation posture\
The document is buyer-facing and self-contained. It preserves decision semantics, validator semantics, failure semantics, gate logic, evidence requirements, workflow ordering, and machine-readable forms.

# 1. Scope and Key Terms

This specification governs the boundary between candidate persistent artefacts and runtime context eligible for restoration. The document is normative. It defines verdict semantics, validators, workflow ordering, state transitions, gates, evidence requirements, machine-readable forms, deployment obligations, and conformance scenarios.

## Key terms

| Term | Meaning |
| --- | --- |
| IRR | Reception log used to prove valid intake and to anchor which head is visible and eligible for restoration. |
| Head | The candidate top record or state boundary considered for restoration. |
| Accepted head | The head made eligible by a valid IRR entry and the visibility rule. |
| Tool-state | Persisted capability or tool configuration state; it is handled separately from conversational or contextual restoration. |
| Fail-safe suppression | Mandatory prevention of persistent-state injection after a blocking failure. |
| Readmission | Controlled exit from fail-safe after recovery obligations are satisfied and the required authority approves release. |

# 2. Agent Overview

| Field | Value |
| --- | --- |
| Document type | Public Library Specification |
| Agent ID | AGT-VRA-001 |
| Canonical name | Verified Rehydration Agent |
| Class | Critical normative agent |
| Role | Allows restoration only after complete verification; otherwise blocks, suppresses, or isolates persistent context. |
| Scope boundary | The boundary between candidate persistent artefacts and runtime context eligible for restoration. |
| Decision objects | restoration\_request; import\_admissibility; verified\_head\_selection; tool\_state\_activation; fail\_safe\_release; readmission\_request |
| Primary inputs | append-only ledger; write-ahead log (WAL); IRR (reception log); policy bundle; tool-state manifest; startup mount state |
| Primary outputs | restoration\_verdict; suppression action; quarantine action; validated\_context; operator-visible error; readmission token |

## Core invariants

• No restoration is permitted before the full verification sequence completes successfully.

• Any failure in framing, checksum, canonical parse, hash-chain continuity, signature validation, freshness, policy validation, or IRR validity triggers fail-safe handling and suppresses persistent-context injection.

• Restored persistent state may originate only from the verified and eligible head.

• Tool-state remains untrusted and inactive unless a separate activation gate and required approval both succeed.

• Startup remains read-only until the restoration decision is reached.

• Recovery is idempotent and must not produce duplicate effects or duplicate acceptance.

• Replay must begin from a deterministic baseline defined by the verified snapshot and applicable local policy.

# 3. Authority Model

| Field | Value |
| --- | --- |
| Authority source | The criteria and rules defined in this specification, together with local receiver policy and required structural and cryptographic validation. |
| Delegated scope | Decide restoration eligibility; suppress, quarantine, or controlled-release persistent context; emit explicit failure reasons and an independently verifiable evidence bundle. |
| Non-authority zones | Does not approve source semantic content; does not activate tool-state without a separate gate; does not relax policy; does not perform persistent writes during startup verification. |
| Authority budget | Strictly bounded to restore / deny / quarantine / escalate. |
| Escalation path | Operator recovery flow, policy authority, or dual-control readmission where deployed. |
| Authority exhaustion conditions | Any failed critical validator; ordering inconsistency; invalid IRR; policy incompatibility; freshness failure; rollback detection; untrustworthy environment; unresolved writer-lock contention. |

# 4. Input Contract

| Input artefact or signal | Preconditions | Required validators | Evidence fields | Effect on failure |
| --- | --- | --- | --- | --- |
| Append-only ledger | Stable descriptor, read-only access, localizable boundary | V\_FRAME, V\_CHECKSUM, V\_PARSE, V\_CHAIN | frame\_status, checksum\_status, chain\_status | DENY + fail\_safe |
| WAL / phase markers | Coherent phase markers and permissible recovery replay | V\_WAL\_PHASE, V\_COUNTER\_CONT | recovery\_phase, realized\_counter | QUARANTINE / controlled recovery |
| IRR / reception log | Valid IRR and visible accepted head | V\_IRR, V\_VISIBILITY | irr\_digest, accepted\_head\_digest | DENY |
| Policy bundle | Authorized policy\_id and local compatibility | V\_POLICY, V\_COMPAT | policy\_id, compat\_status | DENY |
| Tool-state manifest | Valid schema and policy-conformant allow-list | V\_TOOL\_SCHEMA, V\_TOOL\_ALLOWLIST | tool\_manifest\_digest, tool\_activation\_status | tool\_quarantine |
| Startup mount state | Read-only active before verification begins | V\_BOOT\_MODE | mount\_mode, startup\_epoch | ESCALATE |

# 5. Output Contract

| Output artefact or action | Emission condition | Minimum content | Consumer | Operational note |
| --- | --- | --- | --- | --- |
| restoration\_verdict = ALLOW | All critical validators PASS | verified\_head\_digest, policy\_id, snapshot\_id, validator\_bundle\_id | Execution layer | Release of validated\_context |
| restoration\_verdict = DENY | Any critical validator FAILS | failure\_code, failed\_validator, suppression\_status | Operator / gate | Operator-visible blocking error |
| quarantine\_context | Recoverable failure or restricted tool-state | quarantine\_scope, recovery\_requirements | Recovery flow | Controlled isolation pending closure |
| validated\_context | ALLOW and complete replay from the verified head | context\_digest, source\_head\_digest, replay\_range | Execution layer | Validated context handoff |
| operator-visible error | DENY or ESCALATE | error\_class, evidence\_ref | Operator | Blocking or escalation signal |
| readmission\_token | Only after authorized recovery | token\_id, prerequisites\_satisfied | Policy authority | Readmission gate evidence |

# 6. Verdict Semantics

The normative verdicts are ALLOW, DENY, QUARANTINE, ESCALATE, and READMISSION\_PENDING.

ALLOW means restoration may be executed only from the verified head and only for the context declared eligible.

DENY means no persistent state is injected.

QUARANTINE means artefacts or state portions remain isolated and non-executable.

ESCALATE means operator or policy-authority intervention is required.

READMISSION\_PENDING means a fail-safe state has not yet been closed through the required readmission conditions.

Verdict semantics are constitutive for conformance. A conformant implementation must not downgrade DENY, QUARANTINE, or ESCALATE into non-blocking warnings and must not extend ALLOW beyond the declared eligible context.

# 7. Ordering and Verification Sequence

Verification and release follow the sequence below. The order is normative.

1\. Mount read-only.

2\. Lock a stable snapshot.

3\. Verify framing.

4\. Verify checksum.

5\. Perform canonical parse.

6\. Verify hash-chain continuity.

7\. Verify signatures.

8\. Verify freshness, IRR, and visibility.

9\. Verify policy compatibility.

10\. Select the verified head.

11\. Replay verified records.

12\. Emit the verdict.

No later step may execute if a prior critical step has failed.

Replay uses only the same snapshot context in which the head was validated.

Rollback detection has blocking priority over every other restoration rule.

During recovery, WAL phase ordering prevails over speculative reconstruction.

Durable IRR precedes any readmission of imported context; an unanchored tail remains ineligible even if local integrity can be reconstructed.

# 8. Failure Semantics

| Failure class | Semantic effect | Mandatory action |
| --- | --- | --- |
| Structural verification failure | State remains non-restorable | DENY + fail\_safe |
| Continuity or anti-rollback failure | Candidate head is invalidated | DENY + QUARANTINE + ESCALATE |
| Policy, freshness, or IRR failure | Restoration is ineligible | DENY |
| Tool-state restriction failure | Conversation restoration may continue only if an independent valid path exists | tool\_quarantine |
| Recovery ambiguity | No release until convergence is proven | QUARANTINE |
| Operator or configuration deficiency | Verification environment is not trustworthy | ESCALATE |

# 9. Observability Requirements

Each requirement below defines information that must remain observable so the restoration decision can be reconstructed and operational handling can remain controlled.

| ID | What must be observable | Evidence field | Emission point | Consumer | Failure if absent |
| --- | --- | --- | --- | --- | --- |
| OBS-01 | Result of every critical validator | validator\_bundle\_id | Verdict emission | Auditor / execution layer | Offline verdict reconstruction is not possible |
| OBS-02 | Verified and eligible head | verified\_head\_digest, accepted\_head\_digest | Release gate | Execution layer | Accepted-head-only proof is missing |
| OBS-03 | Explicit reasons for DENY or ESCALATE | failure\_code, failed\_validator | Block / escalation gate | Operator | Blocking decisions are insufficiently explainable |
| OBS-04 | Tool-state activation status | tool\_activation\_status | Tool gate | Operator / policy authority | Boundary between restore and activation is not observable |
| OBS-05 | Recovery phase and convergence state | recovery\_phase, realized\_counter | Recovery path | Policy authority | Readmission control is not supported |
| OBS-06 | Writer-lock status and contention state | writer\_lock\_status, contention\_status | Persistence control plane | Execution owner / auditor | Single-writer enforcement is not provable |

# 10. Validator Catalogue

| Validator ID | Description | Severity | Failure produces | Minimum evidence |
| --- | --- | --- | --- | --- |
| V\_FRAME | Verifies record framing structure and boundaries | critical | DENY | frame\_status, frame\_offset |
| V\_CHECKSUM | Verifies frame checksum | critical | DENY | checksum\_status |
| V\_PARSE | Verifies unambiguous canonical parsing | critical | DENY | parse\_status, canonical\_form\_id |
| V\_CHAIN | Verifies hash-chain continuity | critical | DENY | prior\_digest, current\_digest, chain\_status |
| V\_SIG | Verifies signatures and the permitted cryptographic profile | critical | DENY | key\_id, sig\_status, alg\_profile |
| V\_FRESHNESS | Verifies strict increase against the local watermark | critical | DENY | source\_id, accepted\_freshness, candidate\_freshness |
| V\_POLICY | Verifies policy\_id and local policy compatibility | critical | DENY | policy\_id, compat\_status |
| V\_COMPAT | Verifies deployment-policy compatibility | critical | DENY | deployment\_profile, compat\_status |
| V\_IRR | Verifies IRR existence and validity | critical | DENY | irr\_digest, irr\_status |
| V\_VISIBILITY | Selects only the accepted and visible head | critical | DENY | accepted\_head\_digest |
| V\_BOOT\_MODE | Verifies startup remount as read-only | critical | ESCALATE | mount\_mode |
| V\_SNAPSHOT | Verifies binding to a stable snapshot | critical | DENY | snapshot\_id, fd\_binding\_digest |
| V\_WAL\_PHASE | Verifies coherence of PREPARE / ANCHOR / APPEND / COMMIT markers | high | QUARANTINE | wal\_phase |
| V\_COUNTER\_CONT | Verifies counter monotonicity and continuity | critical | DENY | counter\_value, anchor\_digest |
| V\_TOOL\_SCHEMA | Verifies tool-state schema | medium | tool\_quarantine | tool\_schema\_status |
| V\_TOOL\_ALLOWLIST | Verifies the allow-list and capability ceiling | medium | tool\_quarantine | tool\_id, allow\_status |
| V\_WRITER\_LOCK | Verifies single-writer discipline | high | ESCALATE | writer\_lock\_status, contention\_status |
| V\_ANCHOR | Verifies the anti-rollback anchor | critical | DENY | anchor\_status |

# 11. Decision Logic

| Decision object | Conditions | Verdict | Gate impact | Required evidence | Notes |
| --- | --- | --- | --- | --- | --- |
| restoration\_request | All critical validators PASS | ALLOW | Release validated\_context | validator\_bundle\_id, verified\_head\_digest | Principal rule |
| restoration\_request | Any of V\_FRAME/V\_CHECKSUM/V\_PARSE/V\_CHAIN/V\_SIG FAILS | DENY | No injection | failure\_code, failed\_validator | Hard fail |
| import\_admissibility | Freshness not strictly greater or policy incompatible | DENY | No new acceptance and no restore | source\_id, policy evidence | Downgrade blocked |
| verified\_head\_selection | IRR invalid or visibility unsatisfied | DENY | Tail remains ineligible | irr\_status, visibility evidence | Accepted head only |
| tool\_state\_activation | Tool schema invalid, allow-list unsatisfied, or approval absent | QUARANTINE | Tool remains inactive | tool evidence | Conversation path may remain independent |
| recovery\_replay | WAL phase ambiguous but recoverable | QUARANTINE | No release before convergence | wal evidence | Recovery controlled |
| startup\_environment | Boot mode not read-only or snapshot unstable | ESCALATE | Verification environment blocked | boot evidence | Operator action required |
| readmission\_request | All recovery obligations satisfied and authority approves | READMISSION\_PENDING -> ALLOW | Exit fail-safe | readmission token bundle | Separate gate |

# 12. Workflow and State Transitions

## State model

| State | Meaning | Exit condition |
| --- | --- | --- |
| S0 STARTUP\_READONLY | Storage remounted read-only; no restore permitted | Snapshot locked |
| S1 SNAPSHOT\_LOCKED | Stable verification context established | Structural validation finished |
| S2 STRUCTURAL\_VERIFIED | Framing, checksum, parse, chain, and signature validation succeeded | Policy, freshness, IRR, and visibility verified |
| S3 ELIGIBLE\_HEAD\_SELECTED | Accepted visible head fixed | Replay completed |
| S4 REHYDRATED\_VALIDATED | Validated context assembled | ALLOW emitted |
| S5 FAIL\_SAFE | Persistent context suppressed | Authorized recovery path starts |
| S6 TOOL\_QUARANTINE | Tool-state isolated | Separate approval or discard |
| S7 RECOVERY\_REPLAY | WAL or continuity replay in progress | Convergence proven |
| S8 READMISSION\_PENDING | Fail-safe exit under controlled authority | All obligations satisfied |

## Transition model

| From | Trigger | Guard | To | On failure |
| --- | --- | --- | --- | --- |
| S0 | startup\_complete | V\_BOOT\_MODE PASS | S1 | S5 or ESCALATE |
| S1 | snapshot\_locked | V\_SNAPSHOT PASS | S2 | S5 |
| S2 | structural\_checks\_done | V\_FRAME..V\_SIG PASS | S3 | S5 |
| S3 | eligibility\_checks\_done | V\_FRESHNESS + V\_POLICY + V\_IRR + V\_VISIBILITY PASS | S4 | S5 |
| S3 | tool-state invalid | Tool restrictions failed | S6 | Remain isolated |
| Any state | rollback\_detected | V\_ANCHOR or V\_COUNTER\_CONT FAIL | S5 | QUARANTINE + ESCALATE |
| Recovery path | wal\_replay\_needed | V\_WAL\_PHASE indicates recovery | S7 | S5 |
| S7 | recovery\_converged | No duplicate effects | S8 | S5 |
| S8 | authority\_release | Readmission approved | S0 or S1 | Remain blocked |

# 13. Gate Logic

| Gate | Open condition | Closed by | Effect |
| --- | --- | --- | --- |
| Release gate | All critical validators PASS and verified context is assembled | Any critical failure | Permits validated\_context handoff |
| Block gate | A critical failure is present | Recovery proof plus authority release | Suppresses restore |
| Quarantine gate | Recoverable ambiguity or restricted tool-state | Separate closure conditions | Isolates partial artefacts |
| Escalation gate | Environment, policy, or authority deficiency | Operator or policy-authority action | Halts autonomous progress |
| Readmission gate | Fail-safe was previously entered and the closure bundle is complete | Any missing obligation | Controls exit from fail-safe |

# 14. Evidence Contract

Every relevant decision produces a minimum evidence bundle that is independently verifiable. The minimum bundle for the principal verdict contains validator\_bundle\_id, verified\_head\_digest, snapshot\_id, policy\_id, source\_id, freshness\_value, irr\_digest, failed\_validator (if any), failure\_code, suppression\_status, tool\_activation\_status, recovery\_phase, and readmission\_token\_id (if any).

| Evidence field | Meaning | Produced by | Required |
| --- | --- | --- | --- |
| verified\_head\_digest | Eligible head for replay | V\_CHAIN / V\_VISIBILITY | Yes |
| snapshot\_id | Identifies the verification-time snapshot context | V\_SNAPSHOT | Yes |
| validator\_bundle\_id | Binds the results of all validators | Execution layer | Yes |
| policy\_id | Identifies the locally applied policy | V\_POLICY | Yes |
| source\_id + freshness\_value | Tracks source freshness | V\_FRESHNESS | Yes |
| irr\_digest | Links the decision to valid reception | V\_IRR | Yes |
| failure\_code + failed\_validator | Explains denial or escalation | Gate logic | Conditional |
| tool\_activation\_status | Separates restoration from tool-state activation | Tool gate | Yes |
| recovery\_phase | Shows recovery convergence state | V\_WAL\_PHASE | Conditional |
| writer\_lock\_status | Shows single-writer enforcement at relevant control points | V\_WRITER\_LOCK | Conditional |

# 15. Machine-Readable Forms

| Form ID | Purpose | Canonical fields |
| --- | --- | --- |
| MRF-RESTORE-REQ | Restoration request | request\_id, source\_id, requested\_head, policy\_profile |
| MRF-VALIDATOR-BUNDLE | Validator results | validator\_id, status, evidence\_ref, timestamp\_or\_counter |
| MRF-RESTORE-VERDICT | Final verdict | verdict, verified\_head\_digest, snapshot\_id, failure\_code |
| MRF-TOOL-QUARANTINE | Tool-state isolation | tool\_id, schema\_status, allow\_status, quarantine\_scope |
| MRF-READMISSION | Exit from fail-safe | token\_id, approver\_set, satisfied\_obligations |
| MRF-VALIDATION-LOG | Auditable record of validation execution | validation\_run\_id, test\_id, axis, status, evidence\_ref, reviewer |

# 16. Conformance Requirements and Deployment Obligations

## Conformance requirements

• The agent must not inject unverified persistent state.

• The agent must detect and block rollback, downgrade, and unaccepted heads.

• The agent must preserve fail-closed semantics for every failed critical validator.

• The agent must support replay and offline reconstruction of the restoration verdict from evidence.

• The agent must preserve the structural separation between conversational restoration and tool-state activation.

## Deployment obligations

| Deployment requirement | Obligation | Failure impact if unmet |
| --- | --- | --- |
| Stable snapshot availability | The execution platform must provide a stable snapshot lock or a deterministic equivalent. | Replay sufficiency is compromised. |
| Anti-rollback mechanism | The implementation must anchor continuity to a non-regressing counter or equivalent anchor. | Rollback can no longer be provably blocked. |
| Local policy bundle | The deployment must bind policy\_id and compatibility checks to a local, versioned policy bundle. | Policy closure is compromised. |
| Single-writer enforcement | The execution layer must serialize persistent-state mutation paths and emit writer-lock evidence. | Determinism is compromised. |
| Separate readmission authority | The deployment must define approver\_set and a recovery workflow for readmission. | Fail-safe exit is not trustworthy. |

## Precedence rules

• A failed critical validator prevails over operational utility considerations.

• The accepted-head-only rule prevails over any local continuity of an unanchored tail.

• Local policy prevails over source-asserted provenance or source-asserted policy.

• Conversational restoration does not imply or compensate for tool-state activation.

• Implementation variation in hardware anchoring or writer-lock evidence is permitted only if the semantic requirement remains unchanged and the required evidence remains observable.

# 17. Public Conformance Scenarios

| Scenario | Expected result | Required evidence | Pass criterion |
| --- | --- | --- | --- |
| Framing or checksum corruption | DENY; no injection | failure\_code, validator\_bundle\_id | Negative path is closed |
| Canonical parse ambiguity | DENY; fail\_safe | parse\_status, suppression\_status | No partial restore occurs |
| Hash-chain break | DENY; accepted head invalid | chain\_status, failed\_validator | Continuity blocks restore |
| Invalid signature | DENY | sig\_status | Authenticity gate is enforced |
| Freshness downgrade | DENY; no IRR-visible restore | freshness\_value, policy evidence | Downgrade is blocked |
| IRR absent or invalid | DENY; restoration remains ineligible | irr\_status | Accepted-head rule is enforced |
| Startup not read-only | ESCALATE; no restore | mount\_mode | Environment deficiency is observable |
| Recovery with WAL ambiguity | QUARANTINE until convergence | recovery\_phase | No premature release occurs |
| Invalid tool-state schema | tool\_quarantine; conversation path may remain independent | tool\_activation\_status | Boundary split is preserved |
| Offline replay from evidence bundle | Same verdict reconstructed | validator\_bundle\_id, snapshot\_id | Offline reconstruction succeeds |
| Single-writer contention | ESCALATE or controlled block without semantic drift | writer\_lock\_status, contention\_status | Single-writer discipline is observable |

# 18. Optional Features

| Element | Status | Effect if absent |
| --- | --- | --- |
| Tool-state activation path | Optional / separate gate | Conversational restoration may remain valid; tool-state stays inactive. |
| Dual-control readmission | Policy-dependent but recommended | Without it, the readmission rule must be explicitly narrowed. |
| Semantic continuity score | Optional supplementary control | It may not substitute for mandatory validators. |
| Auxiliary indices | Optional performance-only control | They do not affect acceptance or restoration. |

# 19. Reuse Note

This specification may be reused as a normative boundary for any system that requires controlled rehydration of persistent context. Reuse is permitted only if the implementation preserves identical verdict semantics, the accepted-head-only rule, fail-closed handling for all critical validators, the separation of tool-state activation from conversational restoration, sufficient evidence for replay and offline verdict reconstruction, and the required observability surfaces. Reuse is not permitted through relaxation of critical validators or by downgrading DENY, QUARANTINE, or ESCALATE into non-blocking warnings.

A conformant implementation must preserve the same decision semantics, validator semantics, failure semantics, contract semantics, and authority boundaries defined in this specification.
