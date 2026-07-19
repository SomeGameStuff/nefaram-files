$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$sourceRoot = Join-Path $projectRoot 'Source\Scripts'
$outputRoot = Join-Path $projectRoot 'build-output'
$scriptOutput = Join-Path $outputRoot 'Scripts'
$pluginOutput = Join-Path $outputRoot 'Feral.esp'
$seqOutput = Join-Path $outputRoot 'SEQ\Feral.seq'
$builderProject = Join-Path $PSScriptRoot 'FeralBuilder.csproj'
$markBuilder = Join-Path $projectRoot 'assets\Generate-Feral-Marks.ps1'
$tattooJsonSource = Join-Path $projectRoot 'assets\feral.json'
$tattooJsonOutput = Join-Path $outputRoot 'Textures\Actors\Character\slavetats\feral.json'

New-Item -ItemType Directory -Path $scriptOutput -Force | Out-Null
dotnet run --project $builderProject -- $pluginOutput
if ($LASTEXITCODE -ne 0) { throw 'Feral ESP build or validation failed.' }

& $markBuilder
if ($LASTEXITCODE -ne 0) { throw 'Feral marking texture generation failed.' }
New-Item -ItemType Directory -Path (Split-Path -Parent $tattooJsonOutput) -Force | Out-Null
Copy-Item -LiteralPath $tattooJsonSource -Destination $tattooJsonOutput -Force
$markCount = (Get-ChildItem -LiteralPath (Join-Path $outputRoot 'Textures\Actors\Character\slavetats\Feral') -Filter '*.dds' -File).Count
if ($markCount -ne 8) { throw "Expected 8 Feral marking textures, found $markCount." }

New-Item -ItemType Directory -Path (Split-Path -Parent $seqOutput) -Force | Out-Null
[IO.File]::WriteAllBytes($seqOutput, [BitConverter]::GetBytes([UInt32]0x950))
$seqBytes = [IO.File]::ReadAllBytes($seqOutput)
if ($seqBytes.Length -ne 4 -or [BitConverter]::ToUInt32($seqBytes, 0) -ne 0x950) {
    throw 'Feral SEQ generation failed.'
}

$compiler = 'C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe'
$flags = '-f=C:\tmp\skyrim-scripts-source\Source\Scripts\TESV_Papyrus_Flags.flg'
$includes = '-i=' + ($sourceRoot, (Join-Path $projectRoot 'build-stubs'),
    'C:\Games\nefaram\mods\SKSE\Scripts\Source',
    'C:\tmp\skyrim-scripts-source\Source\Scripts',
    'C:\Games\nefaram\mods\PapyrusUtil SE - Modders Scripting Utility Functions\Source\Scripts',
    "C:\Games\nefaram\mods\powerofthree's Papyrus Extender\Source\scripts",
    'C:\Games\nefaram\mods\Experience\Scripts\Source' -join ';')
$output = '-o=' + $scriptOutput
$scripts = @(
    'cfl_FeralMCM.psc',
    'cfl_FeralMCMxxx.psc',
    'cfl_FeralClaimEffect.psc',
    'cfl_FeralAspectEffect.psc',
    'cfl_FeralAspxEffect.psc',
    'cfl_FeralPassiveEffect.psc',
    'cfl_FeralShapeEffect.psc',
    'cfl_FeralRevertEffect.psc'
)

Push-Location $sourceRoot
try {
    foreach ($script in $scripts) {
        & $compiler $script $flags $includes $output
        if ($LASTEXITCODE -ne 0) { throw "Papyrus compilation failed for $script." }
    }
}
finally {
    Pop-Location
}

foreach ($script in $scripts) {
    $pex = Join-Path $scriptOutput ([IO.Path]::ChangeExtension($script, '.pex'))
    if (!(Test-Path -LiteralPath $pex)) { throw "Missing compiled output: $pex" }
}

$controller = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'cfl_FeralMCM.psc')
$experienceSettingCount = [regex]::Matches($controller, 'settings\[\d+\] = "iXP(?:Quest|Disc|Clear)').Count
if ($experienceSettingCount -ne 91) { throw "Expected 91 Experience reward settings, found $experienceSettingCount." }
foreach ($required in @('GetConfiguredFamily', 'RefreshShapePowers', 'ExperienceRewardsAreSuppressed',
    'RecoverExperienceSettingsIfNeeded', 'CompleteClaim', 'RankForCount', 'EndActiveShape',
    'GetClaimWindowSeconds')) {
    if ($controller -notmatch [regex]::Escape($required)) { throw "Missing controller feature: $required" }
}

Write-Output 'Feral build validation passed: unified transformation records, official race IDs, Bodymorph globals, JSON schema, and 8 Papyrus scripts.'
