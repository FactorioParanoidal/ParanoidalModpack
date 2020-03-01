data:extend(
{
  {
    type = "recipe",
    name = "copper-cable",

    energy_required = 2,
    ingredients = {{"copper-plate", 5}},
    result = "copper-cable",
    result_count = 2,
  },
  
  {
    type = "recipe",
    name = "gilded-copper-cable",
	enabled = false,

    energy_required = 2,
    ingredients = {
      {"copper-cable", 2},
	  {"gold-plate", 1},
    },
    result = "gilded-copper-cable",
  },
  
  {
    type = "recipe",
    name = "electronic-circuit",

    energy_required = 6,
    ingredients = {
      {"basic-electronic-components", 16},
	  {"basic-circuit-board", 1},
	  {"copper-cable", 4},
    },
    result = "electronic-circuit",
  },
 
  {
    type = "recipe",
    name = "advanced-circuit",
    enabled = false,

    energy_required = 8,
    ingredients = {
      {"electronic-circuit", 2},
	  {"electronic-components", 8},
	  {"circuit-board", 1},
      {"tinned-copper-cable", 4},
    },
    result = "advanced-circuit"
  },
})
