-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "powder-mixer",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "smelting",
	make_remnants = false,
}

local tier_map = {
	["angels-powder-mixer"] = { tier = 1, prog_tier = 2 },
	["angels-powder-mixer-2"] = { tier = 2, prog_tier = 3 },
	["angels-powder-mixer-3"] = { tier = 3, prog_tier = 4 },
	["angels-powder-mixer-4"] = { tier = 4, prog_tier = 5 },
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
				filename = "__angelssmeltinggraphics__/graphics/entity/powder-mixer/powder-mixer-base.png",
				priority = "extra-high",
				width = 138,
				height = 170,
				line_length = 4,
				frame_count = 4,
				animation_speed = 0.5,
				shift = util.by_pixel(0.5, -9.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/smelting/powder-mixer/powder-mixer-mask.png",
				priority = "extra-high",
				width = 138,
				height = 170,
				line_length = 4,
				frame_count = 4,
				animation_speed = 0.5,
				shift = util.by_pixel(0.5, -9.5),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/smelting/powder-mixer/powder-mixer-highlights.png",
				priority = "extra-high",
				width = 138,
				height = 170,
				line_length = 4,
				frame_count = 4,
				animation_speed = 0.5,
				shift = util.by_pixel(0.5, -9.5),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__angelssmeltinggraphics__/graphics/entity/powder-mixer/powder-mixer-shadow.png",
				priority = "extra-high",
				width = 183,
				height = 99,
				repeat_count = 4,
				animation_speed = 0.5,
				draw_as_shadow = true,
				shift = util.by_pixel(13, 9),
				scale = 0.5,
			},
		},
	}

	::continue::
end
