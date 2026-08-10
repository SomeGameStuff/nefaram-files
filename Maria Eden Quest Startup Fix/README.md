# Maria Eden Quest Startup Fix

NEFARAM compatibility patch for Maria Eden Prostitution `d2026.8.9`.

## Technical cause

`MEP_PimpStartFoodTrackerHello` calls `MEP_QuestManager.Start(MEPFoodTracker)` while `MEPPimpStartup` is playing. The required `master` alias on `MEPFoodTracker` rejects actors for which `IsInScene != 0`, so the speaking pimp cannot fill the alias and native `Quest.Start()` returns false.

`MEPPimpSlaves` also made `slave2` mandatory even though the same expandable group treats `slave3` and `slave4` as optional. Initialization therefore failed when no second eligible slave NPC was loaded.

The upstream `2026-08-04` archive includes source but no compiled `.pex` for the three alias scripts restored here. Papyrus logs consequently report binding failures for the affected records.

## Fixes

- Allows `MEPFoodTracker` to fill its required master alias while the master is participating in the pimp startup scene. The tracker is observational and does not assign a package to this alias.
- Marks `MEPPimpSlaves` alias `slave2` optional, consistent with its optional `slave3` and `slave4` aliases. A second eligible slave is no longer required to initialize the controller.
- Restores three compiled scripts omitted from the upstream archive: `MEPPimpSlavesPlayerAlias`, `MEPDLC1RagralAlias`, and `MEPFarmerSlaverySlaveAlias`.

The patch does not change `MEP_QuestManager` or suppress failure notifications.

## Build and deployment

Run `Build-And-Deploy.ps1`. It builds an ESL-flagged plugin from the winning English-translated `MariaProstitution.esp`, compiles the three Papyrus sources, and deploys a separate MO2 mod:

`C:\Games\nefaram\mods\[NoDelete] Maria Eden Quest Startup Fix`

Enable the mod after Maria Eden and its translation mods. Load `NEFARAM_MariaEdenQuestStartupFix.esp` after `MariaProstitution.esp`.

`build-stubs` contains compile-only declarations for the two Maria Eden owning quest classes. They are never copied into the runtime mod.
