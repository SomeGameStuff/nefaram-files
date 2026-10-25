param([string]$Mo2Root = $env:NEFARAM_MO2_ROOT)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Mo2Root)) { throw 'Set NEFARAM_MO2_ROOT or pass -Mo2Root.' }
$projectRoot = Split-Path $PSScriptRoot
$modName = '[NoDelete] Bodymorph Alterations'
$oldOverrideName = '[NoDelete] Bodymorph Alterations - Review Fixes'
$modsRoot = [IO.Path]::GetFullPath((Join-Path $Mo2Root 'mods'))
$runtime = Join-Path $modsRoot $modName
$oldOverride = Join-Path $modsRoot $oldOverrideName
$profile = Join-Path $Mo2Root 'profiles\NEFARAM'
$modlist = Join-Path $profile 'modlist.txt'
if (Get-Process SkyrimSE,ModOrganizer -ErrorAction SilentlyContinue) { throw 'Close Skyrim and MO2 before updating Bodymorph.' }
if ((Get-Content -Raw -LiteralPath (Join-Path $Mo2Root 'ModOrganizer.ini')) -notmatch 'selected_profile=@ByteArray\(NEFARAM\)') { throw 'NEFARAM is not the selected profile.' }
if ((Get-Content -LiteralPath (Join-Path $profile 'plugins.txt')) -notcontains '*Dollform.esp') { throw 'Dollform.esp is not enabled.' }
$before = [IO.File]::ReadAllLines($modlist)
if ($before -notcontains "+$modName") { throw 'The existing Bodymorph mod is not enabled.' }
if (!(Test-Path -LiteralPath (Join-Path $runtime 'Dollform.esp'))) { throw 'The existing mod installation was not found.' }
$originalHash = (Get-FileHash -LiteralPath $modlist).Hash
$files = [Collections.Generic.List[string]]::new()
foreach ($compiled in Get-ChildItem -LiteralPath (Join-Path $projectRoot 'Scripts') -Filter '*.pex') {
    $files.Add("Scripts\$($compiled.Name)")
    # Keep already-installed source copies consistent without adding a source tree.
    $source = 'Source\Scripts\' + [IO.Path]::ChangeExtension($compiled.Name, '.psc')
    if (Test-Path -LiteralPath (Join-Path $runtime $source)) { $files.Add($source) }
}
$files.Add('README.md')
$files.Add('REVIEW-2026-10-24.md')
foreach ($relative in $files) {
    if (!(Test-Path -LiteralPath (Join-Path $projectRoot $relative))) { throw "Missing project file: $relative" }
}
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = [IO.Path]::GetFullPath((Join-Path (Split-Path $projectRoot) "artifacts\bodymorph-install-backups\$stamp"))
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
Copy-Item -LiteralPath $modlist -Destination (Join-Path $profile "modlist.before-bodymorph-consolidation.$stamp.txt")
foreach ($relative in $files) {
    $target = Join-Path $runtime $relative
    if (Test-Path -LiteralPath $target) {
        $backup = Join-Path $backupRoot "OriginalMod\$relative"
        New-Item -ItemType Directory -Path (Split-Path $backup) -Force | Out-Null
        Copy-Item -LiteralPath $target -Destination $backup
    }
    $source = Join-Path $projectRoot $relative
    Copy-Item -LiteralPath $source -Destination $target -Force
    if ((Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $target).Hash) { throw "Copy verification failed: $relative" }
}
if ((Get-FileHash -LiteralPath $modlist).Hash -ne $originalHash) { throw 'The modlist changed during deployment; the override has not been removed.' }
$after = @($before | Where-Object { $_ -ne "+$oldOverrideName" -and $_ -ne "-$oldOverrideName" })
[IO.File]::WriteAllLines($modlist, $after, [Text.UTF8Encoding]::new($false))
if (Test-Path -LiteralPath $oldOverride) {
    # Verify both absolute paths before moving the obsolete override recursively.
    $resolvedOverride = (Resolve-Path -LiteralPath $oldOverride).Path
    $archive = [IO.Path]::GetFullPath((Join-Path $backupRoot 'RemovedOverride'))
    if ($resolvedOverride -ne [IO.Path]::GetFullPath((Join-Path $modsRoot $oldOverrideName)) -or
        !$archive.StartsWith($backupRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Override archive paths failed validation.'
    }
    Move-Item -LiteralPath $resolvedOverride -Destination $archive
}
Write-Output "Updated the existing $modName installation and removed the extra override. Backups: $backupRoot"
