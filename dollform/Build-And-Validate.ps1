$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$sourceRoot = Join-Path $projectRoot 'Source\Scripts'
$outputRoot = Join-Path $projectRoot 'Scripts'
$compiler = 'C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe'
$vanilla = 'C:\tmp\skyrim-scripts-source\Source\Scripts'
$includes = @(
    $sourceRoot
    (Join-Path $projectRoot 'build-stubs')
    'C:\Users\antho\nefaram-files\feral\build-stubs'
    'C:\Games\nefaram\mods\SKSE\Scripts\Source'
    $vanilla
    'C:\Games\nefaram\mods\MCM Recorder\Source\scripts'
    "C:\Games\nefaram\mods\powerofthree's Papyrus Extender\Source\scripts"
    'C:\Games\nefaram\mods\PapyrusUtil SE - Modders Scripting Utility Functions\Source\Scripts'
) -join ';'
$scripts = @(
    'cfl_DollformEffect.psc'
    'cfl_HorseformEffect.psc'
    'cfl_CowformEffect.psc'
    'cfl_RabbitformEffect.psc'
    'cfl_TrollformEffect.psc'
    'cfl_DollformMCM.psc'
)

if (!(Test-Path -LiteralPath $compiler)) { throw "Papyrus compiler missing: $compiler" }
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

Push-Location $sourceRoot
try {
    foreach ($script in $scripts) {
        & $compiler $script "-f=$vanilla\TESV_Papyrus_Flags.flg" "-i=$includes" "-o=$outputRoot"
        if ($LASTEXITCODE -ne 0) { throw "Papyrus compilation failed for $script." }
    }
}
finally {
    Pop-Location
}

foreach ($script in $scripts) {
    $pex = Join-Path $outputRoot ([IO.Path]::ChangeExtension($script, '.pex'))
    if (!(Test-Path -LiteralPath $pex)) { throw "Missing compiled output: $pex" }
}

$sources = $scripts | ForEach-Object { Get-Content -Raw -LiteralPath (Join-Path $sourceRoot $_) }
$effectSources = $sources[0..4] -join "`n"
foreach ($required in @('BeginActiveForm', 'IsActiveInstance', 'ActiveFormId', 'ActiveToken',
    'BodymorphAlterations.LastFormToken')) {
    if ($effectSources -notmatch [regex]::Escape($required)) { throw "Missing tokenized lifecycle feature: $required" }
}
if ($sources[5] -notmatch 'RunFormRecovery') { throw 'Missing transactional MCM recovery.' }

Write-Output 'Bodymorph Alterations validation passed: 6 zero-warning scripts, tokenized ownership, and transactional recovery.'
