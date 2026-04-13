-- Copyright (c) Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

local api = require("prototypes.api")
local meld = require("meld")

-- Setup belt animation sets for vanilla entities
local belt_animation_sets = {
	["transport-belt"] = {
		animation_set = {
			filename = "__prismatic-belts__/graphics/entity/base/transport-belt/transport-belt.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5,
			frame_count = 16,
			direction_count = 20,
		},
		frozen_patch = api.get_transport_belt_frozen_patch(1),
	},
	["fast-transport-belt"] = {
		animation_set = {
			filename = "__prismatic-belts__/graphics/entity/base/fast-transport-belt/fast-transport-belt.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5,
			frame_count = 32,
			direction_count = 20,
		},
		frozen_patch = api.get_transport_belt_frozen_patch(2),
	},
	["express-transport-belt"] = {
		animation_set = {
			filename = "__prismatic-belts__/graphics/entity/base/express-transport-belt/express-transport-belt.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5,
			frame_count = 32,
			direction_count = 20,
		},
		frozen_patch = api.get_transport_belt_frozen_patch(2),
	},
}

-- Add belt reader sprites.
meld(belt_animation_sets["transport-belt"], belt_reader_gfx)
meld(belt_animation_sets["fast-transport-belt"], belt_reader_gfx)
meld(belt_animation_sets["express-transport-belt"], belt_reader_gfx)

local tiers = {
	[""] = { technology = "logistics" },
	["fast-"] = { technology = "logistics-2" },
	["express-"] = { technology = "logistics-3" },
}

if mods["reskins-library"] then
	tiers[""].tier = 1
	tiers["fast-"].tier = 2
	tiers["express-"].tier = 3
end

if mods["miniloader"] then
	local chute = data.raw["loader-1x1"]["chute-miniloader-loader"]

	if chute then
		chute.belt_animation_set = belt_animation_sets["transport-belt"]
	end
end

if mods["loaders-modernized"] then
	local chute = data.raw["loader-1x1"]["chute-mdrn-loader"]

	if chute then
		chute.belt_animation_set = belt_animation_sets["transport-belt"]
	end
end

for prefix, properties in pairs(tiers) do
	-- Fetch entities
	local entities = {
		belt = data.raw["transport-belt"][prefix .. "transport-belt"],
		splitter = data.raw["splitter"][prefix .. "splitter"],

		-- More Belts, potentially others...
		lane_splitter = data.raw["lane-splitter"][prefix .. "lane-splitter"],

		underground = data.raw["underground-belt"][prefix .. "underground-belt"],
		loader = data.raw["loader"][prefix .. "loader"],

		-- Miniloader
		miniloader = data.raw["loader-1x1"][prefix .. "miniloader-loader"],
		filter_miniloader = data.raw["loader-1x1"][prefix .. "filter-miniloader-loader"],

		-- Deadlock Stacking Beltboxes and Compact loaders
		deadlock_loader = data.raw["loader-1x1"][prefix .. "transport-belt-loader"],

		-- Krastorio
		krastorio_loader = data.raw["loader-1x1"]["kr-" .. prefix .. "loader"],

		-- Loaders Modernized
		mdrn_loader = data.raw["loader-1x1"][prefix .. "mdrn-loader"],
		mdrn_loader_split = data.raw["loader-1x1"][prefix .. "mdrn-loader-split"],

		-- AAI Loaders
		aai_loader = data.raw["loader-1x1"]["aai-" .. prefix .. "loader"],
	}

	-- Reskin the belt item
	local belt_item = data.raw["item"][prefix .. "transport-belt"]
	if belt_item then
		---@type data.IconData[]
		local icon_data = { {
			icon = "__prismatic-belts__/graphics/icons/base/" .. prefix .. "transport-belt.png",
			icon_size = 64,
		} }

		-- Append tier labels for reskins-library
		if mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false)) then
			local do_labels = reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") == true

			---@type DeferrableIconData
			local deferrable_icon = {
				name = prefix .. "transport-belt",
				type_name = "transport-belt",
				icon_data = do_labels and reskins.lib.tiers.add_tier_labels_to_icons(properties.tier, icon_data) or icon_data,
				pictures = do_labels and reskins.lib.sprites.create_sprite_from_icons(icon_data, 1.0) or nil,
			}

			reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
		else
			belt_item.icons = icon_data

			-- Update entity icon to match
			if entities.belt then
				entities.belt.icons = belt_item.icons
			end
		end
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
			filename = "__prismatic-belts__/graphics/entity/base/" .. prefix .. "transport-belt/remnants/" .. prefix .. "transport-belt-remnants.png",
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
		---@type data.IconData[]
		local icon_data = { {
			icon = "__prismatic-belts__/graphics/technology/base/" .. properties.technology .. ".png",
			icon_size = 256,
		} }

		technology.icons = icon_data
	end
end
