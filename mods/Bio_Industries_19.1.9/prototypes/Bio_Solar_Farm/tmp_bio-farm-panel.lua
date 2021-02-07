          ------- Bio Farm Solar Panel
          {
                type = "solar-panel",
                name = "bi-bio-solar-farm",
                icon = ICONPATH .. "Bio_Solar_Farm_Icon.png",
                icon_size = 64,
                icons = {
                  {
                    icon = ICONPATH .. "Bio_Solar_Farm_Icon.png",
                    icon_size = 64,
                  }
                },
                flags = {"placeable-neutral", "player-creation"},
                minable = {hardness = 0.25, mining_time = 0.5, result = "bi-bio-solar-farm"},
                max_health = 600,
                corpse = "big-remnants",
                dying_explosion = "medium-explosion",
                resistances = {{type = "fire", percent = 80}},
                collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
                selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
                energy_source = {
                  type = "electric",
                  usage_priority = "solar"
                },
                picture = {
                  filename = ENTITYPATH .. "Bio_Solar_Farm_On.png",
                  priority = "low",
                  width = 312,
                  height = 289,
                  frame_count = 1,
                  direction_count = 1,
                  --scale = 3/2,
                  shift = {0.30, 0}
                },
                production = "3600kW"
          },
