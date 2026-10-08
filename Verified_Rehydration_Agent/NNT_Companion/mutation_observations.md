# NNT — Mutation observations for AGT-VRA-001

> Observational only. Raw status-change counts per `(paradigm, mutant category, PT id)`. **No aggregate kill rate, mutation score, survival rate, detection rate, or percentage of any kind is computed or implied.** See `INTERPRETATION_RULES_INFORMATIVE.md` §3 for the forbidden-vocabulary list.

## Methodology

- Each paradigm reconstruction applied 8 deterministic mutation operators to its baseline.
- Operators are mapped to 6 shared semantic categories (MS-01..MS-06).
- For every (mutant, PT) pair, the harness records the live-executed status. The counts below are the number of mutants in a given (paradigm, category) cell whose PT status differs from the unmutated baseline's status on the same PT.

## Per-paradigm mutant build statistics

| Paradigm | Mutants total | Mutants built | Categories observed |
|---|---|---|---|
| python | 8 | 8 | MS-01, MS-02, MS-06 |
| rust | 8 | 5 | MS-01, MS-02 |
| prolog | 8 | 6 | MS-01 |
| c | 8 | 7 | MS-01, MS-02, MS-05 |
| bash | 8 | 7 | MS-01, MS-02 |

## Cross-paradigm `(category, PT) -> per-paradigm status-change counts`

| Category | PT | bash | c | prolog | python | rust |
|---|---|---|---|---|---|---|
| MS-01 | PT-001 | 1 | 1 | 1 | 1 | 1 |
| MS-01 | PT-003 | 1 | 1 | 1 | 1 | 1 |
| MS-01 | PT-014 | 1 | 1 | 1 | 1 | 1 |
| MS-02 | PT-001 | 1 | 1 | 0 | 1 | 1 |
| MS-02 | PT-002 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-003 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-004 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-005 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-006 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-007 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-008 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-009 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-010 | 1 | 1 | 0 | 1 | 1 |
| MS-02 | PT-012 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-014 | 1 | 0 | 0 | 0 | 0 |
| MS-02 | PT-024 | 1 | 0 | 0 | 0 | 0 |
| MS-05 | PT-015 | 0 | 1 | 0 | 0 | 0 |
| MS-06 | PT-001 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-002 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-003 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-011 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-012 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-013 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-014 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-015 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-024 | 0 | 0 | 0 | 1 | 0 |
| MS-06 | PT-027 | 0 | 0 | 0 | 1 | 0 |

## Reader's frame (REQUIRED)

- A count of `N` in cell `(lang, category, PT)` means: in this NNT run, `N` of the mutants in category `<cat>` for paradigm `<lang>` produced a PT status on `<PT>` that differs from the unmutated baseline's status on the same PT.
- The count is not a quality measure. It says nothing about the spec, the test suite, or any implementation. It is purely an observation about the relationship between (paradigm, mutation operator, PT) under one specific protocol.
- Counts across rows are not comparable as ratios. The denominator (mutants built per category) varies per paradigm. The reader who wants the denominator reads the per-paradigm table above; the harness does not compute ratios.

