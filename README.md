# Verified Rehydration Agent (AGT-VRA-001)

A specification document package, distributed free of charge. It defines the normative boundary and decision logic for controlled rehydration of persistent context, permitting restoration only after complete verification.

Agent page: https://semantichor.com/agents/vra/

## License and acceptance

The package is governed by the Verified Rehydration Agent License, included as `Verified_Rehydration_Agent/Verified_Rehydration_Agent_License.md`. In its words:

> Where you obtained the package otherwise than at the point of distribution, you accept this license by accepting it at semantichor.com, in the same two confirmations, before any use of the package.

> A copy of the package held without acceptance confers nothing.

Acceptance page: https://semantichor.com/agents/vra/license/

The supplementary derivations carry their own rights statement, in the "Rights and use" section of `Verified_Rehydration_Agent_Supplement/README.md`.

## Contents

| Folder | Content | Archived record |
|---|---|---|
| `Verified_Rehydration_Agent/` | The package, 148 files, as distributed | https://doi.org/10.5281/zenodo.23228655 |
| `Verified_Rehydration_Agent_Supplement/` | The supplementary derivations, 18 files | https://doi.org/10.5281/zenodo.23228966 |

Both folders are byte-identical to the archived ZIP files. Release v1 of this repository carries the same two ZIP files.

## Integrity

| Item | SHA-256 |
|---|---|
| `Verified_Rehydration_Agent.zip` | `a71a83895b031796a140217343dc3ff37eea275f5067791072781f3af0ba31bc` |
| manifest_ref (SHA-256 of `Verified_Rehydration_Agent_Manifest.sha256`, bound in the License) | `f97626b2c11dd159ae4f6a4986d76d62e08b13775f06383f7df7d8ef3987ed4f` |
| agent_manifest_ref (the frozen normative core, 7 files) | `4b3bf7d83c9aea06b0e6d894df556d9716c61ab3ff7f2ebc95991cc92e3ad072` |
| `Verified_Rehydration_Agent_Supplement.zip` | `cd8a26baada8baad21bc1bd52d014cbc523eb96d4daa7a0613cbd81f5aec2bb6` |
| Supplement Manifest (`VRA_Supplement_Manifest.json`) | `20c19f2c25931001d71525fd318a60e9272b5e4b48c37a84c562adc3d9169100` |

## Checking a clone

```text
cd Verified_Rehydration_Agent
sha256sum -c Verified_Rehydration_Agent_Manifest.sha256
cd ../Verified_Rehydration_Agent_Supplement
python verify_anchor.py ../Verified_Rehydration_Agent/Verified_Rehydration_Agent_Manifest.sha256
```

The second check prints the supplement Manifest's SHA-256, which equals the value above. The package's own runbook, `Verified_Rehydration_Agent/verify.md`, governs the verification of the package.

The `.gitattributes` file at the repository root (`* -text`) keeps every file byte-identical on checkout, on every operating system. The supplement verifier inventories its folder recursively, so a file added inside that folder makes the check fail.
