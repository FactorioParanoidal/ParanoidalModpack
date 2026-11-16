local shared = require("shared")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
require("__core__.lualib.sound-util")

local mode = settings.startup[shared.settings.graphics].value
local geometry = shared.graphics[mode] or shared.graphics.own
local path = shared.mod .. "/graphics/entity/droid-m-o/"
-- Rendered frames (tools: blender/mo_model.py) are centred 0.30 tiles above the floor, seen at Factorio's 45 degrees.
local own_shift = {0, -0.30 * 0.7071}

local function layer(spec)
  local sprite =
  {
    width = spec.size[1],
    height = spec.size[2],
    frame_count = spec.frames,
    line_length = spec.line_length or spec.frames,
    direction_count = spec.directions,
    shift = spec.shift,
    scale = spec.scale
  }
  if spec.files then
    -- A direction per line: one slice of all its frames (filenames need slice and lines_per_file).
    sprite.filenames = spec.files
    sprite.lines_per_file = spec.lines_per_file
    sprite.slice = spec.frames
  else
    sprite.filename = spec.file
  end
  if spec.shadow then
    sprite.draw_as_shadow = true
  end
  if spec.glow then
    sprite.draw_as_glow = true
    sprite.blend_mode = "additive"
  end
  return sprite
end

local function own(name, directions, frames)
  return
  {
    layers =
    {
      layer{file = path .. "own/" .. name .. ".png", size = {96, 96}, frames = frames, directions = directions, shift = own_shift, scale = 0.5},
      layer{file = path .. "own/" .. name .. "-shadow.png", size = {128, 96}, frames = frames, directions = directions,
            shift = {own_shift[1] + 0.25, own_shift[2]}, scale = 0.5, shadow = true},
      layer{file = path .. "own/" .. name .. "-glow.png", size = {96, 96}, frames = frames, directions = directions, shift = own_shift,
            scale = 0.5, glow = true}
    }
  }
end

-- Overlay: the Sweepbot's own chassis (recoloured into M-O's white and blue), with M-O's head on its top.
local chassis_shift = {0, 0.08 - 0.30}
local function overlay(name, directions, frames, lines_per_file)
  local file_count = math.ceil(directions / lines_per_file)
  local function files(stem)
    local list = {}
    for i = 1, file_count do
      list[i] = path .. "overlay/" .. stem .. "-" .. i .. ".png"
    end
    return list
  end
  local head = name == "run" and files("head") or {path .. "overlay/head-scrub.png"}
  local head_glow = name == "run" and files("head-glow") or {path .. "overlay/head-scrub-glow.png"}
  return
  {
    layers =
    {
      layer{files = files("chassis-" .. name), lines_per_file = lines_per_file, size = {256, 288}, frames = frames,
            directions = directions, shift = chassis_shift, scale = 0.25},
      layer{files = files("chassis-" .. name .. "-shadow"), lines_per_file = lines_per_file, size = {176, 144}, frames = frames,
            directions = directions, shift = {chassis_shift[1] + 0.375, chassis_shift[2]}, scale = 0.5, shadow = true},
      layer{files = files("chassis-" .. name .. "-glow"), lines_per_file = lines_per_file, size = {128, 144}, frames = frames,
            directions = directions, shift = chassis_shift, scale = 0.5, glow = true},
      layer{files = head, lines_per_file = lines_per_file, size = {96, 128}, frames = frames, directions = directions,
            shift = own_shift, scale = 0.5},
      layer{files = head_glow, lines_per_file = lines_per_file, size = {96, 128}, frames = frames, directions = directions,
            shift = own_shift, scale = 0.5, glow = true}
    }
  }
end

local run_animation, scrub_animation, distance_per_frame, step_frames
if mode == "overlay" then
  run_animation = overlay("run", 32, 6, 16)
  scrub_animation = overlay("scrub", 4, 14, 4)
  distance_per_frame = 0.02723
  step_frames = {1, 4}
else
  run_animation = own("run", 32, 8)
  scrub_animation = own("scrub", 4, 14)
  -- A quarter turn of his roller ball (radius 0.12) in 8 frames.
  distance_per_frame = 2 * math.pi * 0.12 / 4 / 8
  step_frames = {2, 6}
end

-- The siren that rises from his head at a contaminant: drawn by the script, so it can come and go; it turns while up.
data:extend
{
  {
    type = "animation",
    name = shared.siren,
    layers =
    {
      {filename = path .. "siren.png", size = 32, frame_count = 8, line_length = 8, scale = 0.5},
      {filename = path .. "siren-glow.png", size = 32, frame_count = 8, line_length = 8, scale = 0.5, draw_as_glow = true,
       blend_mode = "additive"}
    }
  }
}

-- The brush at the floor: footsteps in sand and grass, short enough to run into a scrub, under a synthesised buzz.
local scrub_sounds = make_sound_variations{filename = shared.mod .. "/sound/machine/brush", number_of_variations = 5, volume = 0.7}
for _, variation in pairs(make_sound_variations{filename = "__base__/sound/walking/decorative-grass", number_of_variations = 10, volume = 0.35}) do
  scrub_sounds[#scrub_sounds + 1] = variation
end

local empty_rotated_animation =
{
  filename = "__core__/graphics/empty.png",
  width = 1,
  height = 1,
  direction_count = 1
}

data:extend
{
  {
    -- Put on every unpaved tile in data-final-fixes.lua.
    type = "collision-layer",
    name = shared.unpaved
  },
  {
    type = "ammo-category",
    name = shared.ammo_category,
    hidden = true
  },
  {
    type = "unit",
    name = shared.bot,
    icon = shared.mod .. "/graphics/icons/droid-m-o.png",
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-in-kill-statistics"},
    hidden = true,
    max_health = 150,
    healing_per_tick = 0.02,
    collision_box = {{-shared.bot_size, -shared.bot_size}, {shared.bot_size, shared.bot_size}},
    -- A unit's usual mask, and the unpaved tiles: he keeps to the floors, as he kept to the Axiom's.
    collision_mask = {layers = {player = true, train = true, is_object = true, [shared.unpaved] = true}, not_colliding_with_itself = true},
    selection_box = {{-0.4, -0.45}, {0.4, 0.35}},
    sticker_box = {{-0.3, -0.3}, {0.3, 0.3}},
    map_color = {0.92, 0.92, 0.88},
    movement_speed = shared.movement_speed,
    distance_per_frame = distance_per_frame,
    rotation_speed = 0.025,
    distraction_cooldown = 300,
    vision_distance = 0,
    can_open_gates = true,
    -- The whir of his roller ball's motor, a short one per stride.
    walking_sound =
    {
      variations = make_sound_variations
      {
        filename = shared.mod .. "/sound/machine/roll",
        number_of_variations = 5,
        volume = 0.45,
        min_speed = 0.95,
        max_speed = 1.1
      },
      aggregation = {max_count = 1, remove = true, count_already_playing = true}
    },
    running_sound_animation_positions = step_frames,
    damaged_trigger_effect = hit_effects.entity(),
    dying_explosion = {"inserter-explosion", shared.death_cry},
    corpse = "small-remnants",
    -- His eyes: a little yellow glow round him at night.
    light = {minimum_darkness = 0.3, intensity = 0.22, size = 2.5, color = {1, 0.82, 0.35}},
    has_belt_immunity = true,
    affected_by_tiles = true,
    ai_settings =
    {
      do_separation = false,
      destroy_when_commands_fail = false,
      allow_try_return_to_spawner = false,
      join_attacks = false
    },
    run_animation = run_animation,
    -- The scrub sheet: frames 1-6 lean him in and lower the brush, 7-14 scrub with it. Only four directions: he pulls up
    -- square to what he cleans.
    alternative_attacking_frame_sequence =
    {
      warmup_frame_sequence = {1, 2, 3, 4, 5, 6},
      warmup2_frame_sequence = {7},
      attacking_frame_sequence = {7, 8, 9, 10, 11, 12, 13, 14},
      cooldown_frame_sequence = {7, 8, 9, 10, 11, 12, 13, 14},
      prepared_frame_sequence = {7, 8, 9, 10, 11, 12, 13, 14},
      back_to_walk_frame_sequence = {6, 5, 4, 3, 2, 1},
      -- A whole sequence per 1/speed ticks (as the spitters' are): 18 ticks to lean in, a stroke per 20.
      warmup_animation_speed = 1 / 18,
      attacking_animation_speed = 1 / 20,
      cooldown_animation_speed = 1 / 20,
      prepared_animation_speed = 1 / 20,
      back_to_walk_animation_speed = 1 / 14
    },
    attack_parameters =
    {
      type = "projectile",
      ammo_category = shared.ammo_category,
      -- Between collision boxes: the script parks him with the brush over the dirt, well inside this.
      range = 0.3,
      -- Frantic: about three strokes a second.
      cooldown = 20,
      -- The brush motor spinning up, the bristles at the floor, and spinning down.
      cyclic_sound =
      {
        begin_sound = {variations = make_sound_variations{filename = shared.mod .. "/sound/machine/brush-start", number_of_variations = 3, volume = 0.6}},
        middle_sound = {variations = scrub_sounds},
        end_sound = {variations = make_sound_variations{filename = shared.mod .. "/sound/machine/brush-stop", number_of_variations = 3, volume = 0.6}}
      },
      ammo_type =
      {
        target_type = "entity",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {type = "script", effect_id = shared.scrub_effect},
              -- A little dust off each stroke; the last of the dirt goes in a bigger puff (shared.dust).
              {
                type = "create-trivial-smoke",
                smoke_name = shared.dust_smoke,
                repeat_count = 2,
                offset_deviation = {{-0.3, -0.3}, {0.3, 0.3}},
                speed_from_center = 0.004
              }
            }
          }
        }
      },
      animation = scrub_animation
    }
  },
  {
    -- What he scrubs at: placed by the script on the contaminant (or kept on a dirty engineer).
    type = "unit",
    name = shared.proxy,
    icon = "__core__/graphics/empty.png",
    icon_size = 1,
    flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-in-kill-statistics", "not-repairable", "not-selectable-in-game"},
    hidden = true,
    max_health = 1000000,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    collision_mask = {layers = {}, colliding_with_tiles_only = true},
    movement_speed = 0,
    distance_per_frame = 1,
    distraction_cooldown = 0,
    vision_distance = 0,
    run_animation = empty_rotated_animation,
    attack_parameters =
    {
      type = "projectile",
      ammo_category = shared.ammo_category,
      range = 0,
      cooldown = 1,
      ammo_type = {target_type = "entity"},
      animation = empty_rotated_animation
    }
  }
}
