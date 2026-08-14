# Maria Eden - Legacy Simple Slavery Record Shim

Local NEFARAM compatibility mod for using Maria Eden's Simple Slavery event routing
without loading the legacy Simple Slavery Plus Plus or Simple Slavery Rebuild runtime.

## Why this exists

Maria Eden ships a 151-byte `SimpleSlavery.esp` whose header describes it as a dummy
plugin used to route Simple Slavery events into Maria Eden. NEFARAM's PEGI16, PEGI18,
Synthesis 2, Synthesis 3, and preconfigured starter save were built while the full
Simple Slavery plugins were present. The dummy preserves the filename but not the
records/FormIDs those outputs expect.

This mod supplies records-only replacements with the original filenames:

- `SimpleSlavery.esp`
- `SimpleSlaveryRebuild.esp`

The builder copies the locally installed plugins byte-for-byte. The original Simple
Slavery mods are then disabled, preventing their BSAs, compiled scripts, SEQ file, and
voices from loading. This preserves the exact plugin structure expected by the heavily
baked starter save while making the legacy implementation inert: its record attachments
cannot execute without their PEX files. Maria still sees the expected
`SimpleSlavery.esp` filename and handles the external events.

## MO2 order

Enable this mod at higher left-pane priority than Maria Eden. Disable:

- `Simple Slavery Plus Plus`
- `Simple Slavery Rebuild`
- `Simple Slavery Plus Plus Voice`

Keep `SimpleSlavery.esp` and `SimpleSlaveryRebuild.esp` enabled in the right pane.
Do not change PEGI16, PEGI18, Synthesis 2, or Synthesis 3.

## Build and validation

Run `Build-And-Deploy.ps1`. The builder validates that:

- both output plugins are byte-for-byte copies of the installed record providers;
- the runtime shim contains no BSA, PEX, PSC, SEQ, or voice files;
- all Simple Slavery/Rebuild overrides and links in the active PEGI/Synthesis outputs
  resolve to records supplied by the shim.

This is a local derivative compatibility build. Do not publish the generated plugin
files without confirming the upstream Simple Slavery permissions.
