local flib_bounding_box = require("__flib__/bounding-box")
if true or data.raw["lab"]["biolab"] then
  local cryolab=table.deepcopy(data.raw["lab"]["biolab"])

cryolab.name="cryolab"
-- if cryolab.selection_box then
--   cryolab.selection_box=flib_bounding_box.resize(cryolab.selection_box,1)
-- end
-- if cryolab.collision_box then
--   cryolab.collision_box=flib_bounding_box.resize(cryolab.collision_box,1)
-- end

cryolab.collision_box = {{-3.2, -3.2}, {3.2, 3.2}}
cryolab.selection_box = {{-3.5, -3.5}, {3.5, 3.5}}


if mods["fluid-nutrients"] then
  cryolab.minimum_input_temperature = 15
  cryolab.maxiumum_temperature = 100
  cryolab.energy_source = { --Copied and modified from fluid-nutrients to make this mod compatible with its changes to biolabs..
    type = "fluid",
    fluid_box = {
        volume = 20,
        filter = "nutrient-solution",
        pipe_picture = {
            north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture.north),
            east = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.east,
            south = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.south,
            west = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture.west
        },
        pipe_picture_frozen = {
            north = table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"].fluid_boxes[1].pipe_picture_frozen.north),
            east = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.east,
            south = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.south,
            west = data.raw["assembling-machine"]["assembling-machine-2"].fluid_boxes[1].pipe_picture_frozen.west
        },
        pipe_covers = data.raw["assembling-machine"]["biochamber"].fluid_boxes[1].pipe_covers,
        pipe_connections = {
            {flow_direction = "input", direction = defines.direction.west, position = {-3, 0}},
            {flow_direction = "input", direction = defines.direction.east, position = {3, 0}},
            {flow_direction = "input", direction = defines.direction.south, position = {0, 3}},
            {flow_direction = "input", direction = defines.direction.north, position = {0, -3}}
        },
        secondary_draw_orders = { north = -1 },
    },
    burns_fluid = true,
    scale_fluid_usage = true,
    emissions_per_minute = cryolab.energy_source.emissions_per_minute,
}
end
cryolab.icons = {
  {
      icon="__muluna-graphics__/graphics/photometric-lab/photometric-lab-icon.png",
      icon_size=64,
      scale=0.25,
      --tint = {r=0.7,g=0.7,b=1}
  },
  
}
cryolab.energy_usage="1.5MW"
--if data.raw["item"]["cryolab"] then
  cryolab.minable = {mining_time = 0.5, result = "cryolab"}
--end


cryolab.researching_speed=cryolab.researching_speed*3
-- cryolab.science_pack_drain_rate_percent=45
cryolab.uses_quality_drain_modifier = true
cryolab.max_health=500
cryolab.module_slots=6
cryolab.energy_source.emissions_per_minute.pollution=(cryolab.energy_source.emissions_per_minute.pollution or 0)*2
local shift = 0.5
cryolab.on_animation = {
    layers = {
      {
        filename = "__muluna-graphics__/graphics/photometric-lab/photometric-lab-hr-shadow.png",
        priority = "extra-high",
        draw_as_shadow = true,
        --width = 1300,
        --height = 700,
        --frame_count = 64,
        --line_length = 8,
        width = 1200,
        height = 700,
        --animation_speed = 0.2,
        --shift = util.by_pixel(0, -20),
        scale = 0.7,
        repeat_count = 80,
        shift = {0,-1+shift},
      },
      util.sprite_load("__muluna-graphics__/graphics/photometric-lab/photometric-lab-hr-animation",{
        frame_count = 80,
        scale = 0.7,
        animation_speed = 0.05,
        run_mode="forward",
        shift = {0,shift},
        --tint = {r=0.7,g=0.7,b=1}
      }),
      util.sprite_load("__muluna-graphics__/graphics/photometric-lab/photometric-lab-hr-emission1",{
        frame_count = 80,
        draw_as_glow = true,
        blend_mode = "additive",
        scale = 0.7,
        animation_speed = 0.05,
        shift = {0,shift},
        run_mode="forward",
        --tint = {r=0,g=0,b=0.2}
      }),
      util.sprite_load("__muluna-graphics__/graphics/photometric-lab/photometric-lab-hr-emission2",{
        frame_count = 80,
        draw_as_glow = true,
        blend_mode = "additive",
        scale = 0.7,
        animation_speed = 0.05,
        shift = {0,shift},
        run_mode="forward",
        --tint = {r=0,g=0,b=0.2}
      }),
      
    }
  }
cryolab.off_animation = {
    layers = {
      {
        filename = "__muluna-graphics__/graphics/photometric-lab/photometric-lab-hr-shadow.png",
        priority = "extra-high",
        --width = 1300,
        --height = 700,
        --frame_count = 64,
        --line_length = 8,
        width = 1200,
        height = 700,
        --animation_speed = 0.2,
        --shift = util.by_pixel(0, -20),
        draw_as_shadow = true,
        scale = 0.7,
        repeat_count = 80,
        shift = {0,-1+shift},
      },
      util.sprite_load("__muluna-graphics__/graphics/photometric-lab/photometric-lab-hr-animation",{
        frame_count = 80,
        scale = 0.7,
        animation_speed = 0.1,
        shift = {0,shift},
        run_mode="forward",
        --tint = {r=0.7,g=0.7,b=1}
      }),
      util.sprite_load("__muluna-graphics__/graphics/photometric-lab/photometric-lab-hr-emission1",{
        frame_count = 80,
        draw_as_glow = true,
        blend_mode = "additive",
        scale = 0.7,
        animation_speed = 0.1,
        shift = {0,shift},
        run_mode="forward",
        --tint = {r=0,g=0,b=0.2}
      }),
      util.sprite_load("__muluna-graphics__/graphics/photometric-lab/photometric-lab-hr-emission2",{
        frame_count = 80,
        draw_as_glow = true,
        blend_mode = "additive",
        scale = 0.7,
        animation_speed = 0.1,
        shift = {0,shift},
        run_mode="forward",
        --tint = {r=0,g=0,b=0.2}
      }),
      
    }
  }
cryolab.working_sound = data.raw["assembling-machine"]["cryogenic-plant"].working_sound

Muluna:extend{cryolab}
end


