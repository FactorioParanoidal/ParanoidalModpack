-- Cabin filtration of a vehicle by prototype type and name (0..1). Shared by the tooltip (data stage)
-- and the runtime, so both always agree. Unknown vehicle types filter nothing.
local V = {}

local AIRCRAFT = { ["gunship"] = true, ["cargo-plane"] = true, ["jet"] = true, ["flying-fortress"] = true }
local ROLLING = { ["locomotive"] = true, ["cargo-wagon"] = true, ["fluid-wagon"] = true, ["artillery-wagon"] = true }

V.TYPES = { "car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon" }

function V.filtration(entity_type, name)
	if entity_type == "spider-vehicle" then
		return 0.95
	end
	if entity_type == "car" then
		if AIRCRAFT[name] or string.find(name, "tank", 1, true) then
			return 0.85
		end
		return 0.40
	end
	if ROLLING[entity_type] then
		if string.find(name, "armoured", 1, true) or string.find(name, "armored", 1, true) then
			return 0.90
		end
		return 0.75
	end
	return 0
end

return V
