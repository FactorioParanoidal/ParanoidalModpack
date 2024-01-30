
bobmods.lib.recipe.add_new_ingredient("angels-bio-yield-module", {type = "item", name = "alien-artifact", amount = 5})
bobmods.lib.recipe.add_new_ingredient("angels-bio-yield-module-2", {type = "item", name = "alien-artifact", amount = 10})
bobmods.lib.recipe.add_new_ingredient("angels-bio-yield-module-3", {type = "item", name = "alien-artifact", amount = 20})

--[[
data:extend({
    { type = "recipe",
    name = "wood-brick-to-thermal-water",
    icon = data.raw["fluid"]["thermal-water"].icon,
	icon_size = 32,
    category = "liquifying",
    enabled = false,
    subgroup = "bio-processing",
    order = "a-a",
    ingredients ={
      {type="fluid",name="water",amount=10},
      {"wood-bricks", 1}
    },
    results = {
      {type="fluid",name="thermal-water",amount=10}
    },
    energy_required = 20
    },
})
table.insert( data.raw["technology"]["bio-processing-green"].effects, {type = "unlock-recipe", recipe = "wood-brick-to-thermal-water"})
]]