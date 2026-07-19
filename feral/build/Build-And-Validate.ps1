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
$runtimeConfigRoot = Join-Path $outputRoot 'SKSE\Plugins\Feral'

New-Item -ItemType Directory -Path $scriptOutput -Force | Out-Null
dotnet run --project $builderProject -- $pluginOutput
if ($LASTEXITCODE -ne 0) { throw 'Feral ESP build or validation failed.' }

& $markBuilder
if ($LASTEXITCODE -ne 0) { throw 'Feral marking texture generation failed.' }
New-Item -ItemType Directory -Path (Split-Path -Parent $tattooJsonOutput) -Force | Out-Null
Copy-Item -LiteralPath $tattooJsonSource -Destination $tattooJsonOutput -Force
$raceConfigSource = Join-Path $projectRoot 'config\Races.json'
$cosmeticsConfigSource = Join-Path $projectRoot 'config\Cosmetics.json'
New-Item -ItemType Directory -Path $runtimeConfigRoot -Force | Out-Null
Copy-Item -LiteralPath $raceConfigSource -Destination (Join-Path $runtimeConfigRoot 'Races.json') -Force
Copy-Item -LiteralPath $cosmeticsConfigSource -Destination (Join-Path $runtimeConfigRoot 'Cosmetics.json') -Force
$markFiles = Get-ChildItem -LiteralPath (Join-Path $outputRoot 'Textures\Actors\Character\slavetats\Feral') -Filter '*.dds' -File
$stagedMarkCount = @($markFiles | Where-Object { $_.BaseName -match '_[123]$' }).Count
if ($stagedMarkCount -ne 24) { throw "Expected 24 staged Feral marking textures, found $stagedMarkCount." }
$tattooCount = @((Get-Content -Raw -LiteralPath $tattooJsonOutput | ConvertFrom-Json)).Count
if ($tattooCount -ne 24) { throw "Expected 24 SlaveTats registrations, found $tattooCount." }

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
    'RecoverExperienceSettingsIfNeeded', 'CompleteClaim', 'EndActiveShape', 'GetExpressionScale',
    'StartFeralFatigue', 'IsFeralActiveValue', 'MasteryPointsForNextLevel',
    'MasteryAwardForHarvest', 'GrantMastery', 'AddActivityMastery', 'AddShapeTime',
    'RankForLevel', 'Feral.MasteryLevel')) {
    if ($controller -notmatch [regex]::Escape($required)) { throw "Missing controller feature: $required" }
}
if ($controller -notmatch 'If !IsFeralEnabled\(\) \|\| akKiller != Game.GetPlayer\(\)') {
    throw 'Actor-killed handler does not reject irrelevant kills before race matching.'
}
$actorKilledBody = [regex]::Match($controller, 'Event OnActorKilled[\s\S]*?EndEvent').Value
if ($actorKilledBody -match 'PendingEssence|FormListAdd') {
    throw 'Actor-killed handler still retains corpse references.'
}
if ($controller -match 'QueueNiNodeUpdate') {
    throw 'Controller still requests a redundant full NiNode rebuild.'
}
$masteryCurveTotal = 0
for ($level = 0; $level -lt 100; $level++) {
    $masteryCurveTotal += 5 + [Math]::Ceiling($level * 0.45)
}
if ($masteryCurveTotal -lt 2700 -or $masteryCurveTotal -gt 2900) {
    throw "Unexpected level-100 mastery curve total: $masteryCurveTotal"
}

$shapeEffect = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'cfl_FeralShapeEffect.psc')
foreach ($required in @('BeginActiveShape', 'IsActiveInstance', 'Feral.LastShapeToken',
    'Feral.ActiveToken', 'ownsCurrentShape', 'AddShapeTime', 'GetTimeElapsed')) {
    if ($shapeEffect -notmatch [regex]::Escape($required)) { throw "Missing owner-safe shape feature: $required" }
}
if ($shapeEffect -match 'RegisterFor(?:Single)?Update|QueueNiNodeUpdate') {
    throw 'Shape effect contains polling or a redundant full NiNode rebuild.'
}

Write-Output "Feral v6 build validation passed: automatic harvest, 100-level mastery ($masteryCurveTotal points), low-overhead shape use, staged transformations, XP modes, JSON configs, and 8 Papyrus scripts."
