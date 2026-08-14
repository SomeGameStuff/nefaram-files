[CmdletBinding()]
param(
    [string]$Mo2Root = 'C:\Games\nefaram',
    [string]$RepoRoot = 'C:\Users\antho\nefaram-files'
)

$ErrorActionPreference = 'Stop'

$projectRoot = Join-Path $RepoRoot 'Maria Eden - Legacy Simple Slavery Record Shim'
$outputDir = Join-Path $projectRoot 'mod'
$runtimeName = '[NoDelete] Maria Eden - Legacy Simple Slavery Record Shim'
$runtimeDir = Join-Path (Join-Path $Mo2Root 'mods') $runtimeName
$profileDir = Join-Path (Join-Path $Mo2Root 'profiles') 'NEFARAM'
$modlistPath = Join-Path $profileDir 'modlist.txt'
$pluginsPath = Join-Path $profileDir 'plugins.txt'

if (-not (Test-Path -LiteralPath (Join-Path $Mo2Root 'portable.txt'))) {
    throw "Not a portable MO2 instance: $Mo2Root"
}

$simpleSlavery = Join-Path $Mo2Root 'mods\Simple Slavery Plus Plus\SimpleSlavery.esp'
$rebuild = Join-Path $Mo2Root 'mods\Simple Slavery Rebuild\SimpleSlaveryRebuild.esp'
$dependents = @(
    (Join-Path $Mo2Root 'mods\NEFARAM Patches\_NEFARAM_____PEGI16_____.esp'),
    (Join-Path $Mo2Root 'mods\NEFARAM Patches\_NEFARAM_____PEGI18_____.esp'),
    (Join-Path $Mo2Root 'mods\Synthesis Output\Synthesis_2.esp'),
    (Join-Path $Mo2Root 'mods\Synthesis Output\Synthesis_3.esp')
)

$required = @($simpleSlavery, $rebuild, $modlistPath, $pluginsPath) + $dependents
foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required file not found: $path"
    }
}

dotnet run --project (Join-Path $projectRoot 'build\RecordShimBuilder.csproj') -- `
    $simpleSlavery $rebuild $outputDir @dependents
if ($LASTEXITCODE -ne 0) {
    throw "Record shim build or validation failed with exit code $LASTEXITCODE"
}

New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $outputDir 'SimpleSlavery.esp') -Destination $runtimeDir -Force
Copy-Item -LiteralPath (Join-Path $outputDir 'SimpleSlaveryRebuild.esp') -Destination $runtimeDir -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination $runtimeDir -Force

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item -LiteralPath $modlistPath -Destination "$modlistPath.$stamp.bak"
Copy-Item -LiteralPath $pluginsPath -Destination "$pluginsPath.$stamp.bak"

$entriesToDisable = @(
    'Simple Slavery Plus Plus',
    'Simple Slavery Rebuild',
    'Simple Slavery Plus Plus Voice'
)
$lines = [System.Collections.Generic.List[string]]::new()
foreach ($line in [IO.File]::ReadAllLines($modlistPath)) {
    $name = if ($line.Length -gt 0 -and ($line[0] -eq '+' -or $line[0] -eq '-')) { $line.Substring(1) } else { $line }
    if ($name -eq $runtimeName) {
        continue
    }
    if ($entriesToDisable -contains $name) {
        $lines.Add("-$name")
    } else {
        $lines.Add($line)
    }
}
$lines.Insert(0, "+$runtimeName")
[IO.File]::WriteAllLines($modlistPath, $lines, [Text.UTF8Encoding]::new($false))

$enabledPlugins = [IO.File]::ReadAllLines($pluginsPath)
foreach ($plugin in @('SimpleSlavery.esp', 'SimpleSlaveryRebuild.esp')) {
    if ($enabledPlugins -notcontains "*$plugin") {
        throw "$plugin is not enabled in plugins.txt; restore the backups and enable it in MO2."
    }
}

Write-Host "Built and deployed $runtimeName"
Write-Host "Profile backups: $modlistPath.$stamp.bak and $pluginsPath.$stamp.bak"
