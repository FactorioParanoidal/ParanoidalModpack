"""Map and particle colours vs the rendered textures (Reforged item "colours", rule b).

colors.py analyse [--mod DIR] [--threshold DE]          map_color of every tile vs texture mean
colors.py particles DUMP [--mod DIR] [--threshold DE]   particle colour of every biome group in a
                                                        data-raw dump vs the group texture mean
colors.py report DUMP OUT.md [--mod DIR] [--threshold DE]  both tables + verdict as Markdown

Texture mean = alpha-weighted mean of what the game draws (mod PNG x tile tint from
tint-matrices.lua). Author colours (prototypes/tile/tile-colors.lua) are often lighter on purpose
so the map reads well, so lightness is ignored: a colour counts as diverged only when its hue /
chroma is far from the ground, measured as sqrt(da*^2 + db*^2) in CIELAB (default threshold 10).
Volcanic tiles are reported but not counted: their mean is pulled by thin glowing cracks; the
bright map colour of heat-4 marks the slowest terrain on purpose and particles are rock debris.
Alien Biomes tints the dust/stone particles of a group (group-colour, e.g. dirt-red) with the map
colour of one tile of the group; tile particle_tints are used by the engine only for water splashes.
"""
import sys, os, re, math, json
sys.dont_write_bytecode = True
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
args = sys.argv[1:]
cmd = args[0]
mod = os.path.dirname(HERE)
thr = 10.0
if "--mod" in args:
    i = args.index("--mod"); mod = args[i + 1]
if "--threshold" in args:
    i = args.index("--threshold"); thr = float(args[i + 1])
P = "__Alien-biomes-Reforged__/"


def lua_colors(path):
    s = open(path, encoding="utf-8").read()
    return {m.group(1): tuple(int(x) for x in m.group(2, 3, 4))
            for m in re.finditer(r"\['([^']+)'\]\s*=\s*\{r\s*=\s*(\d+),\s*g\s*=\s*(\d+),\s*b\s*=\s*(\d+)\}", s)}


def tint_table(path):
    s = open(path, encoding="utf-8").read()
    out = {}
    for m in re.finditer(r'\["([^"]+)"\] = \{picture = "([^"]+)", tint = \{r=([\d.]+),g=([\d.]+),b=([\d.]+)', s):
        out[m.group(1)] = (m.group(2), (float(m.group(3)), float(m.group(4)), float(m.group(5))))
    return out


def srgb_to_lab(rgb):
    c = np.asarray(rgb, np.float64) / 255.0
    c = np.where(c > 0.04045, ((c + 0.055) / 1.055) ** 2.4, c / 12.92)
    M = np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]])
    xyz = M @ c / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.array([116 * f[1] - 16, 500 * (f[0] - f[1]), 200 * (f[1] - f[2])])


def lab_to_srgb(lab):
    L, a, b = lab
    fy = (L + 16) / 116; fx = fy + a / 500; fz = fy - b / 200
    f = np.array([fx, fy, fz])
    xyz = np.where(f ** 3 > 0.008856, f ** 3, (f - 16 / 116) / 7.787) * np.array([0.95047, 1.0, 1.08883])
    Mi = np.linalg.inv(np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]]))
    c = np.clip(Mi @ xyz, 0, 1)
    c = np.where(c > 0.0031308, 1.055 * c ** (1 / 2.4) - 0.055, 12.92 * c)
    return tuple(int(round(v)) for v in np.clip(c * 255, 0, 255))


def tex_mean(path, tint, lo=None):
    a = np.asarray(Image.open(path).convert("RGBA"), np.float64)
    al = a[..., 3] / 255.0
    rgb = a[..., :3] * np.array(tint)
    w = al.sum()
    mean = (rgb * al[..., None]).reshape(-1, 3).sum(0) / w
    lum = rgb @ np.array([0.299, 0.587, 0.114])
    m = (al > 0.5) & (lum <= np.median(lum[al > 0.5]))
    dark = rgb[m].mean(0)
    return mean, dark


author = lua_colors(os.path.join(mod, "prototypes", "tile", "tile-colors.lua"))
tints = tint_table(os.path.join(mod, "prototypes", "tint-matrices.lua"))
tiles = {}
for f in sorted(os.listdir(os.path.join(mod, "graphics", "terrain"))):
    m = re.match(r"^((?:frozen|vegetation)-.+)\.png$", f)
    if m:
        tiles[m.group(1)] = ("graphics/terrain/" + f, (1.0, 1.0, 1.0))
for name, (pic, t) in tints.items():
    tiles[name] = (pic[len(P):], t)

rows, groups = [], {}
for name in sorted(tiles):
    rel, t = tiles[name]
    mean, dark = tex_mean(os.path.join(mod, rel), t)
    lab_t = srgb_to_lab(mean)
    a = author.get(name)
    if a:
        lab_a = srgb_to_lab(a)
        dchroma = float(math.hypot(lab_a[1] - lab_t[1], lab_a[2] - lab_t[2]))
        dL = float(lab_a[0] - lab_t[0])
    else:
        lab_a, dchroma, dL = None, None, None
    rows.append({"tile": name, "author": a, "texture": [round(float(v), 1) for v in mean],
                 "dark": [round(float(v), 1) for v in dark], "dchroma": dchroma, "dL": dL,
                 "lab_t": lab_t, "lab_a": lab_a})
    m = re.match(r"^(mineral|vegetation|volcanic|frozen)-([a-z]+)-(dirt|sand|grass|heat|\d)", name)
    if name.startswith("frozen-"):
        g = "frozen"
    elif m:
        kind = {"mineral": None, "vegetation": "grass", "volcanic": "volcanic"}[m.group(1)]
        g = (m.group(3) if kind is None else kind) + "-" + m.group(2)
    else:
        g = None
    if g:
        groups.setdefault(g, []).append(mean)

if cmd == "analyse":
    print("%-28s %-15s %-18s %6s %6s" % ("tile", "author", "texture", "dChr", "dL"))
    for r in sorted(rows, key=lambda r: -(r["dchroma"] or 0)):
        print("%-28s %-15s %-18s %6s %6s %s" % (r["tile"], r["author"], tuple(int(v) for v in r["texture"]),
              "%.1f" % r["dchroma"] if r["dchroma"] is not None else "-", "%.1f" % r["dL"] if r["dL"] is not None else "-",
              "FIX" if (r["dchroma"] or 0) > thr else ""))
    d = [r["dchroma"] for r in rows if r["dchroma"] is not None]
    print("n=%d median dChr %.1f, over %.0f: %d; median dL %.1f" % (len(d), float(np.median(d)), thr,
          sum(x > thr for x in d), float(np.median([r["dL"] for r in rows if r["dL"] is not None]))))
elif cmd == "particles":
    d = json.load(open(args[1], encoding="utf-8"))
    P_ = d["optimized-particle"]
    print("%-20s %-16s %-16s %6s %6s" % ("group", "particle", "ground", "dChr", "dL"))
    for g in sorted(groups):
        p = P_.get(g + "-stone-particle-tiny")
        if not p:
            print("%-20s no particle" % g); continue
        pic = p["pictures"]
        pic = pic[0] if isinstance(pic, list) else pic
        pic = pic.get("sheet", pic)
        t = pic["tint"]
        S = np.array([t["r"], t["g"], t["b"]]) * 255
        mean = np.mean(groups[g], 0)
        la, lb = srgb_to_lab(S), srgb_to_lab(mean)
        dch = math.hypot(la[1] - lb[1], la[2] - lb[2])
        print("%-20s %-16s %-16s %6.1f %6.1f %s" % (g, tuple(int(round(v)) for v in S), tuple(int(round(v)) for v in mean),
              dch, la[0] - lb[0], "FIX" if dch > thr else ""))
elif cmd == "report":
    import io, contextlib
    d = json.load(open(args[1], encoding="utf-8"))
    out = args[2]
    lines = ["# Цвета карты и частиц против текстур", "",
             "Сгенерировано `tools/colors.py report`. Порог: хроматическое расстояние CIELAB > %g; светлота не учитывается." % thr, ""]
    def verdict(name, dch):
        if dch is None or dch <= thr:
            return ""
        return "намеренно (вулканика)" if name.startswith(("volcanic", "volcanic-")) else "ИСПРАВИТЬ"
    lines += ["## Цвет на карте (map_color)", "", "| тайл | автор | текстура | dChroma | dL | вывод |", "|---|---|---|---|---|---|"]
    for r in sorted(rows, key=lambda r: -(r["dchroma"] or 0)):
        lines.append("| %s | %s | %s | %s | %s | %s |" % (r["tile"], r["author"], tuple(int(v) for v in r["texture"]),
                     "%.1f" % r["dchroma"] if r["dchroma"] is not None else "-", "%.1f" % r["dL"] if r["dL"] is not None else "-",
                     verdict(r["tile"], r["dchroma"])))
    P_ = d["optimized-particle"]
    lines += ["", "## Частицы групп биомов", "", "| группа | частица | земля | dChroma | dL | вывод |", "|---|---|---|---|---|---|"]
    fix = [r["tile"] for r in rows if verdict(r["tile"], r["dchroma"]) == "ИСПРАВИТЬ"]
    for g in sorted(groups):
        p = P_.get(g + "-stone-particle-tiny")
        if not p:
            continue
        pic = p["pictures"]; pic = pic[0] if isinstance(pic, list) else pic; pic = pic.get("sheet", pic)
        t = pic["tint"]; S = np.array([t["r"], t["g"], t["b"]]) * 255; mean = np.mean(groups[g], 0)
        la, lb = srgb_to_lab(S), srgb_to_lab(mean); dch = math.hypot(la[1] - lb[1], la[2] - lb[2])
        v = verdict(g, dch)
        if v == "ИСПРАВИТЬ":
            fix.append(g)
        lines.append("| %s | %s | %s | %.1f | %.1f | %s |" % (g, tuple(int(round(x)) for x in S), tuple(int(round(x)) for x in mean), dch, la[0] - lb[0], v))
    lines += ["", "## Итог", "", ("Исправить: " + ", ".join(fix)) if fix else
              "Исправлять нечего: цвета автора совпадают с землёй по оттенку; превышения порога только у вулканики (намеренно).", ""]
    open(out, "w", encoding="utf-8", newline="\n").write("\n".join(lines))
    print("report:", out, "to fix:", fix)
