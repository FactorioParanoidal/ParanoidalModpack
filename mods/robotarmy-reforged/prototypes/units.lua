-- Droid units (ground and flying), their projectiles, beams, chain lightning and corpse.
-- The tooltips with the characteristics are written in data-updates (prototypes/ranks.lua),
-- together with the rank prototypes, from the final unit prototypes.
local util = require("util")
local shared = require("lib.shared")

local BOTS = shared.mod_path .. "/graphics/entity/bots/"

local HEALTH = settings.startup[shared.setting.health_scale].value
local DAMAGE = settings.startup[shared.setting.damage_scale].value
local A = shared.ammo
local YUOKI = mods["Yuoki"] ~= nil
-- Bob's plasma damage when Bob's Warfare is there, laser otherwise.
local PLASMA = data.raw["damage-type"]["bob-plasma"] and "bob-plasma" or "laser"

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

local function projectile_ammo(projectile, speed)
  return {
    action = {
      type = "direct",
      action_delivery = {type = "projectile", projectile = projectile, starting_speed = speed or 1},
    },
  }
end

--- Bullet attack of a ground droid.
local function bullets(cooldown, range, damage, sound, center)
  return {
    type = "projectile",
    ammo_category = A.bullet,
    shell_particle = SHELL_PARTICLE,
    cooldown = cooldown,
    projectile_center = center or {0, 0.5},
    projectile_creation_distance = 0.6,
    range = range,
    sound = sound,
    ammo_type = bullet_ammo(damage),
  }
end

--- Run animation of a ground droid (models by YuokiTani); `tint` recolours the body, not the shadow.
local function robot_animation(sheet, scale, tint)
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
        tint = tint,
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

--- Animated walker models of Yuoki Industries (character armour styles): walking 8 directions x 22
--- frames, aiming 18 directions. Used only when that mod is active (the files stay in it).
local YUOKI_SCALE = 0.7
local YUOKI_MODELS = {
  cb4 = {width = 90, walk = "cb4_walk_sheet", gun = "cb4_gun_sheet"},
  robo1 = {width = 80, walk = "robo1_walk", gun = "robo1_walk_gun"},
}
local function yuoki_animations(model)
  local m = YUOKI_MODELS[model]
  local path = "__Yuoki__/graphics/armor/"
  local shift = {0.13 * YUOKI_SCALE, -0.25 * YUOKI_SCALE}
  local run = {
    filename = path .. m.walk .. ".png",
    width = m.width,
    height = 100,
    direction_count = 8,
    frame_count = 22,
    scale = YUOKI_SCALE,
    shift = shift,
  }
  local aim = {
    filename = path .. m.gun .. ".png",
    width = m.width,
    height = 100,
    direction_count = 18,
    frame_count = 1,
    scale = YUOKI_SCALE,
    shift = shift,
  }
  return run, aim
end

local function resist(list)
  local out = {}
  for i, r in pairs(list) do
    out[i] = {type = r[1], decrease = r[2], percent = r[3]}
  end
  return out
end

--- Ground droid. `p.regen` is health per second; `p.attack` gets its animation assigned.
local function ground_droid(p)
  local d = shared.droid_by_name[p.name]
  local run, aim, distance_per_frame
  if d.yuoki and YUOKI then
    run, aim = yuoki_animations(d.yuoki)
    distance_per_frame = 0.1
  else
    run = robot_animation(p.sheet, p.anim_scale or 1, d.tint)
    aim = run
    distance_per_frame = 0.05
  end
  p.attack.animation = aim
  return {
    type = "unit",
    name = p.name,
    icons = shared.droid_icons(p.name),
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    subgroup = "creatures",
    order = "e-a-b-d",
    max_health = p.health * HEALTH,
    healing_per_tick = (p.regen or 0) / 60,
    alert_when_damaged = false,
    has_belt_immunity = true,
    collision_box = {{-DROID_BOX, -DROID_BOX}, {DROID_BOX, DROID_BOX}},
    selection_box = {{-DROID_BOX, -DROID_BOX}, {DROID_BOX, DROID_BOX}},
    sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
    vision_distance = p.vision or 30,
    radar_range = p.radar_range or 1,
    can_open_gates = true,
    ai_settings = AI_SETTINGS,
    movement_speed = p.speed,
    distance_per_frame = distance_per_frame,
    distraction_cooldown = 0,
    absorptions_to_join_attack = {},
    minable = {mining_time = 0.1, result = p.name},
    friendly_map_color = MAP_COLOUR,
    dying_explosion = "medium-explosion",
    resistances = resist(p.resistances),
    attack_parameters = p.attack,
    run_animation = run,
  }
end

--- Flying droid built on the vanilla combat robot sprites. Health and damage: half of ten
--- combat robots of its type (five robots), measured on vanilla robots.
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
local light_resist = {{"physical", 1, 30}, {"explosion", 5, 50}, {"acid", 1, 25}, fire_resist}
local armoured_resist = {{"physical", 1, 40}, {"explosion", 5, 70}, {"acid", 1, 30}, fire_resist}

data:extend({
  -- Light infantry (rifle model).
  ground_droid({
    name = "droid-rifle", sheet = "rifle_run", anim_scale = DROID_SCALE,
    health = 100, regen = 0, speed = 0.08,
    resistances = light_resist,
    attack = bullets(90, 15, 20, RIFLE_SHOT_SOUNDS, {-0.6, 1}),
  }),
  ground_droid({
    -- Scout: fast, sees and charts far (2 chunks around), weak gun.
    name = "droid-scout", sheet = "rifle_run", anim_scale = DROID_SCALE,
    health = 150, regen = 0.6, speed = 0.2, vision = 40, radar_range = 2,
    resistances = {{"physical", 1, 20}, {"explosion", 5, 30}, {"acid", 1, 20}, fire_resist},
    attack = bullets(15, 12, 8, LIGHT_SHOT_SOUNDS, {-0.6, 1}),
  }),
  ground_droid({
    -- Sniper: long range, slow heavy shots, fragile.
    name = "droid-sniper", sheet = "rifle_run", anim_scale = DROID_SCALE,
    health = 50, regen = 0, speed = 0.08, vision = 35,
    resistances = light_resist,
    attack = bullets(150, 28, 90, RIFLE_SHOT_SOUNDS, {-0.6, 1}),
  }),
  ground_droid({
    -- Miner: rifle, lays land mines in battle (control script).
    name = "droid-miner", sheet = "rifle_run", anim_scale = DROID_SCALE,
    health = 120, regen = 0.6, speed = 0.09,
    resistances = light_resist,
    attack = bullets(60, 15, 15, RIFLE_SHOT_SOUNDS, {-0.6, 1}),
  }),

  -- Armoured infantry (battle droid model).
  ground_droid({
    name = "droid-smg", sheet = "smg_run",
    health = 250, regen = 0.6, speed = 0.11,
    resistances = armoured_resist,
    attack = bullets(20, 13, 12, HEAVY_SHOT_SOUNDS),
  }),
  ground_droid({
    -- Repair droid: restores the health of its squad (control script), light gun.
    name = "droid-repair", sheet = "smg_run",
    health = 250, regen = 1.2, speed = 0.11,
    resistances = armoured_resist,
    attack = bullets(20, 12, 5, LIGHT_SHOT_SOUNDS),
  }),
  ground_droid({
    -- Laser rifleman.
    name = "droid-laser", sheet = "smg_run",
    health = 250, regen = 0.6, speed = 0.1,
    resistances = {{"physical", 1, 40}, {"explosion", 5, 60}, {"acid", 1, 30}, {"laser", 2, 20}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = A.energy,
      cooldown = 30,
      projectile_center = {0, 0.5},
      projectile_creation_distance = 0.6,
      range = 18,
      sound = LASER_SOUNDS,
      ammo_type = projectile_ammo("droid-laser-bolt"),
    },
  }),
  ground_droid({
    -- Tesla droid: chain lightning, up to four jumps to enemies around the target.
    name = "droid-tesla", sheet = "smg_run",
    health = 250, regen = 0.6, speed = 0.1,
    resistances = {{"physical", 1, 40}, {"explosion", 5, 60}, {"acid", 1, 30}, {"electric", 5, 50}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = A.electric,
      cooldown = 60,
      projectile_center = {0, 0.5},
      projectile_creation_distance = 0.6,
      range = 14,
      ammo_type = {
        action = {
          type = "direct",
          action_delivery = {
            type = "instant",
            target_effects = {
              -- the chain goes first in case the beam kills the target
              {type = "nested-result", action = {type = "direct", action_delivery = {type = "chain", chain = "droid-tesla-chain"}}},
              {type = "nested-result", action = {type = "direct", action_delivery = {
                type = "beam", beam = "droid-tesla-beam", max_length = 16, duration = 20,
                add_to_shooter = false, destroy_with_source_or_target = false, source_offset = {0, -0.5},
              }}},
            },
          },
        },
      },
    },
  }),

  -- Heavy weapons (rocket droid model).
  ground_droid({
    name = "droid-rocket", sheet = "rocket_run",
    health = 200, regen = 0.6, speed = 0.11,
    resistances = {{"physical", 1, 40}, {"explosion", 5, 30}, {"acid", 1, 30}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = A.rocket,
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
    -- Chemical droid: throws poison capsules; the cloud hurts only what breathes (biters, not droids).
    name = "droid-poison", sheet = "rocket_run",
    health = 200, regen = 0.6, speed = 0.1,
    resistances = {{"physical", 1, 40}, {"explosion", 5, 30}, {"acid", 1, 30}, {"poison", nil, 100}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = "capsule",
      movement_slow_down_factor = 0.8,
      cooldown = 300,
      projectile_creation_distance = 1,
      range = 24,
      min_range = 8,
      projectile_center = {0.6, 1},
      sound = {{filename = "__base__/sound/fight/throw-projectile-1.ogg", volume = 0.6}},
      ammo_type = {
        target_type = "position",
        action = {
          type = "direct",
          action_delivery = {type = "projectile", projectile = "droid-poison-capsule", starting_speed = 0.4},
        },
      },
    },
  }),
  ground_droid({
    name = "droid-flame", sheet = "flame_run",
    health = 400, regen = 0.6, speed = 0.09,
    resistances = {{"physical", 5, 40}, {"explosion", 5, 70}, {"acid", 1, 30}, {"fire", nil, 95}},
    attack = {
      type = "stream",
      ammo_category = A.flame,
      damage_modifier = DAMAGE, -- the vanilla fire stream is not scaled otherwise
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

  -- Assault (terminator model).
  ground_droid({
    -- Heavy assault droid: slow armoured tank with a rapid heavy machine gun.
    name = "droid-heavy", sheet = "terminator_run",
    health = 900, regen = 1.2, speed = 0.07,
    resistances = {{"physical", 5, 75}, {"explosion", 20, 80}, {"acid", 3, 60}, {"laser", 2, 30}, fire_resist},
    attack = bullets(6, 14, 14, HEAVY_SHOT_SOUNDS, {0, 0.4}),
  }),
  ground_droid({
    name = "terminator", sheet = "terminator_run",
    health = 800, regen = 1.2, speed = 0.18,
    resistances = {{"physical", 1, 80}, {"explosion", 20, 90}, {"acid", 5, 85}, {"laser", 5, 35}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = A.energy,
      cooldown = 10,
      projectile_center = {0, 0.4},
      projectile_creation_distance = 1.5,
      range = 15,
      sound = LASER_SOUNDS,
      ammo_type = projectile_ammo("laser-dual"),
    },
  }),
  ground_droid({
    -- Plasma terminator: plasma bolts that also hit enemies around the target.
    name = "terminator-plasma", sheet = "terminator_run",
    health = 1200, regen = 1.8, speed = 0.16,
    resistances = {{"physical", 3, 80}, {"explosion", 20, 90}, {"acid", 8, 85}, {"laser", 8, 50}, fire_resist},
    attack = {
      type = "projectile",
      ammo_category = A.energy,
      cooldown = 45,
      projectile_center = {0, 0.4},
      projectile_creation_distance = 1.5,
      range = 18,
      sound = LASER_SOUNDS,
      ammo_type = projectile_ammo("droid-plasma-bolt"),
    },
  }),

  flying_droid({
    -- 5 defenders: 60 health, 8 physical every 20 ticks each
    name = "defender-unit", icon = "defender.png", order = "b-b-a", health = 300,
    collision_mask = {layers = {ghost = true}},
    resistances = {{"physical", 4}, {"acid", 1, 30}},
    animation = robot_sheet("defender-robot", 16,
      {56, 59, 0, 0.25}, {28, 21, 0, -4.75}, {88, 50, 25.5, 19}),
    attack = {
      type = "projectile",
      ammo_category = A.bullet,
      cooldown = 4,
      projectile_center = {0, 1},
      projectile_creation_distance = 0.6,
      range = 12,
      min_attack_distance = 8,
      sound = LIGHT_SHOT_SOUNDS,
      ammo_type = bullet_ammo(8),
    },
  }),
  flying_droid({
    -- 5 distractors: 90 health, 5 laser every 40 ticks each
    name = "distractor-unit", icon = "distractor.png", order = "b-b-b", health = 450,
    collision_box = {{0, 0}, {0, 0}},
    resistances = {{"physical", 4}, {"acid", 1, 30}},
    animation = robot_sheet("distractor-robot", 16,
      {72, 62, 0, -2.5}, {42, 37, 0, -6.25}, {96, 59, 32.5, 19.25}),
    attack = {
      type = "projectile",
      ammo_category = A.energy,
      cooldown = 8,
      damage_modifier = DAMAGE, -- the vanilla laser projectile is not scaled otherwise
      projectile_center = {0, 0.6},
      projectile_creation_distance = 0.6,
      range = 18,
      min_attack_distance = 12,
      sound = LASER_SOUNDS,
      ammo_type = projectile_ammo("laser"),
    },
  }),
  flying_droid({
    -- 5 destroyers: 60 health, 20 electric every 20 ticks each
    name = "destroyer-unit", icon = "destroyer.png", order = "b-b-c", health = 300,
    collision_box = {{0, 0}, {0, 0}},
    resistances = {{"physical", 8}, {"acid", 5, 70}},
    animation = robot_sheet("destroyer-robot", 32,
      {88, 77, 2.5, -1.25, y = 77}, {52, 42, 2.5, -7, y = 42}, {108, 66, 23.5, 19}),
    attack = {
      type = "beam",
      ammo_category = A.electric,
      cooldown = 20,
      damage_modifier = 5,
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

------------------------------------------------------------------------------------------
-- Projectiles, beams, chain lightning and corpse used by the droids.

local function electric_beam_graphics(tint)
  local body = {}
  for i = 1, 6 do
    body[i] = {
      filename = "__base__/graphics/entity/beam/beam-body-" .. i .. ".png",
      draw_as_glow = true, line_length = 16, width = 32, height = 39, frame_count = 16, tint = tint,
    }
  end
  return {
    beam = {
      start = {
        filename = "__base__/graphics/entity/beam/tileable-beam-START.png",
        draw_as_glow = true, line_length = 4, width = 94, height = 66, frame_count = 16,
        shift = {0.53125, 0}, scale = 0.5, tint = tint,
      },
      ending = {
        filename = "__base__/graphics/entity/beam/tileable-beam-END.png",
        draw_as_glow = true, line_length = 4, width = 91, height = 93, frame_count = 16,
        shift = {-0.078125, -0.046875}, scale = 0.5, tint = tint,
      },
      head = {
        filename = "__base__/graphics/entity/beam/beam-head.png",
        draw_as_glow = true, line_length = 16, width = 45 - 7, height = 39, frame_count = 16,
        shift = util.by_pixel(-7 / 2, 0), tint = tint,
      },
      tail = {
        filename = "__base__/graphics/entity/beam/beam-tail.png",
        draw_as_glow = true, line_length = 16, width = 45 - 6, height = 39, frame_count = 16,
        shift = util.by_pixel(6 / 2, 0), tint = tint,
      },
      body = body,
    },
  }
end

--- Electric beam that deals its damage once per attack (the attack triggers it).
local function electric_beam(name, damage, target_offset, tint)
  return {
    type = "beam",
    name = name,
    flags = {"not-on-map"},
    hidden = true,
    working_sound = {filename = "__base__/sound/fight/electric-beam.ogg", volume = 0.7},
    width = 0.5,
    damage_interval = 20,
    random_target_offset = true,
    target_offset = target_offset,
    action_triggered_automatically = false,
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {{type = "damage", damage = {amount = damage * DAMAGE, type = "electric"}}},
      },
    },
    graphics_set = electric_beam_graphics(tint),
  }
end

--- Explosion at the impact and `damage` to the enemies (not the droids) within `radius`.
local function area_hit(damage, damage_type, radius, effects)
  local out = {}
  for _, e in pairs(effects or {}) do out[#out + 1] = e end
  out[#out + 1] = {
    type = "nested-result",
    action = {
      type = "area",
      radius = radius,
      force = "enemy",
      action_delivery = {
        type = "instant",
        target_effects = {{type = "damage", damage = {amount = damage * DAMAGE, type = damage_type}}},
      },
    },
  }
  return {type = "direct", action_delivery = {type = "instant", target_effects = out}}
end

local rocket_pictures = require("__base__.prototypes.entity.rocket-projectile-pictures")

local laser_bolt = util.table.deepcopy(data.raw.projectile["laser"])
laser_bolt.name = "droid-laser-bolt"
laser_bolt.hidden = true
laser_bolt.action = {
  type = "direct",
  action_delivery = {
    type = "instant",
    target_effects = {
      {type = "create-entity", entity_name = "laser-bubble"},
      {type = "damage", damage = {amount = 20 * DAMAGE, type = "laser"}},
    },
  },
}

local TESLA_TINT = {r = 0.5, g = 1, b = 1}
local PLASMA_TINT = {r = 0.8, g = 0.3, b = 1.0}

data:extend({
  laser_bolt,
  {
    type = "projectile",
    name = "laser-dual",
    flags = {"not-on-map"},
    hidden = true,
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
    name = "droid-plasma-bolt",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0.01,
    action = area_hit(150, PLASMA, 1.5, {{type = "create-entity", entity_name = "laser-bubble"}}),
    light = {intensity = 0.8, size = 12, color = PLASMA_TINT},
    animation = {
      filename = shared.mod_path .. "/graphics/entity/laser/dual-laser.png",
      tint = PLASMA_TINT,
      frame_count = 1,
      width = 24,
      height = 33,
      priority = "high",
      blend_mode = "additive",
    },
  },
  {
    -- Poison capsule of the chemical droid: only the cloud (the vanilla capsule may also carry an
    -- area hit that would hurt the droids around the target).
    type = "projectile",
    name = "droid-poison-capsule",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0.005,
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {type = "create-entity", entity_name = "poison-cloud", show_in_tooltip = true},
      },
    },
    animation = {
      filename = "__base__/graphics/entity/poison-capsule/poison-capsule.png",
      draw_as_glow = true, frame_count = 16, line_length = 8, animation_speed = 0.25,
      width = 58, height = 59, shift = util.by_pixel(1, 0.5), priority = "high", scale = 0.5,
    },
    shadow = {
      filename = "__base__/graphics/entity/poison-capsule/poison-capsule-shadow.png",
      frame_count = 16, line_length = 8, animation_speed = 0.25,
      width = 54, height = 42, shift = util.by_pixel(1, 2), priority = "high", draw_as_shadow = true, scale = 0.5,
    },
    smoke = {{
      name = "poison-capsule-smoke", deviation = {0.15, 0.15}, frequency = 1, position = {0, 0},
      starting_frame = 3, starting_frame_deviation = 5,
    }},
  },
  {
    -- Rocket of the rocket droid: hits the enemies within 2 tiles of the impact.
    type = "projectile",
    name = "droid-explosive-rocket",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0.035,
    action = area_hit(275, "explosion", 2, {
      {type = "create-entity", entity_name = "explosion"},
      {type = "create-entity", entity_name = "small-scorchmark", check_buildability = true},
    }),
    light = {intensity = 0.5, size = 4},
    animation = rocket_pictures.animation({0.5, 1.0, 0.05}),
    shadow = rocket_pictures.shadow,
    smoke = rocket_pictures.smoke,
  },
  electric_beam("robot-electric-beam", 20, {0, -0.5}),
  electric_beam("droid-tesla-beam", 25, {0, -0.5}, TESLA_TINT),
  electric_beam("droid-tesla-beam-bounce", 25, {0, 0}, TESLA_TINT),
  {
    type = "chain-active-trigger",
    name = "droid-tesla-chain",
    max_jumps = 4,
    max_range_per_jump = 6,
    jump_delay_ticks = 6,
    fork_chance = 0,
    action = {
      type = "direct",
      action_delivery = {
        type = "beam",
        beam = "droid-tesla-beam-bounce",
        max_length = 6.5,
        duration = 20,
        add_to_shooter = false,
        destroy_with_source_or_target = false,
        source_offset = {0, 0},
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
