[CmdletBinding()]
param(
    [string]$Mo2Root = $env:NEFARAM_MO2_ROOT,
    [string]$Compiler = $env:NEFARAM_PAPYRUS_COMPILER,
    [string]$VanillaSource = $env:NEFARAM_VANILLA_SOURCE
)

$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$source = Join-Path $projectRoot 'Source\Scripts\MariaLocationManager.psc'
$stubs = Join-Path $projectRoot 'build-stubs'
$projectScripts = Join-Path $projectRoot 'Scripts'
$runtime = Join-Path $Mo2Root 'mods\[NoDelete] Maria Eden Location Menu Freeze Fix'
$runtimeScripts = Join-Path $runtime 'Scripts'

$compiler = $Compiler
$vanilla = $VanillaSource
$skse = Join-Path $Mo2Root 'mods\SKSE\Scripts\Source'
$papyrusUtil = Join-Path $Mo2Root 'mods\PapyrusUtil SE - Modders Scripting Utility Functions\Source\Scripts'
if ([string]::IsNullOrWhiteSpace($Mo2Root) -or [string]::IsNullOrWhiteSpace($compiler) -or [string]::IsNullOrWhiteSpace($vanilla)) {
    throw 'Set NEFARAM_MO2_ROOT, NEFARAM_PAPYRUS_COMPILER, and NEFARAM_VANILLA_SOURCE before building.'
}

foreach ($required in @($source, $stubs, $compiler, $vanilla, $skse, $papyrusUtil)) {
    if (!(Test-Path -LiteralPath $required)) {
        throw "Required path not found: $required"
    }
}

New-Item -ItemType Directory -Force -Path $projectScripts | Out-Null
New-Item -ItemType Directory -Force -Path $runtimeScripts | Out-Null

$include = "$(Split-Path -Parent $source);$stubs;$skse;$papyrusUtil;$vanilla"
$flags = Join-Path $vanilla 'TESV_Papyrus_Flags.flg'

& $compiler $source "-f=$flags" "-i=$include" "-o=$projectScripts"
if ($LASTEXITCODE -ne 0) {
    throw 'Papyrus compilation failed.'
}

$pex = Join-Path $projectScripts 'MariaLocationManager.pex'
if (!(Test-Path -LiteralPath $pex)) {
    throw "Compiler did not create $pex"
}

Copy-Item -LiteralPath $pex -Destination (Join-Path $runtimeScripts 'MariaLocationManager.pex') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination (Join-Path $runtime 'README.md') -Force

Write-Host "Built and deployed: $runtime"
