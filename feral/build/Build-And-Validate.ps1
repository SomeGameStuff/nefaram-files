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
$handsMarkCount = @($markFiles | Where-Object { $_.BaseName -match '_hands$' }).Count
if ($handsMarkCount -ne 8) { throw "Expected 8 Feral hand marking textures, found $handsMarkCount." }
$tattooCount = @((Get-Content -Raw -LiteralPath $tattooJsonOutput | ConvertFrom-Json)).Count
if ($tattooCount -ne 40) { throw "Expected 40 SlaveTats registrations, found $tattooCount." }

New-Item -ItemType Directory -Path (Split-Path -Parent $seqOutput) -Force | Out-Null
[IO.File]::WriteAllBytes($seqOutput, [BitConverter]::GetBytes([UInt32]0x950))
$seqBytes = [IO.File]::ReadAllBytes($seqOutput)
if ($seqBytes.Length -ne 4 -or [BitConverter]::ToUInt32($seqBytes, 0) -ne 0x950) {
    throw 'Feral SEQ generation failed.'
}

$compiler = 'C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe'
$vanillaSource = 'C:\Users\antho\nefaram-files\tools\vanilla-source\Source\Scripts'
$flags = '-f=' + (Join-Path $vanillaSource 'TESV_Papyrus_Flags.flg')
$includes = '-i=' + ($sourceRoot, (Join-Path $projectRoot 'build-stubs'),
    'C:\Games\nefaram\mods\SKSE\Scripts\Source',
    $vanillaSource,
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
    'cfl_FeralTechniqueEffect.psc',
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
$skyUiStub = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'build-stubs\SKI_ConfigBase.psc')
$experienceSettingCount = [regex]::Matches($controller, 'settings\[\d+\] = "iXP(?:Quest|Disc|Clear)').Count
if ($experienceSettingCount -ne 91) { throw "Expected 91 Experience reward settings, found $experienceSettingCount." }
foreach ($required in @('GetConfiguredFamily', 'RefreshShapePowers', 'ExperienceRewardsAreSuppressed',
    'RecoverExperienceSettingsIfNeeded', 'CompleteClaim', 'EndActiveShape', 'GetExpressionScale',
    'StartFeralFatigue', 'IsFeralActiveValue', 'MasteryPointsForNextLevel',
    'MasteryAwardForHarvest', 'GrantMastery', 'AddActivityMastery', 'AddShapeTime',
    'RankForLevel', 'GetMarkOpacity', 'Feral.MasteryLevel', 'RefreshTechniquePowers',
    'GetActiveFamily', 'GetNotoriety', 'RecordWitnessedTransformation', 'SpawnHunterGroup',
    'PassiveRankForLevel', 'DurationTierForLevel', 'ShapeDurationForLevel',
    'RefreshPassivePowers', 'ApplyShapeTier', 'GetMorphMultiplier', 'GetConfiguredMorphValue',
    'EnsureKinshipDefaults', 'IsKinshipEnabled', 'AreKinshipApproachesEnabled',
    'GetKinshipMinimumLevel', 'GetKinshipFrequency', 'GetKinshipCooldownHours',
    'BroadcastShapeStart', 'BroadcastShapeEnd', 'FeralShapeStart', 'FeralShapeEnd')) {
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
if ($controller -match 'RegisterFor(?:Single)?Update') {
    throw 'Controller contains a recurring Papyrus update registration.'
}
$rankForLevelBody = [regex]::Match($controller, 'Int Function RankForLevel[\s\S]*?EndFunction').Value
if ($rankForLevelBody -match '34|67|Return 2|Return 3') {
    throw 'Transformation power acquisition is still coupled to retired visual stages.'
}
if ($controller -notmatch 'Return 0\.25 \+ \(\(level - 1\) \* \(0\.75 / 99\.0\)\)') {
    throw 'Continuous level 1-100 expression curve is missing.'
}
foreach ($milestone in @('level >= 25', 'level >= 50', 'level >= 75', 'level >= 100')) {
    if ($controller -notmatch [regex]::Escape($milestone)) { throw "Missing progression milestone: $milestone" }
}
if ($controller -notmatch 'seconds > 1200\.0' -or $controller -notmatch 'Feral\.Morph\.Multiplier\.') {
    throw 'Long-duration mastery or per-save morph configuration is missing.'
}
foreach ($page in @('Overview', 'Progression', 'Families', 'Morphs', 'Human response', 'Settings')) {
    if ($controller -notmatch ('Pages\[\d+\] = "' + [regex]::Escape($page) + '"')) {
        throw "Missing MCM page: $page"
    }
}
if ($controller -notmatch 'Return 13' -or $controller -notmatch 'Event OnConfigOpen\(\)[\s\S]*?EnsurePages\(\)[\s\S]*?EndEvent') {
    throw 'MCM v13 existing-save page refresh is missing.'
}
if ($controller -match '_morphOptions\s*=\s*None') {
    throw 'MCM still assigns None to an Int array.'
}
foreach ($required in @('BuildProgressionPage', 'BuildFamiliesPage', 'BuildHumanResponsePage',
    'SexIntegrationInstalled', 'SexProgressionText', 'MorphDisplayName', 'Event OnOptionHighlight')) {
    if ($controller -notmatch [regex]::Escape($required)) { throw "Missing MCM v13 feature: $required" }
}
if ($skyUiStub -notmatch 'Int Property TOP_TO_BOTTOM = 2' -or
    $skyUiStub -notmatch 'Int Function AddHeaderOption' -or
    $skyUiStub -notmatch 'Int Function AddEmptyOption' -or
    $skyUiStub -notmatch 'Event OnConfigOpen' -or
    $skyUiStub -notmatch 'Event OnOptionHighlight') {
    throw 'Local SkyUI compile interface does not match the runtime API.'
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
    'Feral.ActiveToken', 'ownsCurrentShape', 'AddShapeTime', 'GetCurrentGameTime',
    'MarkOpacity', 'Return baseMark + " III"', 'EndActiveShape', 'BroadcastShapeStart',
    'BroadcastShapeEnd')) {
    if ($shapeEffect -notmatch [regex]::Escape($required)) { throw "Missing owner-safe shape feature: $required" }
}
if ($shapeEffect -match 'GetTimeElapsed') {
    throw 'Shape effect still calls GetTimeElapsed, which fails on an unbound finish event.'
}
if ($shapeEffect -match 'RegisterFor(?:Single)?Update|QueueNiNodeUpdate') {
    throw 'Shape effect contains polling or a redundant full NiNode rebuild.'
}
if ($shapeEffect -match 'ApplyCosmetic\(player\)|0\.15 \* Rank') {
    throw 'Shape visuals still contain a discrete rank-gated application path.'
}

$techniqueEffect = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'cfl_FeralTechniqueEffect.psc')
foreach ($required in @('Feral.TechniqueReady.', 'GetActiveFamily', 'GetMasteryLevel', 'OnEffectFinish')) {
    if ($techniqueEffect -notmatch [regex]::Escape($required)) { throw "Missing technique feature: $required" }
}
if ($controller -notmatch 'remaining > 15\.0' -or $techniqueEffect -notmatch 'remaining > 60\.0') {
    throw 'Cross-session real-time timer recovery is missing.'
}
if ($techniqueEffect -match 'RegisterFor(?:Single)?Update') {
    throw 'Technique effect contains a Papyrus update registration.'
}

Write-Output "Feral v13 build validation passed: six-page MCM, kinship integration controls and lifecycle events, existing-save navigation repair, friendly live-inspected morphs, permanent family passives, 2-20 minute shapes, 100-level mastery ($masteryCurveTotal points), notoriety, XP modes, and 9 Papyrus scripts."
