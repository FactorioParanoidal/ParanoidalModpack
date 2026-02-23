-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then
	return
end
if not (reskins.angels and reskins.angels.triggers.bioprocessing.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "seed-extractor",
	base_entity_name = "assembling-machine-1",
	mod = "compatibility",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "extendedangels",
	make_remnants = false,
}

local tier_map = {
	["angels-seed-extractor"] = { tier = 1 },
	["angels-seed-extractor-2"] = { tier = 2 },
	["angels-seed-extractor-3"] = { tier = 3 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = map.tint or reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.graphics_set.animation = {
		layers = {
			-- Base
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/seed-extractor/seed-extractor.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				frame_count = 25,
				line_length = 5,
				shift = { 0, 0 },
				animation_speed = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-compatibility__/graphics/entity/extendedangels/seed-extractor/seed-extractor-mask.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				frame_count = 25,
				line_length = 5,
				shift = { 0, 0 },
				animation_speed = 0.5,
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-compatibility__/graphics/entity/extendedangels/seed-extractor/seed-extractor-highlights.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				frame_count = 25,
				line_length = 5,
				shift = { 0, 0 },
				animation_speed = 0.5,
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}

	::continue::
end
