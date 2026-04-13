-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then
	return
end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.radar = true
end

-- Set input parameters
local inputs = {
	type = "radar",
	icon_name = "radar",
	base_entity_name = "radar",
	mod = "bobs",
	group = "warfare",
	particles = { ["medium"] = 2 },
}

local tier_map = {
	["radar"] = 1,
	["bob-radar-2"] = 2,
	["bob-radar-3"] = 3,
	["bob-radar-4"] = 4,
	["bob-radar-5"] = 5,
}

---@param tint data.Color
---@return data.RotatedAnimation
local function get_radar_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/radar/remnants/radar-remnants.png",
				width = 282,
				height = 212,
				direction_count = 1,
				shift = util.by_pixel(12, 4.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/radar/remnants/radar-remnants-mask.png",
				width = 282,
				height = 212,
				direction_count = 1,
				shift = util.by_pixel(12, 4.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/radar/remnants/radar-remnants-highlights.png",
				width = 282,
				height = 212,
				direction_count = 1,
				shift = util.by_pixel(12, 4.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

-- Reskin entities, create and assign extra details
for name, tier in pairs(tier_map) do
	---@type data.RadarPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	local remnant_animation = get_radar_remnant_animation(inputs.tint)
	remnant.animation = make_rotated_animation_variations_from_sheet(1, remnant_animation)

	-- Reskin entity
	entity.integration_patch = {
		filename = "__base__/graphics/entity/radar/radar-integration.png",
		priority = "low",
		width = 238,
		height = 216,
		shift = util.by_pixel(1.5, 4),
		scale = 0.5,
	}

	entity.pictures = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/radar/radar.png",
				priority = "low",
				width = 196,
				height = 254,
				apply_projection = false,
				direction_count = 64,
				line_length = 8,
				shift = util.by_pixel(1.0, -16.0),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/radar/radar-mask.png",
				priority = "low",
				width = 196,
				height = 254,
				apply_projection = false,
				direction_count = 64,
				line_length = 8,
				shift = util.by_pixel(1, -16),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/radar/radar-highlights.png",
				priority = "low",
				width = 196,
				height = 254,
				apply_projection = false,
				direction_count = 64,
				line_length = 8,
				shift = util.by_pixel(1, -16),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/radar/radar-shadow.png",
				priority = "low",
				width = 336,
				height = 170,
				apply_projection = false,
				direction_count = 64,
				line_length = 8,
				shift = util.by_pixel(39.0, 6.0),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	if name ~= "radar" then
		entity.water_reflection = util.copy(data.raw[inputs.type]["radar"].water_reflection)
	end

	::continue::
end
