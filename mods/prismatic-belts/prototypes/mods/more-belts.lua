local api = require("prototypes.api")
local sprite_utils = {
	icons = require("__reskins-sprite-utils__.icons"),
	colors = require("__reskins-sprite-utils__.colors"),
}

if not mods["more-belts"] then
	return
end


---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["mk4"] = {
		logistics_technology = {
			name = "logistics-4",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF66FFBA"),
		},
	},
	["mk5"] = {
		logistics_technology = {
			name = "logistics-5",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF669CFF"),
		},
	},
	["mk6"] = {
		logistics_technology = {
			name = "logistics-6",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFFF9166"),
		},
	},
	["mk7"] = {
		logistics_technology = {
			name = "logistics-7",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFC566FF"),
		},
	},
	["mk8"] = {
		logistics_technology = {
			name = "logistics-8",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFFF66A6"),
		},
	},
}

local function get_lane_splitter_icon(splitter_entity, belt_entity)
	local splitter_icon = sprite_utils.icons.get_icon_from_prototype(splitter_entity)
	local belt_icon = sprite_utils.icons.get_icon_from_prototype(belt_entity)
	return sprite_utils.icons.compose_icons("default", splitter_icon, sprite_utils.icons.transform_icon(belt_icon, 0.5, { 8, -8 }))
end

for tier, inputs in pairs(transport_belt_inputs_map) do
	api.transform_belt_and_related_connectables("ddi-transport-belt-" .. tier, inputs)

	local belt = data.raw["transport-belt"]["ddi-transport-belt-" .. tier]
	local splitter = data.raw["splitter"]["ddi-splitter-" .. tier]
	local lane_splitter = data.raw["lane-splitter"][tier .. "-lane-splitter"]

	if belt and splitter and lane_splitter then
		---@type DeferrableIconData
		local lane_splitter_icon = {
			name = lane_splitter.name,
			type_name = lane_splitter.type,
			icon_data = get_lane_splitter_icon(splitter, belt),
		}

		sprite_utils.icons.assign_deferrable_icon(lane_splitter_icon)
	end
end

-- Also handle the lane splitters added for the vanilla belts. Note that the standard lane splitter
-- needs to be handled in data-final-fixes.
for _, prefix in pairs({ "fast-", "express-" }) do
	local belt = data.raw["transport-belt"][prefix .. "transport-belt"]
	local splitter = data.raw["splitter"][prefix .. "splitter"]
	local lane_splitter = data.raw["lane-splitter"][prefix .. "lane-splitter"]

	if belt and splitter and lane_splitter then
		---@type DeferrableIconData
		local lane_splitter_icon = {
			name = lane_splitter.name,
			type_name = lane_splitter.type,
			icon_data = get_lane_splitter_icon(splitter, belt),
		}

		sprite_utils.icons.assign_deferrable_icon(lane_splitter_icon)
	end
end
