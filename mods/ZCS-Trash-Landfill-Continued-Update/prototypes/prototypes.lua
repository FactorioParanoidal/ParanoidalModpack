local GFX = "__ZCS-Trash-Landfill-Continued-Update__/graphics/"

-- ENTITY
local landfill_entity = {
  type = "container",
  name = "zcs-trash-landfill",
  icon = GFX .. "zcs-trash-landfill.png",
  icon_size = 32,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.5, result = "zcs-trash-landfill"},
  max_health = 1200,
  corpse = "big-remnants",

  collision_box = {{-8.4, -8.4}, {8.4, 8.4}},
  selection_box = {{-8.5, -8.5}, {8.5, 8.5}},

  inventory_size = 48,
  picture = {
    filename = GFX .. "zcs-trash-landfill-entity.png",
    size = 637,
    scale = 1.0
  }
}

-- ITEM
local landfill_item = {
  type = "item",
  name = "zcs-trash-landfill",
  icon = GFX .. "zcs-trash-landfill.png",
  icon_size = 32,
  subgroup = "storage",
  order = "z[zcs-trash-landfill]",
  place_result = "zcs-trash-landfill",
  stack_size = 10
}

-- RECIPE (Factorio 2.0: typed ingredients/results)
local landfill_recipe = {
  type = "recipe",
  name = "zcs-trash-landfill",
  enabled = false,
  ingredients = {
    {type = "item", name = "stone-brick",  amount = 60},
    {type = "item", name = "stone-wall",   amount = 20},
    {type = "item", name = "steel-plate",  amount = 8},
    {type = "item", name = "copper-plate", amount = 12},
    {type = "item", name = "iron-plate",   amount = 12}
  },
  results = {
    {type = "item", name = "zcs-trash-landfill", amount = 1}
  },
  main_product = "zcs-trash-landfill"
}

-- TECHNOLOGY
local landfill_tech = {
  type = "technology",
  name = "zcs-trash-landfill-tech",
  icon = GFX .. "zcs-trash-landfill.png",
  icon_size = 32,
  effects = {
    {type = "unlock-recipe", recipe = "zcs-trash-landfill"}
  },
  prerequisites = {"stone-wall", "steel-processing"}, -- nombres internos correctos
  unit = {
    count = 100,
    ingredients = { {"automation-science-pack", 1} },
    time = 15
  },
  order = "a-b-z"
}

data:extend{landfill_entity, landfill_item, landfill_recipe, landfill_tech}
