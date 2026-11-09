local lib_planet = require("lib.planet")

local Public = {}

function Public.visit_planet_achievement(planet, icon, icon_size)
	if not lib_planet.is_space_location(planet) then
		error(
			"PlanetsLib.visit_planet_achievement() - visit_planet_achievement's planet paramter only takes a planet or space-location prototype. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	if type(icon) ~= "string" then
		error(
			"PlanetsLib.visit_planet_achievement() - visit_planet_achievement's icon paramter takes a path to an image. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	local localised_name = planet.localised_name or {"space-location-name."..planet.name}
	return 
		{
			type = "change-surface-achievement",
			name = "visit-"..planet.name,
			localised_name = {"achievement-name.visit-planet", localised_name},
			localised_description = {"achievement-description.visit-planet", localised_name},
			order = "a[progress]-g[visit-planet]-e["..planet.name.."]",
			surface = planet.name,
			icon = icon,
			icon_size = icon_size or 128,
		}
	
end

return Public