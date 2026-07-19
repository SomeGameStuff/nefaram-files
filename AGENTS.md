# NEFARAM — Agent Guide

Canonical knowledge for AI agents (Claude Code, OpenAI Codex) working on this Skyrim
modding setup. `CLAUDE.md` in this repo and in `C:\games\nefaram` are symlinks to this
file — edit here, never in the symlink copies.

## What this is

- **NEFARAM**: a Wabbajack-installed Skyrim SE/AE (game build **1.6.1170**, SKSE
  `skse64_1_6_1170`) modlist — ~2,237 MO2 mods, ~1,900 plugin lines — plus ~20
  locally-developed add-on mods sourced from this repository.
- Two working areas, never interchangeable:

| | Path | Role |
|---|---|---|
| **Runtime** | `C:\games\nefaram` | Portable MO2 instance. Installed, runnable state. Reference/packaging inspection only. |
| **Source of record** | `C:\Users\antho\nefaram-files` | This git repo (GitHub `SomeGameStuff/nefaram-files`). All edits, commits, tags, releases. |

Release artifacts go to `C:\Users\antho\nefaram-files\artifacts`.

## Golden rules

1. **Never edit an installed base mod** under `C:\games\nefaram\mods\`. All changes ship
   as separate patch/add-on MO2 mods sourced from this repo.
2. **Never package or publish from `C:\games\nefaram`.** Releases are built from
   repo folders only (`nefaram-mod-release` skill).
3. **Back up `modlist.txt` / `plugins.txt`** (timestamped copy next to the file) before
   any programmatic edit. The profile already accumulates these; keep the habit.
4. **Compile stubs stay out of runtime.** `build-stubs\`, `vanilla-source\`, logs, and
   tooling are never copied into an MO2 mod folder or release zip.
5. **Prefer reversible changes**: loose-`.pex` overrides, JSON config, MCM toggles over
   ESP edits; copies of saves, never in-place edits.
6. Other MO2 instances exist on this machine (e.g. `E:\Modlists\N.Y.A`). Confirm you
   are in the NEFARAM instance before touching anything.

## Runtime path map

| What | Path |
|---|---|
| MO2 root (portable) | `C:\games\nefaram` (`portable.txt`, instance-local) |
| Active profile | `C:\games\nefaram\profiles\NEFARAM` (only profile) |
| Profile INIs | `profiles\NEFARAM\Skyrim.ini` etc. — Papyrus logging toggles live here |
| Saves | `profiles\NEFARAM\saves` (profile-local; `WABBAJACK_INCLUDE_SAVES` marker) |
| Installed mods | `C:\games\nefaram\mods` (2,237 folders) |
| Game Root (stock game) | `C:\games\nefaram\Game Root` — `SkyrimSE.exe`, SKSE, **ENB + ReShade live here only** |
| Real Steam game | `C:\games\steamapps\common\Skyrim Special Edition` — Papyrus Compiler lives here only |
| MO2 logs | `C:\games\nefaram\logs` |
| Crash dumps (MO2) | `C:\games\nefaram\crashDumps` |
| Crash Logger reports | `Documents\My Games\Skyrim Special Edition\SKSE\crash-*.log` |
| Papyrus logs | `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` |
| Overwrite | `C:\games\nefaram\overwrite` — inspect before assuming output is lost |

Secrets at MO2 root: `kimi.bat` (API key), `.github-token`. Never commit, package, or
paste them. The `.git` dir at MO2 root is an empty shell, not a repo — ignore it.

## Tools (`C:\games\nefaram\tools`)

SSEEdit (xEdit), ReSaver, DynDOLOD, xLODGen, Synthesis, PGPatcher, Cathedral Assets
Optimizer, BethINI (Bethini Pie), ENB Manager, DAR Explorer, ACMOS Road Generator, PCA,
ModGroupInstaller. Check here before assuming a tool is missing.

## Papyrus toolchain

- Compiler: `C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe`
- Vanilla script source (canonical, durable): `C:\Users\antho\nefaram-files\tools\vanilla-source\Source\Scripts`
  (includes `TESV_Papyrus_Flags.flg`). Legacy copy at `C:\tmp\skyrim-scripts-source` —
  `C:\tmp` is volatile, do not rely on it.
- Typical invocation per script:
  `PapyrusCompiler.exe <script>.psc -f="<vanilla>\TESV_Papyrus_Flags.flg" -i="<src>;<vanilla>" -o="<out>"`
- Expect `0 error(s), 0 warning(s)`. Minimal local stubs for external symbols go in the
  project's `build-stubs\`.

## xEdit / ESP tooling

- SSEEdit: `C:\games\nefaram\tools\SSEEdit\SSEEdit.exe`
- Headless pattern: `SSEEdit.exe -D:'<Data dir>' -IKnowWhatImDoing -nobuildrefs -autoload -script:'<script>.pas' -autoexit`
  (or explicit plugin list instead of `-autoload` for small jobs).
- xEdit launched outside MO2 does **not** see MO2's virtual Data — pass `-D:` and/or an
  explicit plugin list, or build a scratch `Data` dir with the needed plugins copied in.
- For generated plugins this repo uses Mutagen (`dotnet run`) generators
  (e.g. `Spatial Storage Rings Work\ssr-mutagen-build`, NVLC `MutagenGenerator`) or
  xEdit Pascal scripts; keep generators in the repo.
- `Game.GetFormFromFile` needs the plugin-local FormID: strip the load-order byte
  (`0x05000806` → `0x000806`).

## MO2 conventions in this setup

- Local mods use `[NoDelete] NNN <Name>` in the left pane (numbered priority slots:
  010 HVL, 360 LEA, 390 SPERG patch, 400 Lola voices, 500 SSR, 600–612 Lola patches,
  unnumbered for the rest). `[NoDelete]` = survive list-wide cleanups.
- `modlist.txt` order can appear **reversed** from the MO2 UI left pane. `+` = enabled,
  `-` = disabled. Verify ordering in MO2 after scripted edits.
- A loose file in a higher-priority mod wins over BSA-packed copies — the standard
  override mechanism for script patches here.
- `plugins.txt` entries are `*`-prefixed when enabled.

## Local mod registry

| Repo folder | Installed MO2 mod | Plugin | Notes |
|---|---|---|---|
| `RaceMenu Appearance Slots` | `[NoDelete] RaceMenu Appearance Slots` | `RMAppSlots.esp` | `ras_*` scripts; deps RaceMenu, SkyUI, PapyrusUtil, PO3 PE |
| `RaceMenu Appearance Slots - Vampire Lord Bridge` | `[NoDelete] RaceMenu Appearance Slots - Vampire Lord Bridge` | (overrides `HNVVampLord.pex`) | Must out-prioritize Humanoid Vampire Lords |
| `SPERG-Script-Lag-Patch` | `[NoDelete] 390 SPERG Script Lag Patch` | none (loose pex) | Whitelists SPERG speed refresh; see `docs/known-issues.md` |
| `SexLab Humanoid Vampire Lord Female Player Patch` | `[NoDelete] SexLab Humanoid Vampire Lord Female Player Patch` | none | `sslActorLibrary.pex` override, after SexLab Framework |
| `Spatial Storage Rings Work` | `[NoDelete] 500 Spatial Storage Rings` | `Spatial Storage Rings.esp` | `SSR_*`; Build-CompilePapyrus.ps1; Mutagen + xEdit regen |
| `lola-expanded-addons` | `[NoDelete] 360 Lola Expanded Addons` | `LolaExpandedAddons.esp` | `cfl_*` + `vkj*` overrides; Config.json + HairPool.json |
| `lola-milk-economy` | `[NoDelete] Lola Milk Economy` | none | JSON config `SKSE\Plugins\LolaMilkEconomy` |
| `lola-transformative-elixirs` | `[NoDelete] Lola Transformative Elixirs` | none | Patches upstream `TransformativeElixirs.esp` behavior |
| `dollform` | `[NoDelete] Bodymorph Alterations` | `Dollform.esp` | `cfl_*form*`; Build-And-Validate.ps1; `bat BodymorphStartMCM` repair |
| `feral` | `Feral - Bodymorph Addon` | `Feral.esp` (build-output) | `cfl_Feral*`; v5 progression complete 2026-07 |
| `NEFARAM - Vampire Lord Consequences` | `NEFARAM - Vampire Lord Consequences` | generated (xEdit/Mutagen) | Plan: `VampireLordConsequencesPlan.md` at MO2 root |
| `NEFARAM-Flawed-Wardrobe` | `NEFARAM - Flawed Wardrobe` | 4× `*_Catalogue*.esl` | |
| `practical-defeat-humanoid-robbery-only` | `NEFARAM - Practical Defeat Humanoid Robbery Only` | none | |
| `Lola DOM Handler Patch` | `[NoDelete] 600 Lola DOM Handler Patch` | `Lola DOM Handler Patch.esp` | |
| `LolaOutfitGracePatch` | `[NoDelete] 611 Lola Outfit Zone Grace Patch` | none | |
| `LolaVampireLordClothingRestrictionPatch` | `[NoDelete] 612 Lola Vampire Lord Clothing Restriction Patch` | none | `vkjarmorrestriction.pex` override |
| — | `[NoDelete] 610 Lola Vampire Lord Outfit Task Patch` | ? | ⚠ Installed mod with no repo source found — locate or recreate |
| `MCM Recorder Hard Mode` | (played via upstream MCM Recorder) | none | Documentation only |
| `ToH Typo Patch` | not currently in `mods\` (verify) | `ToH Typo Patch.esp` | Packaged zip in repo root |
| `cfl-lolaaddon-outfits` | n/a | — | Outfit-config notes for upstream `cfl_LolaAddon_` |
| `BNPPlayerSkinDllPoc` | relates to `[BnP] Player Toggle Source` + `[Patch] BnP Player Nord Vampire Toggle` | — | PoC; BNP* generators in MO2 `__temp__` |

Tooling in `tools/`: ModGroupInstaller, ModListCompare, NexusFileResolver,
vanilla-source (gitignored). Shared agent skills in `agent-skills/`.

## Skills (shared by both agents)

Live in `agent-skills/`, symlinked into `~/.claude/skills` and `~/.codex/skills`:

- `skyrim-mo2-papyrus-modding` — building/patching mods (Papyrus, loose overrides, config)
- `skyrim-papyrus-triage` — script lag / save backlog diagnosis, ReSaver helpers
- `skyrim-crash-analyzer` — crash log analysis (`scripts/analyze_skyrim_crash.py`)
- `nefaram-mod-release` — packaging + GitHub releases (`scripts/package-nefaram-mod.ps1`)

## Knowledge docs (`docs/`)

- `docs/script-prefix-map.md` — script prefix → owning mod (ownership gotchas)
- `docs/known-issues.md` — fixed bugs, root causes, where the fix lives
- `docs/environment-quirks.md` — MO2/xEdit/Papyrus gotchas for this machine
- `docs/own-mods-api.md` — plugins, configs, entry points of our own mods

## Research artifacts (at MO2 root, not in git)

`current-mods-july-2-2026.txt` (modlist snapshot), `Nefaram_Ultimate_Overhaul_*`
(compare vs Ultimate Overhaul list), `SkinnyPeTe_*` (compare vs SkinnyPeTe list),
`Nefaram_Ultimate_Overhaul_graphics_breakdown.md`, `VampireLordConsequencesPlan.md`.
Regenerate modlist snapshots with ModListCompare rather than trusting old ones.
