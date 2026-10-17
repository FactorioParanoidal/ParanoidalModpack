"""Tree shadows and normal maps at half resolution (derived graphics).

trees.py DUMP UPSTREAM_GRAPHICS_DIR [--mod DIR] [--dry-run]
  DUMP: data-raw-dump.json of the mod in normal mode BEFORE prototypes/reforged/trees.lua
        halves the sprite definitions (or of the original Alien Biomes pair: the tree sprite
        definitions are identical), used to know the frame layout of every file.
  UPSTREAM_GRAPHICS_DIR: `graphics` of the unpacked alien-biomes-graphics release (originals).

Why: tree shadows are soft dark masks and normal maps only modulate light; at half
resolution they look the same in the game but take a quarter of the atlas (shadows were
171 MiB, normals 36 MiB of uncompressed RGBA). Trunks and leaves keep full resolution.

How: every graphics/entity/tree/*/*-shadow.png and *-normal.png is used by one-row
animations (x = y = 0, line_length 0). Each USED frame (w x h) is padded to even size with
transparent pixels on the right/bottom, downscaled 2x on premultiplied RGBA (Lanczos) and
placed at column k * ceil(w/2). Unused frames of the original sheet are dropped.
prototypes/reforged/trees.lua applies the matching rule to the sprite definitions:
width = ceil(w/2), height = ceil(h/2), scale = 2 * scale, shift unchanged (the padding
moves the centre by at most a quarter of an original pixel).
The list of derived files with the source SHA-1 goes to tools/data/derived-graphics.json
(`reforge.py graphics` reports when an upstream source changed). Optimise with pingo after.
"""
import sys, os, re, json, math, hashlib
sys.dont_write_bytecode = True
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
args = sys.argv[1:]
mod = os.path.dirname(HERE)
dry = "--dry-run" in args
if dry:
    args.remove("--dry-run")
if "--mod" in args:
    i = args.index("--mod"); mod = args[i + 1]; del args[i:i + 2]
dump_path, upstream = args[0], args[1]
OURS = ("__Alien-biomes-Reforged__/", "__alien-biomes-graphics__/")
RX = re.compile(r"^graphics/entity/tree/[^/]+/[^/]+-(shadow|normal)\.png$")

dump = json.load(open(dump_path, encoding="utf-8"))
specs = {}


def walk(o):
    if isinstance(o, dict):
        f = o.get("filename")
        if isinstance(f, str) and f.startswith(OURS):
            rel = f.split("__/", 1)[1]
            if RX.match(rel):
                key = (int(o.get("x", 0)), int(o.get("y", 0)), int(o["width"]), int(o["height"]),
                       int(o.get("frame_count", 1)), int(o.get("line_length", 0)),
                       int(o.get("direction_count", 1)), int(o.get("variation_count", 1)))
                specs.setdefault(rel, set()).add(key)
        for v in o.values():
            walk(v)
    elif isinstance(o, list):
        for v in o:
            walk(v)


walk(dump.get("tree", {}))


def sha1(p):
    return hashlib.sha1(open(p, "rb").read()).hexdigest()


def half_frame(fr):
    """fr: HxWx4 float straight RGBA -> half size, premultiplied resampling."""
    h, w = fr.shape[:2]
    pad = np.zeros((h + h % 2, w + w % 2, 4), np.float32)
    pad[:h, :w] = fr
    a = pad[..., 3:4] / 255.0
    pm = np.concatenate([pad[..., :3] * a, pad[..., 3:4]], -1)
    W2, H2 = pad.shape[1] // 2, pad.shape[0] // 2
    chans = [np.asarray(Image.fromarray(pm[..., c]).resize((W2, H2), Image.LANCZOS)) for c in range(4)]
    pm2 = np.clip(np.stack(chans, -1), 0, 255)
    a2 = pm2[..., 3:4] / 255.0
    rgb = np.where(a2 > 1e-4, pm2[..., :3] / np.maximum(a2, 1e-4), 0)
    return np.clip(np.round(np.concatenate([rgb, pm2[..., 3:4]], -1)), 0, 255).astype(np.uint8)


derived, problems = {}, []
before = after = 0
for rel in sorted(specs):
    ss = specs[rel]
    if len(ss) != 1:
        problems.append("%s: %d different sprite definitions" % (rel, len(ss))); continue
    x, y, w, h, fc, ll, dc, vc = next(iter(ss))
    if (x, y, ll, dc, vc) != (0, 0, 0, 1, 1):
        problems.append("%s: unsupported layout %s" % (rel, (x, y, ll, dc, vc))); continue
    src = os.path.join(upstream, rel[len("graphics/"):])
    img = np.asarray(Image.open(src).convert("RGBA"), np.float32)
    if img.shape[1] < fc * w or img.shape[0] < h:
        problems.append("%s: image smaller than %d frames of %dx%d" % (rel, fc, w, h)); continue
    w2, h2 = (w + 1) // 2, (h + 1) // 2
    out = np.zeros((h2, w2 * fc, 4), np.uint8)
    for k in range(fc):
        out[:, k * w2:(k + 1) * w2] = half_frame(img[0:h, k * w:(k + 1) * w])
    before += fc * w * h * 4; after += fc * w2 * h2 * 4
    derived[rel] = {"tool": "trees.py", "method": "half-resolution, used frames only",
                    "source_sha1": sha1(src), "frames": fc, "frame": [w, h], "new_frame": [w2, h2]}
    if not dry:
        Image.fromarray(out).save(os.path.join(mod, rel), optimize=True)
for p in problems:
    print("PROBLEM", p)
print("files %d, atlas regions %.1f -> %.1f MiB%s" % (len(derived), before / 2**20, after / 2**20, " (dry run)" if dry else ""))
if not dry:
    with open(os.path.join(HERE, "data", "derived-graphics.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(derived, f, indent=1, sort_keys=True); f.write("\n")
sys.exit(1 if problems else 0)
