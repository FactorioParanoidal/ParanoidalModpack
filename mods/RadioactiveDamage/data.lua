function uranium_stream(data)
  return
  {
    type = "stream",
    name = data.name,
    flags = {"not-on-map"},
    stream_light = {intensity = 1, size = 4},
    ground_light = {intensity = 0.8, size = 4},

    particle_buffer_size = 90,
    particle_spawn_interval = data.particle_spawn_interval,
    particle_spawn_timeout = data.particle_spawn_timeout,
    particle_vertical_acceleration = 0.005 * 0.60 *1.5, --x
    particle_horizontal_speed = 0.2* 0.75 * 1.5 * 1.5, --x
    particle_horizontal_speed_deviation = 0.005 * 0.70,
    particle_start_alpha = 0.5,
    particle_end_alpha = 1,
    particle_alpha_per_part = 0.8,
    particle_scale_per_part = 0.8,
    particle_loop_frame_count = 15,
    particle_fade_out_threshold = 0.95,
    particle_fade_out_duration = 2,
    particle_loop_exit_threshold = 0.25,
    special_neutral_target_damage = {amount = 1, type = "uranium-damage"},
    initial_action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
           --[[ {
              type = "create-fire",
              entity_name = data.splash_fire_name,
              tile_collision_mask = { "water-tile" }
            },]]--
            {
              type = "create-entity",
              entity_name = "water-splash",
              tile_collision_mask = { "ground-tile" }
            }
          }
        }
      },
      {
        type = "area",
        radius = data.spit_radius,
        force = "enemy",
        ignore_collision_condition = true,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
      --[[      {
              type = "create-sticker",
              sticker = data.sticker_name
            },]]-- 
            {
              type = "damage",
              damage = {amount = 1, type = "uranium-damage"}
            }
          }
        }
      }
    },
    particle = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
      line_length = 5,
      width = 22,
      height = 84,
      frame_count = 15,
      shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      tint = data.tint,
      priority = "high",
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
        line_length = 5,
        width = 42,
        height = 164,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
        tint = data.tint,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },
    spine_animation = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-tail.png",
      line_length = 5,
      width = 66,
      height = 12,
      frame_count = 15,
      shift = util.mul_shift(util.by_pixel(0, -2), data.scale),
      tint = data.tint,
      priority = "high",
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-tail.png",
        line_length = 5,
        width = 132,
        height = 20,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(0, -1), data.scale),
        tint = data.tint,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },
    shadow = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
      line_length = 15,
      width = 22,
      height = 84,
      frame_count = 15,
      priority = "high",
      shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      draw_as_shadow = true,
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
        line_length = 15,
        width = 42,
        height = 164,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
        draw_as_shadow = true,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },

    oriented_particle = true,
    shadow_scale_enabled = true,
  }
end

data:extend({uranium_stream({
    name = "uranium-damage",
    scale = 0.83,
    tint = {r = 0, g = 1.000, b = 0, a = 1.000},
    corpse_name = "acid-splash-worm-medium",
    spit_radius = 1.55,
    particle_spawn_interval = 1,
    particle_spawn_timeout = 6,
    splash_fire_name = "acid-splash-fire-worm-medium",
    sticker_name = "acid-sticker-medium"})})

local whitebelt = util.table.deepcopy(data.raw["armor"]["heavy-armor"]);
whitebelt.name = "hazmat-suit"
whitebelt.icon = "__RadioactiveDamage__/hazmat-suit.png"
whitebelt.icon_size = 96
whitebelt.equipment_grid = nil
whitebelt.inventory_size_bonus = 0
whitebelt.infinite = false
whitebelt.durability = 15
whitebelt.resistances =
    {
      {
        type = "uranium-damage",
        decrease = 1,
        percent = 99
      }}
data:extend({whitebelt})

local whitedam = util.table.deepcopy(data.raw["damage-type"]["acid"]);
whitedam.name = "uranium-damage"
data:extend({whitedam})

data:extend({{
    type = "recipe",
    name = "hazmat-suit",
    enabled = true,
    energy_required = 8,
    ingredients = {{ "plastic-bar", 100}, {"lead-plate", 100}},
    result = "hazmat-suit"
  }})