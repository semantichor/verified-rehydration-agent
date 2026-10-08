D1 — Semantic Index Human Edition

*Verified Rehydration Agent • Public release v1 • Semantic Index v2.0 canonical package*

# Document metadata

**agent\_name:** Verified Rehydration Agent

**agent\_version:** Public release v1

**index\_version:** 2.0

**source\_documents:** Verified\_Rehydration\_Agent\_Specification.md

**derivation\_scope:** single-document authorized public corpus

**publication\_format:** D1; D2-YAML; D2-JSON; D3; D4

**authorized\_public\_corpus:** Verified\_Rehydration\_Agent\_Specification.md

**excluded\_sources\_statement:** Only the authorized public corpus is used for source\_refs and textual attestation.

# Method framing

Corpus basis: only the authorized public corpus.

Lexical rule: preferred labels are limited to terms textually attested in the public specification.

Semantic rule: normative, state, decision, validation, evidence, boundary, control, abbreviation, transition, and optionality vocabulary is separated explicitly.

Packaging rule: D2 is 1:1 semantic with D1, while D3 and D4 cross-check coverage and ambiguity handling.

# Indexed entry count

**Total entries:** 96

**Canonical categories:** Identity Terms; Boundary Terms; Control Terms; Decision Terms; Validation Terms; Evidence Terms; State Terms; Transition Terms; Abbreviation Terms; Optionality Terms

**Textual attestation:** All preferred labels are textually attested in the public specification.

# Identity Terms

**Entry count:** 3

### ID-001 — Verified Rehydration Agent

**definition\_short:** Canonical name of the agent defined by the public specification.

**definition\_operational:** Names the agent whose role is to allow restoration only after complete verification and otherwise block, suppress, or isolate persistent context.

**normative\_status:** normative

**source\_refs:** Title block; §2 Agent Overview

**related\_terms:** AGT-VRA-001; Public Library Specification; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ID-002 — AGT-VRA-001

**definition\_short:** Agent identifier assigned in the overview table.

**definition\_operational:** Provides the stable identifier for the public specification record of the agent.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview

**related\_terms:** Verified Rehydration Agent

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ID-003 — Public Library Specification

**definition\_short:** Document type declared for the public release.

**definition\_operational:** Marks the document as the buyer-facing and self-contained public specification used for semantic extraction.

**normative\_status:** normative

**source\_refs:** Title block; §2 Agent Overview

**related\_terms:** Verified Rehydration Agent

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# Boundary Terms

**Entry count:** 10

### BD-001 — persistent context

**definition\_short:** Persistent context subject to restoration control.

**definition\_operational:** Names the persistent state whose restoration is permitted only after complete verification and otherwise remains blocked, suppressed, or isolated.

**normative\_status:** normative

**source\_refs:** Title block; §1 Scope and Key Terms; §2 Agent Overview; §8 Failure Semantics

**related\_terms:** validated\_context; Tool-state; Fail-safe suppression

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** Restoration is permitted only after complete verification.

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-002 — IRR

**definition\_short:** Reception log used to prove valid intake and visibility.

**definition\_operational:** Names the reception log used to prove valid intake and to anchor which head is visible and eligible for restoration.

**normative\_status:** normative

**source\_refs:** §1 Scope and Key Terms; §4 Input Contract; §7 Ordering and Verification Sequence; §10 Validator Catalogue; §14 Evidence Contract

**related\_terms:** Head; Accepted head; V\_IRR; V\_VISIBILITY; irr\_digest

**synonyms:** reception log; IRR / reception log

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** reception log

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-003 — Head

**definition\_short:** Candidate top record or state boundary considered for restoration.

**definition\_operational:** Names the candidate top record or state boundary considered for restoration before accepted visibility and full verification are established.

**normative\_status:** normative

**source\_refs:** §1 Scope and Key Terms; §7 Ordering and Verification Sequence

**related\_terms:** Accepted head; verified head

**synonyms:** —

**non\_synonyms:** Accepted head

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** Accepted head; verified head

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-004 — Accepted head

**definition\_short:** Head made eligible by a valid IRR entry and the visibility rule.

**definition\_operational:** Names the head made eligible by a valid IRR entry and the visibility rule, but not yet the verified head for replay and release.

**normative\_status:** normative

**source\_refs:** §1 Scope and Key Terms; §4 Input Contract; §9 Observability Requirements; §16 Precedence rules

**related\_terms:** Head; verified head; V\_VISIBILITY; accepted\_head\_digest

**synonyms:** —

**non\_synonyms:** Head; verified head

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** Head; verified head

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-005 — verified head

**definition\_short:** Head fixed for replay and release after the required verification sequence.

**definition\_operational:** Names the head selected after verification, used for replay, release, and evidence binding.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §6 Verdict Semantics; §7 Ordering and Verification Sequence; §9 Observability Requirements; §14 Evidence Contract

**related\_terms:** Head; Accepted head; validated\_context; verified\_head\_digest

**synonyms:** —

**non\_synonyms:** Head

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** Head; Accepted head

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-006 — Tool-state

**definition\_short:** Persisted capability or tool configuration state handled separately from restoration.

**definition\_operational:** Names persisted capability or tool configuration state that remains separate from conversational or contextual restoration and requires a separate activation gate and approval path.

**normative\_status:** normative

**source\_refs:** §1 Scope and Key Terms; §2 Agent Overview; §4 Input Contract; §8 Failure Semantics; §11 Decision Logic; §18 Optional Features

**related\_terms:** tool\_state\_activation; tool\_activation\_status; Tool-state activation path

**synonyms:** —

**non\_synonyms:** validated\_context

**usage\_constraints:** Tool-state remains untrusted and inactive unless a separate activation gate and required approval both succeed.

**allowed\_values:** —

**ambiguities:** Tool-state activation path; tool\_state\_activation

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-007 — append-only ledger

**definition\_short:** Primary persistent input used as a restoration source.

**definition\_operational:** Names the append-only ledger provided as a primary input and validated for framing, checksum, canonical parse, and chain continuity before restoration.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §4 Input Contract

**related\_terms:** V\_FRAME; V\_CHECKSUM; V\_PARSE; V\_CHAIN

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-008 — policy bundle

**definition\_short:** Authorized policy input used for local compatibility checks.

**definition\_operational:** Names the policy bundle used to verify authorized policy\_id and local compatibility before restoration can be allowed.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §4 Input Contract; §10 Validator Catalogue; §16 Deployment obligations

**related\_terms:** policy\_id; V\_POLICY; V\_COMPAT

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** policy\_id; V\_POLICY

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-009 — startup mount state

**definition\_short:** Startup storage state before verification begins.

**definition\_operational:** Names the startup mount state that must be read-only before verification begins and remains part of the trusted restoration boundary.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §4 Input Contract; §10 Validator Catalogue

**related\_terms:** V\_BOOT\_MODE; S0 STARTUP\_READONLY

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** S0 STARTUP\_READONLY; V\_BOOT\_MODE

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### BD-010 — validated\_context

**definition\_short:** Validated context assembled for handoff after ALLOW.

**definition\_operational:** Names the restored context handed to the execution layer only after ALLOW and complete replay from the verified head.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §12 Workflow and State Transitions; §13 Gate Logic

**related\_terms:** restoration\_verdict; ALLOW; verified head

**synonyms:** —

**non\_synonyms:** Tool-state

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# Control Terms

**Entry count:** 8

### CT-001 — Fail-safe suppression

**definition\_short:** Mandatory prevention of persistent-state injection after a blocking failure.

**definition\_operational:** Names the mandatory blocking control that suppresses persistent-state injection after any blocking failure and keeps restoration fail-closed.

**normative\_status:** normative

**source\_refs:** §1 Scope and Key Terms; §6 Verdict Semantics; §8 Failure Semantics; §13 Gate Logic

**related\_terms:** DENY; S5 FAIL\_SAFE; Readmission

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** Mandatory prevention of persistent-state injection after a blocking failure.

**allowed\_values:** —

**ambiguities:** S5 FAIL\_SAFE; fail\_safe\_release

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### CT-002 — Readmission

**definition\_short:** Controlled exit from fail-safe after recovery obligations and approval.

**definition\_operational:** Names the controlled exit from fail-safe after recovery obligations are satisfied and the required authority approves release.

**normative\_status:** normative

**source\_refs:** §1 Scope and Key Terms; §5 Output Contract; §6 Verdict Semantics; §13 Gate Logic

**related\_terms:** readmission\_request; READMISSION\_PENDING; Readmission gate

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** Controlled exit from fail-safe after recovery obligations are satisfied and the required authority approves release.

**allowed\_values:** —

**ambiguities:** readmission\_request; READMISSION\_PENDING

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### CT-003 — Release gate

**definition\_short:** Gate that permits validated\_context handoff.

**definition\_operational:** Names the gate that opens only when all critical validators PASS and verified context is assembled, allowing validated\_context handoff.

**normative\_status:** normative

**source\_refs:** §9 Observability Requirements; §13 Gate Logic

**related\_terms:** validated\_context; ALLOW; validator\_bundle\_id

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### CT-004 — Block gate

**definition\_short:** Gate that suppresses restore when a critical failure is present.

**definition\_operational:** Names the gate that closes autonomous restore and suppresses injection while recovery proof and authority release are still absent.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §13 Gate Logic

**related\_terms:** DENY; Fail-safe suppression

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### CT-005 — Quarantine gate

**definition\_short:** Gate that isolates partial artefacts during recoverable ambiguity or tool restriction.

**definition\_operational:** Names the gate that isolates partial artefacts while separate closure conditions remain unsatisfied.

**normative\_status:** normative

**source\_refs:** §8 Failure Semantics; §13 Gate Logic

**related\_terms:** QUARANTINE; S6 TOOL\_QUARANTINE

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### CT-006 — Escalation gate

**definition\_short:** Gate that halts autonomous progress when the environment, policy, or authority is deficient.

**definition\_operational:** Names the gate that blocks autonomous progress until operator or policy-authority action resolves the deficiency.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §13 Gate Logic

**related\_terms:** ESCALATE; startup\_environment

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### CT-007 — Readmission gate

**definition\_short:** Gate that controls exit from fail-safe.

**definition\_operational:** Names the gate that opens only after fail-safe entry and completion of the closure bundle, and remains closed if any obligation is missing.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §11 Decision Logic; §13 Gate Logic

**related\_terms:** Readmission; readmission\_request; READMISSION\_PENDING

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### CT-008 — accepted-head-only rule

**definition\_short:** Rule that limits restoration to the accepted head.

**definition\_operational:** Names the precedence rule and proof requirement that restoration may not extend beyond the accepted head and that an unanchored tail remains ineligible.

**normative\_status:** normative

**source\_refs:** §9 Observability Requirements; §16 Precedence rules; §19 Reuse Note

**related\_terms:** Accepted head; IRR; verified head

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** The accepted-head-only rule prevails over any local continuity of an unanchored tail.

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# Decision Terms

**Entry count:** 14

### DE-001 — restoration\_request

**definition\_short:** Decision object for the principal restoration rule.

**definition\_operational:** Names the decision object that yields ALLOW when all critical validators PASS and yields DENY when a critical validator fails.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §11 Decision Logic

**related\_terms:** ALLOW; DENY; validator\_bundle\_id; verified\_head\_digest

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-002 — import\_admissibility

**definition\_short:** Decision object for freshness and policy acceptance of imported context.

**definition\_operational:** Names the decision object that denies acceptance and restore when freshness is not strictly greater or policy is incompatible.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §11 Decision Logic

**related\_terms:** DENY; source\_id; policy\_id

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-003 — verified\_head\_selection

**definition\_short:** Decision object for accepted and visible head selection.

**definition\_operational:** Names the decision object that denies restoration when IRR is invalid or visibility is unsatisfied and keeps the tail ineligible.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §11 Decision Logic

**related\_terms:** Accepted head; DENY; V\_IRR; V\_VISIBILITY

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-004 — tool\_state\_activation

**definition\_short:** Decision object for tool-state release or isolation.

**definition\_operational:** Names the decision object that quarantines tool-state when schema, allow-list, or approval requirements are not satisfied.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §11 Decision Logic

**related\_terms:** Tool-state; QUARANTINE; tool\_activation\_status

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** Tool-state; Tool-state activation path

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-005 — fail\_safe\_release

**definition\_short:** Decision object listed for controlled release from fail-safe.

**definition\_operational:** Names the fail-safe release decision object listed in the agent overview and bounded by the readmission controls and authority release path.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §13 Gate Logic

**related\_terms:** Readmission; Readmission gate; authority\_release

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** Fail-safe suppression; S5 FAIL\_SAFE

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-006 — readmission\_request

**definition\_short:** Decision object for authorized exit from fail-safe.

**definition\_operational:** Names the decision object that transitions READMISSION\_PENDING to ALLOW only after recovery obligations are satisfied and authority approves.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §11 Decision Logic

**related\_terms:** READMISSION\_PENDING; ALLOW; Readmission gate

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** Readmission; READMISSION\_PENDING

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-007 — recovery\_replay

**definition\_short:** Decision object for recoverable WAL ambiguity.

**definition\_operational:** Names the decision object that yields QUARANTINE when WAL phase ambiguity is recoverable and blocks release before convergence is proven.

**normative\_status:** normative

**source\_refs:** §11 Decision Logic

**related\_terms:** QUARANTINE; WAL; recovery\_phase

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** WAL; S7 RECOVERY\_REPLAY; recovery\_phase

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-008 — startup\_environment

**definition\_short:** Decision object for startup trustworthiness.

**definition\_operational:** Names the decision object that yields ESCALATE when boot mode is not read-only or the snapshot is unstable.

**normative\_status:** normative

**source\_refs:** §11 Decision Logic

**related\_terms:** ESCALATE; V\_BOOT\_MODE; V\_SNAPSHOT

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-009 — restoration\_verdict

**definition\_short:** Final verdict emitted for restoration handling.

**definition\_operational:** Names the final verdict output that binds the restoration decision to validator results, head selection, snapshot context, and failure signaling.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §5 Output Contract; §6 Verdict Semantics; §15 Machine-Readable Forms

**related\_terms:** ALLOW; DENY; QUARANTINE; ESCALATE; READMISSION\_PENDING

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** ALLOW; DENY; QUARANTINE; ESCALATE; READMISSION\_PENDING

**ambiguities:** restoration\_request

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-010 — ALLOW

**definition\_short:** Normative verdict permitting restoration.

**definition\_operational:** Means restoration may be executed only from the verified head and only for the context declared eligible.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §6 Verdict Semantics; §11 Decision Logic

**related\_terms:** restoration\_verdict; validated\_context; verified head

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** ALLOW means restoration may be executed only from the verified head and only for the context declared eligible.

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-011 — DENY

**definition\_short:** Normative verdict blocking restoration.

**definition\_operational:** Means no persistent state is injected and the blocking reason remains explicit in the evidence and gate outputs.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §6 Verdict Semantics; §11 Decision Logic

**related\_terms:** restoration\_verdict; failure\_code; Fail-safe suppression

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** DENY means no persistent state is injected.

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-012 — QUARANTINE

**definition\_short:** Normative verdict isolating artefacts or state portions.

**definition\_operational:** Means artefacts or state portions remain isolated and non-executable until the required closure conditions are met.

**normative\_status:** normative

**source\_refs:** §6 Verdict Semantics; §8 Failure Semantics; §11 Decision Logic

**related\_terms:** Quarantine gate; S6 TOOL\_QUARANTINE

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** QUARANTINE means artefacts or state portions remain isolated and non-executable.

**allowed\_values:** —

**ambiguities:** S6 TOOL\_QUARANTINE; MRF-TOOL-QUARANTINE

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-013 — ESCALATE

**definition\_short:** Normative verdict requiring operator or policy-authority intervention.

**definition\_operational:** Means operator or policy-authority intervention is required because the verification environment, policy, or authority conditions are not trustworthy or not sufficient.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §6 Verdict Semantics; §8 Failure Semantics; §11 Decision Logic

**related\_terms:** Escalation gate; startup\_environment

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** ESCALATE means operator or policy-authority intervention is required.

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### DE-014 — READMISSION\_PENDING

**definition\_short:** Normative verdict showing fail-safe closure is still incomplete.

**definition\_operational:** Means a fail-safe state has not yet been closed through the required readmission conditions.

**normative\_status:** normative

**source\_refs:** §6 Verdict Semantics; §11 Decision Logic

**related\_terms:** readmission\_request; Readmission gate; S8 READMISSION\_PENDING

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** S8 READMISSION\_PENDING

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# Validation Terms

**Entry count:** 18

### VA-001 — V\_FRAME

**definition\_short:** Verifies record framing structure and boundaries.

**definition\_operational:** Names the validator that verifies record framing structure and boundaries and whose failure produces DENY. Minimum evidence: frame\_status, frame\_offset. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-002 — V\_CHECKSUM

**definition\_short:** Verifies frame checksum.

**definition\_operational:** Names the validator that verifies frame checksum and whose failure produces DENY. Minimum evidence: checksum\_status. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-003 — V\_PARSE

**definition\_short:** Verifies unambiguous canonical parsing.

**definition\_operational:** Names the validator that verifies unambiguous canonical parsing and whose failure produces DENY. Minimum evidence: parse\_status, canonical\_form\_id. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-004 — V\_CHAIN

**definition\_short:** Verifies hash-chain continuity.

**definition\_operational:** Names the validator that verifies hash-chain continuity and whose failure produces DENY. Minimum evidence: prior\_digest, current\_digest, chain\_status. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-005 — V\_SIG

**definition\_short:** Verifies signatures and the permitted cryptographic profile.

**definition\_operational:** Names the validator that verifies signatures and the permitted cryptographic profile and whose failure produces DENY. Minimum evidence: key\_id, sig\_status, alg\_profile. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-006 — V\_FRESHNESS

**definition\_short:** Verifies strict increase against the local watermark.

**definition\_operational:** Names the validator that verifies strict increase against the local watermark and whose failure produces DENY. Minimum evidence: source\_id, accepted\_freshness, candidate\_freshness. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-007 — V\_POLICY

**definition\_short:** Verifies policy\_id and local policy compatibility.

**definition\_operational:** Names the validator that verifies policy\_id and local policy compatibility and whose failure produces DENY. Minimum evidence: policy\_id, compat\_status. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-008 — V\_COMPAT

**definition\_short:** Verifies deployment-policy compatibility.

**definition\_operational:** Names the validator that verifies deployment-policy compatibility and whose failure produces DENY. Minimum evidence: deployment\_profile, compat\_status. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-009 — V\_IRR

**definition\_short:** Verifies IRR existence and validity.

**definition\_operational:** Names the validator that verifies irr existence and validity and whose failure produces DENY. Minimum evidence: irr\_digest, irr\_status. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-010 — V\_VISIBILITY

**definition\_short:** Selects only the accepted and visible head.

**definition\_operational:** Names the validator that selects only the accepted and visible head and whose failure produces DENY. Minimum evidence: accepted\_head\_digest. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-011 — V\_BOOT\_MODE

**definition\_short:** Verifies startup remount as read-only.

**definition\_operational:** Names the validator that verifies startup remount as read-only and whose failure produces ESCALATE. Minimum evidence: mount\_mode. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-012 — V\_SNAPSHOT

**definition\_short:** Verifies binding to a stable snapshot.

**definition\_operational:** Names the validator that verifies binding to a stable snapshot and whose failure produces DENY. Minimum evidence: snapshot\_id, fd\_binding\_digest. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-013 — V\_WAL\_PHASE

**definition\_short:** Verifies coherence of PREPARE / ANCHOR / APPEND / COMMIT markers.

**definition\_operational:** Names the validator that verifies coherence of prepare / anchor / append / commit markers and whose failure produces QUARANTINE. Minimum evidence: wal\_phase. Severity: high.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-014 — V\_COUNTER\_CONT

**definition\_short:** Verifies counter monotonicity and continuity.

**definition\_operational:** Names the validator that verifies counter monotonicity and continuity and whose failure produces DENY. Minimum evidence: counter\_value, anchor\_digest. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-015 — V\_TOOL\_SCHEMA

**definition\_short:** Verifies tool-state schema.

**definition\_operational:** Names the validator that verifies tool-state schema and whose failure produces tool\_quarantine. Minimum evidence: tool\_schema\_status. Severity: medium.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-016 — V\_TOOL\_ALLOWLIST

**definition\_short:** Verifies the allow-list and capability ceiling.

**definition\_operational:** Names the validator that verifies the allow-list and capability ceiling and whose failure produces tool\_quarantine. Minimum evidence: tool\_id, allow\_status. Severity: medium.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-017 — V\_WRITER\_LOCK

**definition\_short:** Verifies single-writer discipline.

**definition\_operational:** Names the validator that verifies single-writer discipline and whose failure produces ESCALATE. Minimum evidence: writer\_lock\_status, contention\_status. Severity: high.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### VA-018 — V\_ANCHOR

**definition\_short:** Verifies the anti-rollback anchor.

**definition\_operational:** Names the validator that verifies the anti-rollback anchor and whose failure produces DENY. Minimum evidence: anchor\_status. Severity: critical.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §11 Decision Logic

**related\_terms:** validator\_bundle\_id; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# Evidence Terms

**Entry count:** 15

### EV-001 — validator\_bundle\_id

**definition\_short:** Evidence field binding the results of all validators.

**definition\_operational:** Identifies the bundle that binds the results of every critical validator and supports verdict emission and offline reconstruction.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §9 Observability Requirements; §14 Evidence Contract

**related\_terms:** restoration\_verdict; V\_FRAME; V\_ANCHOR

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-002 — verified\_head\_digest

**definition\_short:** Evidence field identifying the verified head for replay.

**definition\_operational:** Provides the digest of the verified head used for replay, release, and accepted-head-only proof.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §9 Observability Requirements; §14 Evidence Contract; §15 Machine-Readable Forms

**related\_terms:** verified head; V\_CHAIN; V\_VISIBILITY

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-003 — accepted\_head\_digest

**definition\_short:** Evidence field identifying the accepted and visible head.

**definition\_operational:** Provides the digest that proves accepted-head visibility and supports release-gate observability.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §9 Observability Requirements

**related\_terms:** Accepted head; V\_VISIBILITY

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-004 — snapshot\_id

**definition\_short:** Evidence field identifying the verification-time snapshot context.

**definition\_operational:** Provides the stable snapshot identifier used to bind verification, replay, and offline reconstruction to the same snapshot context.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §10 Validator Catalogue; §14 Evidence Contract; §15 Machine-Readable Forms

**related\_terms:** V\_SNAPSHOT; restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** Replay uses only the same snapshot context in which the head was validated.

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-005 — policy\_id

**definition\_short:** Evidence field identifying the locally applied policy.

**definition\_operational:** Names the policy identifier used in compatibility checks and recorded in the verdict evidence bundle.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §5 Output Contract; §10 Validator Catalogue; §14 Evidence Contract

**related\_terms:** policy bundle; V\_POLICY; V\_COMPAT

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** policy bundle; V\_POLICY

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-006 — irr\_digest

**definition\_short:** Evidence field linking the decision to valid reception.

**definition\_operational:** Provides the digest that links the restoration decision to valid IRR handling and accepted intake.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §10 Validator Catalogue; §14 Evidence Contract

**related\_terms:** IRR; V\_IRR

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** IRR

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-007 — failure\_code

**definition\_short:** Evidence field explaining denial or escalation.

**definition\_operational:** Provides the explicit failure code used to explain DENY or ESCALATE and to keep blocking decisions observable and reconstructable.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §9 Observability Requirements; §14 Evidence Contract; §15 Machine-Readable Forms

**related\_terms:** DENY; ESCALATE; failed\_validator

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-008 — tool\_activation\_status

**definition\_short:** Evidence field separating restoration from tool-state activation.

**definition\_operational:** Shows whether tool-state activation remains inactive, quarantined, or otherwise separately gated from conversational restoration.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §9 Observability Requirements; §14 Evidence Contract

**related\_terms:** Tool-state; tool\_state\_activation

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-009 — recovery\_phase

**definition\_short:** Evidence field showing WAL recovery and convergence state.

**definition\_operational:** Shows the current recovery phase so that convergence, replay sufficiency, and readmission control remain observable.

**normative\_status:** normative

**source\_refs:** §4 Input Contract; §9 Observability Requirements; §14 Evidence Contract

**related\_terms:** WAL; S7 RECOVERY\_REPLAY; recovery\_replay

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** WAL; S7 RECOVERY\_REPLAY; wal\_replay\_needed

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-010 — writer\_lock\_status

**definition\_short:** Evidence field showing single-writer enforcement at relevant control points.

**definition\_operational:** Shows writer-lock and contention state so that single-writer discipline remains observable during restore and mutation control.

**normative\_status:** normative

**source\_refs:** §9 Observability Requirements; §10 Validator Catalogue; §14 Evidence Contract; §16 Deployment obligations

**related\_terms:** V\_WRITER\_LOCK

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-011 — source\_id

**definition\_short:** Evidence field identifying the source under freshness evaluation.

**definition\_operational:** Names the source identifier used in freshness verification and in machine-readable restore requests.

**normative\_status:** normative

**source\_refs:** §11 Decision Logic; §14 Evidence Contract; §15 Machine-Readable Forms

**related\_terms:** V\_FRESHNESS; MRF-RESTORE-REQ

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-012 — freshness\_value

**definition\_short:** Evidence field recording source freshness in the minimum bundle.

**definition\_operational:** Names the freshness value used to track source freshness in the minimum evidence bundle for the principal verdict.

**normative\_status:** normative

**source\_refs:** §14 Evidence Contract

**related\_terms:** V\_FRESHNESS

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-013 — failed\_validator

**definition\_short:** Evidence field naming the validator that failed.

**definition\_operational:** Names the failed validator used to explain DENY or ESCALATE and to preserve explicit failure reasons.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §9 Observability Requirements; §14 Evidence Contract

**related\_terms:** failure\_code; DENY; ESCALATE

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-014 — suppression\_status

**definition\_short:** Evidence field recording suppression handling after blocking failure.

**definition\_operational:** Names the suppression status carried with denial signaling and fail-safe handling after a blocking failure.

**normative\_status:** normative

**source\_refs:** §5 Output Contract; §14 Evidence Contract

**related\_terms:** Fail-safe suppression; DENY

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### EV-015 — readmission\_token\_id

**definition\_short:** Evidence field identifying readmission token issuance where applicable.

**definition\_operational:** Names the readmission token identifier carried in the minimum evidence bundle when readmission token issuance is applicable.

**normative\_status:** normative

**source\_refs:** §14 Evidence Contract

**related\_terms:** Readmission; MRF-READMISSION

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# State Terms

**Entry count:** 9

### ST-001 — S0 STARTUP\_READONLY

**definition\_short:** Storage remounted read-only; no restore permitted.

**definition\_operational:** Names the workflow state in which storage remounted read-only; no restore permitted. Exit condition: Snapshot locked.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ST-002 — S1 SNAPSHOT\_LOCKED

**definition\_short:** Stable verification context established.

**definition\_operational:** Names the workflow state in which stable verification context established. Exit condition: Structural validation finished.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ST-003 — S2 STRUCTURAL\_VERIFIED

**definition\_short:** Framing, checksum, parse, chain, and signature validation succeeded.

**definition\_operational:** Names the workflow state in which framing, checksum, parse, chain, and signature validation succeeded. Exit condition: Policy, freshness, IRR, and visibility verified.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ST-004 — S3 ELIGIBLE\_HEAD\_SELECTED

**definition\_short:** Accepted visible head fixed.

**definition\_operational:** Names the workflow state in which accepted visible head fixed. Exit condition: Replay completed.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ST-005 — S4 REHYDRATED\_VALIDATED

**definition\_short:** Validated context assembled.

**definition\_operational:** Names the workflow state in which validated context assembled. Exit condition: ALLOW emitted.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ST-006 — S5 FAIL\_SAFE

**definition\_short:** Persistent context suppressed.

**definition\_operational:** Names the workflow state in which persistent context suppressed. Exit condition: Authorized recovery path starts.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** Fail-safe suppression; fail\_safe\_release

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ST-007 — S6 TOOL\_QUARANTINE

**definition\_short:** Tool-state isolated.

**definition\_operational:** Names the workflow state in which tool-state isolated. Exit condition: Separate approval or discard.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** QUARANTINE; MRF-TOOL-QUARANTINE

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ST-008 — S7 RECOVERY\_REPLAY

**definition\_short:** WAL or continuity replay in progress.

**definition\_operational:** Names the workflow state in which wal or continuity replay in progress. Exit condition: Convergence proven.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** WAL; recovery\_phase; wal\_replay\_needed

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### ST-009 — S8 READMISSION\_PENDING

**definition\_short:** Fail-safe exit under controlled authority.

**definition\_operational:** Names the workflow state in which fail-safe exit under controlled authority. Exit condition: All obligations satisfied.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** READMISSION\_PENDING

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# Transition Terms

**Entry count:** 8

### TR-001 — startup\_complete

**definition\_short:** Trigger in the transition model from S0 STARTUP\_READONLY to S1 SNAPSHOT\_LOCKED.

**definition\_operational:** Names the trigger that moves the workflow from S0 STARTUP\_READONLY to S1 SNAPSHOT\_LOCKED when the guard V\_BOOT\_MODE PASS is satisfied. On failure: S5 FAIL\_SAFE or ESCALATE.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** S0 STARTUP\_READONLY; S1 SNAPSHOT\_LOCKED

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### TR-002 — snapshot\_locked

**definition\_short:** Trigger in the transition model from S1 SNAPSHOT\_LOCKED to S2 STRUCTURAL\_VERIFIED.

**definition\_operational:** Names the trigger that moves the workflow from S1 SNAPSHOT\_LOCKED to S2 STRUCTURAL\_VERIFIED when the guard V\_SNAPSHOT PASS is satisfied. On failure: S5 FAIL\_SAFE.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** S1 SNAPSHOT\_LOCKED; S2 STRUCTURAL\_VERIFIED

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### TR-003 — structural\_checks\_done

**definition\_short:** Trigger in the transition model from S2 STRUCTURAL\_VERIFIED to S3 ELIGIBLE\_HEAD\_SELECTED.

**definition\_operational:** Names the trigger that moves the workflow from S2 STRUCTURAL\_VERIFIED to S3 ELIGIBLE\_HEAD\_SELECTED when the guard V\_FRAME..V\_SIG PASS is satisfied. On failure: S5 FAIL\_SAFE.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** S2 STRUCTURAL\_VERIFIED; S3 ELIGIBLE\_HEAD\_SELECTED

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### TR-004 — eligibility\_checks\_done

**definition\_short:** Trigger in the transition model from S3 ELIGIBLE\_HEAD\_SELECTED to S4 REHYDRATED\_VALIDATED.

**definition\_operational:** Names the trigger that moves the workflow from S3 ELIGIBLE\_HEAD\_SELECTED to S4 REHYDRATED\_VALIDATED when the guard V\_FRESHNESS + V\_POLICY + V\_IRR + V\_VISIBILITY PASS is satisfied. On failure: S5 FAIL\_SAFE.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** S3 ELIGIBLE\_HEAD\_SELECTED; S4 REHYDRATED\_VALIDATED

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### TR-005 — rollback\_detected

**definition\_short:** Trigger in the transition model from Any state to S5 FAIL\_SAFE.

**definition\_operational:** Names the trigger that moves the workflow from Any state to S5 FAIL\_SAFE when the guard V\_ANCHOR or V\_COUNTER\_CONT FAIL is satisfied. On failure: QUARANTINE + ESCALATE.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** Any state; S5 FAIL\_SAFE

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### TR-006 — wal\_replay\_needed

**definition\_short:** Trigger in the transition model from Recovery path to S7 RECOVERY\_REPLAY.

**definition\_operational:** Names the trigger that moves the workflow from Recovery path to S7 RECOVERY\_REPLAY when the guard V\_WAL\_PHASE indicates recovery is satisfied. On failure: S5 FAIL\_SAFE.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** Recovery path; S7 RECOVERY\_REPLAY

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** WAL; S7 RECOVERY\_REPLAY; recovery\_phase

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### TR-007 — recovery\_converged

**definition\_short:** Trigger in the transition model from S7 RECOVERY\_REPLAY to S8 READMISSION\_PENDING.

**definition\_operational:** Names the trigger that moves the workflow from S7 RECOVERY\_REPLAY to S8 READMISSION\_PENDING when the guard No duplicate effects is satisfied. On failure: S5 FAIL\_SAFE.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** S7 RECOVERY\_REPLAY; S8 READMISSION\_PENDING

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### TR-008 — authority\_release

**definition\_short:** Trigger in the transition model from S8 READMISSION\_PENDING to S0 STARTUP\_READONLY.

**definition\_operational:** Names the trigger that moves the workflow from S8 READMISSION\_PENDING to S0 STARTUP\_READONLY when the guard Readmission approved is satisfied. On failure: Remain blocked.

**normative\_status:** normative

**source\_refs:** §12 Workflow and State Transitions

**related\_terms:** S8 READMISSION\_PENDING; S0 STARTUP\_READONLY

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# Abbreviation Terms

**Entry count:** 7

### AB-001 — WAL

**definition\_short:** Write-ahead log used for recovery ordering and phase control.

**definition\_operational:** Names the write-ahead log whose phase ordering prevails during recovery and whose ambiguity can force QUARANTINE until convergence is proven.

**normative\_status:** normative

**source\_refs:** §2 Agent Overview; §4 Input Contract; §7 Ordering and Verification Sequence; §10 Validator Catalogue; §12 Workflow and State Transitions

**related\_terms:** V\_WAL\_PHASE; recovery\_phase; S7 RECOVERY\_REPLAY

**synonyms:** write-ahead log

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** wal\_replay\_needed; S7 RECOVERY\_REPLAY; recovery\_phase

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### AB-002 — MRF-RESTORE-REQ

**definition\_short:** Machine-readable form for restoration requests.

**definition\_operational:** Names the machine-readable restoration request form whose canonical fields are request\_id, source\_id, requested\_head, and policy\_profile.

**normative\_status:** normative

**source\_refs:** §15 Machine-Readable Forms

**related\_terms:** restoration\_request

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### AB-003 — MRF-VALIDATOR-BUNDLE

**definition\_short:** Machine-readable form for validator results.

**definition\_operational:** Names the machine-readable form that carries validator\_id, status, evidence\_ref, and timestamp\_or\_counter.

**normative\_status:** normative

**source\_refs:** §15 Machine-Readable Forms

**related\_terms:** validator\_bundle\_id

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### AB-004 — MRF-RESTORE-VERDICT

**definition\_short:** Machine-readable form for the final verdict.

**definition\_operational:** Names the machine-readable verdict form whose canonical fields are verdict, verified\_head\_digest, snapshot\_id, and failure\_code.

**normative\_status:** normative

**source\_refs:** §15 Machine-Readable Forms

**related\_terms:** restoration\_verdict

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### AB-005 — MRF-TOOL-QUARANTINE

**definition\_short:** Machine-readable form for tool-state isolation.

**definition\_operational:** Names the machine-readable form for tool-state isolation whose canonical fields are tool\_id, schema\_status, allow\_status, and quarantine\_scope.

**normative\_status:** normative

**source\_refs:** §15 Machine-Readable Forms

**related\_terms:** Tool-state; QUARANTINE

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** QUARANTINE; S6 TOOL\_QUARANTINE

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### AB-006 — MRF-READMISSION

**definition\_short:** Machine-readable form for exit from fail-safe.

**definition\_operational:** Names the machine-readable readmission form whose canonical fields are token\_id, approver\_set, and satisfied\_obligations.

**normative\_status:** normative

**source\_refs:** §15 Machine-Readable Forms

**related\_terms:** Readmission; readmission\_request

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### AB-007 — MRF-VALIDATION-LOG

**definition\_short:** Machine-readable form for auditable validation execution.

**definition\_operational:** Names the machine-readable validation log whose canonical fields are validation\_run\_id, test\_id, axis, status, evidence\_ref, and reviewer.

**normative\_status:** normative

**source\_refs:** §15 Machine-Readable Forms

**related\_terms:** validator\_bundle\_id

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

# Optionality Terms

**Entry count:** 4

### OP-001 — Tool-state activation path

**definition\_short:** Optional separate gate for tool-state activation.

**definition\_operational:** Names an optional feature whose absence leaves conversational restoration valid while tool-state remains inactive.

**normative\_status:** implementation\_optional

**source\_refs:** §18 Optional Features

**related\_terms:** Tool-state; tool\_state\_activation

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** Tool-state; tool\_state\_activation

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### OP-002 — Dual-control readmission

**definition\_short:** Policy-dependent but recommended readmission control.

**definition\_operational:** Names an optional readmission arrangement that, if absent, requires the readmission rule to be explicitly narrowed.

**normative\_status:** implementation\_optional

**source\_refs:** §3 Authority Model; §18 Optional Features

**related\_terms:** Readmission; Readmission gate

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** —

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### OP-003 — Semantic continuity score

**definition\_short:** Optional supplementary control for continuity evaluation.

**definition\_operational:** Names an optional supplementary control that may not substitute for mandatory validators.

**normative\_status:** implementation\_optional

**source\_refs:** §18 Optional Features

**related\_terms:** V\_CHAIN; V\_ANCHOR

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** It may not substitute for mandatory validators.

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true

### OP-004 — Auxiliary indices

**definition\_short:** Optional performance-only control.

**definition\_operational:** Names optional indices that may exist for performance reasons but do not affect acceptance or restoration.

**normative\_status:** implementation\_optional

**source\_refs:** §18 Optional Features

**related\_terms:** restoration\_request

**synonyms:** —

**non\_synonyms:** —

**usage\_constraints:** They do not affect acceptance or restoration.

**allowed\_values:** —

**ambiguities:** —

**term\_attested\_in\_spec:** true

**public\_traceable:** true
