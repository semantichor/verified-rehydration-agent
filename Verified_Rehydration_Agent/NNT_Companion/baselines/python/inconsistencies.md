# Inconsistencies log — AGT-VRA-001 — python

Observed after reading all cited cross-references. Neutral statements of what was observed.

## O1. Count of structural guarantees differs across documents

**Observed**: The Whitepaper states a count of four. `Verified_Rehydration_Agent_Whitepaper.html`:1128
reads "The Verified Rehydration Agent provides four guarantees. These are structural properties
of the specification." The README states seven. `Verified_Rehydration_Agent_README.md`:69 reads
"7 structural properties, defined in spec §2 Agent Overview / Core invariants", and
`Verified_Rehydration_Agent_Specification.md`:47-59 enumerates seven core invariants.

**Both locations**: `Verified_Rehydration_Agent_Whitepaper.html`:1128 (count four);
`Verified_Rehydration_Agent_README.md`:69 and `Verified_Rehydration_Agent_Specification.md`:47
(count seven).

**Cross-references read while reconciling**: README front matter (`Verified_Rehydration_Agent_README.md`:6,
"Where this README and the specification appear to differ, the specification controls"); the README
reading-order note that the Whitepaper is non-normative (`Verified_Rehydration_Agent_README.md`:54,
"carry no terminology from it into implementation"); the Whitepaper colophon
(`Verified_Rehydration_Agent_Whitepaper.html`:1128 section context declares the Whitepaper
non-normative and states the specification controls); the seven §2 core invariants themselves
(`Verified_Rehydration_Agent_Specification.md`:47-59).

**Why the surface figures still differ after those reads**: The two numbers describe the same
underlying properties at different enumeration granularities — the Whitepaper presents a coarser
four-item roll-up (G.01–G.04), the README and §2 present the seven-item normative set. The
documents agree on precedence (the Whitepaper is non-normative and the specification controls), so
the intent is aligned; the literal counts four and seven are not made equal by reading the
cross-references. This is recorded as an observation of the two figures, not as a characterization
of either document.

No other inconsistencies observed in this NNT run.
