-- Prototype/data-stage and control lifecycle checks on mocks. Not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
local root = directory .. "../"
package.path = root .. "?.lua;" .. package.path
local builder = require("prototypes.defects-preview")
local final = require("prototypes.defects-final")
local function near(a, b) assert(math.abs(a - b) < 1e-9, tostring(a) .. " != " .. tostring(b)) end
local function copy(t)
    if type(t) ~= "table" then return t end
    local result = {}
    for k, v in pairs(t) do result[k] = copy(v) end
    return result
end
local logged = {}
log = function(line) logged[#logged + 1] = line end

local raw = {
    quality = {
        normal = {name = "normal", level = 0, next = "uncommon", next_probability = 1},
        uncommon = {name = "uncommon", level = 2, next = "legendary", next_probability = .2},
        legendary = {name = "legendary", level = 6, default_multiplier = 2, electric_pole_wire_reach_bonus = 3},
        ["quality-unknown"] = {name = "quality-unknown", level = 0},
    },
    technology = {["quality-module"] = {name = "quality-module", prerequisites = {"modules"}},
        ["logistic-science-pack"] = {name = "logistic-science-pack", prerequisites = {"electronics"}},
        ["green-tech"] = {name = "green-tech", prerequisites = {"logistic-science-pack"},
            effects = {{type = "unlock-recipe", recipe = "green-building"}, {type = "unlock-recipe", recipe = "both-building"}}},
        ["hidden-tech"] = {name = "hidden-tech", hidden = true,
            effects = {{type = "unlock-recipe", recipe = "green-building-old"}}}},
    item = {
        ["iron-plate"] = {name = "iron-plate"}, ["iron-gear-wheel"] = {name = "iron-gear-wheel"},
        ["assembling-machine-1"] = {name = "assembling-machine-1", place_result = "assembling-machine-1"},
        ["small-electric-pole"] = {name = "small-electric-pole", place_result = "small-electric-pole"},
        pipe = {name = "pipe", place_result = "pipe"},
        ["bet-charger-1"] = {name = "bet-charger-1", place_result = "bet-charger-1"},
        ["memory-unit"] = {name = "memory-unit", place_result = "memory-unit"},
        ["some-valve"] = {name = "some-valve", place_result = "some-valve"},
        ["bob-small-storage-tank"] = {name = "bob-small-storage-tank", place_result = "bob-small-storage-tank"},
        ["storage-tank"] = {name = "storage-tank", place_result = "storage-tank"},
        ["some-roboport"] = {name = "some-roboport", place_result = "some-roboport"},
        ["some-equipment"] = {name = "some-equipment", place_as_equipment_result = "some-equipment"},
        ["green-building"] = {name = "green-building", place_result = "green-building"},
        ["both-building"] = {name = "both-building", place_result = "both-building"},
    },
    module = {["some-module"] = {name = "some-module"}},
    valve = {["some-valve"] = {name = "some-valve"}},
    ["storage-tank"] = {["bob-small-storage-tank"] = {name = "bob-small-storage-tank"},
        ["storage-tank"] = {name = "storage-tank"}},
    roboport = {["some-roboport"] = {name = "some-roboport"}},
    ["item-with-entity-data"] = {
        ["Schall-tank-L-mk2"] = {name = "Schall-tank-L-mk2", place_result = "Schall-tank-L-mk2"},
    },
    pipe = {pipe = {name = "pipe"}},
    tool = {["automation-science-pack"] = {name = "automation-science-pack"}},
    lab = {lab = {inputs = {"automation-science-pack"}}},
    resource = {["iron-ore"] = {minable = {results = {{type = "item", name = "iron-ore"}}}}},
    recipe = {
        gear = {category = "crafting", ingredients = {{type = "item", name = "iron-plate", amount = 2}},
            results = {{type = "item", name = "iron-gear-wheel", amount = 1}}},
        assembler = {ingredients = {{type = "item", name = "iron-gear-wheel", amount = 5}},
            results = {{type = "item", name = "assembling-machine-1", amount = 1}}},
        mixed = {results = {{type = "item", name = "assembling-machine-1", amount = 1},
            {type = "item", name = "iron-gear-wheel", amount = 1}}},
        sorting = {results = {{type = "item", name = "iron-ore", amount = 1}}},
        fluid = {results = {{type = "fluid", name = "water", amount = 10}}},
        ["gear-recycling"] = {category = "recycling", results = {{type = "item", name = "iron-plate", amount = 1}}},
        science = {results = {{type = "item", name = "automation-science-pack", amount = 1}}, allow_quality = true},
        -- Green-science gate (2026-10-18): unlocked only behind logistic-science-pack -> no defects; an item
        -- with a recipe available from the start keeps them; a hidden technology unlocks nothing.
        ["green-building"] = {enabled = false, results = {{type = "item", name = "green-building", amount = 1}}},
        ["green-building-old"] = {enabled = false, results = {{type = "item", name = "green-building", amount = 1}}},
        ["both-building"] = {enabled = false, results = {{type = "item", name = "both-building", amount = 1}}},
        ["both-building-early"] = {results = {{type = "item", name = "both-building", amount = 1}}},
        ["green-building-recycling"] = {category = "recycling", results = {{type = "item", name = "both-building", amount = 1}}},
        -- Recycling floor (2026-10-19): only recycling of an item that can be defective is slowed.
        ["assembler-recycling"] = {category = "recycling", energy_required = 0.03125,
            ingredients = {{type = "item", name = "assembling-machine-1", amount = 1}},
            results = {{type = "item", name = "iron-gear-wheel", amount = 1}}},
        ["pole-recycling"] = {category = "recycling", energy_required = 0.5,
            ingredients = {{type = "item", name = "small-electric-pole", amount = 1}}, results = {}},
        ["green-recycling"] = {category = "recycling", energy_required = 0.00625,
            ingredients = {{type = "item", name = "green-building", amount = 1}}, results = {}},
        ["plate-recycling"] = {category = "recycling",
            ingredients = {{type = "item", name = "iron-plate", amount = 1}}, results = {}},
    },
    ["mining-drill"] = {
        default = {}, listed = {allowed_effects = {"speed", "quality", "productivity"}},
        single = {allowed_effects = "quality"},
    },
    ["assembling-machine"] = {
        plain = {}, already = {quality_affects_energy_usage = true},
        dictionary = {quality_affects_energy_usage = true, energy_usage_quality_multiplier = {legendary = .5}},
        stale = {energy_usage_quality_multiplier = {legendary = 9}},
    },
    furnace = {stone = {}},
    ["electric-pole"] = {
        small = {supply_area_distance = 2.5, maximum_wire_distance = 7.5},
        connector = {supply_area_distance = 0, maximum_wire_distance = 14},
        hidden = {supply_area_distance = 63, maximum_wire_distance = 1},
    },
}
local originals = copy(raw.quality)
local prototypes = builder.prepare(raw)
assert(#prototypes == 15)

-- Standard and positive qualities are NOT shifted or otherwise modified by prepare.
for name, quality in pairs(raw.quality) do
    for key, value in pairs(originals[name]) do assert(quality[key] == value, name .. "." .. key) end
end
local research_total = 0
for _, prototype in ipairs(prototypes) do
    if prototype.type == "quality" then
        raw.quality[prototype.name] = prototype
        local tier = tonumber(prototype.name:match("ic%-defect%-(%d)"))
        local m = 1 / 3 + (5 - tier) * 2 / 15
        assert(prototype.level == 0, "Defects stay on internal level 0")
        assert(prototype.order == "0-ic-defect-" .. (5 - tier) and prototype.order < "a")
        assert(prototype.icons[1].icon == "__ic-more-qualities__/graphics/icons/quality-uncommon-t" .. tier .. ".png")
        local tint = prototype.icons[1].tint
        assert(tint.r == 0 and tint.g == 0 and tint.b == 0 and tint.a == 1)
        for _, field in ipairs({"default_multiplier", "crafting_machine_speed_multiplier", "inserter_speed_multiplier",
            "inventory_size_multiplier", "lab_research_speed_multiplier", "accumulator_capacity_multiplier",
            "tool_durability_multiplier", "flying_robot_max_energy_multiplier", "fluid_wagon_capacity_multiplier",
            "logistic_cell_charging_energy_multiplier"}) do near(prototype[field], m) end
        near(prototype.crafting_machine_energy_usage_multiplier, 1 / m)
        assert(prototype.range_multiplier == 1 and prototype.beacon_power_usage_multiplier == 1)
        assert(prototype.mining_drill_resource_drain_multiplier == 1 and prototype.science_pack_drain_multiplier == 1)
        assert(prototype.next == (tier > 1 and ("ic-defect-" .. (tier - 1)) or "normal"))
    else
        local level = tonumber(prototype.name:match("(%d+)$"))
        assert(prototype.enabled == true and prototype.localised_name[2] == tostring(level))
        assert(#prototype.prerequisites == (level == 1 and 0 or 1))
        if level > 1 then assert(prototype.prerequisites[1] == "ic-defect-control-" .. (level - 1)) end
        assert(#prototype.unit.ingredients == 1 and prototype.unit.ingredients[1][1] == "automation-science-pack")
        research_total = research_total + prototype.unit.count
    end
end
assert(research_total == 550)
local parents = raw.technology["quality-module"].prerequisites
assert(#parents == 2 and parents[1] == "modules" and parents[2] == "ic-defect-control-10")
-- User decision 2026-10-18: green science also requires quality control 10.
local green = raw.technology["logistic-science-pack"].prerequisites
assert(#green == 2 and green[1] == "electronics" and green[2] == "ic-defect-control-10")
assert(not pcall(builder.prepare, raw), "Duplicate registration must fail")
local without_module = {quality = {normal = {level = 0}}, technology = {}}
assert(not pcall(builder.prepare, without_module), "Missing mandatory quality-module must not silently lose the dependency")
local existing_parent = {quality = {normal = {level = 0}}, technology = {
    ["quality-module"] = {prerequisites = {"modules", "ic-defect-control-10"}}}}
builder.prepare(existing_parent)
assert(#existing_parent.technology["quality-module"].prerequisites == 2, "Do not duplicate prerequisites")
assert(existing_parent.technology["logistic-science-pack"] == nil, "An absent green science technology is skipped")

-- Late layer.
local extra, report, finished, _, returned_no_defect = final.apply(raw, {mode = "materials", supply_reduction = .5, wire_reduction = 1})
assert(extra[1].type == "mod-data" and extra[1].name == "ic-defects-classification")
assert(extra[1].data.finished == finished and extra[1].data.mode == "materials")
assert(finished["assembling-machine-1"] and finished["small-electric-pole"] and finished["automation-science-pack"])
assert(not finished.pipe and not finished["iron-gear-wheel"] and not finished["iron-ore"])
-- Paranoidal decision 2026-10-14: these upgrade chains are finished products without defects.
local no_defect = extra[1].data.no_defect
for _, name in ipairs({"Schall-tank-L-mk2", "bet-charger-1", "memory-unit"}) do
    assert(finished[name] and no_defect[name], name)
end
assert(not no_defect["assembling-machine-1"] and not no_defect["small-electric-pole"])
-- User decisions 2026-10-18: groups without defects by entity type, item type, equipment and name;
-- the large storage tank keeps defects although its entity type is shared with the small tank.
for _, name in ipairs({"some-valve", "bob-small-storage-tank", "some-roboport", "some-equipment", "some-module"}) do
    assert(finished[name] and no_defect[name], name)
end
assert(finished["storage-tank"] and not no_defect["storage-tank"])
assert(finished["green-building"] and no_defect["green-building"], "made only after green science")
assert(finished["both-building"] and not no_defect["both-building"], "also available before green science")
assert(returned_no_defect == no_defect, "apply returns the no-defect set (drill tooltips)")
assert(raw.recipe["assembler-recycling"].energy_required == final.recycling_minimum, "defect-capable recycling slowed")
assert(raw.recipe["pole-recycling"].energy_required == 0.5, "longer recycling kept")
assert(raw.recipe["green-recycling"].energy_required == 0.00625, "recycling of an exempt item kept")
assert(raw.recipe["plate-recycling"].energy_required == nil, "recycling of a material kept")
local floor_line = false
for _, line in ipairs(report) do
    if line:find("recycling of items that can be defective takes at least 0.0625 s: recipes slowed 1", 1, true) then floor_line = true end
end
assert(floor_line, "recycling floor logged")
assert(#final.exempt_items == 54) -- 29 + 12 Factorissimo factory items (2026-10-15) + 3 Flow Control pipes (2026-10-18) + 2 factory 4 items (2026-10-19) + 8 logistic memory units (2026-10-22)
assert(raw.recipe.gear.allow_quality == false and raw.recipe.mixed.allow_quality == false)
assert(raw.recipe.sorting.allow_quality == false)
assert(raw.recipe.assembler.allow_quality == nil and raw.recipe.science.allow_quality == true)
assert(raw.recipe.fluid.allow_quality == nil)
assert(raw.recipe["gear-recycling"].allow_quality == nil, "recycling keeps native quality")
local drills = raw["mining-drill"]
assert(table.concat(drills.default.allowed_effects, ",") == "speed,productivity,consumption,pollution")
assert(table.concat(drills.listed.allowed_effects, ",") == "speed,productivity")
assert(#drills.single.allowed_effects == 0)
local machines = raw["assembling-machine"]
for _, name in ipairs({"plain", "stale"}) do
    local machine = machines[name]
    assert(machine.quality_affects_energy_usage)
    local d = machine.energy_usage_quality_multiplier
    assert(d.normal == 1 and d.uncommon == 1 and d.legendary == 1 and d["quality-unknown"] == 1,
        "Previously quality-blind machines keep x1 for every non-defect quality")
    near(d["ic-defect-5"], 3); near(d["ic-defect-1"], 15 / 13)
end
assert(machines.already.energy_usage_quality_multiplier == nil, "Existing quality behaviour is left to qualities")
assert(machines.dictionary.energy_usage_quality_multiplier.legendary == .5)
near(machines.dictionary.energy_usage_quality_multiplier["ic-defect-5"], 3)
assert(raw.furnace.stone.quality_affects_energy_usage)

local poles = raw["electric-pole"]
near(poles.small.supply_area_distance, 2); near(poles.small.maximum_wire_distance, 6.5)
assert(poles.connector.supply_area_distance == 0 and poles.connector.maximum_wire_distance == 13)
near(poles.hidden.supply_area_distance, 62.5); assert(poles.hidden.maximum_wire_distance == 0)
local q = raw.quality
near(q.normal.electric_pole_supply_area_distance_bonus, .5); near(q.normal.electric_pole_wire_reach_bonus, 1)
near(q.uncommon.electric_pole_supply_area_distance_bonus, 2.5); near(q.uncommon.electric_pole_wire_reach_bonus, 5)
near(q.legendary.electric_pole_wire_reach_bonus, 4)
for tier = 1, 5 do
    near(q["ic-defect-" .. tier].electric_pole_supply_area_distance_bonus, .5 * (5 - tier) / 5)
    near(q["ic-defect-" .. tier].electric_pole_wire_reach_bonus, (5 - tier) / 5)
end
-- Effective radius: standard unchanged, -5 reduced by the full amount.
near(poles.small.supply_area_distance + q.normal.electric_pole_supply_area_distance_bonus, 2.5)
near(poles.small.supply_area_distance + q["ic-defect-5"].electric_pole_supply_area_distance_bonus, 2)
local joined = table.concat(report, "\n")
assert(joined:find("upgrade chains without defects (tanks, fuel cells, chargers, memory units, hazmat suit, factory buildings, Flow Control pipes): 3", 1, true))
assert(joined:find("groups without defects (5): valves and small fluid tanks 2,", 1, true))
assert(joined:find("made only after logistic-science-pack without defects: 1; finished products that can still get defects:", 1, true))
assert(joined:find("modules 1, module parts 0, equipment 1,", 1, true) and joined:find("roboports 1", 1, true))
-- "hidden" (wire 1, reduction 1) ends exactly at 0: reduced, not clamped.
assert(joined:find("clamped poles: connector", 1, true) and not joined:find("hidden (", 1, true))
assert(joined:find("material%-pipe %(1%): pipe"))
assert(not pcall(final.apply, {quality = {normal = {}}}, {}), "Requires registered defect qualities")

-- control.lua lifecycle: init/config/new force/reset, machine registry, warnings.
local callbacks, events = {}, {}
for i, name in ipairs({"on_force_created", "on_force_reset", "on_player_crafted_item", "on_player_mined_entity",
    "on_robot_mined_entity", "on_built_entity", "on_robot_built_entity", "script_raised_built",
    "script_raised_revive", "on_entity_cloned", "on_chunk_generated", "on_tick"}) do events[name] = i end
defines = dofile(directory .. "mock.lua").defines(events)
-- control.lua registers a read-only remote interface (2a71d6eb63).
remote = {add_interface = function() end}
script = {
    on_init = function(fn) callbacks.init = fn end,
    on_configuration_changed = function(fn) callbacks.configuration = fn end,
    on_event = function(event, fn, filters) assert(event); callbacks[event] = fn end,
}
local unlocked = {}
local force = {index = 1, name = "player", technologies = {},
    unlock_quality = function(name) unlocked[name] = (unlocked[name] or 0) + 1 end}
for level = 1, 10 do force.technologies["ic-defect-control-" .. level] = {enabled = false, researched = level == 1} end
local scanned = 0
game = {tick = 0, forces = {player = force}, surfaces = {{find_entities_filtered = function()
    scanned = scanned + 1; return {} end}}}
storage = {ic_defect_machines = {entries = {}}}
_G.prototypes = {mod_data = {}, recipe = {}, get_entity_filtered = function() return {} end,
    get_recipe_filtered = function() return {} end}
settings = {startup = {["ic-more-qualities-defects-preview"] = {value = false}}}
dofile(root .. "control.lua")
for _, name in ipairs({"on_player_crafted_item", "on_built_entity", "on_entity_cloned", "on_chunk_generated",
    "on_tick"}) do
    assert(callbacks[events[name]], "Missing handler " .. name)
end
callbacks.init()
assert(next(unlocked) == nil and scanned == 0 and storage.ic_defects == nil)
settings.startup["ic-more-qualities-defects-preview"].value = true
callbacks.init()
callbacks.configuration({})
callbacks[events.on_force_created]({force = force})
callbacks[events.on_force_reset]({force = force})
for tier = 1, 5 do assert(unlocked["ic-defect-" .. tier] == 4) end
for level = 1, 10 do
    local technology = force.technologies["ic-defect-control-" .. level]
    assert(technology.enabled and technology.researched == (level == 1))
end
-- Each configuration scans every surface three times: workshops, control posts and drills (no crafting
-- machine prototype can need handling in this mock, so they are not searched).
assert(scanned == 6 and storage.ic_defects and storage.ic_defect_machines == nil, "scanned " .. scanned)
callbacks[events.on_tick]({tick = 1})

local modules = {module = {["quality-module"] = {hidden = true, effect = {quality = .01}},
    ["bob-god-module"] = {hidden = true}}, recipe = {["quality-module"] = {hidden = true, enabled = false}}}
require("prototypes.defects-quality-modules")(modules)
assert(modules.module["quality-module"].hidden == false and modules.recipe["quality-module"].hidden == false)
assert(modules.module["bob-god-module"].hidden and modules.recipe["quality-module"].enabled == false)
print("PASS: 5 defect qualities on level 0 without shifting standard/positive qualities, multipliers,")
print("1/m energy, 10 red-science technologies (quality-module and logistic-science-pack REQUIRE level 10), classification mod-data,")
print("white intermediate recipes, drills without quality effect, machine energy dictionaries,")
print("uniform pole reduction with clamping report, control lifecycle. Mocks only, not Factorio.")
