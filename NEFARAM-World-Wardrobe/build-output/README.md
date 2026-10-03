# NEFARAM World Wardrobe

Generated distribution for the armor and clothing records added by the active NEFARAM load order. It makes every technically playable added item obtainable without editing any installed source mod.

## Runtime design

- **SkyPatcher** adds one low-probability router to each reviewed vanilla merchant or loot list. Nested generated lists keep every leaf below 80 entries and prevent thousands of direct additions from overwhelming vanilla loot.
- **Container Item Distributor** adds category routers only to exact merchant chest records. Generic chest or wardrobe base records are never targeted.
- **SPID 7.2+** gives six explicitly approved complete outfits to generic non-unique bandit or Thalmor actors at 1% per outfit. The late `zz_` file is a fallback; focused SPID outfit mods keep precedence.
- Two ESL catalogues hold item pools. A third ESL router depends on those catalogues and is the only generated plugin referenced by runtime distributor configs.

No vanilla records, installed armor mods, NPC records, cells, or leveled lists are overridden in the generated plugins.

## Classification and rarity

The generator scans new `ARMO` records from active non-official plugins. A record is eligible when it is named, playable, has a body template, and has armor-addon links. Quest, scripted, unique, restraint, and transformation items remain eligible by design. Deleted, non-playable, unnamed, model-less, obvious invisible/test/skin records are reported but not distributed.

Items are classified into common clothing, fine clothing, mage/religious wear, light armor, heavy armor, several faction pools, and oddities. Each category is divided into value quartiles:

| Tier | Player level | Pool chance-none |
|---|---:|---:|
| 1 | 1 | 75% |
| 2 | 8 | 85% |
| 3 | 18 | 92% |
| 4 | 30 | 97% |

The outer SkyPatcher router has another 50% chance-none. CID category routers use 25%. This keeps high-value equipment rare even though exhaustive coverage is aggressive.

## Build and validate

```powershell
.\Build-And-Deploy.ps1
```

The script runs the .NET 9 / Mutagen generator, validates every generated plugin and required config, and copies the runtime files to `<mo2-root>\mods\[NoDelete] NEFARAM - World Wardrobe`.

To inspect the exact vanilla list and merchant-container records recognized by this installation:

```powershell
dotnet run --project .\Generator -- --inspect-targets
```

Edit `Generator\rules.json` to force categories, include a suspicious record, exclude a record, or change the explicit NPC outfit allowlist. Generated files under `build-output\` are replaced on every build.

## Reports

- `coverage.csv`: every eligible item, category, tier, and acquisition route.
- `excluded.csv`: every rejected armor record and the precise reason.
- `coverage.md`: high-level totals and invariants.

The build fails if an eligible record has no acquisition route, a configured vanilla target does not exist, an output master is unavailable, an ESL record budget is exceeded, or a generated list is empty/oversized.

## Load order

Enable SkyPatcher and place this MO2 mod after the armor/clothing mods. Load the catalogues after all their masters and the router after both catalogues. A new game or disposable test save is recommended for the first visual and economy pass.

## Load-order format repair (2026-09-06)

Generated plugins now use ESL-flagged .esp files with the master flag clear. They retain light-plugin slot usage and load after their ESP dependencies. Do not rename them back to .esl. Runtime uses the separate [NoDelete] mod ending in - Load Order Fix; the original installed mod remains disabled for rollback.

The migration preserves record IDs and contents but changes plugin filenames. Existing saves may lose items or references from the old plugins; use a new game for guaranteed compatibility. Saves are untouched. Never load old and new catalogues together.
Catalogue01 requires both Fertility Mode plugins; Catalogue02 requires Skyrim On Skooma. Keep those dependencies enabled for this build. Removing either requires a separately reviewed regeneration.
