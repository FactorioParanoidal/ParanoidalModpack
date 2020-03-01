local assemblerlight = table.deepcopy(data.raw.lamp["small-lamp"])

assemblerlight.name = "assembler-lamp"
--assemblerlight.light = {intensity = 0.5, size = 5, color = {r=0.03, g=0.573, b=0.816}}
assemblerlight.light = {intensity = settings.startup["assemblerlight-intensity"].value, size = settings.startup["assemblerlight-size"].value, color = {r=settings.startup["assemblerlight-red"].value, g=settings.startup["assemblerlight-green"].value, b=settings.startup["assemblerlight-blue"].value}}

assemblerlight.energy_source = {type = "electric",  usage_priority = "lamp", render_no_power_icon = false, render_no_network_icon = false }
assemblerlight.energy_usage_per_tick = "0.001KW"
assemblerlight.darkness_for_all_lamps_off = settings.startup["assemblerlight-default-on"].value
assemblerlight.darkness_for_all_lamps_on = settings.startup["assemblerlight-default-off"].value
assemblerlight.vehicle_impact_sound = nil
assemblerlight.flags = {"not-blueprintable", "not-deconstructable", "not-on-map", "placeable-off-grid"}
assemblerlight.selectable_in_game = false
assemblerlight.mined_sound = nil
assemblerlight.minable = nil 
assemblerlight.collision_box = {{-1.5,-1.5}, {1.5,1.5}}
assemblerlight.selection_box = {{0,0},{0,0}}
assemblerlight.collision_mask = {}
assemblerlight.circuit_wire_max_distance = 0
assemblerlight.circuit_connector_sprites = nil
assemblerlight.circuit_wire_connection_point = nil

assemblerlight.picture_off =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/small-lamp/lamp.png",
          priority = "low",
          width = 1,
          height = 1,
          frame_count = 1,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(0,3),
          hr_version =
          {
            filename = "__base__/graphics/entity/small-lamp/hr-lamp.png",
            priority = "low",
            width = 1,
            height = 1,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(0.25,3),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/small-lamp/lamp-shadow.png",
          priority = "low",
          width = 1,
          height = 1,
          frame_count = 1,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(4,5),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/small-lamp/hr-lamp-shadow.png",
            priority = "low",
            width = 1,
            height = 1,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(4, 4.75),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
    }
assemblerlight.picture_on =
    {
      filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
      priority = "low",
      width = 1,
      height = 1,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = util.by_pixel(0, -7),
      hr_version =
      {
        filename = "__base__/graphics/entity/small-lamp/hr-lamp-light.png",
        priority = "low",
        width = 1,
        height = 1,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        shift = util.by_pixel(0, -7),
        scale = 0.5
      }
    }



data:extend{assemblerlight}