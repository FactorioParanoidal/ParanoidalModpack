-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local triggers = {}

-- Bob's Assembling Machines
triggers.assembly = {
	burner_assembling_machine_is_small = reskins.lib.settings.get_value("bobmods-assembly-burner"),
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobassembly"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobassembly"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobassembly"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobassembly"),
}

-- Bob's Greenhouse
triggers.greenhouse = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobgreenhouse"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobgreenhouse"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobgreenhouse"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobgreenhouse"),
}

-- Bob's Electronics
triggers.electronics = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobelectronics"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobelectronics"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobelectronics"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobelectronics"),
}

-- Bob's Enemies
triggers.enemies = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobenemies"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobenemies"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobenemies"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobenemies"),
}

-- Bob's Equipment
triggers.equipment = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobequipment"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobequipment"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobequipment"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobequipment"),
}

-- Bob's Logistics
triggers.logistics = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "boblogistics"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "boblogistics"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "boblogistics"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "boblogistics"),
}

-- Bob's Mining
triggers.mining = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobmining"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobmining"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobmining"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobmining"),
}

-- Bob's Modules
triggers.modules = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobmodules"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobmodules"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobmodules"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobmodules"),
}

-- Bob's Metals, Chemicals, and Intermediates
triggers.plates = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobplates"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobplates"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobplates"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobplates"),
}

-- Bob's Ores
triggers.ores = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobores"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobores"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobores"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobores"),
}

-- Bob's Power
triggers.power = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobpower"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobpower"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobpower"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobpower"),

	-- Fetch bobpower settings
	accumulators = reskins.lib.settings.get_value("bobmods-power-accumulators"),
	poles = reskins.lib.settings.get_value("bobmods-power-poles"),
	steam = reskins.lib.settings.get_value("bobmods-power-steam"),
	fluidgenerator = reskins.lib.settings.get_value("bobmods-power-fluidgenerator"),
	heatsources = reskins.lib.settings.get_value("bobmods-power-heatsources"),
	nuclear = reskins.lib.settings.get_value("bobmods-power-nuclear"),
	solar = reskins.lib.settings.get_value("bobmods-power-solar"),
}

-- Bob's Revamp
triggers.revamp = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobrevamp"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobrevamp"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobrevamp"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobrevamp"),
}

-- Bob's Technology
triggers.technology = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobtech"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobtech"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobtech"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobtech"),
}

-- Bob's Vehicle Equipment
triggers.vehicle_equipment = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobvehicleequipment"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobvehicleequipment"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobvehicleequipment"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobvehicleequipment"),
}

-- Bob's Warfare
triggers.warfare = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-bobs", "bobwarfare"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-bobs", "bobwarfare"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-bobs", "bobwarfare"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-bobs", "bobwarfare"),
}

-- aai-industry is optionally dependent on angelsrefining and will perform final edits to the burner assembling machine
if mods["aai-industry"] and mods["angelsrefining"] then
	triggers.assembly.burner_assembling_machine_is_small = false
end

return triggers
