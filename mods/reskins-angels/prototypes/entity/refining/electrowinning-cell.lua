-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "electrowinning-cell",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "refining",
	make_remnants = false,
}

local tier_map = {
	["angels-electro-whinning-cell"] = { tier = 1, prog_tier = 4 },
	["angels-electro-whinning-cell-2"] = { tier = 2, prog_tier = 5 },
	["angels-electro-whinning-cell-3"] = { tier = 3, prog_tier = 6 }, -- FIXME: This may no longer exist.
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
				filename = "__angelsrefininggraphics__/graphics/entity/electro-whinning-cell/electro-whinning-cell.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				frame_count = 36,
				line_length = 6,
				shift = { 0, 0 },
				animation_speed = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/refining/electrowinning-cell/electrowinning-cell-mask.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				repeat_count = 36,
				shift = { 0, 0 },
				animation_speed = 0.5,
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/refining/electrowinning-cell/electrowinning-cell-highlights.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				repeat_count = 36,
				shift = { 0, 0 },
				animation_speed = 0.5,
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}

	::continue::
end
