angelsmods.functions.RB.build({
  -- Advanced chemical plant 3
  {
    type = "recipe",
    name = "angels-advanced-chemical-plant-3",
    localised_name = { "entity-name.angels-advanced-chemical-plant-3" },
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-advanced-chemical-plant-2", amount = 1 },
      { type = "item", name = "t5-plate", amount = 2 },
      { type = "item", name = "t5-circuit", amount = 4 },
      { type = "item", name = "t5-brick", amount = 4 },
      { type = "item", name = "t5-pipe", amount = 12 },
    },
    results = { { type = "item", name = "angels-advanced-chemical-plant-3", amount = 1 } },
  },

  -- Air filter 4
  {
    type = "recipe",
    name = "angels-air-filter-4",
    localised_name = { "entity-name.angels-air-filter-4" },
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-air-filter-3", amount = 1 },
      { type = "item", name = "t4-plate", amount = 4 },
      { type = "item", name = "t4-circuit", amount = 5 },
      { type = "item", name = "t4-brick", amount = 5 },
      { type = "item", name = "t4-pipe", amount = 8 },
    },
    results = { { type = "item", name = "angels-air-filter-4", amount = 1 } },
  },
})

data:extend({
  -- Sodium fluoride 1
  {
    type = "recipe",
    name = "angels-solid-sodium-fluoride-1",
    category = "chemistry",
    subgroup = "angels-petrochem-sodium",
    energy_required = 2,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-solid-sodium-hydroxide", amount = 5 },
      { type = "fluid", name = "angels-liquid-hydrofluoric-acid", amount = 50 },
    },
    results = {
      { type = "item", name = "angels-solid-sodium-fluoride", amount = 5 },
      { type = "fluid", name = "angels-water-purified", amount = 50 },
    },
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-hydrofluoric-acid"),
    icon = "__extendedangels__/graphics/icons/solid-sodium-fluoride.png",
    icon_size = 32,
    order = "k",
  },

  -- Sodium fluoride 2
  {
    type = "recipe",
    name = "angels-solid-sodium-fluoride-2",
    category = "chemistry",
    subgroup = "angels-petrochem-sodium",
    energy_required = 2,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-solid-sodium-carbonate", amount = 5 },
      { type = "fluid", name = "angels-liquid-hexafluorosilicic-acid", amount = 25 },
    },
    results = {
      { type = "item", name = "angels-solid-sodium-fluoride", amount = 5 },
      { type = "fluid", name = "angels-water-purified", amount = 25 },
    },
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-hexafluorosilicic-acid"),
    icon = "__extendedangels__/graphics/icons/solid-sodium-fluoride.png",
    icon_size = 32,
    order = "l",
  },

  -- Argon
  {
    type = "recipe",
    name = "angels-gas-argon",
    category = "chemistry",
    subgroup = "angels-petrochem-argon",
    energy_required = 2,
    enabled = false,
    ingredients = {
      { type = "fluid", name = "angels-gas-compressed-air", amount = 100 },
    },
    results = {
      { type = "fluid", name = "angels-gas-argon", amount = 50 },
    },
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("gels-gas-compressed-air"),
    icon = "__extendedangels__/graphics/icons/gas-argon.png",
    icon_size = 32,
    order = "a",
  },
})

if mods["Clowns-Processing"] then
  data:extend({
    -- Disodium phosphate
    {
      type = "recipe",
      name = "angels-solid-disodium-phosphate",
      category = "chemistry",
      subgroup = "angels-petrochem-sodium",
      energy_required = 2,
      enabled = false,
      ingredients = {
        { type = "item", name = "angels-solid-sodium-carbonate", amount = 5 },
        { type = "fluid", name = "clowns-liquid-phosphoric-acid", amount = 50 },
      },
      results = {
        { type = "item", name = "angels-solid-disodium-phosphate", amount = 5 },
      },
      icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
      icon_size = 32,
      order = "m",
    },

    -- Tetrasodium pyrophosphate
    {
      type = "recipe",
      name = "angels-solid-tetrasodium-pyrophosphate",
      category = "smelting",
      subgroup = "angels-petrochem-sodium",
      energy_required = 3.5,
      enabled = false,
      ingredients = {
        { type = "item", name = "angels-solid-disodium-phosphate", amount = 1 },
      },
      results = {
        { type = "item", name = "angels-solid-tetrasodium-pyrophosphate", amount = 1 },
      },
      order = "n",
    },
  })
end
