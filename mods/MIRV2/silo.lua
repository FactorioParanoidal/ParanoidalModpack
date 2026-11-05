-- Ballistic missile silo, ported from MIRV 2.1.0 (Klonan) into MIRV2 (Paranoidal decision 2026-11-05): the silo builds
-- one M.I.R.V at a time and fires it at the target of the targeting remote. The space platform part of 2.1.0 (orbital
-- launchers) is not ported. Its price in the build is set by zzzparanoidal (tweaks/recipe/mirv-silo.lua).
local util = require("tf_util/tf_util")
local shared = require("shared")
local sounds = require("__base__.prototypes.entity.sounds")

-- The silo uses the artillery turret base, and the missile rises out of the opening on top of it
local artillery_base = data.raw["artillery-turret"]["artillery-turret"].base_picture.layers

-- Centre of the opening, relative to the entity centre
local opening = {-0.19, -0.68}

-- Row of the artillery base image at the bottom edge of the opening, everything below it is drawn over the missile
local opening_bottom_row = 88
local opening_bottom = (opening_bottom_row - artillery_base[1].height / 2) * artillery_base[1].scale / 32

-- The missile is a cargo pod on its own, it is about 2.7 tiles tall
local pod_height = 172 * 0.5 / 32

-- When ready, this much of the missile is still inside the silo
local missile_sunk = 0.4

-- Missile centre when ready, and how far it rises to get there from fully inside the silo
local missile_ready = {opening[1], opening_bottom + missile_sunk - pod_height / 2}
local missile_rise = pod_height + 0.1

-- The rocket's flight effects are sized for the base rocket silo, scale them down to the missile
local effect_scale = 0.35

-- The engine draws the rocket higher than its offset and ignores the horizontal offset, measured from screenshots
local rocket_draw_offset = {opening[1], 1.6}

-- The engine also moves the rocket's shadow, this puts it at the foot of the missile, measured from screenshots
local rocket_shadow_offset = {rocket_draw_offset[1] - 2.6, rocket_draw_offset[2] - 2.6}

local silo_icons =
{
  {
    icon = "__base__/graphics/icons/rocket-silo.png",
    tint = {r = 1, g = 0.75, b = 0.7}
  }
}

data:extend
{
  {
    type = "recipe-category",
    name = shared.crafting_category
  }
}

local empty_animation = function()
  local sprite = util.empty_sprite()
  sprite.direction_count = nil
  return sprite
end

-- The rocket's graphics already are the cargo pod, so the real one is never drawn
local cargo_pod = util.copy(data.raw["cargo-pod"]["cargo-pod"])
cargo_pod.name = shared.cargo_pod
cargo_pod.hidden = true
cargo_pod.factoriopedia_simulation = nil
for k, entry in pairs (cargo_pod.procession_graphic_catalogue) do
  if entry.sprite then entry.sprite = empty_animation() end
  if entry.animation then entry.animation = empty_animation() end
end

local rocket_shadow = util.copy(data.raw["rocket-silo-rocket-shadow"]["rocket-silo-rocket-shadow"])
rocket_shadow.name = shared.silo_rocket .. "-shadow"
-- The shadow is drawn within this box, which reaches out to the right as the missile rises
rocket_shadow.collision_box = {{0, 0}, {10, 3.5}}

local rocket = util.copy(data.raw["rocket-silo-rocket"]["rocket-silo-rocket"])
rocket.name = shared.silo_rocket
rocket.shadow_slave_entity = rocket_shadow.name
rocket.cargo_pod_entity = cargo_pod.name
rocket.collision_box = {{-0.6, -1.4}, {0.6, 1.4}}
rocket.rocket_initial_offset = {0, missile_ready[2] + missile_rise}
rocket.rocket_rise_offset = {0, -missile_rise}
rocket.rising_speed = 1 / (2 * 60)
rocket.engine_starting_speed = 1 / (1.5 * 60)
rocket.flying_acceleration = rocket.flying_acceleration * 4
rocket.flying_sound = nil
rocket.cargo_attachment_offset = {0, 0}
rocket.rocket_visible_distance_from_center = missile_ready[2] + missile_rise - 0.1
rocket.rocket_render_layer_switch_distance = rocket.rocket_render_layer_switch_distance * effect_scale
rocket.full_render_layer_switch_distance = rocket.full_render_layer_switch_distance * effect_scale
rocket.effects_fade_in_start_distance = rocket.effects_fade_in_start_distance * effect_scale
rocket.effects_fade_in_end_distance = rocket.effects_fade_in_end_distance * effect_scale
rocket.rocket_above_wires_slice_offset_from_center = rocket.rocket_above_wires_slice_offset_from_center * effect_scale
rocket.rocket_air_object_slice_offset_from_center = rocket.rocket_air_object_slice_offset_from_center * effect_scale

-- Scale the smoke, glare and glow first, then replace the rocket itself with the cargo pod
rocket.rocket_sprite = nil
rocket.rocket_shadow_sprite = nil
rocket.rocket_flame_animation = nil
rocket.rocket_smoke_top1_animation = nil
rocket.rocket_smoke_top2_animation = nil
rocket.rocket_smoke_top3_animation = nil
rocket.rocket_smoke_bottom1_animation = nil
rocket.rocket_smoke_bottom2_animation = nil
rocket.glow_light = nil
rocket.rocket_glare_overlay_sprite = nil
util.scale_graphics(rocket, effect_scale)

rocket.rocket_sprite = util.sprite_load("__base__/graphics/entity/cargo-pod/pod-static-detached", {scale = 0.5, shift = rocket_draw_offset})
rocket.rocket_shadow_sprite = util.sprite_load("__base__/graphics/entity/cargo-pod/pod-static-shadow",
{
  scale = 0.5,
  shift = rocket_shadow_offset,
  draw_as_shadow = true
})
-- The cargo pod's own thruster, placed the same as in its procession graphics
rocket.rocket_flame_animation = util.sprite_load("__base__/graphics/entity/cargo-pod/pod-thruster-loop",
{
  scale = 0.25,
  shift = {rocket_draw_offset[1], rocket_draw_offset[2] + 2},
  draw_as_glow = true,
  blend_mode = "additive",
  frame_count = 10,
  animation_speed = 0.5
})

local silo = util.copy(data.raw["rocket-silo"]["rocket-silo"])
silo.name = shared.silo
silo.icon = nil
silo.icons = silo_icons
silo.minable = {mining_time = 1, result = shared.silo}
silo.fast_replaceable_group = nil
silo.factoriopedia_simulation = nil
silo.crafting_categories = {shared.crafting_category}
silo.fixed_recipe = shared.missile
silo.show_recipe_icon = false
-- One craft makes one missile, and nothing is crafted while a missile is waiting in the silo
silo.rocket_parts_required = 1
silo.rocket_parts_storage_cap = 0
silo.to_be_inserted_to_rocket_inventory_size = 0
silo.launch_to_space_platforms = false
silo.can_launch_without_landing_pads = true
silo.logistic_trash_inventory_size = 0
silo.robot_door = nil
silo.rocket_entity = rocket.name
silo.module_slots = 2
silo.allowed_effects = {"consumption", "speed", "pollution"}
silo.max_health = 2500
silo.corpse = "artillery-turret-remnants"
silo.dying_explosion = "artillery-turret-explosion"
silo.energy_usage = "150kW"
silo.active_energy_usage = "1MW"
silo.collision_box = {{-1.2, -1.2}, {1.2, 1.2}}
silo.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}

-- The rocket silo's sounds are too grand for a single missile
silo.working_sound = nil
silo.alarm_sound = nil
silo.quick_alarm_sound = nil
silo.clamps_on_sound = nil
silo.clamps_off_sound = nil
silo.doors_sound = nil
silo.raise_rocket_sound = nil
silo.open_sound = sounds.turret_open
silo.close_sound = sounds.turret_close

-- A much quicker launch sequence, the lights and doors it waits for aren't drawn anyway
silo.times_to_blink = 1
silo.light_blinking_speed = 1 / 30
silo.door_opening_speed = 1 / 30
silo.rocket_rising_delay = 10
silo.launch_wait_time = 30

-- Graphics: the artillery turret base, and nothing of the rocket silo's doors, arms or lights
silo.graphics_set = nil
silo.base_day_sprite = util.copy(artillery_base[1])
silo.shadow_sprite = util.copy(artillery_base[2])
silo.base_night_sprite = nil
-- The front of the base, so the bottom of the missile is hidden behind the rim of the opening
local base_layer = artillery_base[1]
local front_height = base_layer.height - opening_bottom_row
silo.base_front_sprite = util.copy(base_layer)
silo.base_front_sprite.y = opening_bottom_row
silo.base_front_sprite.height = front_height
silo.base_front_sprite.shift =
{
  0,
  (opening_bottom_row + front_height / 2 - base_layer.height / 2) * base_layer.scale / 32
}
silo.hole_sprite = nil
silo.hole_light_sprite = nil
silo.door_back_sprite = nil
silo.door_front_sprite = nil
silo.door_back_open_offset = {0, 0}
silo.door_front_open_offset = {0, 0}
silo.rocket_shadow_overlay_sprite = nil
silo.rocket_glow_overlay_sprite = nil
silo.red_lights_back_sprites = nil
silo.red_lights_front_sprites = nil
silo.satellite_animation = nil
silo.arm_01_back_animation = nil
silo.arm_02_right_animation = nil
silo.arm_03_front_animation = nil
silo.base_light = nil
silo.base_engine_light = nil

-- While in the silo the missile is only drawn above the bottom edge of the opening
silo.hole_clipping_box = {{opening[1] - 1.5, opening[2] - 4}, {opening[1] + 1.5, opening_bottom}}
silo.silo_fade_out_start_distance = silo.silo_fade_out_start_distance * effect_scale
silo.silo_fade_out_end_distance = silo.silo_fade_out_end_distance * effect_scale
silo.icon_draw_specification = {shift = {0, 0.5}}
silo.icons_positioning =
{
  {inventory_index = defines.inventory.crafter_modules, shift = {0, 1}}
}

local silo_item =
{
  type = "item",
  name = shared.silo,
  icons = silo_icons,
  subgroup = "defensive-structure",
  order = "z[MIRV]-a[silo]",
  place_result = shared.silo,
  stack_size = 5
}

local silo_recipe =
{
  type = "recipe",
  name = shared.silo,
  energy_required = 30,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "concrete", amount = 200},
    {type = "item", name = "steel-plate", amount = 200},
    {type = "item", name = "electric-engine-unit", amount = 50},
    {type = "item", name = "processing-unit", amount = 50},
    {type = "item", name = "pipe", amount = 50}
  },
  results = {{type = "item", name = shared.silo, amount = 1}}
}

data:extend
{
  cargo_pod,
  rocket_shadow,
  rocket,
  silo,
  silo_item,
  silo_recipe
}
