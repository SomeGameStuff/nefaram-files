[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$baseMod = 'C:\Games\nefaram\mods\MariaEdenProstitution'
$dataRoot = Join-Path $projectRoot 'Data'
$cachePath = Join-Path $projectRoot 'translation-cache.json'
$resolvedProject = [IO.Path]::GetFullPath($projectRoot)
$resolvedData = [IO.Path]::GetFullPath($dataRoot)
if (-not $resolvedData.StartsWith($resolvedProject, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to generate outside project: $resolvedData"
}

$cache = @{}
if (Test-Path -LiteralPath $cachePath) {
    $loaded = Get-Content -LiteralPath $cachePath -Raw | ConvertFrom-Json
    foreach ($property in $loaded.PSObject.Properties) {
        $cache[$property.Name] = [string]$property.Value
    }
}

function Get-English([string]$text) {
    if ([string]::IsNullOrWhiteSpace($text)) { return $text }
    if ($cache.ContainsKey($text)) { return $cache[$text] }
    $url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=de&tl=en&dt=t&q=' + [uri]::EscapeDataString($text)
    $response = Invoke-RestMethod -Uri $url -Method Get
    $translated = [string]$response[0][0][0]
    if ([string]::IsNullOrWhiteSpace($translated)) { throw "No translation returned for: $text" }
    $cache[$text] = $translated
    Start-Sleep -Milliseconds 80
    return $translated
}

function Write-JsonUtf8NoBom([string]$path, $value) {
    $content = $value | ConvertTo-Json -Depth 100
    [IO.File]::WriteAllText($path, $content + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
}

if (Test-Path -LiteralPath $resolvedData) {
    Remove-Item -LiteralPath $resolvedData -Recurse -Force
}
$storageOut = Join-Path $resolvedData 'SKSE\Plugins\StorageUtilData'
$poseOut = Join-Path $storageOut 'MariaPoses'
$translationOut = Join-Path $resolvedData 'interface\translations'
New-Item -ItemType Directory -Force -Path $poseOut,$translationOut | Out-Null

$poseSource = Join-Path $baseMod 'SKSE\Plugins\StorageUtilData\MariaPoses'
$poseNames = @{
    'assfuck.json'='All fours, spread'; 'bleedout.json'='Wounded'; 'crawling.json'='Crawl';
    'dance.json'='Dance'; 'device_cage.json'='Pole cage'; 'device_crucified.json'='Crucified';
    'device_strugglerope.json'='Strangling rope'; 'fear.json'='Fear'; 'fieldwork.json'='Field work';
    'foodtable.json'='Serve as table'; 'gulp.json'='Gulp or cough'; 'hogtied.json'='Hogtied';
    'kneel.json'='Kneel'; 'kneel_give_cane.json'='Offer cane'; 'laying.json'='Lie down';
    'masturbate.json'='Masturbate'; 'on_all_fours.json'='All fours';
    'paired_feet_lick.json'='Lick feet'; 'paired_feet_on_face.json'='Foot on face';
    'paired_kiss_holding.json'='Kiss, holding'; 'paired_kiss_princess.json'='Kiss, carried';
    'paired_kiss_standing.json'='Kiss, standing'; 'paired_wash_feet.json'='Wash feet';
    'pickaxefloor.json'='Mining, floor'; 'pickaxewall.json'='Mining, wall';
    'piss_kneeling.json'='Urinate, crouching'; 'piss_standing.json'='Urinate, standing';
    'present_ars.json'='Present rear'; 'present_vagina.json'='Present vagina';
    'pudency_walk.json'='Cover breasts and vulva'; 'serve_drinks.json'='Serve drinks';
    'serve_food.json'='Serve food'; 'sit_crosslegged.json'='Sit cross-legged';
    'spread_legs.json'='Lie down, spread legs'; 'stand_on_tiptoes.json'='Stand on tiptoes';
    'stand_ready.json'='Ready stance'; 'striptease.json'='Striptease'; 'surrender.json'='Surrender';
    'sweeping.json'='Sweep'; 'woodchop.json'='Chop wood'; 'zap_horny.json'='Horny';
    'zap_special.json'='Special'; 'zap_struggle.json'='Struggle'; 'zap_wrist.json'='Wrist'
}
$groupNames = @{
    'Sklaven Pose'='Slave Poses'; 'Sonstiges'='Miscellaneous'; 'Aktion'='Actions';
    'Gesten'='Gestures'; 'Zu Zweit'='Paired'; 'Urinieren'='Urination'; 'BDSM'='BDSM'; 'Zap'='Zap'
}
foreach ($file in Get-ChildItem -LiteralPath $poseSource -Filter '*.json' -File) {
    $json = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    if ($json.string) {
        if ($json.string.name) { $json.string.name = $poseNames[$file.Name] }
        if ($json.string.group) {
            $sourceGroup = [string]$json.string.group
            if ($groupNames.ContainsKey($sourceGroup)) { $json.string.group = $groupNames[$sourceGroup] }
            else { $json.string.group = Get-English $sourceGroup }
        }
        foreach ($property in $json.string.PSObject.Properties) {
            if ($property.Name -like 'mariadance*') {
                $property.Value = Get-English ([string]$property.Value)
            }
        }
    }
    Write-JsonUtf8NoBom (Join-Path $poseOut $file.Name) $json
}

$idleSource = Join-Path $baseMod 'SKSE\Plugins\StorageUtilData\MariaIdles.json'
$idles = Get-Content -LiteralPath $idleSource -Raw | ConvertFrom-Json
$keyMap = [ordered]@{
    'aktion'='actions'; 'arbeiten'='work'; 'bdsm'='bdsm'; 'categories'='categories';
    'gesten'='gestures'; 'knien'='kneeling'; 'laufen'='walking'; 'liegen'='lying';
    'sitzen'='sitting'; 'sklaven aktion'='slave actions'; 'stehen'='standing';
    'tanzen'='dancing'; 'goma'='goma'
}
$newLists = [ordered]@{}
foreach ($entry in $keyMap.GetEnumerator()) {
    $values = @($idles.stringList.($entry.Key))
    if ($entry.Key -eq 'categories') {
        $newLists[$entry.Value] = @($values | ForEach-Object { Get-English ([string]$_) })
    } else {
        $translatedValues = foreach ($value in $values) {
            $parts = [string]$value -split ','
            if ($parts.Count -ge 6) {
                $parts[$parts.Count - 1] = Get-English $parts[$parts.Count - 1]
            }
            $parts -join ','
        }
        $newLists[$entry.Value] = @($translatedValues)
    }
}
Write-JsonUtf8NoBom (Join-Path $storageOut 'MariaIdles.json') ([ordered]@{ stringList = $newLists })

foreach ($sex in @('female','male')) {
    $relative = "MariaOutfits\$sex\outfits.json"
    $source = Join-Path (Join-Path $baseMod 'SKSE\Plugins\StorageUtilData') $relative
    $json = Get-Content -LiteralPath $source -Raw | ConvertFrom-Json
    if ($json.name) { $json.name = Get-English ([string]$json.name) }
    foreach ($property in $json.PSObject.Properties) {
        if ($property.Name -ne 'name' -and $property.Name -ne 'outfits' -and $property.Value.name) {
            $property.Value.name = Get-English ([string]$property.Value.name)
        }
    }
    if ($sex -eq 'female') {
        $json.name = "Women's outfits"
        $outfitNames = @{
            'MariaClothingDancer'='Dancer'; 'MariaClothingFarmer'='Farm slave';
            'MariaClothingFetish'='Fetish'; 'MariaClothingGuard'='Slave guard';
            'MariaClothingHighPriestess'='High priestess'; 'MariaClothingKitty'='Kitten';
            'MariaClothingMaster'='Mistress'; 'MariaClothingPimp'='Pimp';
            'MariaClothingPony'='Ponygirl'; 'MariaClothingPriest'='Temple prostitute';
            'MariaClothingPrisoner'='Prisoner'; 'MariaClothingSlave'='Slave';
            'MariaClothingStaff'='Assistant'; 'MariaClothingSuccubus'='Succubus';
            'MariaClothingWedding'='Bride'; 'MariaClothingWench'='Wench';
            'MariaClothingWhore'='Prostitute'
        }
    } else {
        $json.name = "Men's outfits"
        $outfitNames = @{
            'MariaClothingGuard'='Slave guard'; 'MariaClothingMaster'='Master';
            'MariaClothingPimp'='Pimp'; 'MariaClothingPrisoner'='Prisoner';
            'MariaClothingSlave'='Slave'; 'MariaClothingStaff'='Assistant'
        }
    }
    foreach ($entry in $outfitNames.GetEnumerator()) {
        $json.($entry.Key).name = $entry.Value
    }
    $destination = Join-Path $storageOut $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $destination) | Out-Null
    Write-JsonUtf8NoBom $destination $json
}

$defaultsSource = Join-Path $baseMod 'SKSE\Plugins\StorageUtilData\MariaDefaults.json'
$defaults = Get-Content -LiteralPath $defaultsSource -Raw | ConvertFrom-Json
$defaults.string.playername = Get-English ([string]$defaults.string.playername)
Write-JsonUtf8NoBom (Join-Path $storageOut 'MariaDefaults.json') $defaults

$uiFixes = @{
    'MariaBase_english.txt' = [ordered]@{
        '$ME_PIMPCAMSWITCH'='Pimp camera'; '$ME_PIMPHORSE'='Pimp horse';
        '$ME_CAST_SPECTATORS_MALE'='Invite male spectators'; '$ME_MASTERMGRMENU'='Owner manager...';
        '$ME_OPEN_MANAKIN'='Open inventory'; '$ME_POTENTIAL_CUSTOMER'='Potential owner';
        '$ME_SAVE_OUTFIT_AS'='Save as new outfit...'
    };
    'MariaProstitution_english.txt' = [ordered]@{
        '$MEP_FOLLOWER_CHANGE_TASTES'='Change preferences...'; '$MEP_SHAVE_LEGS'='Shave legs'
    }
}
foreach ($fileName in $uiFixes.Keys) {
    $source = Join-Path $baseMod "interface\translations\$fileName"
    $lines = [Collections.Generic.List[string]](Get-Content -LiteralPath $source)
    $seen = @{}
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^(\$[^\t]+)\t') {
            $key = $Matches[1]
            $seen[$key] = $true
            if ($uiFixes[$fileName].Contains($key)) {
                $lines[$i] = $key + "`t" + $uiFixes[$fileName][$key]
            }
        }
    }
    foreach ($entry in $uiFixes[$fileName].GetEnumerator()) {
        if (-not $seen.ContainsKey($entry.Key)) {
            $lines.Add($entry.Key + "`t" + $entry.Value)
        }
    }
    $sourceBytes = [IO.File]::ReadAllBytes($source)
    $encoding = if ($sourceBytes.Length -ge 2 -and $sourceBytes[0] -eq 0xFF -and $sourceBytes[1] -eq 0xFE) {
        [Text.UnicodeEncoding]::new($false, $true)
    } else {
        [Text.UTF8Encoding]::new($false)
    }
    [IO.File]::WriteAllLines((Join-Path $translationOut $fileName), $lines, $encoding)
}

$orderedCache = [ordered]@{}
foreach ($key in $cache.Keys | Sort-Object) { $orderedCache[$key] = $cache[$key] }
[IO.File]::WriteAllText($cachePath, ($orderedCache | ConvertTo-Json -Depth 10) + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
Write-Host "Generated English data translation with $($cache.Count) cached phrases."
