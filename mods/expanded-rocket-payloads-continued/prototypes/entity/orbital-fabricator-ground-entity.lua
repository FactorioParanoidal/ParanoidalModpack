data:extend({
  {
    type = "assembling-machine",
    name = "ground-auto-fabricator",
    icon = "__expanded-rocket-payloads-continued__/graphic/auto-fabricator-32.png",
    icon_size = 32,
    flags = { "player-creation", "placeable-neutral", "not-rotatable" },
    minable = { hardness = 1.0, mining_time = 3, result = "ground-auto-fabricator" },
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    placeable_by = { item = "ground-auto-fabricator", count = 1 },
    collision_box = { { -3.4, -3.4 }, { 3.4, 3.4 } },
    selection_box = { { -3.4, -3.4 }, { 3.4, 3.4 } },
    drawing_box = { { -3.4, -3.4 }, { 3.4, 3.4 } },
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__expanded-rocket-payloads-continued__/graphic/auto_fabricator-ground-station-220-220.png",
            priority = "extra-high",
            width = 220,
            height = 220,
            shift = { 0.0, -0.1 },
            frame_count = 1,
          },
        },
      },
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound =
      {
        {
          filename = "__base__/sound/assembling-machine-t2-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t2-2.ogg",
          volume = 0.8
        }
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    module_slots = 10,
    crafting_categories = { "auto-fabricator" },
    allowed_effects = { "consumption", "speed", "pollution" },
    ingredient_count = 10,
    crafting_speed = 5,

    order = "d-a-a",
    energy_usage = "500MW",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.08 / 5.5,
      drain = "100MW"
    },
  },
})
