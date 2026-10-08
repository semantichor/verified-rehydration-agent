# AGT-VRA-001 — AWK derivation (pattern-action / data-driven).
# Derived ONLY from the pack: Specification §6 (verdicts), §12 (state+transition
# model), §13 (gate logic), §14 (evidence contract), §17 (scenarios), Semantic
# Index (canonical labels; TR-008 canonical member S0 for authority_release).
# Surfaces: next_state | evidence | verdict_tag | state_tag
# Fail-closed choices (declared open mechanism, constraint: no unverified
# progression): unknown tokens and unmapped (state,trigger) pairs -> ERROR exit 2.
# Idiom: the §12 transition model is DATA (records), matched by pattern rules.

BEGIN {
  # --- §12 state model: canonical labels (Semantic Index ST-*) ---
  split("S0 STARTUP_READONLY|S1 SNAPSHOT_LOCKED|S2 STRUCTURAL_VERIFIED|S3 ELIGIBLE_HEAD_SELECTED|S4 REHYDRATED_VALIDATED|S5 FAIL_SAFE|S6 TOOL_QUARANTINE|S7 RECOVERY_REPLAY|S8 READMISSION_PENDING", SL, "|")
  for (i in SL) { STATE[SL[i]] = 1 }

  # --- trigger vocabulary (§12 rows, CT fixture tokens) ---
  split("StartupComplete SnapshotLocked StructuralChecksDone EligibilityChecksDone RollbackDetected ToolStateInvalid WalReplayNeeded RecoveryConverged AuthorityRelease", TG, " ")
  for (i in TG) { TRIG[TG[i]] = 1 }

  # --- §12 transition model as data: key -> "pass_target;fail_target" ---
  T["S0 STARTUP_READONLY|StartupComplete"]        = "S1 SNAPSHOT_LOCKED;S5 FAIL_SAFE"
  T["S1 SNAPSHOT_LOCKED|SnapshotLocked"]          = "S2 STRUCTURAL_VERIFIED;S5 FAIL_SAFE"
  T["S2 STRUCTURAL_VERIFIED|StructuralChecksDone"]= "S3 ELIGIBLE_HEAD_SELECTED;S5 FAIL_SAFE"
  T["S3 ELIGIBLE_HEAD_SELECTED|EligibilityChecksDone"] = "S4 REHYDRATED_VALIDATED;S5 FAIL_SAFE"
  T["S3 ELIGIBLE_HEAD_SELECTED|ToolStateInvalid"] = "S6 TOOL_QUARANTINE;S6 TOOL_QUARANTINE"
  T["S5 FAIL_SAFE|WalReplayNeeded"]               = "S7 RECOVERY_REPLAY;S5 FAIL_SAFE"
  T["S7 RECOVERY_REPLAY|RecoveryConverged"]       = "S8 READMISSION_PENDING;S5 FAIL_SAFE"
  # §12: S8 + authority_release -> "S0 or S1"; Semantic Index TR-008 canonical member = S0.
  T["S8 READMISSION_PENDING|AuthorityRelease"]    = "S0 STARTUP_READONLY;S8 READMISSION_PENDING"

  # --- §6 verdict vocabulary; §13 gate -> verdict projection ---
  split("ALLOW DENY QUARANTINE ESCALATE READMISSION_PENDING", VV, " ")
  for (i in VV) { VERD[VV[i]] = 1 }
  V["S4 REHYDRATED_VALIDATED"] = "ALLOW";   V["S5 FAIL_SAFE"] = "DENY"
  V["S6 TOOL_QUARANTINE"] = "QUARANTINE";   V["S8 READMISSION_PENDING"] = "READMISSION_PENDING"

  cmd = ARGV[1]
  if (cmd == "next_state")  { do_next(ARGV[2], ARGV[3], ARGV[4]); exit rc }
  if (cmd == "evidence")    { do_evidence(ARGV[2]); exit rc }
  if (cmd == "verdict_tag") { if (ARGV[2] in VERD) print ARGV[2]; else fatal("unknown verdict token: " ARGV[2]); exit rc }
  if (cmd == "state_tag")   { if (ARGV[2] in STATE) print ARGV[2]; else fatal("unknown state token: " ARGV[2]); exit rc }
  fatal("unknown surface: " cmd); exit rc
}

function fatal(msg) { print "ERROR " msg; rc = 2 }

function do_next(s, tr, vp,    key, pf, n, parts, res) {
  if (!(s in STATE))  { fatal("unknown state token: " s);  return }
  if (!(tr in TRIG))  { fatal("unknown trigger token: " tr); return }
  if (vp != "true" && vp != "false") { fatal("unknown validator token: " vp); return }
  # §12: rollback_detected has blocking priority from ANY state -> S5.
  if (tr == "RollbackDetected") { emit(s, tr, vp, "S5 FAIL_SAFE"); return }
  # OR-11: S6 remains stable / terminal on the exposed projection surface.
  if (s == "S6 TOOL_QUARANTINE") { emit(s, tr, vp, "S6 TOOL_QUARANTINE"); return }
  key = s "|" tr
  if (!(key in T)) { fatal("no transition defined: " key); return }  # fail-closed: reject
  n = split(T[key], parts, ";")
  res = (vp == "true") ? parts[1] : parts[2]
  emit(s, tr, vp, res)
}

function emit(s, tr, vp, res) {
  print "next_state current_state=" s " trigger=" tr " validator_passed=" vp " => " res " verdict=" ((res in V) ? V[res] : "NONE")
}

# --- §14 evidence contract: unconditional bundle + conditional activations ---
function core(sup) {
  print "validator_bundle_id=VB-0001 producer=EXECUTION_LAYER"
  print "verified_head_digest=HD-0001 producer=V_CHAIN"
  print "snapshot_id=SNAP-0001 producer=V_SNAPSHOT"
  print "policy_id=POL-0001 producer=V_POLICY"
  print "source_id=SRC-0001 producer=V_FRESHNESS"
  print "freshness_value=FV-0001 producer=V_FRESHNESS"
  print "irr_digest=IRR-0001 producer=V_IRR"
  print "tool_activation_status=inactive producer=TOOL_GATE"
  print "suppression_status=" sup " producer=GATE_LOGIC"
}
function do_evidence(kind) {
  if (kind == "deny_frame")     { core("SUPPRESSED"); print "failure_code=FRAME_INVALID producer=GATE_LOGIC";        print "failed_validator=V_FRAME producer=GATE_LOGIC"; return }
  if (kind == "deny_parse")     { core("SUPPRESSED"); print "failure_code=PARSE_AMBIGUOUS producer=GATE_LOGIC";      print "failed_validator=V_PARSE producer=GATE_LOGIC"; return }
  if (kind == "deny_chain")     { core("SUPPRESSED"); print "failure_code=CHAIN_BREAK producer=GATE_LOGIC";          print "failed_validator=V_CHAIN producer=GATE_LOGIC"; return }
  if (kind == "deny_freshness") { core("SUPPRESSED"); print "failure_code=FRESHNESS_DOWNGRADE producer=GATE_LOGIC";  print "failed_validator=V_FRESHNESS producer=GATE_LOGIC"; return }
  if (kind == "recovery")       { core("SUPPRESSED"); print "recovery_phase=REPLAY_IN_PROGRESS producer=V_WAL_PHASE"; return }
  if (kind == "readmission")    { core("SUPPRESSED"); print "readmission_token_id=RT-0001 producer=READMISSION_AUTHORITY"; return }
  fatal("unknown evidence kind: " kind)
}
