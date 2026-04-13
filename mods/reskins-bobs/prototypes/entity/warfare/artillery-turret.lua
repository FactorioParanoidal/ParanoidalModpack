-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "artillery-turret",
	icon_name = "artillery-turret",
	base_entity_name = "artillery-turret",
	mod = "bobs",
	group = "warfare",
	particles = { ["big"] = 4 },
}

local tier_map = {
	["artillery-turret"] = { tier = 1, prog_tier = 3 },
	["bob-artillery-turret-2"] = { tier = 2, prog_tier = 4 },
	["bob-artillery-turret-3"] = { tier = 3, prog_tier = 5 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.ArtilleryTurretPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	remnant.animation = make_rotated_animation_variations_from_sheet(1, {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/artillery-turret/remnants/artillery-turret-remnants-base.png",
				width = 326,
				height = 290,
				direction_count = 1,
				shift = util.by_pixel(9.5, 1.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/artillery-turret/remnants/artillery-turret-remnants-mask.png",
				width = 326,
				height = 290,
				direction_count = 1,
				shift = util.by_pixel(9.5, 1.5),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/artillery-turret/remnants/artillery-turret-remnants-highlights.png",
				width = 326,
				height = 290,
				direction_count = 1,
				shift = util.by_pixel(9.5, 1.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	})

	-- Reskin entity
	entity.base_picture = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/artillery-turret/artillery-turret-base.png",
				priority = "high",
				width = 207,
				height = 199,
				shift = util.by_pixel(-0, 22),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/artillery-turret/artillery-turret-mask.png",
				priority = "high",
				width = 207,
				height = 199,
				shift = util.by_pixel(-0, 22),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/artillery-turret/artillery-turret-highlights.png",
				priority = "high",
				width = 207,
				height = 199,
				shift = util.by_pixel(-0, 22),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png",
				priority = "high",
				width = 277,
				height = 149,
				shift = util.by_pixel(18 + 2, 38),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	::continue::
end
