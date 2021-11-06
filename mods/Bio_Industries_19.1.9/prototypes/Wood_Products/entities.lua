-- Wood Floor
data:extend({
  {
    type = "tile",
    name = "bi-wood-floor",
    minable = {hardness = 0.2, mining_time = 0.25, result = "wood"},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = {"ground-tile"},
    walking_speed_modifier = 1.2,
    layer = 62,
    decorative_removal_probability = 0.6,
    variants = {
      main =
      {
        {
          picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
          count = 1,
          size = 1
        },
        {
          picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
          count = 1,
          size = 2,
          probability = 0.39
        },
        {
          picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
          count = 1,
          size = 4,
          probability = 1
        }
      },
      inner_corner =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_inner-corner.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_inner-corner.png",
          count = 1,
          scale = 0.5,
        }
      },
      inner_corner_mask =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_inner-corner-mask.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_inner-corner-mask.png",
          count = 1,
          scale = 0.5,
        }
      },
      outer_corner =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_outer-corner.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_outer-corner.png",
          count = 1,
          scale = 0.5,
        }
      },
      outer_corner_mask =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_outer-corner-mask.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_outer-corner-mask.png",
          count = 1,
          scale = 0.5,
        }
      },
      side =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_side.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_side.png",
          count = 1,
          scale = 0.5,
        }
      },
      side_mask =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_side-mask.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_side-mask.png",
          count = 1,
          scale = 0.5,
        }
      },
      u_transition =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_u.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_u.png",
          count = 1,
          scale = 0.5,
        }
      },
      u_transition_mask =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_u-mask.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_u-mask.png",
          count = 1,
          scale = 0.5,
        }
      },
      o_transition =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_o.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_o.png",
          count = 1,
          scale = 0.5,
        }
      },
      o_transition_mask =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor_o-mask.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor_o-mask.png",
          count = 1,
          scale = 0.5,
        }
      },
      material_background =
      {
        picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/woodfloor.png",
        count = 1,
        hr_version =
        {
          picture = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_floor/hr_woodfloor.png",
          count = 1,
          scale = 0.5,
        }
      },
    },
    walking_sound = 
    {
      {filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/sound/walking/wood-01.ogg", volume = 1.2},
      {filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/sound/walking/wood-02.ogg", volume = 1.2},
      {filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/sound/walking/wood-03.ogg", volume = 1.2},
      {filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/sound/walking/wood-04.ogg", volume = 1.2},
    },
    map_color = {r = 139, g = 115, b = 85},
    pollution_absorption_per_second = 0,
    vehicle_friction_modifier = 0.9,
},
})
--###############################################################################################
-- Big Wooden Pole
data:extend({
  {
    type = "electric-pole",
    name = "bi-wooden-pole-big",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_pole_big.png",
    icon_size = 64, icon_mipmaps = 3,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-wooden-pole-big"},
    max_health = 150,
    --corpse = "bi-wooden-pole-big-remnant",
    corpse = "medium-remnants",
    resistances = 
    {
      {type = "fire", percent = 100},
      {type = "physical", percent = 10}
    },
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    drawing_box = {{-1, -6}, {1, 0.5}},
    maximum_wire_distance = 24,
    supply_area_distance = 1.5, -- This is the radius, so the supply area is 3x3.
    pictures = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/poles/big-wooden-pole-01.png",
          priority = "high",
          width = 54,
          height = 180,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(0, -80),
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/poles/hr_big-wooden-pole-01.png",
            priority = "high",
            width = 108,
            height = 360,
            axially_symmetrical = false,
            direction_count = 1,
            scale = 0.5,
            shift = util.by_pixel(0, -80),
          },
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/poles/big-wooden-pole-01_shadow.png",
          priority = "high",
          width = 180,
          height = 20,
          axially_symmetrical = false,
          direction_count = 1,
          shift = util.by_pixel(70, 0),
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/poles/hr_big-wooden-pole-01_shadow.png",
            priority = "high",
            width = 360,
            height = 40,
            axially_symmetrical = false,
            direction_count = 1,
            scale = 0.5,
            shift = util.by_pixel(70, 0),
            draw_as_shadow = true,
          },
        },
      },
    },
    connection_points = 
    {{
      shadow = {copper = {3.3, -0}, green = {3.2, -0}, red = {3.1, -0}},
      wire = {copper = util.by_pixel(24, -134), green = util.by_pixel(18, -133), red = util.by_pixel(11, -131),}      
    }},
      copper_wire_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/copper-wire.png",
      priority = "extra-high-no-scale",
      width = 224,
      height = 46,
    },
    green_wire_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/green-wire.png",
      priority = "extra-high-no-scale",
      width = 224,
      height = 46
    },
    red_wire_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/red-wire.png",
      priority = "extra-high-no-scale",
      width = 224,
      height = 46
    },
    wire_shadow_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/wire-shadow.png",
      priority = "extra-high-no-scale",
      width = 224,
      height = 46
    },
    radius_visualisation_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
      width = 12,
      height = 12
    },
  }
})
--###############################################################################################
-- Huge Wooden Pole
data:extend({
  {
    type = "electric-pole",
    name = "bi-wooden-pole-huge",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_pole_huge.png",
    icon_size = 64, icon_mipmaps = 3,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-wooden-pole-huge"},
    max_health = 250,
    --corpse = "bi-wooden-pole-huge-remnant",
    corpse = "medium-remnants",
    resistances = 
    {
      {type = "fire", percent = 100},
      {type = "physical", percent = 10}
    },
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    drawing_box = {{-1, -7}, {1, 0.5}},
    maximum_wire_distance = 64,
    supply_area_distance = 1,   -- This is the radius, so the supply area is 2x2.
    pictures = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/poles/huge_wooden_pole.png",
          priority = "high",
          width = 64,
          height = 201,
          direction_count = 4,
          shift = util.by_pixel(0, -88),
          scale = 1,
          hr_version ={
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/poles/hr_huge_wooden_pole.png",
            priority = "high",
            width = 128,
            height = 402,
            direction_count = 4,
            shift = util.by_pixel(0, -88),
            scale = 0.5,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/poles/huge_wooden_pole_shadow.png",
          priority = "high",
          width = 219,
          height = 49,
          direction_count = 4,
          shift = util.by_pixel(83, 0),
          scale = 1,
          draw_as_shadow = true,
          hr_version ={
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/poles/hr_huge_wooden_pole_shadow.png",
            priority = "high",
            width = 438,
            height = 97,
            direction_count = 4,
            shift = util.by_pixel(83, 0),
            scale = 0.5,
            draw_as_shadow = true,
          }
        },
      },
    },
    connection_points = {
      {
        shadow = {
          copper = util.by_pixel(169, 5),
          green = util.by_pixel(154, 5),
          red = util.by_pixel(186, 5),
        },
        wire = {
          copper = util.by_pixel(0, -162),
          green = util.by_pixel(-24, -162),
          red = util.by_pixel(24, -162),
        }
      },
      {
        shadow = {
          copper = util.by_pixel(159, 2),
          green = util.by_pixel(156, -10),
          red = util.by_pixel(175, 15),
        },
        wire = {
          copper = util.by_pixel(-4, -163),
          green = util.by_pixel(-22, -171),
          red = util.by_pixel(15, -155),
        }
      },
      {
        shadow = {
          copper = util.by_pixel(173, 0),
          green = util.by_pixel(174, 17),
          red = util.by_pixel(171, -17),
        },
        wire = {
          copper = util.by_pixel(8, -166),
          green = util.by_pixel(8, -151),
          red = util.by_pixel(8, -182),
        }
      },
      {
        shadow = {
          copper = util.by_pixel(173, 2.5),
          green = util.by_pixel(166, 16),
          red = util.by_pixel(180, -11),
        },
        wire = {
          copper = util.by_pixel(5, -163),
          green = util.by_pixel(-13, -155),
          red = util.by_pixel(23, -171),
        }
      }
    },
      radius_visualisation_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
      width = 12,
      height = 12,
      priority = "extra-high-no-scale"
    },
  },
})
--###############################################################################################
-- Wood Fence
data:extend({
 {
    type = "wall",
    name = "bi-wooden-fence",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wooden-fence.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation"},
    collision_box = {{-0.29, -0.09}, {0.29, 0.49}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    minable = {mining_time = 1, result = "bi-wooden-fence"},
    fast_replaceable_group = "wall",
    max_health = 150,
    repair_speed_modifier = 2,
    corpse = "wall-remnants",
    --corpse = "bi-wooden-fence-remnant",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    resistances = 
    {
      {type = "physical", decrease = 2, percent = 15},
      {type = "fire", percent = -25},
      {type = "impact", decrease = 15, percent = 20}
    },
    pictures = {
      single = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-single-1.png",
            priority = "extra-high",
            width = 14,
            height = 92,
            scale = 0.5,
            shift = {0, -0.15625}
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-single-shadow.png",
            priority = "extra-high",
            width = 76,
            height = 50,
            scale = 0.5,
            shift = {0.459375, 0.75},
            draw_as_shadow = true
          }
        }
      },
      straight_vertical = {
        {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-vertical-1.png",
              priority = "extra-high",
              width = 14,
              height = 106,
              scale = 0.5,
              shift = {0, -0.15625}
            },
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-vertical-shadow.png",
              priority = "extra-high",
              width = 78,
              height = 132,
              scale = 0.5,
              shift = {0.490625, 1.425},
              draw_as_shadow = true
            }
          }
        },
        {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-vertical-1.png",
              priority = "extra-high",
              width = 14,
              height = 106,
              scale = 0.5,
              shift = {0, -0.15625}
            },
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-vertical-shadow.png",
              priority = "extra-high",
              width = 78,
              height = 132,
              scale = 0.5,
              shift = {0.490625, 1.425},
              draw_as_shadow = true
            }
          }
        },
        {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-vertical-1.png",
              priority = "extra-high",
              width = 14,
              height = 106,
              scale = 0.5,
              shift = {0, -0.15625}
            },
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-vertical-shadow.png",
              priority = "extra-high",
              width = 78,
              height = 132,
              scale = 0.5,
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
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-horizontal-1.png",
              priority = "extra-high",
              width = 68,
              height = 94,
              scale = 0.5,
              shift = {0, -0.15625}
            },
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-horizontal-shadow.png",
              priority = "extra-high",
              width = 168,
              height = 56,
              scale = 0.5,
              shift = {0.421875, 0.85},
              draw_as_shadow = true
            }
          }
        },
        {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-horizontal-2.png",
              priority = "extra-high",
              width = 68,
              height = 94,
              scale = 0.5,
              shift = {0, -0.15625}
            },
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-horizontal-shadow.png",
              priority = "extra-high",
              width = 168,
              height = 56,
              scale = 0.5,
              shift = {0.421875, 0.85},
              draw_as_shadow = true
            }
          }
        },
        {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-horizontal-3.png",
              priority = "extra-high",
              width = 68,
              height = 94,
              scale = 0.5,
              shift = {0, -0.15625}
            },
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-straight-horizontal-shadow.png",
              priority = "extra-high",
              width = 168,
              height = 56,
              scale = 0.5,
              shift = {0.421875, 0.85},
              draw_as_shadow = true
            }
          }
        }
      },
      corner_right_down = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-corner-right-down.png",
            priority = "extra-high",
            width = 46,
            height = 106,
            scale = 0.5,
            shift = {0.248125, -0.07625}
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-corner-right-down-shadow.png",
            priority = "extra-high",
            width = 104,
            height = 112,
            scale = 0.5,
            shift = {0.724375, 1.30625},
            draw_as_shadow = true
          }
        }
      },
      corner_left_down = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-corner-left-down.png",
            priority = "extra-high",
            width = 42,
            height = 106,
            scale = 0.5,
            shift = {-0.248125, -0.07625}
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-corner-left-down-shadow.png",
            priority = "extra-high",
            width = 120,
            height = 112,
            scale = 0.5,
            shift = {0.128125, 1.30625},
            draw_as_shadow = true
          }
        }
      },
      t_up = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-t-down.png",
            priority = "extra-high",
            width = 68,
            height = 106,
            scale = 0.5,
            shift = {0, -0.07625}
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-t-down-shadow.png",
            priority = "extra-high",
            width = 142,
            height = 110,
            scale = 0.5,
            shift = {0.286875, 1.280625},
            draw_as_shadow = true
          }
        }
      },
      ending_right = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-ending-right.png",
            priority = "extra-high",
            width = 46,
            height = 94,
            scale = 0.5,
            shift = {0.248125, -0.15625}
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-ending-right-shadow.png",
            priority = "extra-high",
            width = 98,
            height = 54,
            scale = 0.5,
            shift = {0.684375, 0.85},
            draw_as_shadow = true
          }
        }
      },
      ending_left = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-ending-left.png",
            priority = "extra-high",
            width = 42,
            height = 94,
            scale = 0.5,
            shift = {-0.248125, -0.15625}
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/wood_fence/fence-ending-left-shadow.png",
            priority = "extra-high",
            width = 126,
            height = 54,
            scale = 0.5,
            shift = {0.128125, 0.85},
            draw_as_shadow = true
          }
        }
      }
    }
},
})
--###############################################################################################
-- Wood Pipe
data:extend({
 {
    type = "pipe",
    name = "bi-wood-pipe",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_pipe.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.075, result = "bi-wood-pipe"},
    max_health = 100,
    corpse = "small-remnants",
    --corpse = "bi-wood-pipe-remnant",
    resistances = 
    {
      {type = "fire", percent = 20},
      {type = "impact", percent = 30}
    },
    fast_replaceable_group = "pipe",
    collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fluid_box = {
      base_area = 1,
      pipe_connections = {
        { position = {0, -1} },
        { position = {1, 0} },
        { position = {0, 1} },
        { position = {-1, 0} }
      },
    },
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    pictures = {
        straight_vertical_single = {
          filename = "__base__/graphics/entity/pipe/pipe-straight-vertical-single.png",
          priority = "extra-high",
          width = 80,
          height = 80,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-straight-vertical-single.png",
            priority = "extra-high",
            width = 160,
            height = 160,
            scale = 0.5
          }
        },
        straight_vertical = {
          filename = "__base__/graphics/entity/pipe/pipe-straight-vertical.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-straight-vertical.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        straight_vertical_window = {
          filename = "__base__/graphics/entity/pipe/pipe-straight-vertical-window.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-straight-vertical-window.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        straight_horizontal_window = {
          filename = "__base__/graphics/entity/pipe/pipe-straight-horizontal-window.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-straight-horizontal-window.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        straight_horizontal = {
          filename = "__base__/graphics/entity/pipe/pipe-straight-horizontal.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-straight-horizontal.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        corner_up_right = {
          filename = "__base__/graphics/entity/pipe/pipe-corner-up-right.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-corner-up-right.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        corner_up_left = {
          filename = "__base__/graphics/entity/pipe/pipe-corner-up-left.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-corner-up-left.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        corner_down_right = {
          filename = "__base__/graphics/entity/pipe/pipe-corner-down-right.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-corner-down-right.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        corner_down_left = {
          filename = "__base__/graphics/entity/pipe/pipe-corner-down-left.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-corner-down-left.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        t_up = {
          filename = "__base__/graphics/entity/pipe/pipe-t-up.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-t-up.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        t_down = {
          filename = "__base__/graphics/entity/pipe/pipe-t-down.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-t-down.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        t_right = {
          filename = "__base__/graphics/entity/pipe/pipe-t-right.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-t-right.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        t_left = {
          filename = "__base__/graphics/entity/pipe/pipe-t-left.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-t-left.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        cross = {
          filename = "__base__/graphics/entity/pipe/pipe-cross.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-cross.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        ending_up = {
          filename = "__base__/graphics/entity/pipe/pipe-ending-up.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-ending-up.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        ending_down = {
          filename = "__base__/graphics/entity/pipe/pipe-ending-down.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-ending-down.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        ending_right = {
          filename = "__base__/graphics/entity/pipe/pipe-ending-right.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-ending-right.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        ending_left = {
          filename = "__base__/graphics/entity/pipe/pipe-ending-left.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-ending-left.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        horizontal_window_background = {
          filename = "__base__/graphics/entity/pipe/pipe-horizontal-window-background.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-horizontal-window-background.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        vertical_window_background = {
          filename = "__base__/graphics/entity/pipe/pipe-vertical-window-background.png",
          priority = "extra-high",
          size = 64,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-pipe-vertical-window-background.png",
            priority = "extra-high",
            size = 128,
            scale = 0.5
          }
        },
        fluid_background = {
          filename = "__base__/graphics/entity/pipe/fluid-background.png",
          priority = "extra-high",
          width = 32,
          height = 20,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-fluid-background.png",
            priority = "extra-high",
            width = 64,
            height = 40,
            scale = 0.5
          }
        },
        low_temperature_flow = {
          filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
          priority = "extra-high",
          width = 160,
          height = 18
        },
        middle_temperature_flow = {
          filename = "__base__/graphics/entity/pipe/fluid-flow-medium-temperature.png",
          priority = "extra-high",
          width = 160,
          height = 18
        },
        high_temperature_flow = {
          filename = "__base__/graphics/entity/pipe/fluid-flow-high-temperature.png",
          priority = "extra-high",
          width = 160,
          height = 18
        },
        gas_flow = {
          filename = "__base__/graphics/entity/pipe/steam.png",
          priority = "extra-high",
          line_length = 10,
          width = 24,
          height = 15,
          frame_count = 60,
          axially_symmetrical = false,
          direction_count = 1,
          hr_version = {
            filename = "__base__/graphics/entity/pipe/hr-steam.png",
            priority = "extra-high",
            line_length = 10,
            width = 48,
            height = 30,
            frame_count = 60,
            axially_symmetrical = false,
            direction_count = 1
          }
        }
      },
    working_sound = {
      sound = {{filename = "__base__/sound/pipe.ogg", volume = 0.85},},
      match_volume_to_activity = true,
      max_sounds_per_type = 3
    },
    horizontal_window_bounding_box = {{-0.25, -0.28125}, {0.25, 0.15625}},
    vertical_window_bounding_box = {{-0.28125, -0.5}, {0.03125, 0.125}}
  },
})
--###############################################################################################
-- Wood Pipe to Ground
data:extend({
{
    type = "pipe-to-ground",
    name = "bi-wood-pipe-to-ground",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_pipe_to_ground.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.075, result = "bi-wood-pipe-to-ground"},
    max_health = 150,
    corpse = "small-remnants",
    resistances = 
    {
      {type = "fire", percent = 20},
      {type = "impact", percent = 40}
    },
    fast_replaceable_group = "pipe",
    collision_box = {{-0.29, -0.29}, {0.29, 0.2}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fluid_box = {
      base_area = 1,
      pipe_covers = 
      {
        north =
        {
          layers =
          {
            {
              filename = "__base__/graphics/entity/pipe-covers/pipe-cover-north.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              hr_version =
              {
                filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-north.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
              }
            },
            {
              filename = "__base__/graphics/entity/pipe-covers/pipe-cover-north-shadow.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              draw_as_shadow = true,
              hr_version =
              {
                filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-north-shadow.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
                draw_as_shadow = true
              }
            }
          }
        },
        east =
        {
          layers =
          {
            {
              filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              hr_version =
              {
                filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
              }
            },
            {
              filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east-shadow.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              draw_as_shadow = true,
              hr_version =
              {
                filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east-shadow.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
                draw_as_shadow = true
              }
            }
          }
        },
        south =
        {
          layers =
          {
            {
              filename = "__base__/graphics/entity/pipe-covers/pipe-cover-south.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              hr_version =
              {
                filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-south.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
              }
            },
            {
              filename = "__base__/graphics/entity/pipe-covers/pipe-cover-south-shadow.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              draw_as_shadow = true,
              hr_version =
              {
                filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-south-shadow.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
                draw_as_shadow = true
              }
            }
          }
        },
        west =
        {
          layers =
          {
            {
              filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              hr_version =
              {
                filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
              }
            },
            {
              filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west-shadow.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              draw_as_shadow = true,
              hr_version =
              {
                filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west-shadow.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
                draw_as_shadow = true
              }
            }
          }
        }
      },
      pipe_connections = {
        { position = {0, -1} },
        {
          position = {0, 1},
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
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    pictures = {
      up = {
        filename = "__base__/graphics/entity/pipe-to-ground/pipe-to-ground-up.png",
        priority = "high",
        size = 64,
        hr_version = {
          filename = "__base__/graphics/entity/pipe-to-ground/hr-pipe-to-ground-up.png",
          priority = "extra-high",
          size = 128,
          scale = 0.5
        }
      },
      down = {
        filename = "__base__/graphics/entity/pipe-to-ground/pipe-to-ground-down.png",
        priority = "high",
        size = 64,
        hr_version = {
          filename = "__base__/graphics/entity/pipe-to-ground/hr-pipe-to-ground-down.png",
          priority = "extra-high",
          size = 128,
          scale = 0.5
        }
      },
      left = {
        filename = "__base__/graphics/entity/pipe-to-ground/pipe-to-ground-left.png",
        priority = "high",
        size = 64,
        hr_version = {
          filename = "__base__/graphics/entity/pipe-to-ground/hr-pipe-to-ground-left.png",
          priority = "extra-high",
          size = 128,
          scale = 0.5
        }
      },
      right = {
        filename = "__base__/graphics/entity/pipe-to-ground/pipe-to-ground-right.png",
        priority = "high",
        size = 64,
        hr_version = {
          filename = "__base__/graphics/entity/pipe-to-ground/hr-pipe-to-ground-right.png",
          priority = "extra-high",
          size = 128,
          scale = 0.5
        }
      },
    },
  },
})