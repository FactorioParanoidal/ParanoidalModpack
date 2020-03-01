--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]

local base_recipes = {
  ["locomotive"] = 10,
  ["cargo-wagon"] = 4,
  ["fluid-wagon"] = 4,
  ["artillery-wagon"] = 20,  
}

for name, energy in pairs(base_recipes) do
  local recipe = data.raw.recipe[name]
  recipe.category = "advanced-crafting"
  recipe.energy_required = energy
end

data:extend({
	{
		type = "recipe",
		name = "heavy-locomotive",
		category = "advanced-crafting",
		energy_required = 10,	
		enabled = false,
		ingredients =
		{
			{"locomotive", 1},
			{"advanced-circuit", 20},
			{"effectivity-module", 10}
		},
		result = "heavy-locomotive"
	},
	{
		type = "recipe",
		name = "express-locomotive",
		category = "advanced-crafting",
		energy_required = 10,	
		enabled = false,
		ingredients =
		{
			{"locomotive", 1},
			{"advanced-circuit", 20},
			{"speed-module", 10}
		},
		result = "express-locomotive"
	},
	{
		type = "recipe",
		name = "heavy-nuclear-locomotive",
		category = "crafting-with-fluid",
		energy_required = 10,		
		enabled = false,
		ingredients =
		{
			{"heavy-locomotive", 1},
			{"steam-turbine", 1},
			{type="fluid", name= "lubricant", amount = 300},
			{"steel-plate", 30},
			{"copper-cable", 20},
		},
		result = "nuclear-locomotive"
	},
	{
		type = "recipe",
		name = "express-nuclear-locomotive",
		category = "crafting-with-fluid",
		energy_required = 10,
		enabled = false,
		ingredients =
		{
			{"express-locomotive", 1},
			{"steam-turbine", 1},
			{type="fluid", name= "lubricant", amount = 300},
			{"steel-plate", 30},
			{"copper-cable", 20},
		},
		result = "nuclear-locomotive"
	},
  {
    type = "recipe",
    name = "heavy-cargo-wagon",
    category = "advanced-crafting",
    energy_required = 8,
    enabled = false,
    ingredients =
    {
      {"cargo-wagon", 1},
      {"effectivity-module", 5}
    },
    result = "heavy-cargo-wagon"
  },  
  {
    type = "recipe",
    name = "express-cargo-wagon",
    category = "advanced-crafting",
    energy_required = 8,
    enabled = false,
    ingredients =
    {
      {"cargo-wagon", 1},
      {"speed-module", 5}
    },
    result = "express-cargo-wagon"
  },    
  {
    type = "recipe",
    name = "heavy-fluid-wagon",
    category = "advanced-crafting",
    energy_required = 8,
    enabled = false,
    ingredients =
    {
      {"fluid-wagon", 1},
      {"effectivity-module", 5}
    },
    result = "heavy-fluid-wagon"
  }, 
  {
    type = "recipe",
    name = "express-fluid-wagon",
    category = "advanced-crafting",
    energy_required = 8,
    enabled = false,
    ingredients =
    {
      {"fluid-wagon", 1},
      {"speed-module", 5}
    },
    result = "express-fluid-wagon"
  },      
})
