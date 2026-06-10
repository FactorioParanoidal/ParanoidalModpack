-- Порт Oberhaul prototypes/petrochemchange.lua (1.1, в 2.0 не портирован). Значения — дамп 1.1; имена → 2.0 (angels-*).
require("__zzzparanoidal__.paralib")

-- категория ручного крафта
data:extend({ { type = "recipe-category", name = "crafting-handonly" } })
local character = data.raw.character and data.raw.character.character
if character and character.crafting_categories then
  table.insert(character.crafting_categories, "crafting-handonly")
end

-- новые рецепты: карбон через CO2 + альтернативный NO
data:extend({
  {
    type = "recipe",
    name = "angels-coke-purification-3",
    category = "angels-liquifying",
    subgroup = "angels-petrochem-coal",
    energy_required = 2,
    enabled = false,
    localised_name = { "item-name.angels-solid-carbon" },
    ingredients = {
      { type = "item", name = "angels-solid-coke", amount = 2 },
      { type = "fluid", name = "angels-gas-carbon-dioxide", amount = 40 },
    },
    results = { { type = "item", name = "angels-solid-carbon", amount = 3 } },
    order = "d[coke-purification]-c",
  },
  {
    type = "recipe",
    name = "angels-gas-nitrogen-monoxide-2",
    category = "chemistry",
    subgroup = "angels-petrochem-nitrogen",
    energy_required = 2,
    enabled = false,
    localised_name = { "fluid-name.angels-gas-nitrogen-monoxide" },
    ingredients = {
      { type = "fluid", name = "angels-gas-ammonia", amount = 60 },
      { type = "fluid", name = "angels-gas-oxygen", amount = 40 },
    },
    results = { { type = "fluid", name = "angels-gas-nitrogen-monoxide", amount = 10 } },
    order = "c[gas-nitrogen-dioxide]-2",
  },
})

-- анлоки (coke-purification-3 — на angels-coal-processing-3, как в финале 1.1;
-- NO-2 в 1.1 был орфан → вешаем на тех базового NO, чтобы был доступен)
paralib.bobmods.lib.tech.add_recipe_unlock("angels-coal-processing-3", "angels-coke-purification-3")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-nitrogen-processing-2", "angels-gas-nitrogen-monoxide-2")

-- resin: только ручной крафт, 1 дерево
local resin_wood = data.raw.recipe["bob-resin-wood"]
if resin_wood then
  resin_wood.category = "crafting-handonly"
  resin_wood.ingredients = { { type = "item", name = "wood", amount = 1 } }
  resin_wood.energy_required = 4
end

-- rubber: 40 resin
local rubber = data.raw.recipe["bob-rubber"]
if rubber then
  rubber.energy_required = 12
  rubber.ingredients = { { type = "item", name = "resin", amount = 40 } }
end
