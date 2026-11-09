require("circuit-connector-sprites")
require("circuit-connector-generated-definitions")

local width = 9-0.00001 -- -0.001 is added to stop floating point error from causing the dimensions to be rounded up to the next highest value.
local height = 9-0.00001
local gap = 0
local scale = 0.9
local greenhouse_category = {
    type="recipe-category",
    name="muluna-greenhouse-11x11",
  }

local greenhouse = {
    type="assembling-machine",
    name= "muluna-greenhouse-wood",
    icon = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-icon.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "muluna-greenhouse-wood"},
    fast_replaceable_group = "",
    max_health = 1000,
    corpse = "medium-small-remnants",
    --effect_receiver = { base_effect = { productivity = 0.5 }},
    allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
    module_slots = 4,
    heating_energy = "2.5MW",
    dying_explosion = "chemical-plant-explosion",
    impact_category = "metal-large",
    match_animation_speed_to_activity = false,
    --mode = "output-to-separate-pipe",
    
    --working_sound = base_boiler.working_sound,
    --open_sound = base_boiler.open_sound,
    --close_sound = base_boiler.close_sound,
    working_sound =
    {
      sound =
      {
        filename = "__space-age__/sound/entity/agricultural-tower/agricultural-tower-hub-loop.ogg",
        volume = 0.7,
        audible_distance_modifier = 0.7,
      },
      max_sounds_per_prototype = 4,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    energy_source={
        type="electric",
        usage_priority = "primary-input",
        drain = "25kW",
        emissions_per_minute = {
          pollution = -4,
          spores = 12,
        },
    },
    collision_box = {{-width/2+gap, -height/2+gap}, {width/2-gap, height/2-gap}},
    selection_box = {{-width/2, -height/2}, {width/2, height/2}},
    burning_cooldown = 20,
    use_mirroring=true,
    --fire_flicker_enabled = true,
    --fire_glow_flicker_enabled = true,
    --damaged_trigger_effect = hit_effects.entity(),
  
    target_temperature = 65,
    fluid_boxes = {
      {
        volume = 200,
        pipe_covers = pipecoverspictures(),
        pipe_picture = Muluna.pipe_pictures.greenhouse_pipe_pictures(),
        pipe_connections =
        {
          {flow_direction = "input-output", direction = defines.direction.west, position = {-4.0, 3}},
          {flow_direction = "input-output", direction = defines.direction.east, position = {4.0, 3}},
          {flow_direction = "input-output", direction = defines.direction.south, position = {-3.0, 4}},
          {flow_direction = "input-output", direction = defines.direction.north, position = {-3, -4}},
        },
        production_type = "input",
        --filter = "carbon-dioxide"
      },
        {
          volume = 200,
          pipe_covers = pipecoverspictures(),
          pipe_picture = Muluna.pipe_pictures.greenhouse_pipe_pictures(),
          pipe_connections =
          {
            --{flow_direction = "input", direction = defines.direction.west, position = {-5.0, 0}},
            --{flow_direction = "input", direction = defines.direction.east, position = {5.0, 0}},
            --{flow_direction = "input", direction = defines.direction.south, position = {-0.0, 5}},
            {flow_direction = "input", direction = defines.direction.north, position = {-0, -4}},
          },
          production_type = "input",
          --filter = "water"
        },
        
        {
            volume = 200,
            pipe_covers = pipecoverspictures(),
            pipe_picture = Muluna.pipe_pictures.greenhouse_pipe_pictures(),
            --pipe_picture =  require("__space-age__.prototypes.entity.cryogenic-plant-pictures").pipe_picture,
            --always_draw_covers = true, -- fighting against FluidBoxPrototype::always_draw_covers crazy default
            pipe_connections =
            {
              {flow_direction = "input-output", direction = defines.direction.west, position = {-4.0, -3}},
              {flow_direction = "input-output", direction = defines.direction.east, position = {4.0, -3}},
              {flow_direction = "input-output", direction = defines.direction.south, position = {3.0, 4}},
            {flow_direction = "input-output", direction = defines.direction.north, position = {3, -4}},
            },
            production_type = "output",
            --filter = "oxygen"
        },
        {
          volume = 200,
          pipe_covers = pipecoverspictures(),
          pipe_picture = Muluna.pipe_pictures.greenhouse_pipe_pictures(),
          pipe_connections =
          {
            --{flow_direction = "input", direction = defines.direction.west, position = {-5.0, 0}},
            --{flow_direction = "input", direction = defines.direction.east, position = {5.0, 0}},
            --{flow_direction = "input", direction = defines.direction.south, position = {-0.0, 5}},
            {flow_direction = "input", direction = defines.direction.west, position = {-4, 0}},
          },
          production_type = "input",
          --filter = "fluoroketone-cold",
        },
        {
          volume = 200,
          pipe_covers = pipecoverspictures(),
          pipe_picture = Muluna.pipe_pictures.greenhouse_pipe_pictures(),
          pipe_connections =
          {
            --{flow_direction = "input", direction = defines.direction.west, position = {-5.0, 0}},
            --{flow_direction = "input", direction = defines.direction.east, position = {5.0, 0}},
            --{flow_direction = "input", direction = defines.direction.south, position = {-0.0, 5}},
            {flow_direction = "output", direction = defines.direction.east, position = {4, 0}},
          },
          production_type = "output",
          --filter = "fluoroketone-hot",
        },
    },
    --fluid_boxes=data.raw["assembling-machine"]["chemical-plant"].fluid_boxes,
      -- fluid_box =
      -- {
      --   volume = 200,hemistry
      --   filter = "steam"
      -- },
    --crafting_categories = {"greenhouse-10x10"},
    crafting_categories = {"muluna-greenhouse-11x11","muluna-greenhouse"},
    crafting_speed=10,
    energy_usage = "0.5MW",
    graphics_set =
        {
          -- frozen_patch = {
          --   north = {
          --     layers = {
          --       {
          --         filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-emission-1.png",
          --         draw_as_glow = true,
          --         priority = "extra-high",
          --         frame_count = 64,
          --         line_length = 8,
          --         width = 340,
          --         height = 355,
          --         animation_speed = 0.5,
          --         shift = util.by_pixel(0, -10),
          --         scale = scale,
          --         blend_mode="additive",
          --         run_mode = "forward-then-backward",
          --           apply_runtime_tint = true
          --       },
          --     }
          --   }
          -- },
          working_visualisations = {
            -- {
            --   animation = {
                
            --       filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-animation-1.png",
            --       priority = "extra-high",
            --       frame_count = 64,
            --       line_length = 8,
            --       width = 340,
            --       height = 355,
            --       animation_speed = 0.25,
            --       shift = util.by_pixel(0, -10),
            --       scale = scale,
            --       run_mode = "forward-then-backward",
                
            --   },
            -- },
            {
              
              --apply_tint = "status",
              render_layer = "wires",
              --fadeout = true,
              
              animation = 
                {
                  stripes = {
                    {
                        filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-emission-1.png",
                        width_in_frames = 8,
                        height_in_frames = 8
                    },
                    {
                        filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-emission-2.png",
                        width_in_frames = 8,
                        height_in_frames = 8
                    }
                },
                  --filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-emission-1.png",
                  draw_as_glow = true,
                  priority = "extra-high",
                  frame_count = 128,
                  lines_per_file = 8,
                  width = 340,
                  height = 355,
                  animation_speed = 0.5,
                  shift = util.by_pixel(0, -10),
                  scale = scale,
                  blend_mode="additive",
                  --run_mode = "forward-then-backward",
                  apply_runtime_tint = true
                },
                
              
            },
            {
              --apply_tint = "status",
              render_layer = "wires",
              light = {
                type = "basic",
                intensity = 1,
                size = 25,
              },
              animation ={
                stripes = {
                  {
                      filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-color3-1.png",
                      width_in_frames = 8,
                      height_in_frames = 8
                  },
                  {
                      filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-color3-2.png",
                      width_in_frames = 8,
                      height_in_frames = 8
                  }
              },
                --filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-color3-1.png",
                draw_as_glow = true,
                priority = "extra-high",
                frame_count = 128,
                lines_per_file = 8,
                width = 340,
                height = 355,
                animation_speed = 0.5,
                shift = util.by_pixel(0, -10),
                scale = scale,
                blend_mode="additive",
                --run_mode = "forward-then-backward",
                  --apply_runtime_tint = true
              },
            },
            
          },
          
            animation = {
              north = {
                layers = {
                    {
                      filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-shadow.png",
                      priority = "high",
                      width = 700,
                      height = 500,
                      frame_count = 1,
                      line_length = 1,
                      repeat_count = 128,
                      animation_speed = 0.5,
                      shift = util.by_pixel(0, -10),
                      draw_as_shadow = true,
                      scale = scale
                  },
                    {
                      stripes = {
                        {
                            filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-animation-1.png",
                            width_in_frames = 8,
                            height_in_frames = 8
                        },
                        {
                            filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-animation-2.png",
                            width_in_frames = 8,
                            height_in_frames = 8
                        }
                    },
                      --filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-animation-1.png",
                      priority = "extra-high",
                      frame_count = 128,
                      lines_per_file = 8,
                      width = 340,
                      height = 355,
                      animation_speed = 0.5,
                      shift = util.by_pixel(0, -10),
                      scale = scale,
                      --run_mode = "forward-then-backward",
                    },
                  }
                
              }
            },
          
          -- animation = {
          -- north =
          
          -- {
             
          --     layers =
          --     {
                
                
                
          --       -- {
          --       --   filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-emission-2.png",
          --       --   --draw_as_glow = true,
          --       --   priority = "extra-high",
          --       --   frame_count = 64,
          --       --   line_length = 8,
          --       --   width = 340,
          --       --   height = 355,
          --       --   animation_speed = 0.5,
          --       --   shift = util.by_pixel(0, -10),
          --       --   scale = scale,
          --       --   blend_mode="additive",
          --       --   run_mode = "forward-then-backward",
          --       --   apply_runtime_tint = true
          --       -- },
          --       -- {
          --       --   filename = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-hr-shadow.png",
          --       --   draw_as_shadow = true,
          --       --   priority = "extra-high",
          --       --   frame_count = 1,
          --       --   width = 700,
          --       --   height = 500,
          --       --   --animation_speed = 0.5,
          --       --   shift = util.by_pixel(0, -10),
          --       --   scale = scale,
          --       --   blend_mode="additive",
          --       --   run_mode = "forward-then-backward",
          --       -- },
          --       -- {
          --       --   filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-shadow.png",
          --       --   priority = "extra-high",
          --       --   width = 900,
          --       --   height = 500,
          --       --   scale = 0.125,
          --       --   shift = util.by_pixel(20.5, 9),
          --       --   draw_as_shadow = true
          --       -- }
          --     }
          --   },
            
          -- },
        },
    
    circuit_wire_max_distance = 12,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true }
      }
    ),
    circuit_connector_flipped = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true }
      }
    ), 
    
  }

if mods["fluid-nutrients"] then
  table.insert(greenhouse.fluid_boxes, 
    {
          volume = 200,
          pipe_covers = pipecoverspictures(),
          pipe_connections =
          {
            --{flow_direction = "input", direction = defines.direction.west, position = {-5.0, 0}},
            --{flow_direction = "input", direction = defines.direction.east, position = {5.0, 0}},
            --{flow_direction = "input", direction = defines.direction.south, position = {-0.0, 5}},
            {flow_direction = "input", direction = defines.direction.south, position = {0, 4}},
          },
          production_type = "input",
          --filter = "water"
        }
      )

end


Muluna:extend{greenhouse,greenhouse_category}