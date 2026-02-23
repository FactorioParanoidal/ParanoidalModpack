local util = require("data-util")

data:extend({
  {
    ingredients = {
      { type = "item", name = "stone", amount = 1 }
    },
    name = "sand",
    results = {{type = "item", name = aai_sand_name, amount = 2}},
    type = "recipe",
    enabled = false,
    energy_required = 0.5,
    allow_productivity = true,
    auto_recycle = false,
    main_product = aai_sand_name,
    localised_name = {"item-name."..aai_sand_name},
  }
})

data:extend({
  {
    category = "smelting",
    enabled = true,
    energy_required = 4,
    ingredients = {
      { type = "item", name = aai_sand_name, amount = 4 }
    },
    results = {{type = "item", name = aai_glass_name, amount = 1}},
    name = "glass",
    type = "recipe",
    allow_productivity = true,
    main_product = aai_glass_name,
    localised_name = {"item-name."..aai_glass_name},
  }
})

data:extend({{
    type = "recipe",
    name = "stone-tablet",
    category = "crafting",
    energy_required = 0.5,
    allow_productivity = true,
    ingredients =
    {
      {type="item", name="stone-brick", amount=1}
    },
    results= { {type="item", name="stone-tablet", amount=4} }
}})

data:extend({{
    type = "recipe",
    name = "motor",
    category = "crafting",
    allow_productivity = true,
    energy_required = settings.startup["aai-fast-motor-crafting"].value and 0.3 or 0.6,
    ingredients = {
      {type="item", name="iron-plate", amount=1},
      {type="item", name="iron-gear-wheel", amount=1}
    },
    results= { {type="item", name="motor", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "electric-motor",
    category = "crafting",
    allow_productivity = true,
    enabled = false,
    energy_required = settings.startup["aai-fast-motor-crafting"].value and 0.4 or 0.8,
    ingredients = {
      {type="item", name="iron-plate", amount=1},
      {type="item", name="iron-gear-wheel", amount=1},
      {type="item", name="copper-cable", amount=6}
    },
    results= { {type="item", name="electric-motor", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "small-iron-electric-pole",
    category = "crafting",
    energy_required = 0.25,
    enabled = false,
    ingredients =
    {
      {type = "item", name = "iron-stick", amount = 2},
      {type = "item", name = "copper-cable", amount = 2}
    },
    results= { {type="item", name="small-iron-electric-pole", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "concrete-wall",
    category = "crafting",
    enabled = false,
    energy_required = 0.25,
    ingredients =
    {
      { type = "item", name = "stone-wall", amount = 1 },
      { type = "item", name = "concrete", amount = 12 }
    },
    results= { {type="item", name="concrete-wall", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "steel-wall",
    category = "crafting",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {type = "item", name = "concrete-wall", amount = 1 },
      {type = "item", name = "steel-plate", amount = 5 }
    },
    results= { {type="item", name="steel-wall", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "concrete-gate",
    category = "crafting",
    enabled = false,
    energy_required = 0.25,
    ingredients =
    {
      { type = "item", name = "gate", amount = 1 },
      { type = "item", name = "advanced-circuit", amount = 2 },
      { type = "item", name = "concrete", amount = 12 }
    },
    results= { {type="item", name="concrete-gate", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "steel-gate",
    category = "crafting",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {type = "item", name = "concrete-gate", amount = 1 },
      {type = "item", name = "processing-unit", amount = 2 },
      {type = "item", name = "steel-plate", amount = 5 }
    },
    results= { {type="item", name="steel-gate", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "burner-lab",
    category = "crafting",
    enabled = true,
    energy_required = 0.5,
    ingredients =
    {
      {type="item", name="motor", amount=10},
      {type="item", name="copper-plate", amount=10},
      {type="item", name="stone-brick", amount=5}
    },
    results= { {type="item", name="burner-lab", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "burner-turbine",
    category = "crafting",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {type="item", name="electric-motor", amount=4},
      {type="item", name="iron-gear-wheel", amount=5},
      {type="item", name="stone-furnace", amount=1}
    },
    results= { {type="item", name="burner-turbine", amount=1} }
}})

data:extend({{
    type = "recipe",
    name = "burner-assembling-machine",
    category = "crafting",
    energy_required = 0.5,
    ingredients = {
      {type="item", name="iron-plate", amount=8},
      {type="item", name="stone-brick", amount=4},
      {type="item", name="motor", amount=1}
    },
    results= { {type="item", name="burner-assembling-machine", amount=1} }
  }
})
