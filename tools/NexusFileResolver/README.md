# Nexus File Resolver

Resolves Nexus `file_id` values for `tools/ModListCompare` CSV rows.

It reads `comparison.csv`, filters a bucket, calls the official Nexus files endpoint, and writes a manifest with:

- existing `local path="..."` entries when an archive is already available;
- `nexus skyrimspecialedition <mod_id> file_id=<file_id>` entries when the API file list can be matched;
- review comments for unresolved rows.

Authentication:

- Prefer `NEXUS_API_KEY` or `NEXUSMODS_API_KEY`.
- If no API key is set, the tool tries Wabbajack's saved Nexus OAuth token.

Example:

```powershell
dotnet build tools\NexusFileResolver\NexusFileResolver.csproj -c Release

tools\NexusFileResolver\bin\Release\net9.0\NexusFileResolver.exe `
  --comparison tools\ModListCompare\out_ultimate_overhaul\comparison.csv `
  --bucket armor-clothing `
  --out tools\ModListCompare\out_ultimate_overhaul\manifests\armor-clothing.resolved.mods.txt `
  --wabbajack C:\Games\wabbajack\wabbajack-cli.bat
```
