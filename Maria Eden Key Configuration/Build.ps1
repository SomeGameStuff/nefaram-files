[CmdletBinding()]
param(
    [switch]$Package
)

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$compiler = 'C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe'
$vanilla = 'C:\Users\antho\nefaram-files\tools\vanilla-source\Source\Scripts'
$source = Join-Path $projectRoot 'Source\Scripts'
$stubs = Join-Path $projectRoot 'build-stubs'
$scripts = Join-Path $projectRoot 'Scripts'
$plugin = Join-Path $projectRoot 'MariaEdenKeyConfig.esp'
$generator = Join-Path $projectRoot 'Generator\Generator.csproj'

foreach ($required in @($compiler, (Join-Path $vanilla 'TESV_Papyrus_Flags.flg'), $generator)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required build input not found: $required"
    }
}

New-Item -ItemType Directory -Force -Path $scripts | Out-Null

& $compiler 'MEPK_MCM.psc' `
    "-f=$(Join-Path $vanilla 'TESV_Papyrus_Flags.flg')" `
    "-i=$source;$stubs;$vanilla" `
    "-o=$scripts"
if ($LASTEXITCODE -ne 0) {
    throw "Papyrus compilation failed with exit code $LASTEXITCODE"
}

dotnet run --project $generator -- $plugin
if ($LASTEXITCODE -ne 0) {
    throw "Plugin generation failed with exit code $LASTEXITCODE"
}

dotnet run --project $generator -- --validate $plugin
if ($LASTEXITCODE -ne 0) {
    throw "Plugin validation failed with exit code $LASTEXITCODE"
}

$poseRoot = Join-Path $projectRoot 'SKSE\Plugins\StorageUtilData\MariaPoses'
$poseFiles = Get-ChildItem -LiteralPath $poseRoot -File -Filter '*.json'
if ($poseFiles.Count -ne 13) {
    throw "Expected 13 pose overrides, found $($poseFiles.Count)."
}
foreach ($file in $poseFiles) {
    $json = Get-Content -Raw -LiteralPath $file.FullName | ConvertFrom-Json
    if ($json.int.hotkey -ne 0) {
        throw "Default direct hotkey is not unbound in $($file.Name)."
    }
}

$hotkeyFile = Join-Path $projectRoot 'SKSE\Plugins\StorageUtilData\MariaHotkeys.json'
$hotkeys = Get-Content -Raw -LiteralPath $hotkeyFile | ConvertFrom-Json
if ($hotkeys.int.keyboard_actionmenu -ne 156) {
    throw 'Default action-menu hotkey is not Numpad Enter in MariaHotkeys.json.'
}
if ($hotkeys.int.keyboard_posemenu -ne 83) {
    throw 'Default pose-menu hotkey is not Numpad Decimal in MariaHotkeys.json.'
}

if (-not (Test-Path -LiteralPath (Join-Path $scripts 'MEPK_MCM.pex'))) {
    throw 'Compiled MEPK_MCM.pex was not produced.'
}

Write-Host 'Build and validation succeeded.'

if ($Package) {
    $artifacts = 'C:\Users\antho\nefaram-files\artifacts'
    $stageRoot = Join-Path $projectRoot 'build-output\Maria Eden Key Configuration'
    $resolvedProject = [IO.Path]::GetFullPath($projectRoot)
    $resolvedStage = [IO.Path]::GetFullPath($stageRoot)
    if (-not $resolvedStage.StartsWith($resolvedProject, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to stage outside project: $resolvedStage"
    }
    if (Test-Path -LiteralPath $resolvedStage) {
        Remove-Item -LiteralPath $resolvedStage -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $resolvedStage 'Scripts') | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $resolvedStage 'Source\Scripts') | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $resolvedStage 'SKSE\Plugins\StorageUtilData') | Out-Null
    Copy-Item -LiteralPath $plugin -Destination $resolvedStage
    Copy-Item -LiteralPath (Join-Path $scripts 'MEPK_MCM.pex') -Destination (Join-Path $resolvedStage 'Scripts')
    Copy-Item -LiteralPath (Join-Path $source 'MEPK_MCM.psc') -Destination (Join-Path $resolvedStage 'Source\Scripts')
    Copy-Item -LiteralPath (Join-Path $projectRoot 'SKSE\Plugins\StorageUtilData\MariaPoses') -Destination (Join-Path $resolvedStage 'SKSE\Plugins\StorageUtilData') -Recurse
    Copy-Item -LiteralPath (Join-Path $projectRoot 'SKSE\Plugins\StorageUtilData\MariaHotkeys.json') -Destination (Join-Path $resolvedStage 'SKSE\Plugins\StorageUtilData')
    Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination $resolvedStage
    Copy-Item -LiteralPath (Join-Path $projectRoot 'AUTHOR-HANDOFF.md') -Destination $resolvedStage
    New-Item -ItemType Directory -Force -Path $artifacts | Out-Null
    $zip = Join-Path $artifacts 'Maria-Eden-Key-Configuration-v0.3.1.zip'
    if (Test-Path -LiteralPath $zip) {
        Remove-Item -LiteralPath $zip -Force
    }
    Compress-Archive -LiteralPath $resolvedStage -DestinationPath $zip -CompressionLevel Optimal
    Write-Host "Packaged $zip"
}
