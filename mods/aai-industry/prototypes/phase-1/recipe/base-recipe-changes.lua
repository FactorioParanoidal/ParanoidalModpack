-- These are technically recipe updates from base
-- but we are still in the first data phase
-- so that those changes can be propagated to recycling recipes
-- that are done in data-updates by the quality mod.

local util = require("data-util")
local basic_circuit = data.raw.item["basic-circuit-board"] and "basic-circuit-board" or "electronic-circuit"

if settings.startup["aai-fast-motor-crafting"].value then
  util.recipe_set_time("iron-gear-wheel", 0.2)
  util.recipe_set_time("copper-cable", 0.2)
end

-- replace iron plate with stone tablet in "electronic-circuit"
-- skip if bobs mods ["wooden-board"]
if data.raw.recipe["electronic-circuit"] and not data.raw.recipe["wooden-board"] then

  local stone_version = data.raw.recipe["electronic-circuit"]
  local wood_version = table.deepcopy(stone_version)

  util.replace_or_add_ingredient_sub(stone_version, "iron-plate", "stone-tablet", 1)
  stone_version.order = data.raw.item["electronic-circuit"].order .. "-a" -- Main
  stone_version.localised_name = {"item-name.electronic-circuit"}
  stone_version.allow_productivity = true

  util.replace_or_add_ingredient_sub(wood_version, "iron-plate", "wood", 1)
  wood_version.name = "electronic-circuit-wood"
  wood_version.allow_as_intermediate = false -- Use the stone recipe for intermediates' handcrafting
  wood_version.icon = nil
  wood_version.icons = util.sub_icons(data.raw.item["electronic-circuit"].icon,
                                      data.raw.item["wood"].icon)
  wood_version.order = data.raw.item["electronic-circuit"].order .. "-b" -- Alternate
  wood_version.localised_name = {"", {"item-name.electronic-circuit"}, " (", {"item-name.wood"}, ")"}
  wood_version.allow_productivity = true
  wood_version.hide_from_signal_gui = false
  wood_version.auto_recycle = false

  data:extend({
    wood_version,
  })
end


util.conditional_modify({
  type = "recipe",
  name = "repair-pack",
  allow_productivity = true,
  ingredients = {
    {type="item", name="iron-plate", amount=3},
    {type="item", name="copper-plate", amount=3},
    {type="item", name="stone", amount=3}
  },
})

-- Halve inserters required for green science
if data.raw.recipe["logistic-science-pack"] and data.raw.recipe["logistic-science-pack"].ingredients then
  local set = data.raw.recipe["logistic-science-pack"]
  if set and type(set) == "table" then
    local found
    for _, ingredient in pairs(set.ingredients) do
      if ingredient.name == "transport-belt" then
        found = true
        break
      end
    end
    if found then
      util.replace_or_add_ingredient(data.raw.recipe["logistic-science-pack"], "transport-belt", "transport-belt", 2)
      util.recipe_set_time("logistic-science-pack", 10)
      util.recipe_set_result_count("logistic-science-pack", 2)
    end
  end
end

-- Reduce LDS and flying robot frames required for yellow science
if data.raw.recipe["utility-science-pack"] then
  util.replace_or_add_ingredient(data.raw.recipe["utility-science-pack"], "processing-unit", "processing-unit", 3)
  util.recipe_set_time("utility-science-pack", 35)
  util.recipe_set_result_count("utility-science-pack", 5)
end


util.conditional_modify({
  type = "recipe",
  name = "automation-science-pack",
  category = "basic-crafting", -- not hand crafted
})
util.conditional_modify({
  type = "recipe",
  name = "logistic-science-pack",
  category = "advanced-crafting", -- not hand crafted, electric only
})
util.conditional_modify({
  type = "recipe",
  name = "military-science-pack",
  category = "advanced-crafting", -- not hand crafted, electric only
})
util.conditional_modify({
  type = "recipe",
  name = "chemical-science-pack",
  category = "advanced-crafting", -- not hand crafted, electric only
})
util.conditional_modify({
  type = "recipe",
  name = "utility-science-pack",
  category = "advanced-crafting", -- not hand crafted, electric only
})
util.conditional_modify({
  type = "recipe",
  name = "production-science-pack",
  category = "advanced-crafting", -- not hand crafted, electric only
})
util.conditional_modify({
  type = "recipe",
  name = "space-science-pack",
  category = "advanced-crafting", -- not hand crafted, electric only
})


util.conditional_modify({
  type = "recipe",
  name = "steel-furnace",
  ingredients = {
    {type = "item", name = "stone-brick", amount = 6},
    {type = "item", name = "steel-plate", amount = 6},
    {type = "item", name = "stone-furnace", amount = 1},
  },
})

util.conditional_modify({
  type = "recipe",
  name = "electric-furnace",
  ingredients = {
    {type = "item", name = "steel-plate", amount = 5},
    {type = "item", name = "advanced-circuit", amount = 5},
    {type = "item", name = "concrete", amount = 5},
    {type = "item", name = "steel-furnace", amount = 1}
  },
})


util.conditional_modify({
  type = "recipe",
  name = "engine-unit",
  category = "crafting", -- engine can be hand crafted
  ingredients = {
    {type="item", name="steel-plate", amount=2},
    {type="item", name="iron-gear-wheel", amount=2},
    {type="item", name="motor", amount=2}
  },
  results= { {type="item", name="engine-unit", amount=1} },
})

util.conditional_modify({
  type = "recipe",
  name = "electric-engine-unit",
  ingredients = {
    {type="fluid", name="lubricant", amount=40},
    {type="item", name="steel-plate", amount=2},
    {type="item", name="electronic-circuit", amount=4},
    {type="item", name="electric-motor", amount=2},
  },
  results= { {type="item", name="electric-engine-unit", amount=1} },
})

util.conditional_modify({
  type = "recipe",
  name = "concrete",
  ingredients = {
    {type="item", name="stone-brick", amount=5},
    {type="item", name=aai_sand_name, amount=10},
    {type="item", name="iron-stick", amount=2},
    {type="fluid", name="water", amount=100}
  },
  results= { {type="item", name="concrete", amount=10} },
})

util.conditional_modify({
  type = "recipe",
  name = "burner-inserter",
  ingredients = {
    {type="item", name="iron-stick", amount=2},
    {type="item", name="motor", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "inserter",
  enabled = false,
  ingredients = {
    {type="item", name="burner-inserter", amount=1},
    {type="item", name="electric-motor", amount=1}
  },
})

if not data.raw.inserter["red-inserter"] then -- not bobs
  util.conditional_modify({
    type = "recipe",
    name = "long-handed-inserter",
    enabled = false,
    ingredients = {
      {type="item", name="inserter", amount=1},
      {type="item", name="iron-plate", amount=2},
      {type="item", name="iron-stick", amount=2}
    },
  })
end


if data.raw.recipe["basic-transport-belt"] then
  util.replace_or_add_ingredient (data.raw.recipe["basic-transport-belt"], "iron-gear-wheel", "motor", 1)
  util.replace_or_add_ingredient (data.raw.recipe["transport-belt"], "iron-gear-wheel", "electric-motor", 1)
else
  util.conditional_modify({
    type = "recipe",
    name = "transport-belt",
    ingredients = {
      {type="item", name="iron-plate", amount=1},
      {type="item", name="motor", amount=1}
    },
  })
end

if data.raw.item["basic-splitter"] then
  util.conditional_modify({
    type = "recipe",
    name = "splitter",
      enabled = false,
      ingredients = {
        {type="item", name="iron-plate", amount=8}, -- should splitters should be made cheapre if they already have another item in the recipes?
        {type="item", name="motor", amount=2},
        {type="item", name="transport-belt", amount=2},
        {type="item", name="basic-splitter", amount=1}
    },
  })

else
  util.conditional_modify({
    type = "recipe",
    name = "splitter",
    enabled = false,
    ingredients = {
      {type="item", name="iron-plate", amount=8},
      {type="item", name="transport-belt", amount=4},
      {type="item", name="motor", amount=4}
    },
  })
end


util.conditional_modify({
  type = "recipe",
  name = "boiler",
  enabled = false,
  ingredients = {
    {type = "item", name = "stone-furnace", amount = 1},
    {type = "item", name = "pipe", amount = 4}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "steam-engine",
  enabled = false,
  ingredients =
  {
    {type="item", name="iron-plate", amount=10},
    {type="item", name="iron-gear-wheel", amount=5},
    {type="item", name="electric-motor", amount=3}
  },
})

util.replace_or_add_ingredient(data.raw.recipe["steam-turbine"], "copper-plate", "copper-plate", 30)
util.replace_or_add_ingredient(data.raw.recipe["steam-turbine"], "iron-gear-wheel", "iron-gear-wheel", 30)
util.replace_or_add_ingredient(data.raw.recipe["steam-turbine"], "electric-motor", "electric-motor", 10)

util.replace_or_add_ingredient(data.raw.recipe["centrifuge"], "electric-motor", "electric-motor", 25)

util.conditional_modify({
  type = "recipe",
  name = "burner-mining-drill",
  ingredients = {
    {type="item", name="stone-brick", amount=4},
    {type="item", name="iron-plate", amount=4},
    {type="item", name="motor", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "electric-mining-drill",
  enabled = false,
  ingredients = {
    {type="item", name="iron-gear-wheel", amount=4},
    {type="item", name="electric-motor", amount=4},
    {type="item", name="burner-mining-drill", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "assembling-machine-1",
  ingredients = {
    {type="item", name="iron-gear-wheel", amount=4},
    {type="item", name="electric-motor", amount=1},
    {type="item", name="burner-assembling-machine", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "assembling-machine-2",
  ingredients = {
    {type="item", name="steel-plate", amount=2},
    {type="item", name="electronic-circuit", amount=2},
    {type="item", name="electric-motor", amount=2},
    {type="item", name="assembling-machine-1", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "assembling-machine-3",
  ingredients = {
    {type="item", name="concrete", amount=8},
    {type="item", name="steel-plate", amount=8},
    {type="item", name="advanced-circuit", amount=8},
    {type="item", name="electric-engine-unit", amount=4},
    {type="item", name="assembling-machine-2", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "chemical-plant",
  ingredients = {
    {type="item", name="steel-plate", amount=5},
    {type="item", name="electric-motor", amount=5},
    {type="item", name=aai_glass_name, amount=5},
    {type="item", name="pipe", amount=5},
    {type="item", name="stone-brick", amount=5}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "oil-refinery",
  ingredients = {
    {type="item", name="steel-plate", amount=15},
    {type="item", name="electric-motor", amount=15},
    {type="item", name=aai_glass_name, amount=15},
    {type="item", name="pipe", amount=15},
    {type="item", name="stone-brick", amount=15}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "lab",
  ingredients = {
    {type="item", name="electronic-circuit", amount=5},
    {type="item", name="electric-motor", amount=5},
    {type="item", name=aai_glass_name, amount=5},
    {type="item", name="burner-lab", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "beacon",
  ingredients = {
    {type="item", name="advanced-circuit", amount=20},
    {type="item", name="concrete", amount=10},
    {type="item", name="steel-plate", amount=10},
    {type="item", name="electric-motor", amount=10}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "offshore-pump",
  enabled = false,
  ingredients = {
    {type="item", name="electric-motor", amount=2},
    {type="item", name="pipe", amount=4}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "pump",
  ingredients = {
    {type="item", name="electric-motor", amount=2},
    {type="item", name="pipe", amount=2},
    {type="item", name="steel-plate", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "pumpjack",
  ingredients = {
    {type="item", name="steel-plate", amount=15},
    {type="item", name="iron-gear-wheel", amount=10},
    {type="item", name="electric-motor", amount=10},
    {type="item", name="pipe", amount=10}
  },
})


util.conditional_modify({
  type = "recipe",
  name = "medium-electric-pole",
  ingredients = {
    {type="item", name="iron-stick", amount=4},
    {type="item", name="steel-plate", amount=2},
    {type="item", name="copper-cable", amount=4},
    {type="item", name="small-iron-electric-pole", amount=1}
  }
})

util.conditional_modify({
  type = "recipe",
  name = "big-electric-pole",
  ingredients = {
    {type="item", name="iron-stick", amount=8},
    {type="item", name="steel-plate", amount=5},
    {type="item", name="copper-cable", amount=10},
    {type="item", name="concrete", amount=1}
  }
})

util.conditional_modify({
  type = "recipe",
  name = "substation",
  ingredients = {
    {type="item", name="copper-cable", amount=20},
    {type="item", name="steel-plate", amount=10},
    {type="item", name="concrete", amount=5},
    {type="item", name="advanced-circuit", amount=5}
  },
})

if data.raw.recipe["roboport-door-1"] then
  -- modify bobs roboport components

  util.replace_or_add_ingredient (data.raw.recipe["roboport-antenna-1"], nil, "electric-motor", 10)
  util.replace_or_add_ingredient (data.raw.recipe["roboport-antenna-1"], "steel-plate", "steel-plate", 15)
  util.replace_or_add_ingredient (data.raw.recipe["roboport-antenna-1"], "electronic-circuit", "electronic-circuit", 25)
  util.replace_or_add_ingredient (data.raw.recipe["roboport-chargepad-1"], nil, "electric-motor", 3)
  util.replace_or_add_ingredient (data.raw.recipe["roboport-chargepad-1"], "steel-plate", "steel-plate", 10)
  util.replace_or_add_ingredient (data.raw.recipe["roboport-door-1"], nil, "electric-motor", 30)
  util.replace_or_add_ingredient (data.raw.recipe["roboport-door-1"], "steel-plate", "steel-plate", 30)
  util.replace_or_add_ingredient (data.raw.recipe["roboport-door-1"], nil, "concrete", 50)

else
  -- modify vanilla
  util.conditional_modify({
    type = "recipe",
    name = "roboport",
    ingredients = {
      {type="item", name="steel-plate", amount=50},
      {type="item", name="electric-motor", amount=50},
      {type="item", name="advanced-circuit", amount=50},
      {type="item", name="concrete", amount=50}
    },
  })
end

util.conditional_modify({
  type = "recipe",
  name = "basic-oil-processing",
  ingredients = {
    {type="fluid", name="water", amount=50},
    {type="fluid", name="crude-oil", amount=100}
  },
  results=
  {
    {type="fluid", name="petroleum-gas", amount=90, fluidbox_index = 3}
  }
})

if data.raw.recipe["basic-oil-processing"] then
  data.raw.recipe["basic-oil-processing"].icon = "__aai-industry__/graphics/icons/basic-oil-processing.png"
end

if data.raw.recipe["advanced-oil-processing"] then
  util.conditional_modify({
    type = "recipe",
    name = "advanced-oil-processing",
    ingredients = {
      {type="fluid", name="water", amount=50},
      {type="fluid", name="crude-oil", amount=100}
    },
    results=
    {
      {type="fluid", name="heavy-oil", amount=20},
      {type="fluid", name="light-oil", amount=70},
      {type="fluid", name="petroleum-gas", amount=30}
    },
  })
  data.raw.recipe["advanced-oil-processing"].icon = "__aai-industry__/graphics/icons/advanced-oil-processing.png"
end

data:extend({
  {
    type = "recipe",
    name = "oil-processing-heavy",
    category = "oil-processing",
    enabled = false,
    energy_required = 2,
    ingredients =
    {
      {type="fluid", name="water", amount=10},
      {type="fluid", name="crude-oil", amount=100}
    },
    results=
    {
      {type="fluid", name="heavy-oil", amount=70},
      {type="fluid", name="light-oil", amount=30},
      {type="fluid", name="petroleum-gas", amount=20}
    },
    allow_productivity = true,
    icon = "__aai-industry__/graphics/icons/crude-oil-processing.png",
    subgroup = "fluid-recipes",
    order = "a[oil-processing]-b[advanced-oil-processing]"
  }
})
util.tech_lock_recipes(
    "advanced-oil-processing",  {
        "oil-processing-heavy"})

util.conditional_modify({
  type = "recipe",
  name = "car",
  ingredients = {
    {type="item", name="iron-gear-wheel", amount=10},
    {type="item", name="steel-plate", amount=5},
    {type="item", name="engine-unit", amount=5}
  }
})

util.conditional_modify({
  type = "recipe",
  name = "locomotive",
  ingredients = {
    {type="item", name="steel-plate", amount=30},
    {type="item", name="engine-unit", amount=15},
    {type="item", name="iron-gear-wheel", amount=10},
    {type="item", name="electronic-circuit", amount=10}
  }
})

util.conditional_modify({
  type = "recipe",
  name = "flying-robot-frame",
  ingredients = {
    {type="item", name="electric-engine-unit", amount=4},
    {type="item", name="battery", amount=4},
    {type="item", name="electronic-circuit", amount=4},
    {type="item", name="steel-plate", amount=4}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "gun-turret",
  ingredients = {
    {type="item", name="iron-plate", amount=20},
    --{type="item", name=basic_circuit, amount=6},
    {type="item", name="iron-gear-wheel", amount=10},
    {type="item", name="motor", amount=5}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "laser-turret",
  ingredients = {
    {type="item", name="steel-plate", amount=20},
    {type="item", name="electronic-circuit", amount=20},
    {type="item", name=aai_glass_name, amount=20},
    {type="item", name="battery", amount=12},
    {type="item", name="electric-motor", amount=5}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "gate",
  ingredients = {
    {type="item", name="stone-wall", amount=1},
    {type="item", name="steel-plate", amount=2},
    {type="item", name=basic_circuit, amount=2},
    {type="item", name="motor", amount=2}
  }
})

util.conditional_modify({
  type = "recipe",
  name = "small-lamp",
  enabled = false,
  ingredients = {
    {type="item", name="iron-plate", amount=1},
    {type="item", name="copper-cable", amount=4},
    {type="item", name=aai_glass_name, amount=1}
  },
})


util.conditional_modify({
  type = "recipe",
  name = "radar",
  enabled = false,
  ingredients = {
    {type="item", name="iron-plate", amount=20},
    {type="item", name="electronic-circuit", amount=8},
    {type="item", name="stone-brick", amount=4},
    {type="item", name="electric-motor", amount=4}
  },
})


-- armour upgrade path
if data.raw.armor["light-armor"] and data.raw.recipe["heavy-armor"] then
  util.replace_or_add_ingredient(data.raw.recipe["heavy-armor"], nil, "light-armor", 1)
end
if data.raw.armor["heavy-armor"] and data.raw.recipe["modular-armor"] then
  util.replace_or_add_ingredient(data.raw.recipe["modular-armor"], nil, "heavy-armor", 1)
end
if data.raw.armor["modular-armor"] and data.raw.recipe["power-armor"] then
  util.replace_or_add_ingredient(data.raw.recipe["power-armor"], nil, "modular-armor", 1)
end
if data.raw.armor["power-armor"] and data.raw.recipe["power-armor-mk2"] then
  util.replace_or_add_ingredient(data.raw.recipe["power-armor-mk2"], nil, "power-armor", 1)
end

util.replace_or_add_ingredient("solar-panel", aai_glass_name, aai_glass_name, 5)
util.replace_or_add_ingredient("satellite", nil, aai_glass_name, 100)
util.replace_or_add_ingredient("personal-laser-defense-equipment", nil, aai_glass_name, 100)
