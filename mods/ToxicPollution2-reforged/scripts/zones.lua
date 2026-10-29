-- Clean-air zones: a working machine that absorbs pollution (air filters, farms, greenhouses) nearby
-- doubles the intoxication decay. Machine names come from mod-data built in data-final-fixes.
local C = require("shared.config")

local Z = {}

local names -- derived from prototypes only; rebuilt after each load

local function clean_names()
	if names == nil then
		local entry = prototypes.mod_data[C.CLEAN_AIR_DATA]
		names = entry and entry.data.names or {}
	end
	return names
end

function Z.near_clean_air(surface, position)
	local list = clean_names()
	if #list == 0 then return false end
	local found = surface.find_entities_filtered({ position = position, radius = C.MODEL.zone_radius, name = list, limit = 8 })
	local working = defines.entity_status.working
	for _, entity in pairs(found) do
		if entity.status == working then
			return true
		end
	end
	return false
end

return Z
