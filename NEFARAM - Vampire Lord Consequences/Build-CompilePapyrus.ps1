$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$mo2Root = $env:NEFARAM_MO2_ROOT
$compiler = $env:NEFARAM_PAPYRUS_COMPILER
$vanilla = $env:NEFARAM_VANILLA_SOURCE
$source = Join-Path $projectRoot 'Source\Scripts'
$output = Join-Path $mo2Root 'mods\NEFARAM - Vampire Lord Consequences\Scripts'
$skse = Join-Path $mo2Root 'mods\SKSE\Scripts\Source'
$flags = Join-Path $vanilla 'TESV_Papyrus_Flags.flg'
if ([string]::IsNullOrWhiteSpace($mo2Root) -or [string]::IsNullOrWhiteSpace($compiler) -or [string]::IsNullOrWhiteSpace($vanilla)) {
  throw 'Set NEFARAM_MO2_ROOT, NEFARAM_PAPYRUS_COMPILER, and NEFARAM_VANILLA_SOURCE before building.'
}

New-Item -ItemType Directory -Force -Path $output | Out-Null
& $compiler 'NVLC_Controller.psc' "-i=$source;$skse;$vanilla" "-o=$output" "-f=$flags"
if ($LASTEXITCODE -ne 0) {
  throw "Papyrus compiler failed with exit code $LASTEXITCODE"
}
