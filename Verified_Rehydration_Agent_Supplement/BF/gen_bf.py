#!/usr/bin/env python3
"""Projection of AGT-VRA-001 into Brainfuck (tape-machine paradigm).

The normative content below is transcribed from the pack alone:
  - §12 transition model (states, triggers, guards, on-failure targets)
  - §12 'rollback has blocking priority over every other rule'
  - CT OR-11 'S6 remains stable / terminal on the projection surface'
  - Semantic Index TR-008 canonical member S0 for authority_release
  - §14 evidence contract (fields, producers, conditional activations)
  - §6 verdict vocabulary
This script is a MECHANICAL RENDERER: it compiles those finite constructs
into BF. The executing artifact is pure Brainfuck; no logic lives here that
is not a direct transcription of a spec clause.

I/O protocol of the produced baseline.bf (BF has no argv; fixed 4-byte stdin):
  byte0 surface: n=next_state e=evidence v=verdict_tag s=state_tag
  'n' s(0-8) t(a-i) v(t/f)   -> prints result state digit or E (fail-closed)
  'e' kind(1-6) x x          -> prints evidence bundle (field=value producer=..)
  'v' code(ADQXR) x x        -> prints canonical verdict word, else E
  's' s(0-8) x x             -> prints canonical state label, else E
Output alphabet for states = Semantic Index short tags S0..S8 rendered as
digits; the harness maps digit->full label (same normalization precedent as
the C baseline's S0_STARTUP_READONLY tokens).
"""

STATES = "012345678"
TRIGGERS = "abcdefghi"  # a=StartupComplete b=SnapshotLocked c=StructuralChecksDone
                        # d=EligibilityChecksDone e=RollbackDetected f=ToolStateInvalid
                        # g=WalReplayNeeded h=RecoveryConverged i=AuthorityRelease
LABELS = ["S0 STARTUP_READONLY","S1 SNAPSHOT_LOCKED","S2 STRUCTURAL_VERIFIED",
          "S3 ELIGIBLE_HEAD_SELECTED","S4 REHYDRATED_VALIDATED","S5 FAIL_SAFE",
          "S6 TOOL_QUARANTINE","S7 RECOVERY_REPLAY","S8 READMISSION_PENDING"]
VERDICTS = {"A":"ALLOW","D":"DENY","Q":"QUARANTINE","X":"ESCALATE","R":"READMISSION_PENDING"}

# §12 transition model rows: (state,trigger) -> (pass_target, fail_target)
TABLE = {("0","a"):("1","5"), ("1","b"):("2","5"), ("2","c"):("3","5"),
         ("3","d"):("4","5"), ("3","f"):("6","6"), ("5","g"):("7","5"),
         ("7","h"):("8","5"), ("8","i"):("0","8")}  # TR-008 canonical S0; fail: remain blocked

def next_state(s, t, v):
    if t == "e": return "5"                      # rollback blocking priority, any state
    if s == "6": return "6"                      # OR-11: S6 terminal on surface
    if (s, t) in TABLE: return TABLE[(s, t)][0 if v == "t" else 1]
    return None                                   # unmapped -> fail-closed reject (E)

CORE = ["validator_bundle_id=VB-0001 producer=EXECUTION_LAYER",
        "verified_head_digest=HD-0001 producer=V_CHAIN",
        "snapshot_id=SNAP-0001 producer=V_SNAPSHOT",
        "policy_id=POL-0001 producer=V_POLICY",
        "source_id=SRC-0001 producer=V_FRESHNESS",
        "freshness_value=FV-0001 producer=V_FRESHNESS",
        "irr_digest=IRR-0001 producer=V_IRR",
        "tool_activation_status=inactive producer=TOOL_GATE",
        "suppression_status=SUPPRESSED producer=GATE_LOGIC"]
EV = {"1": CORE + ["failure_code=FRAME_INVALID producer=GATE_LOGIC","failed_validator=V_FRAME producer=GATE_LOGIC"],
      "2": CORE + ["failure_code=PARSE_AMBIGUOUS producer=GATE_LOGIC","failed_validator=V_PARSE producer=GATE_LOGIC"],
      "3": CORE + ["failure_code=CHAIN_BREAK producer=GATE_LOGIC","failed_validator=V_CHAIN producer=GATE_LOGIC"],
      "4": CORE + ["failure_code=FRESHNESS_DOWNGRADE producer=GATE_LOGIC","failed_validator=V_FRESHNESS producer=GATE_LOGIC"],
      "5": CORE + ["recovery_phase=REPLAY_IN_PROGRESS producer=V_WAL_PHASE"],
      "6": CORE + ["readmission_token_id=RT-0001 producer=READMISSION_AUTHORITY"]}

# ---------- BF emitter ----------
# cells: 0..3 = input bytes, 4=t1, 5=t2, 6..9 = else-flags per nesting depth, 11=print
code = []
pos = [0]
def go(c):
    d = c - pos[0]; code.append(">"*d if d > 0 else "<"*(-d)); pos[0] = c
def emit(s): code.append(s)

def copy(src, t1=4, t2=5):
    go(t1); emit("[-]"); go(t2); emit("[-]")
    go(src); emit("[");  go(t1); emit("+"); go(t2); emit("+"); go(src); emit("-"); emit("]")
    go(t2); emit("[");  go(src); emit("+"); go(t2); emit("-"); emit("]")

def if_eq(cell, ch, depth, body):
    """flag=1; t1=copy(cell)-ord(ch); t1[flag=0;t1=0]; flag[ body; flag=0 ]"""
    f = 6 + depth
    copy(cell)
    go(4); emit("-"*ord(ch))
    go(f); emit("[-]+")
    go(4); emit("[")
    go(f); emit("-")
    go(4); emit("[-]"); emit("]")
    go(f); emit("[")
    body()
    go(f); emit("[-]"); emit("]")

def pr(text):
    go(11)
    for ch in text:
        emit("[-]" + "+"*ord(ch) + ".")
    emit("[-]")

def case(surface, args, out, matched_cell=10):
    def innermost():
        pr(out)
        go(matched_cell); emit("+")
    def build(i):
        if i == len(args): return innermost
        cell, ch = args[i]
        nxt = build(i + 1)
        return lambda: if_eq(cell, ch, i + 1, nxt)
    if_eq(0, surface, 0, build(0))

# read 4 input bytes
for c in range(4): go(c); emit(",")
go(10); emit("[-]")

# surface n: every defined (state,trigger,validator) triple
for s in STATES:
    for t in TRIGGERS:
        for v in "tf":
            r = next_state(s, t, v)
            if r is not None:
                case("n", [(1, s), (2, t), (3, v)], r)
# surface e
for k, lines in EV.items():
    case("e", [(1, k)], "\n".join(lines) + "\n")
# surface v
for k, w in VERDICTS.items():
    case("v", [(1, k)], w)
# surface s
for i, lab in enumerate(LABELS):
    case("s", [(1, str(i))], lab)

# default: nothing matched -> fail-closed E
go(10)
emit("[")            # matched: skip default; consume flag
go(6); emit("[-]+")  # reuse cell6 as done-flag
go(10); emit("[-]"); emit("]")
go(6)
emit("[-]+")         # tmp: ensure defined
# invert: if cell6==0 => not matched -> print E. cell6 currently 1 if matched else 1?  (fix below)
bf = "".join(code)

# Simpler, correct default handling: recompute with a clean scheme.
code.clear(); pos[0] = 0
for c in range(4): go(c); emit(",")
go(10); emit("[-]")
for s in STATES:
    for t in TRIGGERS:
        for v in "tf":
            r = next_state(s, t, v)
            if r is not None:
                case("n", [(1, s), (2, t), (3, v)], r)
for k, lines in EV.items():
    case("e", [(1, k)], "\n".join(lines) + "\n")
for k, w in VERDICTS.items():
    case("v", [(1, k)], w)
for i, lab in enumerate(LABELS):
    case("s", [(1, str(i))], lab)
# default: notm=1; matched[ notm=0; matched=0 ]; notm[ print E; notm=0 ]
go(6); emit("[-]+")
go(10); emit("[")
go(6); emit("-")
go(10); emit("[-]"); emit("]")
go(6); emit("[")
pr("E")
go(6); emit("[-]"); emit("]")
bf = "".join(code)

open("baseline.bf", "w").write(bf)
print("baseline.bf bytes:", len(bf))
