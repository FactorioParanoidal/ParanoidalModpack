local order = 15
local function createBIT(name)
  data:extend({
  { type = "item",
    name = "mining-drill-bit-".. name,
    icon = "__KaoExtended__/graphics/mining-drill-bit-".. name ..".png",
    --flags = {},
    subgroup = "mining-drill-bit",
    order = "a-" .. string.char(order),
    stack_size = 50,
	icon_size = 128,
	icon_mipmaps = 4
    }
  })
  order = order + 1
end
data:extend({{
    type = "item-subgroup",
    name = "mining-drill-bit",
    --group = "bob-intermediate-products",
	group = "intermediate-products",
    order = "z-z",
  }})
local function newRecipe(item, time)
  local rec = { type = "recipe",
      name = "mining-drill-bit-".. item,
      category = "crafting-machine",
      enabled = false,
      energy_required = time,
      ingredients = {},
      result = "mining-drill-bit-".. item,
    }
    data:extend({rec})
    return rec
end
createBIT("mk0")
createBIT("mk1")
createBIT("mk2")
createBIT("mk3")
createBIT("mk4")
createBIT("mk5")

newRecipe("mk0", 2).ingredients = {
  {"iron-plate", 8},
  {"iron-stick", 3},
}
data.raw.recipe["mining-drill-bit-mk0"].enabled = true

newRecipe("mk1", 5).ingredients = {
  {"mining-drill-bit-mk0", 2},
  {"iron-plate", 15}
}
bobmods.lib.tech.add_recipe_unlock("electric-mining", "mining-drill-bit-mk0")

newRecipe("mk2", 7).ingredients = {
  {"mining-drill-bit-mk1", 2},
  {"steel-plate", 15}
}
bobmods.lib.tech.add_recipe_unlock("steel-processing", "mining-drill-bit-mk2")

newRecipe("mk3", 12).ingredients = {
  {"mining-drill-bit-mk2", 2},
  {"cobalt-steel-alloy", 20}
}
bobmods.lib.tech.add_recipe_unlock("angels-cobalt-steel-smelting-1", "mining-drill-bit-mk3")

newRecipe("mk4", 15).ingredients = {
  {"mining-drill-bit-mk3", 2},
  {"titanium-plate", 20}
}
bobmods.lib.tech.add_recipe_unlock("bob-drills-3", "mining-drill-bit-mk4")

newRecipe("mk5", 15).ingredients = {
  {"mining-drill-bit-mk4", 2},
  {"nitinol-gear-wheel", 4},
  {"tungsten-carbide", 20}
}
bobmods.lib.tech.add_recipe_unlock("bob-drills-3", "mining-drill-bit-mk5")