$ErrorActionPreference = 'Stop'

$modRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir = Join-Path $modRoot 'Source\Scripts'
$outputDir = Join-Path $modRoot 'Scripts'
$compiler = 'C:\Games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe'
$vanillaSource = 'C:\Users\antho\nefaram-files\tools\vanilla-source\Source\Scripts'
$skseSource = 'C:\games\nefaram\mods\SKSE\Scripts\Source'

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
    & $compiler $script -i="$sourceDir;$skseSource;$vanillaSource" -o="$outputDir" -f="TESV_Papyrus_Flags.flg"
    if ($LASTEXITCODE -ne 0) {
        throw "Papyrus compilation failed for $script"
    }
}

Write-Host "Compiled Spatial Storage Rings scripts to $outputDir"
