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