# Anchor attestation — AGT-VRA-001 — python

WHAT-anchor for this derivation, answered from the R3.1 read without re-opening files.

## Q1. What does the buyer-contract promise as delivered?

The pack delivers an execution-neutral, self-contained normative specification of the
agent's decision logic at the restoration boundary: the controlled verdict vocabulary
(`Verified_Rehydration_Agent_Specification.md`:96 — ALLOW, DENY, QUARANTINE, ESCALATE,
READMISSION_PENDING), the normative ordering and verification sequence (§7), failure
semantics (§8), the 18-entry validator catalogue with severities (§10), the decision
table (§11), the 9-state workflow and its transition model (§12), gate logic (§13),
the minimum evidence bundle contract (§14), and the machine-readable forms (§15).
README §"What the specification guarantees" states this as 7 structural properties
(no restoration before the full verification sequence completes; any framing/checksum/
parse/chain/signature/freshness/policy/IRR failure triggers fail-safe suppression;
restored state only from the verified and eligible head; tool-state inactive unless a
separate activation gate and approval both succeed; startup read-only until the
restoration decision; idempotent recovery with no duplicate effects; deterministic
replay baseline from the verified snapshot and local policy). Whitepaper §05 presents a
coarser non-normative rollup of four guarantees over the same properties.

## Q2. What does the buyer-contract explicitly delegate to deployment?

Per README §"What your team must produce" (spec §19 Reuse Note + §16 Deployment
obligations), five companion artifacts are built by the buyer and are NOT in the pack,
so I do not implement them: (1) a stable snapshot facility (snapshot lock or
deterministic equivalent with binding evidence); (2) an anti-rollback mechanism
(non-regressing counter or equivalent anchor); (3) a local, versioned policy bundle
binding `policy_id`, `V_POLICY`, and `V_COMPAT`; (4) a single-writer persistence control
plane emitting writer-lock and contention evidence; (5) a readmission authority workflow
(`approver_set`, recovery workflow, readmission-token evidence, release procedure).

## Q3. How does the conformance test suite partition?

The suite holds 29 records anchored 1:1 to the specification: 26 directly runnable on the
projection surface, 1 parameterized (PT-024, authority-release branch under a declared
envelope), and 2 declarative bounded-external checks attested at the release-acceptance
gate (PT-028 for V_COMPAT, PT-029 for V_WRITER_LOCK). The Minimal Run Note states the
suite PASS condition: every runnable test passes, the parameterized authority-release
branch lands only in the permitted state set, and both declarative bounded
external-enforcement checks are satisfied by implementation evidence.

## Q4. Where is the boundary between spec-derivable and deployment-substrate PTs?

Spec-derivable (executable against the local transition and evidence surfaces): the
workflow-transition PTs (PT-001..015, PT-024, PT-027), the verdict/state-taxonomy PTs
(PT-022, PT-023), and the evidence-bundle presence/producer PTs (PT-016..021, PT-025,
PT-026). Deployment-substrate: PT-028 (V_COMPAT policy-compatibility enforcement, bound
to the buyer's local policy bundle) and PT-029 (V_WRITER_LOCK single-writer enforcement,
bound to the buyer's persistence control plane) — the Minimal Run Note names these as
bounded external obligations not locally runnable, proved by architecture evidence rather
than by the workflow transition surface. PT-024's admissible target set {S0, S1} is fixed
by the specification but its concrete resolution rests on the operator-declared readmission
authority workflow, so it is executable locally only under a buyer-declared envelope.
