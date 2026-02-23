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
	icon_name = "steam-turbine",
	base_entity_name = "steam-turbine",
	mod = "bobs",
	group = "power",
	particles = { ["medium"] = 2, ["big"] = 1 },
}

local tier_map = {
	["steam-turbine"] = { tier = 1, prog_tier = 3 },
	["bob-steam-turbine-2"] = { tier = 2, prog_tier = 4 },
	["bob-steam-turbine-3"] = { tier = 3, prog_tier = 5 },
}

---@param tint data.Color
---@return data.RotatedAnimation
local function get_steam_turbine_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/steam-turbine/remnants/steam-turbine-remnants.png",
				width = 460,
				height = 408,
				direction_count = 4,
				shift = util.by_pixel(6, 0),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-turbine/remnants/steam-turbine-remnants-mask.png",
				width = 460,
				height = 408,
				direction_count = 4,
				shift = util.by_pixel(6, 0),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-turbine/remnants/steam-turbine-remnants-highlights.png",
				width = 460,
				height = 408,
				direction_count = 4,
				shift = util.by_pixel(6, 0),
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

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	local remnant_animation = get_steam_turbine_remnant_animation(inputs.tint)
	remnant.animation = make_rotated_animation_variations_from_sheet(1, remnant_animation)

	-- Reskin entities
	entity.horizontal_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H.png",
				width = 320,
				height = 245,
				frame_count = 8,
				line_length = 4,
				shift = util.by_pixel(0, -2.75),
				run_mode = "backward",
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-turbine/steam-turbine-H-mask.png",
				width = 320,
				height = 245,
				repeat_count = 8,
				shift = util.by_pixel(0, -2.75),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-turbine/steam-turbine-H-highlights.png",
				width = 320,
				height = 245,
				repeat_count = 8,
				shift = util.by_pixel(0, -2.75),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
				width = 435,
				height = 150,
				repeat_count = 8,
				draw_as_shadow = true,
				shift = util.by_pixel(28.5, 18),
				run_mode = "backward",
				scale = 0.5,
			},
		},
	}

	entity.vertical_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V.png",
				width = 217,
				height = 374,
				frame_count = 8,
				line_length = 4,
				shift = util.by_pixel(4.75, 0.0),
				run_mode = "backward",
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-turbine/steam-turbine-V-mask.png",
				width = 217,
				height = 347,
				repeat_count = 8,
				shift = util.by_pixel(4.75, 6.75),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/steam-turbine/steam-turbine-V-highlights.png",
				width = 217,
				height = 347,
				repeat_count = 8,
				shift = util.by_pixel(4.75, 6.75),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
				width = 302,
				height = 260,
				repeat_count = 8,
				draw_as_shadow = true,
				shift = util.by_pixel(39.5, 24.5),
				run_mode = "backward",
				scale = 0.5,
			},
		},
	}

	::continue::
end
