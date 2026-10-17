"""Atlas estimate by loaded regions: unique (file, x, y, w, h) frames referenced by a dump.

atlas_regions.py DUMP PREFIX ROOT [PREFIX ROOT ...] [--json OUT]
  PREFIX: mod path prefix such as __Alien-biomes-Reforged__/ ; ROOT: folder it maps to.
The engine loads only the frame rectangles a sprite definition references (and trims their
transparent borders, which is NOT modelled here), identical rectangles are counted once.
Prints uncompressed RGBA MiB per category; also checks every rectangle lies inside its image
(a sprite outside the image is a load error only visible in a graphical launch).
"""
import sys, json, collections, re
from PIL import Image

args = sys.argv[1:]
out_json = None
if "--json" in args:
    i = args.index("--json"); out_json = args[i + 1]; del args[i:i + 2]
dump = json.load(open(args[0], encoding="utf-8"))
roots = dict(zip(args[1::2], args[2::2]))
rects = set()
sizes = {}


def mine(f):
    return isinstance(f, str) and any(f.startswith(p) for p in roots)


def add_frames(f, x, y, w, h, n, ll):
    ll = ll or n
    for k in range(n):
        rects.add((f, x + (k % ll) * w, y + (k // ll) * h, w, h))


def walk(o, key=None):
    if isinstance(o, dict):
        f = o.get("filename")
        if mine(f) and "width" in o:
            w, h = int(o["width"]), int(o["height"])
            n = int(o.get("frame_count", 1)) * int(o.get("direction_count", 1)) * int(o.get("variation_count", 1))
            add_frames(f, int(o.get("x", 0)), int(o.get("y", 0)), w, h, n, int(o.get("line_length", 0)))
        pic = o.get("picture")
        if mine(pic) and "size" in o:
            side = int(round(o["size"] * 32 / o.get("scale", 1)))
            add_frames(pic, int(o.get("x", 0)), int(o.get("y", 0)), side, side, int(o.get("count", 1)), int(o.get("line_length", 0)))
        for k, v in o.items():
            walk(v, k)
    elif isinstance(o, list):
        for v in o:
            walk(v, key)


walk(dump)
tot = collections.Counter(); files = collections.defaultdict(set); outside = []
for f, x, y, w, h in rects:
    if f not in sizes:
        for p, r in roots.items():
            if f.startswith(p):
                sizes[f] = Image.open(r + "/" + f[len(p):]).size
    W, H = sizes[f]
    if x + w > W or y + h > H:
        outside.append((f, x, y, w, h, W, H))
    rel = re.sub(r"^__[^/]+__/", "", f)
    parts = rel.split("/")
    cat = parts[1] if len(parts) > 2 else "other"
    if cat in ("decorative", "entity"):
        cat += "/" + parts[2]
    tot[cat] += w * h * 4
    files[cat].add(f)
for c in sorted(tot):
    print(f"{c:26s} files={len(files[c]):4d} {tot[c] / 2**20:8.1f} MiB")
print(f"{'TOTAL':26s} files={sum(len(v) for v in files.values()):4d} {sum(tot.values()) / 2**20:8.1f} MiB")
print("rectangles outside their image:", len(outside))
for o in outside[:10]:
    print("  OUTSIDE", o)
if out_json:
    json.dump({"MiB": {c: round(v / 2**20, 1) for c, v in tot.items()}, "total_MiB": round(sum(tot.values()) / 2**20, 1),
               "outside": outside}, open(out_json, "w"), indent=1)
