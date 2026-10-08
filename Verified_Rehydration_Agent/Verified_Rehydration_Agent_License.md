# Verified Rehydration Agent — License

## Subject

This license governs the use of the Verified Rehydration Agent specification package (agent_id: AGT-VRA-001), **together with the NNT companion material included in the package**.

The license has two clearly scoped zones. **Zone A** covers the agent specification and carries its full normative status. **Zone B** covers only the included NNT companion material and is demonstration-only. Nothing in Zone B qualifies, dilutes, or conditions the normative status of the agent specification in Zone A.

This package is distributed free of charge. No payment is required, now or ever, for anything this license permits.

---

## ZONE A — Agent (the specification)

### What this package is

The Verified Rehydration Agent specification is a ready-to-build, execution-neutral normative document. It is not a concept paper, not a framework, not a set of guidelines, and not an architecture diagram.

It is the document you hand to an engineering team when you want them to build a component that produces the guarantees the specification defines. The engineering team does not need to make design decisions about what the agent should do, how its logic should work, what it should record, or how it should fail. Those decisions are made. The specification contains them.

Composing this agent with others from the same library, including as a component within a family integrator, is specified in the relevant family pack — a separate package with its own documents and terms.

### What this package is not

This package is not software, SaaS, a managed service, consulting, support, managed operations, or implementation delivery. It is not a reference implementation, and no reference build is shipped — the only executables included are the NNT reproducibility binaries (Zone B), which are explicitly not a reference build. No implementation, and no implementation guidance or suggestions of any kind, are provided in any form. Everything in the package describes how a conforming executable agent must behave and what a conforming implementation must satisfy — not how to build it.

### Grant of rights

Subject to the Restriction section below, you are granted, free of charge and perpetually:

- the right to implement the agent from this specification, in any language or paradigm;
- the right to deploy and operate those implementations for any lawful purpose, including in the course of a commercial business, and to use them **as internal machinery within your own products and services**, including products and services you offer to your own customers;
- the right to study, analyze, and reference the specification for any purpose — including describing, quoting reasonably, reviewing, critiquing, teaching, benchmarking, and publishing analysis of it, including publication of test results and criticism;
- the right to redistribute the package, free of charge, **complete and unmodified**, provided this license travels with it.

The implementations you build are yours. SEMANTICHOR claims no ownership over the source code, builds, or deployments you produce from this specification.

Acceptance of this license is free of charge and is available to any party. Each legal entity accepts in its own name.

### Restriction

You shall not:

- **offer the agent to third parties as a product, a library, a package, an API, a service, a service tier, or any other identifiable offering of its capability** — whether for payment or free of charge;
- distribute an implementation derived from this specification as a standalone software product, library, or package;
- redistribute the specification package other than complete and unmodified, or charge any fee for redistributing it;
- modify, adapt, translate, abridge, restate, or create derivative works of the specification text, the companion material, the Manifest, or this license — other than translations and annotations for your own internal use that you do not distribute.

**The line.** Using an implementation as internal machinery inside your own product or service is permitted, including commercially and at any scale: the third party consumes your product, and neither selects nor obtains the agent as such. Offering the capability itself is not permitted. *Permitted:* your application uses the agent internally to validate state, and your customers buy your application. *Not permitted:* you expose the agent as an API, ship it as a library, or offer it as a service, so that a third party can obtain or invoke its capability as a thing in itself.

Composition is internal machinery. Where an implementation of this agent is composed with others under an integrator, and what reaches the third party is the composed verdict, this agent is internal machinery within that composition.

Compliance with the Restriction section is a condition of the rights granted under this license; those rights terminate automatically if it is not met, and are reinstated on cure, prospectively only. Implementations already supplied to third parties before the breach remain licensed.

This restriction extends to the NNT companion material under Zone B.

### Disclaimers

This package is a normative specification. It is not software, SaaS, a managed service, consulting, support, managed operations, implementation delivery, or a validation service.

The agent is semantically closed — every term is resolved within the package's Semantic Index and Ambiguity Register. The correctness of any implementation built from it is therefore the implementer's responsibility. No warranty is provided on any implementation built from this specification, and SEMANTICHOR is not obligated to provide support.

A verdict produced by an implementation of this specification is a technical output of that implementation. It is not legal advice, and it does not itself constitute, certify, or guarantee the regulatory compliance of any system or decision.

---

## ZONE B — NNT companion (Non-Normative Tests, demonstration-only)

**This zone applies only to the NNT companion material** (reproducible baselines, reports, attestations, and any included binaries). It does not apply to the specification documents or the Manifest, and does not diminish or qualify the normative status of the agent specification in Zone A.

### What the companion is

The package includes NNT companion material — Non-Normative Tests — as included evidence accompanying the agent. It is informative, non-normative, and demonstration-only. It serves as **bounded evidence** of the agent's **derivability** and **self-sufficiency** from the package, and of the **behavioral convergence observed** across paradigm-isolated reconstructions.

### What the companion is not

The companion is not a reference implementation, not a recommended implementation or model to copy, not a certification, approval, or warranty, and not a measure, score, or guarantee of quality, security, fitness, or correctness. It does not certify, validate, or prove that the specification is correct. Implementation is performed solely from the Zone A specification; any reliance on the companion as an implementation pattern is at your own risk.

### Bounded observations

Every statement in the companion is bounded to the run that produced it and is to be read as such — "in this NNT test, the following was observed." Any figures it reports are specific to this agent and this run and do not generalize.

### Binaries

Any executable files in the companion are included solely to demonstrate reproducibility of the baselines. They are provided AS IS, are not part of what you implement, and are run entirely at your own risk. Their hashes appear in the Manifest only so you can verify reproducibility, not as an endorsement of execution.

### Restriction

The Zone A Restriction section applies equally to the NNT companion material.

---

## Distribution and acceptance

This specification is distributed free of charge. Merchant-of-Record terms do not apply to this free distribution. This license governs your use of the specification and is between you (the Licensee) and SEMANTICHOR.

You accept this license at the point of distribution, before the package is delivered to you. Acceptance is given in two confirmations, both required: acceptance of the document as a whole, and express acceptance of the following clauses, whose full text is presented inline at the point of confirmation, not by reference or link: *(i)* the Limitation of liability and the Disclaimers; *(ii)* the automatic termination of rights upon non-compliance with the Restriction section, and their reinstatement on cure; *(iii)* the Governing law and exclusive jurisdiction clause; *(iv)* the reservations set out in the Restriction section.

Where you obtained the package otherwise than at the point of distribution, you accept this license by accepting it at semantichor.com, in the same two confirmations, before any use of the package.

Delivery of the package occurs only after both confirmations are given. A copy of the package held without acceptance confers nothing.

## Limitation of liability

The package is provided "as is." To the maximum extent permitted by law, SEMANTICHOR shall not be liable for any indirect, incidental, special, consequential, or punitive damages, nor for any loss of profit, data, or goodwill, arising out of or relating to the package or its use. SEMANTICHOR's total aggregate liability under this license shall not exceed one hundred euros (EUR 100). Nothing in this license excludes or limits liability that cannot be excluded or limited under applicable law.

## Data protection

Any implementation you build operates on your own data and on data you control. SEMANTICHOR supplies a specification only: it has no access to, and does not process, any data handled by your implementations. With respect to such data you are the sole controller and/or processor; SEMANTICHOR is neither a controller nor a processor of it and has no data-protection obligations (including under the GDPR) in relation to your operational data.

## Version and updates

This license covers the package version identified by the manifest_ref below. A revised specification is published under its own license; this license confers no right to updated, future, or other versions. Do not implement against a version-mismatched package.

## Succession

This license does not extend automatically to your successors and assigns. Any party may accept it in its own name, free of charge.

## Governing law

This license is governed by Romanian law. Any dispute arising out of or in connection with this license is subject to the exclusive jurisdiction of the Romanian courts.

## Severability

If any provision of this license is held to be unenforceable, the remaining provisions shall remain in effect. The rights granted in this license are conditional on the Restriction section being enforceable.

## Identifier and integrity reference

This license is minted last, over the finalized and tested package, and binds it through the reference below. The integrity chain is one-way: License -> Manifest -> artifacts. A package is authentic only if its artifacts match the Manifest and the Manifest matches the reference below.

Licensee: the natural person or legal entity that has accepted this license and holds a complete, unmodified copy of this package. Acceptance is free of charge and requires no purchase.

agent_id: AGT-VRA-001
manifest_ref: f97626b2c11dd159ae4f6a4986d76d62e08b13775f06383f7df7d8ef3987ed4f
