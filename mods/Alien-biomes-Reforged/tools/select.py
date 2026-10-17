"""Pick best variant per family and assemble final matrices.
select.py OUT_DIR PSNR_MIN SSIM_MIN name=variant_dir ...
"""
import sys, os, json, shutil

out, pmin, smin = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
vars_ = [a.split("=", 1) for a in sys.argv[4:]]
reps = {n: (d, json.load(open(os.path.join(d, "report.json")))) for n, d in vars_}
keys = sorted(set().union(*[r.keys() for _, r in reps.values()]))
os.makedirs(os.path.join(out, "matrices"), exist_ok=True)
os.makedirs(os.path.join(out, "previews"), exist_ok=True)
final, table = {}, []
for k in keys:
    cands = []
    for n, (d, r) in reps.items():
        if k not in r:
            continue
        if n == "add2L" and not k.startswith(("lava-", "dune-")):
            continue  # tiles have a single main picture layer in 2.0
        fr = r[k]
        ms = [m for g in fr["groups"] for m in g["colors"].values()]
        files = sum(len(g["layers"]) for g in fr["groups"])
        wp = min(m["psnr"] for m in ms); ws = min(m["ssim"] for m in ms)
        sa = sum(m["ssim"] for m in ms) / len(ms)
        cands.append({"name": n, "dir": d, "files": files, "wp": wp, "ws": ws, "sa": sa,
                      "ok": wp >= pmin and ws >= smin, "n": len(ms)})
    ok = [c for c in cands if c["ok"]]
    if ok:
        fmin = min(c["files"] for c in ok)
        pick = max((c for c in ok if c["files"] == fmin), key=lambda c: (c["wp"], c["sa"]))
    else:
        fmax_allowed = 2
        pool = [c for c in cands if c["files"] <= fmax_allowed]
        pick = max(pool, key=lambda c: (c["wp"], c["sa"]))
    fr = reps[pick["name"]][1][k]
    for g in fr["groups"]:
        for L in g["layers"]:
            shutil.copy2(os.path.join(pick["dir"], "matrices", L["file"]), os.path.join(out, "matrices", L["file"]))
    shutil.copy2(os.path.join(pick["dir"], "previews", k + ".png"), os.path.join(out, "previews", k + ".png"))
    fr["picked"] = pick["name"]
    final[k] = fr
    table.append(f"| {k} | {pick['n']} | {pick['files']} | {pick['name']} | {pick['wp']:.2f} | {pick['ws']:.4f} | {pick['sa']:.4f} | {'yes' if pick['ok'] else 'no (best of <=2)'} |")
json.dump(final, open(os.path.join(out, "report.json"), "w"), indent=1)
hdr = ["| family | originals | matrices | variant | worst PSNR | worst SSIM | avg SSIM | passes threshold |", "|---|---|---|---|---|---|---|---|"]
open(os.path.join(out, "selection.md"), "w", encoding="utf-8").write("\n".join(hdr + table) + "\n")
print("\n".join(hdr + table))
print("originals", sum(int(t.split("|")[2]) for t in table), "matrices", sum(int(t.split("|")[3]) for t in table))
