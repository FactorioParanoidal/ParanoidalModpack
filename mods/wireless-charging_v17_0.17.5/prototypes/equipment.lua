data:extend
{
  {
    type = "battery-equipment",
    name = "wireless-charging-lo-power-induction-coil",
    sprite =
    {
      filename = "__wireless-charging_v17__/graphics/equipment/lo-power-induction-coil.png",
      width = 64,
      height = 64,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      buffer_capacity = math.ceil(500 / 60) .. "kJ",
      input_flow_limit = "0W",
      output_flow_limit = 500 .. "kW",
      usage_priority = "primary-output"
    },
    categories = {"armor"},
  },
  {
    type = "battery-equipment",
    name = "wireless-charging-hi-power-induction-coil",
    sprite =
    {
      filename = "__wireless-charging_v17__/graphics/equipment/hi-power-induction-coil.png",
      width = 96,
      height = 96,
      priority = "medium"
    },
    shape =
    {
      width = 3,
      height = 3,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      buffer_capacity = math.ceil(20 / 60) .. "MJ",
      input_flow_limit = "0W",
      output_flow_limit = 20 .. "MW",
      usage_priority = "primary-output"
    },
    categories = {"armor"},
  },
}
