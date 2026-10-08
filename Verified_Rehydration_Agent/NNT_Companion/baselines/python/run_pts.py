#!/usr/bin/env python3
"""NNT R6 conformance runner for AGT-VRA-001 -- python.

Relocatable by construction: it discovers its own directory from __file__ and
resolves baseline.py and its output files relative to itself, and it invokes the
baseline through the current interpreter (sys.executable). Re-running the
delivered run_pts.py against the delivered baseline.py reproduces the delivered
pt_results.json statuses.

It drives the Public Conformance Tests (Verified_Rehydration_Agent_Conformance_
Tests.md): for each runnable / parameterized record it invokes the baseline with
the documented fixture, captures stdout, and applies the documented PASS oracle;
for each declarative bounded-external record (PT-028, PT-029) it records a SKIP
with an attestation note (the Minimal Run Note names these as not locally
runnable). Composite PT-014 is one row / one block with two internal invocations.
"""
from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Callable, Optional

SCRIPT_DIR = Path(__file__).resolve().parent
BASELINE = SCRIPT_DIR / "baseline.py"
LOG_PATH = SCRIPT_DIR / "pt_run_log.txt"
RESULTS_PATH = SCRIPT_DIR / "pt_results.json"
INTERP = sys.executable

# PT-024 buyer-declared parameter envelope (bounded by spec 12 "S0 or S1" and
# Conformance OR-20). This run declares the admissible target set explicitly.
PT024_ENVELOPE = {"S0 STARTUP_READONLY", "S1 SNAPSHOT_LOCKED"}


def invoke(step_args: list[str]) -> tuple[str, int, str]:
    """Run the baseline with step_args; return (command_string, exit_code, stdout)."""
    cmd = [INTERP, str(BASELINE), *step_args]
    cmd_str = " ".join(f'"{c}"' if " " in c else c for c in cmd)
    proc = subprocess.run(cmd, capture_output=True, text=True)
    out = proc.stdout if proc.returncode == 0 else (proc.stdout + proc.stderr)
    return cmd_str, proc.returncode, out


# --- Oracle helpers ---------------------------------------------------------


def _result_state(stdout: str) -> str:
    return json.loads(stdout)["result_state"]


def _bundle(stdout: str) -> dict:
    return json.loads(stdout)["bundle"]


def _present_nonempty(bundle: dict, fields: tuple[str, ...]) -> tuple[bool, str]:
    missing = [f for f in fields if not str(bundle.get(f, "")).strip()]
    if missing:
        return False, f"missing/empty: {missing}"
    return True, f"present+non-empty: {list(fields)}"


def _present(bundle: dict, fields: tuple[str, ...]) -> tuple[bool, str]:
    missing = [f for f in fields if f not in bundle]
    if missing:
        return False, f"absent: {missing}"
    return True, f"present: {list(fields)}"


# --- PT specifications ------------------------------------------------------
# Each entry: id, category, list of step-arg lists, oracle(list_of_stdout)->(bool,note)


def _eq_state(expected: str) -> Callable[[list[str]], tuple[bool, str]]:
    def oracle(outs: list[str]) -> tuple[bool, str]:
        got = _result_state(outs[0])
        return got == expected, f"result_state={got!r} expected={expected!r}"
    return oracle


PT_SPECS: list[dict] = [
    {"id": "PT-001", "cat": "runnable", "steps": [["transition", "--state", "S0 STARTUP_READONLY", "--trigger", "StartupComplete", "--validator-passed", "true"]], "oracle": _eq_state("S1 SNAPSHOT_LOCKED")},
    {"id": "PT-002", "cat": "runnable", "steps": [["transition", "--state", "S2 STRUCTURAL_VERIFIED", "--trigger", "StructuralChecksDone", "--validator-passed", "true"]], "oracle": _eq_state("S3 ELIGIBLE_HEAD_SELECTED")},
    {"id": "PT-003", "cat": "runnable", "steps": [["transition", "--state", "S3 ELIGIBLE_HEAD_SELECTED", "--trigger", "EligibilityChecksDone", "--validator-passed", "true"]], "oracle": _eq_state("S4 REHYDRATED_VALIDATED")},
    {"id": "PT-004", "cat": "runnable", "steps": [["transition", "--state", "S2 STRUCTURAL_VERIFIED", "--trigger", "StructuralChecksDone", "--validator-passed", "false"]], "oracle": _eq_state("S5 FAIL_SAFE")},
    {"id": "PT-005", "cat": "runnable", "steps": [["transition", "--state", "S2 STRUCTURAL_VERIFIED", "--trigger", "StructuralChecksDone", "--validator-passed", "false"]], "oracle": _eq_state("S5 FAIL_SAFE")},
    {"id": "PT-006", "cat": "runnable", "steps": [["transition", "--state", "S2 STRUCTURAL_VERIFIED", "--trigger", "StructuralChecksDone", "--validator-passed", "false"]], "oracle": _eq_state("S5 FAIL_SAFE")},
    {"id": "PT-007", "cat": "runnable", "steps": [["transition", "--state", "S2 STRUCTURAL_VERIFIED", "--trigger", "StructuralChecksDone", "--validator-passed", "false"]], "oracle": _eq_state("S5 FAIL_SAFE")},
    {"id": "PT-008", "cat": "runnable", "steps": [["transition", "--state", "S3 ELIGIBLE_HEAD_SELECTED", "--trigger", "EligibilityChecksDone", "--validator-passed", "false"]], "oracle": _eq_state("S5 FAIL_SAFE")},
    {"id": "PT-009", "cat": "runnable", "steps": [["transition", "--state", "S3 ELIGIBLE_HEAD_SELECTED", "--trigger", "EligibilityChecksDone", "--validator-passed", "false"]], "oracle": _eq_state("S5 FAIL_SAFE")},
    {"id": "PT-010", "cat": "runnable", "steps": [["transition", "--state", "S0 STARTUP_READONLY", "--trigger", "StartupComplete", "--validator-passed", "false"]], "oracle": _eq_state("S5 FAIL_SAFE")},
    {"id": "PT-011", "cat": "runnable", "steps": [["transition", "--state", "S3 ELIGIBLE_HEAD_SELECTED", "--trigger", "RollbackDetected", "--validator-passed", "true"]], "oracle": _eq_state("S5 FAIL_SAFE")},
    {"id": "PT-012", "cat": "runnable", "steps": [["transition", "--state", "S5 FAIL_SAFE", "--trigger", "WalReplayNeeded", "--validator-passed", "true"]], "oracle": _eq_state("S7 RECOVERY_REPLAY")},
    {"id": "PT-013", "cat": "runnable", "steps": [["transition", "--state", "S3 ELIGIBLE_HEAD_SELECTED", "--trigger", "ToolStateInvalid", "--validator-passed", "true"]], "oracle": _eq_state("S6 TOOL_QUARANTINE")},
    {"id": "PT-015", "cat": "runnable", "steps": [["transition", "--state", "S6 TOOL_QUARANTINE", "--trigger", "StartupComplete", "--validator-passed", "true"]], "oracle": _eq_state("S6 TOOL_QUARANTINE")},
    {"id": "PT-016", "cat": "runnable", "steps": [["evidence", "--fixture", "EB-01"]], "oracle": lambda o: _present_nonempty(_bundle(o[0]), ("validator_bundle_id", "verified_head_digest", "snapshot_id"))},
    {"id": "PT-017", "cat": "runnable", "steps": [["evidence", "--fixture", "EB-02"]], "oracle": lambda o: _present_nonempty(_bundle(o[0]), ("validator_bundle_id", "verified_head_digest", "snapshot_id", "policy_id", "source_id", "freshness_value", "irr_digest", "tool_activation_status"))},
    {"id": "PT-018", "cat": "runnable", "steps": [["evidence", "--fixture", "EB-03"]], "oracle": lambda o: _present(_bundle(o[0]), ("failure_code", "failed_validator", "suppression_status"))},
    {"id": "PT-019", "cat": "runnable", "steps": [["evidence", "--fixture", "EB-05"]], "oracle": lambda o: _present(_bundle(o[0]), ("recovery_phase", "recovery_phase_producer"))},
    {"id": "PT-020", "cat": "runnable", "steps": [["evidence", "--fixture", "EB-06"]], "oracle": lambda o: _present(_bundle(o[0]), ("readmission_token_id",))},
    {"id": "PT-021", "cat": "runnable", "steps": [["evidence", "--fixture", "EB-04"]], "oracle": None},   # producer oracle, set below
    {"id": "PT-022", "cat": "runnable", "steps": [["taxonomy"]], "oracle": None},                         # taxonomy oracle, set below
    {"id": "PT-023", "cat": "runnable", "steps": [["taxonomy"]], "oracle": None},                         # taxonomy oracle, set below
    {"id": "PT-024", "cat": "parameterized", "steps": [["transition", "--state", "S8 READMISSION_PENDING", "--trigger", "AuthorityRelease", "--validator-passed", "true"]], "oracle": None},  # membership, set below
    {"id": "PT-025", "cat": "runnable", "steps": [["evidence", "--fixture", "EB-02"]], "oracle": None},   # cross-ref oracle, set below
    {"id": "PT-026", "cat": "runnable", "steps": [["evidence", "--fixture", "EB-05"]], "oracle": None},   # cross-ref oracle, set below
    {"id": "PT-027", "cat": "runnable", "steps": [["transition", "--state", "S3 ELIGIBLE_HEAD_SELECTED", "--trigger", "ToolStateInvalid", "--validator-passed", "true"]], "oracle": _eq_state("S6 TOOL_QUARANTINE")},
    # PT-014 composite handled specially below (two invocations, one row/block).
    {"id": "PT-028", "cat": "declarative", "steps": [], "oracle": None,
     "skip": "declarative/parameterized deployment-substrate boundary, not locally runnable",
     "note": "SKIP (declarative bounded external): V_COMPAT policy-compatibility enforcement is bounded in import_admissibility / policy subsystem (Conformance Tests 4 Minimal Run Note; spec 16 Deployment obligations 'Local policy bundle'). Buyer obligation proved by architecture evidence: the deployment's local versioned policy bundle binding policy_id, V_POLICY, and V_COMPAT (README 'What your team must produce' #3)."},
    {"id": "PT-029", "cat": "declarative", "steps": [], "oracle": None,
     "skip": "declarative/parameterized deployment-substrate boundary, not locally runnable",
     "note": "SKIP (declarative bounded external): V_WRITER_LOCK single-writer enforcement is bounded in the persistence control plane / deployment conformance layer (Conformance Tests 4 Minimal Run Note; spec 16 Deployment obligations 'Single-writer enforcement'). Buyer obligation proved by architecture evidence: the deployment's single-writer persistence control plane emitting writer-lock and contention evidence (README 'What your team must produce' #4)."},
]


# Fill the oracles that need multi-field / structured logic.
def _oracle_pt021(outs: list[str]) -> tuple[bool, str]:
    b = _bundle(outs[0])
    checks = {
        "validator_bundle_id_producer": "ExecutionLayer",
        "failure_explanation_producer": "GateLogic",
        "tool_activation_status_producer": "ToolGate",
    }
    bad = {k: b.get(k) for k, v in checks.items() if b.get(k) != v}
    return (not bad), (f"producers ok: {checks}" if not bad else f"producer mismatch: {bad}")


def _oracle_pt022(outs: list[str]) -> tuple[bool, str]:
    tax = json.loads(outs[0])
    v = tax["verdict_tags"]["QUARANTINE"]
    s = tax["state_tags"]["S6_TOOL_QUARANTINE"]
    return v != s, f"verdict_tag={v!r} state_tag={s!r} distinct={v != s}"


def _oracle_pt023(outs: list[str]) -> tuple[bool, str]:
    d = json.loads(outs[0])["verdict_discriminants"]
    trio = [d["DENY"], d["ESCALATE"], d["QUARANTINE"]]
    distinct = len(set(trio)) == 3
    return distinct, f"discriminants DENY/ESCALATE/QUARANTINE={trio} pairwise_distinct={distinct}"


def _oracle_pt024(outs: list[str]) -> tuple[bool, str]:
    got = _result_state(outs[0])
    return got in PT024_ENVELOPE, f"result_state={got!r} in declared envelope {sorted(PT024_ENVELOPE)}"


def _oracle_pt025(outs: list[str]) -> tuple[bool, str]:
    b = _bundle(outs[0])
    ok_present, note = _present_nonempty(b, ("freshness_value", "policy_id"))
    ok_fv = b.get("failed_validator") == "V_FRESHNESS"
    return (ok_present and ok_fv), f"{note}; failed_validator={b.get('failed_validator')!r} (expect V_FRESHNESS)"


def _oracle_pt026(outs: list[str]) -> tuple[bool, str]:
    b = _bundle(outs[0])
    ok_present, note = _present(b, ("recovery_phase",))
    ok_pr = b.get("recovery_phase_producer") == "V_WAL_PHASE"
    return (ok_present and ok_pr), f"{note}; recovery_phase_producer={b.get('recovery_phase_producer')!r} (expect V_WAL_PHASE)"


_ORACLE_OVERRIDES = {
    "PT-021": _oracle_pt021, "PT-022": _oracle_pt022, "PT-023": _oracle_pt023,
    "PT-024": _oracle_pt024, "PT-025": _oracle_pt025, "PT-026": _oracle_pt026,
}
for _spec in PT_SPECS:
    if _spec["id"] in _ORACLE_OVERRIDES:
        _spec["oracle"] = _ORACLE_OVERRIDES[_spec["id"]]


# --- Log writing ------------------------------------------------------------


def _log_block(fh, pt_id: str, invocations: list[tuple[str, int, str]]) -> None:
    fh.write(f"PT-ID: {pt_id}\n")
    if not invocations:
        fh.write("COMMAND: (no invocation -- SKIP: declarative/parameterized deployment-substrate boundary, not locally runnable)\n")
        fh.write("EXIT_CODE: -1\n")
        fh.write("STDOUT_TAIL: (not invoked; see pt_results.json notes)\n\n")
        return
    for cmd_str, code, out in invocations:
        tail = out[-4096:]
        fh.write(f"COMMAND: {cmd_str}\n")
        fh.write(f"EXIT_CODE: {code}\n")
        fh.write(f"STDOUT_TAIL: {tail.strip()}\n")
    fh.write("\n")


# --- Main run ---------------------------------------------------------------


def run() -> dict:
    results: list[dict] = []
    with open(LOG_PATH, "w", encoding="utf-8") as fh:
        # Ordered run: PT-001..PT-013, then composite PT-014, then PT-015.., PT-029.
        ordered = ["PT-001", "PT-002", "PT-003", "PT-004", "PT-005", "PT-006", "PT-007",
                   "PT-008", "PT-009", "PT-010", "PT-011", "PT-012", "PT-013", "PT-014",
                   "PT-015", "PT-016", "PT-017", "PT-018", "PT-019", "PT-020", "PT-021",
                   "PT-022", "PT-023", "PT-024", "PT-025", "PT-026", "PT-027", "PT-028", "PT-029"]
        specs_by_id = {s["id"]: s for s in PT_SPECS}

        for pt_id in ordered:
            if pt_id == "PT-014":
                # Composite: two invocations, one row/one block.
                cmd_a, code_a, out_a = invoke(["transition", "--state", "S3 ELIGIBLE_HEAD_SELECTED", "--trigger", "ToolStateInvalid", "--validator-passed", "true"])
                cmd_b, code_b, out_b = invoke(["transition", "--state", "S3 ELIGIBLE_HEAD_SELECTED", "--trigger", "EligibilityChecksDone", "--validator-passed", "true"])
                try:
                    ra, rb = _result_state(out_a), _result_state(out_b)
                    passed = (ra == "S6 TOOL_QUARANTINE" and rb == "S4 REHYDRATED_VALIDATED" and ra != rb)
                    note = f"(a)={ra!r} (b)={rb!r} distinct={ra != rb}"
                    status = "PASS" if passed else "FAIL"
                except Exception as exc:  # unexpected runtime failure of a should-run PT
                    status, note = "ERROR", f"composite invocation error: {exc}"
                _log_block(fh, pt_id, [(cmd_a, code_a, out_a), (cmd_b, code_b, out_b)])
                results.append({"id": pt_id, "category": "runnable", "status": status, "notes": note})
                continue

            spec = specs_by_id[pt_id]
            if spec["cat"] == "declarative":
                _log_block(fh, pt_id, [])
                results.append({"id": pt_id, "category": "declarative", "status": "SKIP", "notes": spec["note"]})
                continue

            invocations = [invoke(step) for step in spec["steps"]]
            try:
                if any(code != 0 for _c, code, _o in invocations):
                    status = "ERROR"
                    note = "non-zero exit on a runnable PT: " + "; ".join(f"exit={c}" for _s, c, _o in invocations)
                else:
                    ok, note = spec["oracle"]([o for _c, _code, o in invocations])
                    status = "PASS" if ok else "FAIL"
            except Exception as exc:
                status, note = "ERROR", f"oracle/runtime error: {exc}"
            if pt_id == "PT-024":
                note = "declared envelope {S0 STARTUP_READONLY, S1 SNAPSHOT_LOCKED} per spec 12 / OR-20; " + note
            _log_block(fh, pt_id, invocations)
            results.append({"id": pt_id, "category": spec["cat"], "status": status, "notes": note})

    totals = {"total": len(results), "pass": 0, "fail": 0, "skip": 0, "error": 0}
    for r in results:
        totals[r["status"].lower()] = totals.get(r["status"].lower(), 0) + 1

    record = {
        "agent_id": "AGT-VRA-001",
        "lang": "python",
        "test_run_timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "execution_mode": "live",
        "protocol": "buyer-conformance",
        "totals": totals,
        "results": results,
    }
    RESULTS_PATH.write_text(json.dumps(record, indent=2, ensure_ascii=False), encoding="utf-8")
    return record


if __name__ == "__main__":
    rec = run()
    t = rec["totals"]
    print(f"AGT-VRA-001 python conformance: total={t['total']} pass={t['pass']} "
          f"fail={t['fail']} skip={t['skip']} error={t['error']}")
    print(f"log: {LOG_PATH}")
    print(f"results: {RESULTS_PATH}")
