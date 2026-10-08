# VRA supplementary derivations

This supplement records five additional target paradigms for the Verified
Rehydration Agent (AGT-VRA-001): Common Lisp, Brainfuck, spreadsheet formulas,
an Analytical Engine-style program, and AWK. It is separate from the VRA
package and its Non-Normative Tests (NNT) companion. The VRA package Manifest
does not list the files in this supplement; the supplement has its own Manifest
that names and hashes the VRA package Manifest as its parent artifact.
The renderings use the same published Specification and Conformance Tests;
their captured outputs are evidence for this artifact and these reported
surfaces, not independent-party verification.

## Demonstrated surfaces

- **State transitions:** Specification §12, using the conformance suite's
  Boolean guard projection. The sweep covers nine states, nine triggers, and
  two guard outcomes: 162 input triples. Fifty produce explicitly specified
  transition results under the projection rules; 112 unmapped triples produce
  the fail-closed token `E`. This is a component-level sweep, not a full-agent
  or deployment evaluation.
- **Full conformance suite:** The AWK runner and spreadsheet workbook report
  27 PASS, 0 FAIL, 2 SKIP, and 0 ERROR across the 29 published records.
  PT-028 and PT-029 are declarative checks requiring deployment evidence.

The projection applies rollback priority (`rollback_detected` → S5), treats S6
as terminal on this surface (Conformance Tests OR-11), and selects S0 for the
allowed `authority_release` successor (Semantic Index TR-008). Its complete
output histogram is `0=1 1=1 2=1 3=1 4=1 5=24 6=18 7=1 8=2 E=112`.
The 50 non-`E` results comprise 18 rollback cases, 16 S6-terminal cases,
eight passing table rows, and eight failing table rows.

## Files

| Paradigm or role | Files | Purpose |
|---|---|---|
| Common Lisp | `LISP/vra_sec12.lisp`, `LISP/lisp_162.txt` | §12 implementation and captured sweep |
| Brainfuck | `BF/gen_bf.py`, `BF/baseline.bf`, `BF/bf.c`, `LISP/bf_162.txt` | generator, Brainfuck program, interpreter, captured sweep |
| Spreadsheet formulas | `VRA_excel_derivation.xlsx` | `Spec12`, `Vocab`, `Evidence`, `PT`, and `Sweep` sheets |
| Analytical Engine-style | `AE/vra_ae_sweep.py`, `AE/ae_162.txt` | program for the third-party emulator and captured sweep |
| AWK | `AWK/baseline.awk`, `AWK/run_pts.awk`, `AWK/pt_run_log.txt` | full-suite implementation, runner, and captured log |
| Comparators | `LISP/spec_162.txt`, `LISP/rust_sweep.rs`, `LISP/rust_162.txt` | reference output and Rust rendering of the same projection |

The five shipped text vectors (`spec_162.txt`, `lisp_162.txt`, `bf_162.txt`,
`rust_162.txt`, `ae_162.txt`) are byte-identical. Each has 162 newline-delimited
results and SHA-256:

`43c9c6952ea5fde6a93eb07fd961486a2d8e82d935517d2c5b259af88576cb58`

The historical framing spans the Analytical Engine design described in 1843
and Rust's public announcement in 2010: 167 years between designs represented
by contemporary renderings. Lisp (1958), rendered here in its Common Lisp
dialect (standardized by ANSI in 1994), and Brainfuck (1993) supply additional
points in that comparison. It does not imply that the Analytical Engine itself
was built or executed in the nineteenth century.

The supplemental Rust comparator is distinct from the NNT Rust baseline.
Both follow the published transition rules, but this projection chooses S0
for `authority_release` and reports unmapped inputs as `E`; the shipped NNT
Rust baseline defaults to the permitted S1 choice and uses S5 for its
fail-closed fallback. Their output vectors therefore should not be compared
byte-for-byte without accounting for these declared choices.

The workbook expresses states as full labels and unmapped results as `ERROR`.
Normalize these to the vector tokens (`0`–`8`, `E`) before comparing its saved
`Sweep` results with the text vectors. Its `Sweep` sheet also includes two
unknown-token probes outside the 162-input sweep.

## Reproduce

Run the first three commands from this supplement's root and the final command
from `AWK`, using compatible local toolchains:

```text
sbcl --script LISP/vra_sec12.lisp > lisp_out.txt
rustc -O LISP/rust_sweep.rs -o rust_sweep.exe
./rust_sweep.exe > rust_out.txt
cd AWK
awk -f run_pts.awk
```

For Brainfuck, run `BF/gen_bf.py` from the `BF` directory to regenerate
`baseline.bf`; compile `BF/bf.c` with a C compiler and feed the resulting
interpreter four-byte inputs (`n`, state `0`–`8`, trigger `a`–`i`, guard `t`/`f`)
in state/trigger/guard order. The captured output is `LISP/bf_162.txt`.
The original run notes recorded SBCL 2.6.6 for Common Lisp and MSYS2 gcc 15.2
for the Brainfuck interpreter, with the sweep recorded on 2026-07-18.

The Analytical Engine-style source requires the third-party
[`py-analytical_engine`](https://github.com/enigmatic-code/py-analytical_engine)
emulator, which is not included here. Obtain it from the linked repository and
place its `py-ae` directory beside
`AE/vra_ae_sweep.py` and run that script to regenerate `AE/ae_162.txt`.
The source implements a Note-G-style operation diagram, not Lovelace's
Bernoulli-number algorithm. It uses store columns, arithmetic, and conditional
branching on the mill result (`BRZ`), in the emulator's integer mode. Triggers
`a`–`i` are encoded as 1–9 and the sentinel 99 is rendered as `E`. The
program forms `state × 10 + trigger`, subtracts each of the eight table keys
and branches on zero; its guarded output is `fail + guard × (pass − fail)`.
These decisions are expressed in the Analytical Engine program, while Python
sets the inputs, runs the emulator, and records its output. The
[Fourmilab authenticity discussion](https://www.fourmilab.ch/babbage/authentic.html)
documents the historical Combinatorial Cards branching mechanism. The
Analytical Engine was never built; this output is conditional on the
third-party emulator's implementation of these operations.

All renderings are study artifacts. None is a normative source or a reference
implementation for VRA. The VRA Specification and Conformance Tests define the
required behaviour and acceptance criteria.

## Integrity and VRA package anchor

`VRA_Supplement_Manifest.json` records the SHA-256 of the VRA package's
`Verified_Rehydration_Agent_Manifest.sha256` and the SHA-256 and byte length of
every other file in this supplement. It does not use an NNT-specific hash as
its anchor. The supplement Manifest excludes itself to avoid a self-reference.

Before generating new outputs in this directory, verify the package Manifest
and the complete supplement inventory with:

```text
python verify_anchor.py PATH_TO/Verified_Rehydration_Agent_Manifest.sha256
```

The verifier prints the supplement Manifest's own SHA-256. Compare that value
with the digest published alongside the supplement or cited in the article;
the digest identifies this exact version of the supplement Manifest.
Verification of the files inside the VRA package remains governed by the
package's own `verify.md` procedure.

## Rights and use

All rights reserved. You may download, inspect and run these files to
reproduce the reported results. They are provided as is, without warranty,
and are run at your own risk. No other right is granted.
