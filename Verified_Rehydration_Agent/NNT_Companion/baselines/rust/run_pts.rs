// Verified Rehydration Agent (AGT-VRA-001) — rust conformance runner.
//
// Relocatable: it discovers its own directory from std::env::current_exe(),
// resolves the delivered baseline (baseline.exe / baseline) beside itself, and
// writes pt_run_log.txt and pt_results.json beside itself. No absolute machine
// path is baked in. Re-running the delivered runner against the delivered
// baseline reproduces the delivered pt_results.json statuses.
//
// It drives the Conformance Tests (Verified_Rehydration_Agent_Conformance_Tests.md)
// against the baseline's projection surface next_state(current_state, trigger,
// validator_passed) and its evidence surface, and applies each record's oracle.

use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

#[derive(Clone, Copy, PartialEq, Eq)]
enum Status {
    Pass,
    Fail,
    Skip,
    Error,
}

impl Status {
    fn s(self) -> &'static str {
        match self {
            Status::Pass => "PASS",
            Status::Fail => "FAIL",
            Status::Skip => "SKIP",
            Status::Error => "ERROR",
        }
    }
}

struct Invocation {
    command: String,
    exit_code: i32,
    stdout: String,
}

struct PtOutcome {
    id: String,
    category: String,
    status: Status,
    notes: String,
    invocations: Vec<Invocation>,
}

fn baseline_path(dir: &Path) -> Option<PathBuf> {
    for name in ["baseline.exe", "baseline"] {
        let p = dir.join(name);
        if p.exists() {
            return Some(p);
        }
    }
    None
}

fn invoke(bin: &Path, args: &[&str]) -> Invocation {
    let out = Command::new(bin).args(args).output();
    match out {
        Ok(o) => {
            let stdout = String::from_utf8_lossy(&o.stdout).to_string();
            let code = o.status.code().unwrap_or(-999);
            let command = format!("{} {}", bin.display(), args.join(" "));
            Invocation { command, exit_code: code, stdout }
        }
        Err(e) => Invocation {
            command: format!("{} {}", bin.display(), args.join(" ")),
            exit_code: -998,
            stdout: format!("(spawn error: {e})"),
        },
    }
}

// Parse `key=value` lines into a map.
fn kv(stdout: &str) -> BTreeMap<String, String> {
    let mut m = BTreeMap::new();
    for line in stdout.lines() {
        if let Some((k, v)) = line.split_once('=') {
            m.insert(k.trim().to_string(), v.trim().to_string());
        }
    }
    m
}

fn next_state_of(inv: &Invocation) -> Option<String> {
    kv(&inv.stdout).get("next_state").cloned()
}

fn present_nonempty(m: &BTreeMap<String, String>, keys: &[&str]) -> Result<(), String> {
    for k in keys {
        match m.get(*k) {
            Some(v) if !v.is_empty() => {}
            _ => return Err(format!("missing/empty field: {k}")),
        }
    }
    Ok(())
}

// One single-transition workflow record: invoke the projection surface and
// compare the resulting state to the oracle.
fn workflow(bin: &Path, id: &str, cat: &str, state: &str, trig: &str, vp: &str, expect: &str) -> PtOutcome {
    let inv = invoke(bin, &["transition", state, trig, vp]);
    let got = next_state_of(&inv);
    let (status, notes) = match &got {
        Some(g) if g == expect => (Status::Pass, format!("next_state={g} == {expect}")),
        Some(g) => (Status::Fail, format!("next_state={g} != expected {expect}")),
        None => (Status::Error, "no next_state in stdout".to_string()),
    };
    PtOutcome { id: id.into(), category: cat.into(), status, notes, invocations: vec![inv] }
}

fn main() {
    let exe = std::env::current_exe().expect("current_exe");
    let dir = exe.parent().expect("exe parent").to_path_buf();
    let bin = match baseline_path(&dir) {
        Some(b) => b,
        None => {
            eprintln!("baseline not found beside runner in {}", dir.display());
            std::process::exit(3);
        }
    };

    let mut outcomes: Vec<PtOutcome> = Vec::new();

    // Runnable / parameterized single-transition records.
    outcomes.push(workflow(&bin, "PT-001", "runnable", "S0", "StartupComplete", "true", "S1"));
    outcomes.push(workflow(&bin, "PT-002", "runnable", "S2", "StructuralChecksDone", "true", "S3"));
    outcomes.push(workflow(&bin, "PT-003", "runnable", "S3", "EligibilityChecksDone", "true", "S4"));
    outcomes.push(workflow(&bin, "PT-004", "runnable", "S2", "StructuralChecksDone", "false", "S5"));
    outcomes.push(workflow(&bin, "PT-005", "runnable", "S2", "StructuralChecksDone", "false", "S5"));
    outcomes.push(workflow(&bin, "PT-006", "runnable", "S2", "StructuralChecksDone", "false", "S5"));
    outcomes.push(workflow(&bin, "PT-007", "runnable", "S2", "StructuralChecksDone", "false", "S5"));
    outcomes.push(workflow(&bin, "PT-008", "runnable", "S3", "EligibilityChecksDone", "false", "S5"));
    outcomes.push(workflow(&bin, "PT-009", "runnable", "S3", "EligibilityChecksDone", "false", "S5"));
    outcomes.push(workflow(&bin, "PT-010", "runnable", "S0", "StartupComplete", "false", "S5"));
    outcomes.push(workflow(&bin, "PT-011", "runnable", "S3", "RollbackDetected", "true", "S5"));
    outcomes.push(workflow(&bin, "PT-012", "runnable", "S5", "WalReplayNeeded", "true", "S7"));
    outcomes.push(workflow(&bin, "PT-013", "runnable", "S3", "ToolStateInvalid", "true", "S6"));

    // PT-014 composite: two calls + relationship (S6 != S4).
    {
        let a = invoke(&bin, &["transition", "S3", "ToolStateInvalid", "true"]);
        let b = invoke(&bin, &["transition", "S3", "EligibilityChecksDone", "true"]);
        let ga = next_state_of(&a);
        let gb = next_state_of(&b);
        let (status, notes) = match (&ga, &gb) {
            (Some(x), Some(y)) if x == "S6" && y == "S4" && x != y => {
                (Status::Pass, "first=S6 second=S4 and distinct".to_string())
            }
            (Some(x), Some(y)) => (Status::Fail, format!("first={x} second={y}; expected S6,S4 distinct")),
            _ => (Status::Error, "missing next_state in composite".to_string()),
        };
        outcomes.push(PtOutcome {
            id: "PT-014".into(), category: "runnable".into(), status, notes,
            invocations: vec![a, b],
        });
    }

    outcomes.push(workflow(&bin, "PT-015", "runnable", "S6", "StartupComplete", "true", "S6"));

    // Evidence records.
    {
        let inv = invoke(&bin, &["evidence", "eb01"]);
        let m = kv(&inv.stdout);
        let (status, notes) = match present_nonempty(&m, &["validator_bundle_id", "verified_head_digest", "snapshot_id"]) {
            Ok(()) => (Status::Pass, "closure fields present and non-empty".into()),
            Err(e) => (Status::Fail, e),
        };
        outcomes.push(PtOutcome { id: "PT-016".into(), category: "runnable".into(), status, notes, invocations: vec![inv] });
    }
    {
        let inv = invoke(&bin, &["evidence", "eb02"]);
        let m = kv(&inv.stdout);
        let keys = ["validator_bundle_id", "verified_head_digest", "snapshot_id", "policy_id", "source_id", "freshness_value", "irr_digest", "tool_activation_status"];
        let (status, notes) = match present_nonempty(&m, &keys) {
            Ok(()) => (Status::Pass, "all 8 mandatory fields present and non-empty".into()),
            Err(e) => (Status::Fail, e),
        };
        outcomes.push(PtOutcome { id: "PT-017".into(), category: "runnable".into(), status, notes, invocations: vec![inv] });
    }
    {
        let inv = invoke(&bin, &["evidence", "eb03"]);
        let m = kv(&inv.stdout);
        let (status, notes) = match present_nonempty(&m, &["failure_code", "failed_validator", "suppression_status"]) {
            Ok(()) => (Status::Pass, "failure-explanation fields present".into()),
            Err(e) => (Status::Fail, e),
        };
        outcomes.push(PtOutcome { id: "PT-018".into(), category: "runnable".into(), status, notes, invocations: vec![inv] });
    }
    {
        let inv = invoke(&bin, &["evidence", "eb05"]);
        let m = kv(&inv.stdout);
        let (status, notes) = match present_nonempty(&m, &["recovery_phase", "recovery_phase_producer"]) {
            Ok(()) => (Status::Pass, "recovery_phase and producer present".into()),
            Err(e) => (Status::Fail, e),
        };
        outcomes.push(PtOutcome { id: "PT-019".into(), category: "runnable".into(), status, notes, invocations: vec![inv] });
    }
    {
        let inv = invoke(&bin, &["evidence", "eb06"]);
        let m = kv(&inv.stdout);
        let (status, notes) = match present_nonempty(&m, &["readmission_token_id"]) {
            Ok(()) => (Status::Pass, "readmission_token_id present".into()),
            Err(e) => (Status::Fail, e),
        };
        outcomes.push(PtOutcome { id: "PT-020".into(), category: "runnable".into(), status, notes, invocations: vec![inv] });
    }
    {
        let inv = invoke(&bin, &["evidence", "eb04"]);
        let m = kv(&inv.stdout);
        let want = [
            ("validator_bundle_id_producer", "ExecutionLayer"),
            ("failure_explanation_producer", "GateLogic"),
            ("tool_activation_status_producer", "ToolGate"),
        ];
        let mut err = None;
        for (k, v) in want {
            if m.get(k).map(|s| s.as_str()) != Some(v) {
                err = Some(format!("producer {k} != {v} (got {:?})", m.get(k)));
                break;
            }
        }
        let (status, notes) = match err {
            None => (Status::Pass, "producer tags match".into()),
            Some(e) => (Status::Fail, e),
        };
        outcomes.push(PtOutcome { id: "PT-021".into(), category: "runnable".into(), status, notes, invocations: vec![inv] });
    }
    {
        let inv = invoke(&bin, &["verdict-tag", "QUARANTINE"]);
        let vinv = invoke(&bin, &["state-tag", "S6"]);
        let vt = kv(&inv.stdout).get("verdict_tag").cloned();
        let st = kv(&vinv.stdout).get("state_tag").cloned();
        let (status, notes) = match (&vt, &st) {
            (Some(a), Some(b)) if a != b => (Status::Pass, format!("verdict_tag {a} distinct from state_tag {b}")),
            (Some(a), Some(b)) => (Status::Fail, format!("tags collapsed: {a} == {b}")),
            _ => (Status::Error, "missing tag output".into()),
        };
        outcomes.push(PtOutcome { id: "PT-022".into(), category: "runnable".into(), status, notes, invocations: vec![inv, vinv] });
    }
    {
        let d = invoke(&bin, &["verdict-tag", "DENY"]);
        let e = invoke(&bin, &["verdict-tag", "ESCALATE"]);
        let q = invoke(&bin, &["verdict-tag", "QUARANTINE"]);
        let td = kv(&d.stdout).get("verdict_tag").cloned();
        let te = kv(&e.stdout).get("verdict_tag").cloned();
        let tq = kv(&q.stdout).get("verdict_tag").cloned();
        let (status, notes) = match (&td, &te, &tq) {
            (Some(a), Some(b), Some(c)) if a != b && b != c && a != c => {
                (Status::Pass, "Deny/Escalate/Quarantine pairwise distinct".into())
            }
            (Some(a), Some(b), Some(c)) => (Status::Fail, format!("not pairwise distinct: {a},{b},{c}")),
            _ => (Status::Error, "missing tag output".into()),
        };
        outcomes.push(PtOutcome { id: "PT-023".into(), category: "runnable".into(), status, notes, invocations: vec![d, e, q] });
    }

    // PT-024 parameterized: authority-release branch, result in {S0,S1}.
    {
        let inv = invoke(&bin, &["transition", "S8", "AuthorityRelease", "true"]);
        let got = next_state_of(&inv);
        let (status, notes) = match &got {
            Some(g) if g == "S0" || g == "S1" => (Status::Pass, format!("declared envelope landed in {{S0,S1}}: {g}")),
            Some(g) => (Status::Fail, format!("landed outside {{S0,S1}}: {g}")),
            None => (Status::Error, "no next_state".into()),
        };
        outcomes.push(PtOutcome { id: "PT-024".into(), category: "parameterized".into(), status, notes, invocations: vec![inv] });
    }

    // Cross-reference evidence records.
    {
        let inv = invoke(&bin, &["evidence", "eb02"]);
        let m = kv(&inv.stdout);
        let ok = m.get("freshness_value").map(|s| !s.is_empty()).unwrap_or(false)
            && m.get("policy_id").map(|s| !s.is_empty()).unwrap_or(false)
            && m.get("failed_validator").map(|s| s == "V_FRESHNESS").unwrap_or(false);
        let (status, notes) = if ok {
            (Status::Pass, "freshness_value+policy_id present; failed_validator=V_FRESHNESS".into())
        } else {
            (Status::Fail, format!("freshness/policy/failed_validator mismatch: {:?}", m.get("failed_validator")))
        };
        outcomes.push(PtOutcome { id: "PT-025".into(), category: "runnable".into(), status, notes, invocations: vec![inv] });
    }
    {
        let inv = invoke(&bin, &["evidence", "eb05"]);
        let m = kv(&inv.stdout);
        let ok = m.get("recovery_phase").map(|s| !s.is_empty()).unwrap_or(false)
            && m.get("recovery_phase_producer").map(|s| s == "V_WAL_PHASE").unwrap_or(false);
        let (status, notes) = if ok {
            (Status::Pass, "recovery_phase present; producer=V_WAL_PHASE".into())
        } else {
            (Status::Fail, format!("recovery_phase/producer mismatch: {:?}", m.get("recovery_phase_producer")))
        };
        outcomes.push(PtOutcome { id: "PT-026".into(), category: "runnable".into(), status, notes, invocations: vec![inv] });
    }

    outcomes.push(workflow(&bin, "PT-027", "runnable", "S3", "ToolStateInvalid", "true", "S6"));

    // Declarative bounded-external obligations — not locally runnable by design
    // (Conformance Tests §4 Minimal Run Note "Bounded external obligations not
    // locally runnable"). Recorded SKIP, never ERROR.
    outcomes.push(PtOutcome {
        id: "PT-028".into(), category: "declarative".into(), status: Status::Skip,
        notes: "V_COMPAT bounded external enforcement (import_admissibility / policy-compatibility subsystem); buyer deployment obligation §16 'Local policy bundle'; proved by architecture evidence, not the local transition surface.".into(),
        invocations: vec![],
    });
    outcomes.push(PtOutcome {
        id: "PT-029".into(), category: "declarative".into(), status: Status::Skip,
        notes: "V_WRITER_LOCK distributed enforcement (persistence control plane / deployment conformance); buyer deployment obligation §16 'Single-writer enforcement'; proved by architecture evidence, not the local transition surface.".into(),
        invocations: vec![],
    });

    // ---- write pt_run_log.txt ----
    let mut log = String::new();
    for o in &outcomes {
        log.push_str(&format!("PT-ID: {}\n", o.id));
        if o.invocations.is_empty() {
            // SKIP block: explicit non-invocation marker.
            log.push_str(&format!(
                "COMMAND: (no invocation -- SKIP: declarative bounded-external obligation, not locally runnable)\n"
            ));
            log.push_str("EXIT_CODE: -1\n");
            log.push_str("STDOUT_TAIL: (not invoked; see pt_results.json notes)\n");
        } else {
            for inv in &o.invocations {
                log.push_str(&format!("COMMAND: {}\n", inv.command));
                log.push_str(&format!("EXIT_CODE: {}\n", inv.exit_code));
                let tail = tail_bytes(&inv.stdout, 4096);
                log.push_str(&format!("STDOUT_TAIL: {}\n", tail.replace('\n', " | ")));
            }
        }
        log.push('\n');
    }
    let log_path = dir.join("pt_run_log.txt");
    fs::write(&log_path, &log).expect("write pt_run_log");

    // ---- write pt_results.json ----
    let (mut np, mut nf, mut ns, mut ne) = (0, 0, 0, 0);
    for o in &outcomes {
        match o.status {
            Status::Pass => np += 1,
            Status::Fail => nf += 1,
            Status::Skip => ns += 1,
            Status::Error => ne += 1,
        }
    }
    let total = outcomes.len();
    let mut json = String::new();
    json.push_str("{\n");
    json.push_str("  \"agent_id\": \"AGT-VRA-001\",\n");
    json.push_str("  \"lang\": \"rust\",\n");
    json.push_str(&format!("  \"test_run_timestamp_utc\": \"{}\",\n", iso_utc()));
    json.push_str("  \"execution_mode\": \"live\",\n");
    json.push_str("  \"protocol\": \"buyer-conformance\",\n");
    json.push_str(&format!(
        "  \"totals\": {{\"total\": {total}, \"pass\": {np}, \"fail\": {nf}, \"skip\": {ns}, \"error\": {ne}}},\n"
    ));
    json.push_str("  \"results\": [\n");
    for (i, o) in outcomes.iter().enumerate() {
        let comma = if i + 1 < outcomes.len() { "," } else { "" };
        json.push_str(&format!(
            "    {{\"id\": \"{}\", \"category\": \"{}\", \"status\": \"{}\", \"notes\": \"{}\"}}{}\n",
            o.id, o.category, o.status.s(), json_escape(&o.notes), comma
        ));
    }
    json.push_str("  ]\n");
    json.push_str("}\n");
    let json_path = dir.join("pt_results.json");
    fs::write(&json_path, &json).expect("write pt_results");

    println!(
        "conformance run complete: total={total} pass={np} fail={nf} skip={ns} error={ne}"
    );
    println!("log: {}", log_path.display());
    println!("results: {}", json_path.display());
}

fn tail_bytes(s: &str, n: usize) -> String {
    let b = s.as_bytes();
    if b.len() <= n {
        s.to_string()
    } else {
        String::from_utf8_lossy(&b[b.len() - n..]).to_string()
    }
}

fn json_escape(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"").replace('\n', " ")
}

// Minimal UTC timestamp without external crates (seconds since epoch, ISO-ish).
fn iso_utc() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let secs = SystemTime::now().duration_since(UNIX_EPOCH).map(|d| d.as_secs()).unwrap_or(0);
    format!("epoch-{secs}Z")
}
