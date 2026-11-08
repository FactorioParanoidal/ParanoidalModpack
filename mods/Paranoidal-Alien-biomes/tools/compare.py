"""Compare variant reports: compare.py OUT.md name=report.json ..."""
import sys, json, re, collections

out = sys.argv[1]
vars_ = [a.split("=", 1) for a in sys.argv[2:]]
reps = {n: json.load(open(p)) for n, p in vars_}
keys = sorted(set().union(*[r.keys() for r in reps.values()]))


def summ(fr):
    ms = [m for g in fr["groups"] for m in g["colors"].values()]
    return {
        "psnr_avg": sum(m["psnr"] for m in ms) / len(ms),
        "psnr_min": min(m["psnr"] for m in ms),
        "ssim_avg": sum(m["ssim"] for m in ms) / len(ms),
        "ssim_min": min(m["ssim"] for m in ms),
        "contrast_min": min(m["contrast"] for m in ms),
        "dE_max": max(m["dE_mean"] for m in ms),
        "worst": min(((m["psnr"], c) for g in fr["groups"] for c, m in g["colors"].items()))[1],
    }


lines = ["| family | variant | PSNR avg | PSNR min (color) | SSIM avg | SSIM min | contrast min | dE max |", "|---|---|---|---|---|---|---|---|"]
agg = collections.defaultdict(lambda: collections.defaultdict(list))
for k in keys:
    for n, r in reps.items():
        if k not in r:
            continue
        s = summ(r[k])
        grp = re.sub(r"-\d+$", "", k)
        for f in ("psnr_avg", "psnr_min", "ssim_avg", "ssim_min"):
            agg[grp][n].append(s[f])
        lines.append(f"| {k} | {n} | {s['psnr_avg']:.2f} | {s['psnr_min']:.2f} ({s['worst']}) | {s['ssim_avg']:.4f} | {s['ssim_min']:.4f} | {s['contrast_min']:.3f} | {s['dE_max']:.2f} |")
lines += ["", "| group | variant | PSNR avg | PSNR min avg | SSIM avg | SSIM min avg |", "|---|---|---|---|---|---|"]
for g, d in agg.items():
    for n, l in d.items():
        k = len(l) // 4
        lines.append(f"| {g} | {n} | {sum(l[0::4])/k:.2f} | {sum(l[1::4])/k:.2f} | {sum(l[2::4])/k:.4f} | {sum(l[3::4])/k:.4f} |")
open(out, "w", encoding="utf-8").write("\n".join(lines) + "\n")
print("\n".join(lines[-(len(agg) * len(reps) + 2):]))
