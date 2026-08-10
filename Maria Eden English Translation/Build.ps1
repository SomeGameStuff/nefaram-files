[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$dataRoot = Join-Path $projectRoot 'Final MO2 Mod'
$poseRoot = Join-Path $dataRoot 'SKSE\Plugins\StorageUtilData\MariaPoses'
$poseFiles = Get-ChildItem -LiteralPath $poseRoot -Filter '*.json' -File
if ($poseFiles.Count -lt 40) { throw "Expected at least 40 translated pose files, found $($poseFiles.Count)." }
foreach ($file in $poseFiles) {
    $json = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    if (-not $json.string.name -or -not $json.string.group) { throw "Missing translated pose labels in $($file.Name)." }
}
foreach ($required in @('MariaIdles.json','MariaOutfits\female\outfits.json','MariaOutfits\male\outfits.json','MariaDefaults.json')) {
    if (-not (Test-Path -LiteralPath (Join-Path $dataRoot "SKSE\Plugins\StorageUtilData\$required"))) { throw "Missing $required" }
}
foreach ($required in @('MariaBase_english.txt','MariaProstitution_english.txt')) {
    if (-not (Test-Path -LiteralPath (Join-Path $dataRoot "interface\translations\$required"))) { throw "Missing $required" }
}
Write-Host 'English data translation validation succeeded.'

foreach ($required in @(
    'MariaBase.esm',
    'MariaProstitution.esp',
    'MariaDevices.esp',
    'MariaSlaveLocations.esp',
    'MariaWhoreLocations.esp',
    'MariaProstitutionMarkers.esp',
    'Scripts\MariasUtils.pex',
    'Scripts\MEP_AnimalQuest.pex',
    'Scripts\MEP_DumbEffect.pex',
    'Scripts\MEP_MiniNeedsAlias.pex'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $dataRoot $required))) { throw "Missing $required" }
}
Write-Host 'Complete English MO2 mod validation succeeded.'
