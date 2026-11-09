--Based on code in Varaxia's "Celestial Weather" mod

    local smoke = table.deepcopy(data.raw["trivial-smoke"]["aquilo-snow-smoke"])
    smoke.name = "muluna-overhead-asteroids"
    smoke.color = {0.0, 0.0, 0.0}
    smoke.duration = 255*60 --I would make this higher, but the engine forbids making duration exceed this value
    smoke.spread_duration = 255*60
    smoke.movement_slow_down_factor = 1
    smoke.affected_by_wind = false
    smoke.animation.filename = "__muluna-graphics__/graphics/particle/overhead-asteroid-particle/sand-particles.png"
    smoke.render_layer = "light-effect"
    data.extend{(smoke)}

local Public = {}

  Public.player_effects =
      {
        type = "cluster",
        cluster_count = 2,
        distance = 14,
        distance_deviation = 14,
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            type = "create-trivial-smoke",
            smoke_name = "fsand",
            speed = {0.01, -0.01},
            initial_height = 5,
            speed_multiplier = 1,
            speed_multiplier_deviation = 0.2,
            starting_frame = 8,
            starting_frame_deviation = 8,
            offset_deviation = {{-96*2, -48*2}, {96*2, 48*2}},
            speed_from_center = 0.00,
            speed_from_center_deviation = 0.00
          }
        }
      }



return Public
