% =====================================================================
% run_pts.pl  --  R6 conformance runner for the VRA prolog baseline.
%
% RELOCATABLE: discovers its own directory at load time and consults
% baseline.pl from the same directory; writes pt_results.json beside
% itself. No absolute machine path is baked in, so the delivered
% run_pts.pl + baseline.pl reproduce the delivered statuses on any host.
%
% Usage:
%   swipl -q run_pts.pl -g "run_one('PT-001')" -t halt   % one PT -> stdout block
%   swipl -q run_pts.pl -g main -t halt                  % full suite + pt_results.json
%
% This runner is the test harness (it uses ->/; for pass/fail reporting);
% the spec semantics live in baseline.pl, which is pure Horn clauses.
% =====================================================================

:- dynamic script_dir/1.
:- ( prolog_load_context(directory, D0) -> true ; D0 = '.' ),
   retractall(script_dir(_)),
   assertz(script_dir(D0)),
   atom_concat(D0, '/baseline.pl', BP),
   consult(BP).

% ---- workflow-transition oracle helper -------------------------------
wf(State, Trig, VP, Expected, Status, Observed) :-
    ( next_state(State, Trig, VP, R)
    -> ( R == Expected -> Status = 'PASS' ; Status = 'FAIL' ), Observed = R
    ;  Status = 'FAIL', Observed = no_solution ).

% ---- evidence field-presence oracle helper ---------------------------
evidence_present_pt(Bundle, Fields, Status, Observed) :-
    ( forall(member(F, Fields), field_present(Bundle, F))
    -> Status = 'PASS' ; Status = 'FAIL' ),
    findall(F=V, (member(F, Fields), ( field_value(Bundle, F, V) -> true ; V = absent )), Pairs),
    format(atom(Observed), 'bundle=~w ~w', [Bundle, Pairs]).

% ---- per-PT oracles (Conformance Tests §1 procedures + §3 oracles) ----
pt_run('PT-001', runnable, S, O) :- wf(s0_startup_readonly,       startup_complete,        true,  s1_snapshot_locked,        S, O).
pt_run('PT-002', runnable, S, O) :- wf(s2_structural_verified,    structural_checks_done,  true,  s3_eligible_head_selected, S, O).
pt_run('PT-003', runnable, S, O) :- wf(s3_eligible_head_selected, eligibility_checks_done, true,  s4_rehydrated_validated,   S, O).
pt_run('PT-004', runnable, S, O) :- wf(s2_structural_verified,    structural_checks_done,  false, s5_fail_safe,              S, O).
pt_run('PT-005', runnable, S, O) :- wf(s2_structural_verified,    structural_checks_done,  false, s5_fail_safe,              S, O).
pt_run('PT-006', runnable, S, O) :- wf(s2_structural_verified,    structural_checks_done,  false, s5_fail_safe,              S, O).
pt_run('PT-007', runnable, S, O) :- wf(s2_structural_verified,    structural_checks_done,  false, s5_fail_safe,              S, O).
pt_run('PT-008', runnable, S, O) :- wf(s3_eligible_head_selected, eligibility_checks_done, false, s5_fail_safe,              S, O).
pt_run('PT-009', runnable, S, O) :- wf(s3_eligible_head_selected, eligibility_checks_done, false, s5_fail_safe,              S, O).
pt_run('PT-010', runnable, S, O) :- wf(s0_startup_readonly,       startup_complete,        false, s5_fail_safe,              S, O).
pt_run('PT-011', runnable, S, O) :- wf(s3_eligible_head_selected, rollback_detected,       true,  s5_fail_safe,              S, O).
pt_run('PT-012', runnable, S, O) :- wf(s5_fail_safe,              wal_replay_needed,       true,  s7_recovery_replay,        S, O).
pt_run('PT-013', runnable, S, O) :- wf(s3_eligible_head_selected, tool_state_invalid,      true,  s6_tool_quarantine,        S, O).
pt_run('PT-014', runnable, S, O) :- pt14(S, O).
pt_run('PT-015', runnable, S, O) :- wf(s6_tool_quarantine,        startup_complete,        true,  s6_tool_quarantine,        S, O).
pt_run('PT-016', runnable, S, O) :- evidence_present_pt(eb01, [validator_bundle_id, verified_head_digest, snapshot_id], S, O).
pt_run('PT-017', runnable, S, O) :- evidence_present_pt(eb02, [validator_bundle_id, verified_head_digest, snapshot_id, policy_id, source_id, freshness_value, irr_digest, tool_activation_status], S, O).
pt_run('PT-018', runnable, S, O) :- evidence_present_pt(eb03, [failure_code, failed_validator, suppression_status], S, O).
pt_run('PT-019', runnable, S, O) :- evidence_present_pt(eb05, [recovery_phase, recovery_phase_producer], S, O).
pt_run('PT-020', runnable, S, O) :- evidence_present_pt(eb06, [readmission_token_id], S, O).
pt_run('PT-021', runnable, S, O) :- pt21(S, O).
pt_run('PT-022', runnable, S, O) :- pt22(S, O).
pt_run('PT-023', runnable, S, O) :- pt23(S, O).
pt_run('PT-024', parameterized, S, O) :- pt24(S, O).
pt_run('PT-025', runnable, S, O) :- pt25(S, O).
pt_run('PT-026', runnable, S, O) :- pt26(S, O).
pt_run('PT-027', runnable, S, O) :- wf(s3_eligible_head_selected, tool_state_invalid,      true,  s6_tool_quarantine,        S, O).
pt_run('PT-028', declarative, 'SKIP', 'SKIP bounded external obligation V_COMPAT per Conformance Minimal Run Note (Verified_Rehydration_Agent_Conformance_Tests.md:518); policy-compatibility enforcement for import_admissibility is deployment substrate (Verified_Rehydration_Agent_Specification.md:296); proved by architecture evidence, not the local workflow transition surface').
pt_run('PT-029', declarative, 'SKIP', 'SKIP bounded external obligation V_WRITER_LOCK per Conformance Minimal Run Note (Verified_Rehydration_Agent_Conformance_Tests.md:518); single-writer discipline in the persistence control plane is deployment substrate (Verified_Rehydration_Agent_Specification.md:297); proved by architecture evidence, not the local workflow transition surface').

% PT-014 composite: paired comparison, one oracle, one row (composite convention).
pt14(Status, Observed) :-
    next_state(s3_eligible_head_selected, tool_state_invalid,      true, R1),
    next_state(s3_eligible_head_selected, eligibility_checks_done, true, R2),
    ( ( R1 == s6_tool_quarantine, R2 == s4_rehydrated_validated, R1 \== R2 )
    -> Status = 'PASS' ; Status = 'FAIL' ),
    ( R1 \== R2 -> Distinct = true ; Distinct = false ),
    format(atom(Observed), 'first=~w second=~w distinct=~w', [R1, R2, Distinct]).

% PT-021 authorized non-validator producer tags (OR-17).
pt21(Status, Observed) :-
    ( field_value(eb04, validator_bundle_id_producer,    'ExecutionLayer'),
      field_value(eb04, failure_explanation_producer,    'GateLogic'),
      field_value(eb04, tool_activation_status_producer, 'ToolGate')
    -> Status = 'PASS' ; Status = 'FAIL' ),
    findall(F=V, ( member(F, [validator_bundle_id_producer, failure_explanation_producer, tool_activation_status_producer]),
                   ( field_value(eb04, F, V) -> true ; V = absent ) ), Pairs),
    format(atom(Observed), '~w', [Pairs]).

% PT-022 verdict tag distinct from workflow-state tag (OR-18).
pt22(Status, Observed) :-
    verdict_taxon(quarantine, VT), state_taxon(s6_tool_quarantine, ST),
    ( VT \== ST -> Status = 'PASS' ; Status = 'FAIL' ),
    format(atom(Observed), 'verdict_tag=~w state_tag=~w', [VT, ST]).

% PT-023 Deny/Escalate/Quarantine pairwise distinct (OR-19).
pt23(Status, Observed) :-
    verdict_taxon(deny, DD), verdict_taxon(escalate, EE), verdict_taxon(quarantine, QQ),
    ( ( DD \== EE, EE \== QQ, DD \== QQ ) -> Status = 'PASS' ; Status = 'FAIL' ),
    format(atom(Observed), 'deny=~w escalate=~w quarantine=~w', [DD, EE, QQ]).

% PT-024 parameterized authority-release branch, bounded to {S0,S1} (OR-20).
pt24(Status, Observed) :-
    ( next_state(s8_readmission_pending, authority_release, true, R),
      admissible_authority_release_target(R)
    -> Status = 'PASS', RR = R ; Status = 'FAIL', RR = no_solution ),
    format(atom(Observed), 'declared_result=~w admissible_set=[s0_startup_readonly,s1_snapshot_locked]', [RR]).

% PT-025 freshness-downgrade cross-reference (OR-21).
pt25(Status, Observed) :-
    ( field_present(eb02, freshness_value),
      field_present(eb02, policy_id),
      field_value(eb02, failed_validator, 'V_FRESHNESS')
    -> Status = 'PASS' ; Status = 'FAIL' ),
    findall(F=V, ( member(F, [freshness_value, policy_id, failed_validator]),
                   ( field_value(eb02, F, V) -> true ; V = absent ) ), Pairs),
    format(atom(Observed), '~w', [Pairs]).

% PT-026 WAL-ambiguity cross-reference (OR-22).
pt26(Status, Observed) :-
    ( field_present(eb05, recovery_phase),
      field_value(eb05, recovery_phase_producer, 'V_WAL_PHASE')
    -> Status = 'PASS' ; Status = 'FAIL' ),
    findall(F=V, ( member(F, [recovery_phase, recovery_phase_producer]),
                   ( field_value(eb05, F, V) -> true ; V = absent ) ), Pairs),
    format(atom(Observed), '~w', [Pairs]).

% ---- canonical PT id list (Conformance Tests §1 order) ---------------
all_pts([ 'PT-001','PT-002','PT-003','PT-004','PT-005','PT-006','PT-007','PT-008','PT-009','PT-010',
          'PT-011','PT-012','PT-013','PT-014','PT-015','PT-016','PT-017','PT-018','PT-019','PT-020',
          'PT-021','PT-022','PT-023','PT-024','PT-025','PT-026','PT-027','PT-028','PT-029' ]).

% ---- run one PT and print a stdout block -----------------------------
run_one(PTID) :-
    ( pt_run(PTID, Cat, Status, Observed) -> true ; Cat = unknown, Status = 'ERROR', Observed = 'no such PT' ),
    format("PT-RESULT id=~w | category=~w | status=~w | observed=~w~n", [PTID, Cat, Status, Observed]).

% ---- run whole suite, print blocks, write pt_results.json ------------
main :-
    all_pts(L),
    forall(member(P, L), run_one(P)),
    write_results_json(L),
    ( script_dir(D), atom_concat(D, '/pt_results.json', JP) -> true ; JP = 'pt_results.json' ),
    format("WROTE ~w~n", [JP]).

utc_iso(TS) :-
    get_time(T),
    stamp_date_time(T, date(Y,Mo,D,H,Mi,Sf,_,_,_), 'UTC'),
    S is truncate(Sf),
    format(atom(TS), '~d-~|~`0t~d~2+-~|~`0t~d~2+T~|~`0t~d~2+:~|~`0t~d~2+:~|~`0t~d~2+Z', [Y,Mo,D,H,Mi,S]).

count_status(L, Target, N) :-
    findall(x, (member(P, L), pt_run(P, _, St, _), St == Target), Xs),
    length(Xs, N).

write_results_json(L) :-
    ( script_dir(D), atom_concat(D, '/pt_results.json', Path) -> true ; Path = 'pt_results.json' ),
    utc_iso(TS),
    length(L, Total),
    count_status(L, 'PASS', NP),
    count_status(L, 'FAIL', NF),
    count_status(L, 'SKIP', NS),
    count_status(L, 'ERROR', NE),
    setup_call_cleanup(
        open(Path, write, Str),
        ( format(Str, '{~n', []),
          format(Str, '  "agent_id": "AGT-VRA-001",~n', []),
          format(Str, '  "lang": "prolog",~n', []),
          format(Str, '  "test_run_timestamp_utc": "~w",~n', [TS]),
          format(Str, '  "execution_mode": "live",~n', []),
          format(Str, '  "protocol": "buyer-conformance",~n', []),
          format(Str, '  "totals": {"total": ~w, "pass": ~w, "fail": ~w, "skip": ~w, "error": ~w},~n', [Total, NP, NF, NS, NE]),
          format(Str, '  "results": [~n', []),
          write_results_array(Str, L),
          format(Str, '  ]~n', []),
          format(Str, '}~n', []) ),
        close(Str) ).

write_results_array(_, []).
write_results_array(Str, [P|Rest]) :-
    pt_run(P, Cat, St, Notes),
    ( Rest == [] -> Comma = '' ; Comma = ',' ),
    format(Str, '    {"id": "~w", "category": "~w", "status": "~w", "notes": "~w"}~w~n', [P, Cat, St, Notes, Comma]),
    write_results_array(Str, Rest).
