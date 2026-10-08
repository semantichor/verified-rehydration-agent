# NNT — Coverage trace for AGT-VRA-001

> Observational only. This report records the buyer-facing claim surface and the partition of conformance tests, both resolved against the pack's CANONICAL files through the harness's canonical-claim-surface pins and byte-verified at preflight.

## Buyer-contract claim surface (an automated step canonical verification)

- specification §"## Core invariants": 7 structural properties pinned.
- specification §"## Deployment obligations": 5 deployment-substrate obligations pinned.

## Conformance test partition (canonical: conformance_tests, derivation kind_field_count)

- Total PT records: 29
- Runnable on projection surface: 26
- Parameterized: 1
- Declarative (release-acceptance gate, not locally runnable): 2

## Canonical guarantees (verbatim, for trace reference)

1. No restoration is permitted before the full verification sequence completes successfully.
2. Any failure in framing, checksum, canonical parse, hash-chain continuity, signature validation, freshness, policy validation, or IRR validity triggers fail-safe handling and suppresses persistent-context injection.
3. Restored persistent state may originate only from the verified and eligible head.
4. Tool-state remains untrusted and inactive unless a separate activation gate and required approval both succeed.
5. Startup remains read-only until the restoration decision is reached.
6. Recovery is idempotent and must not produce duplicate effects or duplicate acceptance.
7. Replay must begin from a deterministic baseline defined by the verified snapshot and applicable local policy.

## Canonical deployment obligations (verbatim, for trace reference)

1. **Stable snapshot availability** — The execution platform must provide a stable snapshot lock or a deterministic equivalent. (Failure impact if unmet: Replay sufficiency is compromised.)
2. **Anti-rollback mechanism** — The implementation must anchor continuity to a non-regressing counter or equivalent anchor. (Failure impact if unmet: Rollback can no longer be provably blocked.)
3. **Local policy bundle** — The deployment must bind policy\_id and compatibility checks to a local, versioned policy bundle. (Failure impact if unmet: Policy closure is compromised.)
4. **Single-writer enforcement** — The execution layer must serialize persistent-state mutation paths and emit writer-lock evidence. (Failure impact if unmet: Determinism is compromised.)
5. **Separate readmission authority** — The deployment must define approver\_set and a recovery workflow for readmission. (Failure impact if unmet: Fail-safe exit is not trustworthy.)

## Bidirectional trace — coarse keyword-overlap matching

Parsed **29 PT records** from `Verified_Rehydration_Agent_Conformance_Tests.md`. The two tables below show keyword-overlap matches between canonical guarantee text and PT Purpose/Procedure/Expected/Oracle prose. Matching is **coarse**: ≥2 shared content tokens (length ≥ 5, common function words and verbs like `verify`/`agent` stripped). A match is a candidate link, not a normative attestation. Multiple matches per guarantee are expected (one guarantee often covers many PTs); zero matches signal either a guarantee that the PT suite does not exercise OR a vocabulary mismatch the coarse matcher cannot bridge.

### Forward — canonical guarantee → matched PT records

| Guarantee | # matched | Top PT IDs (overlap score) | Shared tokens (first 5) |
|---|---|---|---|
| Canonical #1 | 0 | (none) | (none) |
| Canonical #2 | 5 | PT-004 (2), PT-005 (2), PT-017 (2), PT-018 (2), PT-025 (2) | `checksum`, `framing` |
| Canonical #3 | 7 | PT-002 (2), PT-003 (2), PT-008 (2), PT-009 (2), PT-011 (2), PT-013 (2) | `eligible`, `state` |
| Canonical #4 | 1 | PT-014 (2) | `remains`, `tool-state` |
| Canonical #5 | 2 | PT-001 (2), PT-010 (2) | `read-only`, `startup` |
| Canonical #6 | 0 | (none) | (none) |
| Canonical #7 | 2 | PT-016 (2), PT-017 (2) | `replay`, `snapshot` |

### Reverse — PT record → matched guarantees

Each PT is matched against all canonical guarantees using the same coarse overlap rule. A PT with zero guarantee matches is observation that its specific surface is not directly mirrored in the buyer-facing claim text (e.g., evidence-bundle field PTs may share few content tokens with high-level guarantees because they exercise the schema, not the prose).

| PT ID | Kind | # matched | Top guarantee IDs (overlap score) |
|---|---|---|---|
| PT-001 | Runnable | 1 | Canonical #5 (2) |
| PT-002 | Runnable | 1 | Canonical #3 (2) |
| PT-003 | Runnable | 1 | Canonical #3 (2) |
| PT-004 | Runnable | 1 | Canonical #2 (2) |
| PT-005 | Runnable | 1 | Canonical #2 (2) |
| PT-006 | Runnable | 0 | (none) |
| PT-007 | Runnable | 0 | (none) |
| PT-008 | Runnable | 1 | Canonical #3 (2) |
| PT-009 | Runnable | 1 | Canonical #3 (2) |
| PT-010 | Runnable | 1 | Canonical #5 (2) |
| PT-011 | Runnable | 1 | Canonical #3 (2) |
| PT-012 | Runnable | 0 | (none) |
| PT-013 | Runnable | 1 | Canonical #3 (2) |
| PT-014 | Runnable | 1 | Canonical #4 (2) |
| PT-015 | Runnable | 0 | (none) |
| PT-016 | Runnable | 1 | Canonical #7 (2) |
| PT-017 | Runnable | 2 | Canonical #2 (2), Canonical #7 (2) |
| PT-018 | Runnable | 1 | Canonical #2 (2) |
| PT-019 | Runnable | 0 | (none) |
| PT-020 | Runnable | 0 | (none) |
| PT-021 | Runnable | 0 | (none) |
| PT-022 | Runnable | 0 | (none) |
| PT-023 | Runnable | 0 | (none) |
| PT-024 | Parameterized | 0 | (none) |
| PT-025 | Runnable | 1 | Canonical #2 (2) |
| PT-026 | Runnable | 0 | (none) |
| PT-027 | Runnable | 1 | Canonical #3 (2) |
| PT-028 | Declarative | 0 | (none) |
| PT-029 | Declarative | 0 | (none) |

### Bidirectional coverage observation

- PT records with at least one guarantee match: **16 / 29**
- Canonical guarantees with at least one PT match: **5 / 7**

These are coarse-matcher counts, not normative coverage scores. A PT with no guarantee match may still be valid coverage (e.g., evidence-schema PTs that test fields rather than claims). A guarantee with no PT match may indicate the guarantee is exercised indirectly via composite PTs whose Purpose prose summarizes a transition rather than mentioning the guarantee's keywords.

Expected convergence frame: a buyer building from this pack alone, in idiomatically distinct paradigms, should produce implementations that converge on the agent-logic surface (the guarantees above) and diverge on the deployment-substrate surface (the artifacts above). See `aggregate_observations.md` for the observed per-PT convergence in this run.

