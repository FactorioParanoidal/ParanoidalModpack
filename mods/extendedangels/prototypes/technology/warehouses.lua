if not (mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses) then
  return
end

data:extend({
  -- Warehouses 2
  {
    type = "technology",
    name = "angels-warehouses-2",
    icon = "__angelsaddons-storage__/graphics/technology/warehouses.png",
    icon_size = 128,
    prerequisites = {
      "angels-warehouses",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-mk2",
      },
    },
    unit = {
      count = 125,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
      },
      time = 20,
    },
    order = "c-a",
  },

  -- Warehouses 3
  {
    type = "technology",
    name = "angels-warehouses-3",
    icon = "__angelsaddons-storage__/graphics/technology/warehouses.png",
    icon_size = 128,
    prerequisites = {
      "angels-warehouses-2",
      "angels-titanium-smelting-1",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-mk3",
      },
    },
    unit = {
      count = 200,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
      },
      time = 20,
    },
    order = "c-a",
  },

  -- Warehouses 4
  {
    type = "technology",
    name = "angels-warehouses-4",
    icon = "__angelsaddons-storage__/graphics/technology/warehouses.png",
    icon_size = 128,
    prerequisites = {
      "angels-warehouses-3",
      "angels-tungsten-smelting-1",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-mk4",
      },
    },
    unit = {
      count = 200,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
      },
      time = 20,
    },
    order = "c-a",
  },

  -- Logisitic warehouses 2
  {
    type = "technology",
    name = "angels-logistic-warehouses-2",
    icon = "__angelsaddons-storage__/graphics/technology/warehouses-logistics.png",
    icon_size = 128,
    prerequisites = {
      "angels-logistic-warehouses",
      "angels-warehouses-2",
      "production-science-pack"
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-passive-provider-mk2",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-active-provider-mk2",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-storage-mk2",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-requester-mk2",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-buffer-mk2",
      },
    },
    unit = {
      count = 125,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 },
      },
      time = 20,
    },
    order = "c-a",
  },

  -- Logistic warehouses 3
  {
    type = "technology",
    name = "angels-logistic-warehouses-3",
    icon = "__angelsaddons-storage__/graphics/technology/warehouses-logistics.png",
    icon_size = 128,
    prerequisites = {
      "angels-logistic-warehouses-2",
      "angels-warehouses-3",
      "angels-titanium-smelting-1",
      "processing-unit",
      "utility-science-pack",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-passive-provider-mk3",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-active-provider-mk3",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-storage-mk3",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-requester-mk3",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-buffer-mk3",
      },
    },
    unit = {
      count = 200,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 },
      },
      time = 25,
    },
    order = "c-a",
  },

  -- Logistic warehouses 4
  {
    type = "technology",
    name = "angels-logistic-warehouses-4",
    icon = "__angelsaddons-storage__/graphics/technology/warehouses-logistics.png",
    icon_size = 128,
    prerequisites = {
      "angels-logistic-warehouses-3",
      "angels-warehouses-4",
      "angels-tungsten-smelting-1",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-passive-provider-mk4",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-active-provider-mk4",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-storage-mk4",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-requester-mk4",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-warehouse-buffer-mk4",
      },
    },
    unit = {
      count = 300,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 },
      },
      time = 30,
    },
    order = "c-a",
  },
})
