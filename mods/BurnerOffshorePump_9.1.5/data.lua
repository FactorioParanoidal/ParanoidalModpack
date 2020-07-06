
require ('prototypes.burner-offshore-pump')
require ('prototypes.electric-offshore-pump')
require ('prototypes.electric-modular-offshore-pump')



local recipe_category = {name = "bop-fluids-making", type = "recipe-category"}

local fixed_recipe = {
  type = 'recipe',
  name = 'bop-make-water',
  category = 'bop-fluids-making',
  hidden = true,
--  hide_from_stats = true,  
  hide_from_stats = false,  
  
  icon = '__BurnerOffshorePump__/graphics/icons/empty.png',
  icon_size = 32,
  energy_required = 1, -- default is 0.5
  ingredients = {},
  results = {{type = "fluid", name = "water", amount = 300}},
  subgroup = "fluid-recipes",
}

-- speed 1: 120 fluids / sec
-- speed 10: 1200 fluids / second


data:extend ({recipe_category, fixed_recipe})


data.raw.item["offshore-pump"].flags = {'hidden'}
data.raw.recipe["offshore-pump"].hidden = true