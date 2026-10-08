# Verified Rehydration Agent Pack — Verification Runbook (`verify.md`)

> Drop this file next to an **unzipped** SEMANTICHOR Verified Rehydration Agent pack and run it inside an
> agentic environment with a shell and a filesystem (Cowork, Codex, or any comparable agentic shell).
> It must **execute**, not be read. If you cannot run commands, stop: every result below is `NOT RUN`.

---

## What this runbook is
This pack **declares its own numbers** — how many artefacts it ships, how many canonical terms it
indexes, how many conformance records it carries, what those records return. This runbook has you
**reproduce those declared values on your own machine**, before you build anything against the
specification.

You are verifying AGT-VRA-001, the Verified Rehydration Agent — a fail-closed gatekeeper that verifies persisted state before restoring it.

Each check has the same shape: **find the value the pack declares, observe the value your machine
produces, record whether they match.** A mismatch is a fact you report, not a judgment you make:
either the bytes you received are not the bytes that were published, or your environment differs.
Both are worth knowing before you build. Neither requires you to decide what it means.

## What this runbook does not do
- **It does not evaluate your implementation or your deployment.** The specification is
  execution-neutral: it defines *what*, never *how*. What you build, and the substrate you build it
  on, are yours — this runbook has no visibility into either and makes no claim about them. Where
  the line between what the specification determines and what it leaves to you falls is stated by the
  pack itself, not by this runbook (Ground Rule 9).
- **It does not judge the specification against the rehydration / state-verification domain.** Whether the model is
  *right for your problem* is a human judgment. Nothing here establishes it, and nothing here should
  be read as establishing it.
- **It does not audit the NNT companion as a product.** The companion is informative, non-normative
  evidence — a partial demonstration that the specification is derivable. Part B reproduces what it
  declares; it does not assess it. The specification controls.

## Ground rules
1. **Do not trust this file.** It ships with the product. Re-run every command and trust the **raw
   output**, not anything written here. If this file and the output disagree, the output wins — and
   you report the discrepancy.
2. **Execute, never assert.** No "looks rigorous" / "appears complete." Run the check, paste the
   **raw output**, state what it shows. Did not run it → `NOT RUN`, never a match.
3. **Compare against the pack's own declarations, never against this file.** This runbook carries
   **no numbers**. Every expected value is read from a shipped document — and you record where you
   read it. A value this file supplied would be a second source of truth that could disagree with the
   first.
4. **A check you could not complete is `INCONCLUSIVE` or `NOT RUN` — never a mismatch.** If a
   verifier fails, a toolchain is missing, or your security software blocks a step, that is the
   status you record, naming the cause. An unconfirmed result is never reported as a match, and never
   as a defect.
5. **Structural only.** These checks confirm that the pack reproduces what it declares. They cannot
   confirm that what it declares is correct for the rehydration / state-verification domain. Never certify that half.
6. **The pack co-states its figures. Read every place, not the first place.** A quantity this pack
   declares is normally stated in more than one document: the **anchor** that defines it, and one or
   more derivatives that restate it. Before you reproduce a declared value, find every place the pack
   states it, and record each one. A value you read in a single document and nowhere else is a value
   you have not finished reading. Where an anchor and a derivative disagree, do not adjudicate between
   them: record both, name which one is the anchor, and check whether the specification states how
   derivatives relate to it.
7. **Name the axis before you compare.** Two figures are comparable only if they count the same thing.
   Before you put two numbers side by side, write down what each one counts — on the same line as
   the value, in the same row of the table. Where the pack declares the rule that relates two figures,
   read that rule before counting: it is the criterion, and a figure outside it is correctly different.
   Where the pack declares no such rule, record both figures with their axes and stop. Two of this
   pack's own declarations differing is not a result this runbook produces.
8. **Earn a discrepancy.** Before you write `MISMATCH` or `INCONCLUSIVE`, name the document that would
   have to change for the finding to be real, and state that you read that document end to end. It
   must cost you as much to report a discrepancy as to set one aside; otherwise the cheap direction
   wins and the report fills with findings that dissolve on the first careful reading. A discrepancy
   you cannot anchor to a document is a reading you have not finished, not a defect you have found.
9. **Latitude is not a gap.** The specification is execution-neutral by design: it determines the
   agent logic and deliberately leaves the deployment substrate to the implementer. That line is drawn
   by the pack, not by this runbook — the companion states an expected convergence frame, naming
   the surface on which independent implementations should converge and the surface on which they
   should diverge. Which document carries it is not fixed: find it, read it, and record where you read
   it, before you write down any "the specification does not say". The operative test: where the
   specification declares a parameter but declares no outcome for some combination of it, the surface
   is declared and the outcome is left open — that is latitude, and you record it as latitude.
   Where the specification declares neither, that is a gap, and you record it as one. Reporting
   latitude as a defect marks the package down for the property it is built to have.
10. **The canonical set is one document. Read it whole before you record anything.** The
    canonical set is the Specification, the Semantic Index in all three of its editions — human,
    YAML and JSON — the Coverage Matrix, the Ambiguity Register and the Conformance Tests; where
    the pack is a composed integrator, the connector annexes it names belong to the set as well.
    Naming those documents is not a declared value under Ground Rule 3: it identifies the object you
    are reading, and every figure inside it still comes from the pack. They are not a library you
    consult. They are one document distributed across several files, each written assuming the
    others, and the sentence that settles what you are looking at is regularly in a file you would
    not have opened. Read all of it before you record a single result, and list the set you
    identified in your report. Reading it in fragments — the section that looks relevant, the file
    a check appears to name, the part you needed for the number in front of you — does not produce
    a partial verification. It produces confident wrong ones. If you did not read the whole set, every
    row you write is `NOT RUN` under this rule.
    **Say how you read each of them.** Listing the set is not reading it, and "I read the
    whole set" is a sentence you can write in good faith while a file of it is still unread.
    So record, file by file, the depth you read it at: as text, read through; as an extracted
    document body, naming the parts you extracted; or as structured data, read entry by entry
    with every field as text. Counting a structured edition's entries, validating its metadata
    and comparing the editions against each other is **not** reading it — that is the
    vocabulary-closure check, which asks a different question, and a file you handled that way
    is a file you have not read under this rule. Say so and the rows resting on it are
    `NOT RUN`, which is the honest outcome and the cheap one. The structured editions are where
    this divides, because they are the only part of the set that can be processed completely
    without being read at all.
    The same whole governs every finding you record. Before you write `MISMATCH` or
    `INCONCLUSIVE`, read the canonical set again — whole, as one document, with the finding in
    hand — and ask the question Ground Rule 8 does not: not what would have to change for your
    finding to be real, but what in this pack already accounts for what you saw. The sentence that
    accounts for it sits, by construction, in a file you would not have opened for this point, so a
    targeted re-reading will not find it and a fragment cannot settle it. If the set accounts for
    the observation, the row is `MATCH` and that document is its anchor. If nothing in it does, the
    row stands, and it now carries both readings. State in your report that you made this
    confrontation and what the set said. A finding recorded without it is not a finding; it is a
    reading you stopped early.
    State the depth of that re-reading as well. A reading this confrontation is meant to catch
    is one that already felt complete — anchored to a document, internally consistent, and
    assembled from the files the question appeared to live in. Re-read at the depth you read
    at the first time and you will arrive where you already are.

## Inputs
- The unzipped **Verified Rehydration Agent pack**: Specification, Semantic Index (D1–D4), Ambiguity Register,
  Conformance Tests, Coverage Matrix, License, SHA-256 Manifest, Whitepaper, and the NNT companion
  (baselines + mutants + attestations).
- **Compiled-paradigm binaries, and your security software.** If the pack includes compiled
  paradigms, it ships **prebuilt, unsigned** executables as Zone-B evidence, and Part B may have you
  **build more of them yourself**. Freshly built unsigned binaries carry no reputation, so a
  mainstream antivirus or endpoint tool may flag, block or quarantine them as unrecognised. **That is
  a property of unsigned binaries, not a finding about this package** — the same bytes may pass on
  one host and be quarantined on another, or on the same host on a different day. This runbook does
  **not** ask you to change your security settings, and you should not disable protection to run it.
  If your security software blocks a check, that check is `INCONCLUSIVE` or `NOT RUN` under Ground
  Rule 4 — never a mismatch and never a package defect — and you report it as such, naming the tool
  and the file it acted on. The compiled paradigms ship their **source** alongside the binaries.
- **Your transfer, and line endings.** A manifest binds bytes. If you unzip, copy or check this pack
  out through a tool that rewrites line endings, text files will hash differently from the values the
  Manifest records, and a verification can fail across many files at once — which reads exactly
  like tamper. The test that separates the two: normalise line endings on your copy and verify again.
  If the set then matches, you have measured an artefact of your own transfer rather than a modified
  package, and you record it as an observation naming the tool that introduced it — never a
  mismatch and never a package defect (Ground Rule 4). If it still fails after normalisation, that is
  a real verification failure and you report it as one.

---

## Procedure

### 0 — Reading order
Read the README first: it states the order in which the documents are meant to be read, and what each
one establishes. Follow that order, and follow it to the end. The canonical files are one document in
several files: a figure you have read in one of them is not a figure you have finished reading (Ground
Rule 6). Each check below names an **anchor** — the document in which the value is defined. The
anchor is where you start, not the only place the pack states it.

---

## Part A — the pack
The normative core and the package documents: what you build from.

### 1 — Integrity and final-release readiness
- **Declared:** the Manifest lists one SHA-256 entry per shipped file, and the License binds the
  Manifest's own hash as `manifest_ref`. A Manifest **may** carry a header naming the files
  deliberately excluded from the chain; this runbook does not require one. Where there is no header,
  identify the uncovered files by comparing the shipped set against the entries, and record them as
  an observation — the absence of a statement the pack never promised is not a gap (Ground Rule 3).
  Record which **configuration** you hold: a unit package on its own, or the same unit inside a
  larger package that composes several. A file a unit does not carry may be carried once at the
  composed level by design, so an absence read in the wrong configuration is not an absence. Where
  you cannot tell which configuration you hold, say so.
- **Reproduce — verify every artefact.** Use the command for your platform; all three read the same
  manifest and report the same result:
  - **Linux:** `sha256sum -c <manifest>.sha256`
  - **macOS:** `shasum -a 256 -c <manifest>.sha256` *(`sha256sum` is not installed by default)*
  - **Windows:** PowerShell and `certutil` cannot consume a manifest file. Either run the Linux command
    inside **WSL** or **Git Bash**, or verify file-by-file in PowerShell:
    `Get-Content <manifest>.sha256 | ? { $_ -notmatch '^\s*#' -and $_.Trim() } | % { $h,$f = $_ -split '\s+',2; if ((Get-FileHash $f.Trim() -Algorithm SHA256).Hash -ieq $h) { "OK   $f" } else { "FAIL $f" } }`
    *(the filter skips the manifest's `#` header lines, which are not file entries)*
- **Reproduce — close the chain.** Recompute the Manifest's own hash and compare it to the
  `manifest_ref` bound in the License. A pack may bind more than one reference — one over what you
  received, one over a frozen core — and the rule by which a reference is derived may itself be
  stated outside the bundle you hold. Reproduce the reference whose derivation the pack states. Where
  a reference's derivation rule is not stated in what you received, that check is `INCONCLUSIVE` under
  Ground Rule 4, recorded with the rule you looked for and where you looked: a reconstruction you
  could not perform is never a mismatch.
- **Reproduce — tamper-evidence.** Alter one byte of any artefact, re-run the verification, confirm
  that file is now reported as failing, then restore it and confirm the full set matches again.
- **Reproduce — final release.** The pack declares itself a final release. Grep every shipped file
  for non-final markers (`-draft`, `-rc`, `RC`, `TODO`, `PLACEHOLDER`, `WIP`). Note that this runbook
  names those markers in this sentence, so it will match itself — that is expected. State the
  **domain of your sweep** before you run it: which files you read as text, which you read as
  extracted document bodies, which you scan as raw bytes, and which you skipped. Two auditors
  sweeping different domains produce different counts from the same pack, and a count means
  nothing without the domain recorded beside it. For every
  other hit, record **which file carries it and what that file is**: the pack states which of its
  documents are normative and which are informative evidence, and a marker in the release identity of
  a normative document is a different observation from a marker in the metadata of the apparatus that
  produced the evidence. Name the axis (Ground Rule 7); do not merge them into one count.
- **Record:** entries matched / total, whether the Manifest hash equals `manifest_ref` and which
  reference you reproduced, whether your deliberate edit was detected and the restore returned the set
  to matching, and every non-final marker found outside this file together with the document that
  carries it.

### 2 — Vocabulary closure
- **Declared:** every classified quantity has an **anchor** — the document that defines it and
  states the criterion by which it is classified. The Semantic Index (D1) is the anchor for the
  canonical terms and states its **own derivation rule**, which tokens it is meant to resolve,
  together with its per-category counts; the Ambiguity Register and the Conformance Tests are the
  anchors for their own quantities. The README restates them: it is a derivative, not an anchor
  (Ground Rule 6). Read the criterion before counting — it is what makes a figure right or wrong,
  and an item outside it is correctly absent.
- **Reproduce — one row per criterion, not one row per quantity.** A pack may partition the *same*
  set on more than one criterion: by what a record is and by what it obliges, by what a document
  declares statically and by what a run enumerates. Those are two lawful partitions of one set, not a
  contradiction, and each is reproduced against its own criterion, in its own row, with its axis named
  (Ground Rule 7). Then count the entries in D1, compare the JSON and YAML editions against each
  other, compare both against D3, and check the per-category counts against the totals D1 states.
- **Record:** per criterion — the declared count, its anchor, what that criterion counts, and the
  count you observed; and whether the index editions agree. Where two of the pack's own figures differ
  and the pack declares a rule relating them, reproduce the rule and record it. Where it declares no
  such rule, record both figures with their axes and stop: that is not a mismatch (Ground Rules 7 and
  8).

### 3 — Decision logic and fail-closed behaviour
- **Declared:** the specification's transition model gives, for every state and trigger, the target
  on success and the target on failure. The Conformance Tests give, per record, the expected result
  and the oracle it is measured against.
- **Reproduce — the suite.** Run the conformance suite against one shipped baseline. The baseline is
  the **vehicle**, not the object: what you are reproducing is the expected result declared by each
  record.
- **Reproduce — fail-closed.** The surface you enumerate is the one the **specification**
  declares: the states and the triggers named in its transition model, read from the specification
  itself. It is not the token set of a shipped baseline — a baseline is an implementation, and a
  token it carries that the specification does not declare is outside the surface, not an additional
  state. Record where you read the surface (Ground Rule 6).
  Take the axes from the model, not from this sentence. Where the specification declares the validator
  outcome to be an input independent of the trigger, enumerate both outcomes; where the gate is
  integrated into the trigger, the validator flag is not a free axis at that cell, and enumerating it
  anyway manufactures inputs the declared semantics never produces. Record which axes you enumerated
  and why.
  Then confirm that **state restored / ALLOW** is reached only by the path the specification declares
  reaches it, and by no path in which a critical gate failed.
- **Record:** per record, expected result and observed result; for the sweep, the axes you enumerated,
  the total combinations, and every path that reached state restored / ALLOW. Where the pack declares a
  state label and a verdict token to be distinct types, record them as two values and do not collapse
  one into the other. Where the specification declares a parameter on an edge but declares no outcome
  for some combination of it, that is a declared surface with an undetermined outcome: record it under
  Ground Rule 9, never as a fail-open. If an observed value differs from a declared one, record both
  and stop there — attributing the difference is not your task.

---

### 4 — What remains yours to build
- **Declared:** the pack states what it does **not** ship — the artefacts your team produces, the
  deployment substrate it assumes, and the obligations it delegates to your own release gate. Which
  document carries that statement is not fixed: the README normally names the artefacts, and the
  specification normally names the assumptions and the delegated obligations. Find every place the
  pack states them (Ground Rule 6).
- **Reproduce:** enumerate the buyer-side artefacts and obligations the pack declares, from the
  documents that declare them, and check that the statements correspond. An obligation named in one
  place and absent from another is a difference you record with both readings and their axes (Ground
  Rule 7), not a defect you have found. Where the conformance suite designates records as
  bounded-external, check that each one names the obligation it rests on.
- **Record:** the declared set, where you read each part of it, and whether the places agree. This is
  the scope of what the pack hands you and the scope of what it leaves with you. A pack that declares
  both is one you can plan a build against — and that is the only sense in which this runbook
  speaks to readiness.

---

## Part B — the derivability evidence
**Informative, non-normative.** The NNT companion is a *partial demonstration* that the specification
is derivable — a sample of paradigms, not a property of the product. Nothing in this stage can
establish a defect in the specification, and nothing in it overrides Part A.

**Independence, stated up front:** the companion discloses in its own attestations that the
reconstructions share model, prompt-author and training data. They are paradigm-isolated, not
independently derived. Convergence therefore demonstrates that the specification is **derivable** —
one source can rebuild it several ways and land on the same behaviour — and **not** that it is
unambiguous to independent readers. This runbook does not re-derive that bound; it reports it.

**The baselines are study artefacts, and the companion says so:** they are not reference
implementations. Do not complete them, and do not rebuild one to fill a column. Where a paradigm
ships no runner, or ships one that records output without checking its own oracles, that is the
shape the companion has — record what is there and what is not. A paradigm without a runner is
not a delivery gap, and a runner you wrote yourself measures your harness, not this pack.

### 5 — Conformance reproduction across paradigms
- **Declared:** the companion states, per paradigm, how many conformance records pass and how many
  are skipped, and names the reason each skip is declarative or bounded-external. Which document
  carries that statement is not fixed — find it, and record where you read it (Ground Rule 3).
- **Reproduce:** run the shipped suite in each of python, rust, prolog, c, bash and record the pass/skip profile you
  observe. A shipped runner may carry the **build-host paths of the harness that produced it**. If a
  runner cannot resolve its own paths on your machine, repoint them to your local copy, **disclose
  the change as a diff**, and change nothing else — no oracle, no expected value, no assertion. A
  runner you had to repoint is still a reproduction; a runner whose oracle you touched is not.
- **Record:** declared profile and observed profile per paradigm, each with the document you read it
  in. A run's own completion marker and the companion's ledger may report the same profile over
  different denominators — one counting what that paradigm enumerated, the other what the suite
  declares. Name which figure you took and where from: a denominator that differs between a marker and
  the ledger is a difference of axis (Ground Rule 7), not a mismatch. Nothing further.

### 6 — Inspection of the observation record
- **Read, do not re-derive:** the mutation observations, the interpretation rules, the coverage trace
  and the auto-disclosure audit. Each states what it claims and — importantly — what it declines to
  claim: the companion computes no kill rate, no coverage score and no quality figure, by its own
  rules.
- **Record:** what each document declares, and any bound it places on itself. This is an inspection,
  not a measurement; there is no expected value to reproduce.

---

## Required report format

Before the first table, list the canonical set you identified and state that you read it whole
(Ground Rule 10). A report without that line is incomplete in the same way a row without its
`Where declared` reference is.

**A. The pack.** One row per **criterion**, not one row per quantity (Ground Rule 7):

| Check | Declared value | Anchor | What it counts | Observed value | Result |
|---|---|---|---|---|---|
| … | … | document + section | the criterion this figure is counted on | … | `MATCH` / `MISMATCH` / `INCONCLUSIVE` / `NOT RUN` |

Every row states the anchor it read the declared value in, and what that figure counts. A row missing
either is incomplete. Use `INCONCLUSIVE` or `NOT RUN` — never `MISMATCH` — for anything you could
not complete (Ground Rule 4). Do not add commentary to this table: a mismatch is reported by the two
values, and needs no interpretation from you.

Every `MISMATCH` row and every `INCONCLUSIVE` row carries one line beneath the table, and only those
rows do: **the document that would have to change for this to be real**, and the statement that you
read that document end to end (Ground Rule 8). A row that cannot carry that line is withdrawn before
the report is sent.

**B. The evidence.** The same table for checks 5 and 6, followed by a short
**Observations** paragraph. Observations carry **no verdict**: record what you saw, not what you
conclude from it. Part B cannot produce a finding against the specification.

**C. Boundary.** State plainly what this run did not cover: your implementation and deployment
substrate, any obligation the pack declares as external, the configuration you audited, and whether
the specification is correct for the rehydration / state-verification domain. Do not score these — name them, so the reader knows what remains theirs.

**D. If this run is one of several.** Where the same package is verified by more than one auditor, or
in more than one environment, the reports are meant to be compared mechanically rather than read side
by side as prose. Use the check identifiers and the row keys exactly as they appear above, and the
four status words exactly as spelled — no synonyms, no additional statuses, no merged rows. A row
present in one report and absent from another is then visible as a difference in coverage rather than
as a disagreement about the package, and the delta between two reports can be produced by a diff. If
you depart from the row keys, say so and give the mapping.

End with this line, verbatim:

> *The credibility of this report rests on the raw outputs above, which you can re-run independently —
> not on this prompt. Structural claims are verified by execution; semantic correctness against the
> domain remains a human judgment, deliberately not certified here.*

---

### Note on honesty (for you, the auditor)
The one failure mode that matters is a report claiming **more** than the raw outputs support: a match
where a check did not run, a completed status where a verifier failed, a reproduced profile you did
not actually observe. Report **less** than you proved, never more — and where you did not look, say
so rather than inferring.

That rule runs in both directions, and the second direction is the easier one to miss. A finding is
also a claim: `MISMATCH` asserts that two things which ought to agree do not, and `INCONCLUSIVE`
asserts that you could not settle it. Both are claims about the package, and both cost the reader real
work to set aside. Reporting a discrepancy you have not anchored is claiming more than the raw outputs
support, in the direction that feels safe. Ground Rule 8 is this same rule, applied to findings.
