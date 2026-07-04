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
  -o artifacts\ModGroupInstaller-v0.2.0-win-x64
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
+ loverslab url="https://www.loverslab.com/files/file/11116-example" file="Example.zip" install="Example LL Mod"
separator "Animation Mods"
```

## Nexus Handling

Nexus entries need `game`, `mod_id`, and `file_id`. Prefer including `download_file="Exact Archive Name.ext"` when the entry came from a Nexus/MO2 export. That lets the installer find the exact cached archive instead of another file from the same Nexus mod page.

The installer checks for already-downloaded Nexus archives before opening a browser. It searches:

- Wabbajack saved `DownloadLocation` for the selected install.
- MO2 `download_directory`.
- The Windows user `Downloads` folder.

If a Nexus API key or Wabbajack OAuth token can download directly, the tool uses it. For non-premium accounts, Nexus may require browser/manual download; in that case the tool opens the Nexus page and waits for a newly completed archive in one of the download search folders.

For Nexus installs, the installer writes MO2 `meta.ini` with `modid`, `fileid`, `installationFile`, and repository metadata. This is what enables MO2 actions such as "Open on Nexus". If a Nexus mod folder already exists, rerunning a manifest will skip extraction but refresh the metadata.

LoversLab entries default to manual acquisition.

## FOMOD and Data Layout

The installer extracts archives and normalizes simple single-folder wrappers. It does not fully evaluate FOMOD option logic yet.

Watch for archives that extract to folders such as `fomod`, `00 Data`, `Data`, `1_MAIN`, `BaseFiles`, `Body`, or `HeelSounds`. Those may require a real FOMOD selection or a conservative default folder copy before MO2 considers them valid game data.

Known safe manual repairs used during testing:

- `[COCO] Lace Lingerie Pack`: copy `1_MAIN` to the mod root and choose either `Heels Sound` or `No Heels Sound` ESP.
- `Iron Rose Armor`: copy `BaseFiles` to the mod root; optional UBE/HeelSounds folders depend on installed requirements.
- `Thieves Guild Armors Retexture SE`: copy `00 Data\Base Install - Thieves` to the mod root.
- `Dark Brotherhood Armors Retexture SE`: copy base textures plus one color variant to the mod root.
- `Bruma Outfits for Skyrim Imperials (SPID Version)`: copy `Data` to the mod root. This is an `.ini`-only distribution file, so simple game-data checks may still look unusual.
