-- local util = require("util")

-- Commenting out this code as it never did anything anyway, the subgroup is "satellites" not "satellite"

-- for name, connection in pairs(data.raw["space-connection"]) do
-- 	if not (name:match("%-to%-parent$") or name:match("%-from%-parent$")) then
-- 		local source_name = connection.from
-- 		local target_name = connection.to

-- 		local source_prototype = data.raw.planet[source_name]
-- 		local target_prototype = data.raw.planet[target_name]

-- 		if source_prototype and target_prototype and source_prototype.orbit and target_prototype.orbit then
-- 			if
-- 				source_prototype.orbit
-- 				and source_prototype.orbit.parent
-- 				and source_prototype.orbit.parent.type == "planet"
-- 				and source_prototype.orbit.parent.name == target_name
-- 				and (source_prototype.subgroup == "satellite" or source_prototype.orbit.is_satellite)
-- 			then
-- 				local new_name = name .. "-satellite-to-parent"
-- 				data.raw["space-connection"][new_name] = util.table.deepcopy(connection)
-- 				data.raw["space-connection"][new_name].name = new_name
-- 				data.raw["space-connection"][name] = nil
-- 			elseif
-- 				target_prototype.orbit
-- 				and target_prototype.orbit.parent
-- 				and target_prototype.orbit.parent.type == "planet"
-- 				and target_prototype.orbit.parent.name == source_name
-- 				and (target_prototype.subgroup == "satellite" or target_prototype.orbit.is_satellite)
-- 			then
-- 				local new_name = name .. "-parent-to-satellite"
-- 				data.raw["space-connection"][new_name] = util.table.deepcopy(connection)
-- 				data.raw["space-connection"][new_name].name = new_name
-- 				data.raw["space-connection"][name] = nil
-- 			end
-- 		end
-- 	end
-- end
