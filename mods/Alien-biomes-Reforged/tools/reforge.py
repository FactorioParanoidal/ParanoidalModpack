"""Alien-biomes-Reforged maintenance CLI. Full description: tools/README.md.

Run with `python -I tools/reforge.py COMMAND ...`; all paths are arguments.
--mod defaults to the mod folder that contains this tools/ directory.

Commands
  code      --upstream DIR [--dry-run]
            Refresh the code from an unpacked upstream `alien-biomes` release:
            upstream-owned files are replaced, mod paths rewritten, patches.py
            re-applied, changelog merged, data/upstream-code-manifest.json updated.
            Graphics, tools/, info.json and Reforged-only files are never touched.
  graphics  --upstream DIR [--apply]
            Compare an unpacked upstream `alien-biomes-graphics` release with
            data/upstream-graphics-manifest.json. Without --apply only reports.
            --apply copies changed/new plain files ("kept"); families replaced by
            matrices and derived files are only reported (rebuild them, see README).
  matrices  --selection DIR
            Install a select.py result (report.json + matrices/) into the mod and
            regenerate prototypes/tint-matrices.lua. Replaced originals are deleted.
  tintlua   Regenerate prototypes/tint-matrices.lua from tools/data only.
  manifest  --code DIR --graphics DIR
            (Re)write both upstream manifests from unpacked upstream releases,
            classifying every graphics file by its current status in the mod.
  check     [--png]
            Static checks: literal mod paths in Lua exist, tint-matrices files
            exist, upstream-owned files still carry every patch; --png decodes all PNGs.
Exit code 1 on any problem.
"""
import argparse, hashlib, json, os, re, shutil, sys

sys.dont_write_bytecode = True  # keep tools/ free of __pycache__
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import patches as patchdef  # noqa: E402

MOD_NAME = "Alien-biomes-Reforged"
P = "__%s__" % MOD_NAME
UPSTREAM_PREFIXES = ("__alien-biomes-graphics__", "__alien-biomes__")
DATA = os.path.join(HERE, "data")
CODE_MANIFEST = os.path.join(DATA, "upstream-code-manifest.json")
GFX_MANIFEST = os.path.join(DATA, "upstream-graphics-manifest.json")
MATRICES_REPORT = os.path.join(DATA, "matrices-report.json")
ECONOMY_TINTS = os.path.join(DATA, "economy-tints.json")  # optional, written by economy.py
MATDIR = {"mineral": "terrain/matrices", "volcanic": "terrain/matrices", "vegetation": "terrain/matrices",
          "dune": "decorative/dune/matrices", "lava": "decorative/lava/matrices"}
# upstream graphics that the code never loads (removed from the mod)
UNUSED_RES = [r"^terrain/cliffs/", r"^entity/tree/green-coral/",
              r"^decorative/lava/[a-z]+/lava-decal-(00|01|02|03|04|05|06|08|09|10|11|12|13|22|23|24|29)\.png$"]
# upstream graphics regenerated from the original by a Reforged tool (status "derived")
DERIVED_FILE = os.path.join(DATA, "derived-graphics.json")
NOT_CODE = {"info.json", "changelog.txt"}
# upstream Lua that nothing requires (dead code with stale paths); skipped by `check`
DEAD_CODE = {"prototypes/tile/tile-transitions-dynamic.lua"}


def sha1(path):
    h = hashlib.sha1()
    with open(path, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def walk_files(root, skip_dirs=()):
    out = []
    for r, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if not d.startswith(".") and os.path.relpath(os.path.join(r, d), root).replace(os.sep, "/") not in skip_dirs]
        for f in files:
            out.append(os.path.relpath(os.path.join(r, f), root).replace(os.sep, "/"))
    return sorted(out)


def jload(p, default=None):
    if not os.path.exists(p):
        return default
    with open(p, encoding="utf-8") as f:
        return json.load(f)


def jsave(p, obj):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        json.dump(obj, f, indent=1, ensure_ascii=False, sort_keys=True)
        f.write("\n")


def read(p):
    with open(p, encoding="utf-8", newline="") as f:
        return f.read()


def write(p, s):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8", newline="") as f:
        f.write(s)


def rewrite_paths(s):
    for u in UPSTREAM_PREFIXES:
        s = s.replace(u, P)
    return s


def apply_patches(mod, only_files=None, check_only=False):
    """Returns list of problems. check_only: verify every patch result is present."""
    problems = []
    for entry in patchdef.PATCHES:
        kind, rel = entry[0], entry[1]
        if only_files is not None and rel not in only_files:
            continue
        p = os.path.join(mod, rel)
        if not os.path.exists(p):
            problems.append("missing file for patch: %s" % rel); continue
        s = read(p)
        if kind == "replace":
            old, new = entry[2], entry[3]
            if check_only:
                if s.count(new) != 1:
                    problems.append("patch not applied (%s): %r" % (rel, new[:70]))
                continue
            n = s.count(old)
            if n != 1:
                problems.append("anchor found %d times in %s: %r" % (n, rel, old[:70])); continue
            s = s.replace(old, new)
        elif kind == "append":
            text = entry[2]
            if check_only:
                if text not in s:
                    problems.append("append not present (%s): %r" % (rel, text[:70]))
                continue
            if text not in s:
                s = s + ("" if s.endswith("\n") else "\n") + text
        else:
            problems.append("unknown patch kind %s" % kind); continue
        write(p, s)
    return problems


# ------------------------------------------------------------------ code
def cmd_code(mod, up, dry):
    info = jload(os.path.join(up, "info.json"))
    if not info or info.get("name") != "alien-biomes":
        sys.exit("--upstream must be an unpacked alien-biomes release (info.json name alien-biomes)")
    man = jload(CODE_MANIFEST)
    if not man:
        sys.exit("no %s; run `manifest` first" % CODE_MANIFEST)
    old_files = set(man["files"])
    new_files = [f for f in walk_files(up) if f not in NOT_CODE]
    ours = set(walk_files(mod)) - old_files
    clash = [f for f in new_files if f in ours and f not in old_files and not f.startswith(("graphics/",))]
    if clash:
        sys.exit("upstream now ships files that Reforged owns, resolve by hand: %s" % clash)
    removed = sorted(old_files - set(new_files))
    print("upstream %s -> %s: %d files, %d removed upstream" % (man["version"], info["version"], len(new_files), len(removed)))
    for f in removed:
        print("  remove", f)
    if dry:
        changed = [f for f in new_files if f not in man["files"] or man["files"][f] != sha1(os.path.join(up, f))]
        print("changed/new upstream files:", len(changed))
        for f in changed:
            print("  ", f)
        return 0
    for f in removed:
        p = os.path.join(mod, f)
        if os.path.exists(p):
            os.remove(p)
    for f in new_files:
        src, dst = os.path.join(up, f), os.path.join(mod, f)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if f.endswith(".lua"):
            write(dst, rewrite_paths(read(src)))  # always: patches.py may have changed
        elif not os.path.exists(dst) or man["files"].get(f) != sha1(src):
            shutil.copy2(src, dst)  # binaries only when upstream changed them (keeps pingo results)
    problems = apply_patches(mod)
    # changelog: Reforged entries stay on top of the new upstream changelog
    cl = read(os.path.join(mod, "changelog.txt"))
    marker = "Version: %s\n" % man["version"]
    i = cl.find(marker)
    if i < 0:
        problems.append("changelog: upstream marker %r not found, changelog left unchanged" % marker.strip())
    else:
        head = cl[:i]
        sep = head.rfind("-" * 99)
        ours_part = head[:sep] if sep >= 0 else head
        write(os.path.join(mod, "changelog.txt"), ours_part + read(os.path.join(up, "changelog.txt")))
    man = {"name": info["name"], "version": info["version"], "files": {f: sha1(os.path.join(up, f)) for f in new_files}}
    jsave(CODE_MANIFEST, man)
    for p in problems:
        print("PROBLEM", p)
    print("done. Next: bump info.json version, add a changelog entry, run `check`, a dump (tools/run_isolated.py) and dumpdiff.")
    return 1 if problems else 0


# ------------------------------------------------------------------ graphics
def classify(rel, replaced, derived):
    if rel in replaced:
        return "matrix"
    if rel in derived:
        return "derived"
    if any(re.search(r, rel) for r in UNUSED_RES):
        return "unused"
    return "kept"


def derived_files():
    """graphics-relative paths of files regenerated by a Reforged tool (data/derived-graphics.json)."""
    return {k[len("graphics/"):] if k.startswith("graphics/") else k for k in jload(DERIVED_FILE, {})}


def replaced_sources():
    rep = jload(MATRICES_REPORT, {})
    out = {}
    for key, fr in rep.items():
        for rel in fr["sources"].values():
            out[rel] = key
    return out


def cmd_manifest(mod, code, gfx):
    ci, gi = jload(os.path.join(code, "info.json")), jload(os.path.join(gfx, "info.json"))
    if ci.get("name") != "alien-biomes" or gi.get("name") != "alien-biomes-graphics":
        sys.exit("expected unpacked alien-biomes and alien-biomes-graphics releases")
    jsave(CODE_MANIFEST, {"name": ci["name"], "version": ci["version"],
                          "files": {f: sha1(os.path.join(code, f)) for f in walk_files(code) if f not in NOT_CODE}})
    from PIL import Image
    replaced = replaced_sources()
    derived = derived_files()
    files = {}
    for f in walk_files(os.path.join(gfx, "graphics")):
        p = os.path.join(gfx, "graphics", f)
        e = {"sha1": sha1(p), "status": classify(f, replaced, derived)}
        if f.endswith(".png"):
            e["size"] = list(Image.open(p).size)
        if e["status"] == "matrix":
            e["family"] = replaced[f]
        files[f] = e
    jsave(GFX_MANIFEST, {"name": gi["name"], "version": gi["version"], "files": files})
    st = {}
    for e in files.values():
        st[e["status"]] = st.get(e["status"], 0) + 1
    print("code files", len(jload(CODE_MANIFEST)["files"]), "graphics", len(files), st)
    # consistency with the mod
    bad = 0
    for f, e in files.items():
        present = os.path.exists(os.path.join(mod, "graphics", f))
        if (e["status"] in ("kept", "derived")) != present:
            bad += 1
            print("  status/presence mismatch:", f, e["status"], "present" if present else "absent")
    return 1 if bad else 0


def cmd_graphics(mod, up, apply):
    gi = jload(os.path.join(up, "info.json"))
    if not gi or gi.get("name") != "alien-biomes-graphics":
        sys.exit("--upstream must be an unpacked alien-biomes-graphics release")
    man = jload(GFX_MANIFEST)
    replaced = replaced_sources()
    derived = derived_files()
    new = {f: sha1(os.path.join(up, "graphics", f)) for f in walk_files(os.path.join(up, "graphics"))}
    report = {"kept": [], "matrix": [], "derived": [], "unused": [], "removed": []}
    for f, h in new.items():
        old = man["files"].get(f)
        if old and old["sha1"] == h:
            continue
        st = old["status"] if old else classify(f, replaced, derived)
        report[st].append(f + ("" if old else "  (new)"))
    for f in man["files"]:
        if f not in new:
            report["removed"].append(f)
    print("upstream graphics %s -> %s" % (man["version"], gi["version"]))
    for k, v in report.items():
        print("%-8s %d" % (k, len(v)))
        for f in v[:50]:
            print("   ", f)
    if report["matrix"]:
        print("matrix families changed: rebuild them (README: rebuilding matrices), then `matrices`.")
    if report["derived"]:
        print("derived files changed: regenerate them with the tool named in data/derived-graphics.json.")
    if apply:
        for f in report["kept"]:
            f = f.split("  ")[0]
            dst = os.path.join(mod, "graphics", f)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy2(os.path.join(up, "graphics", f), dst)
        for f in report["removed"]:
            if man["files"][f]["status"] in ("kept", "derived"):
                p = os.path.join(mod, "graphics", f)
                if os.path.exists(p):
                    os.remove(p)
        print("applied kept/removed. Optimise new PNGs with pingo, then run `manifest` with the new releases.")
    return 0


# ------------------------------------------------------------------ matrices
def colt(t):
    return "{r=%.4f,g=%.4f,b=%.4f,a=1}" % tuple(t)


def tintlua(mod):
    report = jload(MATRICES_REPORT)
    economy = jload(ECONOMY_TINTS, {})
    tiles, dunes, lava = {}, {}, {}
    for key, fr in sorted(report.items()):
        kind = key.split("-")[0]
        sub = MATDIR[kind]
        for g in fr["groups"]:
            files = ["%s/graphics/%s/%s" % (P, sub, L["file"]) for L in g["layers"]]
            for color, m in g["colors"].items():
                if kind in ("mineral", "volcanic", "vegetation"):
                    fam = key.split("-", 1)[1]
                    tiles["%s-%s-%s" % (kind, color, fam)] = (files[0], m["tints"][0])
                elif kind == "dune":
                    e = dunes.setdefault(key.split("-")[1], {"file": files[0], "tints": {}})
                    e["tints"][color] = m["tints"][0]
                elif kind == "lava":
                    e = lava.setdefault(key.split("-")[1], {"base": files[0], "glow": files[1], "tints": {}})
                    e["tints"][color] = m["tints"][1]
    lines = ["-- Generated by tools/reforge.py tintlua from tools/data: do not edit by hand.",
             "-- picture/file: matrix PNG; tint: per-colour multiplier fitted to the original texture.",
             "-- economy: matrix and tint used by the economy atlas setting (one matrix per family).",
             "return {", "  tiles = {"]
    for name, (f, t) in sorted(tiles.items()):
        ex = ""
        e = economy.get("tiles", {}).get(name)
        if e:
            ex = ', economy = {picture = "%s/graphics/terrain/matrices/%s", tint = %s}' % (P, e["matrix"], colt(e["tint"]))
        lines.append('    ["%s"] = {picture = "%s", tint = %s%s},' % (name, f, colt(t), ex))
    lines += ["  },", "  dunes = {"]
    for idx, e in sorted(dunes.items()):
        lines.append('    ["%s"] = {file = "%s", tints = {' % (idx, e["file"]))
        for c, t in sorted(e["tints"].items()):
            lines.append('      %s = %s,' % (c, colt(t)))
        lines.append("    }},")
    lines += ["  },", "  lava = {"]
    for idx, e in sorted(lava.items()):
        lines.append('    ["%s"] = {base = "%s", glow = "%s", tints = {' % (idx, e["base"], e["glow"]))
        for c, t in sorted(e["tints"].items()):
            lines.append('      %s = %s,' % (c, colt(t)))
        lines.append("    }},")
    lines += ["  },", "}", ""]
    write(os.path.join(mod, "prototypes", "tint-matrices.lua"), "\n".join(lines))
    print("tint-matrices.lua: tiles %d, dunes %d, lava %d, economy tiles %d" % (len(tiles), len(dunes), len(lava), len(economy.get("tiles", {}))))


def cmd_matrices(mod, sel):
    rep = jload(os.path.join(sel, "report.json"))
    for key, fr in rep.items():
        sub = MATDIR[key.split("-")[0]]
        for g in fr["groups"]:
            for L in g["layers"]:
                dst = os.path.join(mod, "graphics", sub, L["file"])
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                shutil.copy2(os.path.join(sel, "matrices", L["file"]), dst)
        for rel in fr["sources"].values():
            p = os.path.join(mod, "graphics", rel)
            if os.path.exists(p):
                os.remove(p)
    jsave(MATRICES_REPORT, rep)
    tintlua(mod)
    print("installed. Optimise the new matrices with pingo, rerun economy.py if families changed, run check + dump.")
    return 0


# ------------------------------------------------------------------ check
def cmd_check(mod, png):
    problems = []
    lit = re.compile(r'"(%s/[^"|]+)"' % re.escape(P))
    for f in walk_files(mod, skip_dirs=("tools", "graphics")):
        if f.endswith(".lua") and f not in DEAD_CODE:
            s = read(os.path.join(mod, f))
            for line in s.splitlines():
                if line.lstrip().startswith("--"):
                    continue
                for m in lit.finditer(line):
                    rel = m.group(1)[len(P) + 1:]
                    if rel.endswith(("/", ".")) or ".." in rel or not re.search(r"\.\w+$", rel):
                        continue
                    if not os.path.exists(os.path.join(mod, rel)):
                        problems.append("missing file %s (in %s)" % (rel, f))
            for u in UPSTREAM_PREFIXES:
                if u in s:
                    problems.append("upstream mod path %s left in %s" % (u, f))
    man = jload(CODE_MANIFEST, {"files": {}})
    problems += apply_patches(mod, only_files=set(man["files"]), check_only=True)
    if png:
        from PIL import Image
        n = 0
        for f in walk_files(os.path.join(mod, "graphics")):
            if f.endswith(".png"):
                try:
                    Image.open(os.path.join(mod, "graphics", f)).load(); n += 1
                except Exception as e:
                    problems.append("png %s: %s" % (f, e))
        print("png decoded:", n)
    for p in sorted(set(problems)):
        print("PROBLEM", p)
    print("check:", "FAIL" if problems else "OK")
    return 1 if problems else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("command", choices=["code", "graphics", "matrices", "tintlua", "manifest", "check"])
    ap.add_argument("--mod", default=os.path.dirname(HERE))
    ap.add_argument("--upstream")
    ap.add_argument("--selection")
    ap.add_argument("--code")
    ap.add_argument("--graphics")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--png", action="store_true")
    a = ap.parse_args()
    mod = os.path.abspath(a.mod)
    if a.command == "code":
        return cmd_code(mod, a.upstream, a.dry_run)
    if a.command == "graphics":
        return cmd_graphics(mod, a.upstream, a.apply)
    if a.command == "matrices":
        return cmd_matrices(mod, a.selection)
    if a.command == "tintlua":
        tintlua(mod); return 0
    if a.command == "manifest":
        return cmd_manifest(mod, a.code, a.graphics)
    if a.command == "check":
        return cmd_check(mod, a.png)


if __name__ == "__main__":
    sys.exit(main())
