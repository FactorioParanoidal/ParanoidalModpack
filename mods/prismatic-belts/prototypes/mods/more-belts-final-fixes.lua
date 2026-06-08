local sprite_utils = { icons = require("__reskins-sprite-utils__.icons") }

if not mods["more-belts"] then
	return
end

local belt = data.raw["transport-belt"]["transport-belt"]
local splitter = data.raw["splitter"]["splitter"]
local lane_splitter = data.raw["lane-splitter"]["lane-splitter"]

if not belt and splitter and lane_splitter then
	return
end

local function get_lane_splitter_icon(splitter_entity, belt_entity)
	local splitter_icon = sprite_utils.icons.get_icon_from_prototype(splitter_entity)
	local belt_icon = sprite_utils.icons.get_icon_from_prototype(belt_entity)

	return sprite_utils.icons.compose_icons("default", splitter_icon, sprite_utils.icons.transform_icon(belt_icon, 0.5, { 8, -8 }))
end

---@type DeferrableIconData
local deferrable_icon = {
	name = lane_splitter.name,
	type_name = lane_splitter.type,
	icon_data = get_lane_splitter_icon(splitter, belt),
}

sprite_utils.icons.assign_deferrable_icon(deferrable_icon)
