local waypoint = table.deepcopy(data.raw["train-stop"]["train-stop"])
waypoint.name = "waypoint"
waypoint.icon = GRAPHICSPATH .. "icon/waypoint.png"
waypoint.icon_size = 64
waypoint.minable = { mining_time = 1, result = "waypoint" }
waypoint.rail_overlay_animations = nil
waypoint.collision_mask = { layers = { object = true } }
waypoint.collision_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }
waypoint.selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }

waypoint.animations = {
  north = {
    layers = {
      {
        filename = GRAPHICSPATH .. "entity/waypoint/main.png",
        width = 128,
        height = 128,
        scale = 1,
        shift = { 0, -1 },
      },
      {
        filename = GRAPHICSPATH .. "entity/waypoint/shadow.png",
        width = 256,
        height = 128,
        scale = 1,
        draw_as_shadow = true,
        shift = { 0, -1 },
      },
    }
  },
}

waypoint.top_animations = nil
waypoint.working_sound = nil
waypoint.factoriopedia_simulation = nil
waypoint.light1 = nil
waypoint.light2 = nil
waypoint.circuit_wire_max_distance = 0

data:extend({ waypoint })
