local EQUIPPATH = "__Aircraft-space-age__/graphics/equipment/"

data:extend({
  { -- Aircraft Energy Shield
    type = "energy-shield-equipment",
    name = "aircraft-energy-shield",
    sprite = {
      filename = EQUIPPATH .. "aircraft_energy_shield.png",
      width = 128,
      height = 128,
      priority = "medium",
      scale = 0.5
    },
    shape = {
      width = 2,
      height = 2,
      type = "full"
    },
    max_shield_value = 250,
    energy_per_shield = "18kJ",
    energy_source = {
      type = "electric",
      buffer_capacity = "480kJ",
      input_flow_limit = "480kW",
      usage_priority = "primary-input"
    },
    categories = {"aircraft"}
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Aircraft Afterburner
    type = "movement-bonus-equipment",
    name = "aircraft-afterburner",
    sprite = {
      filename = EQUIPPATH .. "aircraft_afterburner.png",
      width = 256,
      height = 128,
      priority = "medium",
      scale = 0.5
    },
    shape = {
      width = 4,
      height = 2,
      type = "full"
    },
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_consumption = "350kW",
    movement_bonus = 0.50,
    categories = {"aircraft"}
  },
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
})