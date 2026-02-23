-- Copyright (c) Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

local api = require("prototypes.api")
local meld = require("meld")

if not mods["space-age"] then
	return
end

-- Setup belt animation sets for space-age entities.
---@type { [data.EntityID] : data.TransportBeltAnimationSet }
local belt_animation_sets = {
	["turbo-transport-belt"] = {
		alternate = true,
		animation_set = {
			filename = "__prismatic-belts__/graphics/entity/space-age/turbo-transport-belt/turbo-transport-belt.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5,
			frame_count = 64,
			direction_count = 20,
		},
		frozen_patch = api.get_transport_belt_frozen_patch(3),
	},
}

-- Add belt reader sprites.
meld(belt_animation_sets["turbo-transport-belt"], belt_reader_gfx)

local tiers = {
	["turbo-"] = { technology = "turbo-transport-belt" },
}

for prefix, properties in pairs(tiers) do
	-- Fetch entities
	local entities = {
		belt = data.raw["transport-belt"][prefix .. "transport-belt"],
		splitter = data.raw["splitter"][prefix .. "splitter"],
		underground = data.raw["underground-belt"][prefix .. "underground-belt"],
		loader = data.raw["loader"][prefix .. "loader"],

		-- Miniloader
		-- miniloader = data.raw["loader-1x1"][prefix .. "miniloader-loader"],
		-- filter_miniloader = data.raw["loader-1x1"][prefix .. "filter-miniloader-loader"],

		-- Deadlock Stacking Beltboxes and Compact loaders
		-- deadlock_loader = data.raw["loader-1x1"][prefix .. "transport-belt-loader"],

		-- Krastorio
		-- krastorio_loader = data.raw["loader-1x1"]["kr-" .. prefix .. "loader"],

		-- Loaders Modernized
		mdrn_loader = data.raw["loader-1x1"][prefix .. "mdrn-loader"],
		mdrn_loader_split = data.raw["loader-1x1"][prefix .. "mdrn-loader-split"],

		-- AAI Loaders
		aai_loader = data.raw["loader-1x1"]["aai-" .. prefix .. "loader"],
	}

	-- Reskin the belt item
	local belt_item = data.raw["item"][prefix .. "transport-belt"]
	if belt_item then
		local icon_data = { {
			icon = "__prismatic-belts__/graphics/icons/space-age/" .. prefix .. "transport-belt.png",
			icon_size = 64,
		} }

		-- Append tier labels for reskins-library
		-- if mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false)) then
		-- local do_labels = reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") == true

		-- ---@type DeferrableIconData
		-- local deferrable_icon = {
		--     name = prefix .. "transport-belt",
		--     type_name = "transport-belt",
		--     icon_data = do_labels and reskins.lib.tiers.add_tier_labels_to_icons(properties.tier, icon_data) or
		--         icon_data,
		--     pictures = do_labels and reskins.lib.sprites.create_sprite_from_icons(icon_data, 1.0) or nil,
		-- }

		-- reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
		-- else
		belt_item.icons = icon_data

		-- Update entity icon to match
		if entities.belt then
			entities.belt.icons = belt_item.icons
		end
		-- end
	end

	-- Reskin all related entity types
	for _, entity in pairs(entities) do
		if entity then
			entity.belt_animation_set = belt_animation_sets[prefix .. "transport-belt"]
		end
	end

	-- Setup remnants
	local remnants = data.raw["corpse"][prefix .. "transport-belt-remnants"]

	if remnants then
		if entities.belt then
			remnants.icons = entities.belt.icons
			remnants.icon = entities.belt.icon
			remnants.icon_size = entities.belt.icon_size
		end

		remnants.animation = make_rotated_animation_variations_from_sheet(2, {
			filename = "__prismatic-belts__/graphics/entity/space-age/" .. prefix .. "transport-belt/remnants/" .. prefix .. "transport-belt-remnants.png",
			line_length = 1,
			width = 106,
			height = 102,
			frame_count = 1,
			variation_count = 1,
			axially_symmetrical = false,
			direction_count = 4,
			shift = util.by_pixel(1, -0.5),
			scale = 0.5,
		})
	end

	-- Setup logistics technologies
	local technology = data.raw["technology"][properties.technology]

	if technology then
		local icon_data = { {
			icon = "__prismatic-belts__/graphics/technology/space-age/" .. properties.technology .. ".png",
			icon_size = 256,
		} }

		technology.icons = icon_data
	end
end
