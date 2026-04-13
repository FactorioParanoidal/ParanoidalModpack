-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.bioprocessing.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "algae-farm",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "bioprocessing",
	make_remnants = false,
}

local tier_map = {
	["angels-algae-farm"] = { tier = 1, prog_tier = 0 },
	["angels-algae-farm-2"] = { tier = 2, prog_tier = 1 },
	["angels-algae-farm-3"] = { tier = 3, prog_tier = 2 },
	["angels-algae-farm-4"] = { tier = 4, prog_tier = 3 },
	["angels-algae-farm-5"] = { tier = 5, prog_tier = 4 }, -- Extended Angels
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
				filename = "__angelsbioprocessinggraphics__/graphics/entity/algae-farm/algae-farm.png",
				priority = "extra-high",
				width = 288,
				height = 288,
				line_length = 6,
				frame_count = 36,
				shift = { 0, 0 },
				animation_speed = 0.4,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/bioprocessing/algae-farm/algae-farm-mask.png",
				priority = "extra-high",
				width = 288,
				height = 288,
				repeat_count = 36,
				shift = { 0, 0 },
				animation_speed = 0.4,
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/bioprocessing/algae-farm/algae-farm-highlights.png",
				priority = "extra-high",
				width = 288,
				height = 288,
				repeat_count = 36,
				shift = { 0, 0 },
				animation_speed = 0.4,
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}

	::continue::
end
