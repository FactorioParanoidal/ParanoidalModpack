local function make_interface(name, icon, localised_name, collision_box, buffer_capacity, input_flow_limit)
  return {
    type = "electric-energy-interface",
    name = name,
    icon = icon,
	icon_size = 32,
    localised_name = {"entity-name." .. localised_name},
    collision_box = collision_box,
    flags = {"not-blueprintable", "not-deconstructable", "not-on-map", "placeable-off-grid"},
    max_health = 40,
    corpse = "medium-remnants",
    collision_mask = {},
    energy_source =
    {
      type = "electric",
      buffer_capacity = buffer_capacity,
      usage_priority = "secondary-input",
      input_flow_limit = input_flow_limit,
      output_flow_limit = "0W"
    },
    energy_production = "0W",
    energy_usage = "0kW",
    picture =
    {
      filename = "__core__/graphics/empty.png",
      priority = "low",
      width = 1,
      height = 1,
    },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-idle.ogg",
        volume = 0.4,
      },
      max_sounds_per_type = 5
    },
  }
end

data:extend
{
  make_interface("lo-power-induction-station-interface",
                 "__wireless-charging_v17__/graphics/icons/lo-power-induction-station.png",
                 "wireless-charging-lo-power-induction-station-interface",
                 {{-1.3, -1.3}, {1.3, 1.3}},
                 (500 / 60) .. "kJ",
                 500 .. "kW"),
  make_interface("hi-power-induction-station-interface",
                 "__wireless-charging_v17__/graphics/icons/hi-power-induction-station.png",
                 "wireless-charging-hi-power-induction-station-interface",
                 {{-1.3, -1.3}, {1.3, 1.3}},
                 (20 / 60) .. "MJ",
                 20 .. "MW"),
  make_interface("lo-power-induction-rail-interface",
                 "__wireless-charging_v17__/graphics/icons/lo-power-induction-rail.png",
                 "wireless-charging-lo-power-induction-rail-interface",
                 {{-0.7, -0.8}, {0.7, 0.8}},
                 (500 / 60) .. "kJ",
                 500 .. "kW"),
  make_interface("hi-power-induction-rail-interface",
                 "__wireless-charging_v17__/graphics/icons/hi-power-induction-rail.png",
                 "wireless-charging-hi-power-induction-rail-interface",
                 {{-0.7, -0.8}, {0.7, 0.8}},
                 (20 / 60) .. "MJ",
                 20 .. "MW"),
}
