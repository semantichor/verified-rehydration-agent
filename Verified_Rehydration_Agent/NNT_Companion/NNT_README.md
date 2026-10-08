# Verified Rehydration Agent — Non Normative Tests (NNT) Companion
## NNT Release 1.0.0 — README

You have received a **non-normative companion test package** that travels alongside the Verified Rehydration Agent specification package (agent_id: `AGT-VRA-001`). This package contains observations produced by the SEMANTICHOR NNT harness against the buyer-facing surface of the agent pack.

The authoritative documents for Verified Rehydration Agent remain in the agent pack itself: `Verified_Rehydration_Agent_Specification.md` controls all normative questions. Where this companion and the agent specification appear to differ, the agent specification controls. This companion **never** controls.

---

### What this package is, and is not

This package **is** an informative-only artifact produced by the SEMANTICHOR Non Normative Tests harness. It documents one specific testing protocol applied to the Verified Rehydration Agent buyer-facing pack, the conditions of the test run, and the observations produced. It is delivered for **demonstration and study purposes only**.

This package **is not** a specification, a reference implementation, a validation service, a certification of the Verified Rehydration Agent specification, a certification of any implementation derived from that specification, a normative document of any kind, or a substitute for the Verified Rehydration Agent pack. It does not authorize any implementation choice, does not validate any test-suite outcome, and does not constitute a basis for compliance claims.

This package is also not software, SaaS, a managed service, consulting, support, managed operations, or implementation delivery. It is a set of static documents and (where applicable) static source files included strictly for study.

---

### What you received

| File / Directory | Role |
| --- | --- |
| `NNT_README.md` | This file. |
| `Convergence_Exhibit.md` | Buyer-facing synthesis of the cross-paradigm convergence evidence in this companion. Observational only. |
| `INTERPRETATION_RULES_INFORMATIVE.md` | Rules for reading the observations in this companion. Mandatory before consulting any per-paradigm report or aggregate. |
| `per_paradigm_reports/{lang}.md` | One report per paradigm-restricted buyer-simulator reconstruction (Python, Rust, Prolog, C, Bash). Each describes what its reconstruction observed during the test run. |
| `aggregate_observations.md` | Cross-paradigm convergence and divergence observations. Observational only. |
| `auto_disclosure_audit.md` | Audit of the agent pack's Semantic Index, Ambiguity Register, and Coverage Matrix against the observed test run. |
| `coverage_trace.md` | Bidirectional trace between Whitepaper guarantees, README guarantee items, Spec clauses, and Conformance Tests records. |
| `baselines/{lang}/` *(present only in `_with_baseline` variant)* | The 5 paradigm-isolated baseline implementations produced by the reconstructions (one subdirectory per paradigm that completed; halted paradigms are absent). **For study only.** Not reference implementations. |
| Package `Manifest.sha256` | Integrity hashes for this companion and the agent pack are unified in the package Manifest (`Verified_Rehydration_Agent_Manifest.sha256`), which also carries the reference to the agent pack. |

The `_no_baseline` variant of this companion omits the `baselines/` directory. The `_with_baseline` variant includes it. Both variants contain identical reports and observations.

---

### Suggested reading order

1. This README (you are here).
2. `INTERPRETATION_RULES_INFORMATIVE.md` — read **before** any observation report so the framing rules apply when you consult per-paradigm content.
3. `Convergence_Exhibit.md` — read for the buyer-facing synthesis of the convergence evidence.
4. `auto_disclosure_audit.md` — read to see how the agent pack's own self-disclosure surfaces behaved under the test.
5. `coverage_trace.md` — read to see how the bidirectional chain held up.
6. `aggregate_observations.md` — read for cross-paradigm signals.
7. `per_paradigm_reports/{lang}.md` for any paradigm of interest, after the aggregate.
8. *(if `_with_baseline` variant)* `baselines/{lang}/` — study only, never as reference.

This order is not normative; it is the order in which the documents will be most readable for a buyer who wants to understand the run.

---

### What this package observes

The harness produced observations within four categories. None of these are normative claims.

1. **Per-paradigm baseline behavior** — 5 paradigm-restricted reconstructions each attempted to implement the agent from the buyer-facing pack and ran the agent's Conformance Tests against their implementation. Per-paradigm pass/fail patterns are reported as observations of the test run, not as judgments about the spec or the paradigm. Paradigms that halted before completion (host-environmental constraints, toolchain blocks, etc.) are recorded in their `per_paradigm_reports/{lang}.md` with the verbatim `stop_condition.md` content; they are excluded from cross-paradigm convergence accounting in `aggregate_observations.md`.

2. **Cross-paradigm convergence/divergence** — where multiple paradigm-reconstructions produced semantically equivalent baselines on a particular surface, that is observed as convergence. Where they diverged, that is observed as divergence. Neither is a defect claim.

3. **Auto-disclosure traceability** — the agent pack ships a Semantic Index, an Ambiguity Register, and a Coverage Matrix. The harness recorded which clarifying questions raised by reconstructions were resolved in the Ambiguity Register and which were not. This is reported as an observation about the test, not as a judgment about the agent pack.

4. **Coverage chain trace** — the harness traced the chain from each Whitepaper guarantee, through README items, to spec clauses, to Conformance Tests records. Broken links in either direction are reported as observational findings, not as defects.

---

### What you cannot do with this package

The following actions are **explicitly outside** the scope of permitted use for this companion:

- **Implement Verified Rehydration Agent using any baseline included here.** Baselines are study artifacts produced under restricted conditions by paradigm-isolated reconstructions. They are not reference implementations and are not guaranteed to be correct, complete, or compliant.
- **Cite kill rates, pass rates, or any numerical observation as a quality measure** of the Verified Rehydration Agent specification or of any implementation.
- **Use observations from this companion as compliance evidence.** Compliance with Verified Rehydration Agent is established against the agent specification's Conformance Tests applied to your own implementation.
- **Treat any cross-paradigm divergence observed here as a defect** in Verified Rehydration Agent. Divergence under restricted-reconstruction conditions does not entail defect in the specification.
- **Treat any cross-paradigm convergence observed here as a guarantee** of paradigm-agnosticism. Convergence under restricted-reconstruction conditions does not entail paradigm-independence of the specification.
- **Resell, redistribute, sublicense, or otherwise transfer this companion package** to any third party. This restriction matches the restriction on the Verified Rehydration Agent pack itself.

---

### How to read these observations

Two rules apply to every observation in this companion:

1. **Observational, not normative.** The companion reports what was observed under a specific protocol with declared contamination axes. It does not conclude.
2. **Companion-bounded.** Every observation applies to this NNT run on this agent pack version. It does not generalize to other runs, other pack versions, or other implementations.

If you are unsure how to interpret a specific observation, `INTERPRETATION_RULES_INFORMATIVE.md` provides the full set of permissible and prohibited readings. When in doubt, refer to the agent specification — it is the only authoritative source.

---

### Authority boundary

This companion has **no authority**.

It does not certify the Verified Rehydration Agent specification.
It does not validate any implementation built from that specification.
It does not constrain, qualify, supplement, or modify the agent specification's authority or the agent license's terms.
It does not extend the agent specification's grant of rights.
It does not impose any obligations on the buyer beyond the redistribution restriction noted above.

Every claim in every report inside this companion is bounded to "in this NNT test run, under the declared methodology and contamination axes, this was observed." Nothing more.

---

### Versioning and integrity

| Field | Value |
| --- | --- |
| NNT harness version | `1.0.0` |
| NNT run timestamp (UTC) | `2026-09-18T11:23:53.854705+00:00` |
| Companion agent identifier | `AGT-VRA-001` |
| Companion agent manifest reference | `4b3bf7d83c9aea06b0e6d894df556d9716c61ab3ff7f2ebc95991cc92e3ad072` |
| Companion agent specification version | `Public release v1` |
| NNT companion variant | `with_baseline` *(with_baseline | no_baseline)* |
| NNT manifest reference | `(see Verified_Rehydration_Agent_Manifest.sha256)` *(see Verified_Rehydration_Agent_Manifest.sha256)* |

If any field above does not match the corresponding metadata in the files you received, this companion may have been altered. The harness produces fresh artifacts on each run; this companion is not maintained or updated after production.

---

### Support model

There is no support for this companion. It is a one-time-produced informative artifact. No bug fixes, no updates, no consultations, no implementation guidance, no clarifications are offered. If you have questions about the Verified Rehydration Agent specification, refer to the Verified Rehydration Agent pack and its own support model.

---

*End of NNT companion README for Verified Rehydration Agent.*
