# Public Conformance Tests — Verified Rehydration Agent

*Verified Rehydration Agent*\
*Public Test Suite / Public Fixtures / Public Oracles / Minimal Run Note*

**Package:** Verified Rehydration Agent (VRA)

**Public conformance scope:** buyer-usable autosufficiency test layer only

# 1. Public Test Suite

The public suite below contains only buyer-usable tests. Tests are grouped by execution form: runnable, parameterized, and declarative external-enforcement checks.

| Public Test ID | Kind | Input surface / purpose | PASS oracle |
| --- | --- | --- | --- |
| PT-001 | Runnable | S0 STARTUP\_READONLY + StartupComplete + pass | S1 SNAPSHOT\_LOCKED |
| PT-002 | Runnable | S2 STRUCTURAL\_VERIFIED + StructuralChecksDone + pass | S3 ELIGIBLE\_HEAD\_SELECTED |
| PT-003 | Runnable | S3 ELIGIBLE\_HEAD\_SELECTED + EligibilityChecksDone + pass | S4 REHYDRATED\_VALIDATED |
| PT-004 | Runnable | Structural corruption path | S5 FAIL\_SAFE |
| PT-005 | Runnable | Canonical parse ambiguity path | S5 FAIL\_SAFE |
| PT-006 | Runnable | Hash-chain break path | S5 FAIL\_SAFE |
| PT-007 | Runnable | Invalid signature path | S5 FAIL\_SAFE |
| PT-008 | Runnable | Freshness downgrade path | S5 FAIL\_SAFE |
| PT-009 | Runnable | IRR invalid / accepted-head failure | S5 FAIL\_SAFE |
| PT-010 | Runnable | Startup not read-only | S5 FAIL\_SAFE |
| PT-011 | Runnable | Any-state rollback override | S5 FAIL\_SAFE |
| PT-012 | Runnable | Recoverable WAL ambiguity | S7 RECOVERY\_REPLAY |
| PT-013 | Runnable | Invalid tool-state schema | S6 TOOL\_QUARANTINE |
| PT-014 | Runnable | Non-inheriting restoration boundary | S6 vs S4 split preserved |
| PT-015 | Runnable | Terminal integrity of S6 | S6 remains stable |
| PT-016 | Runnable | Offline replay from evidence bundle | Closure fields present |
| PT-017 | Runnable | Mandatory evidence bundle completeness | All unconditional fields present |
| PT-018 | Runnable | Failure explanation activation | failure\_code / failed\_validator / suppression\_status present |
| PT-019 | Runnable | Recovery-phase activation | recovery\_phase present |
| PT-020 | Runnable | Readmission-token activation | readmission\_token\_id present |
| PT-021 | Runnable | Authorized non-validator producers | Producer tags preserved |
| PT-022 | Runnable | Canonical verdict fidelity | Verdict tag distinct from state tag |
| PT-023 | Runnable | Negative-outcome semantic separation | Deny / Escalate / Quarantine remain distinct |
| PT-024 | Parameterized | Authority-release branch | Result ∈ {S0, S1} |
| PT-025 | Runnable | Cross-reference derivation: freshness downgrade | freshness\_value + policy\_id + failed\_validator(V\_FRESHNESS) |
| PT-026 | Runnable | Cross-reference derivation: WAL ambiguity | recovery\_phase + producer(V\_WAL\_PHASE) |
| PT-027 | Runnable | Adequate projection granularity | S6 TOOL\_QUARANTINE directly surfaced |
| PT-028 | Declarative | V\_COMPAT bounded external enforcement | Policy-compatibility enforcement evidence required |
| PT-029 | Declarative | V\_WRITER\_LOCK distributed enforcement | Writer-lock enforcement evidence required |

## PT-001

**Kind:** Runnable

**Purpose:** Verify earliest valid passing-path progression from startup read-only into snapshot lock.

**Fixture:** WF-01

**Procedure:** Call the workflow transition surface with current\_state=S0 STARTUP\_READONLY, trigger=StartupComplete, validator\_passed=true.

**Expected result:** Return state is S1 SNAPSHOT\_LOCKED.

**Oracle linkage:** OR-01

## PT-002

**Kind:** Runnable

**Purpose:** Verify mid-path structural-success continuation.

**Fixture:** WF-02

**Procedure:** Call the workflow transition surface with current\_state=S2 STRUCTURAL\_VERIFIED, trigger=StructuralChecksDone, validator\_passed=true.

**Expected result:** Return state is S3 ELIGIBLE\_HEAD\_SELECTED.

**Oracle linkage:** OR-02

## PT-003

**Kind:** Runnable

**Purpose:** Verify package-defined success path from accepted-head eligibility to validated rehydration.

**Fixture:** WF-03

**Procedure:** Call the workflow transition surface with current\_state=S3 ELIGIBLE\_HEAD\_SELECTED, trigger=EligibilityChecksDone, validator\_passed=true.

**Expected result:** Return state is S4 REHYDRATED\_VALIDATED.

**Oracle linkage:** OR-03

## PT-004

**Kind:** Runnable

**Purpose:** Verify that framing or checksum corruption blocks restoration.

**Fixture:** WF-04

**Procedure:** Call the workflow transition surface with current\_state=S2 STRUCTURAL\_VERIFIED, trigger=StructuralChecksDone, validator\_passed=false.

**Expected result:** Return state is S5 FAIL\_SAFE.

**Oracle linkage:** OR-04

## PT-005

**Kind:** Runnable

**Purpose:** Verify that canonical parse ambiguity blocks restoration.

**Fixture:** WF-04

**Procedure:** Call the workflow transition surface with current\_state=S2 STRUCTURAL\_VERIFIED, trigger=StructuralChecksDone, validator\_passed=false.

**Expected result:** Return state is S5 FAIL\_SAFE.

**Oracle linkage:** OR-04

## PT-006

**Kind:** Runnable

**Purpose:** Verify that hash-chain break blocks restoration.

**Fixture:** WF-04

**Procedure:** Call the workflow transition surface with current\_state=S2 STRUCTURAL\_VERIFIED, trigger=StructuralChecksDone, validator\_passed=false.

**Expected result:** Return state is S5 FAIL\_SAFE.

**Oracle linkage:** OR-04

## PT-007

**Kind:** Runnable

**Purpose:** Verify that invalid signature blocks restoration.

**Fixture:** WF-04

**Procedure:** Call the workflow transition surface with current\_state=S2 STRUCTURAL\_VERIFIED, trigger=StructuralChecksDone, validator\_passed=false.

**Expected result:** Return state is S5 FAIL\_SAFE.

**Oracle linkage:** OR-04

## PT-008

**Kind:** Runnable

**Purpose:** Verify that freshness downgrade is blocked on the eligibility path.

**Fixture:** WF-05

**Procedure:** Call the workflow transition surface with current\_state=S3 ELIGIBLE\_HEAD\_SELECTED, trigger=EligibilityChecksDone, validator\_passed=false.

**Expected result:** Return state is S5 FAIL\_SAFE.

**Oracle linkage:** OR-05

## PT-009

**Kind:** Runnable

**Purpose:** Verify that IRR absence or invalid accepted-head visibility blocks restoration.

**Fixture:** WF-05

**Procedure:** Call the workflow transition surface with current\_state=S3 ELIGIBLE\_HEAD\_SELECTED, trigger=EligibilityChecksDone, validator\_passed=false.

**Expected result:** Return state is S5 FAIL\_SAFE.

**Oracle linkage:** OR-05

## PT-010

**Kind:** Runnable

**Purpose:** Verify that non-read-only startup blocks restoration.

**Fixture:** WF-06

**Procedure:** Call the workflow transition surface with current\_state=S0 STARTUP\_READONLY, trigger=StartupComplete, validator\_passed=false.

**Expected result:** Return state is S5 FAIL\_SAFE.

**Oracle linkage:** OR-06

## PT-011

**Kind:** Runnable

**Purpose:** Verify critical rollback override from a nontrivial state.

**Fixture:** WF-07

**Procedure:** Call the workflow transition surface with current\_state=S3 ELIGIBLE\_HEAD\_SELECTED, trigger=RollbackDetected, validator\_passed=true.

**Expected result:** Return state is S5 FAIL\_SAFE.

**Oracle linkage:** OR-07

## PT-012

**Kind:** Runnable

**Purpose:** Verify recoverable WAL ambiguity enters bounded recovery instead of premature release.

**Fixture:** WF-08

**Procedure:** Call the workflow transition surface with current\_state=S5 FAIL\_SAFE, trigger=WalReplayNeeded, validator\_passed=true.

**Expected result:** Return state is S7 RECOVERY\_REPLAY.

**Oracle linkage:** OR-08

## PT-013

**Kind:** Runnable

**Purpose:** Verify invalid tool-state schema routes to tool quarantine.

**Fixture:** WF-09

**Procedure:** Call the workflow transition surface with current\_state=S3 ELIGIBLE\_HEAD\_SELECTED, trigger=ToolStateInvalid, validator\_passed=true.

**Expected result:** Return state is S6 TOOL\_QUARANTINE.

**Oracle linkage:** OR-09

## PT-014

**Kind:** Runnable

**Purpose:** Verify non-inheriting boundary behavior: invalid tool-state remains isolated while mainline eligibility can still pass.

**Fixture:** WF-10

**Procedure:** Run two calls: (a) current\_state=S3, trigger=ToolStateInvalid, validator\_passed=true; (b) current\_state=S3, trigger=EligibilityChecksDone, validator\_passed=true.

**Expected result:** First result is S6 TOOL\_QUARANTINE; second result is S4 REHYDRATED\_VALIDATED; the two results are not equal.

**Oracle linkage:** OR-10

## PT-015

**Kind:** Runnable

**Purpose:** Verify terminal/stable behavior of the isolation state on the exposed projection surface.

**Fixture:** WF-11

**Procedure:** Call the workflow transition surface with current\_state=S6 TOOL\_QUARANTINE, trigger=StartupComplete, validator\_passed=true.

**Expected result:** Return state remains S6 TOOL\_QUARANTINE.

**Oracle linkage:** OR-11

## PT-016

**Kind:** Runnable

**Purpose:** Verify that a representative verdict evidence bundle supports offline replay of the decision basis.

**Fixture:** EB-01

**Procedure:** Evaluate the representative deny-path evidence bundle for closure fields.

**Expected result:** validator\_bundle\_id, verified\_head\_digest, and snapshot\_id are present and non-empty.

**Oracle linkage:** OR-12

## PT-017

**Kind:** Runnable

**Purpose:** Verify completeness of the mandatory principal evidence bundle.

**Fixture:** EB-02

**Procedure:** Evaluate the representative deny-path evidence bundle using the freshness-downgrade class.

**Expected result:** validator\_bundle\_id, verified\_head\_digest, snapshot\_id, policy\_id, source\_id, freshness\_value, irr\_digest, and tool\_activation\_status are all present and non-empty.

**Oracle linkage:** OR-13

## PT-018

**Kind:** Runnable

**Purpose:** Verify activation of conditional failure explanation fields.

**Fixture:** EB-03

**Procedure:** Evaluate the representative deny-path evidence bundle using a blocking parse failure.

**Expected result:** failure\_code, failed\_validator, and suppression\_status are present.

**Oracle linkage:** OR-14

## PT-019

**Kind:** Runnable

**Purpose:** Verify activation of the recovery-phase evidence field.

**Fixture:** EB-05

**Procedure:** Evaluate the representative recovery evidence bundle.

**Expected result:** recovery\_phase and recovery\_phase\_producer are present.

**Oracle linkage:** OR-15

## PT-020

**Kind:** Runnable

**Purpose:** Verify activation of the readmission token evidence field.

**Fixture:** EB-06

**Procedure:** Evaluate the representative readmission evidence bundle.

**Expected result:** readmission\_token\_id is present.

**Oracle linkage:** OR-16

## PT-021

**Kind:** Runnable

**Purpose:** Verify that explicitly authorized non-validator producers are accepted as valid producers.

**Fixture:** EB-04

**Procedure:** Evaluate the representative deny-path bundle for producer tags.

**Expected result:** validator\_bundle\_id\_producer = ExecutionLayer; failure\_explanation\_producer = GateLogic; tool\_activation\_status\_producer = ToolGate.

**Oracle linkage:** OR-17

## PT-022

**Kind:** Runnable

**Purpose:** Verify that canonical verdict vocabulary remains distinct from workflow-state labels.

**Fixture:** VT-01

**Procedure:** Compare the verdict tag for QUARANTINE with the workflow-state tag for S6 TOOL\_QUARANTINE.

**Expected result:** The tags are distinct and non-collapsed.

**Oracle linkage:** OR-18

## PT-023

**Kind:** Runnable

**Purpose:** Verify that distinct negative outcomes remain semantically distinct.

**Fixture:** VT-02

**Procedure:** Compare the discriminants for DENY, ESCALATE, and QUARANTINE.

**Expected result:** All three are pairwise distinct.

**Oracle linkage:** OR-19

## PT-024

**Kind:** Parameterized

**Purpose:** Verify bounded delegated authority-release branch handling.

**Fixture:** WF-12

**Procedure:** Call the workflow transition surface with current\_state=S8 READMISSION\_PENDING, trigger=AuthorityRelease, validator\_passed=true.

**Expected result:** Return state is either S0 STARTUP\_READONLY or S1 SNAPSHOT\_LOCKED; no other result is admissible.

**Oracle linkage:** OR-20

## PT-025

**Kind:** Runnable

**Purpose:** Verify evidence-plus-scenario cross-reference for freshness downgrade.

**Fixture:** EB-02

**Procedure:** Evaluate the representative deny-path bundle for the freshness-downgrade case.

**Expected result:** freshness\_value and policy\_id are present; failed\_validator = V\_FRESHNESS.

**Oracle linkage:** OR-21

## PT-026

**Kind:** Runnable

**Purpose:** Verify evidence-plus-scenario cross-reference for WAL ambiguity.

**Fixture:** EB-05

**Procedure:** Evaluate the representative recovery bundle for the WAL ambiguity case.

**Expected result:** recovery\_phase is present; recovery\_phase\_producer = V\_WAL\_PHASE.

**Oracle linkage:** OR-22

## PT-027

**Kind:** Runnable

**Purpose:** Verify that the current projection surface is adequate for direct testing of tool-state quarantine routing.

**Fixture:** WF-09

**Procedure:** Call the workflow transition surface with current\_state=S3 ELIGIBLE\_HEAD\_SELECTED, trigger=ToolStateInvalid, validator\_passed=true.

**Expected result:** Return state is S6 TOOL\_QUARANTINE.

**Oracle linkage:** OR-09

## PT-028

**Kind:** Declarative

**Purpose:** Verify bounded external enforcement for V\_COMPAT.

**Fixture:** DC-01

**Procedure:** Inspect the implementation’s policy-compatibility enforcement surface.

**Expected result:** The implementation provides a policy-compatibility enforcement point for import\_admissibility and records compatibility evidence.

**Oracle linkage:** OR-23

## PT-029

**Kind:** Declarative

**Purpose:** Verify bounded external enforcement for V\_WRITER\_LOCK.

**Fixture:** DC-02

**Procedure:** Inspect the implementation’s persistence control / deployment conformance surface.

**Expected result:** The implementation enforces single-writer discipline and emits writer-lock / contention evidence without semantic drift.

**Oracle linkage:** OR-24

# 2. Public Fixtures

| Fixture ID | Fixture class | Minimum contents | Used by |
| --- | --- | --- | --- |
| WF-01 | Workflow fixture | current\_state=S0 STARTUP\_READONLY; trigger=StartupComplete; validator\_passed=true | PT-001 |
| WF-02 | Workflow fixture | current\_state=S2 STRUCTURAL\_VERIFIED; trigger=StructuralChecksDone; validator\_passed=true | PT-002 |
| WF-03 | Workflow fixture | current\_state=S3 ELIGIBLE\_HEAD\_SELECTED; trigger=EligibilityChecksDone; validator\_passed=true | PT-003 |
| WF-04 | Workflow fixture | current\_state=S2 STRUCTURAL\_VERIFIED; trigger=StructuralChecksDone; validator\_passed=false | PT-004..PT-007 |
| WF-05 | Workflow fixture | current\_state=S3 ELIGIBLE\_HEAD\_SELECTED; trigger=EligibilityChecksDone; validator\_passed=false | PT-008..PT-009 |
| WF-06 | Workflow fixture | current\_state=S0 STARTUP\_READONLY; trigger=StartupComplete; validator\_passed=false | PT-010 |
| WF-07 | Workflow fixture | current\_state=S3 ELIGIBLE\_HEAD\_SELECTED; trigger=RollbackDetected; validator\_passed=true | PT-011 |
| WF-08 | Workflow fixture | current\_state=S5 FAIL\_SAFE; trigger=WalReplayNeeded; validator\_passed=true | PT-012 |
| WF-09 | Workflow fixture | current\_state=S3 ELIGIBLE\_HEAD\_SELECTED; trigger=ToolStateInvalid; validator\_passed=true | PT-013, PT-027 |
| WF-10 | Composite workflow fixture | (a) WF-09 and (b) WF-03 executed as a paired comparison | PT-014 |
| WF-11 | Workflow fixture | current\_state=S6 TOOL\_QUARANTINE; trigger=StartupComplete; validator\_passed=true | PT-015 |
| WF-12 | Parameterized workflow fixture | current\_state=S8 READMISSION\_PENDING; trigger=AuthorityRelease; validator\_passed=true | PT-024 |
| EB-01 | Evidence bundle fixture | Representative DENY-path bundle using V\_CHAIN | PT-016 |
| EB-02 | Evidence bundle fixture | Representative DENY-path bundle using V\_FRESHNESS | PT-017, PT-025 |
| EB-03 | Evidence bundle fixture | Representative DENY-path bundle using V\_PARSE | PT-018 |
| EB-04 | Evidence bundle fixture | Representative DENY-path bundle using V\_FRAME for producer-tag assertions | PT-021 |
| EB-05 | Evidence bundle fixture | Representative recovery bundle | PT-019, PT-026 |
| EB-06 | Evidence bundle fixture | Representative readmission bundle | PT-020 |
| VT-01 | Vocabulary fixture | NormativeVerdict::Quarantine compared against WorkflowState::S6ToolQuarantine | PT-022 |
| VT-02 | Vocabulary fixture | NormativeVerdict discriminants for Deny, Escalate, and Quarantine | PT-023 |
| DC-01 | Declarative conformance fixture | Implementation evidence for V\_COMPAT in import\_admissibility / policy subsystem | PT-028 |
| DC-02 | Declarative conformance fixture | Implementation evidence for V\_WRITER\_LOCK in persistence control / deployment subsystem | PT-029 |

# 3. Public Oracles

| Oracle ID | Oracle class | Applies to | PASS condition |
| --- | --- | --- | --- |
| OR-01 | Workflow oracle | PT-001 | Result state = S1 SNAPSHOT\_LOCKED |
| OR-02 | Workflow oracle | PT-002 | Result state = S3 ELIGIBLE\_HEAD\_SELECTED |
| OR-03 | Workflow oracle | PT-003 | Result state = S4 REHYDRATED\_VALIDATED |
| OR-04 | Workflow oracle | PT-004..PT-007 | Result state = S5 FAIL\_SAFE |
| OR-05 | Workflow oracle | PT-008..PT-009 | Result state = S5 FAIL\_SAFE |
| OR-06 | Workflow oracle | PT-010 | Result state = S5 FAIL\_SAFE |
| OR-07 | Workflow oracle | PT-011 | Result state = S5 FAIL\_SAFE |
| OR-08 | Workflow oracle | PT-012 | Result state = S7 RECOVERY\_REPLAY |
| OR-09 | Workflow oracle | PT-013, PT-027 | Result state = S6 TOOL\_QUARANTINE |
| OR-10 | Split-boundary oracle | PT-014 | Invalid tool-state path ends in S6; mainline eligibility path ends in S4; results remain distinct |
| OR-11 | Terminality oracle | PT-015 | S6 remains stable / terminal on the exposed projection surface |
| OR-12 | Evidence oracle | PT-016 | validator\_bundle\_id, verified\_head\_digest, snapshot\_id all present and non-empty |
| OR-13 | Evidence oracle | PT-017 | validator\_bundle\_id, verified\_head\_digest, snapshot\_id, policy\_id, source\_id, freshness\_value, irr\_digest, tool\_activation\_status all present and non-empty |
| OR-14 | Evidence oracle | PT-018 | failure\_code, failed\_validator, suppression\_status all present |
| OR-15 | Evidence oracle | PT-019 | recovery\_phase and recovery\_phase\_producer present |
| OR-16 | Evidence oracle | PT-020 | readmission\_token\_id present |
| OR-17 | Producer oracle | PT-021 | validator\_bundle\_id\_producer=ExecutionLayer; failure\_explanation\_producer=GateLogic; tool\_activation\_status\_producer=ToolGate |
| OR-18 | Taxonomy oracle | PT-022 | Canonical verdict tag remains distinct from workflow-state tag |
| OR-19 | Taxonomy oracle | PT-023 | Deny, Escalate, and Quarantine remain pairwise distinct |
| OR-20 | Parameterized oracle | PT-024 | Result ∈ {S0 STARTUP\_READONLY, S1 SNAPSHOT\_LOCKED} |
| OR-21 | Cross-reference oracle | PT-025 | freshness\_value and policy\_id present; failed\_validator = V\_FRESHNESS |
| OR-22 | Cross-reference oracle | PT-026 | recovery\_phase present; recovery\_phase\_producer = V\_WAL\_PHASE |
| OR-23 | Declarative oracle | PT-028 | Implementation proves bounded policy-compatibility enforcement and preserves compatibility evidence |
| OR-24 | Declarative oracle | PT-029 | Implementation proves single-writer enforcement and emits writer\_lock / contention evidence |

# 4. Minimal Run Note

Required projection surface: the implementation shall expose a workflow transition surface equivalent to next\_state(current\_state, trigger, validator\_passed) for the workflow tests, and an evidence surface capable of emitting the principal bundle fields and producer tags asserted by the evidence tests.

Required input types: workflow state, transition trigger, boolean validator gate outcome for runnable workflow tests; representative deny, recovery, and readmission evidence bundles for evidence tests; bounded external enforcement attestations for V\_COMPAT and V\_WRITER\_LOCK declarative checks.

Required assertion result types: workflow state equality; workflow-state membership for the bounded authority-release branch; field-presence assertions; producer-tag assertions; verdict-taxonomy distinction assertions; declarative compliance proof for bounded external enforcement.

Suite PASS condition: every runnable test passes, the parameterized authority-release branch lands only in the permitted state set, and both declarative bounded external-enforcement checks are satisfied by implementation evidence.

Bounded external obligations not locally runnable: V\_COMPAT remains bounded in import\_admissibility / policy compatibility enforcement; V\_WRITER\_LOCK remains bounded in the persistence control plane / deployment conformance layer. These two obligations must be proved by architecture evidence rather than by the local workflow transition surface alone.
