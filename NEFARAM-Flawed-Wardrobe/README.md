# NEFARAM Flawed Wardrobe

Generated MO2 add-on that creates early-access flawed versions of 300 armour and clothing records without editing any source mod.

## Runtime behavior

- The forge shows one `Flawed Work Order: <item>` entry for each selected source item.
- A work order uses the source recipe ingredients when the source plugin provides a recipe, plus 2 leather strips and 1 charcoal.
- Crafting produces a temporary scripted token. It uniformly chooses one of ten fixed variants, adds exactly one result, and removes itself.
- Five outcomes use Negative Enchantments effects and five use SLER effects, giving a 50/50 normal/adult split.
- `Refit One Carried Flawed Item` converts one eligible carried variant back to its exact clean source for 2 leather strips and 1 charcoal.
- Refit thresholds are 25 (cloth/leather), 40 (steel), 60 (advanced/elven), 80 (glass/ebony), and 100 (daedric/dragon). If no carried item qualifies, the controller refunds the materials.

## Installed layout

`C:\games\nefaram\mods\NEFARAM - Flawed Wardrobe\`

- `NEFARAM_FlawedWardrobe_CatalogueA.esl` through `CatalogueD.esl`
- `Scripts\NFW_CraftResult.pex`
- `Scripts\NFW_RefitController.pex`
- `README.md`

Each catalogue contains 75 source items and 750 variants. Catalogue D also contains the shared refit lists, controller token, and single refit recipe; it therefore loads after catalogues A-C.

## Rebuild

Vanilla Papyrus sources are extracted to `C:\tmp\skyrim-scripts-source\Source\Scripts`. Compile both project scripts with the installed Papyrus compiler, then run the generator with offsets `0`, `75`, `150`, and `225` in that order. Run `dotnet run -- --validate` afterward.

Selection is deterministic: take up to 12 eligible wearable records from each configured source in source order, then fill any remaining slots from additional eligible records in source order. Shields and obvious invisible/dummy/placeholder records are excluded.

## Dependencies and order

Keep `disenchantments.esl`, `SLER.esp`, and all selected armour sources enabled. Load catalogues A-D after those dependencies and in alphabetical order. The NEFARAM profile currently satisfies this order.

Static validation confirms 3,000 variants, 300 ten-item result lists, 300 work orders, no direct variant recipes, parallel refit mappings for all 3,000 variants, valid VMAD properties, ESL flags, and sub-4,096 record counts. A final in-game forge/save-load smoke test remains a manual QA step.
