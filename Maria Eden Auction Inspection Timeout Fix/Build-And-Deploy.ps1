[CmdletBinding()]
param(
    [string]$Mo2Root = $env:NEFARAM_MO2_ROOT,
    [string]$Compiler = $env:NEFARAM_PAPYRUS_COMPILER,
    [string]$VanillaSource = $env:NEFARAM_VANILLA_SOURCE
)

$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$source = Join-Path $projectRoot 'Source\Scripts\MEP_AuctionQuest.psc'
$stubs = Join-Path $projectRoot 'build-stubs'
$projectScripts = Join-Path $projectRoot 'Scripts'
$runtime = Join-Path $Mo2Root 'mods\[NoDelete] Maria Eden Auction Inspection Timeout Fix'
$runtimeScripts = Join-Path $runtime 'Scripts'

$vanilla = $VanillaSource
$skse = Join-Path $Mo2Root 'mods\SKSE\Scripts\Source'
$papyrusUtil = Join-Path $Mo2Root 'mods\PapyrusUtil SE - Modders Scripting Utility Functions\Source\Scripts'
$po3 = Join-Path $Mo2Root "mods\powerofthree's Papyrus Extender\Source\scripts"
$originalPex = Join-Path $Mo2Root 'mods\MariaEdenProstitution\scripts\MEP_AuctionQuest.pex'
if ([string]::IsNullOrWhiteSpace($Mo2Root) -or [string]::IsNullOrWhiteSpace($compiler) -or [string]::IsNullOrWhiteSpace($vanilla)) {
    throw 'Set NEFARAM_MO2_ROOT, NEFARAM_PAPYRUS_COMPILER, and NEFARAM_VANILLA_SOURCE before building.'
}

foreach ($required in @($source, $stubs, $compiler, $vanilla, $skse, $papyrusUtil, $po3, $originalPex)) {
    if (!(Test-Path -LiteralPath $required)) {
        throw "Required path not found: $required"
    }
}

New-Item -ItemType Directory -Force -Path $projectScripts | Out-Null
New-Item -ItemType Directory -Force -Path $runtimeScripts | Out-Null

$include = "$(Split-Path -Parent $source);$stubs;$skse;$papyrusUtil;$po3;$vanilla"
$flags = Join-Path $vanilla 'TESV_Papyrus_Flags.flg'

& $compiler $source "-f=$flags" "-i=$include" "-o=$projectScripts"
if ($LASTEXITCODE -ne 0) {
    throw 'Papyrus compilation failed.'
}

$pex = Join-Path $projectScripts 'MEP_AuctionQuest.pex'
if (!(Test-Path -LiteralPath $pex)) {
    throw "Compiler did not create $pex"
}

if ((Get-FileHash -Algorithm SHA256 -LiteralPath $pex).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $originalPex).Hash) {
    throw 'Compiled override unexpectedly matches the original PEX.'
}

Copy-Item -LiteralPath $pex -Destination (Join-Path $runtimeScripts 'MEP_AuctionQuest.pex') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination (Join-Path $runtime 'README.md') -Force

Write-Host "Built and deployed: $runtime"
