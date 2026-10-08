local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local filter = require("scripts.defects.eligibility")
local catalog = filter.catalog({
    lab = {type="lab", lab_inputs={"automation-science-pack", "modded-science", "bob-speed-processor"}},
    ore = {type="resource", mineable_properties={products={{type="item",name="alien-ore"},{type="fluid",name="oil"}}}},
    tree = {type="tree", mineable_properties={products={{type="item",name="alien-wood"}}}},
    building = {type="assembling-machine", mineable_properties={products={{type="item",name="assembling-machine-1"}}}},
})
assert(not catalog.raw['assembling-machine-1'] and not catalog.raw.oil)
for _, name in ipairs({'wood','stone','coal','alien-ore','alien-wood','iron-plate','steel-plate',
    'iron-gear-wheel','copper-cable','electronic-circuit','processing-unit','bob-module-processor-board'}) do
    assert(not filter.is_finished({name=name,type='item'},catalog),name)
end
assert(not filter.is_finished({name='alien-wood',type='item',place_result={}},catalog))
assert(not filter.is_finished({name='non-science-component',type='tool'},catalog))
assert(not filter.is_finished({name='seed',type='item',plant_result={}},catalog))
for _,name in ipairs({'assembling-machine-1','inserter','transport-belt','small-electric-pole','wooden-chest'}) do
    assert(filter.is_finished({name=name,type='item',place_result={}},catalog),name)
end
for _,name in ipairs({'automation-science-pack','modded-science','bob-speed-processor'}) do
    assert(filter.is_finished({name=name,type='tool'},catalog),name)
end
for _,kind in ipairs({'ammo','armor','gun','capsule','module','repair-tool','rail-planner'}) do
    assert(filter.is_finished({name='example-'..kind,type=kind},catalog),kind)
end
assert(filter.is_finished({name='battery-equipment',type='item',place_as_equipment_result={}},catalog))
assert(filter.is_finished({name='concrete',type='item',place_as_tile_result={}},catalog))
print('PASS: finished buildings/equipment/consumables/lab inputs included; mined resources, wood,')
print('plates, gears, circuits and non-science tools excluded. Classification mock, not Factorio.')
