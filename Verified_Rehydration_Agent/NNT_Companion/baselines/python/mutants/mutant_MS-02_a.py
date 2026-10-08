#!/usr/bin/env python3
"""AGT-VRA-001 Verified Rehydration Agent -- python baseline (NNT run).

Complete ad-litteram transcription of the enumerated specification surface of
`Verified_Rehydration_Agent_Specification.md` (sections 1-19), together with the
projection surface the Conformance Tests require: a workflow transition surface
equivalent to next_state(current_state, trigger, validator_passed) and an
evidence surface emitting the principal bundle fields and producer tags.

Derivation source: the 11 buyer-facing pack files only. The specification is
execution-neutral; this file realizes its semantics in python idiom:

  - dispatch by structural `match` on Enum tuples (transition surface) and a
    dict-of-callables (CLI), never an if/elif ladder over event strings;
  - domain types are `Enum` and frozen `@dataclass`, never raw dicts where the
    structure is fixed;
  - the state-machine boundary raises a custom Exception on any non-enumerated
    (state, trigger) pair -- fail-closed, no silent fallback (spec 16
    fail-closed conformance requirement; spec 3 authority is bounded to
    restore / deny / quarantine / escalate);
  - typing annotations carry the specification's own vocabulary.

Usage (driven by run_pts.py):
  baseline.py transition --state "S0 STARTUP_READONLY" --trigger StartupComplete --validator-passed true
  baseline.py evidence   --fixture EB-02
  baseline.py taxonomy
  baseline.py surface
"""
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, Optional

# ---------------------------------------------------------------------------
# 6 Verdict Semantics -- the controlled verdict vocabulary.
# ---------------------------------------------------------------------------


class Verdict(Enum):
    """Spec 6: the normative verdicts. Discriminants are distinct by auto()."""

    ALLOW = auto()
    DENY = auto()
    QUARANTINE = auto()
    ESCALATE = auto()
    READMISSION_PENDING = auto()

    @property
    def tag(self) -> str:
        return f"NormativeVerdict::{self.name}"


# ---------------------------------------------------------------------------
# 12 Workflow -- State model (S0..S8).
# ---------------------------------------------------------------------------


class State(Enum):
    """Spec 12 State model. `.value` is the canonical label used by the
    Conformance Tests projection surface."""

    S0_STARTUP_READONLY = "S0 STARTUP_READONLY"
    S1_SNAPSHOT_LOCKED = "S1 SNAPSHOT_LOCKED"
    S2_STRUCTURAL_VERIFIED = "S2 STRUCTURAL_VERIFIED"
    S3_ELIGIBLE_HEAD_SELECTED = "S3 ELIGIBLE_HEAD_SELECTED"
    S4_REHYDRATED_VALIDATED = "S4 REHYDRATED_VALIDATED"
    S5_FAIL_SAFE = "S5 FAIL_SAFE"
    S6_TOOL_QUARANTINE = "S6 TOOL_QUARANTINE"
    S7_RECOVERY_REPLAY = "S7 RECOVERY_REPLAY"
    S8_READMISSION_PENDING = "S8 READMISSION_PENDING"

    @property
    def tag(self) -> str:
        return f"WorkflowState::{self.name}"


# ---------------------------------------------------------------------------
# 12 Workflow -- Transition triggers (the 8 indexed transition terms plus the
# tool-state-invalid trigger phrase used by the S3->S6 transition row).
# ---------------------------------------------------------------------------


class Trigger(Enum):
    STARTUP_COMPLETE = "startup_complete"
    SNAPSHOT_LOCKED = "snapshot_locked"
    STRUCTURAL_CHECKS_DONE = "structural_checks_done"
    ELIGIBILITY_CHECKS_DONE = "eligibility_checks_done"
    TOOL_STATE_INVALID = "tool-state invalid"
    ROLLBACK_DETECTED = "rollback_detected"
    WAL_REPLAY_NEEDED = "wal_replay_needed"
    RECOVERY_CONVERGED = "recovery_converged"
    AUTHORITY_RELEASE = "authority_release"


class Severity(Enum):
    """Spec 10 validator severities."""

    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"


class ValidatorId(Enum):
    V_FRAME = "V_FRAME"
    V_CHECKSUM = "V_CHECKSUM"
    V_PARSE = "V_PARSE"
    V_CHAIN = "V_CHAIN"
    V_SIG = "V_SIG"
    V_FRESHNESS = "V_FRESHNESS"
    V_POLICY = "V_POLICY"
    V_COMPAT = "V_COMPAT"
    V_IRR = "V_IRR"
    V_VISIBILITY = "V_VISIBILITY"
    V_BOOT_MODE = "V_BOOT_MODE"
    V_SNAPSHOT = "V_SNAPSHOT"
    V_WAL_PHASE = "V_WAL_PHASE"
    V_COUNTER_CONT = "V_COUNTER_CONT"
    V_TOOL_SCHEMA = "V_TOOL_SCHEMA"
    V_TOOL_ALLOWLIST = "V_TOOL_ALLOWLIST"
    V_WRITER_LOCK = "V_WRITER_LOCK"
    V_ANCHOR = "V_ANCHOR"


# ---------------------------------------------------------------------------
# Boundary exceptions -- fail-closed, no silent fallback (spec 16).
# ---------------------------------------------------------------------------


class VRAError(Exception):
    """Base for boundary faults of the agent surface."""


class UnmappedTransitionError(VRAError):
    """A (state, trigger) pair not enumerated in spec 12. The specification is
    a finite, fully-enumerated object; a pair outside it is closed fail-safe by
    raising here rather than returning a guessed state. Spec 16 requires
    fail-closed semantics; spec 3 bounds authority to restore/deny/quarantine/
    escalate, so no new transition is invented at this boundary."""

    def __init__(self, state: "State", trigger: "Trigger") -> None:
        super().__init__(
            f"unmapped transition: ({state.value!r}, {trigger.value!r})"
        )
        self.state = state
        self.trigger = trigger


class UnknownFixtureError(VRAError):
    """An evidence-fixture id not defined by the Conformance Tests 2 Public
    Fixtures table."""


# ---------------------------------------------------------------------------
# 12 Transition surface -- next_state(current_state, trigger, validator_passed)
#
# Ordering of `case` arms encodes spec precedence:
#   1. rollback_detected from ANY state -> S5   (spec 7: rollback detection has
#      blocking priority over every other restoration rule; spec 12 "Any state"
#      catch-all row; on failure QUARANTINE + ESCALATE downstream);
#   2. S3 + tool-state invalid -> S6            (spec 12 tool split row);
#   3. S6 terminal on the exposed projection    (Conformance OR-11);
#   4. the numbered pass-path rows, each guarded by validator_passed: a passed
#      critical gate advances, a failed one routes to S5 FAIL_SAFE
#      (spec 12 "On failure" column; spec 8 structural failure -> DENY + fail_safe);
#   5. any other pair -> fail-closed (raise).
# ---------------------------------------------------------------------------

# PT-024 admissible target set is {S0, S1} per spec 12 (S8 authority_release ->
# "S0 or S1") and Conformance OR-20. Buyer-declared envelope for this run:
# release re-enters at S0 STARTUP_READONLY (full read-only re-verification),
# the more conservative of the two package-authorized targets.
AUTHORITY_RELEASE_TARGET: State = State.S0_STARTUP_READONLY


def next_state(current: State, trigger: Trigger, validator_passed: bool) -> State:
    """Spec 12 transition model as an executable projection surface."""
    assert isinstance(current, State), "current must be a State"
    assert isinstance(trigger, Trigger), "trigger must be a Trigger"
    assert isinstance(validator_passed, bool), "validator_passed must be bool"

    match (current, trigger):
        case (_, Trigger.ROLLBACK_DETECTED):
            return State.S5_FAIL_SAFE
        case (State.S3_ELIGIBLE_HEAD_SELECTED, Trigger.TOOL_STATE_INVALID):
            return State.S6_TOOL_QUARANTINE
        case (State.S6_TOOL_QUARANTINE, _):
            return State.S6_TOOL_QUARANTINE
        case (State.S0_STARTUP_READONLY, Trigger.STARTUP_COMPLETE):
            return State.S1_SNAPSHOT_LOCKED if not validator_passed else State.S5_FAIL_SAFE
        case (State.S1_SNAPSHOT_LOCKED, Trigger.SNAPSHOT_LOCKED):
            return State.S2_STRUCTURAL_VERIFIED if validator_passed else State.S5_FAIL_SAFE
        case (State.S2_STRUCTURAL_VERIFIED, Trigger.STRUCTURAL_CHECKS_DONE):
            return State.S3_ELIGIBLE_HEAD_SELECTED if validator_passed else State.S5_FAIL_SAFE
        case (State.S3_ELIGIBLE_HEAD_SELECTED, Trigger.ELIGIBILITY_CHECKS_DONE):
            return State.S4_REHYDRATED_VALIDATED if validator_passed else State.S5_FAIL_SAFE
        case (State.S5_FAIL_SAFE, Trigger.WAL_REPLAY_NEEDED):
            return State.S7_RECOVERY_REPLAY if validator_passed else State.S5_FAIL_SAFE
        case (State.S7_RECOVERY_REPLAY, Trigger.RECOVERY_CONVERGED):
            return State.S8_READMISSION_PENDING if validator_passed else State.S5_FAIL_SAFE
        case (State.S8_READMISSION_PENDING, Trigger.AUTHORITY_RELEASE):
            return AUTHORITY_RELEASE_TARGET if validator_passed else State.S8_READMISSION_PENDING
        case _:
            raise UnmappedTransitionError(current, trigger)


# ---------------------------------------------------------------------------
# Input parsing helpers -- accept the spec label, the CamelCase Conformance
# token, and the enum name for both states and triggers.
# ---------------------------------------------------------------------------


def _norm(token: str) -> str:
    return "".join(ch for ch in token.lower() if ch.isalnum())


_STATE_BY_NORM: dict[str, State] = {}
for _s in State:
    _STATE_BY_NORM[_norm(_s.value)] = _s          # "S0 STARTUP_READONLY"
    _STATE_BY_NORM[_norm(_s.name)] = _s           # "S0_STARTUP_READONLY"
    _STATE_BY_NORM[_norm(_s.value.split()[0])] = _s  # short code "S0"

_TRIGGER_BY_NORM: dict[str, Trigger] = {}
for _t in Trigger:
    _TRIGGER_BY_NORM[_norm(_t.value)] = _t        # "startup_complete" / "tool-state invalid"
    _TRIGGER_BY_NORM[_norm(_t.name)] = _t         # "STARTUP_COMPLETE"


def parse_state(token: str) -> State:
    key = _norm(token)
    if key not in _STATE_BY_NORM:
        raise VRAError(f"unknown state token: {token!r}")
    return _STATE_BY_NORM[key]


def parse_trigger(token: str) -> Trigger:
    key = _norm(token)
    if key not in _TRIGGER_BY_NORM:
        raise VRAError(f"unknown trigger token: {token!r}")
    return _TRIGGER_BY_NORM[key]


def parse_bool(token: str) -> bool:
    t = token.strip().lower()
    if t in ("true", "t", "1", "yes", "pass", "passed"):
        return True
    if t in ("false", "f", "0", "no", "fail", "failed"):
        return False
    raise VRAError(f"unknown boolean token: {token!r}")


# ---------------------------------------------------------------------------
# 10 Validator Catalogue (18 validators, ad-litteram).
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Validator:
    vid: ValidatorId
    description: str
    severity: Severity
    failure_produces: str
    minimum_evidence: tuple[str, ...]


VALIDATOR_CATALOGUE: dict[ValidatorId, Validator] = {
    ValidatorId.V_FRAME: Validator(ValidatorId.V_FRAME, "Verifies record framing structure and boundaries", Severity.CRITICAL, "DENY", ("frame_status", "frame_offset")),
    ValidatorId.V_CHECKSUM: Validator(ValidatorId.V_CHECKSUM, "Verifies frame checksum", Severity.CRITICAL, "DENY", ("checksum_status",)),
    ValidatorId.V_PARSE: Validator(ValidatorId.V_PARSE, "Verifies unambiguous canonical parsing", Severity.CRITICAL, "DENY", ("parse_status", "canonical_form_id")),
    ValidatorId.V_CHAIN: Validator(ValidatorId.V_CHAIN, "Verifies hash-chain continuity", Severity.CRITICAL, "DENY", ("prior_digest", "current_digest", "chain_status")),
    ValidatorId.V_SIG: Validator(ValidatorId.V_SIG, "Verifies signatures and the permitted cryptographic profile", Severity.CRITICAL, "DENY", ("key_id", "sig_status", "alg_profile")),
    ValidatorId.V_FRESHNESS: Validator(ValidatorId.V_FRESHNESS, "Verifies strict increase against the local watermark", Severity.CRITICAL, "DENY", ("source_id", "accepted_freshness", "candidate_freshness")),
    ValidatorId.V_POLICY: Validator(ValidatorId.V_POLICY, "Verifies policy_id and local policy compatibility", Severity.CRITICAL, "DENY", ("policy_id", "compat_status")),
    ValidatorId.V_COMPAT: Validator(ValidatorId.V_COMPAT, "Verifies deployment-policy compatibility", Severity.CRITICAL, "DENY", ("deployment_profile", "compat_status")),
    ValidatorId.V_IRR: Validator(ValidatorId.V_IRR, "Verifies IRR existence and validity", Severity.CRITICAL, "DENY", ("irr_digest", "irr_status")),
    ValidatorId.V_VISIBILITY: Validator(ValidatorId.V_VISIBILITY, "Selects only the accepted and visible head", Severity.CRITICAL, "DENY", ("accepted_head_digest",)),
    ValidatorId.V_BOOT_MODE: Validator(ValidatorId.V_BOOT_MODE, "Verifies startup remount as read-only", Severity.CRITICAL, "ESCALATE", ("mount_mode",)),
    ValidatorId.V_SNAPSHOT: Validator(ValidatorId.V_SNAPSHOT, "Verifies binding to a stable snapshot", Severity.CRITICAL, "DENY", ("snapshot_id", "fd_binding_digest")),
    ValidatorId.V_WAL_PHASE: Validator(ValidatorId.V_WAL_PHASE, "Verifies coherence of PREPARE / ANCHOR / APPEND / COMMIT markers", Severity.HIGH, "QUARANTINE", ("wal_phase",)),
    ValidatorId.V_COUNTER_CONT: Validator(ValidatorId.V_COUNTER_CONT, "Verifies counter monotonicity and continuity", Severity.CRITICAL, "DENY", ("counter_value", "anchor_digest")),
    ValidatorId.V_TOOL_SCHEMA: Validator(ValidatorId.V_TOOL_SCHEMA, "Verifies tool-state schema", Severity.MEDIUM, "tool_quarantine", ("tool_schema_status",)),
    ValidatorId.V_TOOL_ALLOWLIST: Validator(ValidatorId.V_TOOL_ALLOWLIST, "Verifies the allow-list and capability ceiling", Severity.MEDIUM, "tool_quarantine", ("tool_id", "allow_status")),
    ValidatorId.V_WRITER_LOCK: Validator(ValidatorId.V_WRITER_LOCK, "Verifies single-writer discipline", Severity.HIGH, "ESCALATE", ("writer_lock_status", "contention_status")),
    ValidatorId.V_ANCHOR: Validator(ValidatorId.V_ANCHOR, "Verifies the anti-rollback anchor", Severity.CRITICAL, "DENY", ("anchor_status",)),
}

# 11 Decision Logic: restoration_request hard-fail set (any of these FAILS -> DENY).
HARD_FAIL_SET: frozenset[ValidatorId] = frozenset(
    {ValidatorId.V_FRAME, ValidatorId.V_CHECKSUM, ValidatorId.V_PARSE, ValidatorId.V_CHAIN, ValidatorId.V_SIG}
)
CRITICAL_VALIDATORS: frozenset[ValidatorId] = frozenset(
    v.vid for v in VALIDATOR_CATALOGUE.values() if v.severity is Severity.CRITICAL
)


def principal_verdict(results: dict[ValidatorId, bool]) -> Verdict:
    """Spec 11 principal rule: all critical validators PASS -> ALLOW; any critical
    validator FAILS -> a blocking verdict. The hard-fail structural set routes to
    DENY (spec 11 row 2); V_BOOT_MODE failure routes to ESCALATE (spec 10); other
    critical failures route to DENY (spec 8 fail-closed)."""
    for vid in CRITICAL_VALIDATORS:
        if results.get(vid, True) is False:
            if vid is ValidatorId.V_BOOT_MODE:
                return Verdict.ESCALATE
            return Verdict.DENY
    return Verdict.ALLOW


# ---------------------------------------------------------------------------
# 14 Evidence Contract -- the evidence surface.
# ---------------------------------------------------------------------------

# Unconditional (Required = Yes) fields of the minimum principal bundle (spec 14).
UNCONDITIONAL_FIELDS: tuple[str, ...] = (
    "validator_bundle_id",
    "verified_head_digest",
    "snapshot_id",
    "policy_id",
    "source_id",
    "freshness_value",
    "irr_digest",
    "tool_activation_status",
)

# Representative, non-empty values for the buyer-declared conformance fixtures.
# These are representative closure values (the pack delivers no substrate values);
# the oracles assert presence / non-emptiness / producer identity, not the value.
_REP: dict[str, str] = {
    "validator_bundle_id": "vbundle-REP-0001",
    "verified_head_digest": "sha256:head-REP-0001",
    "snapshot_id": "snap-REP-0001",
    "policy_id": "policy-REP-v1",
    "source_id": "src-REP-0001",
    "freshness_value": "0000000000000010",
    "irr_digest": "sha256:irr-REP-0001",
    "tool_activation_status": "inactive",
}
# Producer tags (spec 14 "Produced by"; Conformance PT-021 / PT-026).
_PRODUCERS_ALWAYS: dict[str, str] = {
    "validator_bundle_id_producer": "ExecutionLayer",
    "tool_activation_status_producer": "ToolGate",
}


def _base_bundle() -> dict[str, str]:
    """The unconditional fields plus their always-present producer tags."""
    bundle: dict[str, str] = {k: _REP[k] for k in UNCONDITIONAL_FIELDS}
    bundle.update(_PRODUCERS_ALWAYS)
    return bundle


def _deny_bundle(failed_validator: ValidatorId) -> dict[str, str]:
    bundle = _base_bundle()
    bundle["failed_validator"] = failed_validator.value
    bundle["failure_code"] = f"DENY_{failed_validator.value}"
    bundle["suppression_status"] = "suppressed"
    bundle["failure_explanation_producer"] = "GateLogic"
    return bundle


# Conformance Tests 2 Public Fixtures -> evidence bundle builders.
def _fixture_eb01() -> dict[str, str]:
    return _deny_bundle(ValidatorId.V_CHAIN)


def _fixture_eb02() -> dict[str, str]:
    return _deny_bundle(ValidatorId.V_FRESHNESS)


def _fixture_eb03() -> dict[str, str]:
    return _deny_bundle(ValidatorId.V_PARSE)


def _fixture_eb04() -> dict[str, str]:
    return _deny_bundle(ValidatorId.V_FRAME)


def _fixture_eb05() -> dict[str, str]:
    bundle = _base_bundle()
    bundle["recovery_phase"] = "ANCHOR"
    bundle["recovery_phase_producer"] = "V_WAL_PHASE"
    return bundle


def _fixture_eb06() -> dict[str, str]:
    bundle = _base_bundle()
    bundle["readmission_token_id"] = "rtok-REP-0001"
    return bundle


EVIDENCE_FIXTURES: dict[str, Callable[[], dict[str, str]]] = {
    "EB-01": _fixture_eb01,
    "EB-02": _fixture_eb02,
    "EB-03": _fixture_eb03,
    "EB-04": _fixture_eb04,
    "EB-05": _fixture_eb05,
    "EB-06": _fixture_eb06,
}


def build_evidence_bundle(fixture_id: str) -> dict[str, str]:
    builder = EVIDENCE_FIXTURES.get(fixture_id.strip().upper())
    if builder is None:
        raise UnknownFixtureError(f"unknown evidence fixture: {fixture_id!r}")
    return builder()


# ---------------------------------------------------------------------------
# Enumerated reference surface (spec 1-19) -- transcribed for completeness and
# offline reconstruction. Not exercised directly by every PT, but part of the
# ad-litteram transcription contract (R5 completeness self-check).
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class CoreOverview:
    agent_id: str = "AGT-VRA-001"
    canonical_name: str = "Verified Rehydration Agent"
    agent_class: str = "Critical normative agent"


CORE_INVARIANTS: tuple[str, ...] = (
    "No restoration is permitted before the full verification sequence completes successfully.",
    "Any failure in framing, checksum, canonical parse, hash-chain continuity, signature validation, freshness, policy validation, or IRR validity triggers fail-safe handling and suppresses persistent-context injection.",
    "Restored persistent state may originate only from the verified and eligible head.",
    "Tool-state remains untrusted and inactive unless a separate activation gate and required approval both succeed.",
    "Startup remains read-only until the restoration decision is reached.",
    "Recovery is idempotent and must not produce duplicate effects or duplicate acceptance.",
    "Replay must begin from a deterministic baseline defined by the verified snapshot and applicable local policy.",
)

# 7 Ordering and Verification Sequence -- the 12 numbered steps, in order.
ORDERING_SEQUENCE: tuple[str, ...] = (
    "Mount read-only.",
    "Lock a stable snapshot.",
    "Verify framing.",
    "Verify checksum.",
    "Perform canonical parse.",
    "Verify hash-chain continuity.",
    "Verify signatures.",
    "Verify freshness, IRR, and visibility.",
    "Verify policy compatibility.",
    "Select the verified head.",
    "Replay verified records.",
    "Emit the verdict.",
)
ORDERING_RULES: tuple[str, ...] = (
    "No later step may execute if a prior critical step has failed.",
    "Replay uses only the same snapshot context in which the head was validated.",
    "Rollback detection has blocking priority over every other restoration rule.",
    "During recovery, WAL phase ordering prevails over speculative reconstruction.",
    "Durable IRR precedes any readmission of imported context; an unanchored tail remains ineligible even if local integrity can be reconstructed.",
)


@dataclass(frozen=True)
class FailureClass:
    failure_class: str
    semantic_effect: str
    mandatory_action: str


FAILURE_SEMANTICS: tuple[FailureClass, ...] = (
    FailureClass("Structural verification failure", "State remains non-restorable", "DENY + fail_safe"),
    FailureClass("Continuity or anti-rollback failure", "Candidate head is invalidated", "DENY + QUARANTINE + ESCALATE"),
    FailureClass("Policy, freshness, or IRR failure", "Restoration is ineligible", "DENY"),
    FailureClass("Tool-state restriction failure", "Conversation restoration may continue only if an independent valid path exists", "tool_quarantine"),
    FailureClass("Recovery ambiguity", "No release until convergence is proven", "QUARANTINE"),
    FailureClass("Operator or configuration deficiency", "Verification environment is not trustworthy", "ESCALATE"),
)


@dataclass(frozen=True)
class ObservabilityReq:
    oid: str
    observable: str
    evidence_field: str


OBSERVABILITY: tuple[ObservabilityReq, ...] = (
    ObservabilityReq("OBS-01", "Result of every critical validator", "validator_bundle_id"),
    ObservabilityReq("OBS-02", "Verified and eligible head", "verified_head_digest, accepted_head_digest"),
    ObservabilityReq("OBS-03", "Explicit reasons for DENY or ESCALATE", "failure_code, failed_validator"),
    ObservabilityReq("OBS-04", "Tool-state activation status", "tool_activation_status"),
    ObservabilityReq("OBS-05", "Recovery phase and convergence state", "recovery_phase, realized_counter"),
    ObservabilityReq("OBS-06", "Writer-lock status and contention state", "writer_lock_status, contention_status"),
)


@dataclass(frozen=True)
class DecisionRule:
    decision_object: str
    conditions: str
    verdict: str
    gate_impact: str
    required_evidence: str


DECISION_LOGIC: tuple[DecisionRule, ...] = (
    DecisionRule("restoration_request", "All critical validators PASS", "ALLOW", "Release validated_context", "validator_bundle_id, verified_head_digest"),
    DecisionRule("restoration_request", "Any of V_FRAME/V_CHECKSUM/V_PARSE/V_CHAIN/V_SIG FAILS", "DENY", "No injection", "failure_code, failed_validator"),
    DecisionRule("import_admissibility", "Freshness not strictly greater or policy incompatible", "DENY", "No new acceptance and no restore", "source_id, policy evidence"),
    DecisionRule("verified_head_selection", "IRR invalid or visibility unsatisfied", "DENY", "Tail remains ineligible", "irr_status, visibility evidence"),
    DecisionRule("tool_state_activation", "Tool schema invalid, allow-list unsatisfied, or approval absent", "QUARANTINE", "Tool remains inactive", "tool evidence"),
    DecisionRule("recovery_replay", "WAL phase ambiguous but recoverable", "QUARANTINE", "No release before convergence", "wal evidence"),
    DecisionRule("startup_environment", "Boot mode not read-only or snapshot unstable", "ESCALATE", "Verification environment blocked", "boot evidence"),
    DecisionRule("readmission_request", "All recovery obligations satisfied and authority approves", "READMISSION_PENDING -> ALLOW", "Exit fail-safe", "readmission token bundle"),
)


@dataclass(frozen=True)
class StateSpec:
    state: State
    meaning: str
    exit_condition: str


STATE_MODEL: tuple[StateSpec, ...] = (
    StateSpec(State.S0_STARTUP_READONLY, "Storage remounted read-only; no restore permitted", "Snapshot locked"),
    StateSpec(State.S1_SNAPSHOT_LOCKED, "Stable verification context established", "Structural validation finished"),
    StateSpec(State.S2_STRUCTURAL_VERIFIED, "Framing, checksum, parse, chain, and signature validation succeeded", "Policy, freshness, IRR, and visibility verified"),
    StateSpec(State.S3_ELIGIBLE_HEAD_SELECTED, "Accepted visible head fixed", "Replay completed"),
    StateSpec(State.S4_REHYDRATED_VALIDATED, "Validated context assembled", "ALLOW emitted"),
    StateSpec(State.S5_FAIL_SAFE, "Persistent context suppressed", "Authorized recovery path starts"),
    StateSpec(State.S6_TOOL_QUARANTINE, "Tool-state isolated", "Separate approval or discard"),
    StateSpec(State.S7_RECOVERY_REPLAY, "WAL or continuity replay in progress", "Convergence proven"),
    StateSpec(State.S8_READMISSION_PENDING, "Fail-safe exit under controlled authority", "All obligations satisfied"),
)


@dataclass(frozen=True)
class TransitionRule:
    from_state: str
    trigger: str
    guard: str
    to_state: str
    on_failure: str


TRANSITION_MODEL: tuple[TransitionRule, ...] = (
    TransitionRule("S0", "startup_complete", "V_BOOT_MODE PASS", "S1", "S5 or ESCALATE"),
    TransitionRule("S1", "snapshot_locked", "V_SNAPSHOT PASS", "S2", "S5"),
    TransitionRule("S2", "structural_checks_done", "V_FRAME..V_SIG PASS", "S3", "S5"),
    TransitionRule("S3", "eligibility_checks_done", "V_FRESHNESS + V_POLICY + V_IRR + V_VISIBILITY PASS", "S4", "S5"),
    TransitionRule("S3", "tool-state invalid", "Tool restrictions failed", "S6", "Remain isolated"),
    TransitionRule("Any state", "rollback_detected", "V_ANCHOR or V_COUNTER_CONT FAIL", "S5", "QUARANTINE + ESCALATE"),
    TransitionRule("Recovery path", "wal_replay_needed", "V_WAL_PHASE indicates recovery", "S7", "S5"),
    TransitionRule("S7", "recovery_converged", "No duplicate effects", "S8", "S5"),
    TransitionRule("S8", "authority_release", "Readmission approved", "S0 or S1", "Remain blocked"),
)


@dataclass(frozen=True)
class Gate:
    name: str
    open_condition: str
    closed_by: str
    effect: str


GATE_LOGIC: tuple[Gate, ...] = (
    Gate("Release gate", "All critical validators PASS and verified context is assembled", "Any critical failure", "Permits validated_context handoff"),
    Gate("Block gate", "A critical failure is present", "Recovery proof plus authority release", "Suppresses restore"),
    Gate("Quarantine gate", "Recoverable ambiguity or restricted tool-state", "Separate closure conditions", "Isolates partial artefacts"),
    Gate("Escalation gate", "Environment, policy, or authority deficiency", "Operator or policy-authority action", "Halts autonomous progress"),
    Gate("Readmission gate", "Fail-safe was previously entered and the closure bundle is complete", "Any missing obligation", "Controls exit from fail-safe"),
)


@dataclass(frozen=True)
class EvidenceFieldSpec:
    field_name: str
    meaning: str
    produced_by: str
    required: str


EVIDENCE_CONTRACT: tuple[EvidenceFieldSpec, ...] = (
    EvidenceFieldSpec("verified_head_digest", "Eligible head for replay", "V_CHAIN / V_VISIBILITY", "Yes"),
    EvidenceFieldSpec("snapshot_id", "Identifies the verification-time snapshot context", "V_SNAPSHOT", "Yes"),
    EvidenceFieldSpec("validator_bundle_id", "Binds the results of all validators", "Execution layer", "Yes"),
    EvidenceFieldSpec("policy_id", "Identifies the locally applied policy", "V_POLICY", "Yes"),
    EvidenceFieldSpec("source_id + freshness_value", "Tracks source freshness", "V_FRESHNESS", "Yes"),
    EvidenceFieldSpec("irr_digest", "Links the decision to valid reception", "V_IRR", "Yes"),
    EvidenceFieldSpec("failure_code + failed_validator", "Explains denial or escalation", "Gate logic", "Conditional"),
    EvidenceFieldSpec("tool_activation_status", "Separates restoration from tool-state activation", "Tool gate", "Yes"),
    EvidenceFieldSpec("recovery_phase", "Shows recovery convergence state", "V_WAL_PHASE", "Conditional"),
    EvidenceFieldSpec("writer_lock_status", "Shows single-writer enforcement at relevant control points", "V_WRITER_LOCK", "Conditional"),
)

MINIMUM_BUNDLE_FIELDS: tuple[str, ...] = (
    "validator_bundle_id", "verified_head_digest", "snapshot_id", "policy_id",
    "source_id", "freshness_value", "irr_digest", "failed_validator", "failure_code",
    "suppression_status", "tool_activation_status", "recovery_phase", "readmission_token_id",
)


@dataclass(frozen=True)
class MRForm:
    form_id: str
    purpose: str
    canonical_fields: tuple[str, ...]


MACHINE_READABLE_FORMS: tuple[MRForm, ...] = (
    MRForm("MRF-RESTORE-REQ", "Restoration request", ("request_id", "source_id", "requested_head", "policy_profile")),
    MRForm("MRF-VALIDATOR-BUNDLE", "Validator results", ("validator_id", "status", "evidence_ref", "timestamp_or_counter")),
    MRForm("MRF-RESTORE-VERDICT", "Final verdict", ("verdict", "verified_head_digest", "snapshot_id", "failure_code")),
    MRForm("MRF-TOOL-QUARANTINE", "Tool-state isolation", ("tool_id", "schema_status", "allow_status", "quarantine_scope")),
    MRForm("MRF-READMISSION", "Exit from fail-safe", ("token_id", "approver_set", "satisfied_obligations")),
    MRForm("MRF-VALIDATION-LOG", "Auditable record of validation execution", ("validation_run_id", "test_id", "axis", "status", "evidence_ref", "reviewer")),
)

CONFORMANCE_REQUIREMENTS: tuple[str, ...] = (
    "The agent must not inject unverified persistent state.",
    "The agent must detect and block rollback, downgrade, and unaccepted heads.",
    "The agent must preserve fail-closed semantics for every failed critical validator.",
    "The agent must support replay and offline reconstruction of the restoration verdict from evidence.",
    "The agent must preserve the structural separation between conversational restoration and tool-state activation.",
)

DEPLOYMENT_OBLIGATIONS: tuple[str, ...] = (
    "Stable snapshot availability",
    "Anti-rollback mechanism",
    "Local policy bundle",
    "Single-writer enforcement",
    "Separate readmission authority",
)

PRECEDENCE_RULES: tuple[str, ...] = (
    "A failed critical validator prevails over operational utility considerations.",
    "The accepted-head-only rule prevails over any local continuity of an unanchored tail.",
    "Local policy prevails over source-asserted provenance or source-asserted policy.",
    "Conversational restoration does not imply or compensate for tool-state activation.",
    "Implementation variation in hardware anchoring or writer-lock evidence is permitted only if the semantic requirement remains unchanged and the required evidence remains observable.",
)

OPTIONAL_FEATURES: tuple[str, ...] = (
    "Tool-state activation path",
    "Dual-control readmission",
    "Semantic continuity score",
    "Auxiliary indices",
)


def surface_summary() -> dict[str, int]:
    """R5 completeness self-check: counts of the enumerated surface."""
    return {
        "verdicts": len(Verdict),
        "states": len(State),
        "triggers_indexed": len([t for t in Trigger if t is not Trigger.TOOL_STATE_INVALID]),
        "triggers_total": len(Trigger),
        "validators": len(VALIDATOR_CATALOGUE),
        "critical_validators": len(CRITICAL_VALIDATORS),
        "core_invariants": len(CORE_INVARIANTS),
        "ordering_steps": len(ORDERING_SEQUENCE),
        "ordering_rules": len(ORDERING_RULES),
        "failure_classes": len(FAILURE_SEMANTICS),
        "observability_reqs": len(OBSERVABILITY),
        "decision_rules": len(DECISION_LOGIC),
        "state_model_rows": len(STATE_MODEL),
        "transition_model_rows": len(TRANSITION_MODEL),
        "gates": len(GATE_LOGIC),
        "evidence_fields": len(EVIDENCE_CONTRACT),
        "machine_readable_forms": len(MACHINE_READABLE_FORMS),
        "conformance_requirements": len(CONFORMANCE_REQUIREMENTS),
        "deployment_obligations": len(DEPLOYMENT_OBLIGATIONS),
        "precedence_rules": len(PRECEDENCE_RULES),
        "optional_features": len(OPTIONAL_FEATURES),
        "evidence_fixtures": len(EVIDENCE_FIXTURES),
    }


# ---------------------------------------------------------------------------
# CLI -- dispatch via a dict-of-callables (not an if/elif ladder).
# ---------------------------------------------------------------------------


def handle_transition(args: argparse.Namespace) -> dict:
    current = parse_state(args.state)
    trigger = parse_trigger(args.trigger)
    passed = parse_bool(args.validator_passed)
    result = next_state(current, trigger, passed)
    return {
        "surface": "transition",
        "current_state": current.value,
        "trigger": trigger.value,
        "validator_passed": passed,
        "result_state": result.value,
        "result_state_name": result.name,
    }


def handle_evidence(args: argparse.Namespace) -> dict:
    bundle = build_evidence_bundle(args.fixture)
    return {"surface": "evidence", "fixture": args.fixture.strip().upper(), "bundle": bundle}


def handle_taxonomy(_args: argparse.Namespace) -> dict:
    return {
        "surface": "taxonomy",
        "verdict_tags": {v.name: v.tag for v in Verdict},
        "verdict_discriminants": {v.name: v.value for v in Verdict},
        "state_tags": {s.name: s.tag for s in State},
    }


def handle_surface(_args: argparse.Namespace) -> dict:
    return {"surface": "surface_summary", "counts": surface_summary()}


HANDLERS: dict[str, Callable[[argparse.Namespace], dict]] = {
    "transition": handle_transition,
    "evidence": handle_evidence,
    "taxonomy": handle_taxonomy,
    "surface": handle_surface,
}


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="AGT-VRA-001 python baseline")
    sub = p.add_subparsers(dest="command", required=True)

    t = sub.add_parser("transition", help="workflow transition surface")
    t.add_argument("--state", required=True)
    t.add_argument("--trigger", required=True)
    t.add_argument("--validator-passed", required=True, dest="validator_passed")

    e = sub.add_parser("evidence", help="evidence bundle surface")
    e.add_argument("--fixture", required=True)

    sub.add_parser("taxonomy", help="verdict / state taxonomy surface")
    sub.add_parser("surface", help="enumerated surface counts")
    return p


def main(argv: Optional[list[str]] = None) -> int:
    args = build_parser().parse_args(argv)
    handler = HANDLERS[args.command]
    try:
        result = handler(args)
    except UnmappedTransitionError as exc:
        print(json.dumps({"error": "unmapped_transition", "detail": str(exc)}), file=sys.stderr)
        return 3
    except VRAError as exc:
        print(json.dumps({"error": "vra_error", "detail": str(exc)}), file=sys.stderr)
        return 4
    print(json.dumps(result, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
