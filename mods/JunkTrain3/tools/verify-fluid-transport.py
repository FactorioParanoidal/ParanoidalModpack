#!/usr/bin/env python3
"""Check MK0 fluid transport against Factorio's final, full-pack --dump-data."""
import argparse
import configparser
import json
from pathlib import Path
import struct
import sys
from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('dump', type=Path)
p.add_argument('--report', type=Path, help='Write machine-readable verification results')
a = p.parse_args()
d = json.loads(a.dump.read_text())
errors = []
def check(ok, message):
    if not ok:
        errors.append(message)

def proto(kind, name):
    result = d.get(kind, {}).get(name)
    check(result is not None, f'Missing {kind}: {name}')
    return result or {}

wagon = proto('fluid-wagon', 'yir_us_fluid')
pump = proto('pump', 'scrap-fluid-pump')
tech = proto('technology', 'scrap-fluid-handling')
for name in ['ScrapFluidTrailer', 'scrap-fluid-pump']:
    proto('item', name)
    proto('recipe', name)
if errors:
    if a.report:
        a.report.write_text(json.dumps({'passed': False, 'dump': str(a.dump), 'errors': errors}, indent=2) + '\n')
    print('\n'.join('FAIL: ' + e for e in errors))
    sys.exit(1)

cargo = d['cargo-wagon']['yir_us_cargo']
for field in ['max_health', 'weight', 'max_speed', 'braking_force', 'friction_force', 'air_resistance', 'connection_distance', 'joint_distance', 'collision_box', 'selection_box', 'vertical_selection_shift']:
    check(wagon.get(field) == cargo.get(field), f'Wagon must match cargo {field}')
check(wagon.get('capacity') == 5000, 'Wagon capacity must be 5000')
check(wagon.get('tank_count') == 1, 'Wagon must have one tank')
check(wagon.get('quality_affects_capacity') is False, 'Quality must not increase wagon capacity')
check(pump.get('pumping_speed') == 5, 'Pump must transfer 300/s (5/tick)')
check(pump.get('energy_source', {}).get('type') == 'electric', 'Pump must be electric')
check(set(tech.get('prerequisites', [])) == {'JunkTrain_tech', 'basic-fluid-handling'}, 'Technology prerequisites')
check(tech['unit']['count'] == 50 and tech['unit']['time'] == 20, 'Technology cost')
check(tech['unit']['ingredients'] == [['automation-science-pack', 1]], 'Technology science')
unlocks = {e.get('recipe') for e in tech.get('effects', []) if e['type'] == 'unlock-recipe'}
check({'ScrapFluidTrailer', 'scrap-fluid-pump'} <= unlocks, 'Both recipes must unlock')
expected = {
    'ScrapFluidTrailer': {'bob-small-inline-storage-tank': 1, 'iron-plate': 10, 'iron-stick': 4, 'wood': 20},
    'scrap-fluid-pump': {'electric-motor': 1, 'iron-plate': 4, 'pipe': 2},
}
for name, ingredients in expected.items():
    r = d['recipe'][name]
    check({i['name']: i['amount'] for i in r['ingredients']} == ingredients, f'{name} ingredients')
    check(r.get('enabled') is False, f'{name} must require research')
    check(r['results'] == [{'type': 'item', 'name': name, 'amount': 1}], f'{name} output')
    check(d['item'][name].get('place_result') == ('yir_us_fluid' if name == 'ScrapFluidTrailer' else name), f'{name} placement')
    recycling = d['recipe'].get(name + '-recycling')
    check(recycling is not None, f'{name} recycling recipe')
    if recycling:
        outputs = {o['name'] for o in recycling.get('results', [])}
        check(outputs == set(ingredients), f'{name} recycling outputs')
        for output in recycling.get('results', []):
            amount = output.get('amount', 0) + output.get('extra_count_fraction', 0)
            check(abs(amount - ingredients[output['name']] * .25) < 1e-6, f'{name} recycling yield: {output["name"]}')
check(d['recipe']['scrap-fluid-pump'].get('subgroup') == d['recipe']['pump'].get('subgroup'), 'MK0 pump must share the normal pump menu row')
check(d['recipe']['ScrapFluidTrailer'].get('energy_required') == 10, 'Wagon crafting time')
check(d['recipe']['ScrapFluidTrailer'].get('subgroup') == 'paranoidal-transport-fluid-wagon', 'Wagon menu row')
check(d['recipe']['ScrapFluidTrailer'].get('order') < d['recipe']['fluid-wagon'].get('order'), 'MK0 precedes normal wagon')
check('logistic-science-pack' in {i[0] for i in d['technology']['fluid-handling']['unit']['ingredients']}, 'Normal pump remains on green science')

# Fixed-point prerequisite closure: research must remain red-only transitively.
red_techs = set()
while True:
    added = {n for n,t in d['technology'].items()
             if not t.get('hidden', False) and t.get('enabled', True)
             and all(i[0] == 'automation-science-pack' for i in t.get('unit', {}).get('ingredients', []))
             and set(t.get('prerequisites', [])) <= red_techs}
    if added <= red_techs:
        break
    red_techs |= added
check('scrap-fluid-handling' in red_techs, 'Technology must be transitively red-only')
recipes = {n for n,r in d['recipe'].items() if r.get('enabled', True) and not r.get('hidden', False)}
for name in red_techs:
    recipes |= {e['recipe'] for e in d['technology'][name].get('effects', []) if e['type'] == 'unlock-recipe'}
# Starting resources plus real mining outputs; no crafted intermediate is a seed.
available = {('item', n) for n in ['wood', 'raw-fish']}
for r in d.get('resource', {}).values():
    m = r.get('minable', {})
    if m.get('result'):
        available.add(('item', m['result']))
    for out in m.get('results', []):
        available.add((out.get('type', 'item'), out['name']))
for tree in d.get('tree', {}).values():
    m = tree.get('minable', {})
    if m.get('result'): available.add(('item', m['result']))
    for out in m.get('results', []): available.add((out.get('type', 'item'), out['name']))
for pump_proto in d.get('offshore-pump', {}).values():
    if pump_proto.get('fluid'): available.add(('fluid', pump_proto['fluid']))
while True:
    before = len(available)
    for name in recipes:
        r = d['recipe'][name]
        if all((i.get('type', 'item'), i['name']) in available for i in r.get('ingredients', [])):
            available.update((o.get('type', 'item'), o['name']) for o in r.get('results', []))
    if len(available) == before: break
for name in [*expected, *{i for v in expected.values() for i in v}]:
    check(('item', name) in available, f'Red-only production unavailable: {name}')

for lang in ['ru', 'en']:
    loc = configparser.ConfigParser(interpolation=None, strict=False)
    loc.optionxform = str
    loc.read(sorted((ROOT / f'mods/JunkTrain3/locale/{lang}').glob('*.cfg')))
    for section, names in {'item-name': ['ScrapFluidTrailer', 'scrap-fluid-pump'], 'entity-name': ['yir_us_fluid', 'scrap-fluid-pump'], 'recipe-name': ['ScrapFluidTrailer', 'scrap-fluid-pump'], 'recipe-description': ['ScrapFluidTrailer', 'scrap-fluid-pump'], 'technology-name': ['scrap-fluid-handling'], 'junktrain-status': ['wagon-only'], 'technology-description': ['scrap-fluid-handling'], 'item-description': ['ScrapFluidTrailer', 'scrap-fluid-pump'], 'entity-description': ['yir_us_fluid', 'scrap-fluid-pump']}.items():
        for name in names:
            check(loc.has_option(section, name) and bool(loc.get(section, name)), f'{lang} {section}.{name}')
rot = wagon['pictures']['rotated']
for field, value in {'direction_count':128, 'line_length':8, 'lines_per_file':8, 'width':256, 'height':256}.items():
    check(rot.get(field) == value, f'Sprite {field}')
check(not rot.get('back_equals_front'), 'Sprite must cover all 128 directions')
assets = {'graphics/train/t0/usfw_sheet-0.png':(2048,2048), 'graphics/train/t0/usfw_sheet-1.png':(2048,2048), 'graphics/train/t0/usfw_icon.png':(64,64), 'graphics/technology/scrap-fluid-handling.png':(256,256)}
for name,size in assets.items():
    path = ROOT / 'mods/JunkTrain3' / name
    check(path.exists(), f'Asset missing: {name}')
    if path.exists():
        header = path.read_bytes()[:26]
        check(header[:8] == b'\x89PNG\r\n\x1a\n' and struct.unpack('>II', header[16:24]) == size, f'PNG dimensions: {name}')
        check(header[25] == 6, f'RGBA PNG required: {name}')
frames = []
for sheet in range(2):
    path = ROOT / f'mods/JunkTrain3/graphics/train/t0/usfw_sheet-{sheet}.png'
    if path.exists():
        atlas = Image.open(path).convert('RGBA')
        for cell in range(64):
            x, y = cell % 8 * 256, cell // 8 * 256
            frame = atlas.crop((x,y,x+256,y+256))
            alpha = frame.getchannel('A')
            bounds = alpha.getbbox()
            check(bounds is not None and all(0 < v < 256 for v in bounds), f'Frame {sheet*64+cell} clipped/empty')
            check(alpha.getextrema() == (0, 255), f'Frame {sheet*64+cell} transparency')
            frames.append(frame.tobytes())
check(len(set(frames)) == 128, 'All 128 directions must be distinct full renders')
if a.report:
    a.report.write_text(json.dumps({
        'passed': not errors, 'dump': str(a.dump), 'errors': errors,
        'capacity': wagon['capacity'], 'tank_count': wagon['tank_count'],
        'quality_affects_capacity': wagon['quality_affects_capacity'],
        'pump_units_per_second': pump['pumping_speed'] * 60,
        'wagon_menu': d['recipe']['ScrapFluidTrailer'].get('subgroup'),
        'pump_menu': d['recipe']['scrap-fluid-pump'].get('subgroup'),
        'red_technology_count': len(red_techs), 'distinct_frames': len(set(frames)),
        'required_items_producible': {n: ('item', n) in available for n in [*expected, *{i for v in expected.values() for i in v}]},
    }, indent=2) + '\n')
print('\n'.join('FAIL: '+e for e in errors) if errors else 'PASS: MK0 prototypes, balance, unlocks, red-science closure, recycling, menu, locale and assets')
sys.exit(bool(errors))
