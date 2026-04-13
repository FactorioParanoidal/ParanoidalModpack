data:extend({
  -- Hydro plant 4
  {
    type = "item",
    name = "angels-hydro-plant-4",
    icons = extangels.numeral_tier({
      icon = "__angelsrefininggraphics__/graphics/icons/hydro-plant.png",
      icon_size = 64,
    }, 4, angelsmods.refining.number_tint),
    subgroup = "angels-water-treatment-building",
    order = "a[hydro-plant]-d[mk4]",
    place_result = "angels-hydro-plant-4",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-hydro-plant"],
    {
      name = "angels-hydro-plant-4",
      minable = { result = "angels-hydro-plant-4" },
      module_slots = 4,
      crafting_speed = 4,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.06 * 60 },
      },
      energy_usage = "300kW",
    },
  }),

  -- Salination plant 3
  {
    type = "item",
    name = "angels-salination-plant-3",
    icons = extangels.numeral_tier({
      icon = "__angelsrefininggraphics__/graphics/icons/salination-plant.png",
      icon_size = 64,
    }, 3, angelsmods.refining.number_tint),
    subgroup = "angels-water-treatment-building",
    order = "f[salination-plant3]",
    place_result = "angels-salination-plant-3",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-salination-plant"],
    {
      name = "angels-salination-plant-3",
      minable = { result = "angels-salination-plant-3" },
      module_slots = 3,
      crafting_speed = 3,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.05 * 60 },
      },
      energy_usage = "300kW",
    },
  }),

  -- Washing plant 3
  {
    type = "item",
    name = "angels-washing-plant-3",
    icons = extangels.numeral_tier({
      icon = "__angelsrefininggraphics__/graphics/icons/washing-plant-ico.png",
      icon_size = 32,
    }, 3, angelsmods.refining.number_tint),
    subgroup = "angels-washing-building",
    order = "b[washing-plant]-c[mk3]",
    place_result = "angels-washing-plant-3",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-washing-plant"],
    {
      name = "angels-washing-plant-3",
      minable = { result = "angels-washing-plant-3" },
      next_upgrade = "angels-washing-plant-4",
      module_slots = 3,
      crafting_speed = 3,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.05 * 60 },
      },
      energy_usage = "200kW",
    },
  }),

  -- Washing plant 4
  {
    type = "item",
    name = "angels-washing-plant-4",
    icons = extangels.numeral_tier({
      icon = "__angelsrefininggraphics__/graphics/icons/washing-plant-ico.png",
      icon_size = 32,
    }, 4, angelsmods.refining.number_tint),
    subgroup = "angels-washing-building",
    order = "b[washing-plant]-d[mk4]",
    place_result = "angels-washing-plant-4",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-washing-plant"],
    {
      name = "angels-washing-plant-4",
      minable = { result = "angels-washing-plant-4" },
      module_slots = 4,
      crafting_speed = 4,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.06 * 60 },
      },
      energy_usage = "250kW",
    },
  }),

  -- Ore crusher 4
  {
    type = "item",
    name = "angels-ore-crusher-4",
    icons = extangels.numeral_tier({
      icon = "__angelsrefininggraphics__/graphics/icons/ore-crusher.png",
      icon_size = 64,
    }, 4, angelsmods.refining.number_tint),
    subgroup = "angels-ore-crusher",
    order = "e[ore-crusher-4]",
    place_result = "angels-ore-crusher-4",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-ore-crusher-3"],
    {
      name = "angels-ore-crusher-4",
      minable = { result = "angels-ore-crusher-4" },
      module_slots = 4,
      crafting_speed = 4,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.06 * 60 },
      },
      energy_usage = "175kW",
    },
  }),

  -- Ore floatation cell 4
  {
    type = "item",
    name = "angels-ore-floatation-cell-4",
    icons = extangels.numeral_tier({
      icon = "__angelsrefininggraphics__/graphics/icons/ore-floatation-cell.png",
      icon_size = 64,
    }, 4, angelsmods.refining.number_tint),
    subgroup = "angels-ore-floatation",
    order = "d[ore-floatation-cell-4]",
    place_result = "angels-ore-floatation-cell-4",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-ore-floatation-cell-3"],
    {
      name = "angels-ore-floatation-cell-4",
      minable = { result = "angels-ore-floatation-cell-4" },
      module_slots = 4,
      crafting_speed = 2,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.05 * 60 },
      },
      energy_usage = "350kW",
    },
  }),

  -- Ore leaching plant 4
  {
    type = "item",
    name = "angels-ore-leaching-plant-4",
    icons = extangels.numeral_tier({
      icon = "__extendedangels__/graphics/icons/ore-leaching-plant-4.png",
      icon_size = 32,
    }, 4, angelsmods.refining.number_tint),
    subgroup = "angels-ore-leaching",
    order = "d[ore-leaching-plant-4]",
    place_result = "angels-ore-leaching-plant-4",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-ore-leaching-plant-3"],
    {
      name = "angels-ore-leaching-plant-4",
      minable = { result = "angels-ore-leaching-plant-4" },
      module_slots = 4,
      crafting_speed = 2,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.07 * 60 },
      },
      energy_usage = "350kW",
    },
  }),

  -- Ore refinery 3
  {
    type = "item",
    name = "angels-ore-refinery-3",
    icons = extangels.numeral_tier({
      icon = "__angelsrefininggraphics__/graphics/icons/ore-refinery.png",
      icon_size = 64,
    }, 3, angelsmods.refining.number_tint),
    subgroup = "angels-ore-refining",
    order = "c[ore-refinery-3]",
    place_result = "angels-ore-refinery-3",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-ore-refinery-2"],
    {
      name = "angels-ore-refinery-3",
      minable = { result = "angels-ore-refinery-3" },
      module_slots = 3,
      crafting_speed = 2,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.04 * 60 },
      },
      energy_usage = "400kW",
    },
  }),
})

-- Item order fixes
data.raw.item["angels-hydro-plant"].order = "a[hydro-plant]-a[mk1]"
data.raw.item["angels-hydro-plant-2"].order = "a[hydro-plant]-b[mk2]"
data.raw.item["angels-hydro-plant-3"].order = "a[hydro-plant]-c[mk3]"
data.raw.item["angels-washing-plant"].order = "b[washing-plant]-a[mk1]"
data.raw.item["angels-washing-plant-2"].order = "b[washing-plant]-b[mk2]"

-- Next upgrade fixes, due to util.merge usage
data.raw["assembling-machine"]["angels-washing-plant-4"].next_upgrade = nil
data.raw["assembling-machine"]["angels-hydro-plant-4"].next_upgrade = nil
data.raw["assembling-machine"]["angels-salination-plant-3"].next_upgrade = nil

-- Entity icon adjustments
data.raw["assembling-machine"]["angels-hydro-plant-4"].icons = extangels.numeral_tier({
  icon = "__angelsrefininggraphics__/graphics/icons/hydro-plant.png",
  icon_size = 64,
}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["angels-salination-plant-3"].icons = extangels.numeral_tier({
  icon = "__angelsrefininggraphics__/graphics/icons/salination-plant.png",
  icon_size = 64,
}, 3, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["angels-washing-plant-3"].icons = extangels.numeral_tier({
  icon = "__angelsrefininggraphics__/graphics/icons/washing-plant-ico.png",
  icon_size = 32,
}, 3, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["angels-washing-plant-4"].icons = extangels.numeral_tier({
  icon = "__angelsrefininggraphics__/graphics/icons/washing-plant-ico.png",
  icon_size = 32,
}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["angels-ore-crusher-4"].icons = extangels.numeral_tier({
  icon = "__angelsrefininggraphics__/graphics/icons/ore-crusher.png",
  icon_size = 64,
}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["angels-ore-floatation-cell-4"].icons = extangels.numeral_tier({
  icon = "__angelsrefininggraphics__/graphics/icons/ore-floatation-cell.png",
  icon_size = 64,
}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["angels-ore-leaching-plant-4"].icons = extangels.numeral_tier({
  icon = "__extendedangels__/graphics/icons/ore-leaching-plant-4.png",
  icon_size = 32,
}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["angels-ore-refinery-3"].icons = extangels.numeral_tier({
  icon = "__angelsrefininggraphics__/graphics/icons/ore-refinery.png",
  icon_size = 64,
}, 3, angelsmods.refining.number_tint)
