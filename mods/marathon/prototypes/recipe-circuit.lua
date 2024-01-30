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
	  {"circuit-board", 2},
      {"tinned-copper-cable", 4},
    },
    result = "advanced-circuit"
  },
})

-- from bobelectronics electronics.lua
data:extend(
{
  {
    type = "item",
    name = "phenolic-board",
    icon = "__bobelectronics__/graphics/icons/phenolic-board.png",
    icon_size = 128,
    subgroup = "bob-boards",
    order = "c-a2[phenolic-board]",
    stack_size = 200
  },

  {
    type = "recipe",
    name = "phenolic-board",
    category = "electronics-machine",
    enabled = false,
    ingredients =
    {
      {"wooden-board", 2}, --DrD wood, 1
      {"resin", 1},
    },
    result = "phenolic-board",
    result_count = 2
  },
})


data:extend(
{
  {
    type = "item",
    name = "circuit-board",
    icon = "__bobelectronics__/graphics/icons/circuit-board.png",
    icon_size = 128,
    subgroup = "bob-electronic-boards",
    order = "c-b2[circuit-board]",
    stack_size = 200
  },

  {
    type = "recipe",
    name = "circuit-board",
    category = "electronics-machine",
    energy_required = 5,
    enabled = false,
    ingredients = --DrD
    {
      {"phenolic-board", 2},
      {"copper-plate", 4},
      {type="fluid", name="ferric-chloride-solution", amount=10}
    },
    result = "circuit-board",
    allow_decomposition = false
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "superior-circuit-board",
    icon = "__bobelectronics__/graphics/icons/superior-circuit-board.png",
    icon_size = 128,
    subgroup = "bob-electronic-boards",
    order = "c-b3[superior-circuit-board]",
    stack_size = 200
  },

  {
    type = "recipe",
    name = "superior-circuit-board",
    category = "electronics-machine",
    energy_required = 10,
    enabled = false,
    ingredients = --DrD
    {
      {"fibreglass-board", 2},
      {"copper-plate", 5},
      {type="fluid", name="ferric-chloride-solution", amount=15}
    },
    result = "superior-circuit-board",
    allow_decomposition = false
  },
}
)


data:extend(
{
  {
    type = "item",
    name = "processing-unit",
    icon = "__bobelectronics__/graphics/icons/electronic-logic-board.png",
    icon_size = 128,
    subgroup = "bob-electronic-boards",
    order = "c-c3[electronic-logic-board]",
    stack_size = 200
  },

  {
    type = "recipe",
    name = "processing-unit",
    category = "electronics",
    normal =
    {
      energy_required = 10,
      enabled = false,
      ingredients =
      {
        {"superior-circuit-board", 1},
        --{"basic-electronic-components", 2},  --DrD
        {"electronic-components", 4},
        {"intergrated-electronics", 2},
      },
      result = "processing-unit",
      allow_decomposition = false
    },
    expensive =
    {
      energy_required = 16,
      enabled = false,
      ingredients =
      {
        {"superior-circuit-board", 1},
        --{"basic-electronic-components", 3},  --DrD
        {"electronic-components", 6},
        {"intergrated-electronics", 3},
      },
      result = "processing-unit",
      allow_decomposition = false
    },
    allow_decomposition = false
  },
}
)


data:extend(
{
  {
    type = "item",
    name = "advanced-processing-unit",
    icon = "__bobelectronics__/graphics/icons/electronic-processing-board.png",
    icon_size = 128,
    subgroup = "bob-electronic-boards",
    order = "c-c4[electronic-processing-board]",
    stack_size = 200
  },

  {
    type = "recipe",
    name = "advanced-processing-unit",
    category = "electronics",
    normal =
    {
      energy_required = 15,
      enabled = false,
      ingredients =
      {
        {"multi-layer-circuit-board", 1},
        --{"basic-electronic-components", 1},  --DrD
        {"electronic-components", 2},
        {"intergrated-electronics", 4},
        {"processing-electronics", 1},
      },
      result = "advanced-processing-unit",
      allow_decomposition = false
    },
    expensive =
    {
      energy_required = 24,
      enabled = false,
      ingredients =
      {
        {"multi-layer-circuit-board", 1},
        --{"basic-electronic-components", 3},  --DrD
        {"electronic-components", 3},
        {"intergrated-electronics", 6},
        {"processing-electronics", 3},
      },
      result = "advanced-processing-unit",
      allow_decomposition = false
    },
    allow_decomposition = false
  },
}
)

--from bobelectronics 


if data.raw.item["glass"] then
  bobmods.lib.recipe.add_ingredient("fibreglass-board", {"glass", 2}) --DrD 1
else
  bobmods.lib.recipe.add_ingredient("fibreglass-board", {"plastic-bar", 2}) --DrD 1
end

if data.raw.item["tin-plate"] then
  bobmods.lib.recipe.add_ingredient("circuit-board", {"tin-plate", 2}) --DrD 1
else
  bobmods.lib.recipe.add_ingredient("circuit-board", {"copper-plate", 1}) --DrD 1
end

if not data.raw.item["silicon-wafer"] then
  if data.raw.item["silicon"] or data.raw.item["silicon-plate"] then
    data:extend(
    {
      {
        type = "item",
        name = "silicon-wafer",
        icon = "__bobelectronics__/graphics/icons/silicon-wafer.png",
        icon_size = 32,
        subgroup = "bob-resource",
        order = "f[silicon-wafer]",
        stack_size = 500
      },

      {
        type = "recipe",
        name = "silicon-wafer",
        category = "crafting-machine",
        enabled = false,
        energy_required = 5,
        ingredients =
        {
        },
        result = "silicon-wafer",
        result_count = 4, -- 8 DrD
      },
    }
    )

    if data.raw.item["silicon"] then
      table.insert(data.raw.recipe["silicon-wafer"].ingredients ,{"silicon", 1})
    else
      table.insert(data.raw.recipe["silicon-wafer"].ingredients ,{"silicon-plate", 1})
    end
  end
end

if data.raw.item["tin-plate"] then
  data:extend(
  {
    {
      type = "item",
      name = "solder-alloy",
      icon = "__bobelectronics__/graphics/icons/solder-plate.png",
      icon_size = 32,
      subgroup = "bob-alloy",
      order = "c-b-h[solder]",
      stack_size = 200
    },

    {
      type = "recipe",
      name = "solder-alloy",
      energy_required = 7,
      enabled = false,
      category = "crafting-machine",
      ingredients =
      {
        {"tin-plate", 9},
        {"copper-plate", 1},
      },
      result = "solder-alloy",
      result_count = 5, -- 11 DrD
      allow_decomposition = false
    },
  }
  )
  if data.raw.item["silver-plate"] then
    table.insert(data.raw.recipe["solder-alloy"].ingredients,{"silver-plate", 1})
  end

  if data.raw.item["lead-plate"] then
    data:extend(
    {
      {
        type = "recipe",
        name = "solder-alloy-lead",
        energy_required = 7,
        enabled = false,
        category = "crafting-machine",
        ingredients =
        {
          {"tin-plate", 4},
          {"lead-plate", 7},
        },
        result = "solder-alloy",
        result_count = 5, -- 11 DrD
        allow_decomposition = false
      },
    }
    )
  end
end


