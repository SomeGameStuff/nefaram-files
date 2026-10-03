[CmdletBinding()]
param(
    [string]$Mo2Root = $env:NEFARAM_MO2_ROOT,
    [string]$Compiler = $env:NEFARAM_PAPYRUS_COMPILER,
    [string]$VanillaSource = $env:NEFARAM_VANILLA_SOURCE
)

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$runtimeName = '[NoDelete] Maria Eden Quest Startup Fix'
$runtimePath = Join-Path (Join-Path $Mo2Root 'mods') $runtimeName
$projectRuntime = Join-Path $projectRoot 'Runtime'
$sourcePlugin = Join-Path $Mo2Root 'mods\[NoDelete] Maria Eden Complete English Translation\MariaProstitution.esp'
$pluginName = 'NEFARAM_MariaEdenQuestStartupFix.esp'
$compiler = $Compiler
$vanilla = $VanillaSource
if ([string]::IsNullOrWhiteSpace($Mo2Root) -or [string]::IsNullOrWhiteSpace($compiler) -or [string]::IsNullOrWhiteSpace($vanilla)) {
    throw 'Set NEFARAM_MO2_ROOT, NEFARAM_PAPYRUS_COMPILER, and NEFARAM_VANILLA_SOURCE before building.'
}
$sourceScripts = Join-Path $projectRoot 'Source\Scripts'
$buildStubs = Join-Path $projectRoot 'build-stubs'
$projectScripts = Join-Path $projectRuntime 'Scripts'
$runtimeScripts = Join-Path $runtimePath 'Scripts'

foreach ($required in @($sourcePlugin, $compiler, (Join-Path $vanilla 'TESV_Papyrus_Flags.flg'), $buildStubs)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required path not found: $required"
    }
}

New-Item -ItemType Directory -Force -Path $projectRuntime, $projectScripts, $runtimePath, $runtimeScripts | Out-Null

dotnet run --project (Join-Path $projectRoot 'Generator\Generator.csproj') --configuration Release -- $sourcePlugin (Join-Path $projectRuntime $pluginName)
if ($LASTEXITCODE -ne 0) { throw 'Mutagen generator failed.' }

$include = "$sourceScripts;$buildStubs;$vanilla"
$flags = Join-Path $vanilla 'TESV_Papyrus_Flags.flg'
foreach ($script in @('MEPPimpSlavesPlayerAlias.psc', 'MEPDLC1RagralAlias.psc', 'MEPFarmerSlaverySlaveAlias.psc')) {
    & $compiler (Join-Path $sourceScripts $script) "-f=$flags" "-i=$include" "-o=$projectScripts"
    if ($LASTEXITCODE -ne 0) { throw "Papyrus compilation failed: $script" }
}

Copy-Item -LiteralPath (Join-Path $projectRuntime $pluginName) -Destination (Join-Path $runtimePath $pluginName) -Force
Get-ChildItem -LiteralPath $projectScripts -File -Filter '*.pex' | Copy-Item -Destination $runtimeScripts -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination (Join-Path $runtimePath 'README.md') -Force

$runtimeFiles = Get-ChildItem -LiteralPath $runtimePath -Recurse -File
$unexpected = $runtimeFiles | Where-Object {
    $_.FullName -notlike "*$pluginName" -and
    $_.Extension -ne '.pex' -and
    $_.Name -ne 'README.md' -and
    $_.Name -ne 'meta.ini'
}
if ($unexpected) {
    throw "Unexpected runtime files: $($unexpected.FullName -join ', ')"
}

Write-Host "Built and deployed $runtimeName"
