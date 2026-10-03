param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePlugin,
    [Parameter(Mandatory = $true)]
    [string]$OutputPlugin
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-U16([byte[]]$Bytes, [int]$Offset) { [BitConverter]::ToUInt16($Bytes, $Offset) }
function Read-U32([byte[]]$Bytes, [int]$Offset) { [BitConverter]::ToUInt32($Bytes, $Offset) }
function Get-Sig([byte[]]$Bytes, [int]$Offset) { [Text.Encoding]::ASCII.GetString($Bytes, $Offset, 4) }

function Get-Range([byte[]]$Bytes, [int]$Offset, [int]$Length) {
    $result = New-Object byte[] $Length
    [void][Array]::Copy($Bytes, $Offset, $result, 0, $Length)
    return ,$result
}

function Set-U16([byte[]]$Bytes, [int]$Offset, [uint16]$Value) {
    [void][Array]::Copy([BitConverter]::GetBytes($Value), 0, $Bytes, $Offset, 2)
}

function Set-U32([byte[]]$Bytes, [int]$Offset, [uint32]$Value) {
    [void][Array]::Copy([BitConverter]::GetBytes($Value), 0, $Bytes, $Offset, 4)
}

function Add-Bytes([Collections.Generic.List[byte]]$List, [byte[]]$Bytes) {
    foreach ($b in $Bytes) { [void]$List.Add($b) }
}

function Add-Subrecord([Collections.Generic.List[byte]]$List, [string]$Signature, [byte[]]$Data) {
    Add-Bytes $List ([Text.Encoding]::ASCII.GetBytes($Signature))
    $len = New-Object byte[] 2
    Set-U16 $len 0 ([uint16]$Data.Length)
    Add-Bytes $List $len
    Add-Bytes $List $Data
}

function Get-Subrecords([byte[]]$Data) {
    $items = New-Object Collections.Generic.List[object]
    $offset = 0
    while ($offset + 6 -le $Data.Length) {
        $sig = Get-Sig $Data $offset
        $len = [int](Read-U16 $Data ($offset + 4))
        $offset += 6
        if ($offset + $len -gt $Data.Length) { throw "Malformed $sig subrecord" }
        $payload = Get-Range $Data $offset $len
        [void]$items.Add([pscustomobject]@{ Signature = $sig; Data = $payload })
        $offset += $len
    }
    return $items
}

function Find-Record([byte[]]$Bytes, [int]$Offset, [int]$End, [string]$WantedSignature, [uint32]$WantedFormID) {
    while ($Offset + 24 -le $End) {
        $sig = Get-Sig $Bytes $Offset
        $size = [int](Read-U32 $Bytes ($Offset + 4))
        if ($size -lt 0) { throw 'Negative record/group size' }
        if ($sig -eq 'GRUP') {
            if ($size -lt 24 -or $Offset + $size -gt $End) { throw 'Malformed GRUP' }
            $found = Find-Record $Bytes ($Offset + 24) ($Offset + $size) $WantedSignature $WantedFormID
            if ($null -ne $found) { return ,$found }
        } else {
            if ($Offset + 24 + $size -gt $End) { throw "Malformed $sig record" }
            $formId = Read-U32 $Bytes ($Offset + 12)
            if ($sig -eq $WantedSignature -and $formId -eq $WantedFormID) {
                return ,(Get-Range $Bytes $Offset (24 + $size))
            }
        }
        $Offset = if ($sig -eq 'GRUP') { $Offset + $size } else { $Offset + 24 + $size }
    }
    return $null
}

function Read-NullString([byte[]]$Bytes) {
    $length = 0
    while ($length -lt $Bytes.Length -and $Bytes[$length] -ne 0) { $length++ }
    return [Text.Encoding]::UTF8.GetString($Bytes, 0, $length)
}

$source = [IO.File]::ReadAllBytes($SourcePlugin)
if ((Get-Sig $source 0) -ne 'TES4') { throw 'Source is not a Skyrim plugin' }
$sourceHeaderSize = [int](Read-U32 $source 4)
$sourceHeaderData = Get-Range $source 24 $sourceHeaderSize

$sourceSubs = @(Get-Subrecords $sourceHeaderData)
$originalMasters = New-Object Collections.Generic.List[object]
$otherHeaderSubs = New-Object Collections.Generic.List[object]
$hedr = $null
$index = 0
while ($index -lt @($sourceSubs).Count) {
    $sub = $sourceSubs[$index]
    if ($sub.Signature -eq 'HEDR') {
        $hedr = $sub.Data
    } elseif ($sub.Signature -eq 'MAST') {
        if ($index + 1 -ge @($sourceSubs).Count -or $sourceSubs[$index + 1].Signature -ne 'DATA') {
            throw 'Malformed TES4 master list'
        }
        [void]$originalMasters.Add([pscustomobject]@{ Name = Read-NullString $sub.Data; Data = $sourceSubs[$index + 1].Data })
        $index++
    } elseif ($sub.Signature -ne 'DATA') {
        [void]$otherHeaderSubs.Add($sub)
    }
    $index++
}
if ($null -eq $hedr) { throw 'Source plugin has no HEDR' }

$quest = Find-Record $source 0 $source.Length 'QUST' ([uint32]0x05000828)
if ($null -eq $quest) { throw 'SOS_Quests record 05000828 was not found' }

$questFlags = Read-U32 $quest 8
if (($questFlags -band 0x00040000) -ne 0) { throw 'SOS_Quests is compressed; refusing to patch it blindly' }
$questDataSize = [int](Read-U32 $quest 4)
$questData = Get-Range $quest 24 $questDataSize
$questSubs = @(Get-Subrecords $questData)
$foundDNAM = $false
$newQuestData = New-Object Collections.Generic.List[byte]
foreach ($sub in $questSubs) {
    $payload = $sub.Data
    if ($sub.Signature -eq 'DNAM') {
        if ($payload.Length -lt 1) { throw 'SOS_Quests has an empty DNAM' }
        $oldFlags = $payload[0]
        if (($oldFlags -band 1) -eq 0) { throw ('SOS_Quests did not have Start Game Enabled set: 0x{0:X2}' -f $oldFlags) }
        $payload = $payload.Clone()
        $payload[0] = $oldFlags -band 0xFE
        $foundDNAM = $true
    }
    Add-Subrecord $newQuestData $sub.Signature $payload
}
if (-not $foundDNAM) { throw 'SOS_Quests has no DNAM subrecord' }

$newQuest = New-Object byte[] (24 + $newQuestData.Count)
[void][Array]::Copy($quest, 0, $newQuest, 0, 24)
Set-U32 $newQuest 4 ([uint32]$newQuestData.Count)
Set-U32 $newQuest 12 ([uint32]0x00000828)
[void][Array]::Copy($newQuestData.ToArray(), 0, $newQuest, 24, $newQuestData.Count)

$headerData = New-Object Collections.Generic.List[byte]
$hedrCopy = $hedr.Clone()
if ($hedrCopy.Length -ge 8) { Set-U32 $hedrCopy 4 ([uint32]1) }
Add-Subrecord $headerData 'HEDR' $hedrCopy
foreach ($master in $originalMasters) {
    Add-Subrecord $headerData 'MAST' ([Text.Encoding]::UTF8.GetBytes($master.Name + [char]0))
    Add-Subrecord $headerData 'DATA' $master.Data
}
if (@($originalMasters | Where-Object { $_.Name -ieq 'Skyrim On Skooma.esp' }).Count -eq 0) {
    Add-Subrecord $headerData 'MAST' ([Text.Encoding]::UTF8.GetBytes('Skyrim On Skooma.esp' + [char]0))
    Add-Subrecord $headerData 'DATA' (New-Object byte[] 8)
}
foreach ($sub in $otherHeaderSubs) { Add-Subrecord $headerData $sub.Signature $sub.Data }

$header = New-Object byte[] 24
[void][Array]::Copy([Text.Encoding]::ASCII.GetBytes('TES4'), 0, $header, 0, 4)
Set-U32 $header 4 ([uint32]$headerData.Count)
[void][Array]::Copy($source, 8, $header, 8, 16)
[void][Array]::Copy($headerData.ToArray(), 0, $header, 24, 0)

$group = New-Object byte[] 24
[void][Array]::Copy([Text.Encoding]::ASCII.GetBytes('GRUP'), 0, $group, 0, 4)
Set-U32 $group 4 ([uint32](24 + $newQuest.Length))
[void][Array]::Copy([Text.Encoding]::ASCII.GetBytes('QUST'), 0, $group, 8, 4)

$output = New-Object Collections.Generic.List[byte]
Add-Bytes $output $header
Add-Bytes $output $headerData.ToArray()
Add-Bytes $output $group
Add-Bytes $output $newQuest
[IO.File]::WriteAllBytes($OutputPlugin, $output.ToArray())

Write-Output ('Created ' + $OutputPlugin)
Write-Output ('Source quest flags: 0x{0:X2}; patched quest flags: 0x{1:X2}' -f $oldFlags, ($oldFlags -band 0xFE))
Write-Output ('Masters: ' + ((@($originalMasters | ForEach-Object { $_.Name }) + @('Skyrim On Skooma.esp')) -join ', '))
