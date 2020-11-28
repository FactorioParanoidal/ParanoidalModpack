local mod_name = "__RITEG__"
local RTG = "RITEG-cyan"
local used_up_RTG = "used-up-RITEG-1"

local power = 6000 --kW
local energy = "200GJ"


local tint = {r = 0.7, g = 1, b = 0.7, a = 1}
local size = 3
local shift = {x=32/32, y= -10/32}

data:extend({
  -- items --
  {
    -- flags = {"goes-to-quickbar"},
    icons = {{icon = mod_name.."/graphics/icons/"..RTG..".png"}}, icon_size = 32,
    name = RTG,
    order = "e[electric-energy-interface]-b[electric-energy-interface]",
    place_result = RTG,
    stack_size = 50,
    subgroup = "energy",
    type = "item"
  },
  
  -- entities --
  {
    allow_copy_paste = false,

    corpse = "medium-remnants",
    enable_gui = false,
    energy_production = (10*power)..'kW', --"6000kW",
    energy_source = {
      buffer_capacity = (power/60) ..'kJ', --"10kJ", -- 10 kJ per tick is (600 kJ/sec) or just 600 kW
      input_flow_limit = "0kW",
      output_flow_limit = power ..'kW', --"600kW",
      type = "electric",
      render_no_power_icon = false,
      usage_priority = "primary-output"
    },
    energy_usage = "0kW",
    flags = {
      "placeable-neutral",
      "player-creation",
      "not-repairable" -- added 0.1.2
    },
    icon = mod_name.."/graphics/icons/"..RTG..".png",
    icon_size = 32,
    max_health = power,
    minable = {
      hardness = 0.2,
      mining_time = 5,
      results = {{used_up_RTG, 10}, {"used-up-MOX-fuel", 10}}
      },
    name = RTG,
    picture = { -- thanks to Sigma1, https://forums.factorio.com/viewtopic.php?f=190&t=56513&p=361828#p361785
      filename = mod_name.."/graphics/entities/"..RTG..".png",
      width = 167,
      height = 154,
      priority = "extra-high",
      shift = shift,
      -- tint = tint,
      hr_version = {
        filename = mod_name.."/graphics/entities/".."hr-"..RTG..".png",
        width = 333,
        height = 307,
        priority = "extra-high",
        shift = shift,
        scale = 0.5
      }
      
    },
    collision_box = {{-size/2+0.23, -size/2+0.23},{size/2-0.23, size/2-0.23}},
    selection_box = {{-size/2, -size/2}, {size/2, size/2}},
    
    type = "electric-energy-interface",
    vehicle_impact_sound = {
      filename = "__base__/sound/car-metal-impact.ogg",
      volume = 0.65
    }
  },

  -- recipes --
  {
    enabled = false,
    energy_required = 5,
    icons = {{icon = mod_name.."/graphics/icons/"..RTG..".png"}}, icon_size = 32,
    ingredients = {
      {"steel-plate", 25},
      -- {"advanced-processing-unit", 15}, -- was old version, fixed in 0.2.14
      {"advanced-circuit", 15},
      {"RITEG-1", 10},
      {"MOX-fuel", 10}, -- 10x 20 GJ!
    },
    name = RTG,
    result = RTG,
    type = "recipe"
  },
  {
    enabled = false,
    energy_required = 30,
    -- icons = {{icon = mod_name.."/graphics/icons/"..used_up_RTG..".png"}}, icon_size = 32,
    icons = {
    {icon = mod_name.."/graphics/icons/"..RTG..".png"},
    {icon = mod_name.."/graphics/icons/recycling.png", scale = 0.5, shift={-8,8}},
    }, 
    icon_size = 32,
    ingredients = {
      {used_up_RTG, 10},
      {"MOX-fuel", 10}, -- 10x 20 GJ!
    },
    name = RTG.."-from-"..used_up_RTG,
    result = RTG,
    type = "recipe"
  }
})

local tech_effects = data.raw.technology["plutonium-nuclear-power"].effects
table.insert (tech_effects, {recipe = RTG, type = "unlock-recipe"})
table.insert (tech_effects, {recipe = RTG.."-from-"..used_up_RTG, type = "unlock-recipe"})


if data.raw.item["MOX-fuel"].icon then
  -- data.raw.item["MOX-fuel"].icons = {{icon = data.raw.item["MOX-fuel"].icon, tint = {r=0,g=1,b=1}}}
  -- data.raw.item["MOX-fuel"].icon = nil
  data.raw.item["MOX-fuel"].icon = mod_name.."/graphics/icons/MOX-fuel.png"
end




























