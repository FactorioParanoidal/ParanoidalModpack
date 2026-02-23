-- Copyright (c) Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

local api = require("prototypes.api")

if not (mods["UltimateBelts"] or mods["UltimateBeltsSpaceAge"]) then
	return
end

local base_tint = util.color("404040")
local tint_base_as_overlay = true
local variant = api.defines.belt_sprites.turbo

local tiers = {
	["ultra-fast-"] = { tint = util.color("00b30cff") },
	["extreme-fast-"] = { tint = util.color("e00000ff"), arrow_tint = util.color("5") },
	["ultra-express-"] = { tint = util.color("3604b5e8"), arrow_tint = util.color("5") },
	["extreme-express-"] = { tint = util.color("002bffff"), arrow_tint = util.color("5") },
	["ultimate-"] = { tint = util.color("00ffddd1") },
	["original-ultimate-"] = { tint = util.color("00ffddd1") },
}

-- Setup all the entities to use the updated belt animation sets
for prefix, properties in pairs(tiers) do
	-- Fetch entities
	local entities = {
		belt = data.raw["transport-belt"][prefix .. "belt"],
		splitter = data.raw["splitter"][prefix .. "splitter"],
		underground = data.raw["underground-belt"][prefix .. "underground-belt"],
		loader = data.raw["loader"]["ub-" .. prefix .. "loader"],

		-- Miniloader
		miniloader = data.raw["loader-1x1"]["ub-" .. prefix .. "miniloader-loader"],
		filter_miniloader = data.raw["loader-1x1"]["ub-" .. prefix .. "filter-miniloader-loader"],

		-- Deadlock Stacking Beltboxes and Compact loaders
		deadlock_loader = data.raw["loader-1x1"][prefix .. "belt-loader"],

		-- Loaders Modernized
		mdrn_loader = data.raw["loader-1x1"][prefix .. "mdrn-loader"],
		mdrn_loader_split = data.raw["loader-1x1"][prefix .. "mdrn-loader-split"],

		-- AAI Loaders
		aai_loader = data.raw["loader-1x1"]["aai-" .. prefix .. "loader"],
	}

	-- Reskin the belt item
	local belt_item = data.raw["item"][prefix .. "belt"]

	if belt_item then
		belt_item.icons = api.get_transport_belt_icon({
			use_three_arrow_variant = true,
			base_tint = base_tint,
			mask_tint = properties.tint,
			arrow_tint = properties.arrow_tint and { 0.2, 0.2, 0.2, 0 } or nil,
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
				base_tint = base_tint,
				tint_base_as_overlay = tint_base_as_overlay,
				mask_tint = properties.tint,
				tint_mask_as_overlay = true,
				variant = variant,
				arrow_tint = properties.arrow_tint,
			})
		end
	end

	-- Setup remnants
	if entities.belt then
		api.create_remnant(prefix .. "belt", {
			base_tint = base_tint,
			tint_base_as_overlay = tint_base_as_overlay,
			mask_tint = properties.tint,
			tint_mask_as_overlay = true,
			variant = variant,
			arrow_tint = properties.arrow_tint,
		})
	end

	-- Setup logistics technologies
	local technology = data.raw["technology"][prefix .. "logistics"]

	if technology then
		technology.icons = api.get_transport_belt_technology_icon({
			base_tint = util.color("404040"),
			mask_tint = properties.tint,
			arrow_tint = properties.arrow_tint and { 0.2, 0.2, 0.2, 0 } or nil,
		})
	end
end
