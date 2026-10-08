# run_pts.awk — conformance runner for the AWK derivation of AGT-VRA-001.
# Oracles encoded from the published Conformance Tests (Public Test ID / PASS oracle)
# and §14 Evidence Contract. The baseline is the implementation under test and is
# never consulted to define an oracle. Emits per-PT status + summary.

function bl(args,   cmd, line, out) {
  cmd = "awk -f " BASEDIR "/baseline.awk -- " args
  out = ""
  while ((cmd | getline line) > 0) out = out line "\n"
  close(cmd)
  return out
}
function res_state(out,   p) { p = index(out, "=> "); if (!p) return "NONE"; out = substr(out, p+3); sub(/ verdict=.*/, "", out); sub(/\n.*/, "", out); return out }
function has(out, s) { return index(out, s) > 0 }
function ns(state, trig, vp) { return bl("next_state \"" state "\" " trig " " vp) }
function report(id, ok, note) { st = ok ? "PASS" : "FAIL"; printf "%s %s %s\n", id, st, note; tot++; if (ok) pass++; else fail++ }
function skip(id, note) { printf "%s SKIP %s\n", id, note; tot++; sk++ }

BEGIN {
  BASEDIR = ENVIRON["BASEDIR"] ? ENVIRON["BASEDIR"] : "."

  # Workflow PTs (WF fixtures / OR oracles)
  report("PT-001", res_state(ns("S0 STARTUP_READONLY","StartupComplete","true"))  == "S1 SNAPSHOT_LOCKED", "OR-01")
  report("PT-002", res_state(ns("S2 STRUCTURAL_VERIFIED","StructuralChecksDone","true")) == "S3 ELIGIBLE_HEAD_SELECTED", "OR-02")
  report("PT-003", res_state(ns("S3 ELIGIBLE_HEAD_SELECTED","EligibilityChecksDone","true")) == "S4 REHYDRATED_VALIDATED", "OR-03")
  # PT-004..007 share WF-04 / OR-04 (structural corruption, parse, chain, signature -> S5)
  for (i = 4; i <= 7; i++)
    report(sprintf("PT-%03d", i), res_state(ns("S2 STRUCTURAL_VERIFIED","StructuralChecksDone","false")) == "S5 FAIL_SAFE", "OR-04")
  # PT-008/009: eligibility-class failures (freshness downgrade / IRR) -> S5
  report("PT-008", res_state(ns("S3 ELIGIBLE_HEAD_SELECTED","EligibilityChecksDone","false")) == "S5 FAIL_SAFE", "OR-05")
  report("PT-009", res_state(ns("S3 ELIGIBLE_HEAD_SELECTED","EligibilityChecksDone","false")) == "S5 FAIL_SAFE", "OR-05")
  report("PT-010", res_state(ns("S0 STARTUP_READONLY","StartupComplete","false")) == "S5 FAIL_SAFE", "OR-06")
  report("PT-011", res_state(ns("S3 ELIGIBLE_HEAD_SELECTED","RollbackDetected","true")) == "S5 FAIL_SAFE", "OR-07 any-state rollback")
  report("PT-012", res_state(ns("S5 FAIL_SAFE","WalReplayNeeded","true")) == "S7 RECOVERY_REPLAY", "OR-08")
  report("PT-013", res_state(ns("S3 ELIGIBLE_HEAD_SELECTED","ToolStateInvalid","true")) == "S6 TOOL_QUARANTINE", "OR-09")
  # PT-014 composite: S6 vs S4 split preserved
  a = res_state(ns("S3 ELIGIBLE_HEAD_SELECTED","ToolStateInvalid","true"))
  b = res_state(ns("S3 ELIGIBLE_HEAD_SELECTED","EligibilityChecksDone","true"))
  report("PT-014", a == "S6 TOOL_QUARANTINE" && b == "S4 REHYDRATED_VALIDATED" && a != b, "OR-10 boundary split")
  report("PT-015", res_state(ns("S6 TOOL_QUARANTINE","StartupComplete","true")) == "S6 TOOL_QUARANTINE", "OR-11 S6 terminal")

  # Evidence PTs (§14 contract)
  ev_rec = bl("evidence recovery")
  report("PT-016", has(ev_rec,"validator_bundle_id=") && has(ev_rec,"snapshot_id="), "closure fields")
  ev_deny = bl("evidence deny_chain")
  ok17 = has(ev_deny,"verified_head_digest=") && has(ev_deny,"snapshot_id=") && has(ev_deny,"validator_bundle_id=") && has(ev_deny,"policy_id=") && has(ev_deny,"source_id=") && has(ev_deny,"freshness_value=") && has(ev_deny,"irr_digest=") && has(ev_deny,"tool_activation_status=")
  report("PT-017", ok17, "all unconditional fields")
  ev_fr = bl("evidence deny_frame")
  report("PT-018", has(ev_fr,"failure_code=") && has(ev_fr,"failed_validator=") && has(ev_fr,"suppression_status="), "failure explanation")
  report("PT-019", has(ev_rec,"recovery_phase="), "recovery-phase activation")
  ev_rd = bl("evidence readmission")
  report("PT-020", has(ev_rd,"readmission_token_id="), "readmission-token activation")
  report("PT-021", has(ev_deny,"producer=V_CHAIN") && has(ev_deny,"producer=V_SNAPSHOT") && has(ev_deny,"producer=EXECUTION_LAYER"), "producer tags preserved")
  vt = bl("verdict_tag DENY"); stg = bl("state_tag \"S5 FAIL_SAFE\"")
  report("PT-022", vt != stg && has(vt,"DENY") && has(stg,"S5 FAIL_SAFE"), "verdict != state tag")
  v1 = bl("verdict_tag DENY"); v2 = bl("verdict_tag ESCALATE"); v3 = bl("verdict_tag QUARANTINE")
  report("PT-023", v1 != v2 && v2 != v3 && v1 != v3, "negative verdicts distinct")
  r24 = res_state(ns("S8 READMISSION_PENDING","AuthorityRelease","true"))
  report("PT-024", r24 == "S0 STARTUP_READONLY" || r24 == "S1 SNAPSHOT_LOCKED", "result in {S0,S1}, got " r24)
  ev_ff = bl("evidence deny_freshness")
  report("PT-025", has(ev_ff,"freshness_value=") && has(ev_ff,"policy_id=") && has(ev_ff,"failed_validator=V_FRESHNESS"), "cross-ref freshness")
  report("PT-026", has(ev_rec,"recovery_phase=") && has(ev_rec,"producer=V_WAL_PHASE"), "cross-ref WAL")
  report("PT-027", res_state(ns("S3 ELIGIBLE_HEAD_SELECTED","ToolStateInvalid","true")) == "S6 TOOL_QUARANTINE", "S6 directly surfaced")
  skip("PT-028", "declarative bounded-external V_COMPAT; not locally runnable by design")
  skip("PT-029", "declarative bounded-external V_WRITER_LOCK; not locally runnable by design")

  printf "SUMMARY total=%d pass=%d fail=%d skip=%d error=0\n", tot, pass, fail, sk
}
