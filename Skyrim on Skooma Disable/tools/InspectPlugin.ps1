param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$OutPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$records = New-Object System.Collections.Generic.List[object]

function Read-UInt16([byte[]]$Bytes, [int]$Offset) {
    return [BitConverter]::ToUInt16($Bytes, $Offset)
}

function Read-UInt32([byte[]]$Bytes, [int]$Offset) {
    return [BitConverter]::ToUInt32($Bytes, $Offset)
}

function Read-Signature([byte[]]$Bytes, [int]$Offset) {
    return [Text.Encoding]::ASCII.GetString($Bytes, $Offset, 4)
}

function Read-NullString([byte[]]$Bytes, [int]$Offset, [int]$Length) {
    $end = $Offset
    $limit = $Offset + $Length
    while ($end -lt $limit -and $Bytes[$end] -ne 0) { $end++ }
    if ($end -le $Offset) { return '' }
    return [Text.Encoding]::UTF8.GetString($Bytes, $Offset, $end - $Offset)
}

function Get-DecompressedRecordData([byte[]]$Bytes, [int]$Offset, [int]$Length, [uint32]$Flags) {
    if (($Flags -band 0x00040000) -eq 0) {
        $data = New-Object byte[] $Length
        [void][Array]::Copy($Bytes, $Offset, $data, 0, $Length)
        return ,$data
    }

    # Skyrim compressed records contain an uncompressed-size prefix followed
    # by a zlib stream. DeflateStream wants the raw deflate payload here.
    $compressedLength = $Length - 4 - 2 - 4
    $input = New-Object IO.MemoryStream
    [void]$input.Write($Bytes, $Offset + 4 + 2, $compressedLength)
    $input.Position = 0
    $deflate = New-Object IO.Compression.DeflateStream($input, ([IO.Compression.CompressionMode]::Decompress))
    $output = New-Object IO.MemoryStream
    [void]$deflate.CopyTo($output)
    $deflate.Dispose()
    $input.Dispose()
    return ,$output.ToArray()
}

function Get-Subrecords([byte[]]$Data) {
    $offset = 0
    while ($offset + 6 -le $Data.Length) {
        $signature = Read-Signature $Data $offset
        $length = Read-UInt16 $Data ($offset + 4)
        $offset += 6
        if ($offset + $length -gt $Data.Length) { break }
        $payload = New-Object byte[] $length
        [void][Array]::Copy($Data, $offset, $payload, 0, $length)
        [pscustomobject]@{ Signature = $signature; Data = $payload }
        $offset = $offset + $length
    }
}

function Get-RecordSummary([byte[]]$Bytes, [int]$Offset, [string]$ParentGroup) {
    $signature = Read-Signature $Bytes $Offset
    $length = [int](Read-UInt32 $Bytes ($Offset + 4))
    $flags = Read-UInt32 $Bytes ($Offset + 8)
    $formId = Read-UInt32 $Bytes ($Offset + 12)
    $dataOffset = $Offset + 24
    if ($dataOffset + $length -gt $Bytes.Length) { return }

    $data = Get-DecompressedRecordData $Bytes $dataOffset $length $flags
    $edid = ''
    $full = ''
    $hasVmad = $false
    $strings = New-Object System.Collections.Generic.List[string]
    $subrecordNames = New-Object System.Collections.Generic.List[string]
    $keyData = New-Object System.Collections.Generic.List[string]
    foreach ($sub in (Get-Subrecords $data)) {
        [void]$subrecordNames.Add($sub.Signature)
        if ($sub.Signature -eq 'EDID') { $edid = Read-NullString $sub.Data 0 $sub.Data.Length }
        elseif ($sub.Signature -eq 'FULL') { $full = Read-NullString $sub.Data 0 $sub.Data.Length }
        elseif ($sub.Signature -eq 'VMAD') {
            $hasVmad = $true
            $ascii = [Text.Encoding]::ASCII.GetString($sub.Data)
            foreach ($match in [regex]::Matches($ascii, '[A-Za-z][A-Za-z0-9_]{2,}')) {
                if ($strings.Count -lt 40 -and $strings -notcontains $match.Value) { [void]$strings.Add($match.Value) }
            }
        }
        if ($sub.Signature -in @('DATA','DNAM','QSTA','QSTI','SCHR','ANAM','ALST','ALID','ALFR','ALED')) {
            $hexLength = [Math]::Min($sub.Data.Length, 64)
            [void]$keyData.Add($sub.Signature + '=' + [BitConverter]::ToString($sub.Data, 0, $hexLength))
        }
    }

    $records.Add([pscustomobject]@{
        Group = $ParentGroup
        Type = $signature
        RecordFlags = ('{0:X8}' -f $flags)
        FormID = ('{0:X8}' -f $formId)
        EDID = $edid
        FULL = $full
        HasVMAD = $hasVmad
        VMADStrings = ($strings -join ', ')
        Subrecords = ($subrecordNames -join ', ')
        KeyData = ($keyData -join ' | ')
    })
}

function Walk-Records([byte[]]$Bytes, [int]$Offset, [int]$End, [string]$Group) {
    while ($Offset + 24 -le $End) {
        $signature = Read-Signature $Bytes $Offset
        $length = [int](Read-UInt32 $Bytes ($Offset + 4))
        if ($length -lt 0) { break }
        if ($signature -eq 'GRUP') {
            if ($Offset + $length -gt $End -or $length -lt 24) { break }
            $label = Read-Signature $Bytes ($Offset + 8)
            Walk-Records $Bytes ($Offset + 24) ($Offset + $length) ($label)
        } else {
            if ($Offset + 24 + $length -gt $End) { break }
            Get-RecordSummary $Bytes $Offset $Group | Out-Null
        }
        $next = if ($signature -eq 'GRUP') { $Offset + $length } else { $Offset + 24 + $length }
        if ($next -le $Offset) { break }
        $Offset = $next
    }
}

$bytes = [IO.File]::ReadAllBytes($Path)
Walk-Records $bytes 0 $bytes.Length '' | Out-Null
if ($OutPath) {
    $records | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutPath -Encoding UTF8
} else {
    $records
}
