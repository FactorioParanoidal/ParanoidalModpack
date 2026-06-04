#!/usr/bin/env python3
"""Check the Factorio mod portal for newer versions of locally installed mods.

Reads each mod's local version from its info.json, queries the public mod
portal API (https://mods.factorio.com/api/mods/<name>), and reports which
mods have a newer release available for the target factorio_version.

No API key needed — the portal's read endpoints are public. Stdlib only.

Usage:
    python3 check_updates.py                 # check every installed mod
    python3 check_updates.py --enabled-only  # only mods enabled in mod-list.json
    python3 check_updates.py --all           # also list up-to-date / not-found mods
    python3 check_updates.py --target 2.0    # force a target factorio_version
"""

import argparse
import concurrent.futures
import functools
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

def find_mods_dir():
    """Locate the folder that holds the mod sub-folders.

    The script lives in <repo>/tools/, so the mods usually sit in
    <repo>/mods/. We also handle being dropped straight into a Factorio mods
    directory. Preference: a dir with mod-list.json, else one that actually
    contains */info.json. Override with --mods-dir.
    """
    here = Path(__file__).resolve().parent
    candidates = [here, here / "mods", here.parent, here.parent / "mods"]
    for candidate in candidates:
        if (candidate / "mod-list.json").exists():
            return candidate
    for candidate in candidates:
        if any(candidate.glob("*/info.json")):
            return candidate
    return here.parent


MODS_DIR = find_mods_dir()
API = "https://mods.factorio.com/api/mods/{}"
API_FULL = "https://mods.factorio.com/api/mods/{}/full"
# Wube's built-in mods — not on the portal, skip them.
BUILTIN = {"base", "elevated-rails", "quality", "space-age"}
WORKERS = 12
TIMEOUT = 20


def parse_version(v):
    """Turn '0.6.16' into a comparable tuple (0, 6, 16). Non-numeric parts -> 0."""
    parts = []
    for chunk in str(v).split("."):
        try:
            parts.append(int(chunk))
        except ValueError:
            parts.append(0)
    return tuple(parts)


def installed_mods():
    """Return {name: {'version', 'factorio_version'}} for every unpacked mod folder."""
    mods = {}
    for info_path in MODS_DIR.glob("*/info.json"):
        try:
            info = json.loads(info_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            continue
        name = info.get("name")
        if not name or name in BUILTIN:
            continue
        mods[name] = {
            "version": info.get("version", "0"),
            "factorio_version": str(info.get("factorio_version", "")),
        }
    return mods


def listed_mods():
    """Names from mod-list.json. Returns ([all_listed], {enabled_names})."""
    ml = MODS_DIR / "mod-list.json"
    if not ml.exists():
        return [], set()
    data = json.loads(ml.read_text())
    names = [m["name"] for m in data.get("mods", []) if m["name"] not in BUILTIN]
    enabled = {m["name"] for m in data.get("mods", []) if m.get("enabled")}
    return names, enabled


def load_local_mods(enabled_only, from_list):
    """Build the mod set to check.

    Source is the installed folders, unless --from-list, in which case the
    canonical set comes from mod-list.json and any listed-but-not-installed mod
    is included with version=None (so we still report its latest portal release).
    """
    installed = installed_mods()
    listed, enabled = listed_mods()

    if from_list:
        mods = {}
        for name in listed:
            if name in installed:
                mods[name] = installed[name]
            else:
                mods[name] = {"version": None, "factorio_version": ""}
    else:
        mods = installed

    if enabled_only and enabled:
        mods = {n: v for n, v in mods.items() if n in enabled}
    return mods


def fetch_mod(name, want_changelog=False):
    """Fetch a mod from the portal.

    Returns (name, releases|None, changelog_text|None, error). Uses the /full
    endpoint (which carries the changelog) only when changelogs are requested.
    """
    url = (API_FULL if want_changelog else API).format(urllib.parse.quote(name, safe=""))
    req = urllib.request.Request(url, headers={"User-Agent": "factorio-mod-update-checker/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        return name, data.get("releases", []), data.get("changelog"), None
    except urllib.error.HTTPError as e:
        return name, None, None, ("not-found" if e.code == 404 else f"http {e.code}")
    except Exception as e:  # network / timeout / decode
        return name, None, None, str(e)


def parse_changelog(text):
    """Parse a Factorio changelog.txt string into {version_str: block_text}."""
    if not text:
        return {}
    text = text.replace("﻿", "")  # some changelogs start with a BOM
    entries = {}
    for chunk in re.split(r"^-{5,}\s*$", text, flags=re.M):
        chunk = chunk.strip("\n")
        if not chunk.strip():
            continue
        m = re.search(r"^Version:\s*(\S+)", chunk, flags=re.M)
        if m:
            entries[m.group(1)] = chunk.rstrip()
    return entries


def changelog_between(text, local_v, remote_v):
    """Return changelog blocks for versions in (local_v, remote_v], newest first."""
    lo, hi = parse_version(local_v), parse_version(remote_v)
    picked = [
        (parse_version(v), block)
        for v, block in parse_changelog(text).items()
        if lo < parse_version(v) <= hi
    ]
    return [block for _, block in sorted(picked, reverse=True)]


def latest_for_target(releases, target):
    """Newest release matching the target factorio_version, else newest overall."""
    matching = [
        r for r in releases
        if str(r.get("info_json", {}).get("factorio_version", "")) == target
    ]
    pool = matching or releases
    if not pool:
        return None
    return max(pool, key=lambda r: parse_version(r.get("version", "0")))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--enabled-only", action="store_true",
                    help="only check mods enabled in mod-list.json")
    ap.add_argument("--all", action="store_true",
                    help="also show up-to-date and not-found mods")
    ap.add_argument("--from-list", action="store_true",
                    help="check every mod in mod-list.json (incl. not-installed)")
    ap.add_argument("--changelog", action="store_true",
                    help="for each update, print changelog entries from your "
                         "version up to the latest")
    ap.add_argument("--target", default=None,
                    help="force target factorio_version (e.g. 2.0); "
                         "default: each mod's own factorio_version")
    ap.add_argument("--mods-dir", default=None,
                    help="path to the folder holding the mod sub-folders "
                         "(default: auto-detect <repo>/mods)")
    args = ap.parse_args()

    global MODS_DIR
    if args.mods_dir:
        MODS_DIR = Path(args.mods_dir).expanduser().resolve()
    print(f"Mods dir: {MODS_DIR}", file=sys.stderr)

    if (args.from_list or args.enabled_only) and not (MODS_DIR / "mod-list.json").exists():
        print("Note: no mod-list.json here; --from-list/--enabled-only ignored, "
              "scanning mod folders instead.", file=sys.stderr)
        args.from_list = args.enabled_only = False

    mods = load_local_mods(args.enabled_only, args.from_list)
    if not mods:
        print("No mods found.", file=sys.stderr)
        return 1
    print(f"Checking {len(mods)} mods against the portal...\n", file=sys.stderr)

    results = {}
    fetch = functools.partial(fetch_mod, want_changelog=args.changelog)
    with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as pool:
        for name, releases, changelog, err in pool.map(fetch, mods):
            results[name] = (releases, changelog, err)

    updates, uptodate, notfound, errors, notinstalled = [], [], [], [], []
    for name in sorted(mods):
        local = mods[name]
        releases, changelog, err = results[name]
        if err == "not-found":
            notfound.append(name)
            continue
        if err:
            errors.append((name, err))
            continue
        # not-installed mods have no factorio_version of their own; fall back to 2.0
        target = args.target or local["factorio_version"] or "2.0"
        rel = latest_for_target(releases, target)
        if not rel:
            notfound.append(name)
            continue
        remote_v = rel.get("version", "0")
        if local["version"] is None:
            notinstalled.append((name, remote_v, target))
        elif parse_version(remote_v) > parse_version(local["version"]):
            updates.append((name, local["version"], remote_v, target, changelog))
        else:
            uptodate.append((name, local["version"]))

    if updates:
        print(f"⬆️  Updates available ({len(updates)}):")
        width = max(len(n) for n, *_ in updates)
        for name, lv, rv, tgt, changelog in sorted(updates):
            print(f"  {name:<{width}}  {lv:>12}  →  {rv:<12}  (FA {tgt})")
            if args.changelog:
                blocks = changelog_between(changelog, lv, rv)
                if blocks:
                    for block in blocks:
                        for line in block.splitlines():
                            print(f"        {line}")
                    print()
                else:
                    print("        (no changelog entries for this range)\n")
    else:
        print("✅ All checked mods are up to date.")

    if notinstalled:
        print(f"\n📥 In list but not installed ({len(notinstalled)}) — latest available:")
        width = max(len(n) for n, *_ in notinstalled)
        for name, rv, tgt in sorted(notinstalled):
            print(f"  {name:<{width}}  →  {rv:<12}  (FA {tgt})")

    if args.all and uptodate:
        print(f"\n✅ Up to date ({len(uptodate)}):")
        for name, lv in uptodate:
            print(f"  {name}  ({lv})")

    if notfound:
        print(f"\n❓ Not on portal / no matching release ({len(notfound)}):")
        if args.all:
            print("  " + ", ".join(notfound))
        else:
            print(f"  (use --all to list; e.g. local-only or renamed mods)")

    if errors:
        print(f"\n⚠️  Errors ({len(errors)}):")
        for name, err in errors:
            print(f"  {name}: {err}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
