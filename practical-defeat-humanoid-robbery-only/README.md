# Practical Defeat Humanoid Robbery Only

Editable source project for the MO2 patch mod:

`C:\games\nefaram\mods\NEFARAM - Practical Defeat Humanoid Robbery Only`

Purpose:
- Keep Practical Defeat robbery enabled for normal NPC aggressors.
- Skip robbery when the first aggressor is not a robbery-capable humanoid.
- Reject creature, animal, undead, skeleton, and draugr aggressors.

Compile command:

```powershell
& 'C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe' `
  'C:\Users\antho\nefaram-files\practical-defeat-humanoid-robbery-only\Source\Scripts\PD_DefeatHandler.psc' `
  -f='C:\games\nefaram\__temp__\skyrim-scripts-source\Source\Scripts\TESV_Papyrus_Flags.flg' `
  -i='C:\Users\antho\nefaram-files\practical-defeat-humanoid-robbery-only\build-stubs;C:\Users\antho\nefaram-files\practical-defeat-humanoid-robbery-only\Source\Scripts;C:\games\nefaram\mods\SKSE\Scripts\Source;C:\games\nefaram\__temp__\skyrim-scripts-source\Source\Scripts' `
  -o='C:\games\nefaram\mods\NEFARAM - Practical Defeat Humanoid Robbery Only\Scripts'
```

The `build-stubs` files are compile-only signatures. Do not package them into the MO2 runtime mod.
