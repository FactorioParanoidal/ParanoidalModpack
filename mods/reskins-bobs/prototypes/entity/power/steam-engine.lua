-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.power.steam) then
	return
end

-- Set input parameters
local inputs = {
	type = "generator",
	icon_name = "steam-engine",
	base_entity_name = "steam-engine",
	mod = "bobs",
	group = "power",
	particles = { ["medium"] = 2, ["big"] = 1 },
}

local tier_map = {
	["steam-engine"] = { tier = 1 },
	["bob-steam-engine-2"] = { tier = 2 },
	["bob-steam-engine-3"] = { tier = 3 },
	["bob-steam-engine-4"] = { tier = 4 },
	["bob-steam-engine-5"] = { tier = 5 },
}

---@param tint data.Color
---@return data.RotatedAnimation
local function get_steam_engine_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/steam-engine/remnants/steam-engine-remnants.png",
				width = 462,
				height = 386,
				direction_count = 4,
				shift = util.by_pixel(17, 6.5),
				scale = 0.5,
			},
			-- Color Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-engine/remnants/steam-engine-remnants-mask.png",
				width = 462,
				height = 386,
				direction_count = 4,
				shift = util.by_pixel(17, 6.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-engine/remnants/steam-engine-remnants-highlights.png",
				width = 462,
				height = 386,
				direction_count = 4,
				shift = util.by_pixel(17, 6.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.GeneratorPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end
	inputs.tint = reskins.lib.tiers.get_tint(map.tier)

	reskins.lib.setup_standard_entity(name, map.tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	local remnant_animation = get_steam_engine_remnant_animation(inputs.tint)
	remnant.animation = make_rotated_animation_variations_from_sheet(1, remnant_animation)

	-- Reskin entities
	entity.horizontal_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/steam-engine/steam-engine-H.png",
				width = 352,
				height = 257,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(1, -4.75),
				scale = 0.5,
			},
			-- Color Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-engine/steam-engine-H-mask.png",
				width = 352,
				height = 257,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(1, -4.75),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-engine/steam-engine-H-highlights.png",
				width = 352,
				height = 257,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(1, -4.75),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png",
				width = 508,
				height = 160,
				frame_count = 32,
				line_length = 8,
				draw_as_shadow = true,
				shift = util.by_pixel(48, 24),
				scale = 0.5,
			},
		},
	}

	entity.vertical_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/steam-engine/steam-engine-V.png",
				width = 225,
				height = 391,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(4.75, -6.25),
				scale = 0.5,
			},
			-- Color mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-engine/steam-engine-V-mask.png",
				width = 225,
				height = 391,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(4.75, -6.25),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-engine/steam-engine-V-highlights.png",
				width = 225,
				height = 391,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(4.75, -6.25),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png",
				width = 330,
				height = 307,
				frame_count = 32,
				line_length = 8,
				draw_as_shadow = true,
				shift = util.by_pixel(40.5, 9.25),
				scale = 0.5,
			},
		},
	}

	::continue::
end
