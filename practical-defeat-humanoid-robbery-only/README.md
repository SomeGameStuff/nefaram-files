# Practical Defeat Humanoid Robbery Only

Editable source project for the MO2 patch mod:

`<mo2-root>\mods\NEFARAM - Practical Defeat Humanoid Robbery Only`

Purpose:
- Keep Practical Defeat robbery enabled for normal NPC aggressors.
- Skip robbery when the first aggressor is not a robbery-capable humanoid.
- Reject creature, animal, undead, skeleton, and draugr aggressors.

Compile command:

```powershell
& '<game-install>\Papyrus Compiler\PapyrusCompiler.exe' `
  '<user-home>\nefaram-files\practical-defeat-humanoid-robbery-only\Source\Scripts\PD_DefeatHandler.psc' `
  -f='<mo2-root>\__temp__\skyrim-scripts-source\Source\Scripts\TESV_Papyrus_Flags.flg' `
  -i='<user-home>\nefaram-files\practical-defeat-humanoid-robbery-only\build-stubs;<user-home>\nefaram-files\practical-defeat-humanoid-robbery-only\Source\Scripts;<mo2-root>\mods\SKSE\Scripts\Source;<mo2-root>\__temp__\skyrim-scripts-source\Source\Scripts' `
  -o='<mo2-root>\mods\NEFARAM - Practical Defeat Humanoid Robbery Only\Scripts'
```

The `build-stubs` files are compile-only signatures. Do not package them into the MO2 runtime mod.
