"""Alien Biomes tint-matrix analysis and builder.

Usage (run with python -I):
  abtint.py survey  GRAPHICS_DIR OUT_DIR [--only REGEX]
  abtint.py build   GRAPHICS_DIR OUT_DIR PLAN_JSON [--only REGEX]

Model: Factorio renders a tinted sprite as premultiplied(texture) * tint, so every
fit is done on premultiplied RGB.  For a family of same-pattern images X_c the
matrix M and tints t_c minimise sum_c ||X_c - t_c * M||^2 (rank-1 factorisation).
"""
import sys, os, re, json, itertools, math
import numpy as np
from PIL import Image, ImageDraw

LUMA = np.array([0.299, 0.587, 0.114], np.float64)


# ---------------------------------------------------------------- families
def find_families(gdir):
    fam = {}
    tdir = os.path.join(gdir, "terrain")
    for f in sorted(os.listdir(tdir)):
        m = re.match(r"^mineral-([a-z]+)-((?:dirt|sand)-\d+)\.png$", f)
        if m:
            fam.setdefault("mineral-" + m.group(2), {})[m.group(1)] = os.path.join(tdir, f); continue
        m = re.match(r"^volcanic-([a-z]+)-(heat-\d+)\.png$", f)
        if m:
            fam.setdefault("volcanic-" + m.group(2), {})[m.group(1)] = os.path.join(tdir, f); continue
        m = re.match(r"^vegetation-([a-z]+)-(grass-\d+)\.png$", f)
        if m:
            fam.setdefault("vegetation-" + m.group(2), {})[m.group(1)] = os.path.join(tdir, f); continue
        m = re.match(r"^frozen-snow-(\d+)\.png$", f)
        if m:
            fam.setdefault("frozen-snow", {})["snow-" + m.group(1)] = os.path.join(tdir, f); continue
    ddir = os.path.join(gdir, "decorative", "dune")
    for color in sorted(os.listdir(ddir)):
        sd = os.path.join(ddir, color, "sand-dune-decal")
        for f in sorted(os.listdir(sd)):
            m = re.match(r"^sand-dune-decal-(\d+)\.png$", f)
            if m:
                fam.setdefault("dune-" + m.group(1), {})[color] = os.path.join(sd, f)
    ldir = os.path.join(gdir, "decorative", "lava")
    for color in sorted(os.listdir(ldir)):
        for f in sorted(os.listdir(os.path.join(ldir, color))):
            m = re.match(r"^lava-decal-(\d+)\.png$", f)
            if m:
                fam.setdefault("lava-" + m.group(1), {})[color] = os.path.join(ldir, color, f)
    return {k: v for k, v in fam.items() if len(v) > 1}


def load_family(files):
    colors = sorted(files)
    imgs = [np.asarray(Image.open(files[c]).convert("RGBA"), np.float32) for c in colors]
    shapes = {i.shape for i in imgs}
    if len(shapes) != 1:
        raise ValueError("shape mismatch %s" % shapes)
    return colors, np.stack(imgs)  # n,H,W,4


# ---------------------------------------------------------------- algebra
def premult(imgs):
    a = imgs[..., 3:4] / 255.0
    return imgs[..., :3] * a, imgs[..., 3]


def gram_rows(X):
    """X: rows x P float32 -> float64 gram, chunked."""
    R, P = X.shape
    G = np.zeros((R, R), np.float64)
    step = 1 << 20
    for s in range(0, P, step):
        B = X[:, s:s + step].astype(np.float64)
        G += B @ B.T
    return G


def rank1_err(Gs):
    w = np.linalg.eigvalsh(Gs)
    return float(np.trace(Gs) - w[-1])


def subset_err(G, n, idx, model):
    """G rows ordered (c, ch) -> c*3+ch."""
    if model == "grey":
        rows = [c * 3 + ch for c in idx for ch in range(3)]
        return rank1_err(G[np.ix_(rows, rows)])
    e = 0.0
    for ch in range(3):
        rows = [c * 3 + ch for c in idx]
        e += rank1_err(G[np.ix_(rows, rows)])
    return e


def best_partition(G, n, k, model):
    full = (1 << n) - 1
    err = {}
    for mask in range(1, full + 1):
        idx = [i for i in range(n) if mask >> i & 1]
        err[mask] = subset_err(G, n, idx, model)
    best = {0: (0.0, [])}
    for _ in range(k):
        nb = {}
        for done, (e0, parts) in best.items():
            rest = full & ~done
            if rest == 0:
                continue
            low = rest & -rest
            sub = rest
            while sub:
                if sub & low:
                    m2 = done | sub
                    e = e0 + err[sub]
                    if m2 not in nb or e < nb[m2][0]:
                        nb[m2] = (e, parts + [sub])
                sub = (sub - 1) & rest
        best = nb
    e, parts = best[full]
    return e, [[i for i in range(n) if p >> i & 1] for p in parts]


# ---------------------------------------------------------------- fitting
def _top_vec(X):
    G = gram_rows(X)
    w, V = np.linalg.eigh(G)
    u = V[:, -1]
    if u.sum() < 0:
        u = -u
    return u


def rank1_shape(sub, model, rw):
    """Weighted rank-1. sub: k,H,W,3 premult. rw: row weights (k). Returns mp (H,W,3), u (k or k,3)."""
    k, H, W = sub.shape[:3]
    sq = np.sqrt(rw).astype(np.float32)
    if model == "grey":
        X = np.concatenate([(sub[i, ..., ch] * sq[i]).reshape(1, -1) for i in range(k) for ch in range(3)])
        u = _top_vec(X)
        m = (u.astype(np.float32) @ X).reshape(H, W)
        u = (u.reshape(k, 3) / sq[:, None])
        return np.repeat(m[..., None], 3, -1), u
    mp = np.zeros((H, W, 3), np.float32)
    U = np.zeros((k, 3))
    for ch in range(3):
        X = np.concatenate([(sub[i, ..., ch] * sq[i]).reshape(1, -1) for i in range(k)])
        u = _top_vec(X)
        mp[..., ch] = (u.astype(np.float32) @ X).reshape(H, W)
        U[:, ch] = u / sq
    return mp, U


def quantize(straight, am):
    H, W = am.shape
    q = np.zeros((H, W, 4), np.uint8)
    q[..., :3] = np.clip(np.round(straight), 0, 255).astype(np.uint8)
    q[..., 3] = am.astype(np.uint8)
    valid = am > 0
    if valid.any():
        q[..., :3][~valid] = np.round(q[..., :3][valid].mean(0)).astype(np.uint8)
    return q


def premult_q(q):
    return q[..., :3].astype(np.float32) * (q[..., 3:4].astype(np.float32) / 255.0)


def ls_tints(Xp, mq, idx, lo=0.0, hi=1.0):
    out = []
    for i in idx:
        t = []
        for ch in range(3):
            x = mq[..., ch].ravel().astype(np.float64); y = Xp[i, ..., ch].ravel().astype(np.float64)
            d = x @ x
            t.append(float(np.clip((x @ y) / d if d else 0.0, lo, hi)))
        out.append(t)
    return out


def sse_colors(Xp, idx, recs):
    return [float(((Xp[i].astype(np.float64) - r) ** 2).sum()) for i, r in zip(idx, recs)]


def fit_group(Xp, A, idx, model, weighting):
    """Single-layer: Xp_i ~ tint_i * premult(M). Returns layers description."""
    sub = Xp[idx]
    am = np.clip(np.round(A[idx].mean(0)), 0, 255)
    amf = np.maximum(am / 255.0, 1e-6)[..., None]
    k = len(idx)
    rw = np.ones(k)
    if weighting == "equal":
        rw = 1.0 / np.array([float((sub[i].astype(np.float64) ** 2).sum()) for i in range(k)])
        rw /= rw.mean()
    iters = 5 if weighting == "minimax" else 1
    for it in range(iters):
        mp, U = rank1_shape(sub, model, rw)
        if weighting == "minimax":
            e = np.array([float(((sub[i] - mp * U[i].astype(np.float32)) ** 2).sum()) for i in range(k)])
            rw = rw * (e / e.mean()) ** 1.0
            rw /= rw.mean()
    # base scale: brightest colour per channel gets tint 1
    umax = U.max(0) if model != "grey" else np.full(3, U.max())
    S0 = np.where(am[..., None] > 0, mp / amf, 0) * umax.astype(np.float32)
    best = None
    for f in (0.85, 0.9, 0.95, 1.0, 1.04, 1.08, 1.12, 1.18, 1.25):
        q = quantize(S0 * f, am)
        mq = premult_q(q)
        tints = ls_tints(Xp, mq, idx)
        e = sum(sse_colors(Xp, idx, [mq * np.array(t, np.float32) for t in tints]))
        if best is None or e < best[0]:
            best = (e, f, q, tints)
    e, f, q, tints = best
    return {"scale": f, "layers": [{"img": q, "blend": "normal", "tints": tints}]}


def fit_group_additive(Xp, A, idx, iters=25):
    """Two layers: X_i ~ B (untinted, normal) + t_i * G (additive glow)."""
    sub = Xp[idx].astype(np.float32)
    k, H, W = sub.shape[:3]
    am = np.clip(np.round(A[idx].mean(0)), 0, 255)
    B = np.zeros((H, W, 3), np.float32); G = np.zeros((H, W, 3), np.float32)
    T = np.zeros((k, 3))
    for ch in range(3):
        X = sub[..., ch].reshape(k, -1)
        mu = X.mean(0)
        C = X - mu
        u = _top_vec(C)
        g = u.astype(np.float32) @ C
        if (g > 0).sum() < (g < 0).sum():
            g, u = -g, -u
        s = u.min()
        b = mu + s * g; t = u - s
        g = np.maximum(g, 0); b = np.maximum(b, 0)
        for _ in range(iters):
            t = np.clip([(g @ (X[i] - b)) / max(float(g @ g), 1e-9) for i in range(k)], 0, None)
            b = np.maximum((X - np.outer(t, g).astype(np.float32)).mean(0), 0)
            tt = float((t ** 2).sum())
            g = np.maximum((t.astype(np.float32) @ (X - b)) / max(tt, 1e-9), 0)
        sc = t.max() if t.max() > 0 else 1.0
        B[..., ch] = b.reshape(H, W); G[..., ch] = (g * sc).reshape(H, W); T[:, ch] = t / sc
    amf = np.maximum(am / 255.0, 1e-6)[..., None]
    qb = quantize(np.where(am[..., None] > 0, B / amf, 0), am)
    # glow layer: alpha 255 so premult == rgb; additive blend adds rgb*tint
    qg = np.zeros((H, W, 4), np.uint8)
    qg[..., :3] = np.clip(np.round(G), 0, 255).astype(np.uint8)
    qg[..., 3] = np.where(G.max(-1) > 0.5, 255, 0).astype(np.uint8)
    mb = premult_q(qb); mg = premult_q(qg)
    tints = []
    for i in range(k):
        resid = sub[i] - mb
        t = []
        for ch in range(3):
            x = mg[..., ch].ravel().astype(np.float64); y = resid[..., ch].ravel().astype(np.float64)
            d = x @ x
            t.append(float(np.clip((x @ y) / d if d else 0.0, 0, 1)))
        tints.append(t)
    return {"scale": 1.0, "layers": [{"img": qb, "blend": "normal", "tints": [[1.0, 1.0, 1.0]] * k},
                                     {"img": qg, "blend": "additive", "tints": tints}]}


def render_layers(fit, j):
    out = None
    for L in fit["layers"]:
        r = premult_q(L["img"]) * np.array(L["tints"][j], np.float32)
        if out is None:
            out = r
        elif L["blend"] == "normal":
            out = r + out * (1 - L["img"][..., 3:4].astype(np.float32) / 255.0)
        else:
            out = out + r
    return out


# ---------------------------------------------------------------- metrics
def box(img, r=3):
    k = 2 * r + 1
    p = np.pad(img, r, mode="edge").astype(np.float64)
    c = p.cumsum(0).cumsum(1)
    c = np.pad(c, ((1, 0), (1, 0)))
    return (c[k:, k:] - c[:-k, k:] - c[k:, :-k] + c[:-k, :-k]) / (k * k)


def ssim(a, b):
    C1, C2 = (0.01 * 255) ** 2, (0.03 * 255) ** 2
    ma, mb = box(a), box(b)
    va = box(a * a) - ma * ma; vb = box(b * b) - mb * mb; cv = box(a * b) - ma * mb
    s = ((2 * ma * mb + C1) * (2 * cv + C2)) / ((ma * ma + mb * mb + C1) * (va + vb + C2))
    return s


def srgb_to_lab(rgb):
    c = rgb / 255.0
    c = np.where(c > 0.04045, ((c + 0.055) / 1.055) ** 2.4, c / 12.92)
    M = np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]])
    xyz = c @ M.T / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.stack([116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])], -1)


def metrics(orig_p, alpha_o, rec_p, mask):
    d = orig_p[mask] - rec_p[mask]
    rmse = float(np.sqrt((d.astype(np.float64) ** 2).mean()))
    lo = orig_p @ LUMA.astype(np.float32); lr = rec_p @ LUMA.astype(np.float32)
    ss = float(ssim(lo, lr)[mask].mean())
    so, sr = float(lo[mask].std()), float(lr[mask].std())
    lab_o = srgb_to_lab(orig_p[mask].mean(0)); lab_r = srgb_to_lab(rec_p[mask].mean(0))
    return {"rmse": round(rmse, 3), "psnr": round(20 * math.log10(255 / max(rmse, 1e-6)), 2),
            "ssim": round(ss, 4), "contrast": round(sr / so, 3) if so else None,
            "dE_mean": round(float(np.linalg.norm(lab_o - lab_r)), 2)}


# ---------------------------------------------------------------- commands
def survey(gdir, out, only):
    fams = find_families(gdir)
    res = {}
    for key in sorted(fams):
        if only and not re.search(only, key):
            continue
        colors, imgs = load_family(fams[key])
        n = len(colors)
        Xp, A = premult(imgs)
        X = np.concatenate([Xp[i, ..., ch].reshape(1, -1) for i in range(n) for ch in range(3)])
        G = gram_rows(X); del X
        tot = float(np.trace(G))
        P = int(np.count_nonzero(A.max(0) > 0))
        r = {"n": n, "colors": colors, "shape": list(imgs.shape[1:3]), "pixels": P}

        def rm(e):
            return round(math.sqrt(max(e, 0) / (n * 3 * P)), 2)
        r["grey_k1"] = rm(subset_err(G, n, list(range(n)), "grey"))
        r["rgb_k1"] = rm(subset_err(G, n, list(range(n)), "rgb"))
        for k in (2, 3):
            if n > k and n <= 12:
                e, parts = best_partition(G, n, k, "rgb")
                r["rgb_k%d" % k] = rm(e)
                r["rgb_k%d_parts" % k] = [[colors[i] for i in p] for p in parts]
        # alpha agreement
        r["alpha_maxdiff"] = float(np.abs(A - A.mean(0)).max())
        r["alpha_meandiff"] = round(float(np.abs(A - A.mean(0)).mean()), 3)
        res[key] = r
        print(key, json.dumps({k: v for k, v in r.items() if k not in ("colors",)}), flush=True)
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "survey.json"), "w") as f:
        json.dump(res, f, indent=1)


def preview(path, colors, imgs_p, recs, crop):
    rows = []
    for c, o, r in zip(colors, imgs_p, recs):
        oc = o[crop]; rc = r[crop]
        diff = np.clip(np.abs(oc - rc) * 4, 0, 255)
        rows.append(np.concatenate([oc, rc, diff], 1))
    h, w = rows[0].shape[0], rows[0].shape[1] // 3
    img = np.clip(np.concatenate(rows, 0), 0, 255).astype(np.uint8)
    im = Image.fromarray(img)
    d = ImageDraw.Draw(im)
    for i, c in enumerate(colors):
        d.text((4, i * h + 4), c + " original", fill=(255, 255, 255))
        d.text((w + 4, i * h + 4), "matrix*tint", fill=(255, 255, 255))
        d.text((2 * w + 4, i * h + 4), "|diff|x4", fill=(255, 255, 255))
    im.save(path, optimize=True)


def build(gdir, out, plan_path, only):
    fams = find_families(gdir)
    plan = json.load(open(plan_path))
    os.makedirs(os.path.join(out, "matrices"), exist_ok=True)
    os.makedirs(os.path.join(out, "previews"), exist_ok=True)
    report = {}
    for key in sorted(fams):
        if only and not re.search(only, key):
            continue
        spec = plan["families"].get(key, plan.get("default"))
        if not spec:
            continue
        colors, imgs = load_family(fams[key])
        n = len(colors)
        Xp, A = premult(imgs)
        mask = A.max(0) > 0
        groups = spec.get("groups") or [colors]
        fam_rep = {"variant": spec, "sources": {c: os.path.relpath(fams[key][c], gdir).replace(os.sep, "/") for c in colors},
                   "size": [int(imgs.shape[2]), int(imgs.shape[1])], "groups": []}
        recs = [None] * n
        for gi, g in enumerate(groups):
            idx = [colors.index(c) for c in g]
            if spec["model"] == "additive":
                fit = fit_group_additive(Xp, A, idx)
            else:
                fit = fit_group(Xp, A, idx, spec["model"], spec.get("weighting", "plain"))
            name = key if len(groups) == 1 else "%s-g%d" % (key, gi + 1)
            grp = {"scale": fit["scale"], "layers": [], "colors": {}}
            for li, L in enumerate(fit["layers"]):
                lname = name + ("" if li == 0 else "-glow") + ".png"
                Image.fromarray(L["img"]).save(os.path.join(out, "matrices", lname), optimize=True)
                grp["layers"].append({"file": lname, "blend": L["blend"]})
            for j, i in enumerate(idx):
                rec = render_layers(fit, j)
                recs[i] = rec
                mt = metrics(Xp[i], A[i], rec, mask)
                mt["tints"] = [[round(v, 4) for v in L["tints"][j]] for L in fit["layers"]]
                grp["colors"][colors[i]] = mt
            fam_rep["groups"].append(grp)
        report[key] = fam_rep
        H, W = imgs.shape[1:3]
        ch = min(H, 256); cw = min(W, 512)
        y0 = 0 if H <= 256 else 128
        crop = (slice(y0, y0 + ch), slice(0, cw))
        preview(os.path.join(out, "previews", key + ".png"), colors, Xp, recs, crop)
        worst = min(m["psnr"] for g in fam_rep["groups"] for m in g["colors"].values())
        print(key, json.dumps(spec), "worst psnr", worst, flush=True)
    rp = os.path.join(out, "report.json")
    old = json.load(open(rp)) if os.path.exists(rp) else {}
    old.update(report)
    with open(rp, "w") as f:
        json.dump(old, f, indent=1)


if __name__ == "__main__":
    args = sys.argv[1:]
    only = None
    if "--only" in args:
        i = args.index("--only"); only = args[i + 1]; del args[i:i + 2]
    if args[0] == "survey":
        survey(args[1], args[2], only)
    elif args[0] == "build":
        build(args[1], args[2], args[3], only)
