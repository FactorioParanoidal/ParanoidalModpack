------------------
---- data.lua ----
------------------

-- Get local functions
local OSM_local = require("utils.local-functions")

-- Setup function host
if not OSM.lib.item then OSM.lib.item = {} end

-- Assign subgroup to item
function OSM.lib.item.assign_subgroup(item_name, item_subgroup, item_order)
	if data.raw.item[item_name] then
		data.raw.item[item_name].subgroup = item_subgroup
		if item_order then
			data.raw.item[item_name].order = item_order
		end
	end
end

-- Removes item from achievement requirements
function OSM.lib.item.remove_achievement_requirement(item_name)

	-- Host achievement types
	local game_achievement_list =
	{
		"produce-achievement",
		"produce-per-hour-achievement"
	}

	-- Scan achievements for item requirements
	for _, achievement_type in pairs(game_achievement_list) do
		for _, achievement in pairs(data.raw[achievement_type]) do
			
			local achievement_name = achievement.name
			if data.raw[achievement_type][achievement_name].item_product == item_name then
				data.raw[achievement_type][achievement_name] = nil
			end
		end
	end
end