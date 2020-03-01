data:extend({
--Item
   {
		type = "item",
		name = "big-lab",
		icon = "__BigLab__/graphics/icon/biglab.png",
		icon_size = 32,
		--- flags = {"goes-to-quickbar"},
		subgroup = "production-machine",
		order = "h[lab]",
		place_result = "big-lab",
		stack_size = 1
	},
--Recipe
	{
		type = "recipe",
		name = "big-lab",
		energy_required = 20,
		enabled = "false",
		ingredients =
		{
		  {"processing-unit", 50},
		  {"lab-2", 30},
		},
		result = "big-lab"
	},
--Entity
	{
		type = "lab",
		name = "big-lab",
		icon = "__BigLab__/graphics/icon/biglab.png",
		icon_size = 32,
		flags = {"placeable-player", "player-creation"},
		minable = {mining_time = 1, result = "big-lab"},
		max_health = 1500,
		crafting_categories = {"chemistry"},
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		collision_box = {{-8.5, -8.5}, {8.5, 8.5}},
		selection_box = {{-9, -9}, {9, 9}},
		light = {intensity = 0.75, size = 8, color = {r = 1.0, g = 1.0, b = 1.0}},
		on_animation = {
      layers =
      {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
          width = 98,
          height = 87,
          frame_count = 33,
          line_length = 11,
		  scale = 6,
          animation_speed = 1 / 3,
          shift = util.by_pixel(0, 1.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab.png",
            width = 194,
            height = 174,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 3
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-integration.png",
          width = 122,
          height = 81,
          frame_count = 1,
		  scale = 6,
          line_length = 1,
          repeat_count = 33,
          animation_speed = 1 / 3,
          shift = util.by_pixel(0, 15.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 3
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-shadow.png",
          width = 122,
          height = 68,
          frame_count = 1,
          line_length = 1,
          repeat_count = 33,
		  scale = 6,
          animation_speed = 1 / 3,
          shift = util.by_pixel(13, 11),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 3,
            draw_as_shadow = true
          }
        }
      }
    },
    off_animation =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
          width = 98,
          height = 87,
          frame_count = 1,
		  scale = 6,
          shift = util.by_pixel(0, 1.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab.png",
            width = 194,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(0, 1.5),
            scale = 3
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-integration.png",
          width = 122,
          height = 81,
		  scale = 6,
          frame_count = 1,
          shift = util.by_pixel(0, 15.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            shift = util.by_pixel(0, 15.5),
            scale = 3
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-shadow.png",
          width = 122,
          height = 68,
          frame_count = 1,
          shift = util.by_pixel(13, 11),
		  scale = 6,
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            shift = util.by_pixel(13, 11),
            draw_as_shadow = true,
            scale = 3
          }
        }
      }
    },
		working_sound =
		{
		  sound =
		  {
			filename = "__base__/sound/lab.ogg",
			volume = 0.7
		  },
		  apparent_volume = 1
		},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
		  type = "electric",
		  usage_priority = "secondary-input"
		},
		energy_usage = "1000kW",
		researching_speed = 100,
		inputs =
		{
		  "automation-science-pack",
		  "logistic-science-pack",
		  "chemical-science-pack",
		  "military-science-pack",
		  "production-science-pack",
		  "utility-science-pack",
		  "space-science-pack"		  
		},
		module_specification =
		{
		  module_slots = 6,
		  max_entity_info_module_icons_per_row = 3,
		  max_entity_info_module_icon_rows = 1,
		  module_info_icon_shift = {0, 0.9}
		}
	},
	
	
	
})

 
if (mods['bobtech']) then 
data.raw["lab"]["big-lab"].inputs =
		{
		  "automation-science-pack",
		  "logistic-science-pack",
		  "chemical-science-pack",
		  "military-science-pack",
		  "production-science-pack",
		  "utility-science-pack",
		  "space-science-pack",
		  "advanced-logistic-science-pack",  --DrD
	---	  "transport-science-pack",
		  "science-pack-gold",
		  "alien-science-pack",
		  "alien-science-pack-blue",
		  "alien-science-pack-orange",
		  "alien-science-pack-purple",
		  "alien-science-pack-yellow",
		  "alien-science-pack-green",
		  "alien-science-pack-red"
		}
end


if (mods['SchallAlienLoot']) then 
data.raw["lab"]["big-lab"].inputs =
		{
		  "automation-science-pack",
		  "logistic-science-pack",
		  "chemical-science-pack",
		  "military-science-pack",
		  "production-science-pack",
		  "utility-science-pack",
		  "space-science-pack",
		  "alien-science-pack",
	---	  "logistic-science-pack",
	---	  "science-pack-gold",
	---	  "alien-science-pack",
	---	  "alien-science-pack-blue",
	---	  "alien-science-pack-orange",
	---	  "alien-science-pack-purple",
	---	  "alien-science-pack-yellow",
	---	  "alien-science-pack-green",
	---	  "alien-science-pack-red"
		}
end