# Maria Eden Location Menu Freeze Fix

NEFARAM loose-script compatibility patch for Maria Eden Prostitution `d2026.8.9`.

## Problem

Opening Maria Eden's Location Menu could hard-freeze Skyrim before the destination
list appeared. `MariaLocationManager.SelectJumpLocation()` synchronously iterated
every registered marker and called native `Location.GetKeywords()` for each one.
The observed freeze stopped Papyrus logging inside that pre-scan and left Skyrim
not responding with one CPU core saturated.

The affected save was inspected with ReSaver and was healthy: 8 active scripts,
no suspended stacks, 3 unattached instances, and no script backlog.

## Fix

The loose `MariaLocationManager.pex` override removes the unsafe all-location
keyword pre-scan. It exposes the brothel and slave-location categories from the
presence of Maria Eden's installed location plugins:

- `MariaWhoreLocations.esp`
- `MariaSlaveLocations.esp`

Selecting a category still uses Maria Eden's original `GetLocations()` filtering,
so destination selection and teleport behavior remain unchanged.

## Installation

Install `[NoDelete] Maria Eden Location Menu Freeze Fix` after
`MariaEdenProstitution` and its other loose-script patches in the MO2 left pane.
No plugin is required.

This patch is safe to add to an existing save. Load a save made before triggering
the frozen menu and test **Numpad Enter → Location Menu**.

## Build

Run `Build-And-Deploy.ps1`. A successful build reports `0 error(s), 0 warning(s)`
and deploys only the compiled PEX plus this README. Compile-only stubs stay in the
source project and are never shipped.
