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
})
