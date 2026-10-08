# Paradigm note — prolog — AGT-VRA-001

Observational, bounded to this NNT run.

## What prolog made easy

The §12 transition model is a decision table, and Horn clauses map to it one row per clause:
`transition(StateIn, Event, StateOut, Conditions)` carries each row's guard as a term, so the spec
surface and the code sit at the same shape. Dispatch on `(current_state, trigger, validator_passed)`
is head unification against clause heads, so `next_state/4` needs no explicit conditionals to select an
edge. The two exclusivity rules the spec states — rollback blocking priority over every other rule
(`Verified_Rehydration_Agent_Specification.md:142`) and the terminal projection state
(`Verified_Rehydration_Agent_Conformance_Tests.md:493`) — are expressed by clause order plus a single
cut each, which is where cut belongs. The §14 evidence contract became a fact base of `bundle_field/3`,
and the presence/producer oracles reduced to `forall/2` and `findall/3` over those facts.

## What prolog made hard

Three spec forms did not sit directly in a single clause head. The S0 on-failure "S5 or ESCALATE"
disjunction (`Verified_Rehydration_Agent_Specification.md:228`) and the non-`Sx` From-fields "Any state"
and "Recovery path" (`:233`, `:234`) had to be re-expressed: a rollback catch-all clause ahead of the
table, and the recovery origin bound to `S5` from its exit condition (`:219`). The parameterized
authority-release target "S0 or S1" (`:236`) is naturally nondeterministic as two `transition/4` facts,
but the single-valued projection surface `next_state/4` required a separate `declared_authority_release_target/1`
fact plus a cut to yield one value, so enumeration of the admissible set and the projected result had to be
kept as distinct predicates. Because evidence-field VALUES are deployment substrate (§16), those slots
carry representative ground tokens rather than terms derivable inside the program.
