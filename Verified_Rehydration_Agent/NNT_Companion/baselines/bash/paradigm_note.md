# Paradigm note — bash

Observational; scoped to this NNT run.

## What bash made easy

The §12 state-event transition model maps directly onto a bash `case` on the
composite key `"${state}|${trigger}|${validator_passed}"`: each §12 row becomes
one pattern, and the §7 priority rules (rollback first, then `S6` isolation)
become two small guarding `case` statements checked ahead of it. The §8 / §16
fail-closed requirement lands naturally on two idioms at once — the `case`
`*)` default routes any unenumerated pair to `S5 FAIL_SAFE`, and a `trap ... ERR`
converts an unexpected runtime error into the same fail-closed emission. The §6
verdict vocabulary and §12 state labels, which D4 AR-002/AR-003 keep distinct,
were kept apart with simple string namespacing (`verdict::` versus `state::`).

## What bash made hard

The §14 evidence contract asks for a bundle of named fields, which fits an
associative array for value handling — but bash associative arrays have no
defined iteration order, so a stable, reproducible bundle required carrying a
parallel indexed array (`EV_ORDER`) to fix field order for emission. The
Minimal Run Note's `next_state(...)` surface is described as a function that
returns a state, yet bash functions return only an integer status; the state is
therefore carried on stdout and captured by the runner, and that stdout channel
made the harness sensitive to an interpreter path containing a space (the
`$BASH` value `bash`), which had to be quoted or replaced to
avoid word-splitting. Finally, bash has no type system to keep a verdict token
and a state token from colliding, so their distinctness (D4) had to be encoded
by hand rather than enforced by the language.
