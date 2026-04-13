-- Copyright (c) Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

local api = require("prototypes.api")

if not (mods["Krastorio2"] or mods["Krastorio2-spaced-out"]) then
	return
end

local tiers = {
	["kr-advanced-"] = { tint = util.color("3ade21d1"), variant = api.defines.belt_sprites.fast, technology = "kr-logistic-4" },
	["kr-superior-"] = { tint = util.color("a30bd6d1"), variant = api.defines.belt_sprites.fast, technology = "kr-logistic-5" },
}

-- Setup all the entities to use the updated belt animation sets
for prefix, properties in pairs(tiers) do
	-- Fetch entities
	local entities = {
		belt = data.raw["transport-belt"][prefix .. "transport-belt"],
		splitter = data.raw["splitter"][prefix .. "splitter"],
		underground = data.raw["underground-belt"][prefix .. "underground-belt"],
		loader = data.raw["loader-1x1"][prefix .. "loader"],
		-- Miniloader
		miniloader = data.raw["loader-1x1"][prefix .. "miniloader-loader"],
		filter_miniloader = data.raw["loader-1x1"][prefix .. "filter-miniloader-loader"],

		-- Loaders Modernized
		mdrn_loader = data.raw["loader-1x1"][prefix .. "mdrn-loader"],
		mdrn_loader_split = data.raw["loader-1x1"][prefix .. "mdrn-loader-split"],

		-- AAI Loaders
		aai_loader = data.raw["loader-1x1"]["aai-" .. prefix .. "loader"],
	}

	-- Reskin the belt item
	local belt_item = data.raw["item"][prefix .. "transport-belt"]
	if belt_item then
		belt_item.icons = api.get_transport_belt_icon({
			mask_tint = properties.tint,
		})

		-- Update entity icon to match
		if entities.belt then
			entities.belt.icons = belt_item.icons
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
		api.create_remnant(prefix .. "transport-belt", {
			mask_tint = properties.tint,
			tint_mask_as_overlay = true,
		})
	end

	-- Setup logistics technologies
	local technology = data.raw["technology"][properties.technology]

	if technology then
		technology.icons = api.get_transport_belt_technology_icon({
			mask_tint = properties.tint,
		})
	end
end
