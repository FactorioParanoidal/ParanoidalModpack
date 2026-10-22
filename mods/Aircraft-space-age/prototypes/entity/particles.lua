local ENTITYPATH = "__Aircraft-space-age__/graphics/entity/"


local napalm_tint = {r=1, g=0.3, b=0.2, a=0.9} --napalm tint
local fire_dev = 7 --napalm spread
local number_of_fires = 12 --napalm number of spawned fires

local function napalm_target_effects()
  local nte = {}
  local fire = {
    type = "create-fire",
    entity_name = "napalm_fire_flame",
    --show_in_tooltip = true,
    offset_deviation = {{-fire_dev, -fire_dev}, {fire_dev, fire_dev}}
  }
  for i=1,number_of_fires do
    table.insert(nte, fire)
    --i = i+1
  end
  return nte
end

local napalm_spine_animation = table.deepcopy(data.raw["stream"]["flamethrower-fire-stream"].spine_animation)
napalm_spine_animation.tint = napalm_tint
napalm_spine_animation.scale = 1
local napalm_shadow = table.deepcopy(data.raw["stream"]["flamethrower-fire-stream"].shadow)
local napalm_particle = table.deepcopy(data.raw["stream"]["flamethrower-fire-stream"].particle)
napalm_particle.tint = napalm_tint

local napalm_fire_flame = table.deepcopy(data.raw["fire"]["fire-flame"])
napalm_fire_flame.name = "napalm_fire_flame"
--napalm_fire_flame.emissions_per_second = 0.050
--change in 2.0 modding API
napalm_fire_flame.emissions = {
    type = "pollution",
    amount = 0.050
}
napalm_fire_flame.damage_per_tick = {amount = 9 / 60, type = "fire"}
napalm_fire_flame.maximum_damage_multiplier = 6
napalm_fire_flame.spread_delay = 5
napalm_fire_flame.spread_delay_deviation = 5
napalm_fire_flame.maximum_spread_count = 500
napalm_fire_flame.initial_lifetime = 600
napalm_fire_flame.lifetime_increase_by = 200
napalm_fire_flame.lifetime_increase_cooldown = 1
napalm_fire_flame.maximum_lifetime = 5000
napalm_fire_flame.delay_between_initial_flames = 1
napalm_fire_flame.smoke[1].deviation = {1.5, 1.5}
napalm_fire_flame.smoke[1].frequency = 0.4
napalm_fire_flame.smoke[1].vertical_speed_slowdown = 0.5
napalm_fire_flame.light = {intensity = 0.1, size = 25, color = napalm_tint}
napalm_fire_flame.smoke_fade_in_duration = 90
napalm_fire_flame.smoke_fade_out_duration = 120
napalm_fire_flame.fade_in_duration = 45
napalm_fire_flame.fade_out_duration = 300

local norendertiles = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" }
for _,tile in pairs(norendertiles) do
  if not mods["alien-biomes"] then
    if data.raw["tile"][tile] then
      table.insert(napalm_fire_flame.burnt_patch_alpha_variations, {tile = tile, alpha = 0})
    end
  end
end

for _,picture in pairs(napalm_fire_flame.pictures) do
  picture.tint = napalm_tint
  picture.scale = 0.7
  --picture.shift[2] = picture.shift[2] - 0.3
end

data:extend({
-----------------------------------------------------napalm fire
  napalm_fire_flame,
-----------------------------------------------------light trail
  {
    type = "trivial-smoke",
    name = "aircraft-trail",
    animation = {
      filename = ENTITYPATH .. "particle/aircraft-trail.png",
      priority = "high",
      width = 64,
      height = 64,
      frame_count = 1,
      repeat_count = 255,
      animation_speed = 1,
      scale = 0.5,
      tint = {r = 0.85, g = 0.67, b = 0.25, a = 1},
      draw_as_glow = true,
    },
    render_layer = "air-object",
    affected_by_wind = false,
    movement_slow_down_factor = 0,
    duration = 255,
    fade_away_duration = 255,
    show_when_smoke_off = true,
    start_scale = 0.5,
    end_scale = 6,
    --cyclic = true,
  },
-----------------------------------------------------napalm stream
  {
    type = "stream",
    name = "napalm-flamethrower-fire-stream",
    flags = {"not-on-map"},

    smoke_sources =
    {
      {
        name = "soft-fire-smoke",
        frequency = 0.05, --0.25,
        position = {0.0, 0}, -- -0.8},
        starting_frame_deviation = 60
      }
    },

    --stream_light = {intensity = 1, size = 4 * 0.8},
    --ground_light = {intensity = 0.8, size = 4 * 0.8},

    particle_buffer_size = 65,
    particle_spawn_interval = 2,
    particle_spawn_timeout = 2,
    particle_vertical_acceleration = 0.005 * 0.3,
    particle_horizontal_speed = 0.45,
    particle_horizontal_speed_deviation = 0.0035,
    particle_start_alpha = 0.5,
    particle_end_alpha = 1,
    particle_start_scale = 0.5,
    particle_loop_frame_count = 3,
    particle_fade_out_threshold = 0.9,
    particle_loop_exit_threshold = 0.25,
    action =
    {
      {
        type = "area",
        radius = 4, --tank-flamethrower-ammo: 4
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "damage",
              damage = { amount = 3, type = "fire" }, --tank-flamethrower-ammo: 7
              apply_damage_to_trees = true
            }
          }
        }
      },
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects = napalm_target_effects()
        }
      }
    },
    spine_animation = napalm_spine_animation,
    shadow = napalm_shadow,
    particle = napalm_particle
  },
})
