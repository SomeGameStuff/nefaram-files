# Mod List Compare

Compares an external MO2 `modlist.txt` against the local NEFARAM MO2 install with fuzzy matching.

Default comparison:

```powershell
python tools\ModListCompare\compare_modlists.py
```

Explicit inputs:

```powershell
python tools\ModListCompare\compare_modlists.py `
  --source-modlist C:\Users\antho\Downloads\modlist.txt `
  --mo2-root C:\Games\nefaram `
  --out tools\ModListCompare\out
```

Outputs:

- `out/comparison.csv`: all source entries with present/fuzzy/missing status.
- `out/missing.md`: grouped human review list.
- `out/manifests/*.mods.txt`: draft manifests for `tools/ModGroupInstaller`.

Manifest notes:

- If a high-confidence archive match is found in `C:\Users\antho\Downloads` or `E:\Games\Tsukiro2\Downloads`, the manifest uses a `local path="..."` entry.
- Lower-confidence archive matches are written as `# review archive-candidate` comments so they can be checked before install.
- If no archive is found, the manifest leaves an `# unresolved:` comment because the source `modlist.txt` does not contain Nexus IDs or file IDs.
