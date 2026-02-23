if not (mods["angelsindustries"] and angelsmods.industries.components) then
  return
end

data:extend({
  {
    type = "recipe",
    name = "block-construction-0",
    enabled = true,
    category = "crafting",
    energy_required = 5,
    ingredients = {
      { type = "item", name = "construction-frame-1", amount = 1 },
      { type = "item", name = "stone", amount = 3 },
    },
    results = {
      { type = "item", name = "block-construction-0", amount = 1 },
    },
  },
})
