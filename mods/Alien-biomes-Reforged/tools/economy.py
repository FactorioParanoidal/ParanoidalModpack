"""Economy atlas: one tint matrix per tile family.

economy.py GRAPHICS_DIR [--mod DIR]
  GRAPHICS_DIR: `graphics` folder of the unpacked upstream alien-biomes-graphics (originals).
For every tile family that uses two matrices (two colour groups) in normal mode, picks the
matrix that represents all colours of the family best and refits each colour's tint to it
by least squares on premultiplied RGB (the same model as abtint.py). The matrices are read
from the mod itself, i.e. exactly the files the game renders (after pingo).
Writes tools/data/economy-tints.json (matrix, tint, PSNR per tile) and prints a summary;
then run `reforge.py tintlua` to put the result into prototypes/tint-matrices.lua.
"""
import sys, os, json, math
sys.dont_write_bytecode = True
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
args = sys.argv[1:]
mod = os.path.dirname(HERE)
if "--mod" in args:
    i = args.index("--mod"); mod = args[i + 1]; del args[i:i + 2]
gdir = args[0]
report = json.load(open(os.path.join(HERE, "data", "matrices-report.json"), encoding="utf-8"))


def premult(path):
    a = np.asarray(Image.open(path).convert("RGBA"), np.float64)
    return a[..., :3] * (a[..., 3:4] / 255.0)


out, rows = {}, []
for key, fr in sorted(report.items()):
    kind = key.split("-")[0]
    if kind not in ("mineral", "volcanic", "vegetation") or len(fr["groups"]) < 2:
        continue
    fam = key.split("-", 1)[1]
    colors = list(fr["sources"])
    X = {c: premult(os.path.join(gdir, fr["sources"][c])) for c in colors}
    best = None
    for g in fr["groups"]:
        mfile = g["layers"][0]["file"]
        M = premult(os.path.join(mod, "graphics", "terrain", "matrices", mfile))
        tot, res = 0.0, {}
        for c in colors:
            t = []
            for ch in range(3):
                x = M[..., ch].ravel(); y = X[c][..., ch].ravel()
                t.append(float(np.clip((x @ y) / (x @ x), 0, 1)))
            rec = M * np.array(t)
            sse = float(((X[c] - rec) ** 2).sum())
            mse = sse / X[c].size
            res[c] = (t, 20 * math.log10(255 / math.sqrt(mse)))
            tot += sse
        if best is None or tot < best[0]:
            best = (tot, mfile, res)
    tot, mfile, res = best
    for c, (t, psnr) in res.items():
        name = "%s-%s-%s" % (kind, c, fam)
        out[name] = {"matrix": mfile, "tint": [round(v, 4) for v in t], "psnr": round(psnr, 2)}
    worst = min(res.items(), key=lambda kv: kv[1][1])
    rows.append((key, mfile, worst[0], worst[1][1], sum(v[1] for v in res.values()) / len(res)))
    print("%-20s keep %-24s worst %-10s %.2f dB  avg %.2f dB" % rows[-1], flush=True)
path = os.path.join(HERE, "data", "economy-tints.json")
with open(path, "w", encoding="utf-8", newline="\n") as f:
    json.dump({"tiles": out, "summary": [{"family": r[0], "matrix": r[1], "worst_color": r[2],
               "worst_psnr": round(r[3], 2), "avg_psnr": round(r[4], 2)} for r in rows]}, f, indent=1, sort_keys=True)
    f.write("\n")
print("tiles with economy tint:", len(out), "->", path)
