
-------- Bio Garden

data:extend({
  
    {
    type = "item",
    name = "bi-bio-garden",
    icon = "__Bio_Industries__/graphics/icons/bio_garden_icon.png",
	icon_size = 32,
    --flags = { "goes-to-quickbar" },
    subgroup = "production-machine",
    order = "x[bi]-b[bi-bio-garden]",
    place_result = "bi-bio-garden",
    stack_size = 10
  },
  
  {
    type = "item",
    name = "bi-purified-air",
    icon = "__Bio_Industries__/graphics/icons/Clean_Air2.png",
	icon_size = 32,
    flags = {"hidden"},
	subgroup = "bio-bio-gardens-fluid",
    order = "bi-purified-air",
    stack_size = 100
  },
  
  
  
  })