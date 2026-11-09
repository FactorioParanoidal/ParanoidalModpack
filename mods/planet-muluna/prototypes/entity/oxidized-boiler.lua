--[[
  Fix/Enhance/Upgrade version of the original snippet.
  This script adjusts fluid properties for "thruster-oxidizer" based on water's heat capacity
  and creates a custom "space-boiler" prototype based on the default boiler.
]]
local dual_icon = require("lib.dual-item-icon").dual_icon
local data_util = require("__flib__.data-util")

--------------------------------------------------------------------------------
-- Step 1: Safely retrieve water fluid data and compute a scaled heat capacity
--------------------------------------------------------------------------------
local water_fluid = data.raw["fluid"]["water"]
if not water_fluid then
  -- If "water" fluid somehow doesn't exist, abort or skip this logic
  log("Warning: 'water' fluid not found. Skipping thruster-oxidizer capacity changes.")
  return
end

local water_capacity_str = water_fluid.heat_capacity or "1KJ"  -- Fallback if missing
local numeric_value, suffix = data_util.get_energy_value(water_capacity_str)
-- e.g. numeric_value = 15, suffix="KJ" or "MJ"

--------------------------------------------------------------------------------
-- Step 2: Modify "thruster-oxidizer" heat capacity, if it exists
--------------------------------------------------------------------------------
-- local thruster_oxidizer = data.raw["fluid"]["thruster-oxidizer"]
-- if thruster_oxidizer then
--   -- For example, dividing water's numeric capacity by 15
--   thruster_oxidizer.heat_capacity = tostring(numeric_value / 15) .. suffix

--   -- Optionally set default temperature if you wish:
--   -- thruster_oxidizer.default_temperature = water_fluid.default_temperature or 15

--   -- If you want to define some unique or additional properties:
--   -- thruster_oxidizer.base_color   = {r=0.2, g=0.5, b=0.8}
--   -- thruster_oxidizer.flow_color   = {r=0.4, g=0.7, b=0.9}
--   -- thruster_oxidizer.fuel_value   = "2MJ"
-- else
--   log("Warning: 'thruster-oxidizer' fluid not found. Skipping modifications.")
-- end

--------------------------------------------------------------------------------
-- (Optional) Step 3: Similarly handle "thruster-fuel"
--------------------------------------------------------------------------------
-- local thruster_fuel = data.raw["fluid"]["thruster-fuel"]
-- if thruster_fuel then
--   thruster_fuel.default_temperature = water_fluid.default_temperature or 15
--   -- thruster_fuel.fuel_value = "4MJ" -- example
-- end

--------------------------------------------------------------------------------
-- Step 4: Create or modify a custom "space-boiler" based on the default "boiler"
--------------------------------------------------------------------------------
local base_boiler = data.raw["boiler"]["boiler"]
if not base_boiler then
  log("Warning: base 'boiler' prototype not found. Cannot create 'space-boiler'.")
  return
end

-- -- Deep copy the table so we don't mutate the original
-- local space_boiler = table.deepcopy(base_boiler)
-- space_boiler.name = "space-boiler"
-- space_boiler.localised_name = {"entity-name.space-boiler-legacy"}
-- space_boiler.localised_description = {"entity-description.space-boiler-legacy"}
-- space_boiler.surface_conditions = nil  -- Remove any surface restrictions
-- space_boiler.energy_consumption = "1.8MW"
-- space_boiler.minable.result = "muluna-advanced-boiler"

-- -- Example custom tweak: you could adjust fluid_box filters or effectivity:
-- -- space_boiler.fluid_box.filter      = "thruster-oxidizer"
-- -- space_boiler.energy_source.effectivity = 64/60  -- example

-- --------------------------------------------------------------------------------
-- -- Step 5: Final extension into the data stage
-- --------------------------------------------------------------------------------
-- Muluna:extend({
--   space_boiler
-- })


--------------------------------------------------------------------------------
-- New Space Boiler
-- Based on Hurricane's Thermal Plant

local function ingredient_multiply(ingredients,name,factor,new_name)
  if new_name == nil then new_name = name end
  
  for _,ingredient in pairs(ingredients) do
    if ingredient.name == name then
      ingredient.name = new_name
      ingredient.amount = ingredient.amount * factor
    end
  end

end


local space_boiler_category = {
  type="recipe-category",
  name="double-boiler",
}
local recipe_time = 6
local space_boiling = {
  type = "recipe",
  categories = {"double-boiler"},
  name = "advanced-water-boiling",
  icons = dual_icon("steam","oxygen"),
  --icon = data.raw["fluid"]["steam"].icon,
  --icon_size= data.raw["fluid"]["steam"].icon_size,
  subgroup="advanced-boiling",
  energy_required=1/recipe_time,
  hide_from_signal_gui = false,
  enabled=false,
  ingredients = {
    {type = "fluid",name = "water", amount = 6/recipe_time,temperature=15},
    {type = "fluid",name = "oxygen", amount = 60/recipe_time},
  },
  results = {
    {type = "fluid",name = "steam", amount = 60/recipe_time,temperature=165},
    {type = "fluid",name = "carbon-dioxide", amount = 60/recipe_time,temperature=165},
  }
}

local space_boiling_atmosphere = Muluna.rro.util_merge{space_boiling,{
  name = "advanced-water-boiling-atmosphere",
  hide_from_signal_gui = false,
  icons = dual_icon("steam","maraxsis-atmosphere"),
  --icon = data.raw["fluid"]["steam"].icon,
  --icon_size= data.raw["fluid"]["steam"].icon_size,
  ingredients = {
    {type = "fluid",name = "water", amount = 6/recipe_time,temperature=15},
    {type = "fluid",name = "maraxsis-atmosphere", amount = 5*60/recipe_time},
  }
}}

-- local temperature_time_ratio = (500-15)/(165-15)

-- local space_boiling_high_temperature = Muluna.rro.util_merge{space_boiling,{
--   name = "advanced-water-boiling-high-temperature",
--   hide_from_signal_gui = false,
--   --icons = dual_icon("steam","oxygen","oxygen"),
--   --icons = dual_icon("steam","maraxsis-atmosphere"),
--   --icon = data.raw["fluid"]["steam"].icon,
--   --icon_size= data.raw["fluid"]["steam"].icon_size,
--   energy_required = space_boiling.energy_required * temperature_time_ratio,
--   ingredients = {
--     {type = "fluid",name = "water", amount = 6/recipe_time,temperature=15},
--     {type = "fluid",name = "oxygen", amount = temperature_time_ratio*60/recipe_time},
--   },
--   results = {
--     {type = "fluid",name = "steam", amount = 60/recipe_time,temperature=500},
--     {type = "fluid",name = "carbon-dioxide", amount = temperature_time_ratio*60/recipe_time,temperature=500},
--   }
-- }}

-- Muluna:extend{space_boiling_high_temperature}




local space_melting = {
  type = "recipe",
  categories = {"double-boiler"},
  hide_from_signal_gui = false,
  name = "advanced-water-melting-oxygen",
  icons = {
    {
      icon = data.raw["recipe"]["ice-melting"].icon,
      icon_size = data.raw["recipe"]["ice-melting"].icon_size,
    }
  }, 
  --icon = data.raw["fluid"]["steam"].icon,
  --icon_size= data.raw["fluid"]["steam"].icon_size,
  energy_required=1/10,
  enabled=false,
  --localised_name = {"recipe-name.water-melting"},
  subgroup="muluna-products",
  ingredients = {
    {type = "item",name = "ice", amount = 1},
    {type = "fluid",name = "oxygen", amount = 60/15},
  },
  results = {
    {type = "fluid",name = "water", amount = 20,temperature=15},
    {type = "fluid",name = "carbon-dioxide", amount = 60/15,temperature=165},
  }
}

local space_melting_oxygen = table.deepcopy(space_melting)
ingredient_multiply(space_melting_oxygen.ingredients,"oxygen",5,"maraxsis-atmosphere")
space_melting_oxygen.name="advanced-water-melting-atmosphere"
Muluna:extend{space_melting,space_melting_oxygen}


local space_boiler_new = {
  type="assembling-machine",
  name= "muluna-advanced-boiler",
  icon = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-icon.png",
  flags = {"placeable-neutral", "player-creation"},
  minable = {mining_time = 0.5, result = "muluna-advanced-boiler"},
  fast_replaceable_group = "boiler",
  max_health = 600,
  corpse = "boiler-remnants",
  dying_explosion = "boiler-explosion",
  impact_category = "metal-large",
  mode = "output-to-separate-pipe",
  circuit_connector = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"].circuit_connector),
  circuit_connector_flipped = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"].circuit_connector_flipped),
  draw_circuit_wires = true,
  circuit_wire_max_distance = data.raw["assembling-machine"]["assembling-machine-1"].circuit_wire_max_distance,
  working_sound = base_boiler.working_sound,
  open_sound = base_boiler.open_sound,
  close_sound = base_boiler.close_sound,
  energy_source=table.deepcopy(base_boiler.energy_source),
  collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  burning_cooldown = 20,
  fire_flicker_enabled = true,
  fire_glow_flicker_enabled = true,
  --damaged_trigger_effect = hit_effects.entity(),
  effect_receiver = {
    base_effect = {},
    uses_module_effects = true,
    uses_beacon_effects = false,
    uses_surface_effects =false,
  },
  allowed_module_categories = {

  },
  target_temperature = 65,
  fluid_boxes = {
      {
        volume = 200,
        pipe_covers = pipecoverspictures(),
        pipe_picture = Muluna.pipe_pictures.advanced_boiler_pipe_pictures(),
        pipe_connections =
        {
          {flow_direction = "input-output", direction = defines.direction.west, position = {-1.0, 0}},
          {flow_direction = "input-output", direction = defines.direction.east, position = {1.0, 0}},
        },
        production_type = "input",
        --filter = "water"
      },
      {
        volume = 200,
        pipe_covers = pipecoverspictures(),
        pipe_picture = Muluna.pipe_pictures.advanced_boiler_pipe_pictures(),
        pipe_connections =
        {
          {flow_direction = "input-output", direction = defines.direction.west, position = {-1.0, 1}},
          {flow_direction = "input-output", direction = defines.direction.east, position = {1.0, 1}}
        },
        production_type = "input",
        --filter = "water"
      },
      {
          volume = 200,
          pipe_covers = pipecoverspictures(),
          pipe_picture = Muluna.pipe_pictures.advanced_boiler_pipe_pictures(),
          pipe_connections =
          {
            {flow_direction = "input-output", direction = defines.direction.north, position = {0, -1.0}},
          },
          production_type = "output",
          --filter = "steam"
        },
      {
          volume = 200,
          pipe_covers = pipecoverspictures(),
          pipe_picture = Muluna.pipe_pictures.advanced_boiler_pipe_pictures(),
          pipe_connections =
          {
            {flow_direction = "input-output", direction = defines.direction.west, position = {-1.0, -1}},
            {flow_direction = "input-output", direction = defines.direction.east, position = {1.0, -1}}
          },
          production_type = "output",
          --filter = "steam"
      },
  },
  --fluid_boxes=data.raw["assembling-machine"]["chemical-plant"].fluid_boxes,
    -- fluid_box =
    -- {
    --   volume = 200,
    --   pipe_covers = pipecoverspictures(),
    --   pipe_connections =
    --   {
    --     {flow_direction = "input-output", direction = defines.direction.west, position = {-1.0, 0}},
    --     {flow_direction = "input-output", direction = defines.direction.east, position = {1.0, 0}}
    --   },
    --   production_type = "input",
    --   filter = "water"
    -- },
    -- output_fluid_box =
    -- {
    --   volume = 200,
    --   pipe_covers = pipecoverspictures(),
    --   pipe_connections =
    --   {
    --     {flow_direction = "output", direction = defines.direction.north, position = {0, -1}}
    --   },
    --   production_type = "output",
    --   filter = "steam"
    -- },
  crafting_categories = {"double-boiler"},
  crafting_speed=3, --Convention: assembler prototype boiler crafting speed is defined as 1 when steam production rate equals vanilla boiler.
  energy_usage = "3.6MW", --Double the vanilla boiler.
  graphics_set = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"].graphics_set),
  pictures = {
    north =
      {
        structure =
        {
          layers =
          {
            {
              filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-shadow.png",
              priority = "extra-high",
              width = 900,
              height = 500,
              scale = 0.35,
              shift = util.by_pixel(0, -20.5),
              draw_as_shadow = true
            },
            {
              filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-animation-1.png",
              priority = "extra-high",
              width = 1300,
              height = 1000,
              frame_count = 64,
              line_length = 8,
              width = 330,
              height = 410,
              animation_speed = 0.5,
              shift = util.by_pixel(0, -20),
              scale = 0.35,
            },
            
          }
        },
        fire_glow =
        {
          filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-emission-1.png",
          draw_as_glow = true,
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 330,
          height = 410,
          animation_speed = 0.5,
          shift = util.by_pixel(0, -20),
          scale = 0.35,
          blend_mode="additive"
        },
        fire =
        {
          filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-emission-1.png",
          draw_as_glow = true,
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 330,
          height = 410,
          animation_speed = 0.5,
          shift = util.by_pixel(0, -20),
          scale = 0.35,
          blend_mode="additive"
        },
      },
  }
}
--space_boiler_new.pictures.east=space_boiler_new.pictures.north
--space_boiler_new.pictures.west=space_boiler_new.pictures.north
--space_boiler_new.pictures.south=space_boiler_new.pictures.north
if data.raw["container"]["bottomless-chest"] then --Checking if game version >= 2.0.57
  space_boiler_new.quality_affects_energy_usage = true
  space_boiler_new.custom_tooltip_fields = {
    {
      name = {"description.effectivity"},
      value = "150%"
    }
  }
end
space_boiler_new.energy_source.light_flicker =
  {
    color = {0,0,0},
    minimum_intensity = 0.6*3,
    maximum_intensity = 0.95*3
  }
local smoke_position = util.by_pixel(30.5, -85)
space_boiler_new.energy_source.smoke =
{
  {
    name = "smoke",
    north_position = smoke_position,
    east_position = smoke_position,
    west_position = smoke_position,
    south_position = smoke_position,
    frequency = 15,
    starting_vertical_speed = 0.20,
    starting_frame_deviation = 60
  }
}
-- The energy source is a deepcopy of the vanilla boiler's, which emits 30 pollution/minute.
-- Clear it explicitly so the vacuum boiler does not inherit that value.
space_boiler_new.energy_source.emissions_per_minute = {}
space_boiler_new.graphics_set.animation = { north = {
  layers =
          {
            {
              filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-animation-1.png",
              priority = "extra-high",
              width = 1300,
              height = 1000,
              frame_count = 64,
              line_length = 8,
              width = 330,
              height = 410,
              animation_speed = 0.5,
              shift = util.by_pixel(0, -20),
              scale = 0.35,
              run_mode="forward-then-backward",
            },
            {
              filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-shadow.png",
              priority = "extra-high",
              width = 900,
              height = 500,
              scale = 0.35,
              repeat_count = 126,
              shift = util.by_pixel(0, -20),
              draw_as_shadow = true
            },
            
            -- {
            --   filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-shadow.png",
            --   priority = "extra-high",
            --   width = 900,
            --   height = 500,
            --   scale = 0.125,
            --   shift = util.by_pixel(20.5, 9),
            --   draw_as_shadow = true
            -- }
          }
        }
}

space_boiler_new.graphics_set.working_visualisations = {

  {
    fadeout = true,
    effect = "flicker",
    animation = { layers = {
      {
        filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-emission-1.png",
        draw_as_glow = true,
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 330,
        height = 410,
        animation_speed = 0.5,
        shift = util.by_pixel(0, -20),
        scale = 0.35,
        blend_mode="additive",
        draw_as_glow = true,
        run_mode="forward-then-backward",
      },
      {
        filename = "__muluna-graphics__/graphics/thermal-plant/thermal-plant-hr-emission-1.png",
        draw_as_glow = true,
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 330,
        height = 410,
        animation_speed = 0.5,
        shift = util.by_pixel(0, -20),
        scale = 0.35,
        blend_mode="additive",
        draw_as_light = true,
        run_mode="forward-then-backward",
      }
    }
    }
    
  }
}

  
if mods["QualityEffectsFixed"] then
  space_boiler_new.qef_ignore = true
end



Muluna:extend{space_boiler_category,space_boiler_new,space_boiling,space_boiling_atmosphere}


