$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$sourceRoot = Join-Path $projectRoot 'Source\Scripts'
$outputRoot = Join-Path $projectRoot 'Scripts'
$mo2Root = $env:NEFARAM_MO2_ROOT
$compiler = $env:NEFARAM_PAPYRUS_COMPILER
$vanilla = $env:NEFARAM_VANILLA_SOURCE
if ([string]::IsNullOrWhiteSpace($vanilla)) {
    $vanilla = Join-Path (Split-Path $projectRoot) 'tools\vanilla-source\Source\Scripts'
}
if ([string]::IsNullOrWhiteSpace($mo2Root) -or [string]::IsNullOrWhiteSpace($compiler)) {
    throw 'Set NEFARAM_MO2_ROOT and NEFARAM_PAPYRUS_COMPILER before building. NEFARAM_VANILLA_SOURCE optionally overrides the repo vanilla sources.'
}
$includes = @(
    $sourceRoot
    (Join-Path $projectRoot 'build-stubs')
    (Join-Path $mo2Root 'mods\SKSE\Scripts\Source')
    $vanilla
    (Join-Path $mo2Root 'mods\MCM Recorder\Source\scripts')
    (Join-Path $mo2Root "mods\powerofthree's Papyrus Extender\Source\scripts")
    (Join-Path $mo2Root 'mods\PapyrusUtil SE - Modders Scripting Utility Functions\Source\Scripts')
) -join ';'
$scripts = @(Get-ChildItem -LiteralPath $sourceRoot -Filter '*.psc' | Select-Object -ExpandProperty Name)

if (!(Test-Path -LiteralPath $compiler)) { throw "Papyrus compiler missing: $compiler" }
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

Push-Location $sourceRoot
try {
    foreach ($script in $scripts) {
        $compilerOutput = & $compiler $script "-f=$vanilla\TESV_Papyrus_Flags.flg" "-i=$includes" "-o=$outputRoot" 2>&1
        $compilerOutput | Write-Output
        if ($LASTEXITCODE -ne 0) { throw "Papyrus compilation failed for $script." }
        if (($compilerOutput -join "`n") -match '(?im)^.*(?:[1-9][0-9]* warning\(s\)|[1-9][0-9]* error\(s\)|: warning)') {
            throw "Papyrus compiler reported warnings/errors for $script."
        }
    }
}
finally {
    Pop-Location
}

foreach ($script in $scripts) {
    $pex = Join-Path $outputRoot ([IO.Path]::ChangeExtension($script, '.pex'))
    if (!(Test-Path -LiteralPath $pex)) { throw "Missing compiled output: $pex" }
}

& (Join-Path $projectRoot 'build\Remove-PexBuildIdentity.ps1') -ScriptsRoot $outputRoot
& (Join-Path $projectRoot 'build\Test-Review.ps1')
Write-Output "Bodymorph Alterations validation passed: $($scripts.Count) compiled scripts and review regression checks."
