#!/usr/bin/env bash
# =============================================================================
# baseline.sh — Verified Rehydration Agent (AGT-VRA-001) — bash baseline
# =============================================================================
# Execution-neutral behavioural transcription of the buyer-facing specification
# Verified_Rehydration_Agent_Specification.md into the bash paradigm.
#
# Projection surface (Conformance Tests §4 Minimal Run Note):
#   1. next_state(current_state, trigger, validator_passed) — §12 Workflow and
#      State Transitions transition model + §7 ordering priority rules.
#   2. evidence <class> — §14 Evidence Contract minimum bundle + producer tags.
#   3. verdict-tag / state-tag — §6 Verdict Semantics vs §12 State model,
#      kept distinct per D4 AR-002 / AR-003.
#
# Paradigm idioms (R4): case-based state-event dispatch; associative arrays for
# evidence-field handling; trap for fail-closed critical paths (§8 / §16);
# parameter substitution for token parsing.
# =============================================================================

set -Eeuo pipefail

# --- fail-closed trap (§8 Failure Semantics; §16 fail-closed semantics) -------
fail_closed() {
    local ec=$?
    printf 'result_state=S5 FAIL_SAFE | rule=trap/fail-closed | exit_context=%s\n' "$ec" >&2
    exit 3
}


# --- canonical state labels (§12 State model) --------------------------------
declare -A STATE_LABEL=(
    [S0]="S0 STARTUP_READONLY"
    [S1]="S1 SNAPSHOT_LOCKED"
    [S2]="S2 STRUCTURAL_VERIFIED"
    [S3]="S3 ELIGIBLE_HEAD_SELECTED"
    [S4]="S4 REHYDRATED_VALIDATED"
    [S5]="S5 FAIL_SAFE"
    [S6]="S6 TOOL_QUARANTINE"
    [S7]="S7 RECOVERY_REPLAY"
    [S8]="S8 READMISSION_PENDING"
)

upper() { printf '%s' "${1:-}" | tr '[:lower:]' '[:upper:]'; }

# --- input normalisation -----------------------------------------------------
# State: accept full label ("S0 STARTUP_READONLY") or short code ("S0").
state_code_of() {
    local s="${1%% *}"
    s=$(upper "$s")
    case "$s" in
        S0|S1|S2|S3|S4|S5|S6|S7|S8) printf '%s' "$s" ;;
        *) printf 'UNKNOWN' ;;
    esac
}

# Trigger: accept CamelCase (Conformance Tests) or snake_case (§12) or spaced.
normalize_trigger() {
    local c
    c=$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')
    case "$c" in
        startupcomplete)        printf 'STARTUP_COMPLETE' ;;
        snapshotlocked)         printf 'SNAPSHOT_LOCKED' ;;
        structuralchecksdone)   printf 'STRUCTURAL_CHECKS_DONE' ;;
        eligibilitychecksdone)  printf 'ELIGIBILITY_CHECKS_DONE' ;;
        toolstateinvalid)       printf 'TOOL_STATE_INVALID' ;;
        rollbackdetected)       printf 'ROLLBACK_DETECTED' ;;
        walreplayneeded)        printf 'WAL_REPLAY_NEEDED' ;;
        recoveryconverged)      printf 'RECOVERY_CONVERGED' ;;
        authorityrelease)       printf 'AUTHORITY_RELEASE' ;;
        *)                      printf 'UNKNOWN_TRIGGER' ;;
    esac
}

# Boolean validator-gate outcome.
normalize_bool() {
    case "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')" in
        true|t|1|pass|passed|yes|y) printf 'true' ;;
        false|f|0|fail|failed|no|n) printf 'false' ;;
        *) printf 'invalid' ;;
    esac
}

# --- core transition surface (§12 transition model; §7 priority rules) --------
# Returns a short state code (S0..S8) on stdout.
next_state_code() {
    local state="$1" trig="$2" vp="$3"

    # §7: "Rollback detection has blocking priority over every other
    # restoration rule." Applies from any state (§12 "Any state" row).
    case "$trig" in
        ROLLBACK_DETECTED) printf 'S5'; return 0 ;;
    esac

    # §12: S6 TOOL_QUARANTINE isolation is stable/terminal on the projection
    # surface for any non-rollback trigger (Conformance Tests PT-015).
    case "$state" in
        S6) printf 'S6'; return 0 ;;
    esac

    # Enumerated (state | trigger | validator_passed) transitions.
    case "${state}|${trig}|${vp}" in
        "S0|STARTUP_COMPLETE|true")            printf 'S1' ;;
        "S0|STARTUP_COMPLETE|false")           printf 'S5' ;;
        "S1|SNAPSHOT_LOCKED|true")             printf 'S2' ;;
        "S1|SNAPSHOT_LOCKED|false")            printf 'S5' ;;
        "S2|STRUCTURAL_CHECKS_DONE|true")      printf 'S3' ;;
        "S2|STRUCTURAL_CHECKS_DONE|false")     printf 'S5' ;;
        "S3|ELIGIBILITY_CHECKS_DONE|true")     printf 'S4' ;;
        "S3|ELIGIBILITY_CHECKS_DONE|false")    printf 'S5' ;;
        "S3|TOOL_STATE_INVALID|true"| \
        "S3|TOOL_STATE_INVALID|false")         printf 'S6' ;;
        "S5|WAL_REPLAY_NEEDED|true")           printf 'S7' ;;
        "S5|WAL_REPLAY_NEEDED|false")          printf 'S5' ;;
        "S7|RECOVERY_CONVERGED|true")          printf 'S8' ;;
        "S7|RECOVERY_CONVERGED|false")         printf 'S5' ;;
        "S8|AUTHORITY_RELEASE|true")           printf 'S0' ;;
        "S8|AUTHORITY_RELEASE|false")          printf 'S8' ;;
        # Catch-all / default: fail-closed (Core safety model; §16 fail-closed).
        *)                                     printf 'S5' ;;
    esac
    return 0
}

rule_of() {
    local s="$1" t="$2" v="$3" r="$4"
    case "$t" in
        ROLLBACK_DETECTED) printf 'rollback-priority->%s' "$r"; return 0 ;;
    esac
    case "$s" in
        S6) printf 'S6-isolated-terminal->%s' "$r"; return 0 ;;
    esac
    printf '%s+%s/%s->%s' "$s" "$t" "$v" "$r"
}

cmd_next_state() {
    local in_state="${1:-}" in_trig="${2:-}" in_vp="${3:-}"
    local sc trig vp rc rule from_label
    sc=$(state_code_of "$in_state")
    trig=$(normalize_trigger "$in_trig")
    vp=$(normalize_bool "$in_vp")

    case "${sc}|${vp}" in
        UNKNOWN\|*|*\|invalid)
            # malformed input -> fail-closed (§16)
            rc="S5"; rule="malformed-input/fail-closed"
            from_label="${in_state:-<none>}"
            ;;
        *)
            rc=$(next_state_code "$sc" "$trig" "$vp")
            rule=$(rule_of "$sc" "$trig" "$vp" "$rc")
            from_label="${STATE_LABEL[$sc]}"
            ;;
    esac

    printf 'result_state=%s | from_state=%s | trigger=%s | validator_passed=%s | rule=%s\n' \
        "${STATE_LABEL[$rc]}" "$from_label" "$trig" "$vp" "$rule"
}

# --- evidence surface (§14 Evidence Contract; §9 Observability) --------------
declare -A EV
declare -a EV_ORDER

ev_set() { EV["$1"]="$2"; }

build_bundle() {
    local class="$1"
    EV_ORDER=(
        verdict validator_bundle_id verified_head_digest accepted_head_digest
        snapshot_id policy_id source_id freshness_value irr_digest
        failed_validator failure_code suppression_status tool_activation_status
        recovery_phase readmission_token_id
        validator_bundle_id_producer verified_head_digest_producer
        snapshot_id_producer policy_id_producer source_freshness_producer
        irr_digest_producer failure_explanation_producer
        tool_activation_status_producer recovery_phase_producer
    )

    # Authorized non-validator producers (§14 Produced by; PT-021/OR-17).
    ev_set validator_bundle_id_producer ExecutionLayer
    ev_set failure_explanation_producer GateLogic
    ev_set tool_activation_status_producer ToolGate
    # Validator producers (§14 Produced by column).
    ev_set verified_head_digest_producer V_CHAIN
    ev_set snapshot_id_producer V_SNAPSHOT
    ev_set policy_id_producer V_POLICY
    ev_set source_freshness_producer V_FRESHNESS
    ev_set irr_digest_producer V_IRR

    # Unconditional minimum-bundle fields (§14 Required=Yes), representative
    # non-empty values (deployment supplies the real digests/ids).
    ev_set validator_bundle_id VB-0001
    ev_set verified_head_digest sha256:head-0001
    ev_set accepted_head_digest sha256:acc-0001
    ev_set snapshot_id SNAP-0001
    ev_set policy_id POL-0001
    ev_set source_id SRC-0001
    ev_set freshness_value 42
    ev_set irr_digest IRR-0001
    # §2 invariant: tool-state inactive unless a separate gate + approval succeed.
    ev_set tool_activation_status inactive

    case "$(printf '%s' "$class" | tr '[:upper:]' '[:lower:]')" in
        allow)
            ev_set verdict ALLOW
            ev_set suppression_status not_suppressed
            ;;
        eb-01|deny-chain)
            ev_set verdict DENY
            ev_set failed_validator V_CHAIN
            ev_set failure_code CHAIN_BREAK
            ev_set suppression_status suppressed
            ;;
        eb-02|deny-freshness)
            ev_set verdict DENY
            ev_set failed_validator V_FRESHNESS
            ev_set failure_code FRESHNESS_DOWNGRADE
            ev_set suppression_status suppressed
            ;;
        eb-03|deny-parse)
            ev_set verdict DENY
            ev_set failed_validator V_PARSE
            ev_set failure_code PARSE_AMBIGUOUS
            ev_set suppression_status suppressed
            ;;
        eb-04|deny-frame)
            ev_set verdict DENY
            ev_set failed_validator V_FRAME
            ev_set failure_code FRAME_INVALID
            ev_set suppression_status suppressed
            ;;
        eb-05|recovery)
            ev_set verdict QUARANTINE
            ev_set recovery_phase converging
            ev_set recovery_phase_producer V_WAL_PHASE
            ev_set suppression_status suppressed
            ;;
        eb-06|readmission)
            ev_set verdict READMISSION_PENDING
            ev_set readmission_token_id RDM-TOKEN-0001
            ;;
        *)
            # Unknown class -> fail-closed deny bundle (§16).
            ev_set verdict DENY
            ev_set failed_validator UNSPECIFIED
            ev_set failure_code UNKNOWN_CLASS
            ev_set suppression_status suppressed
            ;;
    esac
}

emit_bundle() {
    local class="$1" k
    printf 'evidence_bundle: class=%s\n' "$class"
    for k in "${EV_ORDER[@]}"; do
        if [ -n "${EV[$k]:-}" ]; then
            printf '%s=%s\n' "$k" "${EV[$k]}"
        fi
    done
}

cmd_evidence() {
    local class="${1:-allow}"
    build_bundle "$class"
    emit_bundle "$class"
}

# --- taxonomy surface (§6 verdicts vs §12 states; D4 AR-002/AR-003) ----------
cmd_verdict_tag() { printf 'verdict::%s\n' "$(upper "${1:-}")"; }

cmd_state_tag() {
    local c
    c=$(state_code_of "${1:-}")
    case "$c" in
        UNKNOWN) printf 'state::UNKNOWN\n' ;;
        *) printf 'state::%s\n' "$(printf '%s' "${STATE_LABEL[$c]}" | tr ' ' '_')" ;;
    esac
}

cmd_states() {
    local c
    for c in S0 S1 S2 S3 S4 S5 S6 S7 S8; do
        printf '%s\n' "${STATE_LABEL[$c]}"
    done
}

cmd_help() {
    cat <<'EOF'
baseline.sh — Verified Rehydration Agent (AGT-VRA-001) — bash baseline
Usage:
  baseline.sh next_state <current_state> <trigger> <validator_passed>
  baseline.sh evidence <class>          (allow|deny-chain|deny-freshness|
                                         deny-parse|deny-frame|recovery|
                                         readmission | EB-01..EB-06)
  baseline.sh verdict-tag <VERDICT>     (ALLOW|DENY|QUARANTINE|ESCALATE|
                                         READMISSION_PENDING)
  baseline.sh state-tag <STATE>
  baseline.sh states
EOF
}

# --- entrypoint --------------------------------------------------------------
main() {
    local cmd="${1:-help}"
    shift || true
    case "$cmd" in
        next_state|next-state) cmd_next_state "$@" ;;
        evidence)              cmd_evidence "$@" ;;
        verdict-tag|verdict_tag) cmd_verdict_tag "$@" ;;
        state-tag|state_tag)   cmd_state_tag "$@" ;;
        states)                cmd_states ;;
        help|-h|--help)        cmd_help ;;
        *)
            printf 'result_state=S5 FAIL_SAFE | rule=unknown-command/fail-closed | cmd=%s\n' "$cmd" >&2
            exit 2
            ;;
    esac
}

main "$@"
