        ------- Hidden Solar Panel for Solar Mat
  {
    type = "solar-panel",
    name = "bi-musk-mat-hidden-panel",
    icon = ICONPATH .. "solar-mat.png",
    icon_size = 64,
    icons = {
        {
            icon = ICONPATH .. "solar-mat.png",
            icon_size = 64,
        }
    },
    flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "not-repairable"},
    selectable_in_game = false,
    max_health = 1,
    resistances = {{type = "fire", percent = 100}},
    collision_mask = {"ground-tile"},
    collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
    selection_box = {{0, 0}, {0, 0}},
    energy_source = {
      type = "electric",
      usage_priority = "solar"
    },
    picture = {
      filename = ICONPATH .. "empty.png",
      priority = "low",
      width = 1,
      height = 1,
    },
    production = "10kW"
  },
