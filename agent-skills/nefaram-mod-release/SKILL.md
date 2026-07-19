---
name: nefaram-mod-release
description: Package NEFARAM Skyrim MO2 mod project folders into release ZIPs and optionally publish them as GitHub Releases. Use when asked to package a local NEFARAM mod project, create a distributable archive, tag a release, upload artifacts with gh, or set up or verify GitHub release publishing for these mods.
---

# NEFARAM Mod Release

## Workflow

1. Identify the project folder and runtime mod folder.
   - Always treat `C:\Users\antho\nefaram-files` as the source of record for source, commits, tags, and GitHub releases.
   - Prefer `C:\Users\antho\nefaram-files\<Project Name>` as the project source path.
   - Use `C:\Games\nefaram\mods\<MO2 Mod Name>` only as an installed runtime reference when the user explicitly wants to inspect or package the installed MO2 mod. Do not publish from `C:\Games\nefaram`.
   - Check git state before packaging. Do not include unrelated dirty changes in commits or release notes.

2. Verify release readiness.
   - Confirm compiled `.pex` files exist for changed Papyrus sources.
   - Confirm runtime config files are present under `SKSE\Plugins\...` when applicable.
   - Exclude compile-only material such as `build-stubs`, `vanilla-source`, logs, temporary dumps, and local tooling.
   - Exclude `Source\Scripts` by default unless the user explicitly wants a source package.

3. Resolve this skill's directory from the loaded `SKILL.md` path, then package with the bundled script:

```powershell
$skillDir = "<directory-containing-this-SKILL.md>"
& (Join-Path $skillDir "scripts\package-nefaram-mod.ps1") `
  -ProjectPath "C:\Users\antho\nefaram-files\lola-expanded-addons" `
  -Version "1.2.3"
```

Useful options:

```powershell
# Include Source\Scripts in the archive.
-IncludeSource

# Publish with GitHub CLI. Requires gh installed and authenticated.
-Publish -Repo "owner/repo" -Tag "lola-expanded-addons-v1.2.3" -Title "Lola Expanded Addons v1.2.3"

# Create draft or prerelease.
-Draft
-Prerelease
```

4. Publish only when GitHub setup is clear.
   - Use `gh auth status` to verify authentication.
   - Use `gh repo view <owner/repo>` to verify access.
   - If repo/tag naming is ambiguous, ask before publishing.
   - Prefer draft releases for first-time setup or uncertain release notes.

5. Report results.
   - Give the ZIP path and, if published, the GitHub release URL.
   - Mention excluded source/build folders when relevant.
   - Mention any uncommitted repo changes not included in the release.

## Defaults

- Output directory: `C:\Users\antho\nefaram-files\artifacts`
- Archive name: `<ProjectFolder>-<Version>.zip`
- Git tag default: `<ProjectFolder>-v<Version>`
- Runtime package excludes: `.git`, `.github`, `Source`, `build-stubs`, `vanilla-source`, `tools`, `logs`, `__temp__`, `*.log`, `*.tmp`, `*.bak`, `*.psc`

## GitHub Setup

If publishing is requested but unavailable:

```powershell
winget install GitHub.cli
gh auth login
gh repo create owner/repo --private --source "C:\Users\antho\nefaram-files" --remote origin
```

Do not create public repos or push releases without explicit user intent.
