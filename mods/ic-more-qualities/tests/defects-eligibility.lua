-- Classification of finished products (data stage) and its runtime view. Mocks, not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local classify = require("scripts.defects.classify")
local eligibility = require("scripts.defects.eligibility")

local raw = {
    lab = {lab = {inputs = {"automation-science-pack", "modded-science", "bob-speed-processor"}}},
    resource = {ore = {minable = {results = {{type = "item", name = "alien-ore"}, {type = "fluid", name = "oil"}}}}},
    tree = {tree = {minable = {results = {{type = "item", name = "alien-wood"}}}}},
    pipe = {pipe = {}},
    item = {
        wood = {}, stone = {}, coal = {}, ["alien-ore"] = {}, ["alien-wood"] = {place_result = "tree"},
        ["iron-plate"] = {}, ["iron-gear-wheel"] = {}, ["copper-cable"] = {}, ["electronic-circuit"] = {},
        seed = {plant_result = "tree"}, pipe = {place_result = "pipe"}, concrete = {place_as_tile = {result = "concrete"}},
        ["assembling-machine-1"] = {place_result = "assembling-machine-1"}, inserter = {place_result = "inserter"},
        ["battery-equipment"] = {place_as_equipment_result = "battery-equipment"},
        ["parameter-0"] = {parameter = true, place_result = "x"},
    },
    tool = {
        ["automation-science-pack"] = {}, ["modded-science"] = {}, ["bob-speed-processor"] = {},
        ["non-science-component"] = {},
    },
    ammo = {["example-ammo"] = {}}, armor = {["example-armor"] = {}}, gun = {["example-gun"] = {}},
    capsule = {["example-capsule"] = {}}, module = {["example-module"] = {}}, ["repair-tool"] = {["repair-pack"] = {}},
    ["rail-planner"] = {rail = {place_result = "straight-rail"}},
}
local finished, reasons = classify.classify(raw, "materials")
for _, name in ipairs({"wood", "stone", "coal", "alien-ore", "alien-wood", "iron-plate", "iron-gear-wheel",
    "copper-cable", "electronic-circuit", "seed", "non-science-component", "pipe", "concrete", "rail", "parameter-0"}) do
    assert(not finished[name], name)
end
assert(reasons["alien-wood"] == "raw" and reasons.pipe == "material-pipe" and reasons.concrete == "material-tile")
assert(reasons.rail == "material-rail" and reasons["parameter-0"] == "parameter")
for _, name in ipairs({"assembling-machine-1", "inserter", "battery-equipment", "automation-science-pack",
    "modded-science", "bob-speed-processor", "example-ammo", "example-armor", "example-gun", "example-capsule",
    "example-module", "repair-pack"}) do
    assert(finished[name], name)
end
assert(not pcall(classify.classify, raw, "unknown-mode"))

-- Wider modes exclude finished items that feed intermediates or science.
raw.recipe = {
    ["science"] = {ingredients = {{type = "item", name = "inserter", amount = 1}},
        results = {{type = "item", name = "automation-science-pack", amount = 1}}},
}
local wide = classify.classify(raw, "intermediate-ingredients")
assert(not wide.inserter and wide["assembling-machine-1"])

-- Runtime view reads the mod-data written at data stage.
prototypes = {mod_data = {["ic-defects-classification"] = {data = {finished = finished}}}}
eligibility.reset()
assert(eligibility.is_finished("assembling-machine-1") and not eligibility.is_finished("iron-plate"))
prototypes = {mod_data = {}}
eligibility.reset()
assert(not eligibility.is_finished("assembling-machine-1"), "missing mod-data means no finished products")
print("PASS: buildings, equipment, consumables and lab inputs are finished; resources, wood, plates,")
print("gears, circuits, pipes, tiles, rails, parameters and non-science tools are materials. Mocks only.")
