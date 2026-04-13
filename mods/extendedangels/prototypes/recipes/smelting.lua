local OV = angelsmods.functions.OV

data:extend({
  -- Tungsten trioxide
  {
    type = "recipe",
    name = "angels-solid-tungsten-trioxide-smelting",
    category = "angels-chemical-smelting",
    subgroup = "angels-tungsten",
    energy_required = 4,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-pellet-tungsten", amount = 4 },
      { type = "fluid", name = "angels-gas-oxygen", amount = 60 },
    },
    results = {
      { type = "item", name = "angels-solid-tungsten-trioxide", amount = 12 },
    },
    order = "i",
  },

  -- Sodium tungstate
  {
    type = "recipe",
    name = "angels-pellet-tungsten-smelting-2",
    category = "angels-chemical-smelting",
    subgroup = "angels-tungsten",
    energy_required = 8,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-solid-salt", amount = 50 },
      { type = "item", name = "angels-solid-tungsten-trioxide", amount = 12 },
      { type = "item", name = "angels-solid-sodium-fluoride", amount = 6 },
    },
    results = {
      { type = "item", name = "angels-solid-sodium-tungstate", amount = 12 },
    },
    order = "j",
  },

  -- Tungsten powder
  {
    type = "recipe",
    name = "angels-solid-sodium-tungstate-smelting",
    category = "angels-blast-smelting",
    subgroup = "angels-tungsten",
    energy_required = 4,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-solid-sodium-tungstate", amount = 16 },
      { type = "item", name = "angels-pellet-manganese", amount = 4 },
    },
    results = {
      { type = "item", name = "angels-powder-tungsten", amount = 30 },
    },
    icons = extangels.numeral_tier({
      icon = data.raw.item["angels-powder-tungsten"].icon,
      icon_size = data.raw.item["angels-powder-tungsten"].icon_size,
    }, 2, angelsmods.smelting.number_tint),
    order = "h[powder-tungsten]-c",
  },

  -- Tungsten powder mixture
  {
    type = "recipe",
    name = "angels-casting-powder-tungsten-3",
    category = "angels-powder-mixing",
    subgroup = "angels-tungsten-casting",
    energy_required = 4,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-powder-tungsten", amount = 12 },
      { type = "item", name = "angels-powder-zinc", amount = 12 },
    },
    results = {
      { type = "item", name = "angels-casting-powder-tungsten", amount = 24 },
    },
    icons = extangels.numeral_tier({
      icon = data.raw.item["angels-casting-powder-tungsten"].icon,
      icon_size = data.raw.item["angels-casting-powder-tungsten"].icon_size,
    }, 3, angelsmods.smelting.number_tint),
    order = "i[casting-powder-tungsten]-c",
  },

  -- Tungsten hexachloride
  {
    type = "recipe",
    name = "angels-solid-tungsten-oxide-smelting-2",
    category = "angels-liquifying",
    subgroup = "angels-tungsten-carbide",
    energy_required = 6,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-solid-tungsten-trioxide", amount = 12 },
      { type = "fluid", name = "angels-gas-hydrogen-chloride", amount = 30 },
    },
    results = {
      { type = "fluid", name = "angels-gas-tungsten-hexachloride", amount = 60 },
    },
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-gas-hydrogen-chloride"),
  },

  -- Titanium concrete brick
  {
    type = "recipe",
    name = "angels-titanium-concrete-brick",
    category = "crafting-with-fluid",
    subgroup = "angels-stone-casting",
    energy_required = 4,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "stone-brick", amount = 4 },
      { type = "item", name = "angels-plate-titanium", amount = 4 },
      { type = "fluid", name = "angels-liquid-concrete", amount = 40 },
    },
    results = {
      { type = "item", name = "angels-titanium-concrete-brick", amount = 4 },
    },
    order = "k[titanium-concrete-brick]",
  },
   
})

  if mods["bobplates"] then
data:extend({
  -- Tungsten carbide powder mixture 1
  {
    type = "recipe",
    name = "angels-tungsten-carbide-smelting-1",
    category = "angels-chemical-smelting-3",
    subgroup = "angels-alloys-casting",
    energy_required = 8,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-solid-tungsten-oxide", amount = 12 },
      { type = "fluid", name = "angels-gas-hydrogen", amount = 60 },
      { type = "fluid", name = "angels-gas-argon", amount = 30 },
    },
    results = {
      { type = "item", name = "angels-powder-tungsten-carbide", amount = 12 },
    },
    icons = extangels.numeral_tier({
      icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide.png",
      icon_size = 64,
    }, 1, angelsmods.smelting.number_tint),
    order = "aa",
  },

  -- Tungsten carbide powder mixture 2
  {
    type = "recipe",
    name = "angels-tungsten-carbide-smelting-2",
    category = "angels-chemical-smelting-4",
    subgroup = "angels-alloys-casting",
    energy_required = 16,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "fluid", name = "angels-gas-tungsten-hexafluoride", amount = 80 },
      { type = "fluid", name = "angels-gas-hydrogen", amount = 60 },
      { type = "item", name = "angels-solid-carbon", amount = 5 },
    },
    results = {
      { type = "item", name = "angels-powder-tungsten-carbide", amount = 24 },
      { type = "fluid", name = "angels-liquid-hydrofluoric-acid", amount = 60 },
      { type = "fluid", name = "angels-water-purified", amount = 20 },
    },
    icons = extangels.numeral_tier({
      icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide.png",
      icon_size = 64,
    }, 2, angelsmods.smelting.number_tint),
    order = "ab",
  },

  -- Tungsten carbide powder mixture 3
  {
    type = "recipe",
    name = "angels-tungsten-carbide-smelting-3",
    category = "angels-chemical-smelting-4",
    subgroup = "angels-alloys-casting",
    energy_required = 8,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "fluid", name = "angels-gas-tungsten-hexachloride", amount = 60 },
      { type = "fluid", name = "angels-gas-hydrogen", amount = 50 },
      { type = "item", name = "angels-solid-carbon", amount = 5 },
    },
    results = {
      { type = "item", name = "angels-powder-tungsten-carbide", amount = 12 },
      { type = "fluid", name = "angels-gas-hydrogen-chloride", amount = 30 },
    },
    icons = extangels.numeral_tier({
      icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide.png",
      icon_size = 64,
    }, 3, angelsmods.smelting.number_tint),
    order = "ac",
  },

  -- Tungsten carbide
  {
    type = "recipe",
    name = "angels-plate-tungsten-carbide",
    category = "angels-sintering",
    subgroup = "angels-alloys-casting",
    enabled = false,
    auto_recycle = false,
    energy_required = 4,
    ingredients = {
      { type = "item", name = "angels-powder-tungsten-carbide", amount = 12 },
    },
    results = {
      { type = "item", name = "bob-tungsten-carbide", amount = 12 },
    },
    order = "ad",
  },
  -- Molten copper tungsten 1
  {
    type = "recipe",
    name = "angels-copper-tungsten-smelting-1",
    category = "angels-chemical-smelting-3",
    subgroup = "angels-alloys-casting",
    energy_required = 8,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-powder-copper", amount = 16 },
      { type = "item", name = "angels-powder-tungsten", amount = 12 },
      { type = "fluid", name = "angels-gas-hydrogen", amount = 60 },
    },
    results = {
      { type = "item", name = "angels-powder-copper-tungsten", amount = 12 },
    },
    icons = extangels.numeral_tier({
      icon = "__extendedangels__/graphics/icons/powder-copper-tungsten.png",
      icon_size = 64,
    }, 1, angelsmods.smelting.number_tint),
    order = "g[copper-tungsten]-a[powder-copper-tungsten]",
  },

  -- Molten copper tungsten 2
  {
    type = "recipe",
    name = "angels-copper-tungsten-smelting-2",
    category = "angels-chemical-smelting-4",
    subgroup = "angels-alloys-casting",
    energy_required = 8,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-powder-copper", amount = 8 },
      { type = "item", name = "angels-powder-silver", amount = 8 },
      { type = "item", name = "angels-powder-tungsten", amount = 12 },
      { type = "fluid", name = "angels-gas-hydrogen", amount = 60 },
    },
    results = {
      { type = "item", name = "angels-powder-copper-tungsten", amount = 12 },
    },
    icons = extangels.numeral_tier({
      icon = "__extendedangels__/graphics/icons/powder-copper-tungsten.png",
      icon_size = 64,
    }, 2, angelsmods.smelting.number_tint),
    order = "g[copper-tungsten]-a[powder-copper-tungsten]",
  },

  -- Copper tungsten
  {
    type = "recipe",
    name = "angels-molten-copper-tungsten-smelting-1",
    category = "angels-sintering",
    subgroup = "angels-alloys-casting",
    energy_required = 8,
    enabled = false,
    auto_recycle = false,
    ingredients = {
      { type = "item", name = "angels-powder-copper-tungsten", amount = 4 },
    },
    results = {
      { type = "item", name = "bob-copper-tungsten-alloy", amount = 4 },
    },
    order = "g[copper-tungsten]-b[copper-tungsten-alloy]",
  },
})
end

if mods["Clowns-Processing"] then
OV.patch_recipes({
    {
      name = "angels-pellet-tungsten-smelting-2",
      ingredients = {
        { type = "item", name = "angels-solid-tetrasodium-pyrophosphate", amount = 1 }
      },
    },
  })
end
