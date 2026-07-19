# Converts the agent-doc hardlinks into true symlinks.
# Canonical file: C:\Users\antho\nefaram-files\AGENTS.md (git-tracked).
# Link names:    nefaram-files\CLAUDE.md, C:\games\nefaram\CLAUDE.md, C:\games\nefaram\AGENTS.md
#
# Symlink creation needs EITHER Windows Developer Mode enabled
# (Settings > System > For developers) OR an elevated shell.
# Until then, plain hardlinks (created by any agent) keep the four names in sync —
# but only until AGENTS.md is rewritten by an editor that saves via delete+recreate,
# which breaks hardlinks. Re-run this script (or re-hardlink) after that happens.

$repo   = 'C:\Users\antho\nefaram-files'
$mo2    = 'C:\games\nefaram'
$target = Join-Path $repo 'AGENTS.md'

if (-not (Test-Path $target)) { throw "Canonical file missing: $target" }

$links = @(
  @{ Path = (Join-Path $repo 'CLAUDE.md'); Target = 'AGENTS.md' }  # relative, stays valid if repo moves
  @{ Path = (Join-Path $mo2  'CLAUDE.md'); Target = $target }
  @{ Path = (Join-Path $mo2  'AGENTS.md'); Target = $target }
)

foreach ($l in $links) {
  if (Test-Path -LiteralPath $l.Path) { Remove-Item -LiteralPath $l.Path -Force }
  try {
    New-Item -ItemType SymbolicLink -Path $l.Path -Target $l.Target -ErrorAction Stop | Out-Null
    Write-Output "symlink: $($l.Path) -> $($l.Target)"
  } catch {
    # Fall back to a hardlink (no privilege required, same volume only)
    New-Item -ItemType HardLink -Path $l.Path -Target $target -ErrorAction Stop | Out-Null
    Write-Output "hardlink (no symlink privilege): $($l.Path)"
  }
}
