[CmdletBinding()]
param(
    [string]$RuntimeModPath = '<mo2-root>\mods\[NoDelete] NEFARAM - World Wardrobe - Load Order Fix'
)

$ErrorActionPreference = 'Stop'
if (Get-Process -Name ModOrganizer,SkyrimSE -ErrorAction SilentlyContinue) { throw 'Close MO2 and Skyrim before deployment.' }
$projectRoot = $PSScriptRoot
$generator = Join-Path $projectRoot 'Generator\WorldWardrobeGenerator.csproj'
$output = Join-Path $projectRoot 'build-output'

dotnet run --project $generator --configuration Release
if ($LASTEXITCODE -ne 0) { throw "World Wardrobe generation failed with exit code $LASTEXITCODE." }

dotnet run --project $generator --configuration Release -- --validate
if ($LASTEXITCODE -ne 0) { throw "World Wardrobe validation failed with exit code $LASTEXITCODE." }

New-Item -ItemType Directory -Path $RuntimeModPath -Force | Out-Null
Get-ChildItem -LiteralPath $RuntimeModPath -Filter 'NEFARAM_WorldWardrobe_*.esp' -File -ErrorAction SilentlyContinue | Remove-Item -Force
foreach ($relative in @(
    'NEFARAM_WorldWardrobe_CID.ini',
    'zz_NEFARAM_WorldWardrobe_DISTR.ini',
    'coverage.csv',
    'coverage.md',
    'excluded.csv',
    'README.md'
)) {
    $installed = Join-Path $RuntimeModPath $relative
    if (Test-Path -LiteralPath $installed) { Remove-Item -LiteralPath $installed -Force }
}
$skyPatcherDirectory = Join-Path $RuntimeModPath 'SKSE\Plugins\SkyPatcher\leveledList\NEFARAM World Wardrobe'
$resolvedRuntime = [IO.Path]::GetFullPath($RuntimeModPath).TrimEnd('\')
$resolvedSkyPatcher = [IO.Path]::GetFullPath($skyPatcherDirectory)
if (!$resolvedSkyPatcher.StartsWith($resolvedRuntime + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe cleanup path.' }
if (Test-Path -LiteralPath $skyPatcherDirectory) { Remove-Item -LiteralPath $skyPatcherDirectory -Recurse -Force }

Copy-Item -Path (Join-Path $output '*') -Destination $RuntimeModPath -Recurse -Force
Write-Host "Deployed NEFARAM World Wardrobe to $RuntimeModPath"
