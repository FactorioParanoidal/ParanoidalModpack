data:extend({
  {
    type = "item",
    name = "assembly-robot",
    icon = "__SpaceMod__/graphics/icons/assembly-robot.png",
	icon_size = 32,
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "p[assembly-robot]",
    stack_size = 50
  },
  {
    type = "item",
    name = "drydock-assembly",
    icon = "__SpaceMod__/graphics/icons/drydock-assembly.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "q[drydock-assembly]",
    stack_size = 1
  }, 
  {
    type = "item",
    name = "drydock-structural",
    icon = "__SpaceMod__/graphics/icons/drydock-structural.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "r[drydock-structural]",
    stack_size = 1
  },   
  {
    type = "item",
    name = "fusion-reactor",
    icon = "__SpaceMod__/graphics/icons/fusion-reactor.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "s[fusion-reactor]",
    stack_size = 1
  },   
  {
    type = "item",
    name = "hull-component",
    icon = "__SpaceMod__/graphics/icons/hull-component.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "t[hull-component]",
    stack_size = 1
  }, 
  {
    type = "item",
    name = "protection-field",
    icon = "__SpaceMod__/graphics/icons/protection-field.png",
	icon_size = 32,	
--    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "u[protection-field]",
    stack_size = 1
  },  
  {
    type = "item",
    name = "space-thruster",
    icon = "__SpaceMod__/graphics/icons/space-thruster.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "v[space-thruster]",
    stack_size = 1
  }, 
  {
    type = "item",
    name = "fuel-cell",
    icon = "__SpaceMod__/graphics/icons/fuel-cell.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "w[fuel-cell]",
    stack_size = 1
  },  
  {
    type = "item",
    name = "habitation",
    icon = "__SpaceMod__/graphics/icons/habitation.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "x[habitation]",
    stack_size = 1
  },  
  {
    type = "item",
    name = "life-support",
    icon = "__SpaceMod__/graphics/icons/life-support.png",
	icon_size = 32,	
--    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "y[life-support]",
    stack_size = 1
  },
  {
    type = "item",
    name = "command",
    icon = "__SpaceMod__/graphics/icons/command.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "z-a[command]",
    stack_size = 1
  }, 
  {
    type = "item",
    name = "astrometrics",
    icon = "__SpaceMod__/graphics/icons/astrometrics.png",
	icon_size = 32,
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "z-b[astrometrics]",
    stack_size = 1
  },  
  {
    type = "item",
    name = "ftl-drive",
    icon = "__SpaceMod__/graphics/icons/ftl-drive.png",
	icon_size = 32,	
 --   flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "z-c[ftl-drive]",
    stack_size = 1
  },  
  {
    type = "item",
    name = "spacex-combinator",
    icon = "__SpaceMod__/graphics/icons/spacex-combinator.png",
    icon_size = 32,
--    flags = { "goes-to-quickbar" },
    subgroup = "circuit-network",
    place_result = "spacex-combinator",
    order = "c[combinators]-dd[spacex-combinator]",
    stack_size= 50
  },
  {
    type = "constant-combinator",
    name = "spacex-combinator",
    icon = "__SpaceMod__/graphics/icons/spacex-combinator.png",
	icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "spacex-combinator"},
    max_health = 120,
    corpse = "small-remnants",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 18,

    sprites =
    make_4way_animation_from_spritesheet({ layers =
      {
        {
          filename = "__SpaceMod__/graphics/entity/spacex-combinator.png",
          width = 58,
          height = 52,
          frame_count = 1,
          shift = util.by_pixel(0, 5),
          hr_version =
          {
            scale = 0.5,
            filename = "__SpaceMod__/graphics/entity/hr-spacex-combinator.png",
            width = 114,
            height = 102,
            frame_count = 1,
            shift = util.by_pixel(0, 5),
          },
        },
        {
          filename = "__SpaceMod__/graphics/entity/spacex-combinator-shadow.png",
          width = 50,
          height = 34,
          frame_count = 1,
          shift = util.by_pixel(9, 6),
          draw_as_shadow = true,
          hr_version =
          {
            scale = 0.5,
            filename = "__SpaceMod__/graphics/entity/hr-spacex-combinator-shadow.png",
            width = 98,
            height = 66,
            frame_count = 1,
            shift = util.by_pixel(8.5, 5.5),
            draw_as_shadow = true,
          },
        },
      },
    }),
activity_led_sprites =
  {
    north =
    {
      filename = "__SpaceMod__/graphics/entity/activity-leds/constant-combinator-LED-N.png",
      width = 8,
      height = 6,
      frame_count = 1,
      shift = util.by_pixel(9, -12),
      hr_version =
      {
        scale = 0.5,
        filename = "__SpaceMod__/graphics/entity/activity-leds/hr-constant-combinator-LED-N.png",
        width = 14,
        height = 12,
        frame_count = 1,
        shift = util.by_pixel(9, -11.5),
      },
    },
    east =
    {
      filename = "__SpaceMod__/graphics/entity/activity-leds/constant-combinator-LED-E.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(8, 0),
      hr_version =
      {
        scale = 0.5,
        filename = "__SpaceMod__/graphics/entity/activity-leds/hr-constant-combinator-LED-E.png",
        width = 14,
        height = 14,
        frame_count = 1,
        shift = util.by_pixel(7.5, -0.5),
      },
    },
    south =
    {
      filename = "__SpaceMod__/graphics/entity/activity-leds/constant-combinator-LED-S.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-9, 2),
      hr_version =
      {
        scale = 0.5,
        filename = "__SpaceMod__/graphics/entity/activity-leds/hr-constant-combinator-LED-S.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-9, 2.5),
      },
    },
    west =
    {
      filename = "__SpaceMod__/graphics/entity/activity-leds/constant-combinator-LED-W.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-7, -15),
      hr_version =
      {
        scale = 0.5,
        filename = "__SpaceMod__/graphics/entity/activity-leds/hr-constant-combinator-LED-W.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-7, -15),
      },
    },
  },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
      color = {r = 1.0, g = 1.0, b = 1.0}
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points =
    {
      {
        shadow =
        {
          red = {0.15625, -0.28125},
          green = {0.65625, -0.25}
        },
        wire =
        {
          red = {-0.28125, -0.5625},
          green = {0.21875, -0.5625},
        }
      },
      {
        shadow =
        {
          red = {0.75, -0.15625},
          green = {0.75, 0.25},
        },
        wire =
        {
          red = {0.46875, -0.5},
          green = {0.46875, -0.09375},
        }
      },
      {
        shadow =
        {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire =
        {
          red = {0.28125, 0.15625},
          green = {-0.21875, 0.15625}
        }
      },
      {
        shadow =
        {
          red = {-0.03125, 0.28125},
          green = {-0.03125, -0.125},
        },
        wire =
        {
          red = {-0.46875, 0},
          green = {-0.46875, -0.40625},
        }
      }
    },

    circuit_wire_max_distance = 9
  },  
})