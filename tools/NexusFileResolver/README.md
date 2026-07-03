# Nexus File Resolver

Resolves Nexus `file_id` values for `tools/ModListCompare` CSV rows.

It reads `comparison.csv`, filters a bucket, calls the official Nexus files endpoint, and writes a manifest with:

- `nexus skyrimspecialedition <mod_id> file_id=<file_id>` entries when the API file list can be matched;
- `download_file="..."` on resolved entries when the source export had an expected archive name;
- `local path="..."` only when no usable Nexus mod ID is available but a local archive is already available;
- review comments for unresolved rows.

Authentication:

- Prefer `NEXUS_API_KEY` or `NEXUSMODS_API_KEY`.
- If no API key is set, the tool tries Wabbajack's saved Nexus OAuth token.
- If Nexus returns `401` or token refresh fails, log into Nexus again through Wabbajack and rerun the resolver.

Why `download_file` matters:

Nexus mod pages can have many files with the same `mod_id`. The installer uses `download_file` for exact cached archive matching before falling back to download-link handling, which avoids accidentally installing a different option from the same mod page.

Example:

```powershell
dotnet build tools\NexusFileResolver\NexusFileResolver.csproj -c Release

tools\NexusFileResolver\bin\Release\net9.0\NexusFileResolver.exe `
  --comparison tools\ModListCompare\out_ultimate_overhaul\comparison.csv `
  --bucket armor-clothing `
  --out tools\ModListCompare\out_ultimate_overhaul\manifests\armor-clothing.resolved.mods.txt `
  --wabbajack C:\Games\wabbajack\wabbajack-cli.bat
```
