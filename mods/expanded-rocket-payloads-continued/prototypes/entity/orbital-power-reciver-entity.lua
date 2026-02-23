--representing a satellite in orbit beaming power back down. Produces power 24/7, is on same priority as solar.

data:extend({
  {
    type = "electric-energy-interface",
    name = "orbital-power-reciver",
    icon = "__expanded-rocket-payloads-continued__/graphic/ground-reciver-32.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "orbital-power-reciver"},
    max_health = 150,
    corpse = "medium-remnants",
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    selection_box = {{-2, -2}, {2, 2}},
    gui_mode = "none",
    allow_copy_paste = false,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "1GJ",
      usage_priority = "primary-output",
      output_flow_limit = "150MW",
      render_no_power_icon = false,
    },

    energy_production = "150MW",
    energy_usage = "0kW",
    picture =
    {
      filename = "__expanded-rocket-payloads-continued__/graphic/ground-reciver.png",
      priority = "extra-high",
      width = 120,
      height = 120,
      shift = { 0.001, 0.01}
    },
    production = "150MW",
    working_sound =
     {
       sound =
       {
         filename = "__base__/sound/accumulator-working.ogg",
         volume = 1
       },
       idle_sound =
       {
         filename = "__base__/sound/accumulator-idle.ogg",
         volume = 0.4
       },
       max_sounds_per_type = 5
    },
  },
})