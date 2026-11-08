"""Merge terrain g1/g2 bases against the CURRENT rendered Reforged colours.

python -I -B merge_tiles.py --source BACKUP_MOD --out NEW_EMPTY_DIRECTORY
Requires numpy, Pillow and scipy. Source is read-only; never edits the installed mod.
Outputs a complete reforge.py matrices selection, metrics and per-colour previews.
New PNGs are RGBA8, compress_level=0: no palette, lossy encoding or PNG optimisation.

Fit only the 48 loaded main frames, not unused sheet padding. A channel-wise
nonnegative mixture of the two normalised premultiplied bases, with optional
highlight clipping, is fitted jointly with bounded RGB tints. SLSQP minimises the
worst colour MSE (epigraph formulation, three starts); this is a numerical search,
not a claim of global optimality. Identical source pixel pairs are counted once
with their exact multiplicities, so fitting uses all loaded pixels, not a sample.
Compare quantised output + four-decimal tints against BOTH existing bases refitted
to the same targets, and never select a worse worst-colour MSE. Single-base tiles
and all decorative images are copied byte-for-byte; their metadata is preserved.
"""
import argparse
import copy
import hashlib
import json
import math
from pathlib import Path
import sys

sys.dont_write_bytecode = True
import numpy as np
import PIL
from PIL import Image, ImageDraw
import scipy
from scipy.optimize import minimize

TILE_KINDS = ('mineral', 'vegetation', 'volcanic')
REGIONS = [(0, 0, 1024, 64), (0, 128, 2048, 256), (0, 320, 4096, 576)]


def tile_family(name):
    return name.split('-')[0] in TILE_KINDS


def matdir(name):
    kind = name.split('-')[0]
    return 'terrain/matrices' if tile_family(name) else f'decorative/{kind}/matrices'


def save_json(path, value):
    path.write_text(json.dumps(value, indent=1, ensure_ascii=False, sort_keys=True) + '\n', encoding='utf-8')


def premult(a):
    return a[..., :3].astype(np.float64) * (a[..., 3:4].astype(np.float64) / 255)


def used(a):
    return np.concatenate([a[y:y2, x:x2].reshape(-1, a.shape[-1]) for x, y, x2, y2 in REGIONS])


def psnr(mse):
    return 10 * math.log10(255**2 / max(float(mse), 1e-20))


def fit_tints(matrix, bases, counts, group_index, old_tints, rounded=False):
    """Exact sufficient statistics; bases shape (2, unique_pixel_pairs, 3)."""
    weights = counts[:, None]
    mm = np.sum(matrix * matrix * weights, axis=0)
    cross = np.sum(bases * matrix[None] * weights[None], axis=1)
    norm = np.sum(bases * bases * weights[None], axis=1)
    xy = cross[group_index] * old_tints
    yy = norm[group_index] * old_tints**2
    tints = np.clip(xy / np.maximum(mm, 1e-20), 0, 1)
    if rounded:
        tints = np.round(tints, 4)  # exactly what tintlua emits
    mse = np.maximum((yy - 2*tints*xy + tints*tints*mm).sum(axis=1) / (3*counts.sum()), 0)
    return tints, mse


def make_matrix(bases, maxima, params):
    q, gain = np.array(params[:3]), np.array(params[3:6])
    norm = bases * (255 / maxima[:, None, :])
    return np.clip((norm[0]*(1-q) + norm[1]*q) * gain, 0, 255)


def preview(path, before, after, title):
    # Two complete 4x4 frames at native resolution. Display only, not game screenshots.
    a, b = before[320:576, 512:1024], after[320:576, 512:1024]
    canvas = Image.new('RGB', (1536, 288), (28, 28, 28))
    draw = ImageDraw.Draw(canvas)
    for i, (img, label) in enumerate(zip([a, b, np.abs(a-b)*4],
            ['Before: ' + title, 'Merged base x new tint', 'Absolute difference x4'])):
        canvas.paste(Image.fromarray(np.clip(np.rint(img), 0, 255).astype(np.uint8)), (i*512, 32))
        draw.text((i*512+5, 8), label, fill='white')
    canvas.save(path)


def merge_family(name, fr, source, out):
    filenames = [g['layers'][0]['file'] for g in fr['groups']]
    images = [np.asarray(Image.open(source/'graphics'/matdir(name)/f).convert('RGBA')) for f in filenames]
    if any(a.shape != (576, 4096, 4) for a in images):
        raise ValueError(f'{name}: unexpected sheet layout')
    flat = [used(a) for a in images]
    pairs, counts = np.unique(np.concatenate(flat, axis=1), axis=0, return_counts=True)
    bases = np.stack([premult(pairs[:, :4]), premult(pairs[:, 4:])])
    counts = counts.astype(np.float64)
    names, group_index, old_tints = [], [], []
    for i, group in enumerate(fr['groups']):
        if len(group['layers']) != 1:
            raise ValueError(f'{name}: expected one layer per group')
        for color, info in sorted(group['colors'].items()):
            names.append(color); group_index.append(i); old_tints.append(info['tints'][0])
    group_index = np.array(group_index)
    old_tints = np.round(np.array(old_tints), 4)  # installed Lua precision, not latent fit precision
    maxima = np.maximum(bases.max(axis=1), 1e-12)
    candidates = []

    def add_candidate(label, matrix, params=None, existing=None):
        # New files flatten premultiplied pixels onto opaque tile frames.
        # Existing baseline candidates keep their original alpha/pixels exactly.
        rendered = premult(matrix) if existing is not None else np.rint(matrix)
        ts, err = fit_tints(rendered, bases, counts, group_index, old_tints, rounded=True)
        candidates.append({'label': label, 'params': params, 'existing': existing,
                           'tints': ts, 'mse': err})

    for i in range(2):
        add_candidate(f'existing-g{i+1}', pairs[:, i*4:(i+1)*4], existing=i)
    scale = max(1.0, min(float(c['mse'].max()) for c in candidates))
    searches = []
    for start in (0.0, 0.5, 1.0):
        params = np.array([start]*3 + [1.0]*3)
        def errors(p):
            return fit_tints(make_matrix(bases, maxima, p), bases, counts,
                             group_index, old_tints)[1] / scale
        initial = np.r_[params, errors(params).max() + 1e-6]
        result = minimize(lambda p: p[6], initial, method='SLSQP',
            bounds=[(0, 1)]*3 + [(0.75, 1.5)]*3 + [(0, None)],
            constraints=[{'type': 'ineq', 'fun': lambda p: p[6]-errors(p[:6])}],
            options={'maxiter': 160, 'ftol': 1e-10})
        p = result.x[:6]
        add_candidate(f'minimax-start-{start:g}', make_matrix(bases, maxima, p), params=p.tolist())
        searches.append({'start': start, 'success': bool(result.success),
                         'message': str(result.message), 'iterations': int(result.nit)})
    best = min(candidates, key=lambda c: (float(c['mse'].max()), float(c['mse'].mean())))
    full_bases = np.stack([premult(a) for a in images])
    if best['existing'] is not None:
        rgba = images[best['existing']].copy()
    else:
        q = np.array(best['params'][:3]); gain = np.array(best['params'][3:])
        norm = full_bases * (255 / maxima[:, None, None, :])
        rgb = np.rint(np.clip((norm[0]*(1-q) + norm[1]*q)*gain, 0, 255)).astype(np.uint8)
        rgba = np.zeros_like(images[0])
        for x,y,x2,y2 in REGIONS:
            rgba[y:y2,x:x2,:3] = rgb[y:y2,x:x2]
            rgba[y:y2,x:x2,3] = 255
    filename = name + '.png'
    Image.fromarray(rgba).save(out/'matrices'/filename, compress_level=0, optimize=False)
    # Reopen and verify full-colour, lossless writing.
    with Image.open(out/'matrices'/filename) as check:
        assert check.mode == 'RGBA' and np.array_equal(np.asarray(check), rgba)
    rendered = premult(rgba)
    new_colors, color_metrics = {}, {}
    for i, color in enumerate(names):
        before = full_bases[group_index[i]] * old_tints[i]
        after = rendered * best['tints'][i]
        # Independent full-pixel check against compressed-pair sufficient statistics.
        delta = used(before) - used(after)
        mse = float(np.mean(delta**2))
        assert abs(mse-best['mse'][i]) < 1e-6, (name, color, mse, best['mse'][i])
        metric = {'rmse': round(math.sqrt(mse), 6), 'psnr': round(psnr(mse), 4)}
        new_colors[color] = {**metric, 'tints': [best['tints'][i].tolist()]}
        color_metrics[color] = {**metric, 'old_matrix': filenames[group_index[i]],
            'old_tint': old_tints[i].tolist(), 'new_tint': best['tints'][i].tolist()}
        preview(out/'previews'/f'{name}-{color}.png', before, after, name+' / '+color)
    new = copy.deepcopy(fr)
    new['variant'] = {'model': 'rgb', 'weighting': 'worst-colour-mse', 'groups': 1}
    new['picked'] = best['label']
    new['metric_reference'] = 'installed Reforged before merge; loaded main frames only; not upstream'
    new['groups'] = [{'scale': 1.0, 'layers': [{'file': filename, 'blend': 'normal'}], 'colors': new_colors}]
    baseline = min(candidates[:2], key=lambda c: (float(c['mse'].max()), float(c['mse'].mean())))
    summary = {'family': name, 'selected': best['label'], 'parameters': best['params'],
        'output_png_sha256': hashlib.sha256((out/'matrices'/filename).read_bytes()).hexdigest(),
        'source_sha256': {f: hashlib.sha256((source/'graphics'/matdir(name)/f).read_bytes()).hexdigest() for f in filenames},
        'unique_pixel_pairs': len(pairs), 'pixels_evaluated': int(counts.sum()),
        'searches': searches, 'worst_psnr': round(psnr(best['mse'].max()), 4),
        'best_existing_worst_psnr': round(psnr(baseline['mse'].max()), 4),
        'mean_mse': round(float(best['mse'].mean()), 6),
        'worst_color': names[int(np.argmax(best['mse']))], 'colors': color_metrics,
        'candidates': [{'name': c['label'], 'worst_psnr': round(psnr(c['mse'].max()), 4),
                        'mean_mse': round(float(c['mse'].mean()), 6)} for c in candidates]}
    print(name, best['label'], 'worst PSNR', summary['worst_psnr'],
          'existing', summary['best_existing_worst_psnr'], flush=True)
    return new, summary


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    source, out = args.source.resolve(), args.out.resolve()
    if out.exists():
        ap.error('--out must not exist (protects previous outputs)')
    report = json.loads((source/'tools/data/matrices-report.json').read_text(encoding='utf-8'))
    if not any(tile_family(k) and len(v['groups']) == 2 for k,v in report.items()):
        ap.error('source has no two-group tiles; use the pre-merge backup')
    out.mkdir(parents=True); (out/'matrices').mkdir(); (out/'previews').mkdir()
    audit = {'reference': 'current rendered source mod, not upstream', 'regions': REGIONS,
             'environment': {'python': sys.version.split()[0], 'numpy': np.__version__,
                             'Pillow': PIL.__version__, 'scipy': scipy.__version__},
             'generator_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
             'source_report_sha256': hashlib.sha256((source/'tools/data/matrices-report.json').read_bytes()).hexdigest(),
             'source_version': json.loads((source/'info.json').read_text())['version'],
             'png_encoding': 'RGBA8; no palette; compress_level=0; no optimiser', 'families': []}
    final = copy.deepcopy(report)
    for name, fr in sorted(report.items()):
        if tile_family(name) and len(fr['groups']) == 2:
            final[name], summary = merge_family(name, fr, source, out)
            audit['families'].append(summary)
        else:
            if tile_family(name) and len(fr['groups']) != 1:
                raise ValueError(f'{name}: unsupported number of groups')
            for group in fr['groups']:
                for layer in group['layers']:
                    (out/'matrices'/layer['file']).write_bytes((source/'graphics'/matdir(name)/layer['file']).read_bytes())
    save_json(out/'report.json', final)
    save_json(out/'tile-merge-report.json', audit)
    lines = ['# Tile merge: current Reforged reference (not upstream)', '',
             '| Family | New worst PSNR | Best existing base, worst PSNR | Worst colour |',
             '|---|---:|---:|---|']
    for r in audit['families']:
        lines.append(f"| {r['family']} | {r['worst_psnr']:.2f} | {r['best_existing_worst_psnr']:.2f} | {r['worst_color']} |")
    (out/'tile-merge-report.md').write_text('\n'.join(lines)+'\n', encoding='utf-8')


if __name__ == '__main__':
    main()
