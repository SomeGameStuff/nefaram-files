# Environment Quirks (this machine, this setup)

## MO2

- **modlist.txt is reversed vs the UI.** The MO2 left pane shows high-priority mods
  lower; `modlist.txt` line order can look backwards. After scripted edits, verify in
  MO2 before launching anything.
- `+Name` = enabled, `-Name` = disabled in `modlist.txt`. `*Plugin.esp` = enabled in
  `plugins.txt`.
- **`[NoDelete] NNN` convention**: our local mods are renamed with a `[NoDelete]`
  prefix and a priority number (010, 360, 390, 400, 500, 600–612) so automated
  list-wide cleanups leave them alone and their relative order is explicit.
- Always timestamp-backup `modlist.txt`/`plugins.txt` before scripted edits; the
  profile dir keeps the history (`modlist.before-*.txt`, `*.bak`).
- The instance is **portable** (`portable.txt`): all paths are instance-local; saves
  live in the profile (`WABBAJACK_INCLUDE_SAVES`).
- **Overwrite is not a trash can**: tool output (Bodyslide, LOD gen, MCM Recorder)
  lands in `overwrite\` — check there before rerunning a tool.

## Game layout

- The game runs from `<mo2-root>\Game Root` (stock-game copy). **ENB, ReShade,
  SKSE, and `Skyrim.ccc` exist only there.** The real Steam dir
  (`<game-install>`) is untouched except it hosts
  the **Papyrus Compiler**.
- INIs are profile-local: `<mo2-root>\profiles\NEFARAM\Skyrim.ini` —
  Papyrus logging (`bEnableLogging` etc.) is toggled there, not in Documents.
- BethINI backups accumulate under `profiles\NEFARAM\Bethini Pie backups`.

## Papyrus

- Vanilla source canonical copy: `nefaram-files\tools\vanilla-source\Source\Scripts`
  (with `TESV_Papyrus_Flags.flg`). `<temporary-vanilla-source>` is a legacy copy —
  `<temporary>` gets cleaned; never make it the only copy.
- `Game.GetFormFromFile`: strip the load-order byte from xEdit FormIDs
  (`0x05000806` → `0x000806`) or use `Game.GetModByName` + light-plugin rules.
- Papyrus INI "tuning" masks symptoms; a script scheduling work every frame will
  still flood the VM. Fix the script (see SPERG entry in `known-issues.md`).

## xEdit / SSEEdit

- Launched outside MO2, xEdit reads the **real** Data dir and AppData plugin list,
  not MO2's virtual one. Use `-D:'<scratch Data>'` plus an explicit plugin list (or
  `-autoload` with a fully staged dir), `-IKnowWhatImDoing -nobuildrefs -script:...
  -autoexit` for headless runs.
- Keep generator projects (Mutagen `.csproj`, `.pas` scripts) in the repo next to the
  mod they build, not in `<temporary>`.

## Saves

- `.ess` + matching `.skse` co-save are a pair — copy both, never overwrite originals;
  cleaned saves go to new filenames and get re-inspected before loading.
- ReSaver jar: `<mo2-root>\tools\ReSaver\target\ReSaver.jar` (usable headless via
  the helpers in the `skyrim-papyrus-triage` skill).

## Secrets / housekeeping

- `<mo2-root>\kimi.bat` (API key) and `<mo2-root>\.github-token` are
  plaintext secrets — exclude from commits, zips, screenshots.
- `<mo2-root>\.git` is an empty directory, not a repository. Ignore it (or
  delete it); the real repo is `nefaram-files`.
