-- DrD require("prototypes.entities-walls")



data:extend
{
  {
    type = "smoke-with-trigger",
    name = "Schall-poison-cloud",
    localised_name = {"entity-name.poison-cloud"},
    flags = {"not-on-map"},
    show_when_smoke_off = true,
    render_layer = "lower-object-above-shadow",	-- Default: nil,
    animation =
    {
      filename = "__base__/graphics/entity/cloud/cloud-45-frames.png",
      flags = { "compressed" },
      priority = "low",
      width = 256,
      height = 256,
      frame_count = 45,
      animation_speed = 0.5,
      line_length = 7,
      scale = 3
    },
    affected_by_wind = false,	-- Seems no visible difference
    cyclic = true,
    duration = 60 * 20,
    fade_away_duration = 2 * 60,
    spread_duration = 10,
    color = { r = 0.9, g = 0.9, b = 0.2 }, --{ r = 0.2, g = 0.9, b = 0.2 },
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
                damage = { amount = 8, type = "poison"}
              }
            }
          }
        }
      }
    },
    action_cooldown = 30
  },
}