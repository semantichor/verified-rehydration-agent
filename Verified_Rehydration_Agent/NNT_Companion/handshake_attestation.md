# NNT — Handshake attestation for AGT-VRA-001

> Companion-bounded record of the live-handshake check (live-handshake gate). This file is evidence that the run was executed against live toolchains, not via static-trace fallback. Every claim below is bounded to this single NNT run on this version of the agent pack.

## Run-level configuration

- `reconstruction_permissions.mode`: `broad`
- `binary_provenance.mode`: `trusted-path`

### Declared residual contamination axis

- **Session permission breadth**: the test run was started in a `broad-permission` mode. The reconstruction execution surface was wider than the minimum required for the 6 declared toolchain paths. This is the documented residual axis for the default NNT mode. Readers re-running this NNT in `reconstruction_permissions.mode: allowlist` would zero this axis.

Other residual axes (reconstruction prompt-author, model, training data) are shared across all 5 paradigm reconstructions and declared in the NNT methodology.

## Per-paradigm handshake records

### python

- Toolchain ACK: PASS
  - Sentinel captured: `hello, NNT-python`
- Comprehension ACK: PASS
  - Sentences (period-terminated): 4
  - Citations resolved (2):
    - `Verified_Rehydration_Agent_README.md:71` (text; matched keywords: before, completes, full, restoration, sequence)
    - `Verified_Rehydration_Agent_Whitepaper.html:1079` (text; matched keywords: agent, boundary, restoration, specification, state)

### rust

- Toolchain ACK: PASS
  - Sentinel captured: `hello, NNT-rust`
- Comprehension ACK: PASS
  - Sentences (period-terminated): 4
  - Citations resolved (2):
    - `Verified_Rehydration_Agent_README.md:99` (text; matched keywords: against, agent, conformance, each, oracle)
    - `Verified_Rehydration_Agent_Specification.md:108` (text; matched keywords: allow, conformance, deny, escalate, implementation)

### prolog

- Toolchain ACK: PASS
  - Sentinel captured: `hello, NNT-prolog`
- Comprehension ACK: PASS
  - Sentences (period-terminated): 5
  - Citations resolved (2):
    - `Verified_Rehydration_Agent_README.md:99` (text; matched keywords: against, checks, conformance, declarative, each)
    - `Verified_Rehydration_Agent_Conformance_Tests.md:510` (text; matched keywords: asserted, bundle, evidence, expose, fields)

### c

- Toolchain ACK: PASS
  - Sentinel captured: `hello, NNT-c`
- Comprehension ACK: PASS
  - Sentences (period-terminated): 4
  - Citations resolved (2):
    - `Verified_Rehydration_Agent_README.md:99` (text; matched keywords: against, agent, conformance, drives, fail)
    - `Verified_Rehydration_Agent_Coverage_Matrix.md:42` (text; matched keywords: catalogue, contract, decision, input, logic)

### bash

- Toolchain ACK: PASS
  - Sentinel captured: `hello, NNT-bash`
- Comprehension ACK: PASS
  - Sentences (period-terminated): 4
  - Citations resolved (2):
    - `Verified_Rehydration_Agent_README.md:99` (text; matched keywords: against, conformance, drives, fail, input)
    - `Verified_Rehydration_Agent_Semantic_Index.yaml:512` (text; matched keywords: allow, critical, decision, deny, fails)

