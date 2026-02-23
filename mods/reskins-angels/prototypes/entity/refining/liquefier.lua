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
	icon_name = "liquefier",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "refining",
	make_remnants = false,
}

local tier_map = {
	["angels-liquifier"] = { tier = 1 },
	["angels-liquifier-2"] = { tier = 2 },
	["angels-liquifier-3"] = { tier = 3 },
	["angels-liquifier-4"] = { tier = 4 },
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
				filename = "__angelsrefininggraphics__/graphics/entity/liquifier/liquifier.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				frame_count = 30,
				line_length = 10,
				shift = { 0, 0 },
				animation_speed = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/refining/liquefier/liquefier-mask.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				repeat_count = 30,
				shift = { 0, 0 },
				animation_speed = 0.5,
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/refining/liquefier/liquefier-highlights.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				repeat_count = 30,
				shift = { 0, 0 },
				animation_speed = 0.5,
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}

	::continue::
end
