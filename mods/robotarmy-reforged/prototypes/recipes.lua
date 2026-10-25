-- Recipes (loaded from data-updates.lua, after every mod's data.lua, so that the items of
-- Bob's, Angels and Paranoidal exist).
--
-- Each ingredient is a list of alternatives {name, amount, fallback, amount, ...}: the first
-- existing item is used. The first alternative is the Paranoidal ingredient, the
-- last one a vanilla item so that the mod also works without the overhaul mods.
--
-- Droid recipes describe the droid: weapon, frame / armour, actuators, power, control unit.
-- Deploy recipes consume a droid item in a droid assembler or guard station and have no
-- product: the control script spawns a unit for every finished craft (with the quality of
-- the consumed droid item).
local shared = require("lib.shared")

local ICONS = shared.mod_path .. "/graphics/icons/"
local B = shared.buildings

local item_types = {}
for type_name in pairs(defines.prototypes.item) do
  item_types[#item_types + 1] = type_name
end

-- Existence only: Angels hides some Bob's parts (cobalt steel gears, bearings) in data-updates
-- and Paranoidal shows them again later, so the hidden flag is not final here. The final state
-- is checked on the full data dump.
local function usable_item(name)
  for _, type_name in pairs(item_types) do
    if data.raw[type_name] and data.raw[type_name][name] then return true end
  end
  return false
end

local function ingredients(recipe_name, list)
  local out, index = {}, {}
  for _, alternatives in pairs(list) do
    local chosen
    for i = 1, #alternatives, 2 do
      if usable_item(alternatives[i]) then
        chosen = {alternatives[i], alternatives[i + 1]}
        break
      end
    end
    if not chosen then
      error(string.format("robotarmy-reforged: no usable ingredient for %s among %s", recipe_name, serpent.line(alternatives)))
    end
    local name, amount = chosen[1], chosen[2]
    if index[name] then -- two fallbacks resolved to the same item: merge them
      index[name].amount = index[name].amount + amount
    else
      local ingredient = {type = "item", name = name, amount = amount}
      out[#out + 1] = ingredient
      index[name] = ingredient
    end
  end
  return out
end

local prototypes = {}

local function recipe(name, time, list, category)
  prototypes[#prototypes + 1] = {
    type = "recipe",
    name = name,
    enabled = false,
    category = category,
    energy_required = time,
    ingredients = ingredients(name, list),
    results = {{type = "item", name = name, amount = 1}},
  }
end

local function droid(index, name, time, deploy_time, list)
  recipe(name, time, list, "advanced-crafting")
  prototypes[#prototypes + 1] = {
    type = "recipe",
    name = name .. "-deploy",
    icon = ICONS .. shared.droid_icons[name],
    icon_size = 64,
    subgroup = "robotarmy-deploy",
    order = string.format("z[droid]-%02d", index),
    enabled = false,
    hide_from_player_crafting = true,
    auto_recycle = false,
    category = "droids",
    energy_required = deploy_time,
    ingredients = {{type = "item", name = name, amount = 1}},
    results = {},
  }
end

-- Light infantry: rifle, invar frame, clockwork gear train.
droid(1, "droid-rifle", 10, 3, {
  {"bob-rifle", 1, "submachine-gun", 1},
  {"bob-invar-alloy", 25, "steel-plate", 25},
  {"bob-steel-gear-wheel", 30, "iron-gear-wheel", 30},
  {"bob-steel-bearing", 20, "iron-gear-wheel", 20},
  {"electric-motor", 10, "engine-unit", 5},
  {"advanced-circuit", 5},
})
-- Battle droid: submachine gun, armoured cobalt steel body.
droid(2, "droid-smg", 20, 6, {
  {"submachine-gun", 1},
  {"modular-armor", 1},
  {"bob-cobalt-steel-alloy", 25, "steel-plate", 25},
  {"bob-cobalt-steel-bearing", 10, "iron-gear-wheel", 10},
  {"electric-engine-unit", 4},
  {"advanced-circuit", 15},
})
-- Rocket droid: launcher on a stabilised (geared) armoured body.
droid(3, "droid-rocket", 20, 6, {
  {"rocket-launcher", 1},
  {"modular-armor", 1},
  {"bob-cobalt-steel-alloy", 25, "steel-plate", 25},
  {"bob-cobalt-steel-gear-wheel", 15, "iron-gear-wheel", 15},
  {"electric-engine-unit", 4},
  {"advanced-circuit", 25},
})
-- Flamebot: flamethrower, heat resistant titanium hull and fuel lines.
droid(4, "droid-flame", 20, 8, {
  {"flamethrower", 1},
  {"modular-armor", 1},
  {"bob-titanium-plate", 25, "steel-plate", 25},
  {"bob-titanium-pipe", 10, "pipe", 10},
  {"electric-engine-unit", 4},
  {"advanced-circuit", 15},
})
-- Terminator: power armour chassis, twin laser turrets, light alloy frame.
droid(5, "terminator", 40, 10, {
  {"power-armor", 1, "modular-armor", 1},
  {"bob-laser-turret-2", 2, "laser-turret", 2},
  {"low-density-structure", 10},
  {"bob-titanium-bearing", 20, "iron-gear-wheel", 20},
  {"bob-battery-2", 20, "battery", 20},
  {"processing-unit", 20},
})
-- Flying units: a wing of Bob's combat robots under a combat brain of the same tier.
droid(6, "defender-unit", 10, 3, {
  {"bob-defender-robot", 10, "defender-capsule", 10},
  {"bob-robot-brain-combat", 5, "electronic-circuit", 25},
})
droid(7, "distractor-unit", 10, 3, {
  {"bob-distractor-robot", 10, "distractor-capsule", 10},
  {"bob-robot-brain-combat-2", 5, "advanced-circuit", 15},
})
droid(8, "destroyer-unit", 16, 8, {
  {"bob-destroyer-robot", 10, "destroyer-capsule", 10},
  {"bob-robot-brain-combat-3", 5, "processing-unit", 10},
})

recipe(B.assembler, 20, {
  {"assembling-machine-3", 1},
  {"intermediate-structure-components", 4, "steel-plate", 50},
  {"bob-cobalt-steel-gear-wheel", 25, "iron-gear-wheel", 25},
  {"electric-engine-unit", 5},
  {"advanced-circuit", 20},
})
recipe(B.station, 20, {
  {"assembling-machine-3", 1},
  {"intermediate-structure-components", 4, "steel-plate", 50},
  {"refined-concrete", 50},
  {"bob-invar-alloy", 25, "steel-plate", 25},
  {"advanced-circuit", 20},
})
recipe(B.counter, 2, {
  {"constant-combinator", 1},
  {"advanced-circuit", 5},
})
if settings.startup[shared.setting.loot_chest].value then
  recipe(B.loot, 5, {
    {"bob-invar-alloy", 20, "steel-plate", 20},
    {"bob-cobalt-steel-gear-wheel", 10, "iron-gear-wheel", 10},
    {"advanced-circuit", 10},
  })
end

data:extend(prototypes)
