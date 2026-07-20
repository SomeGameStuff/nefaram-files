$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$sourceRoot = Join-Path $projectRoot 'Source\Scripts'
$outputRoot = Join-Path $projectRoot 'Scripts'
$markerPath = Join-Path $projectRoot 'SKSE\Plugins\Feral\SexIntegration.json'
$upstreamRoot = 'C:\Games\nefaram\mods\Sex Grants Experience'
$expected = @{
    'SexLabExperience.psc' = '28828B90595DB4B3DEDD0579CFF10395BC27FD1BCB6CFBF61E8874F043308579'
    'OStimExperience.psc' = 'C4C992F74A29D8B46BA9DC47C5878D7CA2A133E732A1A49665817A459483C5F8'
}
foreach ($name in $expected.Keys) {
    $actual = (Get-FileHash -LiteralPath (Join-Path $upstreamRoot "Source\Scripts\$name") -Algorithm SHA256).Hash
    if ($actual -ne $expected[$name]) { throw "Unsupported Sex Grants Experience source: $name hash $actual" }
}
$expectedPex = @{
    'SexLabExperience.pex' = 'BB407477D4769DE2DD478EE7A5B5607AADDF4BADD35D8AE7BB7F85F87FF81E5D'
    'OStimExperience.pex' = 'E4B179ABECBCB0BF731F01A845B3BB6895156EACB4D334EBCA2ACB0884DA7B09'
}
foreach ($name in $expectedPex.Keys) {
    $actual = (Get-FileHash -LiteralPath (Join-Path $upstreamRoot "Scripts\$name") -Algorithm SHA256).Hash
    if ($actual -ne $expectedPex[$name]) { throw "Unsupported Sex Grants Experience binary: $name hash $actual" }
}

New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
$compiler = 'C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe'
$vanillaSource = 'C:\Users\antho\nefaram-files\tools\vanilla-source\Source\Scripts'
$flags = '-f=' + (Join-Path $vanillaSource 'TESV_Papyrus_Flags.flg')
$includePaths = @(
    $sourceRoot,
    (Join-Path $projectRoot 'build-stubs'),
    'C:\Games\nefaram\mods\SKSE\Scripts\Source',
    'C:\Games\nefaram\mods\PapyrusUtil SE - Modders Scripting Utility Functions\Source\Scripts',
    $vanillaSource
)
$includes = '-i=' + ($includePaths -join ';')
$output = '-o=' + $outputRoot
$scripts = @('SexLabExperience.psc', 'OStimExperience.psc')
Push-Location $sourceRoot
try {
    foreach ($script in $scripts) {
        & $compiler $script $flags $includes $output
        if ($LASTEXITCODE -ne 0) { throw "Papyrus compilation failed for $script" }
    }
}
finally {
    Pop-Location
}

foreach ($script in $scripts) {
    $pex = Join-Path $outputRoot ([IO.Path]::ChangeExtension($script, '.pex'))
    if (!(Test-Path -LiteralPath $pex)) { throw "Missing compiled override: $pex" }
    $source = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot $script)
    foreach ($required in @('Feral.Qualified', 'GetActiveFamily', 'AddActivityMastery', 'GetFeralMasteryReward', 'MasteryPerMatchingScene')) {
        if ($source -notmatch [regex]::Escape($required)) { throw "Missing $required in $script" }
    }
    if ($source -match 'RegisterFor(?:Single)?Update') { throw "Polling found in $script" }
}

if (!(Test-Path -LiteralPath $markerPath)) { throw "Missing integration marker: $markerPath" }
$marker = Get-Content -Raw -LiteralPath $markerPath | ConvertFrom-Json
if ($marker.Installed -ne 1 -or $marker.Version -lt 1 -or $marker.MasteryPerMatchingScene -ne 12) {
    throw 'Feral sex integration marker is invalid.'
}

Write-Output 'Feral Sex Grants Experience integration validated: upstream 1.8.0 pinned, shape-gated XP, matching-family mastery, marker metadata, and 2 compiled overrides.'
