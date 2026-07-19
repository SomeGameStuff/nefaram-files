#!/usr/bin/env python3
"""Read-only Skyrim Crash Logger summarizer for MO2 setups."""

from __future__ import annotations

import argparse
import json
import os
import re
from pathlib import Path
from typing import Iterable


CRASH_RE = re.compile(r"crash-.*\.log$", re.IGNORECASE)
PLUGIN_IN_PARENS_RE = re.compile(r'\("([^"]+\.(?:esp|esm|esl))"\)', re.IGNORECASE)
DLL_RE = re.compile(r"\b([A-Za-z0-9_. -]+\.dll)(?:\+([0-9A-Fa-f]+))?", re.IGNORECASE)
FORM_RE = re.compile(r'\[0x([0-9A-Fa-f]{8})\]')


def default_skse_dir() -> Path:
    home = Path(os.environ.get("USERPROFILE", str(Path.home())))
    return home / "Documents" / "My Games" / "Skyrim Special Edition" / "SKSE"


def newest_file(paths: Iterable[Path]) -> Path | None:
    files = [p for p in paths if p.is_file()]
    return max(files, key=lambda p: p.stat().st_mtime, default=None)


def find_crash_log(skse_dir: Path) -> Path | None:
    if not skse_dir.exists():
        return None
    return newest_file(p for p in skse_dir.iterdir() if CRASH_RE.match(p.name))


def read_text(path: Path, limit_bytes: int = 8_000_000) -> str:
    data = path.read_bytes()
    if len(data) > limit_bytes:
        data = data[:limit_bytes]
    return data.decode("utf-8", errors="replace")


def first_line_matching(lines: list[str], needle: str) -> str | None:
    for line in lines:
        if needle in line:
            return line.strip()
    return None


def section(lines: list[str], header: str, stop_headers: set[str]) -> list[str]:
    out: list[str] = []
    inside = False
    for line in lines:
        stripped = line.strip()
        if stripped == header:
            inside = True
            continue
        if inside and stripped.endswith(":") and stripped in stop_headers:
            break
        if inside:
            out.append(line.rstrip())
    return out


def top_nonempty(items: Iterable[str], n: int) -> list[str]:
    result: list[str] = []
    for item in items:
        value = item.strip()
        if value:
            result.append(value)
        if len(result) >= n:
            break
    return result


def load_lines_if_exists(path: Path) -> list[str]:
    if not path.exists():
        return []
    return read_text(path).splitlines()


def parse_plugins(profile_dir: Path) -> dict[str, int]:
    plugins: dict[str, int] = {}
    for idx, line in enumerate(load_lines_if_exists(profile_dir / "plugins.txt"), start=1):
        value = line.strip()
        if not value or value.startswith("#"):
            continue
        value = value.lstrip("*")
        plugins[value.lower()] = idx
    return plugins


def parse_modlist(profile_dir: Path) -> dict[str, int]:
    mods: dict[str, int] = {}
    for idx, line in enumerate(load_lines_if_exists(profile_dir / "modlist.txt"), start=1):
        value = line.strip()
        if not value or value[0] not in "+-":
            continue
        mods[value[1:].lower()] = idx
    return mods


def find_mod_dirs_for_plugin(mo2_root: Path | None, plugin_names: Iterable[str]) -> dict[str, list[str]]:
    if not mo2_root:
        return {}
    mods_dir = mo2_root / "mods"
    if not mods_dir.exists():
        return {}
    wanted = {name.lower() for name in plugin_names}
    found = {name: [] for name in wanted}
    for plugin_path in mods_dir.rglob("*"):
        if not plugin_path.is_file():
            continue
        if plugin_path.name.lower() in wanted:
            try:
                rel = plugin_path.relative_to(mods_dir)
                mod_name = rel.parts[0]
            except Exception:
                mod_name = str(plugin_path.parent)
            found[plugin_path.name.lower()].append(mod_name)
    return found


def recent_saves(profile_dir: Path, crash_log: Path | None = None, count: int = 6) -> dict[str, list[dict[str, str | int]]]:
    saves_dir = profile_dir / "saves"
    if not saves_dir.exists():
        return {"before_crash": [], "after_crash": []}
    files = sorted(saves_dir.glob("*.ess"), key=lambda p: p.stat().st_mtime, reverse=True)
    crash_time = crash_log.stat().st_mtime if crash_log else None
    before = [p for p in files if crash_time is None or p.stat().st_mtime <= crash_time]
    after = [p for p in files if crash_time is not None and p.stat().st_mtime > crash_time]

    def pack(selected: list[Path]) -> list[dict[str, str | int]]:
        return [
        {"name": p.name, "size": p.stat().st_size, "modified": format_mtime(p)}
            for p in selected[:count]
        ]

    return {"before_crash": pack(before), "after_crash": pack(after)}


def format_mtime(path: Path) -> str:
    import datetime as _dt

    return _dt.datetime.fromtimestamp(path.stat().st_mtime).strftime("%Y-%m-%d %H:%M:%S")


def nearby_skse_logs(skse_dir: Path, dlls: Iterable[str], count: int = 8) -> list[dict[str, str | int]]:
    if not skse_dir.exists():
        return []
    dll_stems = {Path(d).stem.lower() for d in dlls}
    candidates = []
    for p in skse_dir.glob("*.log"):
        stem = p.stem.lower()
        if stem.startswith("crash-"):
            continue
        if stem in dll_stems or any(stem.startswith(s) or s.startswith(stem) for s in dll_stems):
            candidates.append(p)
    if not candidates:
        candidates = sorted(skse_dir.glob("*.log"), key=lambda p: p.stat().st_mtime, reverse=True)[:count]
    else:
        candidates = sorted(candidates, key=lambda p: p.stat().st_mtime, reverse=True)[:count]
    return [{"name": p.name, "size": p.stat().st_size, "modified": format_mtime(p)} for p in candidates]


def analyze(args: argparse.Namespace) -> dict:
    skse_dir = Path(args.skse_dir).expanduser() if args.skse_dir else default_skse_dir()
    crash_log = Path(args.crash_log).expanduser() if args.crash_log else find_crash_log(skse_dir)
    if not crash_log or not crash_log.exists():
        raise SystemExit(f"No crash log found. Checked SKSE dir: {skse_dir}")

    text = read_text(crash_log)
    lines = text.splitlines()
    stop_headers = {
        "POSSIBLE RELEVANT OBJECTS:",
        "PROCESS INFO:",
        "THREAD CONTEXT (HEURISTIC):",
        "SYSTEM SPECS:",
        "CALL STACK ([P]robable / [S]tack scan):",
        "REGISTERS:",
        "STACK:",
        "MODULES:",
        "SKSE PLUGINS:",
        "PLUGINS:",
    }

    relevant = section(lines, "POSSIBLE RELEVANT OBJECTS:", stop_headers)
    call_stack = section(lines, "CALL STACK ([P]robable / [S]tack scan):", stop_headers)
    stack = section(lines, "STACK:", stop_headers)

    object_plugins = sorted(set(PLUGIN_IN_PARENS_RE.findall("\n".join(relevant + stack))))
    dlls = []
    for match in DLL_RE.finditer("\n".join(call_stack[:80] + stack[:160])):
        dll = re.sub(r"^0x[0-9A-Fa-f]+\s+", "", match.group(1).strip())
        dll = Path(dll).name
        if dll.lower() not in {d.lower() for d in dlls}:
            dlls.append(dll)

    named_objects = []
    for line in relevant + stack[:260]:
        if '"' in line and ("Character*" in line or "TESObject" in line or "PlayerCharacter" in line or "Name:" in line):
            named_objects.append(line.strip())
    named_objects = top_nonempty(named_objects, 20)

    forms = sorted(set(FORM_RE.findall("\n".join(relevant + stack[:350]))))

    mo2_root = Path(args.mo2_root).expanduser() if args.mo2_root else None
    profile_dir = None
    if mo2_root and args.profile:
        profile_dir = mo2_root / "profiles" / args.profile
    elif args.profile_dir:
        profile_dir = Path(args.profile_dir).expanduser()

    plugins = parse_plugins(profile_dir) if profile_dir else {}
    modlist = parse_modlist(profile_dir) if profile_dir else {}
    mod_dirs = find_mod_dirs_for_plugin(mo2_root, object_plugins) if mo2_root else {}

    plugin_hits = []
    for plugin in object_plugins:
        plugin_hits.append(
            {
                "plugin": plugin,
                "plugins_txt_line": plugins.get(plugin.lower()),
                "mod_dirs": mod_dirs.get(plugin.lower(), []),
            }
        )

    return {
        "crash_log": str(crash_log),
        "crash_log_modified": format_mtime(crash_log),
        "crash_time": first_line_matching(lines, "CRASH TIME:"),
        "game_version": first_line_matching(lines, "Skyrim SSE v"),
        "exception": first_line_matching(lines, "Unhandled exception"),
        "process_uptime": first_line_matching(lines, "Process Uptime:"),
        "memory": first_line_matching(lines, "PROCESS MEMORY:"),
        "gpu_memory": first_line_matching(lines, "GPU MEMORY:"),
        "possible_relevant_objects": top_nonempty(relevant, 35),
        "call_stack_top": top_nonempty(call_stack, 35),
        "dlls_in_stack": dlls[:30],
        "named_objects": named_objects,
        "forms_seen": forms[:40],
        "plugins_from_objects": plugin_hits,
        "profile_dir": str(profile_dir) if profile_dir else None,
        "modlist_entries_loaded": len(modlist),
        "recent_saves": recent_saves(profile_dir, crash_log) if profile_dir else {"before_crash": [], "after_crash": []},
        "nearby_skse_logs": nearby_skse_logs(skse_dir, dlls),
    }


def print_text(report: dict) -> None:
    print(f"Crash log: {report['crash_log']}")
    print(f"Modified: {report['crash_log_modified']}")
    for key in ["crash_time", "game_version", "exception", "process_uptime", "memory", "gpu_memory"]:
        if report.get(key):
            print(report[key])

    def block(title: str, values: list) -> None:
        if not values:
            return
        print(f"\n{title}:")
        for item in values:
            if isinstance(item, dict):
                print("  - " + json.dumps(item, ensure_ascii=False))
            else:
                print(f"  - {item}")

    block("Possible relevant objects", report["possible_relevant_objects"])
    block("Named objects", report["named_objects"])
    block("Top call stack", report["call_stack_top"])
    block("DLLs in stack", report["dlls_in_stack"])
    block("Plugins from objects", report["plugins_from_objects"])
    if report["recent_saves"].get("before_crash"):
        block("Recent saves before crash", report["recent_saves"]["before_crash"])
    if report["recent_saves"].get("after_crash"):
        block("Newer saves after crash", report["recent_saves"]["after_crash"])
    block("Nearby SKSE logs", report["nearby_skse_logs"])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--crash-log", help="Specific Crash Logger report to analyze")
    parser.add_argument("--skse-dir", help="SKSE documents log directory")
    parser.add_argument("--mo2-root", help="MO2 root, e.g. C:\\games\\nefaram")
    parser.add_argument("--profile", help="MO2 profile name under <mo2-root>\\profiles")
    parser.add_argument("--profile-dir", help="Explicit MO2 profile directory")
    parser.add_argument("--json", action="store_true", help="Emit JSON")
    args = parser.parse_args()

    report = analyze(args)
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print_text(report)


if __name__ == "__main__":
    main()
