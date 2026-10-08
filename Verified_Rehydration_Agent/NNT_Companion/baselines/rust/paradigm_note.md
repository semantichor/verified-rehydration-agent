# Paradigm note — rust — AGT-VRA-001

Observational; scoped to this NNT run.

## What rust made easy

The specification's controlled vocabularies map directly onto exhaustive enums. §6 verdict semantics (`ALLOW`, `DENY`, `QUARANTINE`, `ESCALATE`, `READMISSION_PENDING`), the §12 state model `S0..S8`, and the §12 trigger set each became a `#[derive(Clone, Copy, PartialEq, Eq)] enum`, and the compiler's non-exhaustive-match error kept every `label`/`tag`/`code` projection total as the enums grew. The Conformance Tests projection surface `next_state(current_state, trigger, validator_passed)` maps almost one-to-one onto a single `match (state, trigger)` where each conditional transition is a `match` guard (`if validator_passed`) rather than a nested `if` — the §12 "Guard" column and the rust arm-guard are the same shape. §10's validator catalogue became a `Validator` enum with `severity` and `failure_produces` methods, so severities and failure outcomes stayed attached to their identifiers. `Result<T, String>` carried token parsing without sentinel strings, and the distinct enum discriminants gave PT-022/PT-023 their verdict-vs-state tag separation for free.

## What rust made hard

The §7 priority rules and the §12 open cases resist a purely per-arm exhaustive `match`. "Rollback detection has blocking priority over every other restoration rule" and the terminal isolation of `S6 TOOL_QUARANTINE` had to be expressed as ordered wildcard arms placed before the enumerated rows, and the §16 fail-closed default for non-enumerated `(state, trigger)` inputs landed in a `_` catch-all arm — so the tuple space over states x triggers is not exhaustively enumerated the way a single enum is, and the compiler cannot check that surface. The §12 `authority_release` target "S0 or S1" (PT-024) does not reduce to one return value, so the operator's declared choice enters through an environment parameter that sits outside the pure enum function signature.
