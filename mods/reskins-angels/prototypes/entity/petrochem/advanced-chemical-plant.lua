-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "advanced-chemical-plant",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "petrochem",
	make_remnants = false,
}

local tier_map = {
	["angels-advanced-chemical-plant"] = { tier = 1, prog_tier = 2 },
	["angels-advanced-chemical-plant-2"] = { tier = 2, prog_tier = 4 },

	-- Extended Angels
	["angels-advanced-chemical-plant-3"] = { tier = 3, prog_tier = 5 },
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
				filename = "__angelspetrochemgraphics__/graphics/entity/advanced-chemical-plant/advanced-chemical-plant.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				frame_count = 16,
				line_length = 4,
				animation_speed = 0.5,
				shift = { 0, 0 },
			},
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/advanced-chemical-plant/advanced-chemical-plant-base-patch.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				repeat_count = 16,
				animation_speed = 0.5,
				shift = { 0, 0 },
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/advanced-chemical-plant/advanced-chemical-plant-mask.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				repeat_count = 16,
				animation_speed = 0.5,
				shift = { 0, 0 },
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/advanced-chemical-plant/advanced-chemical-plant-highlights.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				repeat_count = 16,
				animation_speed = 0.5,
				shift = { 0, 0 },
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}

	::continue::
end
