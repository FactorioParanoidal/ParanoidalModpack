local mod_name = "__ElectricResistance__"
local name = "hidden-electric-resistance"

local consumption = (settings.startup["electric-resistance-power-consumption"].value) .. "kW"

local buffer_capacity = (17*settings.startup["electric-resistance-power-consumption"].value) .. "J"

local energy_usage = (10*settings.startup["electric-resistance-power-consumption"].value) .. "kW"

data:extend({
  -- items --
  {
	type = "item",  
    icons = {{icon = mod_name.."/graphics/icons/"..name..".png"}}, 
	icon_size = 32,
    name = name,
    order = "e[electric-energy-interface]-b[electric-energy-interface]",
    place_result = name,
    stack_size = 50,
    subgroup = "energy"
    
  },

  
  -- entities --
  {
	type = "electric-energy-interface",
	name = name,
--	flags = {"placeable-off-grid", "not-on-map"}, -- fixed in 1.0.3
-- added from WiredLamps 1.0.3
    flags = {
		"placeable-neutral", 
		"player-creation", 
		"fast-replaceable-no-build-while-moving",
		"placeable-off-grid",
		"not-on-map",
		"not-blueprintable",
		"not-deconstructable",
		"not-selectable-in-game"
	},
	collision_mask = {}, -- nothing
	selectable_in_game = false,
	
	
    allow_copy_paste = false,

--    gui_mode = "all",
    gui_mode = "none",
	
    energy_production = "0kW",
    energy_source = {
		type = "electric",
--		buffer_capacity = "17J",
		buffer_capacity = buffer_capacity,
--		input_flow_limit = "1kW",
		input_flow_limit = consumption,
		output_flow_limit = "0kW",

		render_no_power_icon = false,
--		usage_priority = "tertiary",
		usage_priority = "primary-input",
		drain = "10kW"
    },
--    energy_usage = "10kW",
    energy_usage = energy_usage,
    icon = mod_name.."/graphics/icons/"..name..".png",
    icon_size = 32,
    max_health = 100,
--    minable = {
--      hardness = 0.2,
--      mining_time = 5,
--      results = {{used_up_name, 1},{"used-up-uranium-fuel-cell", 5}}
--      },
    
    picture = {
      filename = mod_name.."/graphics/entities/"..name..".png",
      width = 32,
      height = 32,
      priority = "low",
	},
	
    collision_box = {{-0.23, -0.23}, {0.23, 0.23}},
    selection_box = {{-0.23, -0.23}, {0.23, 0.23}},
    
    
--    vehicle_impact_sound = {
--      filename = "__base__/sound/car-metal-impact.ogg",
--      volume = 0.65
--    }
  }


})



















