-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

local triggers = {}

-- Angel's Bioprocessing
triggers.bioprocessing = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-angels", "angelsbioprocessing"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-angels", "angelsbioprocessing"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-angels", "angelsbioprocessing"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-angels", "angelsbioprocessing"),
}

-- Angel's Exploration
triggers.exploration = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-angels", "angelsexploration"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-angels", "angelsexploration"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-angels", "angelsexploration"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-angels", "angelsexploration"),
}

-- Angel's Industries
triggers.industries = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-angels", "angelsindustries"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-angels", "angelsindustries"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-angels", "angelsindustries"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-angels", "angelsindustries"),
}

-- Angel's Petrochem
triggers.petrochem = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-angels", "angelspetrochem"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-angels", "angelspetrochem"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-angels", "angelspetrochem"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-angels", "angelspetrochem"),
}

-- Angel's Refining
triggers.refining = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-angels", "angelsrefining"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-angels", "angelsrefining"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-angels", "angelsrefining"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-angels", "angelsrefining"),
}

-- Angel's Smelting
triggers.smelting = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-angels", "angelssmelting"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-angels", "angelssmelting"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-angels", "angelssmelting"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-angels", "angelssmelting"),
	pipes_use_material_colors = false,
}

-- Angel's Addons - Mobility
triggers.mobility = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-angels", "angelsaddons-mobility"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-angels", "angelsaddons-mobility"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-angels", "angelsaddons-mobility"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-angels", "angelsaddons-mobility"),
	pipes_material_colors = false,
}

-- Angel's Addons - Storage
triggers.storage = {
	entities = reskins.lib.settings.is_feature_set_enabled("entities", "reskins-angels", "angelsaddons-storage"),
	equipment = reskins.lib.settings.is_feature_set_enabled("equipment", "reskins-angels", "angelsaddons-storage"),
	items = reskins.lib.settings.is_feature_set_enabled("items-and-fluids", "reskins-angels", "angelsaddons-storage"),
	technologies = reskins.lib.settings.is_feature_set_enabled("technologies", "reskins-angels", "angelsaddons-storage"),
}

-- Mad Clown's Compatibility
triggers.mad_clowns = {
	is_active = mods["Clowns-AngelBob-Nuclear"] and true or mods["Clowns-Extended-Minerals"] and true or mods["Clowns-Nuclear"] and true or mods["Clowns-Processing"] and true or mods["Clowns-Science"] and true or false,
}

-- Angel components
triggers.use_angels_components = (angelsmods and angelsmods.industries and angelsmods.industries.components)
triggers.use_angels_plates = not mods["bobplates"]

return triggers
