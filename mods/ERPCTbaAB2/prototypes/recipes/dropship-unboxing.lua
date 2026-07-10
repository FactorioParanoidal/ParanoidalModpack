data:extend({
  {
    type = "recipe",
    name = "random-dropship-unboxing",
    icon = "__ERPCTbaAB2__/graphics/icons/random-dropship.png",
    icon_size = 32,
    category = mods["angelssmelting"] and "angels-ore-sorting" or "satellite-crafting",
    energy_required = 10,
    enabled = false,
    subgroup = "space-mining",
    ingredients = {
      { type = "item", name = "random-dropship", amount = 1 },
    },
    results = {
      { type = "item", name = "iron-ore", amount_min = 1000, amount_max = 5000, probability = 0.65 },
      { type = "item", name = "copper-ore", amount_min = 2000, amount_max = 4000, probability = 0.35 },
      { type = "item", name = "bob-nickel-ore", amount_min = 3000, amount_max = 5000, probability = 0.22 },
      { type = "item", name = "bob-bauxite-ore", amount_min = 2000, amount_max = 4000, probability = 0.25 },
      { type = "item", name = "bob-cobalt-ore", amount_min = 1000, amount_max = 3000, probability = 0.12 },
      { type = "item", name = "bob-gold-ore", amount_min = 1500, amount_max = 3000, probability = 0.22 },
    },
  },
})

if mods["angelssmelting"] then
  local results = data.raw.recipe["random-dropship-unboxing"].results
  results[#results + 1] = { type = "item", name = "angels-platinum-ore", amount_min = 500, amount_max = 2500, probability = 0.08 }
end

if mods["Clowns-Processing"] then
  local results = data.raw.recipe["random-dropship-unboxing"].results
  results[#results + 1] = { type = "item", name = "clowns-osmium-ore", amount = 5, probability = 0.15 }
  results[#results + 1] = { type = "item", name = "clowns-magnesium-ore", amount = 10, probability = 0.20 }
end
