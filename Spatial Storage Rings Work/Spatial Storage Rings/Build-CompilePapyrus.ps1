$ErrorActionPreference = 'Stop'

$modRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir = Join-Path $modRoot 'Source\Scripts'
$outputDir = Join-Path $modRoot 'Scripts'
$compiler = $env:NEFARAM_PAPYRUS_COMPILER
$vanillaSource = $env:NEFARAM_VANILLA_SOURCE
$skseSource = if ($env:NEFARAM_MO2_ROOT) { Join-Path $env:NEFARAM_MO2_ROOT 'mods\SKSE\Scripts\Source' }
if ([string]::IsNullOrWhiteSpace($compiler) -or [string]::IsNullOrWhiteSpace($vanillaSource) -or [string]::IsNullOrWhiteSpace($skseSource)) {
    throw 'Set NEFARAM_MO2_ROOT, NEFARAM_PAPYRUS_COMPILER, and NEFARAM_VANILLA_SOURCE before building.'
}

if (-not (Test-Path -LiteralPath $compiler)) {
    throw "PapyrusCompiler.exe not found at $compiler"
}

if (-not (Test-Path -LiteralPath $vanillaSource)) {
    throw "Vanilla script source not found at $vanillaSource"
}

if (-not (Test-Path -LiteralPath $skseSource)) {
    throw "SKSE script source not found at $skseSource"
}

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$scripts = @(
    'SSR_RingLesserEffect.psc',
    'SSR_RingGreaterEffect.psc',
    'SSR_RingGrandEffect.psc',
    'SSR_RingInfiniteEffect.psc',
    'SSR_OpenStorageEffect.psc',
    'SSR_StorageContainerScript.psc'
)

foreach ($script in $scripts) {
    & $compiler $script -i="$sourceDir;$skseSource;$vanillaSource" -o="$outputDir" -f="$(Join-Path $vanillaSource 'TESV_Papyrus_Flags.flg')"
    if ($LASTEXITCODE -ne 0) {
        throw "Papyrus compilation failed for $script"
    }
}

Write-Host "Compiled Spatial Storage Rings scripts to $outputDir"
