#!/usr/bin/env python3
# VRA sec12 derived into Babbage's Analytical Engine (1843 paradigm), run on the
# third-party faithful emulator py-analytical_engine (Jim Randell). Sweeps all
# 162 (state x trigger x guard) triples; cross-checked vs the verified reference.
#
# Trigger encoding a..i -> 1..9 (e = 5). Output sentinel 99 = fail-closed 'E'.
# next_state is implemented ONLY with the Engine's documented capabilities:
#   store columns, + - x, and conditional branching on the mill result (BRZ),
#   which is Babbage's 1837 "Combinatorial Cards" mechanism.

import sys, os, io, contextlib
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "py-ae"))
from analytical_engine import AnalyticalEngine

# --- the VRA sec12 card program (Note-G-style operation diagram) --------------
# Store layout:
#   v0=state  v1=trigger(1..9)  v2=guard(1/0)   [inputs, set per run]
#   v3=key  v4=pass  v5=fail  v6=diff  v7=tmp     [scratch]
#   v8=0 v9=10 v10=5 v11=6 v12=99                  [constants]
#   v13..v20 = row keys (1,12,23,34,36,57,78,89)   [constants]
LOGIC = """
# --- constants ---
SET 8 0
SET 9 10
SET 10 5
SET 11 6
SET 12 99
SET 13 1
SET 14 12
SET 15 23
SET 16 34
SET 17 36
SET 18 57
SET 19 78
SET 20 89
# --- global rule 1: trigger == e(5) -> S5  (rollback: blocking priority) ---
SUB v1 v10
BRZ Lemit5
# --- global rule 2: state == 6 -> S6  (OR-11 terminal) ---
SUB v0 v11
BRZ Lemit6
# --- key = state*10 + trigger ---
MUL v0 v9 v3
ADD v3 v1 v3
# --- table row tests (state,trigger) ---
SUB v3 v13
BRZ R1
SUB v3 v14
BRZ R12
SUB v3 v15
BRZ R23
SUB v3 v16
BRZ R34
SUB v3 v17
BRZ R36
SUB v3 v18
BRZ R57
SUB v3 v19
BRZ R78
SUB v3 v20
BRZ R89
# --- default: unmapped -> fail-closed E ---
BRA LemitE
# --- rows: SET pass, SET fail, go to guarded emit ---
:R1
SET 4 1
SET 5 5
BRA Lguard
:R12
SET 4 2
SET 5 5
BRA Lguard
:R23
SET 4 3
SET 5 5
BRA Lguard
:R34
SET 4 4
SET 5 5
BRA Lguard
:R36
SET 4 6
SET 5 6
BRA Lguard
:R57
SET 4 7
SET 5 5
BRA Lguard
:R78
SET 4 8
SET 5 5
BRA Lguard
:R89
SET 4 0
SET 5 8
BRA Lguard
# --- guarded emit: out = fail + guard*(pass - fail) ---
:Lguard
SUB v4 v5 v6
MUL v2 v6 v7
ADD v7 v5
PRINT
HALT
# --- global emits ---
:Lemit5
ADD v10 v8
PRINT
HALT
:Lemit6
ADD v11 v8
PRINT
HALT
:LemitE
ADD v12 v8
PRINT
HALT
"""

def next_state_ae(state, trig_code, guard):
    ae = AnalyticalEngine(number=int, vars=30)
    (program, labels) = ae.assemble(LOGIC)
    ae.load_program(program)
    ae.v[0] = state
    ae.v[1] = trig_code
    ae.v[2] = guard
    with contextlib.redirect_stdout(io.StringIO()):   # silence the engine's chatter
        ae.run()
    assert len(ae.output) == 1, f"expected 1 output, got {ae.output} for ({state},{trig_code},{guard})"
    val = int(ae.output[-1])
    return "E" if val == 99 else str(val)

# --- sweep in the SAME order as the reference: state 0..8, trigger a..i, guard [t,f] ---
tokens = []
from collections import Counter
histo = Counter()
for s in range(9):
    for tcode in range(1, 10):          # a..i -> 1..9
        for g in (1, 0):                # guard t then f
            tok = next_state_ae(s, tcode, g)
            tokens.append(tok)
            histo[tok] += 1

with open(os.path.join(os.path.dirname(__file__), "ae_162.txt"), "w", newline="\n") as f:
    f.write("\n".join(tokens) + "\n")

print("AE sweep triples:", len(tokens))
print("histogram:", dict(sorted(histo.items())))
