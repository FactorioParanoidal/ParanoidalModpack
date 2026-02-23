-- Copyright (c) Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

local api = require("prototypes.api")

if not mods["more-belts"] then
	return
end

local tiers = {
	["mk4"] = {
		tint = util.color("#66ffba"),
		technology = "logistics-4",
		variant = api.defines.belt_sprites.fast,
	},
	["mk5"] = {
		tint = util.color("#669cff"),
		technology = "logistics-5",
		variant = api.defines.belt_sprites.fast,
	},
	["mk6"] = {
		tint = util.color("#ff9166"),
		technology = "logistics-6",
		variant = api.defines.belt_sprites.turbo,
	},
	["mk7"] = {
		tint = util.color("#c566ff"),
		technology = "logistics-7",
		variant = api.defines.belt_sprites.turbo,
	},
	["mk8"] = {
		tint = util.color("#ff66a6"),
		technology = "logistics-8",
		variant = api.defines.belt_sprites.turbo,
	},
}

local function get_lane_splitter_icon(splitter_entity, belt_entity)
	local splitter_icon = api.icons.get_icon_from_prototype_by_reference(splitter_entity)
	local belt_icon = api.icons.get_icon_from_prototype_by_reference(belt_entity)
	return api.icons.combine_icons(false, splitter_icon, api.icons.transform_icon(belt_icon, 0.5, { 8, -8 }))
end

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

		api.icons.assign_deferrable_icon(lane_splitter_icon)
	end
end

for tier, properties in pairs(tiers) do
	local entities = {
		belt = data.raw["transport-belt"]["ddi-transport-belt-" .. tier],
		splitter = data.raw["splitter"]["ddi-splitter-" .. tier],
		lane_splitter = data.raw["lane-splitter"][tier .. "-lane-splitter"],
		underground = data.raw["underground-belt"]["ddi-underground-belt-" .. tier],
		loader = data.raw["loader"]["ddi-loader-" .. tier],
	}

	if entities.belt then
		---@type DeferrableIconData
		local belt_icon = {
			name = entities.belt.name,
			type_name = entities.belt.type,
			icon_data = api.get_transport_belt_icon({
				mask_tint = properties.tint,
			}),
		}

		api.icons.assign_deferrable_icon(belt_icon)

		if entities.splitter and entities.lane_splitter then
			---@type DeferrableIconData
			local lane_splitter_icon = {
				name = entities.lane_splitter.name,
				type_name = entities.lane_splitter.type,
				icon_data = get_lane_splitter_icon(entities.splitter, entities.belt),
			}

			api.icons.assign_deferrable_icon(lane_splitter_icon)
		end
	end

	-- Reskin all related entity types
	for _, entity in pairs(entities) do
		if entity then
			entity.belt_animation_set = api.get_transport_belt_animation_set({
				mask_tint = properties.tint,
				tint_mask_as_overlay = true,
				variant = properties.variant,
			})
		end
	end

	-- Setup remnants
	if entities.belt then
		api.create_remnant(entities.belt.name, {
			mask_tint = properties.tint,
			tint_mask_as_overlay = true,
		})
	end

	-- Setup logistics technologies
	local technology = data.raw["technology"][properties.technology]

	if technology then
		technology.icons = api.get_transport_belt_technology_icon({ mask_tint = properties.tint })
	end
end
