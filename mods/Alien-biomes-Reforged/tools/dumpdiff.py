"""Structural diff of two data-raw dumps, normalising the graphics changes of Reforged.
dumpdiff.py ORIG_DUMP NEW_DUMP REFORGED_DIR
"""
import sys, json, os, re, collections

orig = json.load(open(sys.argv[1], encoding="utf-8"))
new = json.load(open(sys.argv[2], encoding="utf-8"))
rdir = sys.argv[3]
P = "__Alien-biomes-Reforged__/"

# 1. prototype sets
diffs = collections.Counter()
for t in sorted(set(orig) | set(new)):
    a, b = set(orig.get(t, {})), set(new.get(t, {}))
    if a != b:
        print("TYPE", t, "only-orig", sorted(a - b)[:10], "only-new", sorted(b - a)[:10])
        diffs["set"] += 1

# 2. field diffs after normalising filenames and graphics-only fields
GFX_KEYS = {"filename", "picture", "spritesheet", "tint", "layers", "blend_mode", "pictures", "variants"}


def strip(o):
    if isinstance(o, dict):
        return {k: strip(v) for k, v in o.items() if k not in GFX_KEYS}
    if isinstance(o, list):
        return [strip(v) for v in o]
    if isinstance(o, str):
        return o.replace("__alien-biomes-graphics__/", P).replace("__alien-biomes__/", P)
    return o


changed = collections.Counter()
for t in set(orig) & set(new):
    for n in set(orig[t]) & set(new[t]):
        if strip(orig[t][n]) != strip(new[t][n]):
            changed[t] += 1
            if changed[t] <= 2:
                a, b = strip(orig[t][n]), strip(new[t][n])
                ks = [k for k in set(a) | set(b) if a.get(k) != b.get(k)]
                print("FIELD", t, n, ks[:8])
print("non-graphics field differences per type:", dict(changed))

# 3. graphics checks
files = set()


def walk(o):
    if isinstance(o, dict):
        for k, v in o.items():
            if k in ("filename", "picture", "spritesheet") and isinstance(v, str):
                files.add(v)
            walk(v)
    elif isinstance(o, list):
        for v in o:
            walk(v)


walk(new)
mine = sorted(f for f in files if f.startswith(P))
missing = [f for f in mine if not os.path.exists(os.path.join(rdir, f[len(P):]))]
print("referenced Reforged files:", len(mine), "missing:", len(missing), missing[:10])
fo = set(); files_o = files; files = set(); walk(orig); fo = files
orig_ab = sorted(f for f in fo if "__alien-biomes" in f)
print("referenced original AB files:", len(orig_ab))
on_disk = []
for root, d, fs in os.walk(os.path.join(rdir, "graphics")):
    for f in fs:
        on_disk.append((os.path.relpath(os.path.join(root, f), rdir)).replace(os.sep, "/"))
unref = sorted(set(on_disk) - {f[len(P):] for f in mine})
print("graphics on disk:", len(on_disk), "not referenced by any prototype:", len(unref))
open(os.path.join(os.path.dirname(sys.argv[2]), "unreferenced.txt"), "w").write("\n".join(unref))

# 4. tile tint / decorative layers sanity
tiles = new["tile"]
tinted = [n for n, v in tiles.items() if "tint" in v]
print("tiles with tint:", len(tinted), "e.g.", tinted[:3])
ex = tiles.get("mineral-red-dirt-1")
if ex:
    print("mineral-red-dirt-1:", ex["variants"]["main"][0]["picture"], ex["tint"])
lv = new["optimized-decorative"].get("lava-decal-orange")
if lv:
    print("lava-decal-orange picture 0:", json.dumps(lv["pictures"][0])[:400])
dn = [n for n in new["optimized-decorative"] if n.startswith("sand-dune-decal")]
if dn:
    print(dn[0], json.dumps(new["optimized-decorative"][dn[0]]["pictures"][0])[:300])
