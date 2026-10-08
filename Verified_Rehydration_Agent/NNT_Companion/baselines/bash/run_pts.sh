#!/usr/bin/env bash
# =============================================================================
# run_pts.sh — Conformance runner for the bash baseline of AGT-VRA-001.
# Relocatable: resolves the baseline and its output paths RELATIVE to itself.
# Re-running against the delivered baseline reproduces the delivered statuses.
# =============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE="$SCRIPT_DIR/baseline.sh"
# Interpreter on PATH (no embedded spaces); relocatable across hosts.
BASH_BIN="bash"
LOG="$SCRIPT_DIR/pt_run_log.txt"
RESULTS="$SCRIPT_DIR/pt_results.json"

: > /dev/null  # no-op

# results accumulator: one "id\tcategory\tstatus\tnotes" line per PT
RESULT_LINES=()

now_utc() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# --- pt_run_log emitters -----------------------------------------------------
log_block_start() { printf 'PT-ID: %s\n' "$1" >> "$LOG"; }
log_invocation() {
    # $1 command string, $2 exit code, $3 single-line stdout tail
    printf 'COMMAND: %s\n' "$1" >> "$LOG"
    printf 'EXIT_CODE: %s\n' "$2" >> "$LOG"
    printf 'STDOUT_TAIL: %s\n' "$3" >> "$LOG"
}
log_block_end() { printf '\n' >> "$LOG"; }

record() { RESULT_LINES+=("$1"$'\t'"$2"$'\t'"$3"$'\t'"$4"); }

oneline() { printf '%s' "$1" | tr '\n' '|' | tr -s ' '; }

# --- helpers -----------------------------------------------------------------
# run next_state and echo the result_state value only
call_next_state() {
    local out
    out="$($BASH_BIN "$BASELINE" next_state "$1" "$2" "$3" 2>&1)"
    printf '%s' "$out"
}
extract_result_state() {
    local line="$1" v
    v="${line#result_state=}"
    v="${v%% | *}"
    printf '%s' "$v"
}
field_value() {
    # $1 bundle text, $2 key ; echoes value or empty
    printf '%s\n' "$1" | sed -n "s/^$2=//p" | head -n1
}

# --- workflow PT runner ------------------------------------------------------
run_wf() {
    # $1 pt, $2 state, $3 trigger, $4 vp, $5 expected label
    local pt="$1" st="$2" tr="$3" vp="$4" exp="$5"
    local cmd out rc res status notes
    cmd="$BASH_BIN \"$BASELINE\" next_state \"$st\" $tr $vp"
    out="$($BASH_BIN "$BASELINE" next_state "$st" "$tr" "$vp" 2>&1)"; rc=$?
    res="$(extract_result_state "$out")"
    if [ "$res" = "$exp" ]; then status="PASS"; else status="FAIL"; fi
    notes="expected=$exp observed=$res"
    log_block_start "$pt"
    log_invocation "$cmd" "$rc" "$(oneline "$out")"
    log_block_end
    record "$pt" "runnable" "$status" "$notes"
    printf '%-7s %-6s %s\n' "$pt" "$status" "$notes"
}

# --- evidence PT runner (field presence) -------------------------------------
run_ev_present() {
    # $1 pt, $2 class, then N field names required present-nonempty
    local pt="$1" class="$2"; shift 2
    local cmd out rc status notes k v missing=""
    cmd="$BASH_BIN \"$BASELINE\" evidence $class"
    out="$($BASH_BIN "$BASELINE" evidence "$class" 2>&1)"; rc=$?
    for k in "$@"; do
        v="$(field_value "$out" "$k")"
        [ -n "$v" ] || missing="$missing $k"
    done
    if [ -z "$missing" ]; then status="PASS"; notes="all present: $*";
    else status="FAIL"; notes="missing:$missing"; fi
    log_block_start "$pt"
    log_invocation "$cmd" "$rc" "$(oneline "$out")"
    log_block_end
    record "$pt" "runnable" "$status" "$notes"
    printf '%-7s %-6s %s\n' "$pt" "$status" "$notes"
}

# --- evidence PT runner (key=value equality assertions) ----------------------
run_ev_equals() {
    # $1 pt, $2 class, then key=expected pairs
    local pt="$1" class="$2"; shift 2
    local cmd out rc status notes pair k exp v bad=""
    cmd="$BASH_BIN \"$BASELINE\" evidence $class"
    out="$($BASH_BIN "$BASELINE" evidence "$class" 2>&1)"; rc=$?
    for pair in "$@"; do
        k="${pair%%=*}"; exp="${pair#*=}"
        v="$(field_value "$out" "$k")"
        [ "$v" = "$exp" ] || bad="$bad $k(exp=$exp,got=$v)"
    done
    if [ -z "$bad" ]; then status="PASS"; notes="matched: $*";
    else status="FAIL"; notes="mismatch:$bad"; fi
    log_block_start "$pt"
    log_invocation "$cmd" "$rc" "$(oneline "$out")"
    log_block_end
    record "$pt" "runnable" "$status" "$notes"
    printf '%-7s %-6s %s\n' "$pt" "$status" "$notes"
}

# --- SKIP emitter (declarative bounded-external obligations) ------------------
run_skip() {
    local pt="$1" reason="$2"
    log_block_start "$pt"
    printf 'COMMAND: (no invocation -- SKIP: %s)\n' "$reason" >> "$LOG"
    printf 'EXIT_CODE: -1\n' >> "$LOG"
    printf 'STDOUT_TAIL: (not invoked; see pt_results.json notes)\n' >> "$LOG"
    log_block_end
    record "$pt" "declarative" "SKIP" "$reason"
    printf '%-7s %-6s %s\n' "$pt" "SKIP" "$reason"
}

# =============================================================================
# Execute the suite
# =============================================================================
: > "$LOG"   # fresh log for this run (append-only within the run)
printf '# AGT-VRA-001 bash conformance run  %s\n\n' "$(now_utc)" >> "$LOG"

echo "== Workflow transition PTs =="
run_wf PT-001 "S0 STARTUP_READONLY"      StartupComplete       true  "S1 SNAPSHOT_LOCKED"
run_wf PT-002 "S2 STRUCTURAL_VERIFIED"   StructuralChecksDone  true  "S3 ELIGIBLE_HEAD_SELECTED"
run_wf PT-003 "S3 ELIGIBLE_HEAD_SELECTED" EligibilityChecksDone true "S4 REHYDRATED_VALIDATED"
run_wf PT-004 "S2 STRUCTURAL_VERIFIED"   StructuralChecksDone  false "S5 FAIL_SAFE"
run_wf PT-005 "S2 STRUCTURAL_VERIFIED"   StructuralChecksDone  false "S5 FAIL_SAFE"
run_wf PT-006 "S2 STRUCTURAL_VERIFIED"   StructuralChecksDone  false "S5 FAIL_SAFE"
run_wf PT-007 "S2 STRUCTURAL_VERIFIED"   StructuralChecksDone  false "S5 FAIL_SAFE"
run_wf PT-008 "S3 ELIGIBLE_HEAD_SELECTED" EligibilityChecksDone false "S5 FAIL_SAFE"
run_wf PT-009 "S3 ELIGIBLE_HEAD_SELECTED" EligibilityChecksDone false "S5 FAIL_SAFE"
run_wf PT-010 "S0 STARTUP_READONLY"      StartupComplete       false "S5 FAIL_SAFE"
run_wf PT-011 "S3 ELIGIBLE_HEAD_SELECTED" RollbackDetected     true  "S5 FAIL_SAFE"
run_wf PT-012 "S5 FAIL_SAFE"             WalReplayNeeded       true  "S7 RECOVERY_REPLAY"
run_wf PT-013 "S3 ELIGIBLE_HEAD_SELECTED" ToolStateInvalid     true  "S6 TOOL_QUARANTINE"

# PT-014 composite (single row; two internal invocations in one block)
echo "== Composite PT-014 =="
{
    a_out="$($BASH_BIN "$BASELINE" next_state "S3 ELIGIBLE_HEAD_SELECTED" ToolStateInvalid true 2>&1)"; a_rc=$?
    b_out="$($BASH_BIN "$BASELINE" next_state "S3 ELIGIBLE_HEAD_SELECTED" EligibilityChecksDone true 2>&1)"; b_rc=$?
    a_res="$(extract_result_state "$a_out")"; b_res="$(extract_result_state "$b_out")"
    pt14_status="FAIL"; pt14_notes="a=$a_res b=$b_res"
    if [ "$a_res" = "S6 TOOL_QUARANTINE" ] && [ "$b_res" = "S4 REHYDRATED_VALIDATED" ] && [ "$a_res" != "$b_res" ]; then
        pt14_status="PASS"; pt14_notes="split preserved: a=$a_res b=$b_res distinct"
    fi
    log_block_start "PT-014"
    log_invocation "$BASH_BIN \"$BASELINE\" next_state \"S3 ELIGIBLE_HEAD_SELECTED\" ToolStateInvalid true" "$a_rc" "$(oneline "$a_out")"
    log_invocation "$BASH_BIN \"$BASELINE\" next_state \"S3 ELIGIBLE_HEAD_SELECTED\" EligibilityChecksDone true" "$b_rc" "$(oneline "$b_out")"
    log_block_end
    record "PT-014" "runnable" "$pt14_status" "$pt14_notes"
    printf '%-7s %-6s %s\n' "PT-014" "$pt14_status" "$pt14_notes"
}

run_wf PT-015 "S6 TOOL_QUARANTINE"       StartupComplete       true  "S6 TOOL_QUARANTINE"

echo "== Evidence PTs =="
run_ev_present PT-016 deny-chain     validator_bundle_id verified_head_digest snapshot_id
run_ev_present PT-017 deny-freshness validator_bundle_id verified_head_digest snapshot_id policy_id source_id freshness_value irr_digest tool_activation_status
run_ev_present PT-018 deny-parse     failure_code failed_validator suppression_status
run_ev_present PT-019 recovery       recovery_phase recovery_phase_producer
run_ev_present PT-020 readmission    readmission_token_id
run_ev_equals  PT-021 deny-frame     validator_bundle_id_producer=ExecutionLayer failure_explanation_producer=GateLogic tool_activation_status_producer=ToolGate

echo "== Taxonomy PTs =="
# PT-022 verdict vs state tag distinct (D4 AR-003)
{
    vq="$($BASH_BIN "$BASELINE" verdict-tag QUARANTINE 2>&1)"
    sq="$($BASH_BIN "$BASELINE" state-tag "S6 TOOL_QUARANTINE" 2>&1)"
    if [ "$vq" != "$sq" ]; then st22="PASS"; else st22="FAIL"; fi
    log_block_start "PT-022"
    log_invocation "$BASH_BIN \"$BASELINE\" verdict-tag QUARANTINE ; state-tag \"S6 TOOL_QUARANTINE\"" 0 "verdict=$vq state=$sq"
    log_block_end
    record "PT-022" "runnable" "$st22" "verdict_tag=$vq state_tag=$sq distinct=$([ "$vq" != "$sq" ] && echo yes || echo no)"
    printf '%-7s %-6s %s\n' "PT-022" "$st22" "verdict=$vq state=$sq"
}
# PT-023 DENY / ESCALATE / QUARANTINE pairwise distinct
{
    d="$($BASH_BIN "$BASELINE" verdict-tag DENY 2>&1)"
    e="$($BASH_BIN "$BASELINE" verdict-tag ESCALATE 2>&1)"
    q="$($BASH_BIN "$BASELINE" verdict-tag QUARANTINE 2>&1)"
    if [ "$d" != "$e" ] && [ "$d" != "$q" ] && [ "$e" != "$q" ]; then st23="PASS"; else st23="FAIL"; fi
    log_block_start "PT-023"
    log_invocation "$BASH_BIN \"$BASELINE\" verdict-tag DENY|ESCALATE|QUARANTINE" 0 "deny=$d escalate=$e quarantine=$q"
    log_block_end
    record "PT-023" "runnable" "$st23" "deny=$d escalate=$e quarantine=$q"
    printf '%-7s %-6s %s\n' "PT-023" "$st23" "pairwise distinct=$st23"
}

echo "== Parameterized PT-024 (buyer-declared envelope) =="
{
    o24="$($BASH_BIN "$BASELINE" next_state "S8 READMISSION_PENDING" AuthorityRelease true 2>&1)"; rc24=$?
    r24="$(extract_result_state "$o24")"
    # Buyer-declared envelope: authority_release lands in {S0 STARTUP_READONLY,
    # S1 SNAPSHOT_LOCKED} per Spec §12 transition row and PT-024/OR-20.
    case "$r24" in
        "S0 STARTUP_READONLY"|"S1 SNAPSHOT_LOCKED") st24="PASS" ;;
        *) st24="FAIL" ;;
    esac
    log_block_start "PT-024"
    log_invocation "$BASH_BIN \"$BASELINE\" next_state \"S8 READMISSION_PENDING\" AuthorityRelease true" "$rc24" "$(oneline "$o24")"
    log_block_end
    record "PT-024" "parameterized" "$st24" "envelope={S0,S1} observed=$r24"
    printf '%-7s %-6s %s\n' "PT-024" "$st24" "observed=$r24 in {S0,S1}"
}

echo "== Cross-reference evidence PTs =="
run_ev_equals PT-025 deny-freshness freshness_value=42 policy_id=POL-0001 failed_validator=V_FRESHNESS
run_ev_equals PT-026 recovery       recovery_phase=converging recovery_phase_producer=V_WAL_PHASE
run_wf        PT-027 "S3 ELIGIBLE_HEAD_SELECTED" ToolStateInvalid true "S6 TOOL_QUARANTINE"

echo "== Declarative bounded-external obligations (SKIP) =="
run_skip PT-028 "declarative/bounded-external V_COMPAT; buyer obligation = local policy bundle binding policy_id/V_POLICY/V_COMPAT (README artifact 3; Spec §16 Local policy bundle); evidenced by the deployment policy-compatibility enforcement point (DC-01 architecture evidence), not the local projection surface"
run_skip PT-029 "declarative/bounded-external V_WRITER_LOCK; buyer obligation = single-writer persistence control plane emitting writer-lock/contention evidence (README artifact 4; Spec §16 Single-writer enforcement); evidenced by the persistence control plane (DC-02 architecture evidence), not the local projection surface"

# =============================================================================
# Emit pt_results.json
# =============================================================================
total=${#RESULT_LINES[@]}; pass=0; fail=0; skip=0; error=0
json_entries=""
first=1
for line in "${RESULT_LINES[@]}"; do
    IFS=$'\t' read -r id cat status notes <<< "$line"
    case "$status" in
        PASS) pass=$((pass+1)) ;;
        FAIL) fail=$((fail+1)) ;;
        SKIP) skip=$((skip+1)) ;;
        ERROR) error=$((error+1)) ;;
    esac
    notes_esc="${notes//\\/\\\\}"; notes_esc="${notes_esc//\"/\\\"}"
    entry="    {\"id\": \"$id\", \"category\": \"$cat\", \"status\": \"$status\", \"notes\": \"$notes_esc\"}"
    if [ $first -eq 1 ]; then json_entries="$entry"; first=0; else json_entries="$json_entries,
$entry"; fi
done

cat > "$RESULTS" <<JSON
{
  "agent_id": "AGT-VRA-001",
  "lang": "bash",
  "test_run_timestamp_utc": "$(now_utc)",
  "execution_mode": "live",
  "protocol": "buyer-conformance",
  "totals": {"total": $total, "pass": $pass, "fail": $fail, "skip": $skip, "error": $error},
  "results": [
$json_entries
  ]
}
JSON

echo
echo "TOTALS total=$total pass=$pass fail=$fail skip=$skip error=$error"
echo "Wrote: $RESULTS"
echo "Wrote: $LOG"
