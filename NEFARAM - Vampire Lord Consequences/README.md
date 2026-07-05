# NEFARAM - Vampire Lord Consequences

Standalone MO2 add-on patch for the NEFARAM profile. It makes Vampire Lord a high-output form with aftermath: short deliberate use is manageable, while public, prolonged, or bloody use creates social pressure and post-transformation weakness.

## What It Does

- Detects when the player enters and leaves Vampire Lord form.
- Tracks how long the transformation lasted.
- Applies post-reversion crash penalties through actor values.
- Raises hidden Dawnguard Heat for public, daylight, and reckless transformations.
- Tracks humanoid kills during Vampire Lord form with SKSE actor action events.
- Lowers Humanity for transforming, staying transformed too long, and humanoid kills.
- Mirrors Humanity loss into Corruption.
- Slowly decays Heat after quiet days.
- Applies passive penalties below 50 and 25 Humanity.
- Attempts basic Dawnguard hunter ambushes at Heat 50+.

The mod intentionally leaves Vampire Lord damage unchanged.

## Runtime Mod

Installed MO2 mod folder:

`C:\Games\nefaram\mods\NEFARAM - Vampire Lord Consequences`

Runtime contents:

- `NEFARAM - Vampire Lord Consequences.esp`
- `Scripts\NVLC_Controller.pex`
- `SKSE\Plugins\NVLC\Config.json`
- `README.md`

The ESP is ESL-flagged and contains:

- Start-game controller quest: `NVLC_ControllerQuest`
- Globals:
  - `NVLC_Heat`
  - `NVLC_Humanity`
  - `NVLC_Corruption`
  - `NVLC_LastTransformTime`
  - `NVLC_CrashSeverity`

## Install

1. Copy or keep the runtime folder at:

   `C:\Games\nefaram\mods\NEFARAM - Vampire Lord Consequences`

2. In MO2, enable:

   `NEFARAM - Vampire Lord Consequences`

3. In the active profile plugin list, enable:

   `NEFARAM - Vampire Lord Consequences.esp`

For the current local NEFARAM profile, this has already been done in:

- `C:\Games\nefaram\profiles\NEFARAM\modlist.txt`
- `C:\Games\nefaram\profiles\NEFARAM\plugins.txt`

Backups created during installation:

- `modlist.before-nvlc-20260705-160507.txt`
- `plugins.before-nvlc-20260705-160507.txt`

## Uninstall / Rollback

Disable the MO2 mod:

`NEFARAM - Vampire Lord Consequences`

Then disable or remove the plugin entry:

`NEFARAM - Vampire Lord Consequences.esp`

If rolling back immediately from the original install, restore the backup profile files listed above.

Because this mod uses an always-running quest, prefer testing on a new save or a throwaway save first. If removing from an ongoing save, clean removal is not guaranteed by Skyrim's scripting system.

## Build

Compile Papyrus:

```powershell
& 'C:\Users\antho\nefaram-files\NEFARAM - Vampire Lord Consequences\Build-CompilePapyrus.ps1'
```

Generate the ESP:

```powershell
dotnet run --project 'C:\Users\antho\nefaram-files\NEFARAM - Vampire Lord Consequences\MutagenGenerator\MutagenGenerator.csproj'
```

The generator writes directly to:

`C:\Games\nefaram\mods\NEFARAM - Vampire Lord Consequences\NEFARAM - Vampire Lord Consequences.esp`

## Source Layout

- `Source\Scripts\NVLC_Controller.psc`: controller quest script.
- `Build-CompilePapyrus.ps1`: compiler wrapper.
- `MutagenGenerator\Program.cs`: non-interactive ESP generator.
- `xEdit\Generate-NVLC.pas`: earlier xEdit generator attempt kept as reference; Mutagen is the working build path.

## Current Limits

- Feeding detection is not implemented yet.
- Crash is implemented with actor value penalties rather than custom magic effects.
- Dawnguard response is a simple hunter ambush, not a full dossier/raid system.
- Adult-framework hooks are not hard dependencies; later bridge mods can read the exposed globals.
