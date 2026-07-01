data:extend(
{
  {
    type = "explosion",
    name = "explosion-flare",
    flags = {"not-on-map"},
    animations =
    {
      filename = "__Clockwork-2__/graphics/flare-lighting.png",
      priority = "high",
      width = 64,
      height = 64,
      frame_count = 16,
      animation_speed = 32/60,
    },
    light = {intensity = 0.5, size = 80, color = { r = 1.000, g = 0.888, b = 0.419}},
	light_intensity_factor_final = 1.0,
	light_intensity_factor_initial = 1.0,
	light_size_factor_initial = 1.0,
	light_size_factor_final = 1.0,
  },

  {
    type = "smoke-with-trigger",
    name = "flare-cloud",
    flags = {"not-on-map"},
    affected_by_wind = false,
    cyclic = true,
    duration = math.min(60 * 60 * settings.startup["Clockwork-mod-accumulators-capacity"].value, 60*255), -- Duration scales with accumulators, but the game does not allow this type of entity to persist for more than 255 seconds.
    fade_away_duration = 1 * 60,
    spread_duration = 10,
    animation =
    {
        filename = "__Clockwork-2__/graphics/flare-capsule.png",
        priority = "high",
        width = 128,
        height = 128,
        frame_count = 1,
        scale = 0.5,
    },
    working_sound =
    {
      sound = { filename = "__Clockwork-2__/sounds/flare-burning.ogg" },
      apparent_volume = 0.5,
      audible_distance_modifier = 0.5,
      max_sounds_per_type = 3,
    },
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
            type = "create-explosion",
            entity_name = "explosion-flare"
        }
      }
    },
    action_cooldown = 30,
  },

  {
    type = "projectile",
    name = "ln-flare-capsule",
    flags = {"not-on-map"},
    acceleration = 0.005,
    light = {intensity = 0.9, size = 60, color = { r = 1.000, g = 0.888, b = 0.419}},
    animation =
    {
        filename = "__Clockwork-2__/graphics/flare-capsule.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        frame_count = 1,
    },
    smoke = capsule_smoke,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
              type = "create-entity",
              entity_name = "flare-cloud",
          },
        }
      }
    }
  }
})