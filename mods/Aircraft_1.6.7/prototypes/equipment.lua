data:extend({
  { -- Aircraft Energy Shield
    type = "energy-shield-equipment",
    name = "aircraft-energy-shield",
    max_shield_value = 250,
    energy_per_shield = "18kJ",
    energy_source =
    {
      type = "electric",
      buffer_capacity = "480kJ",
      input_flow_limit = "480kW",
      usage_priority = "primary-input"
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    sprite = 
    {
      filename = "__Aircraft__/graphics/Aircraft_Energy_Shield.png",
      width = 64,
      height = 64,
      priority = "medium"
    },
    categories = {"aircraft"}
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Aircraft Afterburner
    type = "movement-bonus-equipment",
    name = "aircraft-afterburner",
    sprite = 
    {
      filename = "__Aircraft__/graphics/Aircraft_Afterburner.png",
      width = 128,
      height = 64,
      priority = "medium"
    },
    shape =
    {
      width = 4,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_consumption = "350kW",
    movement_bonus = 0.50,
    categories = {"aircraft"}
  },
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
})