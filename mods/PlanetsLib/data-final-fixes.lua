PlanetsLib.current_stage = "data-final-fixes"
PlanetsLib.check_global_variables()
require("prototypes.override-final.science")
require("prototypes.override-final.technology-updates")
require("prototypes.override-final.enhanced-tooltips")
require("prototypes.override-final.recipe-effects")
require("prototypes.override-final.pipette-result")
require("prototypes.override-final.lab-updates")
require("prototypes.override-final.ground-diggers")
if mods["space-age"] then
	require("prototypes.override-final.check-unexpected-positions")
	require("prototypes.override-final.update-connections")
    -- Paranoidal fork: the build keeps its item weights (upstream sets the vanilla weights of vanilla items).
	require("prototypes.override-final.rocket-lift-multiplier")
	local ps = require("lib.planet-str")

	local planets = data.raw.planet

	--Set planet string for every planet based on planet name.
	for _, planet in pairs(planets) do
		if planet["surface_properties"] and planet["surface_properties"]["planet-str"] == nil then --Other mods can override planet strings, this is a last-resort planet string generator.
			local truncated_name = string.sub(planet.name, 1, 8) --Planet strings can only be 8 characters or less.
			ps.set_planet_str(planet, truncated_name)
		end
		-- add a surface property that marks that the planet is freezing, entities need heating
		if planet["entities_require_heating"] then
			local properties = planet["surface_properties"] or {}
			properties["is-freezing"] = 1
			planet["surface_properties"] = properties
		end
	end

	require("prototypes.override-final.starmap")

	-- prevent removal of star during sprite_only cleanup
	-- this is necessary for PlanetsLib:update to work during final-fixes
	data.raw["space-location"]["star"].sprite_only = nil

	-- Convert PlanetsLib orbit relationships to Factorio's native orbit representation.
	-- This is done after PlanetsLib's existing position reconciliation and sprite_only
	-- rendering have finished, while all parent prototypes still exist.
	local orbits = require("lib.orbits")
	local locations = {}

	-- collect planet and space-location tables for orbit -> origin processing
	for _, type in pairs({ "space-location", "planet" }) do
		for _, location in pairs(data.raw[type]) do
			table.insert(locations, location)
		end
	end

	-- order the list so parents are processed before their children
	local ordered_locations = orbits.locations_ordered_by_orbits(locations)

	-- for each location, convert from PlanetsLib orbit to new origin format
	for _, location in ipairs(ordered_locations) do
		orbits.apply_native_orbit(location)
	end

	-- reuse the collected locations for sprite_only cleanup
	for _, location in ipairs(locations) do
		if location.sprite_only then
			data.raw[location.type][location.name] = nil
		end
	end

	local gas_list = { "oxygen", "nitrogen", "carbon-dioxide", "argon" }
	local enforce_percentage = settings.startup["PlanetsLib-enforce-gas-percentage"].value --Whether code should assert that combined gas contents add up to less than 100%.

	for _, planet in pairs(planets) do
		if planet.surface_properties and enforce_percentage then
			local gas_content = 0
			for _, gas in pairs(gas_list) do
				if planet.surface_properties[gas] then
					gas_content = gas_content + planet.surface_properties[gas]
				end
			end
			assert(
				gas_content <= 100,
				"Combined gas contents of planet "
					.. planet.name
					.. ' exceed 100%. To override this assertion, add \'data.raw["bool-setting"]["PlanetsLib-enforce-gas-percentage"].forced_value = false\' to settings-updates.lua.'
			)
		end
	end
end



