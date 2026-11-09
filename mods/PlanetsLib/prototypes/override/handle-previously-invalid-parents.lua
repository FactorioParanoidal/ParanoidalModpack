local orbits = require("lib.orbits")

-- We want it to be possible for authors to call PlanetsLib:extend in data.lua even if the parent does not yet exist.

for _, type in pairs({ "planet", "space-location" }) do
	for _, location in pairs(data.raw[type]) do
		if
			location.distance == orbits.SPECIAL_PLACEHOLDERS_FOR_MISSING_PARENT.distance
			and location.orientation == orbits.SPECIAL_PLACEHOLDERS_FOR_MISSING_PARENT.orientation
		then
			local location_copy = util.table.deepcopy(location)
			location_copy.distance = nil
			location_copy.orientation = nil
			PlanetsLib:update(location_copy)
		end
	end
end
