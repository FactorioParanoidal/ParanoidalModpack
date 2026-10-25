-- Droid units (ground and flying), their projectiles, beam and corpse.
local util = require("util")
local shared = require("lib.shared")

local ICONS = shared.mod_path .. "/graphics/icons/"
local BOTS = shared.mod_path .. "/graphics/entity/bots/"

local HEALTH = settings.startup[shared.setting.health_scale].value
local DAMAGE = settings.startup[shared.setting.damage_scale].value

local DROID_SCALE = 0.8
local DROID_BOX = 0.8 * DROID_SCALE
local MAP_COLOUR = {r = 0.05, g = 0.70, b = 0.29}
local AI_SETTINGS = {destroy_when_commands_fail = false, do_separation = true}

local function sounds(names, volume)
  local list = {}
  for i, name in pairs(names) do
    list[i] = {filename = "__base__/sound/fight/" .. name .. ".ogg", volume = volume}
  end
  return list
end

local LASER_SOUNDS = sounds({"laser-1", "laser-2", "laser-3"}, 0.7)
local HEAVY_SHOT_SOUNDS = sounds({"heavy-gunshot-1", "heavy-gunshot-2", "heavy-gunshot-3", "heavy-gunshot-4"}, 0.45)
local LIGHT_SHOT_SOUNDS = sounds({"light-gunshot-1", "light-gunshot-2", "light-gunshot-3"}, 0.7)
local RIFLE_SHOT_SOUNDS = sounds({"light-gunshot-1", "light-gunshot-2", "light-gunshot-3"}, 1)

local FLYING_WORKING_SOUND = {
  sound = {
    {filename = "__base__/sound/flying-robot-1.ogg", volume = 0.6},
    {filename = "__base__/sound/flying-robot-2.ogg", volume = 0.6},
    {filename = "__base__/sound/flying-robot-3.ogg", volume = 0.6},
    {filename = "__base__/sound/flying-robot-4.ogg", volume = 0.6},
    {filename = "__base__/sound/flying-robot-5.ogg", volume = 0.6},
  },
  max_sounds_per_type = 3,
  probability = 1 / (3 * 60), -- average pause between the sounds is 3 seconds
}
local FLYING_DYING_SOUND = {
  {filename = "__base__/sound/fight/robot-explosion-1.ogg", volume = 0.5},
  {filename = "__base__/sound/fight/robot-explosion-2.ogg", volume = 0.5},
}

local SHELL_PARTICLE = {
  name = "shell-particle",
  direction_deviation = 0.1,
  speed = 0.1,
  speed_deviation = 0.03,
  center = {0, 0.1},
  creation_distance = -0.5,
  starting_frame_speed = 0.4,
  starting_frame_speed_deviation = 0.1,
}

local function bullet_ammo(damage)
  return {
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        source_effects = {type = "create-explosion", entity_name = "explosion-gunshot-small"},
        target_effects = {
          {type = "create-entity", entity_name = "explosion-hit"},
          {type = "damage", damage = {amount = damage * DAMAGE, type = "physical"}},
        },
      },
    },
  }
end

local function robot_animation(sheet, scale)
  return {
    layers = {
      {
        filename = BOTS .. "hr-" .. sheet .. ".png",
        width = 160,
        height = 160,
        direction_count = 22,
        frame_count = 1,
        animation_speed = 0.01,
        shift = {0, -0.5},
        scale = scale / 2,
      },
      {
        filename = BOTS .. "hr-" .. sheet .. "-shadow.png",
        width = 320,
        height = 160,
        direction_count = 22,
        frame_count = 1,
        animation_speed = 0.01,
        shift = {0, -0.5},
        scale = scale / 2,
        draw_as_shadow = true,
      },
    },
  }
end

local function resist(list)
  local out = {}
  for i, r in pairs(list) do
    out[i] = {type = r[1], decrease = r[2], percent = r[3]}
  end
  return out
end

--- Ground droid. `p.attack` gets the run animation assigned.
local function ground_droid(p)
  local animation = robot_animation(p.sheet, p.anim_scale or 1)
  p.attack.animation = animation
  return {
    type = "unit",
    name = p.name,
    icon = ICONS .. p.icon,
    icon_size = 64,
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    subgroup = "creatures",
    order = "e-a-b-d",
    max_health = p.health * HEALTH,
    healing_per_tick = p.healing,
    alert_when_damaged = false,
    has_belt_immunity = true,
    collision_box = {{-DROID_BOX, -DROID_BOX}, {DROID_BOX, DROID_BOX}},
    selection_box = {{-DROID_BOX, -DROID_BOX}, {DROID_BOX, DROID_BOX}},
    sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
    vision_distance = 30,
    radar_range = 1,
    can_open_gates = true,
    ai_settings = AI_SETTINGS,
    movement_speed = p.speed,
    distance_per_frame = 0.05,
    distraction_cooldown = 0,
    absorptions_to_join_attack = {},
    minable = {mining_time = 0.1, result = p.name},
    friendly_map_color = MAP_COLOUR,
    dying_explosion = "medium-explosion",
    resistances = resist(p.resistances),
    attack_parameters = p.attack,
    run_animation = animation,
  }
end

--- Flying droid built on the vanilla combat robot sprites.
local function flying_droid(p)
  p.attack.animation = p.animation
  return {
    type = "unit",
    name = p.name,
    icon = "__base__/graphics/icons/" .. p.icon,
    icon_size = 64,
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    subgroup = "creatures",
    order = p.order,
    max_health = p.health * HEALTH,
    healing_per_tick = 0,
    alert_when_damaged = false,
    has_belt_immunity = true,
    collision_box = p.collision_box,
    collision_mask = p.collision_mask,
    selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
    sticker_box = {{-0.1, -0.1}, {0.1, 0.1}},
    vision_distance = 45,
    radar_range = 1,
    can_open_gates = true,
    ai_settings = AI_SETTINGS,
    movement_speed = 0.2,
    distance_per_frame = 0.15,
    distraction_cooldown = 300,
    absorptions_to_join_attack = {},
    minable = {mining_time = 0.1, result = p.name},
    corpse = "robot-corpse",
    dying_explosion = "explosion",
    working_sound = FLYING_WORKING_SOUND,
    dying_sound = FLYING_DYING_SOUND,
    resistances = resist(p.resistances),
    attack_parameters = p.attack,
    run_animation = p.animation,
  }
end

--- Vanilla combat robot sheet (body, runtime-tinted mask, shadow).
local function robot_sheet(name, lines, body, mask, shadow)
  local path = "__base__/graphics/entity/" .. name .. "/" .. name
  local function layer(suffix, l)
    return {
      filename = path .. suffix .. ".png",
      priority = "high",
      line_length = lines,
      width = l[1],
      height = l[2],
      y = l.y,
      direction_count = lines,
      shift = util.by_pixel(l[3], l[4]),
      scale = 0.5,
      apply_runtime_tint = l.tint,
      draw_as_shadow = l.shadow,
    }
  end
  mask.tint = true
  shadow.shadow = true
  return {layers = {layer("", body), layer("-mask", mask), layer("-shadow", shadow)}}
end

local fire_resist = {"fire", 5, 95}

data:extend({
  ground_droid({
    name = "droid-smg", icon = "droid_smg_undep.png", sheet = "smg_run",
    health = 120, healing = 0.01, speed = 0.11,
    resistances = {{"physical", 1, 40}, {"explosion", 5, 70}, {"acid", 1, 30}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = "bullet",
      shell_particle = SHELL_PARTICLE,
      cooldown = 20,
      projectile_center = {0, 0.5},
      projectile_creation_distance = 0.6,
      range = 13,
      sound = HEAVY_SHOT_SOUNDS,
      ammo_type = bullet_ammo(8),
    },
  }),
  ground_droid({
    name = "droid-flame", icon = "droid_flame_undep.png", sheet = "flame_run",
    health = 200, healing = 0.01, speed = 0.09,
    resistances = {{"physical", 5, 40}, {"explosion", 5, 70}, {"acid", 1, 30}, {"fire", nil, 95}},
    attack = {
      type = "stream",
      ammo_category = "flamethrower",
      movement_slow_down_factor = 0.6,
      cooldown = 30,
      projectile_creation_distance = 0.6,
      range = 10,
      min_range = 0,
      projectile_center = {-0.17, 0.2},
      cyclic_sound = {
        begin_sound = {{filename = "__base__/sound/fight/flamethrower-start.ogg", volume = 0.7}},
        middle_sound = {{filename = "__base__/sound/fight/flamethrower-mid.ogg", volume = 0.7}},
        end_sound = {{filename = "__base__/sound/fight/flamethrower-end.ogg", volume = 0.7}},
      },
      ammo_type = {
        action = {
          type = "direct",
          action_delivery = {
            type = "stream",
            stream = "flamethrower-fire-stream",
            duration = 60,
            source_offset = {0.15, -0.5},
            target_effects = {{type = "damage", damage = {amount = 1, type = "physical"}}},
          },
        },
      },
    },
  }),
  ground_droid({
    name = "droid-rifle", icon = "droid_rifle_undep.png", sheet = "rifle_run", anim_scale = DROID_SCALE,
    health = 40, healing = 0, speed = 0.08,
    resistances = {{"physical", 1, 30}, {"explosion", 5, 50}, {"acid", 1, 25}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = "bullet",
      shell_particle = SHELL_PARTICLE,
      cooldown = 120,
      projectile_center = {-0.6, 1},
      projectile_creation_distance = 0.8,
      range = 15,
      sound = RIFLE_SHOT_SOUNDS,
      ammo_type = bullet_ammo(10),
    },
  }),
  ground_droid({
    name = "droid-rocket", icon = "droid_rocket_undep.png", sheet = "rocket_run",
    health = 85, healing = 0.01, speed = 0.11,
    resistances = {{"physical", 1, 40}, {"explosion", 5, 30}, {"acid", 1, 30}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = "rocket",
      movement_slow_down_factor = 0.8,
      cooldown = 180,
      projectile_creation_distance = 1,
      range = 22,
      projectile_center = {0.6, 1},
      sound = {{filename = "__base__/sound/fight/rocket-launcher.ogg", volume = 0.7}},
      ammo_type = {
        action = {
          type = "direct",
          action_delivery = {
            type = "projectile",
            projectile = "droid-explosive-rocket",
            starting_speed = 0.9,
            source_effects = {type = "create-entity", entity_name = "explosion-hit"},
          },
        },
      },
    },
  }),
  ground_droid({
    name = "terminator", icon = "terminator.png", sheet = "terminator_run",
    health = 300, healing = 0.02, speed = 0.18,
    resistances = {{"physical", 1, 80}, {"explosion", 20, 90}, {"acid", 5, 85}, {"laser", 5, 35}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = "laser",
      cooldown = 10,
      projectile_center = {0, 0.4},
      projectile_creation_distance = 1.5,
      range = 15,
      sound = LASER_SOUNDS,
      ammo_type = {
        action = {
          type = "direct",
          action_delivery = {type = "projectile", projectile = "laser-dual", starting_speed = 1},
        },
      },
    },
  }),

  flying_droid({
    name = "defender-unit", icon = "defender.png", order = "b-b-a", health = 65,
    collision_mask = {layers = {ghost = true}},
    resistances = {{"physical", 4}, {"acid", 1, 30}},
    animation = robot_sheet("defender-robot", 16,
      {56, 59, 0, 0.25}, {28, 21, 0, -4.75}, {88, 50, 25.5, 19}),
    attack = {
      type = "projectile",
      ammo_category = "bullet",
      cooldown = 20,
      projectile_center = {0, 1},
      projectile_creation_distance = 0.6,
      range = 12,
      min_attack_distance = 8,
      sound = LIGHT_SHOT_SOUNDS,
      ammo_type = bullet_ammo(5),
    },
  }),
  flying_droid({
    name = "distractor-unit", icon = "distractor.png", order = "b-b-b", health = 85,
    collision_box = {{0, 0}, {0, 0}},
    resistances = {{"physical", 4}, {"acid", 1, 30}},
    animation = robot_sheet("distractor-robot", 16,
      {72, 62, 0, -2.5}, {42, 37, 0, -6.25}, {96, 59, 32.5, 19.25}),
    attack = {
      type = "projectile",
      ammo_category = "laser",
      cooldown = 20,
      damage_modifier = 0.7,
      projectile_center = {0, 0.6},
      projectile_creation_distance = 0.6,
      range = 18,
      min_attack_distance = 12,
      sound = LASER_SOUNDS,
      ammo_type = {
        action = {
          type = "direct",
          action_delivery = {type = "projectile", projectile = "laser", starting_speed = 1},
        },
      },
    },
  }),
  flying_droid({
    name = "destroyer-unit", icon = "destroyer.png", order = "b-b-c", health = 120,
    collision_box = {{0, 0}, {0, 0}},
    resistances = {{"physical", 8}, {"acid", 5, 70}},
    animation = robot_sheet("destroyer-robot", 32,
      {88, 77, 2.5, -1.25, y = 77}, {52, 42, 2.5, -7, y = 42}, {108, 66, 23.5, 19}),
    attack = {
      type = "beam",
      ammo_category = "beam",
      cooldown = 20,
      range = 15,
      min_attack_distance = 9,
      ammo_type = {
        action = {
          type = "direct",
          action_delivery = {
            type = "beam",
            beam = "robot-electric-beam",
            max_length = 20,
            duration = 20,
            source_offset = {0.15, -0.5},
          },
        },
      },
    },
  }),
})

-- Projectiles, beam and corpse used by the droids.
local beam_body = {}
for i = 1, 6 do
  beam_body[i] = {
    filename = "__base__/graphics/entity/beam/beam-body-" .. i .. ".png",
    draw_as_glow = true,
    line_length = 16,
    width = 32,
    height = 39,
    frame_count = 16,
  }
end

local rocket_pictures = require("__base__.prototypes.entity.rocket-projectile-pictures")

data:extend({
  {
    type = "projectile",
    name = "laser-dual",
    flags = {"not-on-map"},
    acceleration = 0.01,
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "create-entity", entity_name = "laser-bubble"},
          {type = "damage", damage = {amount = 30 * DAMAGE, type = "laser"}},
        },
      },
    },
    light = {intensity = 0.7, size = 20},
    animation = {
      filename = shared.mod_path .. "/graphics/entity/laser/dual-laser.png",
      tint = {r = 1.0, g = 0.0, b = 0.0},
      frame_count = 1,
      width = 24,
      height = 33,
      priority = "high",
      blend_mode = "additive",
    },
  },
  {
    type = "projectile",
    name = "droid-explosive-rocket",
    flags = {"not-on-map"},
    acceleration = 0.035,
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {type = "create-entity", entity_name = "explosion"},
          {type = "damage", damage = {amount = 275 * DAMAGE, type = "explosion"}},
          {type = "create-entity", entity_name = "small-scorchmark", check_buildability = true},
        },
      },
    },
    light = {intensity = 0.5, size = 4},
    animation = rocket_pictures.animation({0.5, 1.0, 0.05}),
    shadow = rocket_pictures.shadow,
    smoke = rocket_pictures.smoke,
  },
  {
    type = "beam",
    name = "robot-electric-beam",
    flags = {"not-on-map"},
    working_sound = {filename = "__base__/sound/fight/electric-beam.ogg", volume = 0.7},
    width = 0.5,
    damage_interval = 20,
    random_target_offset = true,
    target_offset = {0, -0.5},
    action_triggered_automatically = false,
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {{type = "damage", damage = {amount = 15 * DAMAGE, type = "electric"}}},
      },
    },
    graphics_set = {
      beam = {
        start = {
          filename = "__base__/graphics/entity/beam/tileable-beam-START.png",
          draw_as_glow = true, line_length = 4, width = 94, height = 66, frame_count = 16,
          shift = {0.53125, 0}, scale = 0.5,
        },
        ending = {
          filename = "__base__/graphics/entity/beam/tileable-beam-END.png",
          draw_as_glow = true, line_length = 4, width = 91, height = 93, frame_count = 16,
          shift = {-0.078125, -0.046875}, scale = 0.5,
        },
        head = {
          filename = "__base__/graphics/entity/beam/beam-head.png",
          draw_as_glow = true, line_length = 16, width = 45 - 7, height = 39, frame_count = 16,
          shift = util.by_pixel(-7 / 2, 0),
        },
        tail = {
          filename = "__base__/graphics/entity/beam/beam-tail.png",
          draw_as_glow = true, line_length = 16, width = 45 - 6, height = 39, frame_count = 16,
          shift = util.by_pixel(6 / 2, 0),
        },
        body = beam_body,
      },
    },
  },
  {
    -- Invisible placeholder corpse of the flying droids.
    type = "corpse",
    name = "robot-corpse",
    icon = "__base__/graphics/icons/medium-biter-corpse.png",
    icon_size = 64,
    selectable_in_game = false,
    selection_box = {{-1, -1}, {1, 1}},
    flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-on-map"},
    subgroup = "corpses",
    order = "c[corpse]-a[biter]-b[medium]",
    dying_speed = 0.04,
    time_before_removed = 15 * 60 * 60,
    final_render_layer = "corpse",
    animation = {
      filename = "__base__/graphics/entity/defender-robot/defender-robot.png",
      width = 1,
      height = 1,
      frame_count = 16,
      direction_count = 16,
      priority = "very-low",
    },
  },
})
