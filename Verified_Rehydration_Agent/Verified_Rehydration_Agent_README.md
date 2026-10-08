# Verified Rehydration Agent
## Public release v1 — README

You have received a **specification document package**, distributed free of charge. It defines the normative boundary and decision logic for controlled rehydration of persistent context, permitting restoration only after complete verification.

The authoritative document is `Verified_Rehydration_Agent_Specification.md`. Where this README and the specification appear to differ, the specification controls.

---

### What this package is, and is not

This package **is** a self-contained, normative, execution-neutral single agent specification, delivered as-is, sufficient for an engineering team to build the agent without further design decisions about agent logic, evidence shape, validator behavior, or failure semantics.

This package **is not** software, SaaS, a managed service, consulting, support, managed operations, or implementation delivery. It does not approve source semantic content, activate tool-state without a separate gate, relax policy, or perform persistent writes during startup verification. It is not a live runtime — nothing in the package executes; everything in the package describes how a conforming executable agent must behave.

---

### What you received

**The specification** — the normative product you implement from:

| File | Role |
| --- | --- |
| `Verified_Rehydration_Agent_Specification.md` | Normative specification. The authoritative document. |
| `Verified_Rehydration_Agent_Semantic_Index.md` | Semantic Index — Human Edition (D1). Canonical glossary of all 96 normative terms. |
| `Verified_Rehydration_Agent_Semantic_Index.yaml` / `Verified_Rehydration_Agent_Semantic_Index.json` | Semantic Index — Structured Edition (D2). The same glossary as data, 1:1 with D1. For tooling. |
| `Verified_Rehydration_Agent_Coverage_Matrix.md` | Semantic Coverage Matrix (D3). Links term categories to the specification's sections. |
| `Verified_Rehydration_Agent_Ambiguity_Register.md` | Ambiguity Register (D4). 11 lexical-overload resolutions. Read before normalization questions arise. |
| `Verified_Rehydration_Agent_Conformance_Tests.md` | Conformance tests you run against your implementation, with fixtures, oracles, and minimal run note. |

**Non-normative material** — accompanies the specification, but is not part of it:

| File | Role |
| --- | --- |
| `Verified_Rehydration_Agent_Whitepaper.html` | Public-facing positioning. Non-normative. |
| `NNT_Companion/` | Non-Normative Tests — demonstration-only evidence that the specification is derivable. Not a reference implementation, and not part of the specification. Do not read it before implementing: read it only after your implementation passes the Conformance Tests. |
| `Verified_Rehydration_Agent_README.md` | This file. Orientation and reading order. |

**Integrity** — how you verify that what you hold is authentic:

| File | Role |
| --- | --- |
| `Verified_Rehydration_Agent_License.md` | The license. |
| `Verified_Rehydration_Agent_Manifest.sha256` | SHA-256 integrity manifest. |
| `verify.md` | Self-audit runbook you run against the package you hold. |

---

### Suggested reading order

1. **This README** — the package's map: what is in it and how the pieces relate.
2. **Integrity check** — run the integrity section of `verify.md` against the Manifest to confirm the package is intact and authentic before reading further.
3. **License** — the terms of use. The license sets out what is free; the reserved uses are not licensed for this package.
4. **Whitepaper** — why the agent exists: problem, outcomes, domains. *(Non-normative — context only; carry no terminology from it into implementation.)*
5. **Specification, front matter and §§1–6** — purpose, scope, authority boundaries, input/output contracts, controlled verdict vocabulary.
6. **Semantic Index — Human Edition (D1)** and **Ambiguity Register (D4)** — the canonical terms and their resolved ambiguities; read before the implementation core to avoid normalization mistakes. The Semantic Index, Semantic Coverage Matrix, and Ambiguity Register are derived views of the specification's own vocabulary — the specification is semantically closed, so they cannot legitimately disagree with it. If you observe a divergence, re-run the integrity check. If the copy is intact, the divergence is a release defect: the specification controls, and you should report it to the source that provided the package.
7. **Specification §§7–15** — ordering sequence, validators, decision table, workflow, gate logic, evidence contract, machine-readable forms. The implementation core.
8. **Specification §§16–19** — conformance requirements, deployment obligations, public conformance scenarios, optionality, reuse note.
9. **Conformance Tests** — fixtures, oracles, and the acceptance criteria your implementation must meet.
10. **Semantic Coverage Matrix (D3)** — cross-check that every term category traces to its sections.
11. **Semantic Index — Structured Edition (D2, YAML/JSON)** — the same glossary as data; consume at implementation time.
12. **NNT companion** — non-normative, demonstration-only evidence that the specification is derivable. Do not read before implementing; read only after your implementation passes the Conformance Tests.
13. **After implementation: verify.md, full runbook** — the package's self-audit: re-run its remaining checks against the package you hold. Your implementation's conformance is established by the Conformance Tests, not by verify.md.

---

### What the specification guarantees

7 structural properties, defined in spec §2 Agent Overview / Core invariants and elaborated through the failure semantics, workflow, gate logic, and evidence contract sections:

1. No restoration is permitted before the full verification sequence completes successfully.
2. Any failure in framing, checksum, canonical parse, hash-chain continuity, signature validation, freshness, policy validation, or IRR validity triggers fail-safe handling and suppresses persistent-context injection.
3. Restored persistent state may originate only from the verified and eligible head.
4. Tool-state remains untrusted and inactive unless a separate activation gate and required approval both succeed.
5. Startup remains read-only until the restoration decision is reached.
6. Recovery is idempotent and must not produce duplicate effects or duplicate acceptance.
7. Replay must begin from a deterministic baseline defined by the verified snapshot and applicable local policy.

These are properties of the specification. They are not warranties about a delivered running system.

---

### What your team must produce

Per spec §19 Reuse Note and §16 Conformance Requirements and Deployment Obligations, 5 deployment artifacts are built by your engineering team from this specification:

1. **Stable snapshot facility** — a stable snapshot lock or deterministic equivalent, with observable snapshot binding evidence.
2. **Anti-rollback mechanism** — a non-regressing counter or equivalent anchor sufficient to prove rollback blocking.
3. **Local policy bundle** — a local, versioned policy bundle binding `policy_id`, `V_POLICY`, and `V_COMPAT` compatibility checks.
4. **Single-writer persistence control plane** — serialized persistent-state mutation paths with emitted writer-lock and contention evidence.
5. **Readmission authority workflow** — an `approver_set`, recovery workflow, readmission-token evidence, and release procedure for controlled fail-safe exit.

The specification is complete enough that none of these requires interpretation of ambiguous prose. Spec §16 sets the implementation acceptance criteria your implementation must meet through the conformance requirements and deployment obligations.

---

### How to verify your implementation conforms

The Conformance Tests document contains 29 test records anchored 1:1 to the specification: 26 directly runnable on the agent's projection surface, 1 parameterized against operator-declared inputs, and 2 declarative checks verified at integration level. Each record cites the specification authority that grounds it, the input fixture that drives it, and the oracle that defines pass and fail. The Minimal Run Note declares the projection surface, input types, assertion result types, and the conformance condition for the suite as a whole.

Run the suite against your implementation. A fully conformant implementation passes the 26 runnable tests, satisfies the 1 parameterized test under your declared parameter envelopes, and attests the 2 declarative checks at your release-acceptance gate.

---

### How the agent is deployed by your team

The agent has a single deployment scope: the boundary between candidate persistent artefacts and runtime context eligible for restoration. It is implemented and operated by your engineering and operations teams as a critical normative agent that allows restoration only after complete verification and otherwise blocks, suppresses, or isolates persistent context. Composing this agent with others from the same library, including as a component within a family integrator, is specified in the relevant family pack — a separate package with its own documents and terms.

In all cases, deployment is performed by your engineering and operations teams. This package is not the deployer.

---

### How to read the package when a question arises

The package is closed on what it must close and deliberately open on what your operating context must close. When implementing or running the agent, edge cases will arise. Read them in this order:

1. **The specification rules first.** If the specification, decision table, gate logic, evidence contract, or validator catalogue resolves the case — apply that rule. The canonical verdicts (§§5–6 and §11) and the dominant fail-closed ordering and failure rules (§§7–8) cover most situations directly.
2. **Operator-declared parameters second.** Where the specification leaves a parameter to your declaration — cadences, procedures, mechanisms, routes, roles — your policy declarations are the authority. Close the case in that policy.
3. **Your own governance third.** Where neither the specification nor an operator-declared parameter applies, the case belongs to your release governance, security authority, or human auditor — exactly as the specification's authority boundary (§3) requires. The agent does not adjudicate beyond its scope.

If you find yourself reconstructing the agent's central decision logic to answer an edge case, stop — this is a signal that one of the three layers above has not been applied. The package is built so that no reconstruction of core decision logic is needed on your side.

---

### Authority boundary

The agent's authority is strictly bounded to restore, deny, quarantine, or escalate. It may decide restoration eligibility; suppress, quarantine, or controlled-release persistent context; emit explicit failure reasons; and produce an independently verifiable evidence bundle. It does not approve source semantic content, activate tool-state without a separate gate, relax policy, or perform persistent writes during startup verification.

This boundary is normative (spec §3 Authority Model and §16 Conformance Requirements and Deployment Obligations) and cannot be overridden by integration choices.

---

### Versioning

| Field | Value |
| --- | --- |
| Specification version | Public release v1 |
| Index version (D1 / D2 / D3 / D4) | v2.0 |
| Term count (D1 / D2 / D3) | 96 |
| Ambiguity entries (D4) | 11 |
| Conformance test records | 29 |

If any field above does not match the corresponding metadata in the files you opened, contact the source that provided the package to obtain the correct release. Do not implement against a version-mismatched package.

---

### Support model

This document package is distributed free of charge and delivered as-is. No support, consulting, implementation, or operational services are included or offered. Your engineering team owns implementation, deployment, operation, and maintenance.

---

*End of README.*
