"""Uncompressed RGBA bytes of unique mod image files referenced by a dump.
atlas_estimate.py DUMP PREFIX MODROOT [PREFIX MODROOT ...]
"""
import sys, json, collections
from PIL import Image

d = json.load(open(sys.argv[1], encoding="utf-8"))
roots = dict(zip(sys.argv[2::2], sys.argv[3::2]))
files = set()


def walk(o):
    if isinstance(o, dict):
        for v in o.values():
            walk(v)
    elif isinstance(o, list):
        for v in o:
            walk(v)
    elif isinstance(o, str) and o.endswith(".png"):
        for p in roots:
            if o.startswith(p):
                files.add(o)


walk(d)
tot = collections.Counter(); cnt = collections.Counter()
for f in files:
    for p, r in roots.items():
        if f.startswith(p):
            rel = f[len(p):]
            w, h = Image.open(r + "/" + rel).size
            cat = rel.split("/")[1] if rel.startswith("graphics/") else "other"
            if cat == "decorative":
                cat += "/" + rel.split("/")[2]
            tot[cat] += w * h * 4; cnt[cat] += 1
for c in sorted(tot):
    print(f"{c:28s} files={cnt[c]:4d}  {tot[c]/2**20:8.1f} MiB")
print(f"{'TOTAL':28s} files={sum(cnt.values()):4d}  {sum(tot.values())/2**20:8.1f} MiB")
