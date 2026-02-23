data:extend({
  {
    type = "assembling-machine",
    name = "ground-telescope",
    icon = "__expanded-rocket-payloads-continued__/graphic/ground-telescope-32.png",
    icon_size = 32,
    flags = { "player-creation", "placeable-neutral" },
    minable = { hardness = 1.0, mining_time = 5, result = "ground-telescope" },
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    placeable_by = { item = "ground-telescope", count = 1 },
    collision_box = { { -5.8, -5.8 }, { 5.8, 5.8 } },
    selection_box = { { -5.8, -5.8 }, { 5.8, 5.8 } },
    drawing_box = { { -5.8, -5.8 }, { 5.8, 5.8 } },
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__expanded-rocket-payloads-continued__/graphic/ground-telescope-400-400.png",
            priority = "extra-high",
            width = 400,
            height = 400,
            shift = { 0.25, 0.015625 },
            frame_count = 1,
          },
        },
      },
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    module_slots = 0,
    crafting_categories = { "ground-telescope" },
    fixed_recipe = "study-the-stars",
    ingredient_count = 1,
    crafting_speed = 1,

    order = "d-a-a",
    energy_usage = "1MW",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
    },
  },
})
