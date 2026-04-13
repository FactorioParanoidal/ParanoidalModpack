-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api.sprites.chemical-plants" then
	return require("__reskins-library__.api.sprites.chemical-plants")
end

--- Provides methods for getting sprites for chemical-plant-type entities.
---
---### Examples
---```lua
---local _sprites = require("__reskins-library__.api.sprites.chemical-plants")
---```
---@class Reskins.Lib.Sprites.ChemicalPlants
local _chemical_plants = {}

---
---Gets the standard working visualisations for a chemical plant. This is the Factorio default.
---
---### Returns
---@return data.WorkingVisualisation # The complete set of working visualisations.
---@nodiscard
function _chemical_plants.get_standard_working_visualisations()
	---@type data.WorkingVisualisation
	local working_visualisation = {
		{
			apply_recipe_tint = "primary",
			north_animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-north.png",
				frame_count = 24,
				line_length = 6,
				width = 66,
				height = 44,
				shift = util.by_pixel(23, 15),
				scale = 0.5,
			},
			east_animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-east.png",
				frame_count = 24,
				line_length = 6,
				width = 70,
				height = 36,
				shift = util.by_pixel(0, 22),
				scale = 0.5,
			},
			south_animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-south.png",
				frame_count = 24,
				line_length = 6,
				width = 66,
				height = 42,
				shift = util.by_pixel(0, 17),
				scale = 0.5,
			},
			west_animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-west.png",
				frame_count = 24,
				line_length = 6,
				width = 74,
				height = 36,
				shift = util.by_pixel(-10, 13),
				scale = 0.5,
			},
		},
		{
			apply_recipe_tint = "secondary",
			north_animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-north.png",
				frame_count = 24,
				line_length = 6,
				width = 62,
				height = 42,
				shift = util.by_pixel(24, 15),
				scale = 0.5,
			},
			east_animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-east.png",
				frame_count = 24,
				line_length = 6,
				width = 68,
				height = 36,
				shift = util.by_pixel(0, 22),
				scale = 0.5,
			},
			south_animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-south.png",
				frame_count = 24,
				line_length = 6,
				width = 60,
				height = 40,
				shift = util.by_pixel(1, 17),
				scale = 0.5,
			},
			west_animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-west.png",
				frame_count = 24,
				line_length = 6,
				width = 68,
				height = 28,
				shift = util.by_pixel(-9, 15),
				scale = 0.5,
			},
		},
		{
			apply_recipe_tint = "tertiary",
			fadeout = true,
			constant_speed = true,
			north_position = util.by_pixel_hr(-30, -161),
			east_position = util.by_pixel_hr(29, -150),
			south_position = util.by_pixel_hr(12, -134),
			west_position = util.by_pixel_hr(-32, -130),
			render_layer = "wires",
			animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-smoke-outer.png",
				frame_count = 47,
				line_length = 16,
				width = 90,
				height = 188,
				animation_speed = 0.5,
				shift = util.by_pixel(-2, -40),
				scale = 0.5,
			},
		},
		{
			apply_recipe_tint = "quaternary",
			fadeout = true,
			constant_speed = true,
			north_position = util.by_pixel_hr(-30, -161),
			east_position = util.by_pixel_hr(29, -150),
			south_position = util.by_pixel_hr(12, -134),
			west_position = util.by_pixel_hr(-32, -130),
			render_layer = "wires",
			animation = {
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-smoke-inner.png",
				frame_count = 47,
				line_length = 16,
				width = 40,
				height = 84,
				animation_speed = 0.5,
				shift = util.by_pixel(0, -14),
				scale = 0.5,
			},
		},
	}

	return working_visualisation
end

---
---Gets an `Animation4Way` object containing vanilla-type (standard) chemical plant sprites colored
---using the given `tint`.
---
---### Returns
---@return data.Animation4Way # The complete set of tinted sprites.
---
---### Examples
---```lua
----- Get the sprites colored for a tier 3 chemical plant.
---local tint = reskins.lib.tiers.get_tint(3)
---local chemical_plant = data.raw["assembling-machine"]["chemical-plant-3"]
---
---chemical_plant.animation = _chemical_plants.get_standard_animation(tint)
---```
---
---### Parameters
---@param tint data.Color
---@nodiscard
function _chemical_plants.get_standard_animation(tint)
	return reskins.lib.sprites.make_4way_animation_from_spritesheet({
		layers = {
			-- Base
			{
				filename = "__reskins-library__/graphics/entity/common/chemical-plant/chemical-plant-base.png",
				width = 220,
				height = 292,
				frame_count = 24,
				line_length = 12,
				shift = util.by_pixel(0.5, -9),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-library__/graphics/entity/common/chemical-plant/chemical-plant-mask.png",
				width = 220,
				height = 292,
				frame_count = 24,
				line_length = 12,
				shift = util.by_pixel(0.5, -9),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-library__/graphics/entity/common/chemical-plant/chemical-plant-highlights.png",
				width = 220,
				height = 292,
				frame_count = 24,
				line_length = 12,
				shift = util.by_pixel(0.5, -9),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/chemical-plant/chemical-plant-shadow.png",
				width = 312,
				height = 222,
				repeat_count = 24,
				shift = util.by_pixel(27, 6),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	})
end

---
---Gets a `RotatedAnimationVariations` object containing vanilla-type (standard) chemical plant
---remnant sprites colored using the given `tint`.
---
---### Returns
---@return data.RotatedAnimationVariations # The complete set of tinted remnant sprites.
---
---### Examples
---```lua
----- Get the remnant sprites colored for a tier 3 chemical plant.
---local tint = reskins.lib.tiers.get_tint(3)
---local chemical_plant_remants = data.raw["corpse"]["chemical-plant-3-remnants"]
---
---chemical_plant_remants.animation = _chemical_plants.get_standard_remnants(tint)
---```
---
---### Parameters
---@param tint data.Color # The color of the remnant sprites.
---@nodiscard
function _chemical_plants.get_standard_remnants(tint)
	---@type data.RotatedAnimationVariations
	local animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-library__/graphics/entity/common/chemical-plant/remnants/chemical-plant-remnants-base.png",
				width = 446,
				height = 342,
				direction_count = 1,
				shift = util.by_pixel(16, -5.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-library__/graphics/entity/common/chemical-plant/remnants/chemical-plant-remnants-mask.png",
				width = 446,
				height = 342,
				direction_count = 1,
				shift = util.by_pixel(16, -5.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-library__/graphics/entity/common/chemical-plant/remnants/chemical-plant-remnants-highlights.png",
				width = 446,
				height = 342,
				direction_count = 1,
				shift = util.by_pixel(16, -5.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return animation
end

return _chemical_plants
