-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Core Library
--     
-- See LICENSE.md in the project directory for license information.

-- Create target drone item
target_drone_item = util.copy(data.raw["item"]["logistic-robot"])
target_drone_item.name = "reskins-target-drone"
target_drone_item.place_result = "reskins-target-drone"
target_drone_item.flags = {"hidden"}
target_drone_item.icon = reskins.lib.directory.."/graphics/target-drone/target-drone-icon.png"
target_drone_item.icon_size = 64
target_drone_item.icon_mipmaps =  4
data:extend({target_drone_item})

-- Create target drone remnant
target_drone_remnant = util.copy(data.raw["corpse"]["logistic-robot-remnants"])
target_drone_remnant.name = "reskins-target-drone-remnants"
target_drone_remnant.icon = reskins.lib.directory.."/graphics/target-drone/target-drone-icon.png"
target_drone_remnant.icon_size = 64
target_drone_remnant.icon_mipmaps =  4
target_drone_remnant.animation = make_rotated_animation_variations_from_sheet (3,
{
    filename = reskins.lib.directory.."/graphics/target-drone/remnants/target-drone-remnants.png",
    line_length = 1,
    width = 58,
    height = 58,
    frame_count = 1,
    variation_count = 1,
    axially_symmetrical = false,
    direction_count = 1,
    shift = util.by_pixel(1, 1),
    hr_version =
    {
        filename = reskins.lib.directory.."/graphics/target-drone/remnants/hr-target-drone-remnants.png",
        line_length = 1,
        width = 116,
        height = 114,
        frame_count = 1,
        variation_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        shift = util.by_pixel(1, 1),
        scale = 0.5,
    },
})
data:extend({target_drone_remnant})

-- Create target drone entity
target_drone = util.copy(data.raw["logistic-robot"]["logistic-robot"])
target_drone.name = "reskins-target-drone"
target_drone.max_health = settings.startup["reskins-lib-target-drone-health"].value
target_drone.flags = {"placeable-enemy", "placeable-off-grid", "not-on-map", "hidden"}
target_drone.icon = reskins.lib.directory.."/graphics/target-drone/target-drone-icon.png"
target_drone.icon_size = 64
target_drone.icon_mipmaps = 4
target_drone.energy_per_tick = "0.00kJ"
target_drone.idle =
{
    filename = reskins.lib.directory.."/graphics/target-drone/target-drone.png",
    priority = "high",
    line_length = 16,
    width = 41,
    height = 42,
    frame_count = 1,
    shift = util.by_pixel(0, -3),
    direction_count = 16,
    y = 42,
    hr_version =
    {
        filename = reskins.lib.directory.."/graphics/target-drone/hr-target-drone.png",
        priority = "high",
        line_length = 16,
        width = 80,
        height = 84,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        y = 84,
        scale = 0.5
    }
}
target_drone.idle_with_cargo =
{
    filename = reskins.lib.directory.."/graphics/target-drone/target-drone.png",
    priority = "high",
    line_length = 16,
    width = 41,
    height = 42,
    frame_count = 1,
    shift = util.by_pixel(0, -3),
    direction_count = 16,
    hr_version =
    {
        filename = reskins.lib.directory.."/graphics/target-drone/hr-target-drone.png",
        priority = "high",
        line_length = 16,
        width = 80,
        height = 84,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        scale = 0.5
    }
}
target_drone.in_motion =
{
    filename = reskins.lib.directory.."/graphics/target-drone/target-drone.png",
    priority = "high",
    line_length = 16,
    width = 41,
    height = 42,
    frame_count = 1,
    shift = util.by_pixel(0, -3),
    direction_count = 16,
    y = 126,
    hr_version =
    {
        filename = reskins.lib.directory.."/graphics/target-drone/hr-target-drone.png",
        priority = "high",
        line_length = 16,
        width = 80,
        height = 84,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        y = 252,
        scale = 0.5
    }
}
target_drone.in_motion_with_cargo =
{
    filename = reskins.lib.directory.."/graphics/target-drone/target-drone.png",
    priority = "high",
    line_length = 16,
    width = 41,
    height = 42,
    frame_count = 1,
    shift = util.by_pixel(0, -3),
    direction_count = 16,
    y = 84,
    hr_version =
    {
        filename = reskins.lib.directory.."/graphics/target-drone/hr-target-drone.png",
        priority = "high",
        line_length = 16,
        width = 80,
        height = 84,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        y = 168,
        scale = 0.5
    }
}
data:extend({target_drone})

-- Create target drone dying particle
local shadow_shift = {-0.75, -0.40}
local animation_shift = {0, 0}

local adjust_animation = function(animation)

  local animation = util.copy(animation)
  local layers = animation.layers or {animation}

  for k, layer in pairs (layers) do

    layer.frame_count = layer.direction_count
    layer.direction_count = 0
    layer.animation_speed = 1
    layer.shift = util.add_shift(layer.shift, animation_shift)

    if layer.hr_version then
      layer.hr_version.frame_count = layer.hr_version.direction_count
      layer.hr_version.direction_count = 0
      layer.hr_version.animation_speed = 1
      layer.hr_version.shift = util.add_shift(layer.hr_version.shift, animation_shift)
    end

  end

  return animation
end

local adjust_shadow = function(shadow_animation)

  local shadow_animation = util.copy(shadow_animation)
  local layers = shadow_animation.layers or {shadow_animation}

  for k, layer in pairs (layers) do

    layer.frame_count = layer.direction_count
    layer.direction_count = 0
    layer.animation_speed = 1
    layer.shift = util.add_shift(layer.shift, shadow_shift)

    if layer.hr_version then
      layer.hr_version.frame_count = layer.hr_version.direction_count
      layer.hr_version.direction_count = 0
      layer.hr_version.animation_speed = 1
      layer.hr_version.shift = util.add_shift(layer.hr_version.shift, shadow_shift)
    end

  end

  return shadow_animation
end

local reversed = function(animation)
  local animation = util.copy(animation)
  local layers = animation.layers or {animation}

  for k, layer in pairs (layers) do
    layer.run_mode = "backward"
    if layer.hr_version then
      layer.hr_version.run_mode = "backward"
    end
  end

  return animation
end

target_drone = data.raw["logistic-robot"]["reskins-target-drone"]
local target_drone_animation = adjust_animation(target_drone.in_motion)
local target_drone_shadow_animation = adjust_shadow(target_drone.shadow_in_motion)

target_drone_dying_particle =
{
    type = "optimized-particle",
    name = "reskins-target-drone-dying-particle",
    pictures = {target_drone_animation, reversed(target_drone_animation)},
    shadows = {target_drone_shadow_animation, reversed(target_drone_shadow_animation)},
    movement_modifier = 0.95,
    life_time = 1000,
    regular_trigger_effect_frequency = 2,
    regular_trigger_effect =
    {
        {
            type = "create-trivial-smoke",
            smoke_name = "smoke-fast",
            starting_frame_deviation = 5,
            probability = 0.5
        },
        {
            type = "create-particle",
            particle_name = "spark-particle",
            tail_length = 10,
            tail_length_deviation = 5,
            tail_width = 5,
            probability = 0.2,
            initial_height = 0.2,
            initial_vertical_speed = 0.15,
            initial_vertical_speed_deviation = 0.05,
            speed_from_center = 0.1,
            speed_from_center_deviation = 0.05,
            offset_deviation = {{-0.25, -0.25},{0.25, 0.25}}
        }
    },
    ended_on_ground_trigger_effect =
    {
        type = "create-entity",
        entity_name = target_drone.name.."-remnants",
        offsets = {{0, 0}}
    }
}
data:extend({target_drone_dying_particle})

target_drone.dying_trigger_effect =
{
    {
        type = "create-particle",
        particle_name = "reskins-target-drone-dying-particle",
        initial_height = 1.8,
        initial_vertical_speed = 0,
        frame_speed = 1,
        frame_speed_deviation = 0.5,
        speed_from_center = 0,
        speed_from_center_deviation = 0.2,
        offset_deviation = {{-0.01, -0.01},{0.01, 0.01}},
        offsets = {{0, 0.5}}
    }
}