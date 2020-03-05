data:extend(
{
  {
    type = "smoke-with-trigger",
    name = "small-poison-cloud",
    flags = {"not-on-map"},
    show_when_smoke_off = true,
    animation =
    {
      filename = "__base__/graphics/entity/cloud/cloud-45-frames.png",
      priority = "low",
      width = 256,
      height = 256,
      frame_count = 45,
      animation_speed = 0.5,
      line_length = 7,
    },
    slow_down_factor = 0,
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 10,
    fade_away_duration = 2 * 60,
    spread_duration = 10,
    color = { r = 0.2, g = 0.9, b = 0.2 },
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "nested-result",
          action =
          {
            type = "area",
            radius = 4,
            entity_flags = {"breaths-air"},
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 4, type = "poison"}
              }
            }
          }
        }
      }
    },
    action_frequency = 5
  },

  {
    type = "smoke-with-trigger",
    name = "small-fire-cloud",
    flags = {"not-on-map"},
    show_when_smoke_off = true,
    animation =
    {
      filename = "__bobenemies__/graphics/entities/fire.png",
      priority = "low",
      width = 30,
      height = 50,
      frame_count = 30,
      animation_speed = 1,
      line_length = 30,
      scale = 3,
    },
    slow_down_factor = 0,
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 10,
    fade_away_duration = 2 * 60,
    spread_duration = 10,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "nested-result",
          action =
          {
            type = "area",
            radius = 4,
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 4, type = "fire"}
              }
            }
          }
        }
      }
    },
    action_frequency = 5
  },
}
)

data:extend(
{
  {
    type = "sticker",
    name = "poison-sticker",
    flags = {"not-on-map"},
    animation =
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-13.png",
      line_length = 8,
      width = 60,
      height = 118,
      frame_count = 25,
      direction_count = 1,
      blend_mode = "additive",
      animation_speed = 1,
      scale = 0.4,
      tint = {r = 0.1, g = 0.5, b = 0.1},
    },
    duration_in_ticks = 30 * 60,
    target_movement_modifier = 0.8,
    damage_per_tick = { amount = 1, type = "poison" },
  }
})
