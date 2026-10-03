[CmdletBinding()]
param(
    [string]$Mo2Root = $env:NEFARAM_MO2_ROOT,
    [string]$Compiler = $env:NEFARAM_PAPYRUS_COMPILER,
    [string]$VanillaSource = $env:NEFARAM_VANILLA_SOURCE
)

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$runtimeName = '[NoDelete] Maria Eden Hygiene Diagnostics'
$runtimePath = Join-Path (Join-Path $Mo2Root 'mods') $runtimeName
$sourcePath = Join-Path $projectRoot 'Source\Scripts\MEP_PimpHygieneQuest.psc'
$buildStubs = Join-Path $projectRoot 'build-stubs'
$projectScripts = Join-Path $projectRoot 'Runtime\Scripts'
$runtimeScripts = Join-Path $runtimePath 'Scripts'
$compiler = $Compiler
$vanilla = $VanillaSource
$skseSource = Join-Path $Mo2Root 'mods\SKSE\Scripts\Source'
if ([string]::IsNullOrWhiteSpace($Mo2Root) -or [string]::IsNullOrWhiteSpace($compiler) -or [string]::IsNullOrWhiteSpace($vanilla)) {
    throw 'Set NEFARAM_MO2_ROOT, NEFARAM_PAPYRUS_COMPILER, and NEFARAM_VANILLA_SOURCE before building.'
}

foreach ($required in @($sourcePath, $buildStubs, $compiler, $skseSource, (Join-Path $vanilla 'TESV_Papyrus_Flags.flg'))) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required path not found: $required" }
}

New-Item -ItemType Directory -Force -Path $projectScripts,$runtimeScripts | Out-Null
$include = "$(Split-Path $sourcePath);$buildStubs;$skseSource;$vanilla"
$flags = Join-Path $vanilla 'TESV_Papyrus_Flags.flg'
& $compiler $sourcePath "-f=$flags" "-i=$include" "-o=$projectScripts"
if ($LASTEXITCODE -ne 0) { throw 'Papyrus compilation failed.' }

$compiled = Join-Path $projectScripts 'MEP_PimpHygieneQuest.pex'
if (-not (Test-Path -LiteralPath $compiled)) { throw "Compiled script missing: $compiled" }
Copy-Item -LiteralPath $compiled -Destination (Join-Path $runtimeScripts 'MEP_PimpHygieneQuest.pex') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination (Join-Path $runtimePath 'README.md') -Force

$unexpected = Get-ChildItem -LiteralPath $runtimePath -Recurse -File | Where-Object {
    $_.Name -notin @('MEP_PimpHygieneQuest.pex','README.md','meta.ini')
}
if ($unexpected) { throw "Unexpected runtime files: $($unexpected.FullName -join ', ')" }
Write-Host "Built and deployed $runtimeName"
