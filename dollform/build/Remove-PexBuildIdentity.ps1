param([Parameter(Mandatory=$true)][string]$ScriptsRoot)
$ErrorActionPreference = 'Stop'
function Read-PexString($reader) {
    $high = $reader.ReadByte()
    $low = $reader.ReadByte()
    return [Text.Encoding]::UTF8.GetString($reader.ReadBytes(($high * 256) + $low))
}
function Write-PexString($writer, [string]$value) {
    $data = [Text.Encoding]::UTF8.GetBytes($value)
    $writer.Write([byte][Math]::Floor($data.Length / 256))
    $writer.Write([byte]($data.Length % 256))
    $writer.Write($data)
}
foreach ($file in Get-ChildItem -LiteralPath $ScriptsRoot -Filter '*.pex') {
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    if ([BitConverter]::ToString($bytes,0,4) -ne 'FA-57-C0-DE') { throw "Unexpected Skyrim PEX header: $($file.Name)" }
    $reader = [IO.BinaryReader]::new([IO.MemoryStream]::new($bytes))
    $prefix = $reader.ReadBytes(16)
    $source = Read-PexString $reader
    $null = Read-PexString $reader
    $null = Read-PexString $reader
    $tail = $reader.ReadBytes([int]($reader.BaseStream.Length - $reader.BaseStream.Position))
    $reader.Dispose()
    $stream = [IO.MemoryStream]::new()
    $writer = [IO.BinaryWriter]::new($stream)
    $writer.Write($prefix)
    Write-PexString $writer (($source -split '[\\/]')[-1])
    Write-PexString $writer 'NEFARAM'
    Write-PexString $writer 'Build'
    $writer.Write($tail)
    $writer.Flush()
    [IO.File]::WriteAllBytes($file.FullName, $stream.ToArray())
    $writer.Dispose()
}
Write-Output 'PEX metadata normalized; bytecode and string tables preserved.'
