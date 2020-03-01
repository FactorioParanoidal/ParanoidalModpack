data.raw["lab"]["lab"].fast_replaceable_group = "lab"

data:extend(
{
  {
    type = "lab",
    name = "lab-2",
    icon = "__bobtech__/graphics/icons/lab2.png",
    icon_size = 32,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "lab-2"},
    max_health = 250,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    light = {intensity = 0.75, size = 8},
    on_animation =
    {
      filename = "__bobtech__/graphics/entity/lab/lab2.png",
      width = 113,
      height = 91,
      frame_count = 33,
      line_length = 11,
      animation_speed = 1 / 3,
      shift = {0.2, 0.15}
    },
    off_animation =
    {
      filename = "__bobtech__/graphics/entity/lab/lab2.png",
      width = 113,
      height = 91,
      frame_count = 1,
      shift = {0.2, 0.15}
    },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/lab.ogg",
        volume = 0.7
      },
      apparent_volume = 1
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "75kW",
    researching_speed = 2,
    inputs =
    {
      "automation-science-pack",
      "logistic-science-pack",
      "chemical-science-pack",
      "military-science-pack",
      "production-science-pack",
      "advanced-logistic-science-pack",
      "utility-science-pack",
      "space-science-pack"
    },
    module_specification =
    {
      module_slots = 4,
      max_entity_info_module_icons_per_row = 4,
      max_entity_info_module_icon_rows = 1,
      module_info_icon_shift = {0, 0.9}
    },
    fast_replaceable_group = "lab",
  },
}
)


