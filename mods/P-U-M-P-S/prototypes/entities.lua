------------------
---- data.lua ----
------------------

-- Settings host
local top_priority_enabled = OSM.lib.get_setting_boolean("osm-pumps-power-priority")
local power_enabled = OSM.lib.get_setting_boolean("osm-pumps-enable-power")
local water_pumpjack_enabled = OSM.lib.get_setting_boolean("osm-pumps-enable-ground-water-pumpjacks")
local burner_enabled = OSM.lib.get_setting_boolean("osm-pumps-burner-offshore-pump")

-- Local functions host
local OSM_local = require("utils.lib")
local OSM_anim = require("utils.animation")-- Fetch animation

-- Fetch external properties
local graphics_set = OSM_anim.template_unpowered_animation() -- unpowered pump uses graphics_set
local animation = OSM_anim.template_powered_animation -- powered pump uses animation
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local electric_priority = "secondary-input"
if top_priority_enabled then electric_priority = "primary-input" end

-- Set entity properties
local crafting_categories = {"pump-water"}
local fixed_recipe = "water-offshore"
local collision_mask = {"object-layer", "train-layer"}
local center_collision_mask = {"water-tile", "object-layer", "player-layer"}
local collision_box = {{-0.6, -1.05}, {0.6, 0.3}}
local selection_box = {{-0.6, -1.49}, {0.6, 0.49}}
local adjacent_tile_collision_box = {{-1, -2}, {1, -1}}
local tile_width = 1
local tile_height = 1
local fast_replaceable_group = "offshore-pumps"
local icon_size = 64
local icon_mipmaps = 4
local flags = {"hidden", "placeable-neutral", "player-creation", "filter-directions"}
local placeholder_flags = {"placeable-neutral", "player-creation", "filter-directions"}
local corpse = "offshore-pump-remnants"
local dying_explosion = "offshore-pump-explosion"
local alert_icon_shift = util.by_pixel(0, 0)
local resistances = {{type = "fire", percent = 70}}
local damaged_trigger_effect = hit_effects.entity()
local circuit_wire_connection_points = circuit_connector_definitions["offshore-pump"].points
local circuit_connector_sprites = circuit_connector_definitions["offshore-pump"].sprites
local circuit_wire_max_distance = default_circuit_wire_max_distance
local squeak_behaviour = false
local open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85}
local close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75}
local vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65}
local burner_source = {type = "burner", fuel_category = "chemical", effectivity = 1, fuel_inventory_size = 1, emissions_per_minute = 3}
local burner_effects = {"consumption", "pollution"}
local electric_source = {type = "electric", usage_priority = electric_priority}
local electric_effects = {"consumption"}
local working_sound =
{
	sound =
	{
		{
			filename = "__base__/sound/offshore-pump.ogg",
			volume = 0.45
		}
	},
	match_volume_to_activity = true,
	audible_distance_modifier = 0.5,
	max_sounds_per_type = 3,
	fade_in_ticks = 4,
	fade_out_ticks = 20
}
local water_reflection =
{
	pictures =
	{
		filename = "__base__/graphics/entity/offshore-pump/offshore-pump-reflection.png",
		priority = "extra-high",
		width = 132,
		height = 156,
		shift = util.by_pixel(0, 19),
		variation_count = 4,
		scale = 1
	},
	rotate = false,
	orientation_to_variation = true
}
local fluid_box = -- unpowered pump uses fluid_box
{
	base_area = 1,
	base_level = 1,
	pipe_covers = pipecoverspictures(),
	production_type = "output",
	pipe_connections =
	{
		{
			position = {0, 1},
			type = "output"
		}
	}
}
local fluid_boxes = -- powered pump uses fluid_boxes
{
	fluid_box,
	off_when_no_fluid_recipe = false
}
local placeable_position_visualization =
{
	filename = "__core__/graphics/cursor-boxes-32x32.png",
	priority = "extra-high-no-scale",
	width = 64,
	height = 64,
	scale = 0.5,
	x = 3*64
}

-- Make template for unpowered offshore pump
local unpowered_pump_template =
{
	-- Template unique properties
	type = "offshore-pump",
	fluid = "water",
	always_draw_fluid = true,
	min_perceived_performance = 0.5,
	fluid_box_tile_collision_test = {"ground-tile"},
	adjacent_tile_collision_test = {"water-tile" },
	adjacent_tile_collision_mask = { "ground-tile"},
	graphics_set = graphics_set,
	flags = placeholder_flags,
	
	-- Template common properties
	collision_mask = collision_mask,
	center_collision_mask = center_collision_mask,
	collision_box = collision_box,
	selection_box = selection_box,
	adjacent_tile_collision_box = adjacent_tile_collision_box,
	tile_width = tile_width,
	tile_height = tile_height,
	fast_replaceable_group = fast_replaceable_group,
	icon_size = icon_size,
	icon_mipmaps = icon_mipmaps,
	corpse = corpse,
	dying_explosion = dying_explosion,
	alert_icon_shift = alert_icon_shift,
	resistances = resistances,
	damaged_trigger_effect = damaged_trigger_effect,
	circuit_wire_connection_points = circuit_wire_connection_points,
	circuit_connector_sprites = circuit_connector_sprites,
	circuit_wire_max_distance = circuit_wire_max_distance,
	squeak_behaviour = squeak_behaviour,
	open_sound = open_sound,
	close_sound = close_sound,
	vehicle_impact_sound =  vehicle_impact_sound,
	working_sound = working_sound,
	water_reflection = water_reflection,
	placeable_position_visualization = placeable_position_visualization,
	fluid_box = fluid_box
}

-- Make template for electric offshore pump
local powered_pump_template =
{
	-- Template unique properties
	type = "assembling-machine",
	energy_source = electric_source,
	allowed_effects = electric_effects,
	flags = flags,

	-- Template common properties
	crafting_categories = crafting_categories,
	fixed_recipe = fixed_recipe,
	collision_mask = collision_mask,
	center_collision_mask = center_collision_mask,
	collision_box = collision_box,
	selection_box = selection_box,
	adjacent_tile_collision_box = adjacent_tile_collision_box,
	tile_width = tile_width,
	tile_height = tile_height,
	fast_replaceable_group = fast_replaceable_group,
	icon_size = icon_size,
	icon_mipmaps = icon_mipmaps,
	corpse = corpse,
	dying_explosion = dying_explosion,
	alert_icon_shift = alert_icon_shift,
	resistances = resistances,
	damaged_trigger_effect = damaged_trigger_effect,
	circuit_wire_connection_points = circuit_wire_connection_points,
	circuit_connector_sprites = circuit_connector_sprites,
	circuit_wire_max_distance = circuit_wire_max_distance,
	squeak_behaviour = squeak_behaviour,
	open_sound = open_sound,
	close_sound = close_sound,
	vehicle_impact_sound =  vehicle_impact_sound,
	working_sound = working_sound,
	water_reflection = water_reflection,
	placeable_position_visualization = placeable_position_visualization,
	fluid_boxes = fluid_boxes
}

-- Make offshore pumps based on power settings
if power_enabled then

	-- Make offshore pump 0
	local offshore_placeholder_0 = table.deepcopy(unpowered_pump_template) -- Placeholder 0
	offshore_placeholder_0.name = "offshore-pump-0-placeholder"
	offshore_placeholder_0.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-0.png"
	offshore_placeholder_0.minable = {mining_time = 0.1, result = "offshore-pump-0"}
	offshore_placeholder_0.max_health = 100
	offshore_placeholder_0.pumping_speed = 5
	data:extend({offshore_placeholder_0})

	local offshore_pump_0 = table.deepcopy(powered_pump_template) -- Offshore pump 0
	offshore_pump_0.name = "offshore-pump-0"
	offshore_pump_0.subgroup = "other"
	offshore_pump_0.next_upgrade = "offshore-pump-1-placeholder"
	offshore_pump_0.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-0.png"
	offshore_pump_0.minable = {mining_time = 0.1, result = "offshore-pump-0"}
	offshore_pump_0.placeable_by = {item = "offshore-pump-0", count = 1}
	offshore_pump_0.max_health = 100
	offshore_pump_0.crafting_speed = 1
	offshore_pump_0.animation = animation(0.25)
	offshore_pump_0.energy_usage = "900kW" --drd 400
	if burner_enabled then
		offshore_pump_0.energy_source = burner_source
		offshore_pump_0.allowed_effects = burner_effects
		offshore_pump_0.energy_usage = "900kW" --drd 400
	end
	data:extend({offshore_pump_0})

	-- Make offshore pump 1
	local offshore_placeholder_1 = table.deepcopy(unpowered_pump_template) -- Placeholder 1
	offshore_placeholder_1.name = "offshore-pump-1-placeholder"
	offshore_placeholder_1.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-1.png"
	offshore_placeholder_1.minable = {mining_time = 0.1, result = "offshore-pump-1"}
	offshore_placeholder_1.max_health = 150
	offshore_placeholder_1.pumping_speed = 20
	data:extend({offshore_placeholder_1})
	
	local offshore_pump_1 = table.deepcopy(powered_pump_template) -- Offshore pump 1
	offshore_pump_1.name = "offshore-pump-1"
	offshore_pump_1.subgroup = "other"
	offshore_pump_1.next_upgrade = "offshore-pump-2-placeholder"
	offshore_pump_1.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-1.png"
	offshore_pump_1.minable = {mining_time = 0.1, result = "offshore-pump-1"}
	offshore_pump_1.placeable_by = {item = "offshore-pump-1", count = 1}
	offshore_pump_1.max_health = 150
	offshore_pump_1.crafting_speed = 4
	offshore_pump_1.animation = animation(0.06)
	offshore_pump_1.energy_usage = "1200kW"
	data:extend({offshore_pump_1})
	
	-- Make offshore pump 2
	local offshore_placeholder_2 = table.deepcopy(unpowered_pump_template) -- Placeholder 2
	offshore_placeholder_2.name = "offshore-pump-2-placeholder"
	offshore_placeholder_2.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-2.png"
	offshore_placeholder_2.minable = {mining_time = 0.1, result = "offshore-pump-2"}
	offshore_placeholder_2.max_health = 200
	offshore_placeholder_2.pumping_speed = 40
	data:extend({offshore_placeholder_2})
	
	local offshore_pump_2 = table.deepcopy(powered_pump_template) -- Offshore pump 2
	offshore_pump_2.name = "offshore-pump-2"
	offshore_pump_2.subgroup = "other"
	offshore_pump_2.next_upgrade = "offshore-pump-3-placeholder"
	offshore_pump_2.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-2.png"
	offshore_pump_2.minable = {mining_time = 0.1, result = "offshore-pump-2"}
	offshore_pump_2.placeable_by = {item = "offshore-pump-2", count = 1}
	offshore_pump_2.max_health = 200
	offshore_pump_2.crafting_speed = 8
	offshore_pump_2.animation = animation(0.03)
	offshore_pump_2.energy_usage = "2000kW"
	data:extend({offshore_pump_2})
	
	-- Make offshore pump 3
	local offshore_placeholder_3 = table.deepcopy(unpowered_pump_template) -- Placeholder 3
	offshore_placeholder_3.name = "offshore-pump-3-placeholder"
	offshore_placeholder_3.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-3.png"
	offshore_placeholder_3.minable = {mining_time = 0.1, result = "offshore-pump-3"}
	offshore_placeholder_3.max_health = 250
	offshore_placeholder_3.pumping_speed = 60
	data:extend({offshore_placeholder_3})
	
	local offshore_pump_3 = table.deepcopy(powered_pump_template) -- Offshore pump 3
	offshore_pump_3.name = "offshore-pump-3"
	offshore_pump_3.subgroup = "other"
	offshore_pump_3.next_upgrade = "offshore-pump-4-placeholder"
	offshore_pump_3.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-3.png"
	offshore_pump_3.minable = {mining_time = 0.1, result = "offshore-pump-3"}
	offshore_pump_3.placeable_by = {item = "offshore-pump-3", count = 1}
	offshore_pump_3.max_health = 250
	offshore_pump_3.crafting_speed = 12
	offshore_pump_3.animation = animation(0.02)
	offshore_pump_3.energy_usage = "2800kW"
	data:extend({offshore_pump_3})
	
	-- Make offshore pump 4
	local offshore_placeholder_4 = table.deepcopy(unpowered_pump_template) -- Placeholder 4
	offshore_placeholder_4.name = "offshore-pump-4-placeholder"
	offshore_placeholder_4.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-4.png"
	offshore_placeholder_4.minable = {mining_time = 0.1, result = "offshore-pump-4"}
	offshore_placeholder_4.max_health = 300
	offshore_placeholder_4.pumping_speed = 80
	data:extend({offshore_placeholder_4})

	local offshore_pump_4 = table.deepcopy(powered_pump_template) -- Offshore pump 4
	offshore_pump_4.name = "offshore-pump-4"
	offshore_pump_4.subgroup = "other"
	offshore_pump_4.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-4.png"
	offshore_pump_4.minable = {mining_time = 0.1, result = "offshore-pump-4"}
	offshore_pump_4.placeable_by = {item = "offshore-pump-4", count = 1}
	offshore_pump_4.max_health = 300
	offshore_pump_4.crafting_speed = 16
	offshore_pump_4.animation = animation(0.01)
	offshore_pump_4.energy_usage = "3600kW"
	data:extend({offshore_pump_4})

else --error("\nDISABLING POWER REQUIREMENTS FOR OFFSHORE PUMPS BREAKS THE FIRST LAW OF THERMODYNAMICS!!!\nPLEASE RESET MOD SETTINGS!")

	-- Make absolutely-fine-perpetual-motion water-thing 0
	local offshore_pump_0 = table.deepcopy(unpowered_pump_template)
	offshore_pump_0.name = "offshore-pump-0"
	offshore_pump_0.next_upgrade = "offshore-pump-1"
	offshore_pump_0.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-0.png"
	offshore_pump_0.minable = {mining_time = 0.1, result = "offshore-pump-0"}
	offshore_pump_0.max_health = 100
	offshore_pump_0.pumping_speed = 5
	data:extend({offshore_pump_0})

	-- Make absolutely-fine-perpetual-motion water-thing 1
	local offshore_pump_1 = table.deepcopy(unpowered_pump_template)
	offshore_pump_1.name = "offshore-pump-1"
	offshore_pump_1.next_upgrade = "offshore-pump-2"
	offshore_pump_1.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-1.png"
	offshore_pump_1.minable = {mining_time = 0.1, result = "offshore-pump-1"}
	offshore_pump_1.placeable_by = {item = "offshore-pump-1", count = 1}
	offshore_pump_1.pumping_speed = 20
	offshore_pump_1.max_health = 150
	data:extend({offshore_pump_1})

	-- Make absolutely-fine-perpetual-motion water-thing 2
	local offshore_pump_2 = table.deepcopy(unpowered_pump_template)
	offshore_pump_2.name = "offshore-pump-2"
	offshore_pump_2.next_upgrade = "offshore-pump-3"
	offshore_pump_2.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-2.png"
	offshore_pump_2.minable = {mining_time = 0.1, result = "offshore-pump-2"}
	offshore_pump_2.placeable_by = {item = "offshore-pump-2", count = 1}
	offshore_pump_2.pumping_speed = 40
	offshore_pump_2.max_health = 200
	data:extend({offshore_pump_2})

	-- Make absolutely-fine-perpetual-motion water-thing 3
	local offshore_pump_3 = table.deepcopy(unpowered_pump_template)
	offshore_pump_3.name = "offshore-pump-3"
	offshore_pump_3.next_upgrade = "offshore-pump-4"
	offshore_pump_3.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-3.png"
	offshore_pump_3.minable = {mining_time = 0.1, result = "offshore-pump-3"}
	offshore_pump_3.placeable_by = {item = "offshore-pump-3", count = 1}
	offshore_pump_3.pumping_speed = 60
	offshore_pump_3.max_health = 250
	data:extend({offshore_pump_3})
	
	-- Make absolutely-fine-perpetual-motion water-thing 4
	local offshore_pump_4 = table.deepcopy(unpowered_pump_template)
	offshore_pump_4.name = "offshore-pump-4"
	offshore_pump_4.icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-4.png"
	offshore_pump_4.minable = {mining_time = 0.1, result = "offshore-pump-4"}
	offshore_pump_4.placeable_by = {item = "offshore-pump-4", count = 1}
	offshore_pump_4.pumping_speed = 80
	offshore_pump_4.max_health = 300
	data:extend({offshore_pump_4})
end

-- Water pumpjacks
if water_pumpjack_enabled then

	-- Fetch animation
	local animation = OSM_anim.water_pumpjack_animation
	
	-- Set entity properties
	local fixed_recipe = "water-ground"
	local collision_mask = {"object-layer", "player-layer", "resource-layer"}
	local collision_box = {{-1.2, -1.2}, {1.2, 1.2}}
	local selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
	local fast_replaceable_group = "water-pumpjacks"
	local drawing_box = {{-1.6, -2.5}, {1.5, 1.6}}
	local flags = {"placeable-neutral", "player-creation"}
	local dying_explosion = "pumpjack-explosion"
	local circuit_wire_connection_points = circuit_connector_definitions["pumpjack"].points
	local circuit_connector_sprites = circuit_connector_definitions["pumpjack"].sprites
	local allowed_effects = {"consumption", "pollution"}
	local working_sound =
	{
		sound =
		{
			{
				filename = "__base__/sound/pumpjack.ogg",
				volume = 0.45
			}
		},
		match_volume_to_activity = true,
		audible_distance_modifier = 0.5,
		max_sounds_per_type = 3,
		fade_in_ticks = 4,
		fade_out_ticks = 20
	}
	local fluid_boxes =
	{
		fluid_box =
		{
			base_area = 1,
			base_level = 1,
			pipe_covers = pipecoverspictures(),
			production_type = "output",
			pipe_connections =
			{
				{
					positions = { {1, -2}, {2, -1}, {-1, 2}, {-2, 1} }
				}
			}
		},
		off_when_no_fluid_recipe = false
	}
	local energy_source =
	{
		type = "electric",
		usage_priority = electric_priority
	}
	local corpse =
	{
		type = "corpse",
		name = "water-pumpjack-remnants",
		icon = "__P-U-M-P-S__/graphics/icons/water-pumpjack.png",
		icon_size = 64,
		icon_mipmaps = 4,
		flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
		subgroup = "extraction-machine-remnants",
		order = "a-d-a",
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		tile_width = 3,
		tile_height = 3,
		selectable_in_game = false,
		time_before_removed = 60 * 60 * 15, -- 15 minutes
		final_render_layer = "remnants",
		remove_on_tile_placement = false,
		animation = make_rotated_animation_variations_from_sheet(2,
		{
			layers =
			{
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/remnants/water-pumpjack-remnants.png",
					line_length = 1,
					width = 138,
					height = 142,
					frame_count = 1,
					direction_count = 1,
					shift = util.by_pixel(0, 3),
					hr_version =
					{
						filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/remnants/hr-water-pumpjack-remnants.png",
						line_length = 1,
						width = 274,
						height = 284,
						frame_count = 1,
						direction_count = 1,
						shift = util.by_pixel(0, 3.5),
						scale = 0.5,
					}
				}
			}
		})
	}	data:extend({corpse}) local corpse = "water-pumpjack-remnants"
	
	-- Make template for water pumpjacks
	local pumpjack_template =
	{
		type = "assembling-machine",
		crafting_categories = crafting_categories,
		fixed_recipe = fixed_recipe,
		collision_mask = collision_mask,
		collision_box = collision_box,
		selection_box = selection_box,
		fast_replaceable_group = fast_replaceable_group,
		drawing_box = drawing_box,
		icon_size = icon_size,
		icon_mipmaps = icon_mipmaps,
		flags = flags,
		corpse = corpse,
		dying_explosion = dying_explosion,
		resistances = resistances,
		damaged_trigger_effect = damaged_trigger_effect,
		circuit_wire_connection_points = circuit_wire_connection_points,
		circuit_connector_sprites = circuit_connector_sprites,
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		squeak_behaviour = squeak_behaviour,
		allowed_effects = allowed_effects,
		energy_source = energy_source,
		fluid_boxes = fluid_boxes,
		open_sound = open_sound,
		close_sound = close_sound,
		vehicle_impact_sound =  vehicle_impact_sound,
		working_sound = working_sound
	}

	-- Make water pumpjack 1
	local water_pumpjack_1 = table.deepcopy(pumpjack_template)
	water_pumpjack_1.name = "water-pumpjack-1"
	water_pumpjack_1.next_upgrade = "water-pumpjack-2"
	water_pumpjack_1.icon = "__P-U-M-P-S__/graphics/icons/water-pumpjack.png"
	water_pumpjack_1.minable = {mining_time = 1, result = "water-pumpjack-1"}
	water_pumpjack_1.animation = animation(0.5)
	water_pumpjack_1.max_health = 100
	water_pumpjack_1.crafting_speed = 1
	water_pumpjack_1.energy_usage = "300kW"
	water_pumpjack_1.order = "8==D" -- yeah, it's a dick bitch!
	data:extend({water_pumpjack_1})

	-- Make water pumpjack 2
	local water_pumpjack_2 = table.deepcopy(pumpjack_template)
	water_pumpjack_2.name = "water-pumpjack-2"
	water_pumpjack_2.next_upgrade = "water-pumpjack-3"
	water_pumpjack_2.icon = "__P-U-M-P-S__/graphics/icons/water-pumpjack.png"
	water_pumpjack_2.minable = {mining_time = 1, result = "water-pumpjack-2"}
	water_pumpjack_2.animation = animation(0.25)
	water_pumpjack_2.max_health = 150
	water_pumpjack_2.crafting_speed = 2
	water_pumpjack_2.energy_usage = "550kW"
	water_pumpjack_2.order = "8==D" -- yeah, it's a dick bitch!
	data:extend({water_pumpjack_2})

	-- Make water pumpjack 3
	local water_pumpjack_3 = table.deepcopy(pumpjack_template)
	water_pumpjack_3.name = "water-pumpjack-3"
	water_pumpjack_3.next_upgrade = "water-pumpjack-4"
	water_pumpjack_3.icon = "__P-U-M-P-S__/graphics/icons/water-pumpjack.png"
	water_pumpjack_3.minable = {mining_time = 1, result = "water-pumpjack-3"}
	water_pumpjack_3.animation = animation(0.16)
	water_pumpjack_3.max_health = 200
	water_pumpjack_3.crafting_speed = 3
	water_pumpjack_3.energy_usage = "750kW"
	water_pumpjack_3.order = "8==D" -- yeah, it's a dick bitch!
	data:extend({water_pumpjack_3})

	-- Make water pumpjack 4
	local water_pumpjack_4 = table.deepcopy(pumpjack_template)
	water_pumpjack_4.name = "water-pumpjack-4"
	water_pumpjack_4.next_upgrade = "water-pumpjack-5"
	water_pumpjack_4.icon = "__P-U-M-P-S__/graphics/icons/water-pumpjack.png"
	water_pumpjack_4.minable = {mining_time = 1, result = "water-pumpjack-4"}
	water_pumpjack_4.animation = animation(0.125)
	water_pumpjack_4.max_health = 250
	water_pumpjack_4.crafting_speed = 4
	water_pumpjack_4.energy_usage = "1000kW"
	water_pumpjack_4.order = "8==D" -- yeah, it's a dick bitch!
	data:extend({water_pumpjack_4})

	-- Make water pumpjack 5
	local water_pumpjack_5 = table.deepcopy(pumpjack_template)
	water_pumpjack_5.name = "water-pumpjack-5"
	water_pumpjack_5.icon = "__P-U-M-P-S__/graphics/icons/water-pumpjack.png"
	water_pumpjack_5.minable = {mining_time = 1, result = "water-pumpjack-5"}
	water_pumpjack_5.animation = animation(0.1)
	water_pumpjack_5.max_health = 300
	water_pumpjack_5.crafting_speed = 5
	water_pumpjack_5.energy_usage = "1250kW"
	water_pumpjack_5.order = "8==D" -- yeah, it's a dick bitch!
	data:extend({water_pumpjack_5})
end