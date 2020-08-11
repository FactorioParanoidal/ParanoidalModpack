data:extend({
  {
    type = "technology",
    name = "Fuel-Additive",
    icon = "__more-petrochem-hell__/graphics/Fuel-Additive.png",
    icon_size = 64,
    prerequisites = {"gas-steam-cracking-1","chlorine-processing-1","sodium-processing","angels-lead-smelting-1"},
			
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "sodium-lead-alloy",
      },
	  {
        type = "unlock-recipe",
        recipe = "gas-chloroethane",
      },
	  {
        type = "unlock-recipe",
        recipe = "fluid-tetraethyllead",
      },
	  {
        type = "unlock-recipe",
        recipe = "high-octane-enriched-fuel",
      },
	  
	 
    },
    unit =
    {
      count = 100,
      ingredients = {{"automation-science-pack", 1},
      {"logistic-science-pack", 1},
	  {"chemical-science-pack", 1},
	  },
      time = 30
    },
    order = ""
  },
  
})