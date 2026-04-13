-- Copyright (c) Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

local api = require("prototypes.api")

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
	local splitter_icon = api.icons.get_icon_from_prototype_by_reference(splitter_entity)
	local belt_icon = api.icons.get_icon_from_prototype_by_reference(belt_entity)

	return api.icons.combine_icons(false, splitter_icon, api.icons.transform_icon(belt_icon, 0.5, { 8, -8 }))
end

---@type DeferrableIconData
local deferrable_icon = {
	name = lane_splitter.name,
	type_name = lane_splitter.type,
	icon_data = get_lane_splitter_icon(splitter, belt),
}

api.icons.assign_deferrable_icon(deferrable_icon)
