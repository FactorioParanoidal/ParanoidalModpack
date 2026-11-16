local shared = require("shared")
local util = require("util")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
require("__core__.lualib.sound-util")

local look = settings.startup[shared.settings.look].value
local L = shared.looks[look] or shared.looks.own
local path = shared.mod .. "/graphics/entity/nan-e/" .. look .. "/"

local empty_sprite = {filename = "__core__/graphics/empty.png", width = 1, height = 1}
local empty_rotated = {filename = "__core__/graphics/empty.png", width = 1, height = 1, direction_count = 1}

-- Her body: the own look is a 3D render (16 directions, 4 frames of the pulsing hover ring); the original look is
-- Informatron's picture, turned to face left or right (8 directions, still).
local run_animation, husk_picture
if look == "informatron" then
  run_animation =
  {
    filename = path .. "run.png",
    width = L.frame[1],
    height = L.frame[2],
    frame_count = 1,
    direction_count = L.directions,
    shift = {0, -0.42},
    scale = 0.5
  }
  husk_picture = {filename = path .. "offline.png", width = L.frame[1], height = L.frame[2], shift = {0, -0.3}, scale = 0.5}
else
  local shift = {0, -L.frame_z * 0.7071}
  run_animation =
  {
    layers =
    {
      {filename = path .. "run.png", width = L.frame[1], height = L.frame[2], frame_count = L.frames,
       direction_count = L.directions, shift = shift, scale = 0.5},
      {filename = path .. "run-shadow.png", width = L.shadow[1], height = L.shadow[2], frame_count = L.frames,
       direction_count = L.directions, shift = {shift[1] + (L.shadow[1] - L.frame[1]) / 2 / 64, shift[2]}, scale = 0.5,
       draw_as_shadow = true},
      {filename = path .. "run-glow.png", width = L.frame[1], height = L.frame[2], frame_count = L.frames,
       direction_count = L.directions, shift = shift, scale = 0.5, draw_as_glow = true, blend_mode = "additive"}
    }
  }
  husk_picture =
  {
    layers =
    {
      {filename = path .. "offline.png", width = 128, height = 96, shift = {0, -0.12}, scale = 0.5},
      {filename = path .. "offline-shadow.png", width = 160, height = 96, shift = {0.25, -0.12}, scale = 0.5,
       draw_as_shadow = true}
    }
  }
end

local icon = shared.mod .. "/graphics/icons/nan-e.png"

data:extend
{
  {
    type = "ammo-category",
    name = "nan-e-none",
    hidden = true
  },
  {
    type = "unit",
    name = shared.unit,
    icon = icon,
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-in-kill-statistics"},
    hidden = true,
    max_health = shared.max_health,
    healing_per_tick = 0.02,
    collision_box = {{-0.25, -0.25}, {0.25, 0.25}},
    -- She hovers over everything built and never blocks a building or the engineer's way; only water (and the edge of
    -- the map) stops her, as it stops him.
    collision_mask = {layers = {water_tile = true}, colliding_with_tiles_only = true},
    selection_box = {{-0.4, -1.0}, {0.4, 0.3}},
    sticker_box = {{-0.3, -0.3}, {0.3, 0.3}},
    map_color = {0.95, 0.62, 0.78},
    movement_speed = shared.movement_speed,
    distance_per_frame = 0.12,
    rotation_speed = 0.03,
    distraction_cooldown = 300,
    vision_distance = 0,
    can_open_gates = true,
    has_belt_immunity = true,
    affected_by_tiles = false,
    -- The soft hum of her hover ring.
    working_sound =
    {
      sound = {filename = shared.mod .. "/sound/machine/hover.ogg", volume = 0.18},
      max_sounds_per_prototype = 2,
      audible_distance_modifier = 0.4
    },
    damaged_trigger_effect = hit_effects.entity(),
    dying_explosion = "inserter-explosion",
    -- Her screen glows a little at night.
    light = {minimum_darkness = 0.3, intensity = 0.25, size = 3, color = {0.55, 0.9, 1}},
    ai_settings =
    {
      do_separation = false,
      destroy_when_commands_fail = false,
      allow_try_return_to_spawner = false,
      join_attacks = false
    },
    run_animation = run_animation,
    -- She never attacks: the defibrillator is the script's.
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "nan-e-none",
      range = 0,
      cooldown = 60,
      ammo_type = {target_type = "entity"},
      animation = empty_rotated
    }
  },
  {
    -- Switched off: found at the Axiom-6, knocked out by damage, or a new one just unpacked. Repaired to full health
    -- (repair packs or construction robots) she wakes up; the script makes her indestructible meanwhile.
    type = "simple-entity-with-owner",
    name = shared.husk,
    icon = icon,
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable",
             "not-rotatable", "not-upgradable"},
    max_health = shared.max_health,
    collision_box = {{-0.35, -0.3}, {0.35, 0.3}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    map_color = {0.95, 0.62, 0.78},
    render_layer = "object",
    damaged_trigger_effect = hit_effects.entity(),
    picture = husk_picture,
    placeable_by = {item = shared.item, count = 1}
  },
  {
    -- Her umbrella as paranoidal-rain sees it: a lightning attractor carried along with her (registered below).
    type = "simple-entity-with-owner",
    name = shared.rod,
    icon = shared.mod .. "/graphics/icons/nan-e.png",
    flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-selectable-in-game",
             "not-in-kill-statistics", "not-repairable"},
    hidden = true,
    max_health = 1000,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    collision_mask = {layers = {}},
    picture = empty_sprite
  },
  {
    -- The defibrillator's shock: the attacker stands still for four seconds. No damage.
    type = "sticker",
    name = shared.sticker,
    flags = {"not-on-map"},
    hidden = true,
    duration_in_ticks = 240,
    target_movement_modifier = 0,
    vehicle_speed_modifier = 0
  }
}

-- The colony's last camp: a crash-site chest of the base game, closed until she remembers the way.
local chest = data.raw.container["crash-site-chest-1"]
if chest then
  local capsule = util.table.deepcopy(chest)
  capsule.name = shared.capsule
  capsule.localised_name = nil
  capsule.localised_description = nil
  capsule.minable = nil
  capsule.inventory_size = 8
  capsule.flags = {"placeable-neutral", "not-deconstructable", "not-blueprintable", "not-rotatable"}
  capsule.hidden = true
  capsule.max_health = 2000
  capsule.icon = shared.mod .. "/graphics/icons/drawing.png"
  capsule.icon_size = 64
  capsule.icons = nil
  data:extend{capsule}
end

-- paranoidal-rain: her umbrella takes the lightning meant for the engineer next to her (and puts it out: "absorb").
local attractors = data.raw["mod-data"] and data.raw["mod-data"]["paranoidal-rain-attractors"]
if attractors then
  attractors.data.attractors = attractors.data.attractors or {}
  attractors.data.attractors[shared.rod] = {range = 10, priority = 900, mode = "absorb", self_damage = 0, energy_share = 0}
end
