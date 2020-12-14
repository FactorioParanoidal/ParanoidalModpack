local mod_name = "__OreRadar__"
local name = "ore-radar"

local tint = {0.6,0.6,0}


local icons = {{icon = "__base__/graphics/icons/radar.png", 
		icon_size = 64, 
		icon_mipmaps = 4,
		tint = tint}}


local item = {
		type = "item",
		name = name,
--		icon = "__base__/graphics/icons/radar.png",
--		icon_size = 64, icon_mipmaps = 4,
		icons = icons,
		subgroup = "defensive-structure",
		order = "d[radar]-a[radar]",
		place_result = name,
		stack_size = 50
	}
	
	
local recipe = {
		type = "recipe",
		name = name,
		ingredients =
		{
			{"electronic-circuit", 5},
			{"iron-gear-wheel", 5},
			{"iron-plate", 10},
			{"radar", 10},
		},
		result = name
	}	
	
--log ('entity = ' .. serpent.block (data.raw.radar.radar, {sortkeys = false}))

local entity = {
	type = "radar",
	name = name,
--	icon = "__base__/graphics/icons/radar.png",
--	icon_size = 64, icon_mipmaps = 4,
	icons = icons,
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 0.1,
		result = name
	},
	max_health = 250,
	corpse = "radar-remnants",
	dying_explosion = "radar-explosion",
	resistances = {
		{type = "fire",	percent = 70},
		{type = "impact", percent = 30}
	},
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	damaged_trigger_effect = {
		type = "create-entity",
		entity_name = "spark-explosion",
		offset_deviation = {{-0.5,-0.5},{0.5,0.5}},
		offsets = {{0,	1}},
		damage_type_filters = "fire"
	},
--	energy_per_sector = "10MJ",
	energy_per_sector = "100MJ",
	max_distance_of_sector_revealed = 1,
	max_distance_of_nearby_sector_revealed = 1,
--	energy_per_nearby_scan = "250kJ",
	energy_per_nearby_scan = "10kJ",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
--	energy_usage = "300kW",
	energy_usage = "1200kW",
	integration_patch = {
		filename = "__base__/graphics/entity/radar/radar-integration.png",
		priority = "low",
		width = 119,
		height = 108,
		direction_count = 1,
		shift = {0.046875,0.125},
		hr_version = {
			filename = "__base__/graphics/entity/radar/hr-radar-integration.png",
			priority = "low",
			width = 238,
			height = 216,
			direction_count = 1,
			shift = {0.046875,0.125},
			scale = 0.5
		}
	},
	pictures = {
		layers = {
			{
				filename = "__base__/graphics/entity/radar/radar.png",
				tint = tint,
				priority = "low",
				width = 98,
				height = 128,
				apply_projection = false,
				direction_count = 64,
				line_length = 8,
				shift = {0.03125,-0.5},
				hr_version = {
					filename = "__base__/graphics/entity/radar/hr-radar.png",
					tint = tint,
					priority = "low",
					width = 196,
					height = 254,
					apply_projection = false,
					direction_count = 64,
					line_length = 8,
					shift = {0.03125,-0.5},
					scale = 0.5
				}
			},
			{
				filename = "__base__/graphics/entity/radar/radar-shadow.png",
				priority = "low",
				width = 172,
				height = 94,
				apply_projection = false,
				direction_count = 64,
				line_length = 8,
				shift = {1.21875,0.09375},
				draw_as_shadow = true,
				hr_version = {
					filename = "__base__/graphics/entity/radar/hr-radar-shadow.png",
					priority = "low",
					width = 343,
					height = 186,
					apply_projection = false,
					direction_count = 64,
					line_length = 8,
					shift = {1.2265625,0.09375},
					draw_as_shadow = true,
					scale = 0.5
				}
			}
		}
	},
	vehicle_impact_sound = {
		{
			filename = "__base__/sound/car-metal-impact-2.ogg",
			volume = 0.5
		},
		{
			filename = "__base__/sound/car-metal-impact-3.ogg",
			volume = 0.5
		},
		{
			filename = "__base__/sound/car-metal-impact-4.ogg",
			volume = 0.5
		},
		{
			filename = "__base__/sound/car-metal-impact-5.ogg",
			volume = 0.5
		},
		{
			filename = "__base__/sound/car-metal-impact-6.ogg",
			volume = 0.5
		}
	},
	working_sound = {
		sound = {
			{
				filename = "__base__/sound/radar.ogg",
				volume = 0.8
			}
		},
		max_sounds_per_type = 3,
		use_doppler_shift = false
	},
	radius_minimap_visualisation_color = {r = 0.06, g = 0.09, b = 0.25, a = 0.25},
	rotation_speed = 0.01
}

data:extend({item, recipe, entity})
-- (technology enabled)


-- test
if false then -- disabled, but works for vanilla radar technology
	
	data.raw.recipe.radar.enabled = false
	local radar_technology = {
		type = "technology",
		name = "radar",
--		icon = "__base__/graphics/entity/radar/radar.png",
		icon = "__OreRadar__/graphics/technology/radar.png",
		icon_size = 128,
--		prerequisites = {},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "radar"
			}
		},
		unit =
		{
			count = 10,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		}
	}
	data:extend({radar_technology})
	log ("added radar technology")
end