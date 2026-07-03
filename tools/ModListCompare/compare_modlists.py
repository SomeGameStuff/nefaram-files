#!/usr/bin/env python3
import argparse
import csv
import difflib
import re
from collections import defaultdict
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path


ARCHIVE_EXTENSIONS = {".zip", ".7z", ".rar", ".fomod"}
DEFAULT_DOWNLOAD_DIRS = [
    Path.home() / "Downloads",
    Path(r"E:\Games\Tsukiro2\Downloads"),
]
LOW_VALUE_TOKENS = {
    "skyrim", "special", "edition", "mod", "mods", "patch", "fix", "fixed", "update", "updated",
    "version", "main", "file", "files", "all", "one", "vanilla", "optimized", "remastered",
}


@dataclass
class ModEntry:
    priority: int
    enabled: bool
    name: str
    category: str
    raw: str
    nexus_id: str = ""
    nexus_url: str = ""
    version: str = ""
    download_file: str = ""


@dataclass
class MatchResult:
    entry: ModEntry
    status: str
    matched_name: str
    score: float
    archive_path: str
    archive_score: float
    bucket: str


@lru_cache(maxsize=200_000)
def normalize_name(value: str) -> str:
    value = value.lower()
    value = re.sub(r"\[[^\]]+\]", " ", value)
    value = re.sub(r"\b(nexus|se|sse|ae|vr|le|fomod|cbbe|3ba|bhunp|unp|hdt|smp|bodyslide|body ?slide)\b", " ", value)
    value = re.sub(r"\bv?\d+(\.\d+){0,4}[a-z]?\b", " ", value)
    value = re.sub(r"\b\d{5,}\b", " ", value)
    value = re.sub(r"[^a-z0-9\s]", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()


@lru_cache(maxsize=200_000)
def token_sort(value: str) -> str:
    return " ".join(sorted(normalize_name(value).split()))


@lru_cache(maxsize=1_000_000)
def fuzzy_score(a: str, b: str) -> float:
    na = normalize_name(a)
    nb = normalize_name(b)
    if not na or not nb:
        return 0.0

    direct = difflib.SequenceMatcher(None, na, nb).ratio()
    sorted_ratio = difflib.SequenceMatcher(None, token_sort(a), token_sort(b)).ratio()
    a_tokens = set(na.split())
    b_tokens = set(nb.split())
    overlap = len(a_tokens & b_tokens) / max(len(a_tokens), len(b_tokens), 1)
    return max(direct, sorted_ratio, overlap)


def clean_mod_name(value: str) -> str:
    value = value.strip()
    value = re.sub(r"^\[NoDelete\]\s*", "", value, flags=re.IGNORECASE)
    value = re.sub(r"^\d+(\.\d+)?\s+", "", value)
    value = re.sub(r'^"|"$', "", value)
    return value.strip()


def parse_source_entries(path: Path) -> list[ModEntry]:
    first_line = path.read_text(encoding="utf-8-sig", errors="replace").splitlines()[0]
    if "," in first_line and "#Mod_Name" in first_line:
        return parse_csv_export(path)
    return parse_modlist(path)


def parse_csv_export(path: Path) -> list[ModEntry]:
    entries: list[ModEntry] = []
    category = "Uncategorized"
    with path.open("r", encoding="utf-8-sig", errors="replace", newline="") as f:
        reader = csv.DictReader(f)
        for fallback_priority, row in enumerate(reader):
            name = clean_mod_name(row.get("#Mod_Name", "") or row.get("Mod_Name", ""))
            if not name:
                continue

            row_category = (row.get("#Primary_Category", "") or row.get("Primary_Category", "")).strip()
            if name.lower().endswith("_separator"):
                category = name[:-10].strip() or row_category or category
                continue

            priority_text = row.get("#Mod_Priority", "") or row.get("Mod_Priority", "")
            try:
                priority = int(priority_text)
            except ValueError:
                priority = fallback_priority

            status = row.get("#Mod_Status", "") or row.get("Mod_Status", "")
            entries.append(ModEntry(
                priority=priority,
                enabled=not status.startswith("-"),
                name=name,
                category=category if category != "Uncategorized" else row_category or category,
                raw=",".join(row.values()),
                nexus_id=(row.get("#Nexus_ID", "") or row.get("Nexus_ID", "")).strip(),
                nexus_url=(row.get("#Mod_Nexus_URL", "") or row.get("Mod_Nexus_URL", "")).strip(),
                version=(row.get("#Mod_Version", "") or row.get("Mod_Version", "")).strip(),
                download_file=(row.get("#Download_File_Name", "") or row.get("Download_File_Name", "")).strip(),
            ))
    return entries


def parse_modlist(path: Path) -> list[ModEntry]:
    entries: list[ModEntry] = []
    category = "Uncategorized"
    priority = 0
    for raw in path.read_text(encoding="utf-8-sig", errors="replace").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line[0] not in "+-":
            continue

        enabled = line[0] == "+"
        name = clean_mod_name(line[1:])
        if name.lower().endswith("_separator"):
            category = name[:-10].strip() or category
            continue

        entries.append(ModEntry(priority, enabled, name, category, raw))
        priority += 1
    return entries


def local_names_from_mo2(mo2_root: Path, profile: str | None) -> list[str]:
    names: set[str] = set()
    mods_dir = mo2_root / "mods"
    if mods_dir.exists():
        names.update(path.name for path in mods_dir.iterdir() if path.is_dir())

    profile_dir = mo2_root / "profiles"
    if profile is None:
        ini = mo2_root / "ModOrganizer.ini"
        if ini.exists():
            selected = re.search(r"selected_profile=@ByteArray\(([^)]+)\)", ini.read_text(errors="replace"))
            if selected:
                profile = selected.group(1)
    if profile:
        modlist = profile_dir / profile / "modlist.txt"
        if modlist.exists():
            names.update(entry.name for entry in parse_modlist(modlist))

    return sorted(names, key=str.lower)


def index_archives(download_dirs: list[Path]) -> list[Path]:
    archives: list[Path] = []
    for directory in download_dirs:
        if not directory.exists():
            continue
        archives.extend(path for path in directory.iterdir() if path.is_file() and path.suffix.lower() in ARCHIVE_EXTENSIONS)
    return sorted(archives, key=lambda path: path.stat().st_mtime, reverse=True)


def find_archive(entry: ModEntry, archives: list[Path], threshold: float) -> tuple[Path | None, float]:
    if entry.download_file:
        for archive in archives:
            if archive.name.casefold() == entry.download_file.casefold():
                return archive, 1.0
        return None, 0.0

    best_path = None
    best_score = 0.0
    for archive in archives:
        archive_name = archive.stem
        score = fuzzy_score(entry.name, archive_name)
        if score > best_score:
            best_score = score
            best_path = archive
    return (best_path, best_score) if best_path and best_score >= threshold else (None, best_score)


def infer_bucket(entry: ModEntry) -> str:
    text = f"{entry.category} {entry.name}".lower()
    buckets = [
        ("armor-clothing", ["armor", "armour", "clothes", "clothing", "outfit", "dress", "robe", "boots", "gloves", "lingerie", "bikini"]),
        ("animations", ["animation", "slal", "ostim", "pose", "nemesis", "pandora", "fnis"]),
        ("adult-frameworks", ["sexlab", "devious", "zaz", "slavetats", "aroused"]),
        ("quests-followers", ["quest", "follower", "companion", "dialogue", "missives"]),
        ("ui", ["ui", "hud", "menu", "mcm", "skyui", "interface"]),
        ("graphics", ["texture", "mesh", "enb", "parallax", "landscape", "tree", "flora", "water", "lod"]),
        ("bugfix-utility", ["fix", "skse", "utility", "framework", "papyrus", "patch"]),
    ]
    for bucket, keywords in buckets:
        if any(keyword in text for keyword in keywords):
            return bucket
    return slugify(entry.category)


def slugify(value: str) -> str:
    value = re.sub(r"[^A-Za-z0-9]+", "-", value.lower()).strip("-")
    return value or "uncategorized"


def compare(source_entries: list[ModEntry], local_names: list[str], archives: list[Path], match_threshold: float, archive_threshold: float) -> list[MatchResult]:
    normalized_local = {normalize_name(name): name for name in local_names}
    token_index: dict[str, set[str]] = defaultdict(set)
    for local in local_names:
        for token in normalize_name(local).split():
            if len(token) > 2 and token not in LOW_VALUE_TOKENS:
                token_index[token].add(local)

    results: list[MatchResult] = []
    for entry in source_entries:
        norm = normalize_name(entry.name)
        if norm in normalized_local:
            results.append(MatchResult(entry, "Present", normalized_local[norm], 1.0, "", 0.0, infer_bucket(entry)))
            continue

        best_name = ""
        best_score = 0.0
        candidate_names: set[str] = set()
        for token in norm.split():
            if len(token) > 2 and token not in LOW_VALUE_TOKENS:
                candidate_names.update(token_index.get(token, set()))

        for local in candidate_names:
            score = fuzzy_score(entry.name, local)
            if score > best_score:
                best_score = score
                best_name = local

        if best_score >= match_threshold:
            results.append(MatchResult(entry, "FuzzyPresent", best_name, best_score, "", 0.0, infer_bucket(entry)))
            continue

        archive, archive_score = find_archive(entry, archives, archive_threshold)
        results.append(MatchResult(entry, "MissingWithArchive" if archive else "Missing", best_name, best_score, str(archive) if archive else "", archive_score, infer_bucket(entry)))
    return results


def write_outputs(results: list[MatchResult], out_dir: Path, manifest_archive_threshold: float) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    csv_path = out_dir / "comparison.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Priority", "Enabled", "Status", "SourceMod", "Category", "Bucket", "MatchedLocal", "Score", "ArchivePath", "ArchiveScore", "NexusID", "NexusURL", "DownloadFile"])
        for result in results:
            writer.writerow([
                result.entry.priority,
                "+" if result.entry.enabled else "-",
                result.status,
                result.entry.name,
                result.entry.category,
                result.bucket,
                result.matched_name,
                f"{result.score:.3f}",
                result.archive_path,
                f"{result.archive_score:.3f}" if result.archive_path else "",
                result.entry.nexus_id,
                result.entry.nexus_url,
                result.entry.download_file,
            ])

    missing = [result for result in results if result.status.startswith("Missing")]
    with (out_dir / "missing.md").open("w", encoding="utf-8") as f:
        f.write("# Missing Mods\n\n")
        f.write(f"Total missing: {len(missing)}\n\n")
        for bucket in sorted({result.bucket for result in missing}):
            group = [result for result in missing if result.bucket == bucket]
            f.write(f"## {bucket} ({len(group)})\n\n")
            for result in group:
                suffix = f" - archive candidate ({result.archive_score:.3f}): `{result.archive_path}`" if result.archive_path else ""
                nexus = f" - Nexus: {result.entry.nexus_url}" if result.entry.nexus_url else ""
                expected = f" - expected: `{result.entry.download_file}`" if result.entry.download_file and not result.archive_path else ""
                f.write(f"- {result.entry.name} ({result.entry.category}){suffix}{nexus}{expected}\n")
            f.write("\n")

    manifests_dir = out_dir / "manifests"
    manifests_dir.mkdir(exist_ok=True)
    for old_manifest in manifests_dir.glob("*.mods.txt"):
        old_manifest.unlink()

    for bucket in sorted({result.bucket for result in missing}):
        group = [result for result in missing if result.bucket == bucket]
        if not group:
            continue
        with (manifests_dir / f"{bucket}.mods.txt").open("w", encoding="utf-8") as f:
            f.write(f'separator "{bucket}"\n')
            for result in group:
                enabled = "+" if result.entry.enabled else "-"
                if result.archive_path and result.archive_score >= manifest_archive_threshold:
                    f.write(f'{enabled} local path="{result.archive_path}" install="{result.entry.name}"\n')
                elif result.archive_path:
                    f.write(f'# review archive-candidate score={result.archive_score:.3f}: {result.archive_path}\n')
                    f.write(f'# unresolved: {result.entry.name} ({result.entry.category})\n')
                else:
                    if result.entry.nexus_url:
                        f.write(f'# nexus page: {result.entry.nexus_url}\n')
                    if result.entry.download_file:
                        f.write(f'# expected archive: {result.entry.download_file}\n')
                    f.write(f'# unresolved: {result.entry.name} ({result.entry.category})\n')


def main() -> int:
    parser = argparse.ArgumentParser(description="Compare an external MO2 modlist against a local MO2 install.")
    parser.add_argument("--source-modlist", default=str(Path.home() / "Downloads" / "modlist.txt"))
    parser.add_argument("--mo2-root", default=r"C:\Games\nefaram")
    parser.add_argument("--profile", default=None)
    parser.add_argument("--out", default=str(Path(__file__).resolve().parent / "out"))
    parser.add_argument("--match-threshold", type=float, default=0.86)
    parser.add_argument("--archive-threshold", type=float, default=0.72)
    parser.add_argument("--manifest-archive-threshold", type=float, default=0.95)
    parser.add_argument("--download-dir", action="append", default=[])
    args = parser.parse_args()

    source_entries = parse_source_entries(Path(args.source_modlist))
    local_names = local_names_from_mo2(Path(args.mo2_root), args.profile)
    download_dirs = [Path(path) for path in args.download_dir] if args.download_dir else DEFAULT_DOWNLOAD_DIRS
    archives = index_archives(download_dirs)
    results = compare(source_entries, local_names, archives, args.match_threshold, args.archive_threshold)
    write_outputs(results, Path(args.out), args.manifest_archive_threshold)

    counts: dict[str, int] = {}
    for result in results:
        counts[result.status] = counts.get(result.status, 0) + 1
    print(f"Compared {len(source_entries)} source mods against {len(local_names)} local mods.")
    for status, count in sorted(counts.items()):
        print(f"{status}: {count}")
    print(f"Output: {Path(args.out).resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
