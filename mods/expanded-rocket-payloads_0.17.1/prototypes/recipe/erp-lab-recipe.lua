 data:extend({
  {
    type = "recipe",
    name = "erp-lab",
    energy_required = 20,
    subgroup = "buildings",
	enabled = false, -- DrD
    ingredients =
    {
      {"electronic-circuit", 200},
      {"processing-unit", 50},
      {"advanced-circuit", 100},
	  {"gilded-copper-cable", 100}, -- DrD
      {"steel-plate", 100},
    },
    result = "erp-lab"
  }
 })