data:extend({
  -- Advanced Chemical Plant
  {
    type = "item",
    name = "angels-advanced-chemical-plant-3",
    icons = extangels.numeral_tier({
      icon = "__angelspetrochemgraphics__/graphics/icons/advanced-chemical-plant.png",
      icon_size = 32,
    }, 3, angelsmods.petrochem.number_tint),
    subgroup = "angels-petrochem-buildings-chemical-plant",
    order = "b[advanced]-c",
    place_result = "angels-advanced-chemical-plant-3",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-advanced-chemical-plant"],
    {
      name = "angels-advanced-chemical-plant-3",
      minable = { result = "angels-advanced-chemical-plant-3" },
      module_slots = 4,
      crafting_speed = 3.5,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = 0.01 * 60 },
      },
      energy_usage = "500kW",
    },
  }),

  -- Air filter 4
  {
    type = "item",
    name = "angels-air-filter-4",
    icons = extangels.numeral_tier({
      icon = "__angelspetrochemgraphics__/graphics/icons/air-filter.png",
      icon_size = 32,
    }, 4, angelsmods.petrochem.number_tint),
    subgroup = "angels-petrochem-buildings-electrolyser",
    order = "b[angels-air-filter]-d",
    place_result = "angels-air-filter-4",
    stack_size = 10,
  },

  util.merge({
    data.raw["assembling-machine"]["angels-air-filter"],
    {
      name = "angels-air-filter-4",
      minable = { result = "angels-air-filter-4" },
      module_slots = 4,
      crafting_speed = 4,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = { pollution = -0.16 * 60 },
      },
      energy_usage = "300kW",
    },
  }),
})

-- Next upgrade fixes, due to util.merge usage
data.raw["assembling-machine"]["angels-advanced-chemical-plant-3"].next_upgrade = nil
data.raw["assembling-machine"]["angels-air-filter-4"].next_upgrade = nil

-- Entity icon adjustments
data.raw["assembling-machine"]["angels-advanced-chemical-plant-3"].icons = extangels.numeral_tier({
  icon = "__angelspetrochemgraphics__/graphics/icons/advanced-chemical-plant.png",
  icon_size = 32,
}, 3, angelsmods.petrochem.number_tint)
data.raw["assembling-machine"]["angels-air-filter-4"].icons = extangels.numeral_tier({
  icon = "__angelspetrochemgraphics__/graphics/icons/air-filter.png",
  icon_size = 32,
}, 4, angelsmods.petrochem.number_tint)
