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
})
-------------------------------------------------------------------------------------------------
if mods["JunkTrain3"] then
data:extend({
--добавляем рецепт для модернизации рельс
{
  type = "recipe",
  name = "scrap-rail-to-rail",
  icons = {
    {
      icon = "__JunkTrain3__/graphics/icons/rail.png",
      icon_size = 32,
      --icon_mipmaps = 4
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
  group = "transport",
  subgroup = "transport-rail",
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
  group = "transport",
  subgroup = "transport-rail-other",
  order = "aa",
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
  group = "transport",
  subgroup = "transport-rail-other",
  order = "ba",
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
  group = "transport",
  subgroup = "transport-rail-other",
  order = "ca",
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
end
--###############################################################################################
--добавляем новые группы и сабгруппы для рецептов
if not mods["angelsindustries"] then
data:extend({
{
  type = "item-group",
  name = "circuit",
  order = "ab",
  icon = "__base__/graphics/technology/circuit-network.png",
  icon_size = 256, icon_mipmaps = 4,
},
{type = "item-subgroup", name = "circuit-connection", group = "circuit", order = "b",},
{type = "item-subgroup", name = "circuit-combinator", group = "circuit", order = "c",},
{type = "item-subgroup", name = "circuit-input", group = "circuit", order = "d",},
{type = "item-subgroup", name = "circuit-visual", group = "circuit", order = "e",},
{type = "item-subgroup", name = "circuit-auditory", group = "circuit", order = "f",},
-------------------------------------------------------------------------------------------------
{
  type = "item-group",
  name = "transport",
  order = "ac",
  icon = "__base__/graphics/technology/railway.png",
  icon_size = 256, icon_mipmaps = 4,
},
{type = "item-subgroup", name = "transport-rail", group = "transport", order = "a",},
{type = "item-subgroup", name = "transport-rail-other", group = "transport", order = "b",},
{type = "item-subgroup", name = "junk-train", group = "transport", order = "ddd",},
{type = "item-subgroup", name = "artillery-wagon", group = "transport", order = "eg",},
{type = "item-subgroup", name = "spider", group = "transport", order = "x",},
{type = "item-subgroup", name = "aircraft", group = "transport", order = "y",},
-------------------------------------------------------------------------------------------------
{type = "item-subgroup", name = "FluidMustFlow", group = "bob-logistics", order = "d-a-3",},
{type = "item-subgroup", name = "FlowControl", group = "bob-logistics", order = "d-a-4",},
{type = "item-subgroup", name = "wooden-pole", group = "logistics", order = "d-1",},
{type = "item-subgroup", name = "medium-electric-pole", group = "logistics", order = "d-2",},
{type = "item-subgroup", name = "big-electric-pole", group = "logistics", order = "d-3",},
{type = "item-subgroup", name = "substation", group = "logistics", order = "d-4",},
{type = "item-subgroup", name = "logistic-chests-1", group = "logistics", order = "f-1",},
{type = "item-subgroup", name = "logistic-chests-4", group = "logistics", order = "f-4",},
{type = "item-subgroup", name = "logistic-chests-5", group = "logistics", order = "f-5",},

})
else
data:extend({
{type = "item-subgroup", name = "transport-rail", group = "angels-vehicles", order = "a",},
{type = "item-subgroup", name = "transport-rail-other", group = "angels-vehicles", order = "b",},
})
end
-------------------------------------------------------------------------------------------------
--создаем предмет для hazard-concrete-brick
data:extend({
{
  type = "item",
  name = "hazard-concrete-brick",
  icons = {
    {
      icon = "__angelssmelting__/graphics/icons/brick-concrete.png",
      icon_size = 32,
      --icon_mipmaps = 4
    },
    {
      icon = "__base__/graphics/icons/refined-hazard-concrete.png",
      icon_size = 64,
      icon_mipmaps = 4,
      scale = 0.3,
      shift = {-10, -10}
    }
  },
  icon_size = 32,
  subgroup = "angels-stone-casting",
  order = "ia",
  stack_size = angelsmods.trigger.pavement_stack_size,
  place_as_tile = {result = "hazard-concrete-brick-left", condition_size = 1, condition = {"water-tile"}}
} 
})
-------------------------------------------------------------------------------------------------
--создаем hazard-tile-left для hazard-concrete-brick
local hazard_tile_left = table.deepcopy(data.raw["tile"]["refined-hazard-concrete-left"])
hazard_tile_left.name = "hazard-concrete-brick-left"
hazard_tile_left.minable = {mining_time = 0.1, result = "hazard-concrete-brick"}
hazard_tile_left.layer = "225"
hazard_tile_left.next_direction = "hazard-concrete-brick-right"
hazard_tile_left.variants.material_background = 
  {
    picture = "__zzzparanoidal__/graphics/grid/hazard-concrete-left.png", count = 8,
    hr_version = {picture = "__zzzparanoidal__/graphics/grid/hr-hazard-concrete-left.png", count = 8, scale = 0.5}
  }
data:extend{hazard_tile_left}
-------------------------------------------------------------------------------------------------
--создаем hazard-tile-right для hazard-concrete-brick
local hazard_tile_right = table.deepcopy(data.raw["tile"]["refined-hazard-concrete-right"])
hazard_tile_right.name = "hazard-concrete-brick-right"
hazard_tile_right.minable = {mining_time = 0.1, result = "hazard-concrete-brick"}
hazard_tile_right.layer = "225"
hazard_tile_right.next_direction = "hazard-concrete-brick-left"
hazard_tile_right.variants.material_background = 
  {
    picture = "__zzzparanoidal__/graphics/grid/hazard-concrete-right.png", count = 8,
    hr_version = {picture = "__zzzparanoidal__/graphics/grid/hr-hazard-concrete-right.png", count = 8, scale = 0.5}
  }
data:extend{hazard_tile_right}
-------------------------------------------------------------------------------------------------
--добавляем рецепт для бетонного кирпича с полосами
data:extend({
{
  type = "recipe",
  name = "hazard-concrete-brick",
  category = "crafting",
  group = "angels-casting",
  subgroup = "angels-stone-casting",
  order = "ia",
  energy_required = 1,
  enabled = false,
  allow_decomposition = false,
  always_show_products = true,
  ingredients = {{type = "item", name = "concrete-brick", amount = 10},},
  results = {{type = "item", name = "hazard-concrete-brick", amount = 10}},
},
})