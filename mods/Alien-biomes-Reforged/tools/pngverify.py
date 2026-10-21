"""Verify optimised PNGs of the mod against their pre-optimisation sources.
pngverify.py MOD_DIR MATRICES_DIR GRAPHICS_MOD_DIR [--derived-ref DIR]
Matrices (graphics/**/matrices/*.png) are compared with MATRICES_DIR, derived files
(tools/data/derived-graphics.json) with the same path under --derived-ref (the generator
output kept before pingo; skipped without it), everything else with the same relative path
under GRAPHICS_MOD_DIR.
Reports: unreadable files, size changes, alpha changes, worst PSNR (premultiplied RGB).
"""
import sys, os, math
import numpy as np
from PIL import Image

import json
argv = sys.argv[1:]
dref = None
if "--derived-ref" in argv:
    i = argv.index("--derived-ref"); dref = argv[i + 1]; del argv[i:i + 2]
mod, mats, gmod = argv[0:3]
dfile = os.path.join(mod, "tools", "data", "derived-graphics.json")
derived = set(json.load(open(dfile))) if os.path.exists(dfile) else set()
rows, bad = [], []
for root, _, files in os.walk(mod):
    for f in files:
        if not f.endswith(".png"):
            continue
        p = os.path.join(root, f)
        rel = os.path.relpath(p, mod).replace(os.sep, "/")
        if rel in derived:
            if not dref:
                continue
            src = os.path.join(dref, rel)
        else:
            src = os.path.join(mats, f) if "/matrices/" in rel else os.path.join(gmod, rel)
        if not os.path.exists(src):
            continue
        try:
            a = np.asarray(Image.open(p).convert("RGBA"), np.float32)
        except Exception as e:
            bad.append((rel, "unreadable %s" % e)); continue
        b = np.asarray(Image.open(src).convert("RGBA"), np.float32)
        if a.shape != b.shape:
            bad.append((rel, "size %s -> %s" % (b.shape, a.shape))); continue
        pa = a[..., :3] * a[..., 3:] / 255; pb = b[..., :3] * b[..., 3:] / 255
        mse = float(((pa - pb) ** 2).mean())
        psnr = 99.0 if mse == 0 else 20 * math.log10(255 / math.sqrt(mse))
        ad = float(np.abs(a[..., 3] - b[..., 3]).max())
        rows.append((psnr, ad, rel, os.path.getsize(src), os.path.getsize(p)))
rows.sort()
print("compared", len(rows), "problems", len(bad))
for b_ in bad[:20]:
    print("PROBLEM", *b_)
print("identical pixels:", sum(r[0] == 99.0 for r in rows))
print("bytes before %.1f MB after %.1f MB" % (sum(r[3] for r in rows) / 2**20, sum(r[4] for r in rows) / 2**20))
print("max alpha change:", max(r[1] for r in rows))
print("worst 10 PSNR:")
for r in rows[:10]:
    print("  %.2f dB  alpha_max_diff=%.0f  %s" % (r[0], r[1], r[2]))
m = [r for r in rows if "/matrices/" in r[2]]
print("matrices: n=%d worst %.2f dB" % (len(m), min(r[0] for r in m)))
