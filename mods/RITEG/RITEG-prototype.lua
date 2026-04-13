local mod_name = "__RITEG__"
local RTG = "RITEG-1"
local used_up_RTG = "used-up-RITEG-1"


local tint = { r = 0.7, g = 1, b = 0.7, a = 1 }
local size = 3
local shift = { x = 32 / 32, y = -10 / 32 }



data:extend({
  -- items --
  {
    -- flags = {"goes-to-quickbar"}, -- not for 0.17
    icons = { { icon = mod_name .. "/graphics/icons/" .. RTG .. ".png", icon_size = 32 } },
    name = RTG,
    order = "e[electric-energy-interface]-b[electric-energy-interface]",
    place_result = RTG,
    stack_size = 50,
    subgroup = "energy",
    type = "item"
  },
  {
    -- flags = {"goes-to-quickbar"},
    icons = { { icon = mod_name .. "/graphics/icons/" .. used_up_RTG .. ".png", icon_size = 32 } },
    name = used_up_RTG,
    order = "e[electric-energy-interface]-b[electric-energy-interface]",
    -- place_result = RTG,
    stack_size = 50,
    subgroup = "energy",
    type = "item"
  },

  -- entities --
  {
    allow_copy_paste = false,

    corpse = "medium-remnants",
    enable_gui = false,
    energy_production = "6000kW",
    energy_source = {
      buffer_capacity = "25kJ", -- 10 kJ per tick is (600 kJ/sec) or just 600 kW
      input_flow_limit = "0kW",
      output_flow_limit = "1500kW",
      type = "electric",
      render_no_power_icon = false,
      usage_priority = "primary-output"
    },
    energy_usage = "0kW",
    flags = {
      "placeable-neutral",
      "player-creation",
      "not-repairable" -- added 0.1.2
    },
    icon = mod_name .. "/graphics/icons/" .. RTG .. ".png",
    icon_size = 32,
    max_health = 600,
    minable = {
      hardness = 0.2,
      mining_time = 5,
      results = { { type = "item", name = used_up_RTG, amount = 1 }, { type = "item", name = "depleted-uranium-fuel-cell", amount = 5 } }
    },
    name = RTG,
    picture = { -- thanks to Sigma1, https://forums.factorio.com/viewtopic.php?f=190&t=56513&p=361828#p361785
      filename = mod_name .. "/graphics/entities/" .. "hr-" .. RTG .. ".png",
      width = 333,
      height = 307,
      priority = "extra-high",
      shift = shift,
      scale = 0.5
    },
    collision_box = { { -size / 2 + 0.23, -size / 2 + 0.23 }, { size / 2 - 0.23, size / 2 - 0.23 } },
    selection_box = { { -size / 2, -size / 2 }, { size / 2, size / 2 } },
    type = "electric-energy-interface",
    vehicle_impact_sound = {
      filename = "__base__/sound/car-metal-impact.ogg",
      volume = 0.65
    }
  },

  -- recipes --
  {
    enabled = false,
    energy_required = 5,
    icons = { { icon = mod_name .. "/graphics/icons/" .. RTG .. ".png", icon_size = 32 } },
    ingredients = {
      { type = "item", name = "iron-plate",         amount = 20 },
      { type = "item", name = "electronic-circuit", amount = 10 },
      { type = "item", name = "uranium-fuel-cell",  amount = 5 }, -- 5x 8 GJ!
    },
    type = "recipe",
    name = RTG,
    results = { { type = "item", name = RTG, amount = 1 } }
  },
  {
    enabled = false,
    energy_required = 30,
    icons = { { icon = mod_name .. "/graphics/icons/" .. RTG .. ".png", icon_size = 32 },
      { icon = mod_name .. "/graphics/icons/recycling.png",     scale = 0.5,   shift = { -8, 8 }, icon_size = 32 } },
    ingredients = {
      { type = "item", name = used_up_RTG,         amount = 1 },
      { type = "item", name = "uranium-fuel-cell", amount = 5 }, -- 5x 8 GJ!
    },
    type = "recipe",
    name = RTG .. "-from-" .. used_up_RTG,
    localised_name = { "recipe-name.RITEG-recycling-recipe", { "entity-name." .. RTG } },
    results = { { type = "item", name = RTG, amount = 1 } }
  }
})

local tech_effects = data.raw["technology"]["nuclear-power"].effects
table.insert(tech_effects, { recipe = RTG, type = "unlock-recipe" })
table.insert(tech_effects, { recipe = RTG .. "-from-" .. used_up_RTG, type = "unlock-recipe" })
