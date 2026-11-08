local function make_visualization(i)
  return
  {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/visualization.png",
    priority = "extra-high",
    x = i * 64,
    size = 64,
    scale = 0.5,
    flags = {"icon"},
    draw_as_glow = true,
  }
end

local function make_disabled_visualization(i)
  return
  {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/disabled-visualization.png",
    priority = "extra-high",
    x = i * 64,
    size = 64,
    scale = 0.5,
    flags = {"icon"},
    draw_as_glow = true,
  }
end

opticalfiberpictures = function()
  return
  {
    straight_vertical_single =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-straight-vertical-single.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 160,
      height = 160,
      scale = 0.5
    },
    straight_vertical =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-straight-vertical.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    straight_vertical_window =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-straight-vertical-window.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    straight_horizontal_window =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-straight-horizontal-window.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    straight_horizontal =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-straight-horizontal.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    corner_up_right =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-corner-up-right.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    corner_up_left =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-corner-up-left.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    corner_down_right =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-corner-down-right.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    corner_down_left =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-corner-down-left.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    t_up =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-t-up.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    t_down =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-t-down.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    t_right =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-t-right.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    t_left =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-t-left.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    cross =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-cross.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    ending_up =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-ending-up.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    ending_down =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-ending-down.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    ending_right =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-ending-right.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    ending_left =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-ending-left.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    straight_vertical_single_visualization = make_visualization(0),
    straight_vertical_visualization = make_visualization(5),
    straight_vertical_window_visualization = make_visualization(5),
    straight_horizontal_window_visualization = make_visualization(10),
    straight_horizontal_visualization = make_visualization(10),
    corner_up_right_visualization = make_visualization(3),
    corner_up_left_visualization = make_visualization(9),
    corner_down_right_visualization = make_visualization(6),
    corner_down_left_visualization = make_visualization(12),
    t_up_visualization = make_visualization(11),
    t_down_visualization = make_visualization(14),
    t_right_visualization = make_visualization(7),
    t_left_visualization = make_visualization(13),
    cross_visualization = make_visualization(15),
    ending_up_visualization = make_visualization(1),
    ending_down_visualization = make_visualization(4),
    ending_right_visualization = make_visualization(2),
    ending_left_visualization = make_visualization(8),
    straight_vertical_single_disabled_visualization = make_disabled_visualization(0),
    straight_vertical_disabled_visualization = make_disabled_visualization(5),
    straight_vertical_window_disabled_visualization = make_disabled_visualization(5),
    straight_horizontal_window_disabled_visualization = make_disabled_visualization(10),
    straight_horizontal_disabled_visualization = make_disabled_visualization(10),
    corner_up_right_disabled_visualization = make_disabled_visualization(3),
    corner_up_left_disabled_visualization = make_disabled_visualization(9),
    corner_down_right_disabled_visualization = make_disabled_visualization(6),
    corner_down_left_disabled_visualization = make_disabled_visualization(12),
    t_up_disabled_visualization = make_disabled_visualization(11),
    t_down_disabled_visualization = make_disabled_visualization(14),
    t_right_disabled_visualization = make_disabled_visualization(7),
    t_left_disabled_visualization = make_disabled_visualization(13),
    cross_disabled_visualization = make_disabled_visualization(15),
    ending_up_disabled_visualization = make_disabled_visualization(1),
    ending_down_disabled_visualization = make_disabled_visualization(4),
    ending_right_disabled_visualization = make_disabled_visualization(2),
    ending_left_disabled_visualization = make_disabled_visualization(8),
    horizontal_window_background =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-straight-horizontal-window-background.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    vertical_window_background =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-straight-vertical-window-background.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    fluid_background =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/fluid-background-new.png",
      flags = {"low-object"},
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    },
    low_temperature_flow = nil,
    --[[{
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/fluid-flow.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      scale = 0.5,
    },]]
    middle_temperature_flow = nil,
    --[[{
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/fluid-flow.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      scale = 0.5,
    },]]
    high_temperature_flow = nil,
    --[[{
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/fluid-flow.png",
      priority = "extra-high",
      width = 320,
      height = 1,
      scale = 0.5,
    },]]
    gas_flow =
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/fluid-flow.png",
      flags = {"low-object"},
      priority = "extra-high",
      scale = 12,
      line_length = 250,
      width = 1,
      height = 1,
      --shift = util.by_pixel(3,3),
      frame_count = 250,
      animation_speed = 400,
    },
  }
end

opticalfibercoverspictures = function()
  return
  {
    north =
    {
      layers =
      {
        {
          filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-cover-north.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
      }
    },
    east =
    {
      layers =
      {
        {
          filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-cover-east.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
      }
    },
    south =
    {
      layers =
      {
        {
          filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-cover-south.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
      }
    },
    west =
    {
      layers =
      {
        {
          filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber-cover-west.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
      }
    }
  }
end

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require ("__space-age__.prototypes.entity.sounds")

data:extend({
  {
    type = "corpse",
    name = "opticalfiber-remnants",
    icon = "__Moshine__/graphics/icons/optical-fiber.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "energy-pipe-distribution-remnants",
    order = "a-d-a",
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = make_rotated_animation_variations_from_sheet(2,
    {
      filename = "__Moshine-assets__/graphics/entity/opticalfiber/remnants/opticalfiber-remnants.png",
      width = 122,
      height = 120,
      line_length = 1,
      direction_count = 2,
      shift = util.by_pixel(1.5, 2.5), -- -0,5
      scale = 0.5
    })
  },

  {
    type = "pipe",
    name = "optical-cable",
    icon = "__Moshine__/graphics/icons/optical-fiber.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "optical-cable"},
    max_health = 10,
    corpse = "opticalfiber-remnants",
    dying_explosion = "pipe-explosion",
    icon_draw_specification = {scale = 0},
    resistances =
    {
      {
        type = "fire",
        percent = 30
      },
      {
        type = "impact",
        percent = 50
      }
    },
    fast_replaceable_group = "optical-cable",
    collision_box = {{-0.01, -0.01}, {0.01, 0.01}},
    selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
    damaged_trigger_effect = hit_effects.entity(),
    fluid_box =
    {
      volume = 100,
      pipe_covers = opticalfibercoverspictures(), -- in case a real pipe is connected to a ghost
      --filter = "raw-data",
      pipe_connections =
      {
        { direction = defines.direction.north, position = {0, 0}, connection_category = "data", hide_connection_info = true },
        { direction = defines.direction.east, position = {0, 0}, connection_category = "data", hide_connection_info = true },
        { direction = defines.direction.south, position = {0, 0}, connection_category = "data", hide_connection_info = true },
        { direction = defines.direction.west, position = {0, 0}, connection_category = "data", hide_connection_info = true }
      },
      max_pipeline_extent = 1000000,
      --render_layer = "decals",
    },
    impact_category = "glass",
    pictures = opticalfiberpictures(),
    --working_sound = sounds.pipe,
    open_sound = sounds.metal_small_open,
    close_sound = sounds.metal_small_close,

    --horizontal_window_bounding_box = {{-0.25, -0.28125}, {0.25, 0.15625}},
    --vertical_window_bounding_box = {{-0.28125, -0.5}, {0.03125, 0.125}}

    horizontal_window_bounding_box = {util.by_pixel(-7, -3.5), util.by_pixel(7, 3)},
    vertical_window_bounding_box = {util.by_pixel(-3, -5), util.by_pixel(4,4)}
  },
})