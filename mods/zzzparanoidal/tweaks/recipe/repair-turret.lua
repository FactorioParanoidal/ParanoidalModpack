-- Repair Turret (Klonan): переопределение рецепта.
if not mods["Repair_Turret"] then return end

local recipe = data.raw.recipe["repair-turret"]
if recipe then
  recipe.ingredients = {
    { type = "item", name = "basic-structure-components", amount = 1 },
    { type = "item", name = "engine-unit",        amount = 4 },
    { type = "item", name = "steel-plate",        amount = 20 },
    { type = "item", name = "electronic-circuit", amount = 20 },
    { type = "item", name = "iron-gear-wheel",    amount = 20 },
    { type = "item", name = "repair-pack",        amount = 5 },
  }
  recipe.energy_required = 30
end
