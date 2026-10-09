-- Data-stage integration of the expansion on a hand-made data.raw. Mocks, not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")
local near = mock.near

package.preload.util = function()
    return {empty_sprite = function() return {filename = "__core__/graphics/empty.png", size = 1} end}
end
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[table.deepcopy(k)] = table.deepcopy(v) end
    return result
end
defines = {prototypes = {
    item = {item = 0, tool = 0, ["repair-tool"] = 0, ammo = 0, blueprint = 0},
    entity = {["assembling-machine"] = 0, furnace = 0, container = 0, reactor = 0, inserter = 0,
        ["electric-energy-interface"] = 0},
}}

local function electric(usage)
    return {type = "electric", usage_priority = "secondary-input", emissions_per_minute = {pollution = 4}}, usage
end
local raw = {
    quality = {
        normal = {level = 0}, uncommon = {level = 2}, ["legendary-t5"] = {level = 24},
        ["ic-defect-1"] = {level = 0, crafting_machine_speed_multiplier = 13 / 15},
        ["ic-defect-5"] = {level = 0, crafting_machine_speed_multiplier = 1 / 3},
    },
    technology = {
        ["ic-defect-control-1"] = {effects = {{type = "nothing"}}, unit = {ingredients = {{"automation-science-pack", 1}}}},
        automation = {effects = {{type = "unlock-recipe", recipe = "assembling-machine-1"}},
            unit = {ingredients = {{"automation-science-pack", 1}}}},
        nuclear = {effects = {{type = "unlock-recipe", recipe = "reactor"}},
            unit = {ingredients = {{"a", 1}, {"b", 1}, {"c", 1}}}},
        hidden = {hidden = true, effects = {{type = "unlock-recipe", recipe = "inserter"}}, unit = {ingredients = {}}},
    },
    recipe = {
        ["assembling-machine-1"] = {enabled = false, results = {{type = "item", name = "assembling-machine-1", amount = 1}}},
        reactor = {enabled = false, results = {{type = "item", name = "reactor", amount = 1}}},
        inserter = {results = {{type = "item", name = "inserter", amount = 1}}},
        gear = {results = {{type = "item", name = "iron-gear-wheel", amount = 1}}},
        ["gear-recycling"] = {category = "recycling", results = {{type = "item", name = "iron-gear-wheel", amount = 1}}},
        white = {allow_quality = false, results = {{type = "item", name = "iron-gear-wheel", amount = 1}}},
        ["ic-refine-workshop"] = {enabled = false, ingredients = {}, results = {}},
        ["ic-control-post"] = {enabled = false, ingredients = {}, results = {}},
    },
    item = {
        ["assembling-machine-1"] = {place_result = "assembling-machine-1", subgroup = "production-machine", order = "a"},
        inserter = {place_result = "inserter"}, ["iron-gear-wheel"] = {}, reactor = {place_result = "nuclear-reactor"},
        ["ic-refine-workshop"] = {place_result = "ic-refine-workshop"}, ["ic-control-post"] = {place_result = "ic-control-post"},
        ["ic-refine-workshop-drive"] = {hidden = true}, secret = {hidden = true}, ["parameter-1"] = {parameter = true},
    },
    tool = {["automation-science-pack"] = {durability = 1}},
    ["repair-tool"] = {["repair-pack"] = {durability = 300}, ["bob-repair-pack-5"] = {durability = 5000}},
    blueprint = {blueprint = {}},
    ammo = {},
    ["assembling-machine"] = {
        ["assembling-machine-1"] = {max_health = 300, energy_usage = "90kW", resistances = {{type = "fire", percent = 70}},
            collision_box = {{-1.2, -1.2}, {1.2, 1.2}}, energy_source = (electric("90kW")), open_sound = {filename = "x"}},
        wide = {max_health = 500, collision_box = {{-2.2, -1.2}, {2.2, 1.2}}, energy_source = (electric())},
        burner = {collision_box = {{-0.9, -0.9}, {0.9, 0.9}}, energy_source = {type = "burner"}},
    },
    furnace = {["ic-refine-workshop"] = {crafting_speed = 1, energy_usage = "75kW", collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
        energy_source = {type = "burner", emissions_per_minute = {pollution = 1}}}},
    container = {["ic-control-post"] = {max_health = 10}},
    reactor = {["nuclear-reactor"] = {max_health = 500}},
    inserter = {inserter = {max_health = 150}},
}

local final = require("prototypes.expansion-final")
local prototypes, report = final.apply(raw, {["assembling-machine-1"] = true}, {["iron-gear-wheel"] = "ingredient"})

-- Machines copy assembling machine 1 of the modpack.
local workshop = raw.furnace["ic-refine-workshop"]
assert(workshop.max_health == 300 and workshop.energy_usage == "90kW" and workshop.resistances[1].percent == 70)
assert(workshop.energy_source.type == "burner" and workshop.energy_source.emissions_per_minute.pollution == 4)
assert(raw.container["ic-control-post"].max_health == 300)
-- Positive-quality speed cap; standard, uncommon and defects keep their multipliers.
local speeds = workshop.crafting_speed_quality_multiplier
assert(speeds["legendary-t5"] == 4 and not speeds.uncommon and not speeds.normal and not speeds["ic-defect-5"])
-- Items next to assembling machine 1, recipes, unlock in quality control 1.
assert(raw.item["ic-refine-workshop"].subgroup == "production-machine")
local ingredients = {}
for _, i in ipairs(raw.recipe["ic-refine-workshop"].ingredients) do ingredients[i.name] = i.amount end
assert(ingredients["assembling-machine-1"] == 1 and ingredients["repair-pack"] == 10)
local effects = raw.technology["ic-defect-control-1"].effects
assert(effects[1].recipe == "ic-refine-workshop" and effects[2].recipe == "ic-control-post" and effects[3].type == "nothing")
-- Repair packs are the workshop's resource.
assert(raw["repair-tool"]["repair-pack"].fuel_category == "ic-repair-resource")
assert(raw["repair-tool"]["repair-pack"].fuel_value == "300kJ" and raw["repair-tool"]["bob-repair-pack-5"].fuel_value == "5000kJ")

-- Refinement recipes and costs.
local recipes, interfaces, data = {}, {}, nil
for _, prototype in ipairs(prototypes) do
    if prototype.type == "recipe" then recipes[prototype.name] = prototype
    elseif prototype.type == "electric-energy-interface" then interfaces[prototype.name] = prototype
    elseif prototype.type == "mod-data" then data = prototype.data end
end
for _, name in ipairs({"assembling-machine-1", "inserter", "iron-gear-wheel", "reactor", "automation-science-pack",
    "ic-refine-workshop", "ic-control-post"}) do
    local recipe = assert(recipes["ic-refine-item-" .. name], name)
    assert(recipe.category == "ic-refine" and recipe.hidden and recipe.hide_from_stats and recipe.allow_quality)
    assert(recipe.ingredients[1].name == name and recipe.results[1].name == name and recipe.results[1].amount == 1)
    assert(not recipe.allow_productivity and recipe.enabled)
end
for _, name in ipairs({"repair-pack", "bob-repair-pack-5", "blueprint", "ic-refine-workshop-drive", "secret", "parameter-1"}) do
    assert(not recipes["ic-refine-item-" .. name], name)
end
local costs = data.costs
assert(costs["assembling-machine-1"].kinds == 1 and costs["assembling-machine-1"].cost == 300)
near(recipes["ic-refine-item-assembling-machine-1"].energy_required, 2)
assert(costs.reactor.kinds == 3 and costs.reactor.health == 500)
near(costs.reactor.cost / 300, 19.36, 0.01)
assert(costs.inserter.kinds == 0, "enabled from the start; the hidden technology is ignored")
near(costs.inserter.cost / 300, 0.707, 0.01)
assert(costs["iron-gear-wheel"].kinds == 0 and costs["iron-gear-wheel"].cost == 300)
-- No researchable recipe: average item.
assert(costs["automation-science-pack"].kinds == nil and costs["automation-science-pack"].cost == 1500)
-- Runtime data: reasons and recipes without quality.
assert(data.reasons["iron-gear-wheel"] == "ingredient" and data.no_quality.white and data.finished_count == 1)

-- Production-mode power: one interface per electric footprint (and rotated), not for burners/workshop.
assert(interfaces["ic-mode-power-3x3"] and interfaces["ic-mode-power-5x3"] and interfaces["ic-mode-power-3x5"])
assert(not interfaces["ic-mode-power-2x2"])
assert(#interfaces["ic-mode-power-5x3"].collision_mask.layers == 0)
assert(report[1]:find("refinement recipes 7", 1, true))
print("PASS: workshop/post stats from assembling machine 1, x4 speed cap, unlocks in control 1,")
print("repair packs as resource, refinement recipe of every item with science x health cost,")
print("exclusions (packs, planners, hidden, parameters), mode power interfaces, runtime mod-data.")
print("Mocks only: not a Factorio data-stage load.")
