# Lola Expanded Addons

Merged NEFARAM add-on for Submissive Lola, Custom Framework Lola Addon,
Transformative Elixirs, Fertility Mode, and Milk Mod Economy.

This is an MO2 addon mod. It does not edit the original mod folders. It ships
loose Papyrus overrides for existing Lola scripts, JSON-configurable checks, and
`LolaExpandedAddons.esp` for owner dialogue topics used by the milk, body, and
fertility interactions.

## What This Replaces

This merged mod replaces the separate addon mods previously built for this list:

- Lola Fertility Mode Addon
- Lola Milk Economy
- Lola Body Potion Routine

Those separate mods should stay disabled when this merged mod is enabled.

## Files Shipped

- `Scripts/cfl_Drugs.pex`
- `Scripts/cfl_lolaMain.pex`
- `Scripts/cfl_LolaMonitor.pex`
- `Scripts/cfl_MCM.pex`
- `Scripts/cfl_Missives.pex`
- `Scripts/LEA_TIF_BodyPotionAccept.pex`
- `Scripts/LEA_TIF_FertilityAccept.pex`
- `Scripts/LEA_TIF_MilkStatus.pex`
- `Scripts/LEA_TIF_MilkTurnIn.pex`
- `Scripts/vkjPlayerAliasScript.pex`
- `LolaExpandedAddons.esp`
- `Source/Scripts/cfl_Drugs.psc`
- `Source/Scripts/cfl_lolaMain.psc`
- `Source/Scripts/cfl_LolaMonitor.psc`
- `Source/Scripts/cfl_MCM.psc`
- `Source/Scripts/cfl_Missives.psc`
- `Source/Scripts/vkjPlayerAliasScript.psc`
- `SKSE/Plugins/LolaExpandedAddons/Config.json`
- `SKSE/Plugins/LolaExpandedAddons/HairPool.json`
- `tools/generate-hair-pool.mjs`

## Intended Behavior

The goal is to make Lola's owner feel more active in systems that already exist
in the modlist. The owner can interfere with the player's body, fertility, and
milk economy through scheduled checks and owner dialogue.

The mod is intentionally conservative by default. Events are chance-based,
cooldown-limited, and use the target mods' own potions/spells where possible.

### Timed Task Compatibility

Submissive Lola and this addon both have tasks that can run for in-game hours or
days. Previously, Lola's long-task check only knew about base Submissive Lola
road-trip and prostitution quests. That allowed addon tasks to overlap in ways
that could be practically unwinnable, such as being sent on a long fetch or sales
assignment while also being pushed into Public Whore service.

This addon now extends Lola's `LongTasksRunning` check. While any supported long
task is active, Lola should not offer another task gated by that same long-task
condition.

The expanded lock currently treats these as mutually exclusive long tasks:

- Submissive Lola road trip.
- Submissive Lola pimped/prostitution quest.
- Lola Expanded/Addons Sales Pet.
- Public Whore integration.
- Public Service.
- Missives.
- Change Town.
- Slave Caravan and its starter quest.
- Lola Buys A House.
- Dungeon Bait.

The lock does not end or repair already-overlapping quests on an existing save.
It prevents additional overlapping starts after the override is loaded.

## Feature Details

### Forced Adventuring Visibility

The Custom Framework Lola Addon "Forced Adventuring" task starts one or more
Missives quests, but the normal quest log only shows Lola's parent task. This
can make it hard to tell which Missives count toward the assignment.

This addon overrides `cfl_Missives` to expose the selected Missives:

- When Lola finishes selecting Missives, a message box lists the chosen quest
  names and whether each one is active or done.
- `MCM > Submissive Lola Extension > Addons` now has a `Forced Adventuring`
  section.
- `Missives status` shows whether the task is inactive, starting, or how many
  selected Missives are complete.
- `Show active Missives` opens the same detail list, including approximate
  in-game hours remaining when the timer is active.

This does not add per-Missive objective lines to the quest log. Dynamic quest
log text would require editing or patching plugin objective records, while this
merged addon remains pluginless.

### Treasure Quest Fallback

Submissive Lola's treasure quest normally completes only when the player loots
from a container tagged with the `BossContainer` location reference type. Some
mod-added dungeons and treasure rooms do not tag their final chest correctly, so
the quest can feel broken even when the player found a reasonable treasure
stash.

This addon overrides `vkjPlayerAliasScript` to keep Lola's original boss-chest
completion and add a configurable fallback.

Default behavior:

- Boss containers still complete the quest exactly as before.
- If the selected chest is not tagged as a boss chest, taking valuable loot from
  a non-owned source container can also complete the quest.
- Player-owned containers, owner inventory, and loose world pickups do not count.
- The fallback only runs while `vkjFindTreasure` is active and before it is
  completed.

`treasure.fallbackMode` controls how permissive this is:

- `0`: off, original boss-container behavior only.
- `1`: valuable loot, default. Completes when the taken gold or item stack meets
  the configured threshold.
- `2`: any container. Any non-owned source container can complete the quest while
  the treasure quest is active.

### Fertility Drug Trick

When Lola's drug trick fires, the owner can also trigger Fertility Mode's built-in
insemination behavior.

Default behavior:

- 15% chance after the drug trick.
- 72 in-game hour cooldown.
- Queues an owner dialogue demand. The player must ask the owner about the
  fertile dose before the Fertility Mode spell is cast.
- Casts Fertility Mode's `_JSW_BB_Inseminate` spell from the owner to the player
  when the dialogue is accepted.
- Does not force guaranteed pregnancy by default.

Fertility Mode still handles its own cycle, conception chance, pregnancy
progression, and birth. The direct pregnancy option exists for testing or more
aggressive play, but it is disabled by default.

### Milk Economy Routine

While Lola ownership is active, the owner can periodically involve Milk Mod
Economy.

Default behavior:

- Starts checking after 4 in-game hours.
- Checks once per in-game hour.
- 35% chance when the cooldown expires.
- 24 in-game hour cooldown.
- Can choose between:
  - forcing a Lactacid dose, or
  - assigning a milk quota, or
  - having the owner start milking the player when the player is full.

For milk quota assignments, the player must return near the owner with enough
MME milk bottles. The owner dialogue hub includes a milk quota status topic while
the quota is active and a turn-in topic when enough milk is ready.

The default quota is 2 bottles, with a 48-hour timeout.

Owner milking uses Milk Mod Economy's own mobile hand-milking function. It does
not call MME's dialogue breastfeeding fragment directly, because that path is
embedded in a dialogue topic script rather than exposed as a stable quest API.

Default owner milking behavior:

- Enabled by default.
- Only runs when the player is already an MME milk maid or milk slave.
- Only runs when the owner is within 500 units.
- Only runs when the player is not in combat, not mounted, and not already being
  milked.
- Requires at least 1 current milk.
- Requires current milk to be at least 75% of MME's current milk maximum.
- When those checks pass, there is a 50% chance that the Milk Economy event
  becomes owner milking instead of Lactacid/quota behavior.

MME still handles its own milking restrictions, animation choice, equipment
logic, breast-row handling, milk bottle output, and "no milk" checks.

### Body Potion Routine

While Lola ownership is active, the owner can periodically feed Transformative
Elixirs according to a longer-running owner mood.

The owner does not decide bigger/smaller from scratch every event. Instead, the
owner picks a mood and keeps it for a configurable duration. The default mood
duration is 168 in-game hours, roughly one week.

Default behavior:

- Starts checking after 6 in-game hours.
- Checks once per in-game hour.
- 35% chance when the cooldown expires.
- 8 in-game hour cooldown.
- Default mood policy is dynamic.
- Default mood duration is 168 in-game hours.
- Queues an owner dialogue demand instead of silently giving a potion.
- The player must ask the owner about the elixir, then the dialogue fragment
  gives and equips the Transformative Elixir.

`body.moodPolicy` controls how the owner chooses a mood:

- `0`: dynamic
- `1`: always bigger
- `2`: always smaller
- `3`: random

Dynamic mood uses `body.sizeOverride` as a manual read on the player's current
body direction:

- `-100`: very small
- `0`: neutral
- `100`: very large

When the override is very small, the owner is biased toward a bigger mood. When
the override is very large, the owner is biased toward a smaller mood. Around
neutral, the owner can go either way.

Changing mood policy or size override in the MCM resets the current mood so the
owner can pick a new one on the next body routine check.

The "bigger" pool uses Transformative Elixirs that generally increase curves,
thickness, muscle, or related body features. The "smaller" pool uses reduction
or slimming-style elixirs. Elixir of Normalcy is disabled by default.

### Automatic Collar Changes

Submissive Lola already has an MCM collar selection and a dialogue path where
the owner can give the player a new collar. This addon can now trigger that
collar swap periodically during Lola ownership.

Default behavior:

- Starts checking after 12 in-game hours.
- Checks once per in-game hour.
- 20% chance when the cooldown expires.
- 72 in-game hour cooldown.
- Requires the owner to be within 500 units.
- Skips while the player is in combat or mounted.
- Skips if the current collar is a quest or blocking device.

The swap uses Lola's existing `vkjDeviceControl.Swapout()` path. That means the
new collar comes from Lola's normal collar MCM selection. If Lola's collar MCM is
set to Random, the automatic event also uses Lola's random collar logic.

The event only changes the player's collar. Playmate collars are left to Lola's
existing playmate systems.

### Bathing Orders

While Lola ownership is active, the owner can periodically react if the player
is visibly dirty or covered in Sexlab Cum Overlays.

Default behavior:

- Starts checking after 8 in-game hours.
- Checks once per in-game hour.
- 25% chance when the cooldown expires.
- 24 in-game hour cooldown.
- Only starts in town by default, using Lola's own town check.
- Counts the player as dirty at bathing dirt stage 3 or higher.
- Counts the player as covered when the combined SCO oral, anal, and vaginal
  counters are at least 2.

If Bathing in Skyrim is available and the owner is nearby, there is a chance the
owner washes the player immediately through Bathing in Skyrim's `BiS_WashActor`
event. Sexlab Cum Overlays listens for Bathing in Skyrim wash events, so this
also gives SCO a normal opportunity to clear persistent cum overlays.

If the owner does not wash the player directly, they give a cleanup assignment.
The player has one in-game hour by default to clean up. The assignment completes
automatically once the dirt/cum checks fall below the configured thresholds. If
the deadline expires, the owner gives a minor Lola punishment by default.

The dirt check supports the common magic-effect stages used by:

- Bathing in Skyrim.
- Bathing in Skyrim Renewed.
- Dirt and Blood.
- Keep It Clean.

If none of those dirt effects are present, the feature can still trigger from
Sexlab Cum Overlays storage counters.

### Hair Style Pool Seeder

Submissive Lola already supports temporary hair style changes through its normal
hair-change quest. That quest reads hair styles from:

`SKSE/Plugins/Lola/HairStyles.json`

This addon does not replace that quest. Instead, it adds a setup helper to the
Addons MCM page that can seed Lola's existing hair style list from a generated
broad NEFARAM hair pool.

Default behavior:

- `HairPool.json` is generated from active hair-related plugins in the NEFARAM
  profile.
- The current generated pool contains 2,232 hair headpart candidates.
- The MCM seed button validates each entry with `Game.GetFormFromFile`.
- Only valid `HeadPart` records with type `3` are added to Lola's style list.
- The clear button removes styles previously seeded by this addon.

After seeding, use Submissive Lola's existing hair settings and select either
`New Style` or `New Style + Random Color`. Lola will then use the seeded styles
with its normal temporary restore behavior.

## MCM

Most commonly changed settings are exposed in:

`MCM > Submissive Lola Extension > Addons`

The MCM page writes to the same JSON file used by the scripts:

`SKSE/Plugins/LolaExpandedAddons/Config.json`

The Addons page also has hair pool utility actions:

- `Seed Lola hair styles`
- `Clear seeded hair styles`
- `Hair styles available`

When Forced Adventuring is active, the Addons page also shows:

- `Missives status`
- `Show active Missives`

The Addons page also exposes Treasure Quest fallback controls:

- `Treasure fallback`
- `Min gold from chest`
- `Min item value`

Bathing order controls:

- `Owner demands bathing`
- `Bathing chance`
- `Bath cooldown hours`
- `Owner bath chance`
- `Cum threshold`
- `Dirt stage threshold`
- `Cleanup deadline hours`
- `Only in town`

If the new Addons page does not appear immediately after installing, save/reload
or wait for SkyUI's MCM registration refresh.

## Config

All settings live in:

`SKSE/Plugins/LolaExpandedAddons/Config.json`

The keys use prefixes:

- `fertility.*`
- `milk.*`
- `body.*`

Important settings:

- `fertility.triggerChance`: chance that Lola's drug trick also triggers
  Fertility Mode.
- `fertility.allowDirectPregnancy`: use Fertility Mode's direct pregnancy spell
  instead of insemination. Default `0`.
- `milk.dailyChance`: chance for a Milk Economy event when its cooldown expires.
- `milk.assignmentMilkCount`: required milk bottles for quota assignments.
- `milk.allowOwnerMilking`: enables owner milking when the player is full.
- `milk.ownerMilkingChance`: chance that an eligible milk event becomes owner
  milking.
- `milk.ownerMilkingFullnessThreshold`: required current milk as a fraction of
  MME's current milk maximum. Default `0.75`.
- `milk.ownerMilkingDistance`: maximum owner distance for owner milking.
- `body.eventChance`: chance for a body potion event when its cooldown expires.
- `body.cooldownHours`: in-game hours between possible body potion events.
- `body.moodPolicy`: `0` dynamic, `1` always bigger, `2` always smaller,
  `3` random.
- `body.sizeOverride`: manual current-size hint from `-100` to `100`.
- `body.moodDurationHours`: how long the owner keeps a chosen mood.
- `collar.enabled`: enables automatic owner collar changes.
- `collar.eventChance`: chance for a collar change when its cooldown expires.
- `collar.cooldownHours`: in-game hours between possible collar changes.
- `collar.ownerDistance`: maximum owner distance for collar changes.
- `bath.enabled`: enables owner bathing orders.
- `bath.eventChance`: chance that a bathing order happens when the cooldown
  expires and the player is dirty enough.
- `bath.cooldownHours`: in-game hours between possible bathing orders.
- `bath.ownerBathChance`: chance the owner bathes the player directly when
  nearby and Bathing in Skyrim is loaded.
- `bath.ownerBathDistance`: maximum owner distance for direct owner bathing.
- `bath.assignmentTimeoutHours`: time allowed to clean yourself.
- `bath.requireTown`: only start bathing orders in town.
- `bath.cumThreshold`: combined SCO cum counter threshold.
- `bath.dirtMinStage`: bathing dirt stage threshold.
- `bath.punishOnFail`: minor Lola punishment if the cleanup deadline expires.
- `treasure.fallbackMode`: `0` off, `1` valuable loot, `2` any non-owned source
  container.
- `treasure.minGold`: gold threshold for Valuable Loot fallback.
- `treasure.minItemValue`: item-stack value threshold for Valuable Loot fallback.

## Load Order

Place this mod above `[NoDelete] cfl_LolaAddon_` in MO2 so its loose scripts win.

Expected profile order:

```text
+Lola Expanded Addons
-Lola Body Potion Routine
-Lola Fertility Mode Addon
-[NoDelete] Lola Milk Economy
-[NoDelete] Lola Transformative Elixirs
+[NoDelete] cfl_LolaAddon_
```

The old separate addon mods should remain disabled to avoid loose-script conflict
confusion.

## Requirements

Required for the base Lola hooks:

- Submissive Lola Resubmission
- Custom Framework Lola Addon
- PapyrusUtil
- SkyUI

Feature-specific requirements:

- Transformative Elixirs for Body Potion Routine.
- Fertility Mode for Fertility Drug Trick.
- Milk Mod Economy for Milk Economy Routine.
- Installed hair plugins for Hair Style Pool Seeder.

If a feature-specific mod is missing, the related event should quietly skip.

## Quick Testing

Use a throwaway save.

For drug trick testing, temporarily set:

```json
"fertility.triggerChance": 100,
"fertility.cooldownHours": 0.0,
"fertility.nextAllowedGameDay": 0.0
```

Then run in the console:

```text
startquest cfl_TrickDrug
```

For body and milk routine testing, temporarily set:

```json
"body.initialDelayHours": 0.1,
"body.eventChance": 100,
"body.cooldownHours": 1.0,
"body.moodDurationHours": 24.0,
"body.currentMood": -1,
"body.nextMoodGameDay": 0.0,
"milk.initialDelayHours": 0.1,
"milk.dailyChance": 100,
"milk.cooldownHours": 1.0,
"milk.assignmentMilkCount": 1,
"milk.allowOwnerMilking": 1,
"milk.ownerMilkingChance": 100,
"milk.ownerMilkingFullnessThreshold": 0.05,
"milk.ownerMilkingDistance": 1000.0,
"collar.initialDelayHours": 0.1,
"collar.eventChance": 100,
"collar.cooldownHours": 1.0,
"collar.ownerDistance": 1000.0
```

For owner milking specifically, the player must already be assigned in Milk Mod
Economy as a milk maid or milk slave and must have at least 1 current milk. Stand
near the Lola owner, wait for the monitor tick, and the owner should start MME's
standard mobile hand milking when the event fires.

For collar testing, set Lola's own collar MCM option to the collar or Random
selection you want, stand near the owner, and wait for the monitor tick. The
current collar must not be a quest or blocking device.

Load a save with Lola ownership active, wait or sleep about one in-game hour, and
watch for owner notifications.

For hair pool testing:

1. Open `MCM > Submissive Lola Extension > Addons`.
2. Click `Seed Lola hair styles`.
3. Go to Lola's normal hair settings and set the hair option to `New Style`.
4. Trigger Lola's normal hair-change event or wait for it naturally.
5. Confirm the hair changes temporarily and restores through Lola's normal flow.

For Forced Adventuring visibility testing, start the normal Lola Missives task
through gameplay or console, let it select the Missives, then open:

`MCM > Submissive Lola Extension > Addons`

The page should show `Missives status`, and clicking `Show active Missives`
should display the selected Missives. The same detail message should appear once
immediately after the task selects its Missives.

For treasure fallback testing, start Lola's find-treasure quest and loot a
non-owned dungeon chest that is not completing normally. With the default
`Valuable Loot` fallback, taking at least `treasure.minGold` gold or an item
stack worth at least `treasure.minItemValue` should advance the quest to the
return/reward stage.

For bathing order testing, temporarily set:

```json
"bath.initialDelayHours": 0.1,
"bath.eventChance": 100,
"bath.cooldownHours": 1.0,
"bath.ownerBathChance": 100,
"bath.assignmentTimeoutHours": 1.0,
"bath.requireTown": 0,
"bath.cumThreshold": 1,
"bath.dirtMinStage": 2
```

Then load a save with Lola ownership active and make sure the player has either
a supported bathing dirt effect or Sexlab Cum Overlays counters. Stand near the
owner and wait for the monitor tick. With Bathing in Skyrim available, the owner
should wash the player. Without it, the owner should assign the one-hour cleanup
task.

Restore normal values after testing.

## Development Notes

This mod uses loose-script overrides plus a small dialogue ESP:

- `cfl_Drugs.psc` handles the rare Lola drug trick Fertility Mode integration.
- `cfl_LolaMonitor.psc` handles ownership-time scheduled events.
- `LolaExpandedAddons.esp` adds the owner dialogue topics for milk turn-in, milk
  quota status, body elixir acceptance/status, and fertility acceptance/status.
- `cfl_MCM.psc` adds the Addons page to the existing Submissive Lola Extension
  MCM.
- `cfl_Missives.psc` exposes the currently selected Forced Adventuring Missives
  to the MCM and startup message box.
- `vkjPlayerAliasScript.psc` makes Lola's treasure quest completion more
  permissive for valuable non-owned chest loot.
- `tools/generate-hair-pool.mjs` regenerates `HairPool.json` from active
  hair-related plugins in the selected MO2 profile.

Existing saves should use the addon reinit/reload path after updating so the new
Papyrus properties and dialogue globals are initialized. `LolaExpandedAddons.esp`
must be enabled after `cfl_LolaAddon.esp`.
