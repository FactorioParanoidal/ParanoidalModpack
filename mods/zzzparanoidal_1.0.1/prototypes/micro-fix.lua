data:extend({
-------------------------------------------------------------------------------------------------
-- создаем технологию для переработки шариков
{
    type = "technology",
    name = "alien-artifact",
    icon = "__reskins-bobs__/graphics/icons/enemies/artifacts/alien-artifact.png",
    icon_size = 64, icon_mipmaps = 4,
    effects =
    {
        {type = "unlock-recipe", recipe = "alien-artifact-red-from-basic"},
        {type = "unlock-recipe", recipe = "alien-artifact-orange-from-basic"},
        {type = "unlock-recipe", recipe = "alien-artifact-yellow-from-basic"},
        {type = "unlock-recipe", recipe = "alien-artifact-green-from-basic"},
        {type = "unlock-recipe", recipe = "alien-artifact-blue-from-basic"},
        {type = "unlock-recipe", recipe = "alien-artifact-purple-from-basic"},

        {type = "unlock-recipe", recipe = "alien-artifact-from-small"},
        {type = "unlock-recipe", recipe = "alien-artifact-red-from-small"},
        {type = "unlock-recipe", recipe = "alien-artifact-orange-from-small"},
        {type = "unlock-recipe", recipe = "alien-artifact-yellow-from-small"},
        {type = "unlock-recipe", recipe = "alien-artifact-green-from-small"},
        {type = "unlock-recipe", recipe = "alien-artifact-blue-from-small"},
        {type = "unlock-recipe", recipe = "alien-artifact-purple-from-small"},
    },
    prerequisites = { "gardens" },
    unit =
    {
        count = 20,
        ingredients = {{ "automation-science-pack", 1 }},
        time = 30
    },
    order = "c-a" 
    },
-------------------------------------------------------------------------------------------------
--создаем рецепт для стекла из дробленого кронтиниума
{
    type = "recipe",
    name = "glass-from-ore4",
    category = "smelting",
    group = "angels-casting",
    subgroup = "angels-glass-casting",
    order = "az",
    always_show_products = true,
    --enabled = false --доступно изначально
    icons = {
        {
          icon = "__reskins-library__/graphics/icons/shared/items/glass.png",
          icon_size = 64,
          icon_mipmaps = 4
        },
        {
          icon = "__angelsrefining__/graphics/icons/angels-ore4-crushed.png",
          icon_size = 32,
          icon_mipmaps = 1,
          scale = 0.4375,
          shift = {-10, -10}
        }
      },
    energy_required = 20,
    ingredients = {{type = "item", name = "angels-ore4-crushed", amount = 7}},
    results = 
    {
        {type = "item", name = "glass", amount = 4},
        {name = "slag", type = "item", amount = 1}
    },
},
-------------------------------------------------------------------------------------------------
--добавляем рецепт для модернизации рельс
{
  type = "recipe",
  name = "scrap-rail-to-rail",
  icons = {
    {
      icon = "__base__/graphics/icons/rail.png",
      icon_size = 64,
      icon_mipmaps = 4
    },
    {
      icon = "__zzzparanoidal__/graphics/upgrade-icon.png",
      icon_size = 16,
      icon_mipmaps = 1,
      scale = 0.9,
      shift = {-10, -10}
    }
  },
  category = "crafting",
  group = "logistics",
  subgroup = "transport",
  order = "aa",
  energy_required = 0.5,
  enabled = false,
  allow_decomposition = false,
  always_show_products = true,
  ingredients = 
    {
      {type = "item", name = "scrap-rail", amount = 2},
      {type = "item", name = "concrete", amount = 6}
    },
  results = {{type = "item", name = "rail", amount = 2}},
},
-------------------------------------------------------------------------------------------------
--добавляем рецепт для модернизации светофора
{
  type = "recipe",
  name = "rail-signal-scrap-to-rail-signal",
  icons = {
    {
      icon = "__base__/graphics/icons/rail-signal.png",
      icon_size = 64,
      icon_mipmaps = 4
    },
    {
      icon = "__zzzparanoidal__/graphics/upgrade-icon.png",
      icon_size = 16,
      icon_mipmaps = 1,
      scale = 0.9,
      shift = {-10, -10}
    }
  },
  category = "crafting",
  group = "logistics",
  subgroup = "transport",
  order = "ab",
  energy_required = 0.5,
  enabled = false,
  allow_decomposition = false,
  always_show_products = true,
  ingredients = 
    {
      {type = "item", name = "rail-signal-scrap", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 1}
    },
  results = {{type = "item", name = "rail-signal", amount = 1}},
},
-------------------------------------------------------------------------------------------------
--добавляем рецепт для модернизации проходного светофора
{
  type = "recipe",
  name = "rail-chain-signal-scrap-to-rail-chain-signal",
  icons = {
    {
      icon = "__base__/graphics/icons/rail-chain-signal.png",
      icon_size = 64,
      icon_mipmaps = 4
    },
    {
      icon = "__zzzparanoidal__/graphics/upgrade-icon.png",
      icon_size = 16,
      icon_mipmaps = 1,
      scale = 0.9,
      shift = {-10, -10}
    }
  },
  category = "crafting",
  group = "logistics",
  subgroup = "transport",
  order = "ac",
  energy_required = 0.5,
  enabled = false,
  allow_decomposition = false,
  always_show_products = true,
  ingredients = 
    {
      {type = "item", name = "rail-chain-signal-scrap", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 1}
    },
  results = {{type = "item", name = "rail-chain-signal", amount = 1}},
},
-------------------------------------------------------------------------------------------------
--добавляем рецепт для модернизации станции
{
  type = "recipe",
  name = "train-stop-scrap-to-train-stop",
  icons = {
    {
      icon = "__base__/graphics/icons/train-stop.png",
      icon_size = 64,
      icon_mipmaps = 4
    },
    {
      icon = "__zzzparanoidal__/graphics/upgrade-icon.png",
      icon_size = 16,
      icon_mipmaps = 1,
      scale = 0.9,
      shift = {-10, -10}
    }
  },
  category = "crafting",
  group = "logistics",
  subgroup = "transport",
  order = "ad",
  energy_required = 0.5,
  enabled = false,
  allow_decomposition = false,
  always_show_products = true,
  ingredients = 
    {
      {type = "item", name = "train-stop-scrap", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 5},
      {type = "item", name = "steel-plate", amount = 10}
    },
  results = {{type = "item", name = "train-stop", amount = 1}},
},

})
