-- Copyright (c) Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

local meld = require("meld")

---The Prismatic Belts library of API functions.
---
---### Examples
---```lua
---local api = require("__prismatic-belts__.prototypes.api")
---```
---@class PrismaticBelts.Api
local api = {
	defines = require("__prismatic-belts__.prototypes.defines"),
	icons = require("__prismatic-belts__.prototypes.icons"),
}

--- Ensure tint is normalized to between 0 and 1
---@param tint data.Color
---@return data.Color
local function normalize_tint(tint)
	local r = tint.r or tint[1]
	local g = tint.g or tint[2]
	local b = tint.b or tint[3]
	local a

	if r > 255 or g > 255 or b > 255 then
		r = r / 255
		g = g / 255
		b = b / 255
		a = tint.a / 255 or tint[4] / 255 or 1
	end

	return { r = r, g = g, b = b, a = a }
end

--- Adjust the alpha value of a given tint
---@param tint data.Color
---@param alpha float
---@return data.Color
local function adjust_alpha(tint, alpha)
	local normalized_tint = normalize_tint(tint)

	---@type data.Color
	local adjusted_tint = { r = normalized_tint.r, g = normalized_tint.g, b = normalized_tint.b, a = alpha }

	return adjusted_tint
end

---Gets the transport belt `frozen_patch` `RotatedSprite` for the given `variant`.
---
---If Space Age is not active, returns `nil`.
---@param variant PrismaticBelts.Api.Defines.BeltSprites Spritesheet to use for the frozen patch.
---@return data.RotatedSprite|nil
function api.get_transport_belt_frozen_patch(variant)
	if not mods["space-age"] then
		return nil
	end

	local frozen_sprite_filenames = {
		[1] = "__space-age__/graphics/entity/frozen/transport-belt/transport-belt.png",
		[2] = "__space-age__/graphics/entity/frozen/express-transport-belt/express-transport-belt.png",
		[3] = "__space-age__/graphics/entity/turbo-transport-belt/turbo-transport-belt-frozen.png",
	}

	---@type data.RotatedSprite
	local frozen_patch = {
		filename = frozen_sprite_filenames[variant],
		priority = "extra-high",
		size = 128,
		scale = 0.5,
		line_length = 1,
		direction_count = 20,
	}

	return frozen_patch
end

----------------------------------------------------------------------------------------------------
-- BELT COLORING API
----------------------------------------------------------------------------------------------------

---@class PrismaticBelts.TransportBeltTechnologyIconInputs
---Color to tint the base sprite (gears, rails)
---@field base_tint? data.Color
---
---Color to tint the mask sprite (belt surface, arrows)
---@field mask_tint? data.Color
---
---Color to tint the arrow layer; when `nil`, the arrow layer will not be included. Suggested alpha
---value is 0. Use to increase the brightness of the arrows when used with a particularly dark
---`mask_tint`.
---@field arrow_tint? data.Color

---Returns a complete technology icons definition
---@param inputs PrismaticBelts.TransportBeltTechnologyIconInputs
---@return data.IconData[]
function api.get_transport_belt_technology_icon(inputs)
	---@type data.IconData[]
	local technology_icons = {
		{
			icon = "__prismatic-belts__/graphics/technology/standard/logistics-technology-base.png",
			icon_size = 256,
			tint = inputs.base_tint and adjust_alpha(inputs.base_tint, 1), -- Ensure non-transparent.
		},
		{
			icon = "__prismatic-belts__/graphics/technology/standard/logistics-technology-mask.png",
			icon_size = 256,
			tint = inputs.mask_tint,
		},
		{
			icon = "__prismatic-belts__/graphics/technology/standard/logistics-technology-highlights.png",
			icon_size = 256,
			tint = { 1, 1, 1, 0 },
		},
	}

	if inputs.arrow_tint then
		table.insert(technology_icons, {
			icon = "__prismatic-belts__/graphics/technology/standard/logistics-technology-arrows.png",
			icon_size = 256,
			tint = inputs.arrow_tint,
		})
	end

	return technology_icons
end

---@class PrismaticBelts.TransportBeltIconInputs
---When true, the icon will have three arrows; otherwise, it will have two.
---@field use_three_arrow_variant? boolean
---
---Color to tint the base sprite (gears, rails)
---@field base_tint? data.Color
---
---Color to tint the mask sprite (belt surface, arrows)
---@field mask_tint? data.Color
---
---Color to tint the arrow layer; when `nil`, the arrow layer will not be included. Suggested alpha
---value is 0. Use to increase the brightness of the arrows when used with a particularly dark
---`mask_tint`.
---@field arrow_tint? data.Color

---Returns a complete item icons definition
---@return data.IconData[]
function api.get_transport_belt_icon(inputs)
	local icon_type = inputs.use_three_arrow_variant and "ub-transport-belt" or "transport-belt"

	---@type data.IconData[]
	local icon_data = {
		{
			icon = "__prismatic-belts__/graphics/icons/standard/" .. icon_type .. "-icon-base.png",
			icon_size = 64,
			tint = inputs.base_tint and adjust_alpha(inputs.base_tint, 1), -- Ensure non-transparent.
		},
		{
			icon = "__prismatic-belts__/graphics/icons/standard/" .. icon_type .. "-icon-mask.png",
			icon_size = 64,
			tint = inputs.mask_tint,
		},
		{
			icon = "__prismatic-belts__/graphics/icons/standard/" .. icon_type .. "-icon-highlights.png",
			icon_size = 64,
			tint = { 1, 1, 1, 0 },
		},
	}

	if inputs.arrow_tint then
		table.insert(icon_data, {
			icon = "__prismatic-belts__/graphics/icons/standard/" .. icon_type .. "-icon-arrows.png",
			icon_size = 64,
			tint = inputs.arrow_tint,
		})
	end

	return icon_data
end

---@class PrismaticBelts.TransportBeltAnimationSetInputs
---Color to tint the base sprite (gears, rails)
---@field base_tint? data.Color
---
---When true, the color blending for the `base_tint` will use Overlay rules.
---@field tint_base_as_overlay? boolean
---
---Color to tint the mask sprite (belt surface, arrows)
---@field mask_tint? data.Color
---
---When true, the color blending for the `mask_tint` will use Overlay rules.
---@field tint_mask_as_overlay? boolean
---
---Color to tint the arrow layer; when `nil`, the arrow layer will not be included. The layer is
---inserted at the top of the stack with `additive-soft` blending; use to increase the brightness of
---the arrows when used with a particularly dark `mask_tint`.
---@field arrow_tint? data.Color
---
---Spritesheet to use for the animation set; defaults to `defines.belt_sprites.standard`.
---@field variant? PrismaticBelts.Api.Defines.BeltSprites

---Returns a complete `TransportBeltAnimationSet` definition.
---@param inputs PrismaticBelts.TransportBeltAnimationSetInputs
---@return data.TransportBeltAnimationSet
function api.get_transport_belt_animation_set(inputs)
	local variant = inputs.variant or api.defines.belt_sprites.standard

	---@class PrismaticBelts.ReturnBeltAnimationSetLayerInputs
	---@field blend_mode? data.BlendMode Blending mode for the layer.
	---@field layer "base"|"mask"|"arrows" "base", "mask" or "arrows" (standard). Determines specific spritesheet used by the layer.
	---@field tint? data.Color Color to tint the layer.
	---@field tint_as_overlay? boolean When true, the color blending will use Overlay rules.

	---Returns a tailored layer of the belt animation set
	---@param layer_inputs PrismaticBelts.ReturnBeltAnimationSetLayerInputs
	---@return data.RotatedAnimation
	local function return_belt_animation_set_layer(layer_inputs)
		-- Point to appropriate sprite directory
		---@type data.RotatedAnimation
		local layer = {
			filename = "__prismatic-belts__/graphics/entity/standard/transport-belt-" .. variant .. "-" .. layer_inputs.layer .. ".png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5,
			frame_count = 16 * (2 ^ (variant - 1)),
			tint = layer_inputs.tint,
			tint_as_overlay = layer_inputs.tint_as_overlay,
			blend_mode = layer_inputs.blend_mode,
			direction_count = 20,
		}

		return layer
	end

	-- Setup belt transport set
	---@type data.TransportBeltAnimationSet
	local transport_belt_animation_set = {
		alternate = variant == 3,
		animation_set = {
			layers = {
				return_belt_animation_set_layer({
					layer = "base",
					tint = inputs.base_tint and adjust_alpha(inputs.base_tint, 1) or nil,
					tint_as_overlay = inputs.tint_base_as_overlay,
				}),
				return_belt_animation_set_layer({
					layer = "mask",
					tint = inputs.mask_tint,
					tint_as_overlay = inputs.tint_mask_as_overlay,
				}),
			},
		},
		frozen_patch = api.get_transport_belt_frozen_patch(variant),
	}

	if inputs.arrow_tint then
		table.insert(
			transport_belt_animation_set.animation_set.layers,
			return_belt_animation_set_layer({
				layer = "arrows",
				tint = inputs.arrow_tint,
				blend_mode = "additive-soft",
			})
		)
	end

	-- Add belt reader sprites.
	meld(transport_belt_animation_set, belt_reader_gfx)

	return transport_belt_animation_set
end

---@class PrismaticBelts.CreateRemnantInputs
---Color to tint the base sprite (gears, rails)
---@field base_tint? data.Color
---
---When true, the color blending for the `base_tint` will use Overlay rules.
---@field tint_base_as_overlay? boolean
---
---Color to tint the mask sprite (belt surface, arrows)
---@field mask_tint? data.Color
---
---When true, the color blending for the `mask_tint` will use Overlay rules.
---@field tint_mask_as_overlay? boolean
---
---Color to tint the arrow layer; when `nil`, the arrow layer will not be included. The layer is
---inserted at the top of the stack with `additive-soft` blending; use to increase the brightness of
---the arrows when used with a particularly dark `mask_tint`.
---@field arrow_tint? data.Color
---
---Spritesheet to use for the remnants; defaults to `defines.belt_sprites.standard`.
---@field variant? PrismaticBelts.Api.Defines.BeltSprites

---Reskins, or creates as needed, appropriate transport belt remnants.
---@param name data.EntityID The prototype name of the transport belt.
---@param inputs PrismaticBelts.CreateRemnantInputs Table of parameters that configure the remnant sprites.
function api.create_remnant(name, inputs)
	---@class PrismaticBelts.ReturnRemnantLayerInputs
	---@field blend_mode? data.BlendMode Blending mode for the layer.
	---@field layer "base"|"mask"|"arrows" "base", "mask" or "arrows" (standard). Determines specific spritesheet used by the layer.
	---@field tint? data.Color Color to tint the layer.
	---@field tint_as_overlay? boolean When true, the color blending will use Overlay rules.

	--- Returns a tailored layer of the belt remnants.
	---@param layer_inputs PrismaticBelts.ReturnRemnantLayerInputs
	---@return data.RotatedAnimation
	local function return_remnant_layer(layer_inputs)
		---@type data.RotatedAnimation
		local layer = {
			filename = "__prismatic-belts__/graphics/entity/standard/remnants/transport-belt-remnants-" .. layer_inputs.layer .. ".png",
			line_length = 1,
			width = 106,
			height = 102,
			frame_count = 1,
			variation_count = 1,
			axially_symmetrical = false,
			direction_count = 4,
			tint = layer_inputs.tint,
			tint_as_overlay = layer_inputs.tint_as_overlay,
			blend_mode = layer_inputs.blend_mode,
			shift = util.by_pixel(1, -0.5),
			scale = 0.5,
		}

		return layer
	end

	-- Setup belt transport set
	---@type data.RotatedAnimation
	local remnant_layers = {
		return_remnant_layer({
			layer = "base",
			tint = inputs.base_tint and adjust_alpha(inputs.base_tint, 1) or nil,
			tint_as_overlay = inputs.tint_base_as_overlay,
		}),
		return_remnant_layer({
			layer = "mask",
			tint = inputs.mask_tint,
			tint_as_overlay = inputs.tint_mask_as_overlay,
		}),
	}

	if inputs.arrow_tint then
		table.insert(
			remnant_layers,
			return_remnant_layer({
				layer = "arrows",
				tint = inputs.arrow_tint,
				blend_mode = "additive-soft",
			})
		)
	end

	-- Fetch remnant
	local remnants = data.raw["corpse"][name .. "-remnants"]

	-- If there is no existing remnant, create one
	if not remnants then
		remnants = {
			type = "corpse",
			name = "prismatic-belts-" .. name .. "-remnants",
			icons = data.raw["transport-belt"][name].icons,
			icon = data.raw["transport-belt"][name].icon,
			icon_size = data.raw["transport-belt"][name].icon_size,
			flags = { "placeable-neutral", "not-on-map" },
			subgroup = "belt-remnants",
			order = (data.raw.item[name] and data.raw.item[name].order) and data.raw.item[name].order .. "-a[" .. name .. "-remnants]" or "a-a-a",
			selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
			tile_width = 1,
			tile_height = 1,
			selectable_in_game = false,
			time_before_removed = 60 * 60 * 15, -- 15 minutes
			final_render_layer = "remnants",
			animation = make_rotated_animation_variations_from_sheet(2, { layers = remnant_layers }),
		}

		data:extend({ remnants })

		-- Assign the corpse
		data.raw["transport-belt"][name].corpse = "prismatic-belts-" .. name .. "-remnants"
	else
		remnants.icons = data.raw["transport-belt"][name].icons
		remnants.icon = data.raw["transport-belt"][name].icon
		remnants.icon_size = data.raw["transport-belt"][name].icon_size
		remnants.animation = make_rotated_animation_variations_from_sheet(2, { layers = remnant_layers })
	end
end

return api
