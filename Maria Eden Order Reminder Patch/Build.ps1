param(
    [string]$InputPlugin = $env:NEFARAM_MARIA_PLUGIN
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($InputPlugin)) { throw 'Pass -InputPlugin or set NEFARAM_MARIA_PLUGIN.' }
$root = $PSScriptRoot
$out = Join-Path $root 'build-output'
New-Item -ItemType Directory -Path $out -Force | Out-Null

dotnet run --project (Join-Path $root 'Generator\Generator.csproj') -c Release -- `
    $InputPlugin `
    (Join-Path $out 'NEFARAM_MariaEdenOrderReminders.esp') `
    (Join-Path $out 'reminder-audit.tsv')

if ($LASTEXITCODE -ne 0) { throw "Generator failed with exit code $LASTEXITCODE" }
