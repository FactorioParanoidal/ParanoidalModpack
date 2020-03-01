-- needed: name, order, health, scale, tint, tint2, ammo_type
-- optional: icon, healing_per_tick, resistances, spawning_time_modifier, distraction_cooldown, pollution_to_join_attack, movement_speed, distance_per_frame, range, vision_distance

function bobmods.enemies.new_biter(input)
data:extend(
{
  {
    type = "unit",
    name = input.name,
    order = input.order,
    icon = input.icon or "__base__/graphics/icons/big-biter.png",
    icon_size = input.icon_size or 32,
    flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "breaths-air", "not-repairable"},
    max_health = input.health,
    subgroup = "enemies",
    resistances = input.resistances,
    spawning_time_modifier = input.spawning_time_modifier or 2,
    healing_per_tick = input.healing_per_tick or 0.02,
    collision_box = {{-0.4 * input.scale, -0.4 * input.scale}, {0.4 * input.scale, 0.4 * input.scale}},
    selection_box = {{-0.7 * input.scale, -1.5 * input.scale}, {0.7 * input.scale, 0.3 * input.scale}},
    sticker_box = {{-0.6 * input.scale, -0.8 * input.scale}, {0.6 * input.scale, 0}},
    distraction_cooldown = input.distraction_cooldown or 300,
    min_pursue_time = 10 * 60,
    max_pursue_distance = 50,
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "melee",
      ammo_type = input.ammo_type,
      range = input.range or 1.5,
      cooldown = 35,
      sound =  make_biter_roars(0.6 * input.scale),
      animation = biterattackanimation(input.scale, input.tint, input.tint2)
    },
    vision_distance = input.vision_distance or 30,
    movement_speed = input.movement_speed or 0.17,
    distance_per_frame = input.distance_per_frame or 0.2,
    -- in pu
    pollution_to_join_attack = input.pollution_to_join_attack or 2000,
    corpse = input.name .. "-corpse",
    dying_explosion = "blood-explosion-big",
    working_sound = make_biter_calls(0.9 * input.scale),
    dying_sound = make_biter_dying_sounds(1.0 * input.scale),
    run_animation = biterrunanimation(input.scale, input.tint, input.tint2)
  },

  {
    type = "corpse",
    name = input.name .. "-corpse",
    icon = input.icon or "__base__/graphics/icons/big-biter-corpse.png",
    icon_size = input.icon_size or 32,
    selectable_in_game = false,
    selection_box = {{-1 * input.scale, -1 * input.scale}, {1 * input.scale, 1 * input.scale}},
    subgroup="corpses",
    order = "c[corpse]-" .. input.order,
    flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-on-map"},
    dying_speed = 0.04,
    time_before_removed = 15 * 60 * 60,
    final_render_layer = "corpse",
    animation = biterdieanimation(input.scale, input.tint, input.tint2)
  }
}
)
end
