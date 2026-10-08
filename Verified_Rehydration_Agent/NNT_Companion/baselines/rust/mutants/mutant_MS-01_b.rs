// Verified Rehydration Agent (AGT-VRA-001) — rust baseline.
//
// Ad-litteram transcription of the buyer-facing specification's agent-logic
// surface into idiomatic rust. Derived solely from
// Verified_Rehydration_Agent_Specification.md and its indices (D1..D4) and the
// Conformance Tests Minimal Run Note projection surface.
//
// Projection surface (Conformance Tests §4): next_state(current_state, trigger,
// validator_passed) plus an evidence surface emitting principal-bundle fields
// and producer tags.
//
// Section anchors used below map to the Specification headings:
//   §4 Input Contract, §5 Output Contract, §6 Verdict Semantics,
//   §7 Ordering, §8 Failure Semantics, §9 Observability, §10 Validator
//   Catalogue, §11 Decision Logic, §12 Workflow/State Transitions,
//   §13 Gate Logic, §14 Evidence Contract, §15 Machine-Readable Forms,
//   §16 Conformance Requirements and Deployment Obligations.

use std::env;
use std::process::exit;

// ---------------------------------------------------------------------------
// §6 Verdict Semantics — the canonical verdict vocabulary as an exhaustive enum.
// ---------------------------------------------------------------------------
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum NormativeVerdict {
    Allow,
    Deny,
    Quarantine,
    Escalate,
    ReadmissionPending,
}

impl NormativeVerdict {
    fn label(self) -> &'static str {
        match self {
            NormativeVerdict::Allow => "ALLOW",
            NormativeVerdict::Deny => "DENY",
            NormativeVerdict::Quarantine => "QUARANTINE",
            NormativeVerdict::Escalate => "ESCALATE",
            NormativeVerdict::ReadmissionPending => "READMISSION_PENDING",
        }
    }
    // Distinct discriminant tag, kept separate from workflow-state tags (AR-002,
    // AR-003; §6). Conformance Tests VT-01/VT-02 assert this separation.
    fn tag(self) -> &'static str {
        match self {
            NormativeVerdict::Allow => "NormativeVerdict::Allow",
            NormativeVerdict::Deny => "NormativeVerdict::Deny",
            NormativeVerdict::Quarantine => "NormativeVerdict::Quarantine",
            NormativeVerdict::Escalate => "NormativeVerdict::Escalate",
            NormativeVerdict::ReadmissionPending => "NormativeVerdict::ReadmissionPending",
        }
    }
    fn parse(s: &str) -> Result<NormativeVerdict, String> {
        match s.trim().to_ascii_uppercase().as_str() {
            "ALLOW" => Ok(NormativeVerdict::Allow),
            "DENY" => Ok(NormativeVerdict::Deny),
            "QUARANTINE" => Ok(NormativeVerdict::Quarantine),
            "ESCALATE" => Ok(NormativeVerdict::Escalate),
            "READMISSION_PENDING" | "READMISSIONPENDING" => Ok(NormativeVerdict::ReadmissionPending),
            other => Err(format!("unknown verdict: {other}")),
        }
    }
}

// ---------------------------------------------------------------------------
// §12 Workflow — the S0..S8 state model as an exhaustive enum.
// ---------------------------------------------------------------------------
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum WorkflowState {
    S0StartupReadonly,
    S1SnapshotLocked,
    S2StructuralVerified,
    S3EligibleHeadSelected,
    S4RehydratedValidated,
    S5FailSafe,
    S6ToolQuarantine,
    S7RecoveryReplay,
    S8ReadmissionPending,
}

impl WorkflowState {
    fn code(self) -> &'static str {
        match self {
            WorkflowState::S0StartupReadonly => "S0",
            WorkflowState::S1SnapshotLocked => "S1",
            WorkflowState::S2StructuralVerified => "S2",
            WorkflowState::S3EligibleHeadSelected => "S3",
            WorkflowState::S4RehydratedValidated => "S4",
            WorkflowState::S5FailSafe => "S5",
            WorkflowState::S6ToolQuarantine => "S6",
            WorkflowState::S7RecoveryReplay => "S7",
            WorkflowState::S8ReadmissionPending => "S8",
        }
    }
    fn label(self) -> &'static str {
        match self {
            WorkflowState::S0StartupReadonly => "S0 STARTUP_READONLY",
            WorkflowState::S1SnapshotLocked => "S1 SNAPSHOT_LOCKED",
            WorkflowState::S2StructuralVerified => "S2 STRUCTURAL_VERIFIED",
            WorkflowState::S3EligibleHeadSelected => "S3 ELIGIBLE_HEAD_SELECTED",
            WorkflowState::S4RehydratedValidated => "S4 REHYDRATED_VALIDATED",
            WorkflowState::S5FailSafe => "S5 FAIL_SAFE",
            WorkflowState::S6ToolQuarantine => "S6 TOOL_QUARANTINE",
            WorkflowState::S7RecoveryReplay => "S7 RECOVERY_REPLAY",
            WorkflowState::S8ReadmissionPending => "S8 READMISSION_PENDING",
        }
    }
    // §12 State model exit condition.
    fn exit_condition(self) -> &'static str {
        match self {
            WorkflowState::S0StartupReadonly => "Snapshot locked",
            WorkflowState::S1SnapshotLocked => "Structural validation finished",
            WorkflowState::S2StructuralVerified => "Policy, freshness, IRR, and visibility verified",
            WorkflowState::S3EligibleHeadSelected => "Replay completed",
            WorkflowState::S4RehydratedValidated => "ALLOW emitted",
            WorkflowState::S5FailSafe => "Authorized recovery path starts",
            WorkflowState::S6ToolQuarantine => "Separate approval or discard",
            WorkflowState::S7RecoveryReplay => "Convergence proven",
            WorkflowState::S8ReadmissionPending => "All obligations satisfied",
        }
    }
    fn tag(self) -> String {
        // Workflow-state tag, kept distinct from verdict tags (AR-002, AR-003).
        format!("WorkflowState::{:?}", self)
    }
    // Terminal verdict projected by a state that carries one (§5/§6/§11).
    fn projected_verdict(self) -> Option<NormativeVerdict> {
        match self {
            WorkflowState::S4RehydratedValidated => Some(NormativeVerdict::Allow),
            WorkflowState::S5FailSafe => Some(NormativeVerdict::Deny),
            WorkflowState::S6ToolQuarantine => Some(NormativeVerdict::Quarantine),
            WorkflowState::S8ReadmissionPending => Some(NormativeVerdict::ReadmissionPending),
            _ => None,
        }
    }
    fn parse(s: &str) -> Result<WorkflowState, String> {
        let head = s.trim().split_whitespace().next().unwrap_or("").to_ascii_uppercase();
        match head.as_str() {
            "S0" => Ok(WorkflowState::S0StartupReadonly),
            "S1" => Ok(WorkflowState::S1SnapshotLocked),
            "S2" => Ok(WorkflowState::S2StructuralVerified),
            "S3" => Ok(WorkflowState::S3EligibleHeadSelected),
            "S4" => Ok(WorkflowState::S4RehydratedValidated),
            "S5" => Ok(WorkflowState::S5FailSafe),
            "S6" => Ok(WorkflowState::S6ToolQuarantine),
            "S7" => Ok(WorkflowState::S7RecoveryReplay),
            "S8" => Ok(WorkflowState::S8ReadmissionPending),
            other => Err(format!("unknown workflow state: {other}")),
        }
    }
}

// ---------------------------------------------------------------------------
// §12 Transition triggers as an exhaustive enum (Conformance Tests CamelCase
// names; §12 snake_case trigger vocabulary accepted as synonyms).
// ---------------------------------------------------------------------------
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Trigger {
    StartupComplete,
    SnapshotLocked,
    StructuralChecksDone,
    EligibilityChecksDone,
    ToolStateInvalid,
    RollbackDetected,
    WalReplayNeeded,
    RecoveryConverged,
    AuthorityRelease,
}

impl Trigger {
    fn parse(s: &str) -> Result<Trigger, String> {
        let n = s.trim().to_ascii_lowercase().replace('_', "");
        match n.as_str() {
            "startupcomplete" => Ok(Trigger::StartupComplete),
            "snapshotlocked" => Ok(Trigger::SnapshotLocked),
            "structuralchecksdone" => Ok(Trigger::StructuralChecksDone),
            "eligibilitychecksdone" => Ok(Trigger::EligibilityChecksDone),
            "toolstateinvalid" => Ok(Trigger::ToolStateInvalid),
            "rollbackdetected" => Ok(Trigger::RollbackDetected),
            "walreplayneeded" => Ok(Trigger::WalReplayNeeded),
            "recoveryconverged" => Ok(Trigger::RecoveryConverged),
            "authorityrelease" => Ok(Trigger::AuthorityRelease),
            other => Err(format!("unknown trigger: {other}")),
        }
    }
}

// ---------------------------------------------------------------------------
// §10 Validator Catalogue — every Validator ID with Severity and failure outcome.
// ---------------------------------------------------------------------------
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Severity {
    Critical,
    High,
    Medium,
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum FailureOutcome {
    Deny,
    Escalate,
    Quarantine,
    ToolQuarantine,
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Validator {
    VFrame,
    VChecksum,
    VParse,
    VChain,
    VSig,
    VFreshness,
    VPolicy,
    VCompat,
    VIrr,
    VVisibility,
    VBootMode,
    VSnapshot,
    VWalPhase,
    VCounterCont,
    VToolSchema,
    VToolAllowlist,
    VWriterLock,
    VAnchor,
}

impl Validator {
    fn id(self) -> &'static str {
        match self {
            Validator::VFrame => "V_FRAME",
            Validator::VChecksum => "V_CHECKSUM",
            Validator::VParse => "V_PARSE",
            Validator::VChain => "V_CHAIN",
            Validator::VSig => "V_SIG",
            Validator::VFreshness => "V_FRESHNESS",
            Validator::VPolicy => "V_POLICY",
            Validator::VCompat => "V_COMPAT",
            Validator::VIrr => "V_IRR",
            Validator::VVisibility => "V_VISIBILITY",
            Validator::VBootMode => "V_BOOT_MODE",
            Validator::VSnapshot => "V_SNAPSHOT",
            Validator::VWalPhase => "V_WAL_PHASE",
            Validator::VCounterCont => "V_COUNTER_CONT",
            Validator::VToolSchema => "V_TOOL_SCHEMA",
            Validator::VToolAllowlist => "V_TOOL_ALLOWLIST",
            Validator::VWriterLock => "V_WRITER_LOCK",
            Validator::VAnchor => "V_ANCHOR",
        }
    }
    fn severity(self) -> Severity {
        match self {
            Validator::VWalPhase | Validator::VWriterLock => Severity::High,
            Validator::VToolSchema | Validator::VToolAllowlist => Severity::Medium,
            _ => Severity::Critical,
        }
    }
    // §10 "Failure produces".
    fn failure_produces(self) -> FailureOutcome {
        match self {
            Validator::VBootMode | Validator::VWriterLock => FailureOutcome::Escalate,
            Validator::VWalPhase => FailureOutcome::Quarantine,
            Validator::VToolSchema | Validator::VToolAllowlist => FailureOutcome::ToolQuarantine,
            _ => FailureOutcome::Deny,
        }
    }
    fn all() -> [Validator; 18] {
        use Validator::*;
        [
            VFrame, VChecksum, VParse, VChain, VSig, VFreshness, VPolicy, VCompat, VIrr,
            VVisibility, VBootMode, VSnapshot, VWalPhase, VCounterCont, VToolSchema,
            VToolAllowlist, VWriterLock, VAnchor,
        ]
    }
    fn parse(s: &str) -> Result<Validator, String> {
        let up = s.trim().to_ascii_uppercase();
        Validator::all()
            .iter()
            .copied()
            .find(|v| v.id() == up)
            .ok_or_else(|| format!("unknown validator: {up}"))
    }
}

// ---------------------------------------------------------------------------
// §12 Transition model + §7 ordering priority + §16 fail-closed default.
//
// This IS the Conformance Tests projection surface:
//   next_state(current_state, trigger, validator_passed).
// Conditional transitions expressed as match guards (rust idiom), never as a
// chain of string comparisons.
// ---------------------------------------------------------------------------
fn next_state(current_state: WorkflowState, trigger: Trigger, validator_passed: bool) -> WorkflowState {
    use Trigger::*;
    use WorkflowState::*;
    match (current_state, trigger) {
        // §7: "Rollback detection has blocking priority over every other
        // restoration rule." §12 "Any state | rollback_detected | ... | S5".
        (_, RollbackDetected) => S5FailSafe,
        // §12: S6 TOOL_QUARANTINE remains isolated ("Remain isolated"); the
        // Conformance Tests OR-11 fix it as stable/terminal on this surface.
        (S6ToolQuarantine, _) => S6ToolQuarantine,
        // Eligibility path (§12 Transition model), each guarded by its gate outcome.
        (S0StartupReadonly, StartupComplete) if validator_passed => S1SnapshotLocked,
        (S0StartupReadonly, StartupComplete) => S5FailSafe,
        (S1SnapshotLocked, SnapshotLocked) if validator_passed => S2StructuralVerified,
        (S1SnapshotLocked, SnapshotLocked) => S5FailSafe,
        (S2StructuralVerified, StructuralChecksDone) if validator_passed => S3EligibleHeadSelected,
        (S2StructuralVerified, StructuralChecksDone) => S5FailSafe,
        (S3EligibleHeadSelected, EligibilityChecksDone) if validator_passed => S5FailSafe,
        (S3EligibleHeadSelected, EligibilityChecksDone) => S5FailSafe,
        // §12 "S3 | tool-state invalid | Tool restrictions failed | S6".
        (S3EligibleHeadSelected, ToolStateInvalid) => S6ToolQuarantine,
        // §12 recovery path and its ordering ("WAL phase ordering prevails").
        (S5FailSafe, WalReplayNeeded) if validator_passed => S7RecoveryReplay,
        (S7RecoveryReplay, RecoveryConverged) if validator_passed => S8ReadmissionPending,
        // §12 "S8 | authority_release | Readmission approved | S0 or S1".
        (S8ReadmissionPending, AuthorityRelease) if validator_passed => authority_release_target(),
        (S8ReadmissionPending, AuthorityRelease) => S8ReadmissionPending, // "Remain blocked"
        // §16: fail-closed. No restoration proceeds on a non-enumerated
        // (state, trigger); the semantic is fail-closed, the mechanism is this
        // paradigm's exhaustive match default.
        _ => S5FailSafe,
    }
}

// §12 "S8 | authority_release | ... | S0 or S1". Bounded parameterized branch
// (Conformance Tests PT-024). The permitted set is {S0, S1}; the specific
// landing is an operator-declared envelope. Default S1 SNAPSHOT_LOCKED;
// overridable to S0 via VRA_READMISSION_TARGET for the operator's declaration.
fn authority_release_target() -> WorkflowState {
    match env::var("VRA_READMISSION_TARGET").ok().as_deref() {
        Some("S0") => WorkflowState::S0StartupReadonly,
        _ => WorkflowState::S1SnapshotLocked,
    }
}

// ---------------------------------------------------------------------------
// §14 Evidence Contract — the minimum evidence bundle and producer tags.
// ---------------------------------------------------------------------------
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum EvidenceClass {
    DenyChain,     // EB-01: representative DENY bundle, V_CHAIN
    DenyFreshness, // EB-02: representative DENY bundle, V_FRESHNESS
    DenyParse,     // EB-03: representative DENY bundle, V_PARSE
    DenyFrame,     // EB-04: representative DENY bundle, V_FRAME (producer tags)
    Recovery,      // EB-05: representative recovery bundle
    Readmission,   // EB-06: representative readmission bundle
}

impl EvidenceClass {
    fn parse(s: &str) -> Result<EvidenceClass, String> {
        match s.trim().to_ascii_lowercase().replace(['-', '_'], "").as_str() {
            "denychain" | "eb01" => Ok(EvidenceClass::DenyChain),
            "denyfreshness" | "eb02" => Ok(EvidenceClass::DenyFreshness),
            "denyparse" | "eb03" => Ok(EvidenceClass::DenyParse),
            "denyframe" | "eb04" => Ok(EvidenceClass::DenyFrame),
            "recovery" | "eb05" => Ok(EvidenceClass::Recovery),
            "readmission" | "eb06" => Ok(EvidenceClass::Readmission),
            other => Err(format!("unknown evidence class: {other}")),
        }
    }
}

// A representative (non-empty) value for a deployment-substrate field. The pack
// delegates the concrete VALUES to deployment; the field PRESENCE and STRUCTURE
// are spec-derivable (§14). These representative values make presence provable
// while remaining clearly representative.
fn repr(field: &str) -> String {
    format!("repr-{field}-0001")
}

// Build the minimum evidence bundle for a class as ordered (key, value) pairs.
// Producer tags follow §14 "Produced by" and §9, matching Conformance Tests
// OR-17 (ExecutionLayer / GateLogic / ToolGate) and OR-22 (recovery_phase
// producer = V_WAL_PHASE).
fn build_bundle(class: EvidenceClass) -> Vec<(String, String)> {
    let mut b: Vec<(String, String)> = Vec::new();
    let failed = match class {
        EvidenceClass::DenyChain => Some(Validator::VChain),
        EvidenceClass::DenyFreshness => Some(Validator::VFreshness),
        EvidenceClass::DenyParse => Some(Validator::VParse),
        EvidenceClass::DenyFrame => Some(Validator::VFrame),
        EvidenceClass::Recovery | EvidenceClass::Readmission => None,
    };

    let verdict = match class {
        EvidenceClass::Recovery => NormativeVerdict::Quarantine,
        EvidenceClass::Readmission => NormativeVerdict::ReadmissionPending,
        _ => NormativeVerdict::Deny,
    };
    b.push(("bundle_class".into(), format!("{}:{}", verdict.label(),
        failed.map(|v| v.id()).unwrap_or("-"))));

    // §14 unconditional principal-bundle fields (Required = Yes) with producers.
    b.push(("validator_bundle_id".into(), repr("validator_bundle_id")));
    b.push(("validator_bundle_id_producer".into(), "ExecutionLayer".into())); // §14 Execution layer
    b.push(("verified_head_digest".into(), repr("verified_head_digest")));
    b.push(("verified_head_digest_producer".into(), "V_CHAIN/V_VISIBILITY".into()));
    b.push(("snapshot_id".into(), repr("snapshot_id")));
    b.push(("snapshot_id_producer".into(), "V_SNAPSHOT".into()));
    b.push(("policy_id".into(), repr("policy_id")));
    b.push(("policy_id_producer".into(), "V_POLICY".into()));
    b.push(("source_id".into(), repr("source_id")));
    b.push(("freshness_value".into(), repr("freshness_value")));
    b.push(("source_freshness_producer".into(), "V_FRESHNESS".into()));
    b.push(("irr_digest".into(), repr("irr_digest")));
    b.push(("irr_digest_producer".into(), "V_IRR".into()));
    // §2 invariant + AR-006/AR-007: tool-state trajectory is independent of the
    // restoration verdict; inactive unless a separate activation gate succeeds.
    b.push(("tool_activation_status".into(), "INACTIVE".into()));
    b.push(("tool_activation_status_producer".into(), "ToolGate".into())); // §14 Tool gate

    // §14 conditional fields, activated by outcome.
    if let Some(v) = failed {
        // failure_code + failed_validator produced by Gate logic (§14).
        b.push(("failed_validator".into(), v.id().into()));
        b.push(("failure_code".into(), repr("failure_code")));
        b.push(("failure_explanation_producer".into(), "GateLogic".into())); // §14 Gate logic
        b.push(("suppression_status".into(), "SUPPRESSED".into()));
    }
    if class == EvidenceClass::Recovery {
        b.push(("recovery_phase".into(), repr("recovery_phase")));
        b.push(("recovery_phase_producer".into(), "V_WAL_PHASE".into())); // §14 V_WAL_PHASE
    }
    if class == EvidenceClass::Readmission {
        b.push(("readmission_token_id".into(), repr("readmission_token_id")));
    }
    b
}

// ---------------------------------------------------------------------------
// Remaining enumerated surfaces, transcribed as data for completeness (R5 §4).
// These are not exercised by the Conformance Tests projection surface but are
// part of the specification's finite enumerated object.
// ---------------------------------------------------------------------------

// §4 Input Contract: (artefact, required_validators, evidence_fields, effect_on_failure).
const INPUT_CONTRACT: &[(&str, &str, &str, &str)] = &[
    ("Append-only ledger", "V_FRAME,V_CHECKSUM,V_PARSE,V_CHAIN", "frame_status,checksum_status,chain_status", "DENY + fail_safe"),
    ("WAL / phase markers", "V_WAL_PHASE,V_COUNTER_CONT", "recovery_phase,realized_counter", "QUARANTINE / controlled recovery"),
    ("IRR / reception log", "V_IRR,V_VISIBILITY", "irr_digest,accepted_head_digest", "DENY"),
    ("Policy bundle", "V_POLICY,V_COMPAT", "policy_id,compat_status", "DENY"),
    ("Tool-state manifest", "V_TOOL_SCHEMA,V_TOOL_ALLOWLIST", "tool_manifest_digest,tool_activation_status", "tool_quarantine"),
    ("Startup mount state", "V_BOOT_MODE", "mount_mode,startup_epoch", "ESCALATE"),
];

// §5 Output Contract: (output, emission_condition, minimum_content, consumer).
const OUTPUT_CONTRACT: &[(&str, &str, &str, &str)] = &[
    ("restoration_verdict=ALLOW", "All critical validators PASS", "verified_head_digest,policy_id,snapshot_id,validator_bundle_id", "Execution layer"),
    ("restoration_verdict=DENY", "Any critical validator FAILS", "failure_code,failed_validator,suppression_status", "Operator / gate"),
    ("quarantine_context", "Recoverable failure or restricted tool-state", "quarantine_scope,recovery_requirements", "Recovery flow"),
    ("validated_context", "ALLOW and complete replay from the verified head", "context_digest,source_head_digest,replay_range", "Execution layer"),
    ("operator-visible error", "DENY or ESCALATE", "error_class,evidence_ref", "Operator"),
    ("readmission_token", "Only after authorized recovery", "token_id,prerequisites_satisfied", "Policy authority"),
];

// §7 Ordering and Verification Sequence (normative order).
const ORDERING_SEQUENCE: &[&str] = &[
    "Mount read-only",
    "Lock a stable snapshot",
    "Verify framing",
    "Verify checksum",
    "Perform canonical parse",
    "Verify hash-chain continuity",
    "Verify signatures",
    "Verify freshness, IRR, and visibility",
    "Verify policy compatibility",
    "Select the verified head",
    "Replay verified records",
    "Emit the verdict",
];

// §8 Failure Semantics: (failure_class, semantic_effect, mandatory_action).
const FAILURE_SEMANTICS: &[(&str, &str, &str)] = &[
    ("Structural verification failure", "State remains non-restorable", "DENY + fail_safe"),
    ("Continuity or anti-rollback failure", "Candidate head is invalidated", "DENY + QUARANTINE + ESCALATE"),
    ("Policy, freshness, or IRR failure", "Restoration is ineligible", "DENY"),
    ("Tool-state restriction failure", "Conversation restoration may continue only if an independent valid path exists", "tool_quarantine"),
    ("Recovery ambiguity", "No release until convergence is proven", "QUARANTINE"),
    ("Operator or configuration deficiency", "Verification environment is not trustworthy", "ESCALATE"),
];

// §9 Observability Requirements: (id, evidence_field).
const OBSERVABILITY: &[(&str, &str)] = &[
    ("OBS-01", "validator_bundle_id"),
    ("OBS-02", "verified_head_digest,accepted_head_digest"),
    ("OBS-03", "failure_code,failed_validator"),
    ("OBS-04", "tool_activation_status"),
    ("OBS-05", "recovery_phase,realized_counter"),
    ("OBS-06", "writer_lock_status,contention_status"),
];

// §11 Decision Logic: (decision_object, verdict).
const DECISION_LOGIC: &[(&str, &str)] = &[
    ("restoration_request (all critical PASS)", "ALLOW"),
    ("restoration_request (V_FRAME/V_CHECKSUM/V_PARSE/V_CHAIN/V_SIG FAILS)", "DENY"),
    ("import_admissibility (freshness not strictly greater or policy incompatible)", "DENY"),
    ("verified_head_selection (IRR invalid or visibility unsatisfied)", "DENY"),
    ("tool_state_activation (schema/allow-list/approval absent)", "QUARANTINE"),
    ("recovery_replay (WAL phase ambiguous but recoverable)", "QUARANTINE"),
    ("startup_environment (boot mode not read-only or snapshot unstable)", "ESCALATE"),
    ("readmission_request (obligations satisfied and authority approves)", "READMISSION_PENDING->ALLOW"),
];

// §13 Gate Logic: (gate, open_condition, closed_by, effect).
const GATE_LOGIC: &[(&str, &str, &str, &str)] = &[
    ("Release gate", "All critical validators PASS and verified context is assembled", "Any critical failure", "Permits validated_context handoff"),
    ("Block gate", "A critical failure is present", "Recovery proof plus authority release", "Suppresses restore"),
    ("Quarantine gate", "Recoverable ambiguity or restricted tool-state", "Separate closure conditions", "Isolates partial artefacts"),
    ("Escalation gate", "Environment, policy, or authority deficiency", "Operator or policy-authority action", "Halts autonomous progress"),
    ("Readmission gate", "Fail-safe was previously entered and the closure bundle is complete", "Any missing obligation", "Controls exit from fail-safe"),
];

// §14 Evidence Contract: (field, produced_by, required).
const EVIDENCE_CONTRACT: &[(&str, &str, &str)] = &[
    ("verified_head_digest", "V_CHAIN / V_VISIBILITY", "Yes"),
    ("snapshot_id", "V_SNAPSHOT", "Yes"),
    ("validator_bundle_id", "Execution layer", "Yes"),
    ("policy_id", "V_POLICY", "Yes"),
    ("source_id + freshness_value", "V_FRESHNESS", "Yes"),
    ("irr_digest", "V_IRR", "Yes"),
    ("failure_code + failed_validator", "Gate logic", "Conditional"),
    ("tool_activation_status", "Tool gate", "Yes"),
    ("recovery_phase", "V_WAL_PHASE", "Conditional"),
    ("writer_lock_status", "V_WRITER_LOCK", "Conditional"),
];

// §15 Machine-Readable Forms: (form_id, canonical_fields).
const MACHINE_READABLE_FORMS: &[(&str, &str)] = &[
    ("MRF-RESTORE-REQ", "request_id,source_id,requested_head,policy_profile"),
    ("MRF-VALIDATOR-BUNDLE", "validator_id,status,evidence_ref,timestamp_or_counter"),
    ("MRF-RESTORE-VERDICT", "verdict,verified_head_digest,snapshot_id,failure_code"),
    ("MRF-TOOL-QUARANTINE", "tool_id,schema_status,allow_status,quarantine_scope"),
    ("MRF-READMISSION", "token_id,approver_set,satisfied_obligations"),
    ("MRF-VALIDATION-LOG", "validation_run_id,test_id,axis,status,evidence_ref,reviewer"),
];

fn cmd_surface() {
    println!("== §4 Input Contract ==");
    for (a, v, e, f) in INPUT_CONTRACT {
        println!("input={a} validators={v} evidence={e} on_failure={f}");
    }
    println!("== §5 Output Contract ==");
    for (o, c, m, cons) in OUTPUT_CONTRACT {
        println!("output={o} condition={c} minimum={m} consumer={cons}");
    }
    println!("== §7 Ordering and Verification Sequence ==");
    for (i, step) in ORDERING_SEQUENCE.iter().enumerate() {
        println!("step{}={step}", i + 1);
    }
    println!("== §8 Failure Semantics ==");
    for (c, s, a) in FAILURE_SEMANTICS {
        println!("failure_class={c} effect={s} mandatory_action={a}");
    }
    println!("== §9 Observability ==");
    for (id, f) in OBSERVABILITY {
        println!("obs={id} evidence={f}");
    }
    println!("== §10 Validator Catalogue ==");
    for v in Validator::all() {
        println!("validator={} severity={:?} failure_produces={:?}", v.id(), v.severity(), v.failure_produces());
    }
    println!("== §11 Decision Logic ==");
    for (d, verdict) in DECISION_LOGIC {
        println!("decision={d} verdict={verdict}");
    }
    println!("== §12 State model ==");
    for s in [
        WorkflowState::S0StartupReadonly, WorkflowState::S1SnapshotLocked, WorkflowState::S2StructuralVerified,
        WorkflowState::S3EligibleHeadSelected, WorkflowState::S4RehydratedValidated, WorkflowState::S5FailSafe,
        WorkflowState::S6ToolQuarantine, WorkflowState::S7RecoveryReplay, WorkflowState::S8ReadmissionPending,
    ] {
        println!("state={} label={} exit={}", s.code(), s.label(), s.exit_condition());
    }
    println!("== §13 Gate Logic ==");
    for (g, o, c, e) in GATE_LOGIC {
        println!("gate={g} open={o} closed_by={c} effect={e}");
    }
    println!("== §14 Evidence Contract ==");
    for (f, p, r) in EVIDENCE_CONTRACT {
        println!("evidence_field={f} produced_by={p} required={r}");
    }
    println!("== §15 Machine-Readable Forms ==");
    for (id, f) in MACHINE_READABLE_FORMS {
        println!("form={id} canonical_fields={f}");
    }
}

// ---------------------------------------------------------------------------
// CLI dispatch.
// ---------------------------------------------------------------------------
fn die(msg: String) -> ! {
    eprintln!("error: {msg}");
    exit(2);
}

fn cmd_transition(args: &[String]) {
    if args.len() < 3 {
        die("transition needs: <state> <trigger> <validator_passed>".into());
    }
    let state = WorkflowState::parse(&args[0]).unwrap_or_else(|e| die(e));
    let trigger = Trigger::parse(&args[1]).unwrap_or_else(|e| die(e));
    let validator_passed = match args[2].trim().to_ascii_lowercase().as_str() {
        "true" | "t" | "1" => true,
        "false" | "f" | "0" => false,
        other => die(format!("validator_passed must be true/false, got {other}")),
    };
    let result = next_state(state, trigger, validator_passed);
    println!("input_state={}", state.code());
    println!("input_trigger={:?}", trigger);
    println!("validator_passed={validator_passed}");
    println!("next_state={}", result.code());
    println!("next_state_label={}", result.label());
    println!("next_state_tag={}", result.tag());
    println!(
        "projected_verdict={}",
        result.projected_verdict().map(|v| v.label()).unwrap_or("IN_PROGRESS")
    );
}

fn cmd_evidence(args: &[String]) {
    if args.is_empty() {
        die("evidence needs: <class>".into());
    }
    let class = EvidenceClass::parse(&args[0]).unwrap_or_else(|e| die(e));
    for (k, v) in build_bundle(class) {
        println!("{k}={v}");
    }
}

fn cmd_verdict_tag(args: &[String]) {
    if args.is_empty() {
        die("verdict-tag needs: <verdict>".into());
    }
    let v = NormativeVerdict::parse(&args[0]).unwrap_or_else(|e| die(e));
    println!("verdict={}", v.label());
    println!("verdict_tag={}", v.tag());
}

fn cmd_state_tag(args: &[String]) {
    if args.is_empty() {
        die("state-tag needs: <state>".into());
    }
    let s = WorkflowState::parse(&args[0]).unwrap_or_else(|e| die(e));
    println!("state={}", s.code());
    println!("state_tag={}", s.tag());
    println!("state_label={}", s.label());
}

// §10 Validator Catalogue dump (transcription completeness surface).
fn cmd_catalogue() {
    for v in Validator::all() {
        println!(
            "validator={} severity={:?} failure_produces={:?}",
            v.id(),
            v.severity(),
            v.failure_produces()
        );
    }
}

fn cmd_health() {
    println!("agent_id=AGT-VRA-001");
    println!("paradigm=rust");
    println!("projection_surface=next_state(current_state,trigger,validator_passed)");
    let r = next_state(WorkflowState::S0StartupReadonly, Trigger::StartupComplete, true);
    println!("probe_transition=S0+StartupComplete+true -> {}", r.label());
}

fn main() {
    let argv: Vec<String> = env::args().collect();
    if argv.len() < 2 {
        die("usage: baseline <transition|evidence|verdict-tag|state-tag|catalogue|health> ...".into());
    }
    let cmd = argv[1].as_str();
    let rest = &argv[2..];
    match cmd {
        "transition" => cmd_transition(rest),
        "evidence" => cmd_evidence(rest),
        "verdict-tag" => cmd_verdict_tag(rest),
        "state-tag" => cmd_state_tag(rest),
        "catalogue" => cmd_catalogue(),
        "surface" => cmd_surface(),
        "health" => cmd_health(),
        other => die(format!("unknown command: {other}")),
    }
}
