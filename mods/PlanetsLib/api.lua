local global_variable_checks = require("lib.global-variable-checks")
local util = require("util")
local lib = require("lib.lib")
local technology = require("lib.technology")
local planet = require("lib.planet")
local planet_str = require("lib.planet-str")
local surface_conditions = require("lib.surface_conditions")
local mod_data = require("lib.mod-data")
local recipe = require("lib.recipe")
local achievements = require("lib.achievements")
local entity_replacements = require("lib.add-entity-replacement")
local dual_item_icon = require("lib.dual-item-icon")
local images = require("lib.images")
local ground_diggers = require("lib.ground-diggers")
local entity_removal_floors = require("lib.entity-removal-floors")

--== APIs ==--
-- API documentation lives in README.md (or on the mod portal.)

PlanetsLib.add_science_packs_from_vanilla_lab_to_technology =
	technology.add_science_packs_from_vanilla_lab_to_technology
PlanetsLib.sort_science_pack_names = technology.sort_science_pack_names
PlanetsLib.get_child_technologies = technology.get_child_technologies
PlanetsLib.excise_tech_from_tech_tree = technology.excise_tech_from_tech_tree
PlanetsLib.excise_recipe_from_tech_tree = technology.excise_recipe_from_tech_tree
PlanetsLib.excise_effect_from_tech_tree = technology.excise_effect_from_tech_tree
PlanetsLib.technology_icon_moon = technology.technology_icon_moon
PlanetsLib.technology_icon_planet = technology.technology_icon_planet
PlanetsLib.technology_icons_planet_cargo_drops = technology.technology_icons_planet_cargo_drops
PlanetsLib.cargo_drops_technology_base = technology.cargo_drops_technology_base
PlanetsLib.technology_effect_cargo_drops = technology.technology_effect_cargo_drops

PlanetsLib.crushing_recipe_icons = recipe.crushing_recipe_icons
PlanetsLib.asteroid_crushing_recipe_icons = recipe.asteroid_crushing_recipe_icons
PlanetsLib.advanced_crushing_recipe_icons = recipe.advanced_crushing_recipe_icons
PlanetsLib.melting_icon = recipe.melting_icon

PlanetsLib.dual_icon = dual_item_icon.dual_icon
PlanetsLib.dual_icon_reversed = dual_item_icon.dual_icon_reversed
PlanetsLib.blur_technology_icon = images.blur_technology_icon

PlanetsLib.assign_rocket_part_recipe = mod_data.assign_rocket_part_recipe
PlanetsLib.add_item_name_to_planet_cargo_drops_whitelist = mod_data.add_item_name_to_planet_cargo_drops_whitelist
PlanetsLib.add_entity_type_to_planet_cargo_drops_whitelist = mod_data.add_entity_type_to_planet_cargo_drops_whitelist
PlanetsLib.add_item_name_to_global_cargo_drops_whitelist = mod_data.add_item_name_to_global_cargo_drops_whitelist
PlanetsLib.add_entity_type_to_global_cargo_drops_whitelist = mod_data.add_entity_type_to_global_cargo_drops_whitelist

PlanetsLib.restrict_surface_conditions = surface_conditions.restrict_surface_conditions
PlanetsLib.relax_surface_conditions = surface_conditions.relax_surface_conditions
PlanetsLib.remove_surface_condition = surface_conditions.remove_surface_condition

PlanetsLib.set_default_import_location = planet.set_default_import_location

PlanetsLib.visit_planet_achievement = achievements.visit_planet_achievement

PlanetsLib.create_planet_entity_variant = entity_replacements.create_planet_entity_variant
PlanetsLib.assign_entity_replacement = entity_replacements.assign_entity_replacement
PlanetsLib.enable_ground_diggers = ground_diggers.enable_ground_diggers
PlanetsLib.assign_entity_removal_floor = entity_removal_floors.assign_entity_removal_floor
PlanetsLib.add_entity_removal_floor_rule = entity_removal_floors.add_entity_removal_floor_rule
PlanetsLib.set_special_properties = planet.set_special_properties
PlanetsLib.get_special_property = planet.get_special_property
PlanetsLib.get_special_properties = planet.get_special_properties

PlanetsLib.get_orbit_sprite = planet.get_orbit_sprite

--- Clones music tracks from source_planet to target_planet.
--- Does not overwrite existing music for target_planet.
--- Options specified in `options`:
--- track_types(table): Allows the selection of only tracks matching one or more track types.
--- modifier_function(function): Function applied to each borrowed track: Expected form: modifier_function = function(track) {Apply changes to track table here} end
-- @param source_planet
-- @param target_planet
-- @param options table Table of options (track_types)
PlanetsLib.borrow_music = planet.borrow_music

function PlanetsLib:extend(configOrConfigs)
	if not configOrConfigs then
		error("PlanetsLib:extend: data passed must not be nil.")
	end
	local configs = lib.wrap_single_config(util.table.deepcopy(configOrConfigs))

	for _, config in ipairs(configs) do
		planet.extend(config)
	end
end

function PlanetsLib:update(configOrConfigs)
	if not configOrConfigs then
		error("PlanetsLib:update: data passed must not be nil.")
	end
	local configs = lib.wrap_single_config(util.table.deepcopy(configOrConfigs))

	for _, config in ipairs(configs) do
		planet.update(config)
	end
end

--== Undocumented APIs ==--
-- Though these APIs are undocumented we should still support them, as mods may be using them.
PlanetsLib.check_global_variables = global_variable_checks.check_global_variables
PlanetsLib.process_technology_recipe_productivity_effects = technology.process_technology_recipe_productivity_effects
PlanetsLib.technology_icons_moon = technology.technology_icon_moon
PlanetsLib.technology_icon_constant_planet = technology.technology_icon_planet
PlanetsLib.surface_conditions = surface_conditions
PlanetsLib.restrict_to_planet = surface_conditions.restrict_to_planet
PlanetsLib.restrict_to_surface = surface_conditions.restrict_to_surface
PlanetsLib.planet_str = planet_str

PlanetsLib.generate_ground_diggers = ground_diggers.generate_ground_diggers

PlanetsLib.objects = require("lib.remove-replace-object") --Table manipulation library
PlanetsLib.rro = PlanetsLib.objects --Alias for PlanetsLib.objects

-- For backwards compatibility (mod-data was not always a thing). NOTE: These functions return numbers, other mods may change the tier prototypes after you call this.
local function get_tierlist_data()
	local tierlist = data.raw["mod-data"]["PlanetsLib-tierlist"]
	return tierlist and tierlist.data
end

PlanetsLib.get_planet_tier = function(planet_name)
	local tierlist = get_tierlist_data()
	if not tierlist then
		return nil
	end
	local tier = tierlist.planet and tierlist.planet[planet_name]
	if tier ~= nil then
		return tier
	end
	return tierlist.default
end

PlanetsLib.get_space_location_tier = function(space_location_name)
	local tierlist = get_tierlist_data()
	if not tierlist then
		return nil
	end
	local tier = tierlist["space-location"] and tierlist["space-location"][space_location_name]
	if tier ~= nil then
		return tier
	end
	return tierlist.default
end
