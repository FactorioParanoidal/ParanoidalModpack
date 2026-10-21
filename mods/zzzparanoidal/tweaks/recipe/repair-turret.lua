-- Защитная башня (defence-tower-reforged, бывшая ремонтная турель Repair Turret): рецепт сборки.
if not mods["defence-tower-reforged"] then return end

local recipe = data.raw.recipe["repair-turret"]
if recipe then
  recipe.ingredients = {
    { type = "item", name = "bob-basic-circuit-board", amount = 25 },
    { type = "item", name = "iron-gear-wheel",         amount = 100 },
    { type = "item", name = "electric-motor",          amount = 15 },
    { type = "item", name = "stone-brick",             amount = 100 },
  }
  recipe.energy_required = 30
end
