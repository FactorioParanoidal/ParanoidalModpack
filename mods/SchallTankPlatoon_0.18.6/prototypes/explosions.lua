local explosion_animations = require("prototypes.explosion-animations")
local sounds = require("__base__.prototypes.entity.demo-sounds")



data:extend
{
  -- Explosion
  {
    type = "explosion",
    name = "autocannon-explosion",
    flags = {"not-on-map"},
    subgroup = "explosions",
    animations = explosion_animations.explosion(0.6),
    light = {intensity = 1, size = 12, color = {r=1.0, g=1.0, b=1.0}},
    -- light = {intensity = 1, size = 20, color = {r=1.0, g=1.0, b=1.0}},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1,
    sound = sounds.small_explosion(0.3)
    -- sound = sounds.small_explosion(0.5)
  },
  {
    type = "explosion",
    name = "napalm-big-explosion",
    flags = {"not-on-map"},
    subgroup = "explosions",
    animations = explosion_animations.big_explosion(4),
    -- animations = explosion_animations.big_explosion(),
    light = {intensity = 1, size = 50, color = {r=1.0, g=1.0, b=1.0}},
    sound = sounds.large_explosion(1.0),
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
            particle_name = "explosion-remnants-particle",
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
}



local uranium_autocannon_shell_explosion = util.table.deepcopy(data.raw["explosion"]["explosion"])
uranium_autocannon_shell_explosion.name = "uranium-autocannon-shell-explosion"
uranium_autocannon_shell_explosion.animations[1].tint = {r = 0.4, g = 1, b = 0.4}

local uranium_autocannon_explosion = util.table.deepcopy(data.raw["explosion"]["autocannon-explosion"])
uranium_autocannon_explosion.name = "uranium-autocannon-explosion"
for k, v in pairs(uranium_autocannon_explosion.animations) do
  v.tint = {r = 0.4, g = 1, b = 0.4}
end


data:extend
{
  uranium_autocannon_shell_explosion,
  uranium_autocannon_explosion
}
