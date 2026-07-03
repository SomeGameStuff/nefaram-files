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

## CLI

Dry-run the included Nexus example:

```powershell
.\tools\ModGroupInstaller\bin\Release\net9.0-windows\ModGroupInstaller.exe `
  --mo2 C:\Games\nefaram `
  --manifest .\tools\ModGroupInstaller\examples\nexus-two-file-test.mods.txt `
  --dry-run
```

Run the install:

```powershell
.\tools\ModGroupInstaller\bin\Release\net9.0-windows\ModGroupInstaller.exe `
  --mo2 C:\Games\nefaram `
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

Nexus entries need `game`, `mod_id`, and `file_id`.

The installer checks for already-downloaded Nexus archives before opening a browser. It searches:

- Wabbajack saved `DownloadLocation` for the selected install.
- MO2 `download_directory`.
- The Windows user `Downloads` folder.

If a Nexus API key or Wabbajack OAuth token can download directly, the tool uses it. For non-premium accounts, Nexus may require browser/manual download; in that case the tool opens the Nexus page and waits for a newly completed archive in one of the download search folders.

LoversLab entries default to manual acquisition.
