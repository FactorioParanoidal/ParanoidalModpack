local shared = require("prototypes.shared")
local sounds = require("__base__.prototypes.entity.sounds")

local cannon_force = shared.setting("tank-cannon-force-condition")
local autocannon_force = shared.setting("tank-autocannon-force-condition")

local shell_collision_box = {{-0.3, -1.1}, {0.3, 1.1}}
local bullet_animation = table.deepcopy(data.raw.projectile["cannon-projectile"].animation)
local rocket_projectile = data.raw.projectile["rocket"]

local function instant(effects)
  return {type = "direct", action_delivery = {type = "instant", target_effects = effects}}
end

local function damage(amount, damage_type)
  return {type = "damage", damage = {amount = amount, type = damage_type}}
end

local function entity(name)
  return {type = "create-entity", entity_name = name}
end

local function scorchmark()
  return {type = "create-entity", entity_name = "small-scorchmark", check_buildability = true}
end

local function area(radius, effects)
  return {type = "nested-result", action = {type = "area", radius = radius, action_delivery = {type = "instant", target_effects = effects}}}
end

-- Armour-piercing cannon shell (normal or uranium).
local function ap_projectile(name, piercing, physical, explosion, hit_explosion)
  return {
    type = "projectile",
    name = name,
    flags = {"not-on-map"},
    hidden = true,
    collision_box = shell_collision_box,
    force_condition = cannon_force,
    acceleration = 0,
    direction_only = true,
    piercing_damage = piercing,
    action = instant({damage(physical, "physical"), damage(explosion, "explosion"), entity(hit_explosion)}),
    final_action = instant({scorchmark()}),
    animation = bullet_animation
  }
end

-- High-explosive shell: direct hit plus area explosion.
local function he_projectile(spec)
  local final_effects = {entity(spec.final_explosion), area(spec.radius, {damage(spec.area_damage, "explosion"), entity(spec.area_explosion)})}
  if spec.scorchmark then table.insert(final_effects, scorchmark()) end
  return {
    type = "projectile",
    name = spec.name,
    flags = {"not-on-map"},
    hidden = true,
    collision_box = shell_collision_box,
    force_condition = spec.force,
    acceleration = 0,
    piercing_damage = spec.piercing,
    action = instant({damage(spec.physical, "physical"), entity(spec.hit_explosion)}),
    final_action = instant(final_effects),
    animation = bullet_animation
  }
end

-- Explosions of the autocannon: the 2.0 explosion animation at 60% size.
local autocannon_explosion = table.deepcopy(data.raw.explosion["explosion"])
autocannon_explosion.name = "autocannon-explosion"
shared.rescale_sprite(autocannon_explosion.animations, 0.6)
autocannon_explosion.light = {intensity = 1, size = 12, color = {r = 1, g = 1, b = 1}}
autocannon_explosion.smoke = "smoke-fast"
autocannon_explosion.smoke_count = 2
autocannon_explosion.smoke_slow_down_factor = 1
autocannon_explosion.sound = table.deepcopy(sounds.small_explosion)
shared.scale_sound(autocannon_explosion.sound, 0.3)

local uranium_tint = {r = 0.4, g = 1, b = 0.4}

local uranium_autocannon_explosion = table.deepcopy(autocannon_explosion)
uranium_autocannon_explosion.name = "uranium-autocannon-explosion"
shared.tint_sprite(uranium_autocannon_explosion.animations, uranium_tint, true)

local uranium_autocannon_shell_explosion = table.deepcopy(data.raw.explosion["explosion"])
uranium_autocannon_shell_explosion.name = "uranium-autocannon-shell-explosion"
shared.tint_sprite(uranium_autocannon_shell_explosion.animations, uranium_tint, true)

-- Napalm: 2.0 fire graphics with the Beta 8 values (other mods may already have changed fire-flame).
local napalm_flame = table.deepcopy(data.raw.fire["fire-flame"])
napalm_flame.name = "Schall-napalm-fire-flame"
napalm_flame.localised_name = {"entity-name.fire-flame"}
napalm_flame.damage_per_tick = {amount = 13 / 60, type = "fire"}
napalm_flame.maximum_damage_multiplier = 6
napalm_flame.damage_multiplier_increase_per_added_fuel = 1
napalm_flame.damage_multiplier_decrease_per_tick = 0.005
napalm_flame.spread_delay = 300
napalm_flame.spread_delay_deviation = 180
napalm_flame.maximum_spread_count = 100
napalm_flame.lifetime_increase_cooldown = 4
napalm_flame.delay_between_initial_flames = 10
napalm_flame.initial_lifetime = 180
napalm_flame.lifetime_increase_by = 225
napalm_flame.maximum_lifetime = 3600

local napalm_fire = {
  type = "projectile",
  name = "Schall-napalm-fire",
  flags = {"not-on-map"},
  hidden = true,
  acceleration = 0.005,
  action = {
    instant({{type = "create-fire", entity_name = "Schall-napalm-fire-flame", initial_ground_flame_count = 240, show_in_tooltip = true}}),
    {
      type = "area",
      radius = 2.5,
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "create-sticker", sticker = "fire-sticker"},
          {type = "damage", damage = {amount = 5, type = "fire"}, apply_damage_to_trees = false}
        }
      }
    }
  },
  animation = table.deepcopy(rocket_projectile.animation),
  shadow = table.deepcopy(rocket_projectile.shadow)
}

local function napalm_cluster(count, distance, deviation)
  return {
    type = "nested-result",
    action = {
      type = "cluster",
      cluster_count = count,
      distance = distance,
      distance_deviation = deviation,
      action_delivery = {
        type = "projectile",
        projectile = "Schall-napalm-fire",
        direction_deviation = 0.6,
        starting_speed = 0.3,
        starting_speed_deviation = 0.1
      }
    }
  }
end

local incendiary_autocannon_projectile = {
  type = "projectile",
  name = "incendiary-autocannon-projectile",
  flags = {"not-on-map"},
  hidden = true,
  force_condition = autocannon_force,
  acceleration = 0,
  action = instant({napalm_cluster(2, 0.5, 1)}),
  light = {intensity = 0.8, size = 5},
  animation = bullet_animation
}

local incendiary_rocket = table.deepcopy(rocket_projectile)
incendiary_rocket.name = "Schall-incendiary-rocket"
incendiary_rocket.acceleration = 0.005
incendiary_rocket.action = instant({
  {
    type = "create-trivial-smoke",
    smoke_name = "nuclear-smoke",
    repeat_count = 10,
    offset_deviation = {{-1, -1}, {1, 1}},
    starting_frame = 3,
    starting_frame_deviation = 5,
    speed_from_center = 0.5
  },
  entity("big-explosion"),
  scorchmark(),
  napalm_cluster(8, 2, 6)
})

data:extend({
  autocannon_explosion,
  uranium_autocannon_explosion,
  uranium_autocannon_shell_explosion,
  napalm_flame,
  napalm_fire,
  incendiary_autocannon_projectile,
  incendiary_rocket,

  he_projectile({
    name = "explosive-autocannon-projectile", force = autocannon_force,
    piercing = 10, physical = 18, hit_explosion = "autocannon-explosion",
    final_explosion = "explosion", radius = 4, area_damage = 30, area_explosion = "autocannon-explosion"
  }),
  he_projectile({
    name = "explosive-uranium-autocannon-projectile", force = autocannon_force,
    piercing = 15, physical = 35, hit_explosion = "uranium-autocannon-explosion",
    final_explosion = "uranium-autocannon-shell-explosion", radius = 4.25, area_damage = 31.5,
    area_explosion = "uranium-autocannon-explosion", scorchmark = true
  }),

  ap_projectile("cannon-H1-projectile", 400, 350, 160, "explosion"),
  ap_projectile("cannon-H2-projectile", 500, 500, 360, "explosion"),
  ap_projectile("uranium-cannon-H1-projectile", 800, 700, 320, "uranium-cannon-explosion"),
  ap_projectile("uranium-cannon-H2-projectile", 1000, 1000, 720, "uranium-cannon-explosion"),

  he_projectile({
    name = "explosive-cannon-H1-projectile", force = cannon_force,
    piercing = 133, physical = 315, hit_explosion = "explosion",
    final_explosion = "big-explosion", radius = 4.45, area_damage = 380, area_explosion = "explosion"
  }),
  he_projectile({
    name = "explosive-cannon-H2-projectile", force = cannon_force,
    piercing = 166, physical = 450, hit_explosion = "explosion",
    final_explosion = "big-explosion", radius = 6, area_damage = 570, area_explosion = "explosion"
  }),
  he_projectile({
    name = "explosive-uranium-cannon-H1-projectile", force = cannon_force,
    piercing = 200, physical = 612, hit_explosion = "uranium-cannon-explosion",
    final_explosion = "uranium-cannon-shell-explosion", radius = 4.75, area_damage = 400,
    area_explosion = "uranium-cannon-explosion", scorchmark = true
  }),
  he_projectile({
    name = "explosive-uranium-cannon-H2-projectile", force = cannon_force,
    piercing = 250, physical = 875, hit_explosion = "uranium-cannon-explosion",
    final_explosion = "uranium-cannon-shell-explosion", radius = 6.375, area_damage = 600,
    area_explosion = "uranium-cannon-explosion", scorchmark = true
  }),
})
