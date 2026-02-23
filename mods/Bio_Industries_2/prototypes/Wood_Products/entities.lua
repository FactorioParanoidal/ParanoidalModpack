local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local BioInd = require('common')('Bio_Industries_2')
local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local WOODPATH = BioInd.modRoot .. "/graphics/entities/wood_products/"
local REMNANTSPATH = BioInd.modRoot .. "/graphics/entities/remnants/"
local ENTITYPATH = "__base__/graphics/entity/"
local PIPEPATH = ENTITYPATH .. "pipe/"
local SNDPATH = "__base__/sound/"

local sounds = {}
sounds.walking_sound = {}
	for i = 1, 11 do
	  sounds.walking_sound[i] = {
		filename = SNDPATH .. "walking/concrete-" .. i ..".ogg",
		volume = 1.2
	  }
	end

-- Used for Wooden Pipe Pictures
pipepictures_w = function()
  return {
    straight_vertical_single = {
        filename = PIPEPATH .. "pipe-straight-vertical-single.png",
        priority = "extra-high",
        width = 160,
        height = 160,
        scale = 0.5
    },
    straight_vertical = {
        filename = PIPEPATH .. "pipe-straight-vertical.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    straight_vertical_window = {
        filename = PIPEPATH .. "pipe-straight-vertical-window.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    straight_horizontal_window = {
        filename = PIPEPATH .. "pipe-straight-horizontal-window.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    straight_horizontal = {
        filename = PIPEPATH .. "pipe-straight-horizontal.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    corner_up_right = {
        filename = PIPEPATH .. "pipe-corner-up-right.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    corner_up_left = {
        filename = PIPEPATH .. "pipe-corner-up-left.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    corner_down_right = {
        filename = PIPEPATH .. "pipe-corner-down-right.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    corner_down_left = {
        filename = PIPEPATH .. "pipe-corner-down-left.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    t_up = {
        filename = PIPEPATH .. "pipe-t-up.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    t_down = {
        filename = PIPEPATH .. "pipe-t-down.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    t_right = {
        filename = PIPEPATH .. "pipe-t-right.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    t_left = {
        filename = PIPEPATH .. "pipe-t-left.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    cross = {
        filename = PIPEPATH .. "pipe-cross.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    ending_up = {
        filename = PIPEPATH .. "pipe-ending-up.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    ending_down = {
        filename = PIPEPATH .. "pipe-ending-down.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    ending_right = {
        filename = PIPEPATH .. "pipe-ending-right.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    ending_left = {
        filename = PIPEPATH .. "pipe-ending-left.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    horizontal_window_background = {
        filename = PIPEPATH .. "pipe-horizontal-window-background.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    vertical_window_background = {
        filename = PIPEPATH .. "pipe-vertical-window-background.png",
        priority = "extra-high",
        size = 128,
        scale = 0.5
    },
    fluid_background = {
        filename = PIPEPATH .. "fluid-background.png",
        priority = "extra-high",
        width = 64,
        height = 40,
        scale = 0.5
    },
    low_temperature_flow = {
      filename = PIPEPATH .. "fluid-flow-low-temperature.png",
      priority = "extra-high",
      width = 160,
      height = 18
    },
    middle_temperature_flow = {
      filename = PIPEPATH .. "fluid-flow-medium-temperature.png",
      priority = "extra-high",
      width = 160,
      height = 18
    },
    high_temperature_flow = {
      filename = PIPEPATH .. "fluid-flow-high-temperature.png",
      priority = "extra-high",
      width = 160,
      height = 18
    },
    gas_flow = {
        filename = PIPEPATH .. "steam.png",
        priority = "extra-high",
        line_length = 10,
        width = 48,
        height = 30,
        frame_count = 60,
        axially_symmetrical = false,
        direction_count = 1
    }
  }
end

---- Wood Floor
data:extend({
  {
    type = "tile",
    name = "bi-wood-floor",
    needs_correction = false,
    minable = {hardness = 0.2, mining_time = 0.25, result = "wood"},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = { layers = { ground_tile = true } },
    walking_speed_modifier = 1.2,
    layer = 13,
    decorative_removal_probability = 1,
    variants = {
    transition = tile_graphics.generic_masked_tile_transitions1,
    main = {
        {
          picture = WOODPATH .. "wood_floor/woodfloor.png",
          count = 4,
          size = 1,
		  scale = 0.5
        },
      },
    inner_corner = {
        picture = WOODPATH .. "wood_floor/woodfloor_inner-corner.png",
        count = 4
      },
    outer_corner = {
        picture = WOODPATH .. "wood_floor/woodfloor_outer-corner.png",
        count = 4,
		scale = 0.5
      },
    side = {
        picture = WOODPATH .. "wood_floor/woodfloor_side.png",
        count = 4,
		scale = 0.5
      },
    u_transition = {
        picture = WOODPATH .. "wood_floor/woodfloor_u.png",
        count = 4,
		scale = 0.5
      },
    o_transition = {
        picture = WOODPATH .. "wood_floor/hr_woodfloor_o.png",
        count = 1,
		scale = 0.5
      }
    },
    walking_sound = sounds.walking_sound,
    map_color = {r = 139, g = 115, b = 85},
    vehicle_friction_modifier = dirt_vehicle_speed_modifer
  },
})

---- Big Wooden Pole
data:extend({
  {
    type = "electric-pole",
    name = "bi-wooden-pole-big",
	icons = { {icon = ICONPATH_E .. "big-wooden-pole.png", icon_size = 64, } },
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-wooden-pole-big"},
    max_health = 150,
    corpse = "bi-wooden-pole-big-remnant",
    resistances = {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "physical",
        percent = 10
      }
    },
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    drawing_box = {{-1, -6}, {1, 0.5}},
    maximum_wire_distance = 24,
    supply_area_distance = 1.5, -- This is the radius, so the supply area is 3x3.
    pictures = {
      filename = WOODPATH .. "big-wooden-pole-01.png",
      priority = "high",
      width = 180,
      height = 180,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {2.2, -2.5}
    },
    connection_points = {
      {
        shadow = {
          copper = {3.3, -0.1},
          green = {3.3, -0.2},
          red = {3.3, -0.3}
        },
         wire = {
          copper = {0.7, -4.3},
          green = {0.7, -4.3},
          red = {0.7, -4.3}
        }
      }
    },
    copper_wire_picture = {
      filename = ENTITYPATH .. "/small-electric-pole/copper-wire.png",
      priority = "extra-high-no-scale",
      width = 224,
      height = 46,
    },
    green_wire_picture = {
      filename = ENTITYPATH .. "/small-electric-pole/green-wire.png",
      priority = "extra-high-no-scale",
      width = 224,
      height = 46
    },
    red_wire_picture = {
      filename = ENTITYPATH .. "/small-electric-pole/red-wire.png",
      priority = "extra-high-no-scale",
      width = 224,
      height = 46
    },
    wire_shadow_picture = {
      filename = ENTITYPATH .. "/small-electric-pole/wire-shadow.png",
      priority = "extra-high-no-scale",
      width = 224,
      height = 46
    },
    radius_visualisation_picture = {
      filename = ENTITYPATH .. "/small-electric-pole/electric-pole-radius-visualization.png",
      width = 12,
      height = 12
    },
  },
  
  ---- corpse	  
	  {
	  type = "corpse",
	  name = "bi-wooden-pole-big-remnant",
	  localised_name = {"entity-name.bi-wooden-pole-big-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	  tile_width = 1,
	  tile_height = 1,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "big-wooden-pole_remnant.png",
		  line_length = 1,
		  width = 108,
		  height = 360,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0, -2.5},
		  scale = 0.5
		}
	  }
	},

})

---- Huge Wooden Pole
data:extend({
  {
    type = "electric-pole",
    name = "bi-wooden-pole-huge",
	icons = { {icon = ICONPATH_E .. "huge-wooden-pole.png", icon_size = 64, } },
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-wooden-pole-huge"},
    max_health = 250,
    corpse = "bi-wooden-pole-huge-remnant",
    resistances = {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "physical",
        percent = 10
      }
    },
    collision_box = {{-0.35, -0.35}, {0.25, 0.25}},
    selection_box = {{-0.55, -0.55}, {0.45, 0.45}},
    drawing_box = {{-1, -7}, {1, 0.5}},
    maximum_wire_distance = 64, -- Factorio Max
    supply_area_distance = 2,   -- This is the radius, so the supply area is 4x4.
    pictures = {
      filename = WOODPATH .. "huge-wooden-pole.png",
      priority = "high",
      width = 546,
      height = 501,
      direction_count = 4,
      shift = {3, -3.45},
      scale = 0.5,
    },
    connection_points = {
      {
        shadow = {
          copper = {5.7, -1.5},
          green = {4.8, -1.5},
          red = {6.6, -1.50}
        },
        wire = {
          copper = {0, -6.125},
          green = {-0.59375, -6.125},
          red = {0.625, -6.125}
        }
      },
      {
        shadow = {
          copper = {6.1, -1.3},
          green = {5.3, -1.8},
          red = {6.8, -0.9}
        },
        wire = {
          copper = {-0.0625, -6.125},
          green = {-0.5, -6.4375},
          red = {0.34375, -5.8125}
        }
      },
      {
        shadow = {
          copper = {5.9, -1.44},
          green = {6.0, -2.1},
          red = {6.0, -0.7}
        },
        wire = {
          copper = {-0.09375, -6.09375},
          green = {-0.09375, -6.53125},
          red = {-0.09375, -5.65625}
        }
      },
      {
        shadow = {
          copper = {6.1, -1.3},
          green = {6.8, -1.8},
          red = {5.35, -0.9}
        },
        wire = {
          copper = {-0.0625, -6.1875},
          green = {0.375, -6.5},
          red = {-0.46875, -5.90625}
        }
      }
    },
    radius_visualisation_picture = {
      filename = ENTITYPATH .. "/small-electric-pole/electric-pole-radius-visualization.png",
      width = 12,
      height = 12,
      priority = "extra-high-no-scale"
    },
  },
  
  ---- corpse
  {
  type = "corpse",
  name = "bi-wooden-pole-huge-remnant",
  localised_name = {"entity-name.bi-wooden-pole-huge-remnant"},
  icon = "__base__/graphics/icons/remnants.png",
  icon_size = 64,
  BI_add_icon = true,
  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
  subgroup = "remnants",
  order = "z-z-z",
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  tile_width = 1,
  tile_height = 1,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutes
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  animation =
  {
    {
      filename = REMNANTSPATH .. "huge_wooden_pole_remnant.png",
      line_length = 1,
      width = 128,
      height = 402,
      frame_count = 1,
      direction_count = 1,
      shift = {0, -2.76},
      scale = 0.5
    }
  }
},

})

---- Wood Fence
data:extend({
 {
    type = "wall",
    name = "bi-wooden-fence",
    icons = { {icon = ICONPATH_E .. "wooden-fence.png", icon_size = 64, } },
    flags = {"placeable-neutral", "player-creation"},
    collision_box = {{-0.29, -0.09}, {0.29, 0.49}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    minable = {mining_time = 1, result = "bi-wooden-fence"},
    fast_replaceable_group = "wall",
    max_health = 150,
    repair_speed_modifier = 2,
    corpse = "wall-remnants",
    repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
    impact_category = "wood",
    resistances = {
      {
        type = "physical",
        decrease = 2,
        percent = 15
      },
      {
        type = "fire",
        percent = -25
      },
      {
        type = "impact",
        decrease = 15,
        percent = 20
      }
    },
    pictures = {
      single = {
        layers = {
          {
            filename = WOODPATH .. "wood_fence/fence-single-1.png",
            priority = "extra-high",
            width = 7,
            height = 46,
            shift = {0, -0.15625}
          },
          {
            filename = WOODPATH .. "wood_fence/fence-single-shadow.png",
            priority = "extra-high",
            width = 38,
            height = 25,
            shift = {0.459375, 0.75},
            draw_as_shadow = true
          }
        }
      },
      straight_vertical = {
        {
          layers = {
            {
              filename = WOODPATH .. "wood_fence/fence-straight-vertical-1.png",
              priority = "extra-high",
              width = 7,
              height = 53,
              shift = {0, -0.15625}
            },
            {
              filename = WOODPATH .. "wood_fence/fence-straight-vertical-shadow.png",
              priority = "extra-high",
              width = 39,
              height = 66,
              shift = {0.490625, 1.425},
              draw_as_shadow = true
            }
          }
        },
        {
          layers = {
            {
              filename = WOODPATH .. "wood_fence/fence-straight-vertical-1.png",
              priority = "extra-high",
              width = 7,
              height = 53,
              shift = {0, -0.15625}
            },
            {
              filename = WOODPATH .. "wood_fence/fence-straight-vertical-shadow.png",
              priority = "extra-high",
              width = 39,
              height = 66,
              shift = {0.490625, 1.425},
              draw_as_shadow = true
            }
          }
        },
        {
          layers = {
            {
              filename = WOODPATH .. "wood_fence/fence-straight-vertical-1.png",
              priority = "extra-high",
              width = 7,
              height = 53,
              shift = {0, -0.15625}
            },
            {
              filename = WOODPATH .. "wood_fence/fence-straight-vertical-shadow.png",
              priority = "extra-high",
              width = 39,
              height = 66,
              shift = {0.490625, 1.425},
              draw_as_shadow = true
            }
          }
        }
      },
      straight_horizontal = {
        {
          layers = {
            {
              filename = WOODPATH .. "wood_fence/fence-straight-horizontal-1.png",
              priority = "extra-high",
              width = 34,
              height = 47,
              shift = {0, -0.15625}
            },
            {
              filename = WOODPATH .. "wood_fence/fence-straight-horizontal-shadow.png",
              priority = "extra-high",
              width = 84,
              height = 28,
              shift = {0.421875, 0.85},
              draw_as_shadow = true
            }
          }
        },
        {
          layers = {
            {
              filename = WOODPATH .. "wood_fence/fence-straight-horizontal-2.png",
              priority = "extra-high",
              width = 34,
              height = 47,
              shift = {0, -0.15625}
            },
            {
              filename = WOODPATH .. "wood_fence/fence-straight-horizontal-shadow.png",
              priority = "extra-high",
              width = 84,
              height = 28,
              shift = {0.421875, 0.85},
              draw_as_shadow = true
            }
          }
        },
        {
          layers = {
            {
              filename = WOODPATH .. "wood_fence/fence-straight-horizontal-3.png",
              priority = "extra-high",
              width = 34,
              height = 47,
              shift = {0, -0.15625}
            },
            {
              filename = WOODPATH .. "wood_fence/fence-straight-horizontal-shadow.png",
              priority = "extra-high",
              width = 84,
              height = 28,
              shift = {0.421875, 0.85},
              draw_as_shadow = true
            }
          }
        }
      },
      corner_right_down = {
        layers = {
          {
            filename = WOODPATH .. "wood_fence/fence-corner-right-down.png",
            priority = "extra-high",
            width = 23,
            height = 53,
            shift = {0.248125, -0.07625}
          },
          {
            filename = WOODPATH .. "wood_fence/fence-corner-right-down-shadow.png",
            priority = "extra-high",
            width = 52,
            height = 56,
            shift = {0.724375, 1.30625},
            draw_as_shadow = true
          }
        }
      },
      corner_left_down = {
        layers = {
          {
            filename = WOODPATH .. "wood_fence/fence-corner-left-down.png",
            priority = "extra-high",
            width = 21,
            height = 53,
            shift = {-0.248125, -0.07625}
          },
          {
            filename = WOODPATH .. "wood_fence/fence-corner-left-down-shadow.png",
            priority = "extra-high",
            width = 60,
            height = 56,
            shift = {0.128125, 1.30625},
            draw_as_shadow = true
          }
        }
      },
      t_up = {
        layers = {
          {
            filename = WOODPATH .. "wood_fence/fence-t-down.png",
            priority = "extra-high",
            width = 34,
            height = 53,
            shift = {0, -0.07625}
          },
          {
            filename = WOODPATH .. "wood_fence/fence-t-down-shadow.png",
            priority = "extra-high",
            width = 71,
            height = 55,
            shift = {0.286875, 1.280625},
            draw_as_shadow = true
          }
        }
      },
      ending_right = {
        layers = {
          {
            filename = WOODPATH .. "wood_fence/fence-ending-right.png",
            priority = "extra-high",
            width = 23,
            height = 47,
            shift = {0.248125, -0.15625}
          },
          {
            filename = WOODPATH .. "wood_fence/fence-ending-right-shadow.png",
            priority = "extra-high",
            width = 49,
            height = 27,
            shift = {0.684375, 0.85},
            draw_as_shadow = true
          }
        }
      },
      ending_left = {
        layers = {
          {
            filename = WOODPATH .. "wood_fence/fence-ending-left.png",
            priority = "extra-high",
            width = 21,
            height = 47,
            shift = {-0.248125, -0.15625}
          },
          {
            filename = WOODPATH .. "wood_fence/fence-ending-left-shadow.png",
            priority = "extra-high",
            width = 63,
            height = 27,
            shift = {0.128125, 0.85},
            draw_as_shadow = true
          }
        }
      }
    }
  },
  --- corpse
	  {
	  type = "corpse",
	  name = "bi-wooden-fence-remnant",
	  localised_name = {"entity-name.bi-wooden-fence-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	  tile_width = 1,
	  tile_height = 1,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "wooden_fence_remnant.png",
		  line_length = 1,
		  width = 128,
		  height = 128,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0, 0},
		  scale = 0.5
		}
	  }
	},
  
})

---- Wood Pipe
data:extend({
 {
    type = "pipe",
    name = "bi-wood-pipe",
	icons = { {icon = ICONPATH_E .. "wood_pipe.png", icon_size = 64, } },
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.075, result = "bi-wood-pipe"},
    max_health = 100,
    corpse = "bi-wood-pipe-remnant",
    resistances = {
      {
        type = "fire",
        percent = 20
      },
      {
        type = "impact",
        percent = 30
      }
    },
    fast_replaceable_group = "pipe",
    collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fluid_box = {
    volume = 100,
    pipe_connections = {
        { direction = defines.direction.north, position = {0, 0} },
        { direction = defines.direction.east, position = {0, 0} },
        { direction = defines.direction.south, position = {0, 0} },
        { direction = defines.direction.west, position = {0, 0} }
      },
    },
    pictures = pipepictures_w(),
    working_sound = {
      sound = {
        {
          filename = "__base__/sound/pipe.ogg",
          volume = 0.85
        },
      },
      match_volume_to_activity = true,
      max_sounds_per_type = 3
    },
    horizontal_window_bounding_box = {{-0.25, -0.28125}, {0.25, 0.15625}},
    vertical_window_bounding_box = {{-0.28125, -0.5}, {0.03125, 0.125}}
  },
  
  ---- corpse
  {
  type = "corpse",
  name = "bi-wood-pipe-remnant",
  localised_name = {"entity-name.bi-wood-pipe-remnant"},
  icon = "__base__/graphics/icons/remnants.png",
  icon_size = 64,
  icon_mipmaps = 4,
  BI_add_icon = true,
  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
  subgroup = "remnants",
  order = "z-z-z",
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  tile_width = 1,
  tile_height = 1,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutes
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  animation =
  {
    {
      filename = REMNANTSPATH .. "woodpipe_remnant.png",
      line_length = 1,
      width = 128,
      height = 128,
      frame_count = 1,
      direction_count = 1,
      shift = {0,0},
      scale = 0.5
    }
  }
},
  
  
})

---- Wood Pipe to Ground
data:extend({
  {
    type = "pipe-to-ground",
    name = "bi-wood-pipe-to-ground",
    icon = ICONPATH_E .. "pipe-to-ground-wood.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH_E .. "pipe-to-ground-wood.png",
        icon_size = 64,
      }
    },
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.075, result = "bi-wood-pipe-to-ground"},
    max_health = 150,
    corpse = "bi-wood-pipe-remnant",
    resistances = {
      {
        type = "fire",
        percent = 20
      },
      {
        type = "impact",
        percent = 40
      }
    },
    fast_replaceable_group = "pipe",
    collision_box = {{-0.29, -0.29}, {0.29, 0.2}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fluid_box = {
      volume = 100,
      pipe_covers = pipecoverspictures(),
      pipe_connections = {
        { direction = defines.direction.north, position = {0, 0} },
        {
          direction = defines.direction.south,
          position = {0, 0},
          connection_type = "underground",
          max_underground_distance = 10
        }
      },
    },
    underground_sprite = {
      filename = "__core__/graphics/arrows/underground-lines.png",
      priority = "extra-high-no-scale",
      size = 64,
      scale = 0.5
    },
        pictures = {
      north = {
          filename = ENTITYPATH .. "/pipe-to-ground/pipe-to-ground-up.png",
          priority = "extra-high",
          size = 128,
          scale = 0.5
      },
      south = {
          filename = ENTITYPATH .. "/pipe-to-ground/pipe-to-ground-down.png",
          priority = "extra-high",
          size = 128,
          scale = 0.5
      },
      west = {
          filename = ENTITYPATH .. "/pipe-to-ground/pipe-to-ground-left.png",
          priority = "extra-high",
          size = 128,
          scale = 0.5
      },
      east = {
          filename = ENTITYPATH .. "/pipe-to-ground/pipe-to-ground-right.png",
          priority = "extra-high",
          size = 128,
          scale = 0.5
      },
    },
  },
})