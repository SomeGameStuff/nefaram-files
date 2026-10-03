# NEFARAM - Disable Skyrim On Skooma

This is a small load-order patch for the NEFARAM Skyrim setup. It overrides
Skyrim On Skooma's `SOS_Quests` controller quest and clears its `Start Game
Enabled` flag.

## Installation

Enable this mod in MO2 and place its plugin at the bottom of the load order,
after `Skyrim On Skooma.esp`, `_NEFARAM_____AFTERSynthesis_____.esp`, and
`Synthesis_0.esp` through `Synthesis_4.esp`.

To re-enable Skyrim On Skooma, disable this patch in MO2.

## Limitations

The original plugin remains installed because Synthesis output depends on it.
This patch prevents the main Skooma quest from starting automatically; it does
not unload the plugin, remove its assets, or unwind a quest/trip that is already
running in an existing save. For best results, enable it before starting a new
game or load a save from before Skyrim On Skooma started.
