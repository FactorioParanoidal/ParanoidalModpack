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
	icon_name = "electric-boiler",
	base_entity_name = "boiler",
	mod = "angels",
	particles = { ["big"] = 3 },
	group = "petrochem",
	make_remnants = false,
}

local tier_map = {
	["angels-electric-boiler"] = { tier = 1, prog_tier = 2 },
	["angels-electric-boiler-2"] = { tier = 2, prog_tier = 3 },
	["angels-electric-boiler-3"] = { tier = 3, prog_tier = 5 },
}

local working_lights = reskins.lib.sprites.make_4way_animation_from_spritesheet({
	filename = "__reskins-angels__/graphics/entity/petrochem/electric-boiler/electric-boiler-working-lights.png",
	priority = "extra-high",
	width = 160,
	height = 160,
	shift = { 0, 0 },
	blend_mode = "additive",
	draw_as_glow = true,
})

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
	entity.graphics_set.animation = reskins.lib.sprites.make_4way_animation_from_spritesheet({
		layers = {
			-- Base
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/electric-boiler/electric-boiler-base.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/electric-boiler/electric-boiler-mask.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/electric-boiler/electric-boiler-highlights.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	})

	entity.graphics_set.idle_animation = nil

	entity.graphics_set.working_visualisations = {
		{
			fadeout = true,
			effect = "uranium-glow",
			north_animation = working_lights.north,
			east_animation = working_lights.east,
			south_animation = working_lights.south,
			west_animation = working_lights.west,
		},
	}

	::continue::
end
