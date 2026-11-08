"""Unit/static tests; optionally verify four isolated Factorio data dumps.
python -I -B tools/test_merge_tiles.py
python -I -B tools/test_merge_tiles.py --dumps OLD_NORMAL OLD_ECONOMY NEW_NORMAL NEW_ECONOMY
All arguments to --dumps are data-raw-dump.json files. Does not modify the mod.
"""
import argparse
import copy
import json
import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
import numpy as np
from PIL import Image


def load_tool(name):
    # Do not put tools/ on sys.path: select.py shadows the stdlib select module.
    spec = importlib.util.spec_from_file_location(name, HERE/(name+'.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


merge = load_tool('merge_tiles')
reforge = load_tool('reforge')

MOD = HERE.parent


class FitTests(unittest.TestCase):
    def test_exact_tints_and_multiplicities(self):
        base = np.array([[20., 35, 80], [170, 110, 230], [240, 200, 190]])
        bases = np.stack([base, base])
        old = np.array([[.4, .6, .9], [.8, .5, .2]])
        tint, error = merge.fit_tints(base, bases, np.array([1., 17, 4]), np.array([0, 1]), old)
        np.testing.assert_allclose(tint, old, atol=1e-12)
        np.testing.assert_allclose(error, 0, atol=1e-10)

    def test_compressed_fit_matches_expanded_pixels(self):
        rng = np.random.default_rng(123)
        bases = rng.random((2, 7, 3))*255
        matrix = rng.random((7, 3))*255
        counts = np.array([1, 3, 15, 8, 6, 1, 4])
        idx = np.array([0, 1, 0]); old = rng.random((3, 3))
        t, mse = merge.fit_tints(matrix, bases, counts, idx, old, rounded=True)
        mx = np.repeat(matrix, counts, axis=0)
        for i in range(3):
            target = np.repeat(bases[idx[i]]*old[i], counts, axis=0)
            self.assertAlmostEqual(mse[i], float(np.mean((target-mx*t[i])**2)), places=8)
            np.testing.assert_array_equal(t[i], np.round(t[i], 4))

    def test_tints_cannot_amplify(self):
        matrix = np.ones((5, 3))*10
        t, mse = merge.fit_tints(matrix, np.stack([matrix*20, matrix*30]),
            np.ones(5), np.array([0, 1]), np.ones((2, 3)))
        np.testing.assert_array_equal(t, 1)
        self.assertTrue(np.all(mse > 0))

    def test_mix_endpoints_and_alpha(self):
        rgba = np.array([[100, 200, 50, 255], [100, 200, 50, 0]], dtype=np.uint8)
        p = merge.premult(rgba)
        np.testing.assert_array_equal(p, [[100, 200, 50], [0, 0, 0]])
        bases = np.stack([p, p/2])
        maxima = bases.max(axis=1)
        a = merge.make_matrix(bases, maxima, [0, 0, 0, 1, 1, 1])
        b = merge.make_matrix(bases, maxima, [1, 1, 1, 1, 1, 1])
        np.testing.assert_array_equal(a, b)

    def test_installed_metadata_and_pngs(self):
        report = json.loads((HERE/'data/matrices-report.json').read_text(encoding='utf-8'))
        self.assertEqual(reforge.matrix_problems(report), [])
        tiles = {k:v for k,v in report.items() if merge.tile_family(k)}
        self.assertEqual(len(tiles), 15)
        self.assertEqual(sum(len(v['groups'][0]['colors']) for v in tiles.values()), 144)
        expected = {v['groups'][0]['layers'][0]['file'] for v in tiles.values()}
        root = MOD/'graphics/terrain/matrices'
        self.assertEqual(expected, {p.name for p in root.glob('*.png')})
        lua = (MOD/'prototypes/tint-matrices.lua').read_text(encoding='utf-8')
        self.assertNotIn('economy =', lua)
        self.assertNotIn('-g1.png', lua); self.assertNotIn('-g2.png', lua)
        for name in expected:
            with Image.open(root/name) as im:
                self.assertEqual(im.size, (4096, 576))
                im.load()  # palette is allowed after the user's later optimisation
        audit = json.loads((HERE/'data/tile-merge-report.json').read_text(encoding='utf-8'))
        self.assertEqual(len(audit['families']), 13)
        self.assertEqual(sum(len(r['colors']) for r in audit['families']), 128)
        for row in audit['families']:
            self.assertGreaterEqual(row['worst_psnr']+1e-4, row['best_existing_worst_psnr'])

    def test_invalid_selection_is_rejected_before_writes(self):
        group = {'layers': [{'file': 'test.png', 'blend': 'normal'}],
                 'colors': {'red': {'tints': [[.5, .5, .5]]}}}
        report = {'mineral-dirt-1': {'sources': {}, 'groups': [group, group]}}
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp); (p/'matrices').mkdir()
            (p/'matrices/test.png').write_bytes(b'not a PNG; preflight rejects groups first')
            (p/'report.json').write_text(json.dumps(report))
            marker = p/'installed-marker'; marker.write_text('unchanged')
            old_path = reforge.MATRICES_REPORT
            reforge.MATRICES_REPORT = str(p/'report.json')
            try:
                self.assertEqual(reforge.cmd_matrices(str(p), str(p)), 1)
                self.assertEqual(marker.read_text(), 'unchanged')
                self.assertFalse((p/'graphics').exists())
                self.assertFalse((p/'prototypes').exists())
            finally:
                reforge.MATRICES_REPORT = old_path


def without_tile_recolouring(dump):
    result = copy.deepcopy(dump)
    for tile in result.get('tile', {}).values():
        tile.pop('tint', None)
        for variant in tile.get('variants', {}).get('main', []):
            variant.pop('picture', None)
    return result


def verify_dumps(paths):
    old_normal, old_economy, normal, economy = [json.loads(Path(p).read_text(encoding='utf-8')) for p in paths]
    for label, old, new in [('normal', old_normal, normal), ('economy', old_economy, economy)]:
        assert set(old) == set(new), (label, 'prototype types changed')
        for kind in old:
            assert set(old[kind]) == set(new[kind]), (label, kind, 'prototype names changed')
        a, b = without_tile_recolouring(old), without_tile_recolouring(new)
        differences = [(kind, name) for kind in a for name in a[kind] if a[kind][name] != b[kind][name]]
        assert not differences, (label, 'changes outside tile main.picture/tint', differences[:20])
        print(label, ': prototype sets, gameplay, transitions, frame geometry/weights, decoratives and trees unchanged')
    report = json.loads((HERE/'data/matrices-report.json').read_text(encoding='utf-8'))
    names = []
    for family, row in report.items():
        if not merge.tile_family(family):
            continue
        kind, rest = family.split('-', 1)
        for color in row['groups'][0]['colors']:
            name = f'{kind}-{color}-{rest}'; names.append(name)
            a, b = normal['tile'][name], economy['tile'][name]
            assert a['tint'] == b['tint'], (name, 'mode tints differ')
            aa, bb = a['variants']['main'], b['variants']['main']
            assert [v['size'] for v in aa] == [1, 2, 4], name
            assert [v['count'] for v in aa] == [16, 16, 16], name
            assert [v['size'] for v in bb] == [1, 2], name
            assert [v['count'] for v in bb] == [16, 8], name
            pictures = {v['picture'] for v in aa+bb}
            assert len(pictures) == 1, name
            assert next(iter(pictures)).endswith(row['groups'][0]['layers'][0]['file']), name
    assert len(names) == 144
    print('144 tile prototypes: shared pictures/tints; normal 16/16/16, economy 16/8')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--dumps', nargs=4)
    args = ap.parse_args()
    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(FitTests))
    if not result.wasSuccessful():
        return 1
    if args.dumps:
        verify_dumps(args.dumps)
    return 0


if __name__ == '__main__':
    sys.exit(main())
