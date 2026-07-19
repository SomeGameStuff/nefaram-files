param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [Parameter(Mandatory=$true)]
    [string]$Version,

    [string]$OutputDir = "",
    [string]$PackageName = "",
    [switch]$IncludeSource,
    [switch]$Publish,
    [string]$Repo = "",
    [string]$Tag = "",
    [string]$Title = "",
    [string]$Notes = "",
    [switch]$Draft,
    [switch]$Prerelease
)

$ErrorActionPreference = "Stop"

$skillDir = Split-Path -Parent $PSScriptRoot
$skillsDir = Split-Path -Parent $skillDir
$repoRoot = Split-Path -Parent $skillsDir

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $repoRoot "artifacts"
}

function Assert-InAllowedRoot {
    param([string]$Path)
    $resolved = (Resolve-Path -LiteralPath $Path).Path
    $allowed = @(
        $repoRoot,
        "C:\Games\nefaram\mods"
    )
    foreach ($root in $allowed) {
        if ($resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $resolved
        }
    }
    throw "Refusing to package outside expected NEFARAM roots: $resolved"
}

function Should-Exclude {
    param(
        [string]$RelativePath,
        [bool]$IncludeSourceFiles
    )
    $normalized = $RelativePath -replace "\\", "/"
    $parts = $normalized -split "/"
    $top = $parts[0]
    $excludedDirs = @(".git", ".github", "Build", "build-stubs", "CompileStubs", "vanilla-source", "tools", "logs", "__temp__")
    if (!$IncludeSourceFiles) {
        $excludedDirs += "Source"
    }
    if ($excludedDirs -contains $top) {
        return $true
    }
    if (!$IncludeSourceFiles -and $normalized.EndsWith(".psc", [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }
    foreach ($suffix in @(".log", ".tmp", ".bak", ".orig", ".patch", ".ps1", ".SKILL.md")) {
        if ($normalized.EndsWith($suffix, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

$project = Assert-InAllowedRoot $ProjectPath
if (!(Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}
$output = (Resolve-Path -LiteralPath $OutputDir).Path

if ([string]::IsNullOrWhiteSpace($PackageName)) {
    $PackageName = Split-Path -Leaf $project
}
if ([string]::IsNullOrWhiteSpace($Tag)) {
    $Tag = "$PackageName-v$Version"
}
if ([string]::IsNullOrWhiteSpace($Title)) {
    $Title = "$PackageName v$Version"
}

$zipPath = Join-Path $output "$PackageName-$Version.zip"
$stageRoot = Join-Path $output "_stage-$PackageName-$Version"

if (Test-Path -LiteralPath $stageRoot) {
    $stageResolved = (Resolve-Path -LiteralPath $stageRoot).Path
    if (!$stageResolved.StartsWith($output, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove stage outside output directory: $stageResolved"
    }
    Remove-Item -LiteralPath $stageResolved -Recurse -Force
}
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

New-Item -ItemType Directory -Path $stageRoot | Out-Null

$files = Get-ChildItem -LiteralPath $project -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($project.Length).TrimStart("\", "/")
    -not (Should-Exclude -RelativePath $relative -IncludeSourceFiles:$IncludeSource.IsPresent)
}

foreach ($file in $files) {
    $relative = $file.FullName.Substring($project.Length).TrimStart("\", "/")
    $dest = Join-Path $stageRoot $relative
    $destDir = Split-Path -Parent $dest
    if (!(Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }
    Copy-Item -LiteralPath $file.FullName -Destination $dest -Force
}

Compress-Archive -Path (Join-Path $stageRoot "*") -DestinationPath $zipPath -Force
Remove-Item -LiteralPath $stageRoot -Recurse -Force

Write-Host "Created package: $zipPath"

if ($Publish) {
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if ($null -eq $gh) {
        throw "GitHub CLI 'gh' is not installed or not on PATH."
    }
    & gh auth status | Out-Host
    if ([string]::IsNullOrWhiteSpace($Repo)) {
        throw "-Repo owner/name is required when publishing."
    }
    & gh repo view $Repo | Out-Null
    $ghArgs = @("release", "create", $Tag, $zipPath, "--repo", $Repo, "--title", $Title)
    if (![string]::IsNullOrWhiteSpace($Notes)) {
        $ghArgs += @("--notes", $Notes)
    } else {
        $ghArgs += @("--generate-notes")
    }
    if ($Draft) {
        $ghArgs += "--draft"
    }
    if ($Prerelease) {
        $ghArgs += "--prerelease"
    }
    & gh @ghArgs
}
