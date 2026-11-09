require("prototypes.tiles")
require("prototypes.events")
require("prototypes.custom-inputs")
local orbits = require("lib.orbits")
PlanetsLib = {}
PlanetsLib.current_stage = "data"
data:extend({
	{
		type = "mod-data",
		name = "Planetslib",
		data = {
			unlinked_prerequisites = {},
			planet_cargo_drop_whitelists = {
				all = {
					entity_types = {},
					item_names = {},
				},
			},
			space_platform_hub_receiving_cargo_units = {"cargo-pod"}, --see __PlanetsLib__.prototypes.vanilla-override.cargo-hatch
			on_entity_placed_on_planet_replacements = {
				--["planet-name"] = {
				-- ["entity-to-replace"] = "new-entity"
				--}
				 --Test data, replace with mod-data when script is confirmed to work.
					-- ["nauvis"] = { --If on planet (or "space-platform")
					-- 	["assembling-machine-1"] = "chemical-plant", --If chemical plant placed on Nauvis, replace with assembling-machine 2
					-- 	["assembling-machine-2"] = "chemical-plant",
					-- 	["assembling-machine-3"] = "chemical-plant", 
					-- 	["electric-furnace"] = "chemical-plant", 
					-- 	--["assembling-machine-1"] = "chemical-plant" --If chemical plant placed on Nauvis, replace with assembling-machine 2
					-- },
					-- ["space-platform"] = { --If on planet (or "space-platform")
					-- 	["chemical-plant"] = "assembling-machine-3" --If chemical plant placed on space platform, replace with assembling-machine 3
					-- },
				
			},
			planet_special_properties = { --Place to store arbitrary planet properties to avoid a proliferation of new mod-data objects.
				--[planet name] = table {incl. rocket_lift_multiplier}
			},
			pipette_result = { --Maps entity name to pipette result. An alternative to EntityPrototype::placeable_by that doesn't affect bot behavior.
				--[entity-name] = "other-entity-name"
			},
			ground_diggers = { --Planets that convert mining drills placed without nearby resources into recipe-crafting machines.
				--[planet-name] = {recipe = "recipe-name", diggers = {["item-name"] = {drill = "entity-name", digger = "digger-entity-name"}}}
			},
			entity_removal_floors = { --Temporary floor tiles placed under simple entities during deconstruction.
				--[planet-name] = {["entity-name"] = {default_tile = "tile-name", default_tile_item = "item-name", waiting_message = {"locale-key"}}}
			},
			items_corrected_fuel_category = {

			}
		},
	},
})

PlanetsLib.constants = data.raw["mod-data"].Planetslib.data



require("api")
PlanetsLib.check_global_variables()

-- Muluna 2.7.40 and older ship their own ground digger prototypes with the same names,
-- which conflict with PlanetsLib's shared prototypes. Fail early with a clear message.
local muluna_version = mods["planet-muluna"]
if muluna_version and helpers.compare_versions(muluna_version, "2.7.40") <= 0 then
	error(
		"PlanetsLib is not compatible with planet-muluna " .. muluna_version
		.. ". Please update planet-muluna to a version newer than 2.7.40. "
		.. "Older Muluna versions have their own ground digger implementation that conflicts with PlanetsLib's shared ground diggers."
	)
end

require("prototypes.vanilla-override.recipe-productivity-technology")
require("prototypes.vanilla-override.cargo-hatch")

require("prototypes.mod-data")

if mods["space-age"] then
	require("prototypes.surface-property")
	require("prototypes.categories")
	require("prototypes.star")

	orbits.ensure_all_locations_have_orbits() -- We also call this in data-updates, but it's good to call it here as well so that if the vanilla planets are moved in data.lua (or before this code runs in data-updates.lua), we correctly recognize that their orbital children should be moved as well.
end

