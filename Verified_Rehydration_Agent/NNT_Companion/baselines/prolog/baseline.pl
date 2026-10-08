% =====================================================================
% baseline.pl  --  Verified Rehydration Agent (AGT-VRA-001)
% Paradigm: prolog. Derived ad-litteram from the buyer-facing pack
% (Specification, Ambiguity Register, Semantic Index, Coverage Matrix).
%
% Native-idiom derivation (R4):
%   * The workflow is a set of Horn clauses transition(StateIn,Event,StateOut,Conditions).
%   * State/verdict resolution is by unification against clause heads, not
%     by explicit procedural conditionals.
%   * Cut (!) short-circuits the gates the spec makes exclusive: the
%     rollback blocking-priority rule (Spec:142) and the terminal
%     tool-quarantine projection state (Conformance OR-11), plus
%     single-result verdict selection.
%   * No if-then-else (->/;) expresses spec semantics anywhere below.
%
% This file is the deliverable artifact for interpreted paradigms
% (an automated step hashes baseline.pl directly). The test oracle lives in the
% Conformance Tests; no PT fixture is embedded here.
% =====================================================================

:- discontiguous transition/4.
:- discontiguous on_failure/3.
:- discontiguous bundle_field/3.

% ---------------------------------------------------------------------
% Canonical state vocabulary (Spec:214..222 State model; Semantic Index ST-001..ST-009)
% ---------------------------------------------------------------------
state(s0_startup_readonly).
state(s1_snapshot_locked).
state(s2_structural_verified).
state(s3_eligible_head_selected).
state(s4_rehydrated_validated).
state(s5_fail_safe).
state(s6_tool_quarantine).
state(s7_recovery_replay).
state(s8_readmission_pending).

% Exit condition per state (Spec:214..222).
state_exit(s0_startup_readonly,      'Snapshot locked').
state_exit(s1_snapshot_locked,       'Structural validation finished').
state_exit(s2_structural_verified,   'Policy, freshness, IRR, and visibility verified').
state_exit(s3_eligible_head_selected,'Replay completed').
state_exit(s4_rehydrated_validated,  'ALLOW emitted').
state_exit(s5_fail_safe,             'Authorized recovery path starts').
state_exit(s6_tool_quarantine,       'Separate approval or discard').
state_exit(s7_recovery_replay,       'Convergence proven').
state_exit(s8_readmission_pending,   'All obligations satisfied').

% ---------------------------------------------------------------------
% Canonical trigger vocabulary (Spec:226..236 Transition model; Semantic Index TR-001..TR-008)
% ---------------------------------------------------------------------
trigger(startup_complete).
trigger(snapshot_locked).
trigger(structural_checks_done).
trigger(eligibility_checks_done).
trigger(tool_state_invalid).
trigger(rollback_detected).
trigger(wal_replay_needed).
trigger(recovery_converged).
trigger(authority_release).

% ---------------------------------------------------------------------
% Normative verdict vocabulary (Spec:96 Verdict Semantics; Semantic Index DE-009 allowed_values)
% ---------------------------------------------------------------------
verdict(allow).
verdict(deny).
verdict(quarantine).
verdict(escalate).
verdict(readmission_pending).

% ---------------------------------------------------------------------
% Transition model -- success edges (Spec:226..236 "From/Trigger/Guard/To").
% Conditions carry the guard exactly as the spec states it.
% ---------------------------------------------------------------------
transition(s0_startup_readonly,       startup_complete,        s1_snapshot_locked,        guard([v_boot_mode])).
transition(s1_snapshot_locked,        snapshot_locked,         s2_structural_verified,    guard([v_snapshot])).
transition(s2_structural_verified,    structural_checks_done,  s3_eligible_head_selected, guard([v_frame,v_checksum,v_parse,v_chain,v_sig])).
transition(s3_eligible_head_selected, eligibility_checks_done, s4_rehydrated_validated,   guard([v_freshness,v_policy,v_irr,v_visibility])).
transition(s3_eligible_head_selected, tool_state_invalid,      s6_tool_quarantine,        guard(tool_restrictions_failed)).
% "Recovery path, wal_replay_needed, V_WAL_PHASE indicates recovery -> S7"
% (Spec:234). The recovery path begins where fail-safe is entered
% (state_exit(s5_fail_safe,'Authorized recovery path starts'), Spec:219).
transition(s5_fail_safe,              wal_replay_needed,       s7_recovery_replay,        guard([v_wal_phase])).
transition(s7_recovery_replay,        recovery_converged,      s8_readmission_pending,    guard(no_duplicate_effects)).
% "S8, authority_release, Readmission approved -> S0 or S1" (Spec:236):
% both targets are admissible; the deployment declares which within the set.
transition(s8_readmission_pending,    authority_release,       s0_startup_readonly,       guard(readmission_approved)).
transition(s8_readmission_pending,    authority_release,       s1_snapshot_locked,        guard(readmission_approved)).

% Transition model -- on-failure edges (Spec:226..236 "On failure" column).
% Row S0 states "S5 or ESCALATE"; the single-valued transition projection
% surface returns S5 FAIL_SAFE, the failure target the Conformance oracle
% OR-06 fixes for the S0 not-read-only path (Conformance:180,488).
on_failure(s0_startup_readonly,       startup_complete,        s5_fail_safe).
on_failure(s1_snapshot_locked,        snapshot_locked,         s5_fail_safe).
on_failure(s2_structural_verified,    structural_checks_done,  s5_fail_safe).
on_failure(s3_eligible_head_selected, eligibility_checks_done, s5_fail_safe).
on_failure(s3_eligible_head_selected, tool_state_invalid,      s6_tool_quarantine).  % "Remain isolated"
on_failure(s5_fail_safe,              wal_replay_needed,       s5_fail_safe).
on_failure(s7_recovery_replay,        recovery_converged,      s5_fail_safe).
on_failure(s8_readmission_pending,    authority_release,       s8_readmission_pending). % "Remain blocked"

% ---------------------------------------------------------------------
% Parameterized authority-release envelope (Conformance PT-024 / OR-20).
% The spec bounds the authority-release target to the set {S0, S1}
% (Spec:236); the buyer declares which within that authorized range.
% ---------------------------------------------------------------------
admissible_authority_release_target(s0_startup_readonly).
admissible_authority_release_target(s1_snapshot_locked).

% Buyer-declared envelope value (within the admissible set). Recorded in
% conformance_log.md ## Envelopes.
declared_authority_release_target(s1_snapshot_locked).

% ---------------------------------------------------------------------
% next_state/4 -- the required projection surface
%   next_state(CurrentState, Trigger, ValidatorPassed, ResultState)
% (Conformance Minimal Run Note, Conformance:510).
%
% Clause order encodes the spec's precedence, using cut only where the
% spec demands exclusivity:
% ---------------------------------------------------------------------

% (1) Rollback detection has blocking priority over every other
%     restoration rule (Spec:142); "Any state, rollback_detected -> S5"
%     (Spec:233). It must not fall through -> cut.
next_state(_State, rollback_detected, _ValidatorPassed, s5_fail_safe) :- !.

% (2) S6 TOOL_QUARANTINE is stable/terminal on the exposed projection
%     surface (Conformance OR-11, Conformance:493); its real exit is a
%     separate approval or discard (Spec:220). Rollback is already
%     handled above, so any other trigger keeps S6.
next_state(s6_tool_quarantine, Trigger, _ValidatorPassed, s6_tool_quarantine) :-
    Trigger \== rollback_detected, !.

% (3) Parameterized authority-release branch: return the buyer-declared
%     envelope value, bounded to the admissible set (PT-024).
next_state(s8_readmission_pending, authority_release, true, Target) :-
    declared_authority_release_target(Target),
    admissible_authority_release_target(Target), !.

% (4) Guard satisfied (ValidatorPassed = true): take the success edge.
next_state(State, Trigger, true, Next) :-
    transition(State, Trigger, Next, _Guard), !.

% (5) Guard failed (ValidatorPassed = false): take the on-failure edge.
next_state(State, Trigger, false, Next) :-
    on_failure(State, Trigger, Next), !.

% ---------------------------------------------------------------------
% Verdict / state taxonomy separation (Ambiguity Register AR-002, AR-003;
% Conformance PT-022 VT-01, PT-023 VT-02). Verdict tags and workflow-state
% tags are kept distinct labels, never collapsed.
% ---------------------------------------------------------------------
verdict_taxon(allow,               'NormativeVerdict::Allow').
verdict_taxon(deny,                'NormativeVerdict::Deny').
verdict_taxon(quarantine,          'NormativeVerdict::Quarantine').
verdict_taxon(escalate,            'NormativeVerdict::Escalate').
verdict_taxon(readmission_pending, 'NormativeVerdict::ReadmissionPending').

state_taxon(s6_tool_quarantine,    'WorkflowState::S6ToolQuarantine').

% ---------------------------------------------------------------------
% Evidence surface (Spec:250..263 Evidence Contract; Conformance evidence
% oracles OR-12..OR-17, OR-21, OR-22).
%
% Bundle identity, kind, and the failing validator each bundle represents.
% ---------------------------------------------------------------------
bundle(eb01). bundle(eb02). bundle(eb03). bundle(eb04). bundle(eb05). bundle(eb06).

bundle_kind(eb01, deny).        % Representative DENY-path bundle using V_CHAIN  (Conformance:468)
bundle_kind(eb02, deny).        % Representative DENY-path bundle using V_FRESHNESS(Conformance:469)
bundle_kind(eb03, deny).        % Representative DENY-path bundle using V_PARSE   (Conformance:470)
bundle_kind(eb04, deny).        % Representative DENY-path bundle using V_FRAME   (Conformance:471)
bundle_kind(eb05, recovery).    % Representative recovery bundle                  (Conformance:472)
bundle_kind(eb06, readmission). % Representative readmission bundle               (Conformance:473)

bundle_class_validator(eb01, 'V_CHAIN').
bundle_class_validator(eb02, 'V_FRESHNESS').
bundle_class_validator(eb03, 'V_PARSE').
bundle_class_validator(eb04, 'V_FRAME').

% The eight unconditional (Required = Yes) evidence fields (Spec:252..261).
% Values are representative non-empty tokens: the concrete field VALUES are
% deployment substrate (Spec:294..298 Deployment obligations), while the
% field PRESENCE and producer are spec-fixed here.
unconditional_field(validator_bundle_id,    'vbundle-0001').
unconditional_field(verified_head_digest,   'vhead-0001').
unconditional_field(snapshot_id,            'snap-0001').
unconditional_field(policy_id,              'policy-0001').
unconditional_field(source_id,              'source-0001').
unconditional_field(freshness_value,        'fresh-0001').
unconditional_field(irr_digest,             'irr-0001').
unconditional_field(tool_activation_status, 'inactive').

% Every bundle carries the unconditional minimum-bundle fields
% ("Every relevant decision produces a minimum evidence bundle", Spec:250).
bundle_field(B, F, V) :- bundle(B), unconditional_field(F, V).

% DENY-path failure-explanation triad (Spec:88 DENY min content;
% Spec:260 failure_code + failed_validator conditional).
bundle_field(B, failure_code,      'FC-BLOCK-0001') :- bundle_kind(B, deny).
bundle_field(B, failed_validator,  V)               :- bundle_kind(B, deny), bundle_class_validator(B, V).
bundle_field(B, suppression_status,'suppressed')    :- bundle_kind(B, deny).

% Authorized non-validator producer tags on the producer-tag fixture EB-04
% (Spec:256,260,261 producers; Conformance PT-021 / OR-17, Conformance:499).
bundle_field(eb04, validator_bundle_id_producer,    'ExecutionLayer').
bundle_field(eb04, failure_explanation_producer,    'GateLogic').
bundle_field(eb04, tool_activation_status_producer, 'ToolGate').

% Recovery bundle EB-05: recovery_phase and its producer
% (Spec:262 recovery_phase produced by V_WAL_PHASE; Conformance OR-15, OR-22).
bundle_field(eb05, recovery_phase,          'converging').
bundle_field(eb05, recovery_phase_producer, 'V_WAL_PHASE').

% Readmission bundle EB-06: readmission_token_id
% (Spec:250 readmission_token_id in the minimum bundle; Conformance OR-16).
bundle_field(eb06, readmission_token_id, 'rtok-0001').

% Field-presence and field-value helpers used by the evidence oracles.
field_present(B, F) :- bundle_field(B, F, V), V \== '', ground(V).
field_value(B, F, V) :- bundle_field(B, F, V).

% ---------------------------------------------------------------------
% Full enumerated-surface transcription (R5 step 4). The runnable PTs
% exercise next_state/4 and the evidence surface above; the fact tables
% below transcribe the remaining enumerated spec surfaces so the whole
% object is present, ad-litteram, in the knowledge base.
% ---------------------------------------------------------------------

% -- Section 4 Input Contract: input_contract(Artefact, [RequiredValidators], EffectOnFailure) (Spec:76..81)
input_contract(append_only_ledger,   [v_frame, v_checksum, v_parse, v_chain], deny_fail_safe).
input_contract(wal_phase_markers,     [v_wal_phase, v_counter_cont],          quarantine_controlled_recovery).
input_contract(irr_reception_log,     [v_irr, v_visibility],                  deny).
input_contract(policy_bundle,         [v_policy, v_compat],                   deny).
input_contract(tool_state_manifest,   [v_tool_schema, v_tool_allowlist],      tool_quarantine).
input_contract(startup_mount_state,   [v_boot_mode],                          escalate).

% -- Section 5 Output Contract: output_contract(Artefact, EmissionCondition) (Spec:87..92)
output_contract(restoration_verdict_allow, all_critical_validators_pass).
output_contract(restoration_verdict_deny,  any_critical_validator_fails).
output_contract(quarantine_context,        recoverable_failure_or_restricted_tool_state).
output_contract(validated_context,         allow_and_complete_replay_from_verified_head).
output_contract(operator_visible_error,    deny_or_escalate).
output_contract(readmission_token,         only_after_authorized_recovery).

% -- Section 8 Failure Semantics: failure_semantics(Class, [MandatoryActions]) (Spec:152..157)
failure_semantics(structural_verification_failure,     [deny, fail_safe]).
failure_semantics(continuity_or_anti_rollback_failure, [deny, quarantine, escalate]).
failure_semantics(policy_freshness_or_irr_failure,     [deny]).
failure_semantics(tool_state_restriction_failure,      [tool_quarantine]).
failure_semantics(recovery_ambiguity,                  [quarantine]).
failure_semantics(operator_or_configuration_deficiency,[escalate]).

% -- Section 9 Observability: obs(ID, [EvidenceFields]) (Spec:165..170)
obs('OBS-01', [validator_bundle_id]).
obs('OBS-02', [verified_head_digest, accepted_head_digest]).
obs('OBS-03', [failure_code, failed_validator]).
obs('OBS-04', [tool_activation_status]).
obs('OBS-05', [recovery_phase, realized_counter]).
obs('OBS-06', [writer_lock_status, contention_status]).

% -- Section 10 Validator Catalogue: validator(ID, Severity, FailureProduces) (Spec:176..193)
validator(v_frame,          critical, deny).
validator(v_checksum,       critical, deny).
validator(v_parse,          critical, deny).
validator(v_chain,          critical, deny).
validator(v_sig,            critical, deny).
validator(v_freshness,      critical, deny).
validator(v_policy,         critical, deny).
validator(v_compat,         critical, deny).
validator(v_irr,            critical, deny).
validator(v_visibility,     critical, deny).
validator(v_boot_mode,      critical, escalate).
validator(v_snapshot,       critical, deny).
validator(v_wal_phase,      high,     quarantine).
validator(v_counter_cont,   critical, deny).
validator(v_tool_schema,    medium,   tool_quarantine).
validator(v_tool_allowlist, medium,   tool_quarantine).
validator(v_writer_lock,    high,     escalate).
validator(v_anchor,         critical, deny).

% -- Section 11 Decision Logic: decision(Object, Conditions, Verdict) (Spec:199..206)
decision(restoration_request,    all_critical_validators_pass,          allow).
decision(restoration_request,    structural_critical_validator_fails,   deny).
decision(import_admissibility,   freshness_not_greater_or_policy_incompat, deny).
decision(verified_head_selection,irr_invalid_or_visibility_unsatisfied, deny).
decision(tool_state_activation,  tool_schema_allowlist_or_approval_unmet,quarantine).
decision(recovery_replay,        wal_phase_ambiguous_but_recoverable,   quarantine).
decision(startup_environment,    boot_not_readonly_or_snapshot_unstable,escalate).
decision(readmission_request,    obligations_satisfied_and_authority_approves, readmission_pending).

% -- Section 13 Gate Logic: gate(Name, OpenCondition, Effect) (Spec:242..246)
gate(release_gate,    all_critical_pass_and_context_assembled, permits_validated_context_handoff).
gate(block_gate,      critical_failure_present,                suppresses_restore).
gate(quarantine_gate, recoverable_ambiguity_or_restricted_tool_state, isolates_partial_artefacts).
gate(escalation_gate, environment_policy_or_authority_deficiency, halts_autonomous_progress).
gate(readmission_gate,fail_safe_entered_and_closure_bundle_complete, controls_exit_from_fail_safe).

% -- Section 14 Evidence Contract catalogue: evidence_contract(Field, Producer, Required) (Spec:254..263)
evidence_contract(verified_head_digest,          'V_CHAIN/V_VISIBILITY', yes).
evidence_contract(snapshot_id,                   'V_SNAPSHOT',           yes).
evidence_contract(validator_bundle_id,           'ExecutionLayer',       yes).
evidence_contract(policy_id,                     'V_POLICY',             yes).
evidence_contract(source_id_and_freshness_value, 'V_FRESHNESS',          yes).
evidence_contract(irr_digest,                    'V_IRR',                yes).
evidence_contract(failure_code_and_failed_validator, 'GateLogic',        conditional).
evidence_contract(tool_activation_status,        'ToolGate',             yes).
evidence_contract(recovery_phase,                'V_WAL_PHASE',          conditional).
evidence_contract(writer_lock_status,            'V_WRITER_LOCK',        conditional).

% -- Section 15 Machine-Readable Forms: mrf(FormID, [CanonicalFields]) (Spec:269..274)
mrf('MRF-RESTORE-REQ',      [request_id, source_id, requested_head, policy_profile]).
mrf('MRF-VALIDATOR-BUNDLE', [validator_id, status, evidence_ref, timestamp_or_counter]).
mrf('MRF-RESTORE-VERDICT',  [verdict, verified_head_digest, snapshot_id, failure_code]).
mrf('MRF-TOOL-QUARANTINE',  [tool_id, schema_status, allow_status, quarantine_scope]).
mrf('MRF-READMISSION',      [token_id, approver_set, satisfied_obligations]).
mrf('MRF-VALIDATION-LOG',   [validation_run_id, test_id, axis, status, evidence_ref, reviewer]).

% ---------------------------------------------------------------------
% Baseline health probe (R5 step 2): exercise the simplest declared
% transition (first workflow row S0 -> S1, Spec:228) and one evidence
% presence check, and print a structured block.
% ---------------------------------------------------------------------
emit_health :-
    next_state(s0_startup_readonly, startup_complete, true, R),
    format("baseline_health {~n", []),
    format("  agent_id: AGT-VRA-001~n", []),
    format("  paradigm: prolog~n", []),
    format("  probe_transition: next_state(s0_startup_readonly, startup_complete, true) = ~w~n", [R]),
    ( field_present(eb01, validator_bundle_id) -> P1 = present ; P1 = absent ),
    field_value(eb01, validator_bundle_id, VB),
    format("  probe_evidence: eb01.validator_bundle_id = ~w (~w)~n", [VB, P1]),
    format("  verdict_vocabulary: [allow, deny, quarantine, escalate, readmission_pending]~n", []),
    format("}~n", []).
