--------------------------
---- data-updates.lua ----
--------------------------

if not mods ["angelsrefining"] then return end

-- Fetch lib functions
local disable_prototype = OSM.lib.prototype.disable_prototype

-- Disable bobmining water miners
disable_prototype("water-miner-1", "all")
disable_prototype("water-miner-2", "all")
disable_prototype("water-miner-3", "all")
disable_prototype("water-miner-4", "all")
disable_prototype("water-miner-5", "all")

-- force angel offshore pumps to comply with the laws of physics
if settings.startup["osm-pumps-enable-power"].value == true then
	
	-- Set common properties
	local crafting_categories = {"pump-water"}
	local fixed_recipe = "angel-viscous-mud"
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

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

	local electric_priority = {}
	if settings.startup ["osm-pumps-power-priority"].value == true then
		electric_priority = "primary-input"
	else
		electric_priority = "secondary-input"
	end

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