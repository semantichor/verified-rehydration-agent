# Paradigm Note — c / AGT-VRA-001

Observational. Records what the c paradigm did with this specification in this NNT test run.

## What c made easy

The §12 Transition model mapped directly onto a C function-pointer table: `transition_fn_t g_handlers[NUM_STATES][NUM_TRIGGERS]`, where each enumerated transition row became one small handler and an unfilled cell (`NULL`) became the fail-closed default. The §7:142 rollback-priority rule and the §12 `Any state | rollback_detected` row became a single guard evaluated before the table lookup, so the "blocking priority over every other restoration rule" ordering fell out of statement order rather than needing a data structure.

The §6 verdict vocabulary and the §12 `S0`–`S8` states became C `enum` types. Because the specification's surface is finite and fully enumerated, writing enum `switch` statements with no `default` let the compiler (`-Wswitch`, under `-Wall -Wextra`) report any enumerator left unhandled — the compiler itself tracked completeness against the enumerated surface, and the build produced no warnings.

## What c made hard

The §14 evidence contract distinguishes fields that are `Required: Yes` from fields that are `Conditional`. C has no built-in optional or record-with-presence type, so the bundle became a `struct` of `const char *` with an explicit `emit_field` that suppresses empty values, and the Yes/Conditional distinction had to be carried by convention (empty string means absent) instead of by the type system, with per-fixture builder functions supplying each bundle class.

The workflow surface names states as labels containing spaces (for example `S0 STARTUP_READONLY`). Since C `argv` tokens split on whitespace and strings are not enum-convertible, the input boundary needed a compact `S0`-style token decoder (`parse_state`) paired with a separate full-label emitter, doubling the state naming into an input form and an output form.
