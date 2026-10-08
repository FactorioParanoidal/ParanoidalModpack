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
    technology = {["quality-module"] = {name = "quality-module"}},
    item = {
        ["iron-plate"] = {name = "iron-plate"}, ["iron-gear-wheel"] = {name = "iron-gear-wheel"},
        ["assembling-machine-1"] = {name = "assembling-machine-1", place_result = "assembling-machine-1"},
        ["small-electric-pole"] = {name = "small-electric-pole", place_result = "small-electric-pole"},
        pipe = {name = "pipe", place_result = "pipe"},
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
        science = {results = {{type = "item", name = "automation-science-pack", amount = 1}}, allow_quality = true},
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
        assert(#prototype.prerequisites == (level == 10 and 2 or (level == 1 and 0 or 1)))
        if level > 1 then assert(prototype.prerequisites[1] == "ic-defect-control-" .. (level - 1)) end
        if level == 10 then assert(prototype.prerequisites[2] == "quality-module") end
        assert(#prototype.unit.ingredients == 1 and prototype.unit.ingredients[1][1] == "automation-science-pack")
        research_total = research_total + prototype.unit.count
    end
end
assert(research_total == 550)
assert(not pcall(builder.prepare, raw), "Duplicate registration must fail")
local without_module = {quality = {normal = {level = 0}}, technology = {}}
local no_module = builder.prepare(without_module)
assert(#no_module[15].prerequisites == 1, "Missing quality-module must not break loading")

-- Late layer.
local extra, report, finished = final.apply(raw, {mode = "materials", supply_reduction = .5, wire_reduction = 1})
assert(extra[1].type == "mod-data" and extra[1].name == "ic-defects-classification")
assert(extra[1].data.finished == finished and extra[1].data.mode == "materials")
assert(finished["assembling-machine-1"] and finished["small-electric-pole"] and finished["automation-science-pack"])
assert(not finished.pipe and not finished["iron-gear-wheel"] and not finished["iron-ore"])
assert(raw.recipe.gear.allow_quality == false and raw.recipe.mixed.allow_quality == false)
assert(raw.recipe.sorting.allow_quality == false)
assert(raw.recipe.assembler.allow_quality == nil and raw.recipe.science.allow_quality == true)
assert(raw.recipe.fluid.allow_quality == nil)
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
assert(joined:find("clamped poles: connector", 1, true) and joined:find("hidden", 1, true))
assert(joined:find("material%-pipe %(1%): pipe"))
assert(not pcall(final.apply, {quality = {normal = {}}}, {}), "Requires registered defect qualities")

-- control.lua lifecycle: init/config/new force/reset, machine registry, warnings.
local callbacks, events = {}, {}
for i, name in ipairs({"on_force_created", "on_force_reset", "on_player_crafted_item", "on_player_mined_entity",
    "on_robot_mined_entity", "on_built_entity", "on_robot_built_entity", "script_raised_built",
    "script_raised_revive", "on_entity_cloned", "on_chunk_generated", "on_tick"}) do events[name] = i end
defines = {events = events, inventory = {crafter_input = 2}}
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
prototypes = {mod_data = {}, recipe = {}}
settings = {startup = {["ic-more-qualities-defects-preview"] = {value = false}},
    global = {["ic-more-qualities-loss-exclude-finished"] = {value = false}}}
dofile(root .. "control.lua")
for _, name in ipairs({"on_player_crafted_item", "on_player_mined_entity", "on_robot_mined_entity",
    "on_built_entity", "on_entity_cloned", "on_chunk_generated", "on_tick"}) do
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
assert(scanned == 2 and storage.ic_defects and storage.ic_defect_machines == nil)
callbacks[events.on_tick]({tick = 1})

local modules = {module = {["quality-module"] = {hidden = true, effect = {quality = .01}},
    ["bob-god-module"] = {hidden = true}}, recipe = {["quality-module"] = {hidden = true, enabled = false}}}
require("prototypes.defects-quality-modules")(modules)
assert(modules.module["quality-module"].hidden == false and modules.recipe["quality-module"].hidden == false)
assert(modules.module["bob-god-module"].hidden and modules.recipe["quality-module"].enabled == false)
print("PASS: 5 defect qualities on level 0 without shifting standard/positive qualities, multipliers,")
print("1/m energy, 10 red-science technologies (+quality-module at 10), classification mod-data,")
print("white intermediate recipes, drills without quality effect, machine energy dictionaries,")
print("uniform pole reduction with clamping report, control lifecycle. Mocks only, not Factorio.")
