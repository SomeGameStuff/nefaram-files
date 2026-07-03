# Mod List Compare

Compares an external MO2 `modlist.txt` or MO2 CSV export against the local NEFARAM MO2 install with fuzzy matching.

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
- CSV exports with Nexus URLs and download filenames add those values to the review comments, but unresolved Nexus rows are not converted to installable Nexus lines unless a local archive is found because the export does not include Nexus file IDs.

Recommended flow for MO2 CSV exports:

1. Run `compare_modlists.py` to produce `comparison.csv`.
2. Run `tools\NexusFileResolver` for a specific bucket to resolve Nexus `file_id` values.
3. Use the `.resolved.mods.txt` manifest with `tools\ModGroupInstaller`.
4. Dry-run before installing. Review cached archive choices and unresolved comments.

Example from the Ultimate Overhaul comparison:

```powershell
python tools\ModListCompare\compare_modlists.py `
  --source-modlist "C:\Users\antho\Downloads\Nefaram Ultimate Overhaul.txt" `
  --mo2-root C:\Games\nefaram `
  --out tools\ModListCompare\out_ultimate_overhaul

tools\NexusFileResolver\bin\Release\net9.0\NexusFileResolver.exe `
  --comparison tools\ModListCompare\out_ultimate_overhaul\comparison.csv `
  --bucket armor-clothing `
  --out tools\ModListCompare\out_ultimate_overhaul\manifests\armor-clothing.resolved.mods.txt `
  --wabbajack C:\Games\wabbajack\wabbajack-cli.bat
```
