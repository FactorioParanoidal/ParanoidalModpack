function boblaserbubbleanimation(scale, tint)
  return
  {
    {
      filename = "__bobwarfare__/graphics/entities/laser-bubble.png",
      scale = scale,
      tint = tint,
      priority = "extra-high",
      width = 8,
      height = 8,
      frame_count = 5
    }
  }
end


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
      filename = "__bobwarfare__/graphics/entities/fire.png",
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

  {
    type = "smoke-with-trigger",
    name = "poison-artillery-cloud",
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
      scale = 3,
    },
    slow_down_factor = 0,
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 30,
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
            radius = 11,
            entity_flags = {"breaths-air"},
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 10, type = "poison"}
              }
            }
          }
        }
      }
    },
    action_frequency = 5
  },

--[[
  {
    type = "flame-thrower-explosion",
    name = "flame-thrower-acid-mist",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations =
    {
      {
        filename = "__base__/graphics/entity/flame-thrower-explosion/flame-thrower-explosion.png",
        priority = "extra-high",
        width = 64,
        height = 64,
        frame_count = 64,
        line_length = 8
      }
    },
    light = {intensity = 0.2, size = 20},
    slow_down_factor = 0.98,
    damage = {amount = 2, type = "acid"}
  },
]]--

  {
    type = "explosion",
    name = "bob-laser-bubble-glass",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations = boblaserbubbleanimation(1, {r=0.8, g=0.8, b=0.8, a=1}),
    light = {intensity = 1, size = 10},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1
  },

  {
    type = "explosion",
    name = "bob-laser-bubble-ruby",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations = boblaserbubbleanimation(1, {r=1, g=0.2, b=0.2, a=1}),
    light = {intensity = 1, size = 10},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1
  },

  {
    type = "explosion",
    name = "bob-laser-bubble-sapphire",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations = boblaserbubbleanimation(1, {r=0.2, g=0.6, b=1, a=1}),
    light = {intensity = 1, size = 10},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1
  },

  {
    type = "explosion",
    name = "bob-laser-bubble-emerald",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations = boblaserbubbleanimation(1, {r=0.3, g=1, b=0.3, a=1}),
    light = {intensity = 1, size = 10},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1
  },

  {
    type = "explosion",
    name = "bob-laser-bubble-amethyst",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations = boblaserbubbleanimation(1, {r=1, g=0.2, b=1, a=1}),
    light = {intensity = 1, size = 10},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1
  },

  {
    type = "explosion",
    name = "bob-laser-bubble-topaz",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations = boblaserbubbleanimation(1, {r=1, g=0.6, b=0.2, a=1}),
    light = {intensity = 1, size = 10},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1
  },

  {
    type = "explosion",
    name = "bob-laser-bubble-diamond",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations = boblaserbubbleanimation(1, {r=1, g=1, b=1, a=1}),
    light = {intensity = 1, size = 10},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1
  },
}
)


data:extend(
{
  {
    type = "explosion",
    name = "plasma-explosion",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__bobwarfare__/graphics/entities/plasma-explosion.png",
        tint = {r = 0.4, g = 0.7, b = 1, a = 1},
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 64,
        line_length = 8,
        scale = 4,
        axially_symmetrical = false,
        direction_count = 1,
        animation_speed = 0.5
      }
    },
    light = {intensity = 1, size = 50},
    sound =
    {
      aggregation =
      {
        max_count = 1,
        remove = true
      },
      variations =
      {
        {
          filename = "__base__/sound/fight/large-explosion-1.ogg",
          volume = 1.0
        },
        {
          filename = "__base__/sound/fight/large-explosion-2.ogg",
          volume = 1.0
        }
      }
    },
    created_effect =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-particle",
            repeat_count = 20,
            entity_name = "explosion-remnants-particle",
            initial_height = 0.5,
            speed_from_center = 0.08,
            speed_from_center_deviation = 0.15,
            initial_vertical_speed = 0.08,
            initial_vertical_speed_deviation = 0.15,
            offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
          }
        }
      }
    }
  },
  {
    type = "explosion",
    name = "small-plasma-explosion",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__bobwarfare__/graphics/entities/plasma-explosion.png",
        tint = {r = 0.4, g = 0.7, b = 1, a = 1},
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 64,
        line_length = 8,
        scale = 1,
        axially_symmetrical = false,
        direction_count = 1,
        animation_speed = 0.5
      }
    },
    light = {intensity = 1, size = 50},
    sound =
    {
      aggregation =
      {
        max_count = 1,
        remove = true
      },
      variations =
      {
        {
          filename = "__base__/sound/fight/large-explosion-1.ogg",
          volume = 1.0
        },
        {
          filename = "__base__/sound/fight/large-explosion-2.ogg",
          volume = 1.0
        }
      }
    },
    created_effect =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-particle",
            repeat_count = 6,
            entity_name = "explosion-remnants-particle",
            initial_height = 0.5,
            speed_from_center = 0.08,
            speed_from_center_deviation = 0.15,
            initial_vertical_speed = 0.08,
            initial_vertical_speed_deviation = 0.15,
            offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
          }
        }
      }
    }
  }
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

data:extend(
{
  {
    type = "sticker",
    name = "plasma-sticker",
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
      tint = {r = 0.0, g = 0.2, b = 1, a = 0.5},
    },

    duration_in_ticks = 30 * 60,
    target_movement_modifier = 0.8,
    damage_per_tick = { amount = 1, type = "plasma" },
  }
})


