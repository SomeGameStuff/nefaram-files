# Maria Eden Complete English Translation

A reversible English override for the 2026-08-04/2026-08-09 Maria Eden build used by NEFARAM. The ready-to-install mod is in [`Final MO2 Mod`](./Final%20MO2%20Mod).

## Coverage

- All 12,911 unique embedded plugin strings were reviewed with Codex using record type, FormID, EditorID, and field-path context.
- Dialogue, quest text, messages, books, menus, NPC labels, cells, locations, worldspaces, map markers, activators, and door-facing destination names are included.
- All 50 JSON/UI translation files are included.
- Four loose PEX overrides translate seven remaining hardcoded notifications.
- Existing English and technical identifiers are preserved where appropriate.
- `Ildrid Grünwald` and `Verona Blaufuß` intentionally remain unchanged because they are NPC surnames.

## Installation

Install the contents of `Final MO2 Mod` as a separate MO2 mod after Maria Eden. It replaces the six Maria plugins with master- and FormID-preserving English versions and supplies loose data/script overrides. Do not merge it into the original mod.

If Maria Eden Key Configuration is installed, keep that patch at higher MO2 priority than this translation so its key-handling scripts win conflicts.

## Source layout

- `Final MO2 Mod` — ready-to-install override.
- `translation-codex-final.json` — final source-to-English translation map.
- `Catalogs` — completed source/English pairs with plugin and record context. No `English` field is left empty.
- `Codex Review` — review batches, outputs, manual overrides, and residue audits.
- `Generator` — Mutagen extraction/writing and translation audit utilities.
- `Data` — translated JSON and interface source files.
- `Source` — readable Papyrus source equivalents for the four notification overrides. Runtime PEX files were produced by string-table patching so their bytecode remains unchanged.

## Validation

- All six generated plugins preserve their original FormID sets, master lists, master ordering, record counts, and translated text-field counts.
- All 25,092 plugin text-field paths were checked against the final translation map.
- German-residue scans found no unresolved translated output; location-facing strings received a separate audit.
- The four PEX overrides change only eight string-table entries representing seven messages. Their bytecode/data tails are byte-for-byte identical to the originals.
- The finished runtime folder was hash-compared with `Final MO2 Mod` after installation.
