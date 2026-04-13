-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.power.solar) then
	return
end

-- Set input parameters
local inputs = {
	type = "solar-panel",
	base_entity_name = "solar-panel",
	mod = "bobs",
	group = "power",
	particles = { ["small"] = 2 },
}

local tier_map = {
	["bob-solar-panel-small"] = { tier = 1, prog_tier = 2 },
	["bob-solar-panel-small-2"] = { tier = 2, prog_tier = 3 },
	["bob-solar-panel-small-3"] = { tier = 3, prog_tier = 4 },
	["solar-panel"] = { tier = 1, prog_tier = 2 },
	["bob-solar-panel-2"] = { tier = 2, prog_tier = 3 },
	["bob-solar-panel-3"] = { tier = 3, prog_tier = 4 },
	["bob-solar-panel-large"] = { tier = 1, prog_tier = 2 },
	["bob-solar-panel-large-2"] = { tier = 2, prog_tier = 3 },
	["bob-solar-panel-large-3"] = { tier = 3, prog_tier = 4 },
}

---@param tint data.Color
---@return data.RotatedAnimation
local function get_small_solar_panel_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/power/solar-panel-small/remnants/small-solar-panel-remnants-base.png",
				width = 246,
				height = 198,
				direction_count = 1,
				shift = util.by_pixel(-1, -0.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/solar-panel-small/remnants/small-solar-panel-remnants-mask.png",
				width = 246,
				height = 198,
				direction_count = 1,
				shift = util.by_pixel(-1, -0.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/solar-panel-small/remnants/small-solar-panel-remnants-highlights.png",
				width = 246,
				height = 198,
				direction_count = 1,
				shift = util.by_pixel(-1, -0.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

---@param tint data.Color
---@return data.RotatedAnimation
local function get_solar_panel_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/solar-panel/remnants/solar-panel-remnants.png",
				width = 290,
				height = 282,
				direction_count = 1,
				shift = util.by_pixel(3.5, 0),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/solar-panel/remnants/solar-panel-remnants-mask.png",
				width = 290,
				height = 282,
				direction_count = 1,
				shift = util.by_pixel(3.5, 0),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/solar-panel/remnants/solar-panel-remnants-highlights.png",
				width = 290,
				height = 282,
				direction_count = 1,
				shift = util.by_pixel(3.5, 0),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.SolarPanelPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Solar panels have a letter annotation to help distinguish them at a glance.
	local letter
	if string.find(name, "small", 1, true) then
		letter = "S"
		inputs.icon_name = "solar-panel-small"
	elseif string.find(name, "large", 1, true) then
		letter = "L"
		inputs.icon_name = "solar-panel-large"
	else
		letter = "M"
		inputs.icon_name = "solar-panel"
	end

	inputs.icon_extras = reskins.lib.icons.get_letter(letter, inputs.tint)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnants
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin entities
	if inputs.icon_name == "solar-panel-small" then
		-- Reskin remnants
		local remnant_animation = get_small_solar_panel_remnant_animation(inputs.tint)
		remnant.animation = make_rotated_animation_variations_from_sheet(2, remnant_animation)

		-- Overwrite picture table in target entity
		entity.picture = {
			layers = {
				-- Base
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-small/base/solar-panel-small.png",
					priority = "high",
					width = 180,
					height = 150,
					shift = util.by_pixel(5, 0.5),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-small/solar-panel-small-mask.png",
					priority = "high",
					width = 180,
					height = 150,
					shift = util.by_pixel(5, 0.5),
					tint = inputs.tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-small/solar-panel-small-highlights.png",
					priority = "high",
					width = 180,
					height = 150,
					shift = util.by_pixel(5, 0.5),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-small/base/solar-panel-small-shadow.png",
					priority = "high",
					width = 180,
					height = 150,
					shift = util.by_pixel(5, 0.5),
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		}

		-- Overwrite or create overlay table in target entity
		entity.overlay = {
			layers = {
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-small/base/solar-panel-small-shadow-overlay.png",
					priority = "high",
					width = 180,
					height = 150,
					shift = util.by_pixel(5, 0.5),
					scale = 0.5,
				},
			},
		}
	elseif inputs.icon_name == "solar-panel" then
		-- Reskin remnants
		local remnant_animation = get_solar_panel_remnant_animation(inputs.tint)
		remnant.animation = make_rotated_animation_variations_from_sheet(2, remnant_animation)

		-- Overwrite picture table in target entity
		entity.picture = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/solar-panel/solar-panel.png",
					priority = "high",
					width = 230,
					height = 224,
					shift = util.by_pixel(-3, 3.5),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel/solar-panel-mask.png",
					priority = "high",
					width = 230,
					height = 224,
					shift = util.by_pixel(-3, 3.5),
					tint = inputs.tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel/solar-panel-highlights.png",
					priority = "high",
					width = 230,
					height = 224,
					shift = util.by_pixel(-3, 3.5),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
					priority = "high",
					width = 220,
					height = 180,
					shift = util.by_pixel(9.5, 6),
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		}

		-- Overwrite or create overlay table in target entity
		entity.overlay = {
			layers = {
				{
					filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
					priority = "high",
					width = 214,
					height = 180,
					shift = util.by_pixel(10.5, 6),
					scale = 0.5,
				},
			},
		}
	elseif inputs.icon_name == "solar-panel-large" then
		-- TODO: Large remnants

		-- Overwrite picture table in target entity
		entity.picture = {
			layers = {
				-- Base
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-large/base/solar-panel-large.png",
					priority = "high",
					width = 308,
					height = 274,
					shift = util.by_pixel(5, 3.5),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-large/solar-panel-large-mask.png",
					priority = "high",
					width = 308,
					height = 274,
					shift = util.by_pixel(5, 3.5),
					tint = inputs.tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-large/solar-panel-large-highlights.png",
					priority = "high",
					width = 308,
					height = 274,
					shift = util.by_pixel(5, 3.5),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-large/base/solar-panel-large-shadow.png",
					priority = "high",
					width = 308,
					height = 274,
					shift = util.by_pixel(5, 3.5),
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		}

		-- Overwrite or create overlay table in target entity
		entity.overlay = {
			layers = {
				{
					filename = "__reskins-bobs__/graphics/entity/power/solar-panel-large/base/solar-panel-large-shadow-overlay.png",
					priority = "high",
					width = 308,
					height = 274,
					shift = util.by_pixel(5, 3.5),
					scale = 0.5,
				},
			},
		}
	end

	::continue::
end
