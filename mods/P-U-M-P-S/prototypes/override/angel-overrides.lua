--------------------------
---- data-updates.lua ----
--------------------------

-- Settings host
local top_priority_enabled = OSM.lib.get_setting_boolean("osm-pumps-power-priority")
local power_enabled = OSM.lib.get_setting_boolean("osm-pumps-enable-power")
local water_pumpjack_enabled = OSM.lib.get_setting_boolean("osm-pumps-enable-ground-water-pumpjacks")

local unpowered_pump = data.raw["offshore-pump"]
local powered_pump = data.raw["assembling-machine"]
local item = data.raw.item
local technology = data.raw.technology

local brn_tooltip = "[img=tooltip-category-chemical]"
local pwr_tooltip = "[img=tooltip-category-electricity]"
local tooltip_font = "[font=default-bold][color=#f5cb48]"
local end_tooltip = "[/color][/font]"
local field_font = "\n[font=default-semibold][color=#ffe6c0]"
local field_font_2 = "[font=default-semibold][color=#ffe6c0]"
local end_font = ": [/color][/font]"

local offshore_name = { "entity-name.offshore-pump" }
local pumpjack_name = { "string.water-pumpjack" }
local offshore_desc = { "entity-description.offshore-pump" }
local electric_offshore = { "string.electric-offshore-pump" }
local burner_offshore = { "string.burner-offshore-pump" }

local pumpjack_tech_desc = { "technology-description.water-pumpjack" }

local seafloor_pump = { "entity-name.seafloor-pump" }
local seafloor_pump = { "entity-name.seafloor-pump-2" }
local seafloor_pump = { "entity-name.seafloor-pump-3" }
local water_bore = { "entity-name.ground-water-pump" }

local consumes = { "tooltip-category.consumes" }
local burnable_fuel = { "fuel-category-name.chemical" }
local electricity = { "tooltip-category.electricity" }
local pumping_speed = { "description.pumping-speed" }
local max_consumption = { "description.max-energy-consumption" }
local min_consumption = { "description.min-energy-consumption" }

if not mods["angelsrefining"] then
	return
end

-- Disable bobmining water miners
OSM.lib.disable_prototype("all", "water-miner-1")
OSM.lib.disable_prototype("all", "water-miner-2")
OSM.lib.disable_prototype("all", "water-miner-3")
OSM.lib.disable_prototype("all", "water-miner-4")
OSM.lib.disable_prototype("all", "water-miner-5")

-- force angel offshore pumps to comply with the laws of physics
if power_enabled then
	-- Set common properties
	local crafting_categories = { "pump-water" }
	local fixed_recipe = "angel-viscous-mud"
	local fixed_recipe_2 = "angel-viscous-mud-2"
	local fixed_recipe_3 = "angel-viscous-mud-3"
	local flags = { "hidden", "placeable-neutral", "player-creation", "filter-directions" }
	local fluid_boxes = {
		{
			base_area = 1,
			base_level = 1,
			pipe_covers = pipecoverspictures(),
			production_type = "output",
			pipe_connections = {
				{
					position = { 0, 1 },
					type = "output",
				},
			},
		},
		off_when_no_fluid_recipe = false,
	}

	-- Mud [recipe - seafloor]
	local mud_seafloor = table.deepcopy(data.raw["recipe"]["water-offshore"])
	mud_seafloor.name = "angel-viscous-mud"
	mud_seafloor.results = { { type = "fluid", name = "water-viscous-mud", amount = 300 } }
	data:extend({ mud_seafloor })

	-- Make seafloor pump placeholder
	local seafloor_pump_placeholder = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump"])
	seafloor_pump_placeholder.name = "seafloor-pump-placeholder"
	seafloor_pump_placeholder.localised_name = { "entity-name.seafloor-pump-placeholder" }
	seafloor_pump_placeholder.localised_description = { "entity-description.seafloor-pump-placeholder" }
	data:extend({ seafloor_pump_placeholder })
	data.raw.item["seafloor-pump"].place_result = "seafloor-pump-placeholder"
	data.raw.item["seafloor-pump"].localised_description = { "item-description.seafloor-pump-placeholder" }

	-- Make seafloor pump
	local animation = data.raw["offshore-pump"]["seafloor-pump"].picture
	data.raw["offshore-pump"]["seafloor-pump"] = nil

	local seafloor_pump = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump-placeholder"])
	seafloor_pump.name = "seafloor-pump"
	seafloor_pump.subgroup = "other"
	seafloor_pump.type = "assembling-machine"
	seafloor_pump.placeable_by = { item = "seafloor-pump", count = 1 }
	seafloor_pump.crafting_speed = 1
	seafloor_pump.energy_source = { type = "electric", usage_priority = "secondary-input" }
	seafloor_pump.energy_usage = "300kW"
	seafloor_pump.allowed_effects = { "consumption" }
	seafloor_pump.localised_description = { "entity-description.seafloor-pump" }
	--
	seafloor_pump.flags = flags
	seafloor_pump.crafting_categories = crafting_categories
	seafloor_pump.fixed_recipe = fixed_recipe
	seafloor_pump.fluid_boxes = fluid_boxes
	seafloor_pump.animation = animation
	-- Remove code leftovers
	seafloor_pump.picture = nil
	seafloor_pump.pumping_speed = nil
	seafloor_pump.fluid_box = nil
	data:extend({ seafloor_pump })

	--Re-add seafloor pumps that angels removed
	--TODO: расплести всю эту помойку
	data:extend({
		{
			type = "item",
			name = "seafloor-pump-2",
			icons = angelsmods.functions.add_number_icon_layer({
				{
					icon = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2-ico.png",
					icon_size = 32,
				},
			}, 2, angelsmods.refining.number_tint),
			subgroup = "washing-building",
			order = "a",
			place_result = "seafloor-pump-2",
			stack_size = 20,
		},
		{
			type = "offshore-pump",
			name = "seafloor-pump-2",
			icons = angelsmods.functions.add_number_icon_layer({
				{
					icon = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2-ico.png",
					icon_size = 32,
				},
			}, 2, angelsmods.refining.number_tint),
			flags = { "placeable-neutral", "player-creation", "filter-directions" },
			collision_mask = { "object-layer", "train-layer" }, -- collide just with object-layer and train-layer which don't collide with water, this allows us to build on 1 tile wide ground
			center_collision_mask = { "water-tile", "object-layer", "player-layer" }, -- to test that tile directly under the pump is ground
			fluid_box_tile_collision_test = { "ground-tile" },
			adjacent_tile_collision_test = { "water-tile" },
			adjacent_tile_collision_mask = { "ground-tile" }, -- to prevent building on edge of map :(
			adjacent_tile_collision_box = { { -2, -3 }, { 2, -2 } },
			minable = { mining_time = 1, result = "seafloor-pump-2" },
			fast_replaceable_group = "seafloor-pump",
			max_health = 320,
			corpse = "small-remnants",
			fluid = "water-viscous-mud",
			resistances = {
				{
					type = "fire",
					percent = 70,
				},
			},
			collision_box = { { -1.4, -2.45 }, { 1.4, 0.3 } },
			selection_box = { { -1.6, -2.49 }, { 1.6, 0.49 } },
			fluid_box = {
				base_area = 1,
				base_level = 1,
				pipe_covers = pipecoverspictures(),
				production_type = "output",
				filter = "water-viscous-mud",
				pipe_connections = {
					{
						position = { 0, 1 },
						type = "output",
					},
				},
			},
			pumping_speed = 10,
			tile_width = 3,
			tile_height = 3,
			vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
			picture = {
				north = {
					filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
					priority = "high",
					shift = { 0, -1 },
					width = 160,
					height = 160,
				},
				east = {
					filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
					priority = "high",
					shift = { 1, 0 },
					x = 160,
					width = 160,
					height = 160,
				},
				south = {
					filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
					priority = "high",
					shift = { 0, 1 },
					x = 320,
					width = 160,
					height = 160,
				},
				west = {
					filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
					priority = "high",
					shift = { -1, 0 },
					x = 480,
					width = 160,
					height = 160,
				},
			},
			placeable_position_visualization = {
				filename = "__core__/graphics/cursor-boxes-32x32.png",
				priority = "extra-high-no-scale",
				width = 64,
				height = 64,
				scale = 0.5,
				x = 3 * 64,
			},
			circuit_wire_connection_points = circuit_connector_definitions["offshore-pump"].points,
			circuit_connector_sprites = circuit_connector_definitions["offshore-pump"].sprites,
			circuit_wire_max_distance = default_circuit_wire_max_distance,
		},
		--MK3
		{
			type = "item",
			name = "seafloor-pump-3",
			icons = angelsmods.functions.add_number_icon_layer({
				{
					icon = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3-ico.png",
					icon_size = 32,
				},
			}, 3, angelsmods.refining.number_tint),
			subgroup = "washing-building",
			order = "a",
			place_result = "seafloor-pump-3",
			stack_size = 20,
		},
		{
			type = "offshore-pump",
			name = "seafloor-pump-3",
			icons = angelsmods.functions.add_number_icon_layer({
				{
					icon = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3-ico.png",
					icon_size = 32,
				},
			}, 3, angelsmods.refining.number_tint),
			flags = { "placeable-neutral", "player-creation", "filter-directions" },
			collision_mask = { "object-layer", "train-layer" }, -- collide just with object-layer and train-layer which don't collide with water, this allows us to build on 1 tile wide ground
			center_collision_mask = { "water-tile", "object-layer", "player-layer" }, -- to test that tile directly under the pump is ground
			fluid_box_tile_collision_test = { "ground-tile" },
			adjacent_tile_collision_test = { "water-tile" },
			adjacent_tile_collision_mask = { "ground-tile" }, -- to prevent building on edge of map :(
			adjacent_tile_collision_box = { { -2, -3 }, { 2, -2 } },
			minable = { mining_time = 1, result = "seafloor-pump-2" },
			fast_replaceable_group = "seafloor-pump",
			max_health = 80,
			corpse = "small-remnants",
			fluid = "water-viscous-mud",
			resistances = {
				{
					type = "fire",
					percent = 70,
				},
			},
			collision_box = { { -1.4, -2.45 }, { 1.4, 0.3 } },
			selection_box = { { -1.6, -2.49 }, { 1.6, 0.49 } },
			fluid_box = {
				base_area = 1,
				base_level = 1,
				pipe_covers = pipecoverspictures(),
				production_type = "output",
				filter = "water-viscous-mud",
				pipe_connections = {
					{
						position = { 0, 1 },
						type = "output",
					},
				},
			},
			pumping_speed = 20,
			tile_width = 3,
			tile_height = 3,
			vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
			picture = {
				north = {
					filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
					priority = "high",
					shift = { 0, -1 },
					width = 160,
					height = 160,
				},
				east = {
					filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
					priority = "high",
					shift = { 1, 0 },
					x = 160,
					width = 160,
					height = 160,
				},
				south = {
					filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
					priority = "high",
					shift = { 0, 1 },
					x = 320,
					width = 160,
					height = 160,
				},
				west = {
					filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
					priority = "high",
					shift = { -1, 0 },
					x = 480,
					width = 160,
					height = 160,
				},
			},
			placeable_position_visualization = {
				filename = "__core__/graphics/cursor-boxes-32x32.png",
				priority = "extra-high-no-scale",
				width = 64,
				height = 64,
				scale = 0.5,
				x = 3 * 64,
			},
			circuit_wire_connection_points = circuit_connector_definitions["offshore-pump"].points,
			circuit_connector_sprites = circuit_connector_definitions["offshore-pump"].sprites,
			circuit_wire_max_distance = default_circuit_wire_max_distance,
		}
	})
	angelsmods.functions.RB.build({
		{
			type = "recipe",
			name = "seafloor-pump-2",
			energy_required = 5,
			enabled = false,
			ingredients = {
				{ type = "item", name = "t0-plate", amount = 2 },
				{ type = "item", name = "t0-circuit", amount = 2 },
				{ type = "item", name = "t0-pipe", amount = 2 },
			},
			result = "seafloor-pump-2",
		},
		{
			type = "recipe",
			name = "seafloor-pump-3",
			energy_required = 5,
			enabled = false,
			ingredients = {
				{ type = "item", name = "t0-plate", amount = 2 },
				{ type = "item", name = "t0-circuit", amount = 2 },
				{ type = "item", name = "t0-pipe", amount = 2 },
			},
			result = "seafloor-pump-3",
		}
	})

	-- Make seafloor pump placeholder MK2
	local seafloor_pump_placeholder_2 = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump-2"])
	seafloor_pump_placeholder_2.name = "seafloor-pump-2-placeholder"
	seafloor_pump_placeholder_2.localised_name = {"entity-name.seafloor-pump-2-placeholder"}
	seafloor_pump_placeholder_2.localised_description = {"", field_font_2, pumping_speed, end_font.."600/s"}
	data:extend({seafloor_pump_placeholder_2})
	data.raw.item["seafloor-pump-2"].place_result = "seafloor-pump-2-placeholder"
	data.raw.item["seafloor-pump-2"].localised_description = {"", pwr_tooltip," ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."588 kW"..field_font, min_consumption, end_font.."18 kW"}

	-- Make seafloor pump
	local animation = data.raw["offshore-pump"]["seafloor-pump-2"].picture
	data.raw["offshore-pump"]["seafloor-pump-2"] = nil

	local seafloor_pump = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump-2-placeholder"])
	seafloor_pump.name = "seafloor-pump-2"
	seafloor_pump.subgroup = "other"
	seafloor_pump.type = "assembling-machine"
	seafloor_pump.placeable_by = {item = "seafloor-pump-2", count = 1}
	seafloor_pump.crafting_speed = 2
	seafloor_pump.energy_source = {type = "electric", usage_priority = "secondary-input"}
	seafloor_pump.energy_usage = "550kW"
	seafloor_pump.allowed_effects = {"consumption"}
	seafloor_pump.localised_description = {"entity-description.seafloor-pump-2"}
	--
	seafloor_pump.flags = flags
	seafloor_pump.crafting_categories = crafting_categories
	seafloor_pump.fixed_recipe = fixed_recipe
	seafloor_pump.fluid_boxes = fluid_boxes
	seafloor_pump.animation = animation
	-- Remove code leftovers
	seafloor_pump.picture = nil
	seafloor_pump.pumping_speed = nil
	seafloor_pump.fluid_box = nil
	data:extend({seafloor_pump})

	-- Make seafloor pump placeholder MK3
	local seafloor_pump_placeholder_3 = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump-3"])
	seafloor_pump_placeholder_3.name = "seafloor-pump-3-placeholder"
	seafloor_pump_placeholder_3.localised_name = { "entity-name.seafloor-pump-3-placeholder" }
	seafloor_pump_placeholder_3.localised_description = { "", field_font_2, pumping_speed, end_font .. "1200/s" }
	data:extend({ seafloor_pump_placeholder_3 })
	data.raw.item["seafloor-pump-3"].place_result = "seafloor-pump-3-placeholder"
	data.raw.item["seafloor-pump-3"].localised_description = {
		"",
		pwr_tooltip,
		" ",
		tooltip_font,
		consumes,
		" ",
		electricity,
		" ",
		end_tooltip .. field_font,
		max_consumption,
		end_font .. "1030 kW" .. field_font,
		min_consumption,
		end_font .. "33 kW",
	}

	-- Make seafloor pump
	local animation = data.raw["offshore-pump"]["seafloor-pump-3"].picture
	data.raw["offshore-pump"]["seafloor-pump-3"] = nil

	local seafloor_pump = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump-3-placeholder"])
	seafloor_pump.name = "seafloor-pump-3"
	seafloor_pump.subgroup = "other"
	seafloor_pump.type = "assembling-machine"
	seafloor_pump.placeable_by = { item = "seafloor-pump-3", count = 1 }
	seafloor_pump.crafting_speed = 4
	seafloor_pump.energy_source = { type = "electric", usage_priority = "secondary-input" }
	seafloor_pump.energy_usage = "1000kW"
	seafloor_pump.allowed_effects = { "consumption" }
	seafloor_pump.localised_description = { "entity-description.seafloor-pump-3" }
	--
	seafloor_pump.flags = flags
	seafloor_pump.crafting_categories = crafting_categories
	seafloor_pump.fixed_recipe = fixed_recipe
	seafloor_pump.fluid_boxes = fluid_boxes
	seafloor_pump.animation = animation
	-- Remove code leftovers
	seafloor_pump.picture = nil
	seafloor_pump.pumping_speed = nil
	seafloor_pump.fluid_box = nil
	data:extend({ seafloor_pump })
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------

	local electric_priority = "secondary-input"
	if top_priority_enabled then
		electric_priority = "primary-input"
	end

	-- Water [recipe - ground water]
	local mud_seafloor = table.deepcopy(data.raw["recipe"]["water-offshore"])
	mud_seafloor.name = "angel-ground-water"
	mud_seafloor.results = { { type = "fluid", name = "water", amount = 60 } }
	data:extend({ mud_seafloor })

	-- Make ground water pump placeholder
	local ground_pump_placeholder = table.deepcopy(data.raw["offshore-pump"]["ground-water-pump"])
	ground_pump_placeholder.name = "ground-water-pump-placeholder"
	ground_pump_placeholder.localised_name = { "entity-name.ground-water-pump-placeholder" }
	ground_pump_placeholder.localised_description = { "entity-description.ground-water-pump-placeholder" }
	data:extend({ ground_pump_placeholder })
	data.raw.item["ground-water-pump"].place_result = "ground-water-pump-placeholder"
	data.raw.item["ground-water-pump"].localised_description = { "item-description.ground-water-pump-placeholder" }

	-- Make ground water pump
	local animation = data.raw["offshore-pump"]["ground-water-pump"].graphics_set.animation
	local fixed_recipe = "angel-ground-water"
	data.raw["offshore-pump"]["ground-water-pump"] = nil

	local ground_pump = table.deepcopy(data.raw["offshore-pump"]["ground-water-pump-placeholder"])
	ground_pump.name = "ground-water-pump"
	ground_pump.type = "assembling-machine"
	ground_pump.placeable_by = { item = "ground-water-pump", count = 1 }
	ground_pump.crafting_speed = 1
	ground_pump.energy_source = { type = "electric", usage_priority = electric_priority }
	ground_pump.energy_usage = "120kW"
	ground_pump.allowed_effects = { "consumption" }
	ground_pump.localised_description = { "entity-description.ground-water-pump" }
	--
	ground_pump.flags = flags
	ground_pump.crafting_categories = crafting_categories
	ground_pump.fixed_recipe = fixed_recipe
	ground_pump.fluid_boxes = fluid_boxes
	ground_pump.animation = animation
	-- Remove code leftovers
	ground_pump.picture = nil
	ground_pump.pumping_speed = nil
	ground_pump.fluid_box = nil
	data:extend({ ground_pump })
end
