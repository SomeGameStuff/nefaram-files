[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$dataRoot = Join-Path $projectRoot 'Final MO2 Mod'
$translationMap = Get-Content -LiteralPath (Join-Path $projectRoot 'translation-codex-final.json') -Raw
if ($translationMap -notmatch '"Angemessene Kleidung für eine Land Sklavin"\s*:\s*"Appropriate clothing for a farm slave"') {
    throw 'Final translation map is missing the farm-slave clothing translation.'
}
foreach ($catalogFile in Get-ChildItem -LiteralPath (Join-Path $projectRoot 'Catalogs') -Filter '*.json' -File) {
    $catalog = Get-Content -LiteralPath $catalogFile.FullName -Raw | ConvertFrom-Json
    $emptyEntries = @($catalog | Where-Object { [string]::IsNullOrWhiteSpace([string]$_.English) })
    if ($emptyEntries.Count -ne 0) { throw "$($catalogFile.Name) contains $($emptyEntries.Count) empty English fields." }
}
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
    $translationPath = Join-Path $dataRoot "interface\translations\$required"
    if (-not (Test-Path -LiteralPath $translationPath)) { throw "Missing $required" }
    $translationBytes = [IO.File]::ReadAllBytes($translationPath)
    if ($translationBytes.Length -lt 2 -or $translationBytes[0] -ne 0xFF -or $translationBytes[1] -ne 0xFE) {
        throw "$required must be UTF-16 LE with a BOM for Skyrim translation lookup."
    }
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
