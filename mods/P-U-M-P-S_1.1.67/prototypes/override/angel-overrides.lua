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

local offshore_name = {"entity-name.offshore-pump"}
local pumpjack_name = {"string.water-pumpjack"}
local offshore_desc = {"entity-description.offshore-pump"}
local electric_offshore = {"string.electric-offshore-pump"}
local burner_offshore = {"string.burner-offshore-pump"}

local pumpjack_tech_desc = {"technology-description.water-pumpjack"}

local seafloor_pump = {"entity-name.seafloor-pump"}
local seafloor_pump = {"entity-name.seafloor-pump-2"}
local seafloor_pump = {"entity-name.seafloor-pump-3"}
local water_bore = {"entity-name.ground-water-pump"}

local consumes = {"tooltip-category.consumes"}
local burnable_fuel = {"fuel-category-name.chemical"}
local electricity = {"tooltip-category.electricity"}
local pumping_speed = {"description.pumping-speed"}
local max_consumption = {"description.max-energy-consumption"}
local min_consumption = {"description.min-energy-consumption"}


if not mods ["angelsrefining"] then return end

-- Disable bobmining water miners
OSM.lib.disable_prototype("all", "water-miner-1")
OSM.lib.disable_prototype("all", "water-miner-2")
OSM.lib.disable_prototype("all", "water-miner-3")
OSM.lib.disable_prototype("all", "water-miner-4")
OSM.lib.disable_prototype("all", "water-miner-5")

-- force angel offshore pumps to comply with the laws of physics
if power_enabled then
	
	-- Set common properties
	local crafting_categories = {"pump-water"}
	local fixed_recipe = "angel-viscous-mud"
	local fixed_recipe_2 = "angel-viscous-mud-2"
	local fixed_recipe_3 = "angel-viscous-mud-3"
	local flags = {"hidden", "placeable-neutral", "player-creation", "filter-directions"}
	local fluid_boxes =
	{
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
		},
		off_when_no_fluid_recipe = false
	}
 
	-- Mud [recipe - seafloor]
	local mud_seafloor = table.deepcopy(data.raw["recipe"]["water-offshore"])
	mud_seafloor.name = "angel-viscous-mud"
	mud_seafloor.results = {{type = "fluid", name = "water-viscous-mud", amount = 300}}
	data:extend({mud_seafloor})

	-- Make seafloor pump placeholder
	local seafloor_pump_placeholder = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump"])
	seafloor_pump_placeholder.name = "seafloor-pump-placeholder"
	seafloor_pump_placeholder.localised_name = {"entity-name.seafloor-pump-placeholder"}
	seafloor_pump_placeholder.localised_description = {"entity-description.seafloor-pump-placeholder"}
	data:extend({seafloor_pump_placeholder})
	data.raw.item["seafloor-pump"].place_result = "seafloor-pump-placeholder"
	data.raw.item["seafloor-pump"].localised_description = {"item-description.seafloor-pump-placeholder"}

	-- Make seafloor pump
	local animation = data.raw["offshore-pump"]["seafloor-pump"].picture
	data.raw["offshore-pump"]["seafloor-pump"] = nil

	local seafloor_pump = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump-placeholder"])
	seafloor_pump.name = "seafloor-pump"
	seafloor_pump.subgroup = "other"
	seafloor_pump.type = "assembling-machine"
	seafloor_pump.placeable_by = {item = "seafloor-pump", count = 1}
	seafloor_pump.crafting_speed = 1
	seafloor_pump.energy_source = {type = "electric", usage_priority = "secondary-input"}
	seafloor_pump.energy_usage = "300kW"
	seafloor_pump.allowed_effects = {"consumption"}
	seafloor_pump.localised_description = {"entity-description.seafloor-pump"}
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

	-- Make seafloor pump placeholder MK2
	local seafloor_pump_placeholder_3 = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump-3"])
	seafloor_pump_placeholder_3.name = "seafloor-pump-3-placeholder"
	seafloor_pump_placeholder_3.localised_name = {"entity-name.seafloor-pump-3-placeholder"}
	seafloor_pump_placeholder_3.localised_description = {"", field_font_2, pumping_speed, end_font.."1200/s"}
	data:extend({seafloor_pump_placeholder_3})
	data.raw.item["seafloor-pump-3"].place_result = "seafloor-pump-3-placeholder"
	data.raw.item["seafloor-pump-3"].localised_description = {"", pwr_tooltip," ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."1030 kW"..field_font, min_consumption, end_font.."33 kW"}

	-- Make seafloor pump
	local animation = data.raw["offshore-pump"]["seafloor-pump-3"].picture
	data.raw["offshore-pump"]["seafloor-pump-3"] = nil

	local seafloor_pump = table.deepcopy(data.raw["offshore-pump"]["seafloor-pump-3-placeholder"])
	seafloor_pump.name = "seafloor-pump-3"
	seafloor_pump.subgroup = "other"
	seafloor_pump.type = "assembling-machine"
	seafloor_pump.placeable_by = {item = "seafloor-pump-3", count = 1}
	seafloor_pump.crafting_speed = 4
	seafloor_pump.energy_source = {type = "electric", usage_priority = "secondary-input"}
	seafloor_pump.energy_usage = "1000kW"
	seafloor_pump.allowed_effects = {"consumption"}
	seafloor_pump.localised_description = {"entity-description.seafloor-pump-3"}
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
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

	local electric_priority = "secondary-input"
	if top_priority_enabled then electric_priority = "primary-input" end

	-- Water [recipe - ground water]
	local mud_seafloor = table.deepcopy(data.raw["recipe"]["water-offshore"])
	mud_seafloor.name = "angel-ground-water"
	mud_seafloor.results = {{type = "fluid", name = "water", amount = 60}}
	data:extend({mud_seafloor})

	-- Make ground water pump placeholder
	local ground_pump_placeholder = table.deepcopy(data.raw["offshore-pump"]["ground-water-pump"])
	ground_pump_placeholder.name = "ground-water-pump-placeholder"
	ground_pump_placeholder.localised_name = {"entity-name.ground-water-pump-placeholder"}
	ground_pump_placeholder.localised_description = {"entity-description.ground-water-pump-placeholder"}
	data:extend({ground_pump_placeholder})
	data.raw.item["ground-water-pump"].place_result = "ground-water-pump-placeholder"
	data.raw.item["ground-water-pump"].localised_description = {"item-description.ground-water-pump-placeholder"}

	-- Make ground water pump
	local animation = data.raw["offshore-pump"]["ground-water-pump"].graphics_set.animation
	local fixed_recipe = "angel-ground-water"
	data.raw["offshore-pump"]["ground-water-pump"] = nil

	local ground_pump = table.deepcopy(data.raw["offshore-pump"]["ground-water-pump-placeholder"])
	ground_pump.name = "ground-water-pump"
	ground_pump.type = "assembling-machine"
	ground_pump.placeable_by = {item = "ground-water-pump", count = 1}
	ground_pump.crafting_speed = 1
	ground_pump.energy_source = {type = "electric", usage_priority = electric_priority}
	ground_pump.energy_usage = "120kW"
	ground_pump.allowed_effects = {"consumption"}
	ground_pump.localised_description = {"entity-description.ground-water-pump"}
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
	data:extend({ground_pump})
end