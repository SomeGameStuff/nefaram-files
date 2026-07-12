# MO2 Mod Group Installer

Small Windows tool for installing a shared group of mods into a portable MO2 instance.

## Build

```powershell
dotnet build .\tools\ModGroupInstaller\ModGroupInstaller.csproj -c Release
```

The executable is written to:

```text
tools\ModGroupInstaller\bin\Release\net9.0-windows\ModGroupInstaller.exe
```

Self-contained release package:

```powershell
dotnet publish .\tools\ModGroupInstaller\ModGroupInstaller.csproj `
  -c Release `
  -r win-x64 `
  --self-contained true `
  -p:PublishSingleFile=true `
  -p:IncludeNativeLibrariesForSelfExtract=true `
  -o artifacts\ModGroupInstaller-v0.3.0-win-x64
```

## CLI

Dry-run the included Nexus example:

```powershell
.\tools\ModGroupInstaller\bin\Release\net9.0-windows\ModGroupInstaller.exe `
  --mo2 "D:\Modding\MO2" `
  --manifest .\tools\ModGroupInstaller\examples\nexus-two-file-test.mods.txt `
  --dry-run
```

Run the install:

```powershell
.\tools\ModGroupInstaller\bin\Release\net9.0-windows\ModGroupInstaller.exe `
  --mo2 "D:\Modding\MO2" `
  --manifest .\tools\ModGroupInstaller\examples\nexus-two-file-test.mods.txt
```

## Manifest

```text
+ local path="C:\mods\Example.zip" install="Example Mod"
+ manual url="https://example.com/Example.zip" install="Manual Mod" sha256="..."
+ discord url="https://cdn.discordapp.com/..." install="Discord-hosted Mod" sha256="..."
+ nexus skyrimspecialedition 16495 file_id=123456 install="JContainers SE"
+ nexus skyrimspecialedition 16495 file="Exact Archive Name.7z" install="JContainers SE"
+ loverslab url="https://www.loverslab.com/files/file/11116-example" file="Example.zip" install="Example LL Mod"
separator "Animation Mods"
```

## Nexus Handling

Nexus entries need `game` and `mod_id`. Use `file_id=...` when known. If the manifest only has `file="Exact Archive Name.ext"` or `download_file="Exact Archive Name.ext"`, the installer uses Nexus file metadata to resolve the matching `file_id`.

Prefer including `download_file="Exact Archive Name.ext"` when the entry came from a Nexus/MO2 export. That lets the installer find the exact cached archive instead of another file from the same Nexus mod page.

The installer checks for already-downloaded Nexus archives before opening a browser. It searches:

- Wabbajack saved `DownloadLocation` for the selected install.
- MO2 `download_directory`.
- The Windows user `Downloads` folder.

If a Nexus API key or Wabbajack OAuth token can download directly, the tool uses it. For non-premium accounts, Nexus may require browser/manual download; in that case the tool opens the exact Nexus file page, prints the archive name to download, and waits for a newly completed archive in one of the download search folders.

For Nexus installs, the installer writes MO2 `meta.ini` with `modid`, `fileid`, `installationFile`, and repository metadata. This is what enables MO2 actions such as "Open on Nexus". If a Nexus mod folder already exists, rerunning a manifest will skip extraction but refresh the metadata.

LoversLab entries default to manual acquisition.

## BodySlide

For installed or already-present manifest mods that contain `CalienteTools\BodySlide\SliderSets`, the installer creates a generated MO2 mod named `ModGroupInstaller Generated BodySlide Groups`.

The generated group name is based on the manifest filename, for example `ModGroupInstaller - SkinnyPeTe easy adds`. After installation, run BodySlide from MO2, select that group, check Build Morphs, and Batch Build to your normal BodySlide output mod.

BodySlide-only mods that contain presets or projects but no normal game data get a harmless marker file under `meshes` so MO2 does not flag them as "no valid game data".

## FOMOD and Data Layout

The installer extracts archives and normalizes simple single-folder wrappers when the wrapper contains game data and the move has no path collisions. It does not evaluate FOMOD option logic.

When an installed archive has no valid game data at the root, the tool prints the top-level entries it found. Option-based FOMOD/BAIN archives should be installed through MO2 or represented in the manifest with explicit archive choices rather than hardcoded tool-specific repairs.
