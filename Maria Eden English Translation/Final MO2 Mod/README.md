# Maria Eden Complete English Translation

Complete English override for the 2026-08-04/2026-08-09 Maria Eden build used by NEFARAM.

Coverage:

- All 12,911 unique embedded plugin strings were reviewed with Codex using record type, FormID, EditorID, and field-path context.
- Dialogue, messages, quest objectives, books, menus, NPC labels, activators, cells, locations, worldspaces, map markers, and door-facing destination names are included.
- Existing English and technical identifiers are preserved where appropriate.
- Two German-looking values intentionally remain unchanged because they are NPC surnames: `Ildrid Grünwald` and `Verona Blaufuß`.
- All 50 Maria JSON/UI translation files are included.
- Four loose PEX overrides translate seven remaining hardcoded German notifications.

Safety and validation:

- This is a separate reversible MO2 override; the original Maria Eden mod is not modified.
- All six plugin replacements preserve their original FormID sets, master lists and ordering, and translated-string field counts.
- All 25,092 plugin text-field paths were checked against the final translation map.
- The four PEX files change only eight string-table entries representing seven notifications; their bytecode/data tails are byte-for-byte identical to the originals.

Install this folder after Maria Eden. Keep the separate Maria Eden Key Configuration mod at higher MO2 priority than this translation.
