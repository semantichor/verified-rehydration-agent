# Paradigm note — python — AGT-VRA-001

Observational. What `python` did with this specification.

## What python made easy

The §12 transition model mapped directly onto a structural `match` over `(State, Trigger)`
Enum tuples. The spec's own precedence fell out of `case` ordering: the "Any state"
`rollback_detected` row became the first arm `case (_, Trigger.ROLLBACK_DETECTED)`, the
`S6 TOOL_QUARANTINE` terminality became `case (State.S6_TOOL_QUARANTINE, _)`, and the
fail-closed default for an unenumerated pair became `case _: raise UnmappedTransitionError`.
The §6 verdict vocabulary and §12 states became `Enum` members whose `.value` carries the
canonical label the Conformance Tests compare against, so the projection surface returns
spec-labelled results with no translation table. The §10 validator catalogue became a frozen
`@dataclass` keyed by an `Enum`, and `frozenset` expressed the §11 hard-fail set and the
critical-severity set as first-class data. Enum `match` with a trailing `case _` gives the
compiler-checked exhaustiveness the spec's finite enumeration wants.

## What python made hard

The §14 evidence contract resisted a single fixed type. Its Required=Yes fields are constant
but its conditional fields (failure explanation, `recovery_phase`, `readmission_token_id`) and
producer tags vary per fixture, so a fixed `@dataclass` with many `Optional` fields plus a
None-omitting serializer fit the presence oracles poorly; per-fixture dict builders were used
instead, which places the bundle shape outside the type annotations that guard the state
machine. A second friction: the Conformance Tests name triggers in CamelCase
(`StartupComplete`) while §12 uses snake_case (`startup_complete`) and the tool trigger is the
phrase "tool-state invalid"; a normalization layer (`_norm`) was needed to accept all three
spellings, since `Enum` lookup alone keys on one canonical form.
