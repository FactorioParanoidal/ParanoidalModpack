local order = 65
local function createSC(name)
  data:extend({
  { type = "item",
    name = name.."-structure-components",
    icon = "__KaoExtended__/graphics/" .. name .. "SC.png",
    --flags = {},
    subgroup = "structurecomponents",
    order = "a-" .. string.char(order),
    stack_size = 50,
    icon_size = 32
    }
  })
  order = order + 1
end
data:extend({{
    type = "item-subgroup",
    name = "structurecomponents",
    --group = "bob-intermediate-products",
	group = "intermediate-products",
    order = "z-z",
  }})
local function newRecipe(item, time)
  local rec = { type = "recipe",
      name = item.."-structure-components",
      category = "crafting-machine",
      enabled = false,
      energy_required = time,
      ingredients = {},
      result = item.."-structure-components",
    }
    data:extend({rec})
    return rec
end
createSC("basic")
createSC("intermediate")
createSC("advanced")
createSC("anotherworld")
newRecipe("basic", 15).ingredients = {
  {"lead-plate", 33},
  {"glass", 15},
  {"stone-brick", 22}
}
newRecipe("intermediate", 30).ingredients = {
  {"basic-structure-components", 2},
  {"brass-gear-wheel", 8},
  {"cobalt-plate", 10},
  {"invar-alloy", 25}
}
newRecipe("advanced", 60).ingredients = {
  {"intermediate-structure-components", 2},
  {"tungsten-plate", 27},
  {"aluminium-plate", 32},
  {"titanium-plate", 52},
  {"cobalt-steel-alloy", 20},
  {"plastic-bar", 40}
}
if
  data.raw.item["alien-science-pack"]
then
newRecipe("anotherworld", 120).ingredients = {
  {"advanced-structure-components", 10},
  {"plastic-bar", 200},
  {"tungsten-carbide", 200},
  {"titanium-bearing", 200},
  {"ceramic-bearing", 200},
  {"gold-plate", 100},
  {"silver-plate", 100}, 
  --{"electrum-alloy", 200},
  {"nitinol-gear-wheel", 200},
  {"alien-science-pack", 200}
}
else
newRecipe("anotherworld", 120).ingredients = {
  {"advanced-structure-components", 10},
  {"plastic-bar", 200},
  {"tungsten-carbide", 200},
  {"titanium-bearing", 200},
  {"ceramic-bearing", 200},
  {"gold-plate", 100},
  {"silver-plate", 100}, 
  --{"electrum-alloy", 200},
  {"nitinol-gear-wheel", 200},

}
end


bobmods.lib.recipe.remove_ingredient("brass-alloy", "copper-plate")
bobmods.lib.recipe.remove_ingredient("brass-alloy", "zinc-plate")
table.insert( data.raw["recipe"]["brass-alloy"].ingredients, {"bronze-alloy", 2})
table.insert( data.raw["recipe"]["brass-alloy"].ingredients, {"zinc-plate", 8})

bobmods.lib.recipe.remove_ingredient("invar-alloy", "iron-plate")
table.insert( data.raw["recipe"]["invar-alloy"].ingredients, {"lead-plate", 3})
bobmods.lib.recipe.remove_ingredient("cobalt-steel-alloy", "iron-plate")
bobmods.lib.recipe.remove_ingredient("cobalt-steel-alloy", "cobalt-plate")
table.insert( data.raw["recipe"]["cobalt-steel-alloy"].ingredients, {"steel-plate", 3})
table.insert( data.raw["recipe"]["cobalt-steel-alloy"].ingredients, {"cobalt-plate", 1})
