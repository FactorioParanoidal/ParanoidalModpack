local meld = require("meld")
local sprite_utils = {
	icons = require("__reskins-sprite-utils__.icons"),
	colors = require("__reskins-sprite-utils__.colors"),
}

---The Prismatic Belts library of API functions.
---
---### Examples
---```lua
---local api = require("__prismatic-belts__.prototypes.api")
---```
---@class PrismaticBelts.Api
local api = {
	defines = require("__prismatic-belts__.prototypes.defines"),
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

---Gets the transport belt `frozen_patch` `RotatedSprite` for the given `belt_sprites`.
---
---If Space Age is not active, returns `nil`.
---@param belt_sprites PrismaticBelts.Api.Defines.BeltSprites Spritesheet to use for the frozen patch.
---@return data.RotatedSprite|nil
function api.get_transport_belt_frozen_patch(belt_sprites)
	if not mods["space-age"] then
		return nil
	end

	local frozen_sprite_filenames = {
		[1] = "__prismatic-belts__/graphics/entity/standard/transport-belt-1-frozen.png",
		[2] = "__prismatic-belts__/graphics/entity/standard/transport-belt-2-frozen.png",
		[3] = "__prismatic-belts__/graphics/entity/standard/transport-belt-3-frozen.png",
	}

	---@type data.RotatedSprite
	local frozen_patch = {
		filename = frozen_sprite_filenames[belt_sprites],
		priority = "extra-high",
		size = 128,
		scale = 0.5,
		line_length = 1,
		direction_count = 20,
	}

	return frozen_patch
end

----------------------------------------------------------------------------------------------------
-- BELT PRESETS
----------------------------------------------------------------------------------------------------

---@class PrismaticBelts.BeltSpritePreset
---The transport belt animation set for the preset, including the frozen patch and belt reader
---sprites.
---@field belt_animation_set data.TransportBeltAnimationSetWithCorners
---
---The remnants animation used by the corresponding corpse prototype.
---@field remnants_animation data.RotatedAnimationVariations
---
---The icon for the transport belt.
---@field icon data.IconData
---
---The technology icon for the technology that unlocks the transport belt.
---@field technology_icon data.IconData
---
---The nominal color of the preset for use with functions that use the tintable sprites.
---@field tint data.Color

---Creates the remnants animation using the specified filename.
---@param filename data.FileName
---@return data.RotatedAnimationVariations
local function get_corpse_animation(filename)
	return make_rotated_animation_variations_from_sheet(2, {
		filename = filename,
		line_length = 1,
		width = 106,
		height = 102,
		frame_count = 1,
		variation_count = 1,
		axially_symmetrical = false,
		direction_count = 4,
		shift = util.by_pixel(1, -0.5),
		scale = 0.5,
	})
end

---@type { [PrismaticBelts.Api.Defines.BeltPresets] : PrismaticBelts.BeltSpritePreset}
local presets = {
	[api.defines.belt_presets.standard] = {
		belt_animation_set = {
			animation_set = {
				filename = "__prismatic-belts__/graphics/entity/base/transport-belt/transport-belt.png",
				priority = "extra-high",
				width = 128,
				height = 128,
				scale = 0.5,
				frame_count = 16,
				direction_count = 20,
			},
			frozen_patch = api.get_transport_belt_frozen_patch(api.defines.belt_sprites.standard),
		},
		remnants_animation = get_corpse_animation("__prismatic-belts__/graphics/entity/base/transport-belt/remnants/transport-belt-remnants.png"),
		icon = {
			icon = "__prismatic-belts__/graphics/icons/base/transport-belt.png",
			icon_size = 64,
		},
		technology_icon = {
			icon = "__prismatic-belts__/graphics/technology/base/logistics.png",
			icon_size = 256,
		},
		tint = sprite_utils.colors.from_argb("ffffb726"),
	},
	[api.defines.belt_presets.fast] = {
		belt_animation_set = {
			animation_set = {
				filename = "__prismatic-belts__/graphics/entity/base/fast-transport-belt/fast-transport-belt.png",
				priority = "extra-high",
				width = 128,
				height = 128,
				scale = 0.5,
				frame_count = 32,
				direction_count = 20,
			},
			frozen_patch = api.get_transport_belt_frozen_patch(api.defines.belt_sprites.fast),
		},
		remnants_animation = get_corpse_animation("__prismatic-belts__/graphics/entity/base/fast-transport-belt/remnants/fast-transport-belt-remnants.png"),
		icon = {
			icon = "__prismatic-belts__/graphics/icons/base/fast-transport-belt.png",
			icon_size = 64,
		},
		technology_icon = {
			icon = "__prismatic-belts__/graphics/technology/base/logistics-2.png",
			icon_size = 256,
		},
		tint = sprite_utils.colors.from_argb("fff22318"),
	},
	[api.defines.belt_presets.express] = {
		belt_animation_set = {
			animation_set = {
				filename = "__prismatic-belts__/graphics/entity/base/express-transport-belt/express-transport-belt.png",
				priority = "extra-high",
				width = 128,
				height = 128,
				scale = 0.5,
				frame_count = 32,
				direction_count = 20,
			},
			frozen_patch = api.get_transport_belt_frozen_patch(api.defines.belt_sprites.fast),
		},
		remnants_animation = get_corpse_animation("__prismatic-belts__/graphics/entity/base/express-transport-belt/remnants/express-transport-belt-remnants.png"),
		icon = {
			icon = "__prismatic-belts__/graphics/icons/base/express-transport-belt.png",
			icon_size = 64,
		},
		technology_icon = {
			icon = "__prismatic-belts__/graphics/technology/base/logistics-3.png",
			icon_size = 256,
		},
		tint = sprite_utils.colors.from_argb("ff33b4ff"),
	},
	[api.defines.belt_presets.turbo] = {
		belt_animation_set = {
			alternate = true,
			animation_set = {
				filename = "__prismatic-belts__/graphics/entity/space-age/turbo-transport-belt/turbo-transport-belt.png",
				priority = "extra-high",
				width = 128,
				height = 128,
				scale = 0.5,
				frame_count = 64,
				direction_count = 20,
			},
			frozen_patch = api.get_transport_belt_frozen_patch(api.defines.belt_sprites.turbo),
		},
		remnants_animation = get_corpse_animation("__prismatic-belts__/graphics/entity/space-age/turbo-transport-belt/remnants/turbo-transport-belt-remnants.png"),
		icon = {
			icon = "__prismatic-belts__/graphics/icons/space-age/turbo-transport-belt.png",
			icon_size = 64,
		},
		technology_icon = {
			icon = "__prismatic-belts__/graphics/technology/space-age/turbo-transport-belt.png",
			icon_size = 256,
		},
		tint = sprite_utils.colors.from_argb("ff94cc33"),
	},
}

meld(presets[api.defines.belt_presets.standard].belt_animation_set, belt_reader_gfx)
meld(presets[api.defines.belt_presets.fast].belt_animation_set, belt_reader_gfx)
meld(presets[api.defines.belt_presets.express].belt_animation_set, belt_reader_gfx)
meld(presets[api.defines.belt_presets.turbo].belt_animation_set, belt_reader_gfx)

---Gets a copy of the sprite presets for the specified `belt_preset`.
---@param belt_preset PrismaticBelts.Api.Defines.BeltPresets
---@return PrismaticBelts.BeltSpritePreset
function api.get_preset(belt_preset)
	return util.copy(presets[belt_preset])
end

----------------------------------------------------------------------------------------------------
-- BELT COLORING API
----------------------------------------------------------------------------------------------------

---@class PrismaticBelts.LogisticsTechnologyIconInputs
---Color to tint the base sprite (gears, rails)
---@field base_tint data.Color?
---
---Color to tint the mask sprite (belt surface, arrows)
---@field mask_tint data.Color?
---
---When provided, the color to tint the arrows on the belt. When `nil`, the layer will not be
---included. Suggested alpha value is 0; use to increase the brightness of the arrows when used with
---a particularly dark `mask_tint`.
---@field arrow_tint data.Color?
---
---When provided, the color to tint the splitter and underground colored structure.
---@field structure_tint data.Color?

---Returns a complete technology icons definition
---@param inputs PrismaticBelts.LogisticsTechnologyIconInputs
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
			tint = inputs.structure_tint or inputs.mask_tint,
		},
		{
			icon = "__prismatic-belts__/graphics/technology/standard/logistics-technology-mask-belts.png",
			icon_size = 256,
			tint = inputs.mask_tint,
		},
	}

	if inputs.arrow_tint then
		table.insert(technology_icons, {
			icon = "__prismatic-belts__/graphics/technology/standard/logistics-technology-mask-arrows.png",
			icon_size = 256,
			tint = inputs.arrow_tint,
		})
	end

	table.insert(technology_icons, {
		icon = "__prismatic-belts__/graphics/technology/standard/logistics-technology-highlights.png",
		icon_size = 256,
		tint = { 1, 1, 1, 0 },
	})

	return technology_icons
end

---@param inputs PrismaticBelts.TransportBeltIconInputs
---@return data.IconData
local function get_aai_loader_technology_icon_belt_layers(inputs)
	local icon_type = inputs.use_three_arrow_variant and "ub-loader" or "loader"

	---@type data.IconData[]
	local icon_data = {
		{
			icon = "__prismatic-belts__/graphics/technology/aai-loaders/" .. icon_type .. "-technology-icon-base.png",
			icon_size = 256,
			tint = inputs.base_tint and adjust_alpha(inputs.base_tint, 1), -- Ensure non-transparent.
		},
		{
			icon = "__prismatic-belts__/graphics/technology/aai-loaders/" .. icon_type .. "-technology-icon-mask.png",
			icon_size = 256,
			tint = inputs.mask_tint,
		},
		{
			icon = "__prismatic-belts__/graphics/technology/aai-loaders/" .. icon_type .. "-technology-icon-highlights.png",
			icon_size = 256,
			tint = { 1, 1, 1, 0 },
		},
	}

	return icon_data
end

---@class PrismaticBelts.TransportBeltIconInputs
---When true, the icon will have three arrows; otherwise, it will have two.
---@field use_three_arrow_variant? boolean
---
---Color to tint the base sprite (gears, rails)
---@field base_tint data.Color?
---
---Color to tint the mask sprite (belt surface, arrows)
---@field mask_tint data.Color?
---
---Color to tint the arrow layer; when `nil`, the arrow layer will not be included. Suggested alpha
---value is 0. Use to increase the brightness of the arrows when used with a particularly dark
---`mask_tint`.
---@field arrow_tint data.Color?

---Returns a complete item icons definition
---@param inputs PrismaticBelts.TransportBeltIconInputs
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

---@param inputs PrismaticBelts.TransportBeltIconInputs
---@return data.IconData
local function get_aai_loader_icon_belt_layers(inputs)
	local icon_type = inputs.use_three_arrow_variant and "ub-transport-belt" or "transport-belt"

	---@type data.IconData[]
	local icon_data = {
		{
			icon = "__prismatic-belts__/graphics/icons/aai-loaders/" .. icon_type .. "-icon-base.png",
			icon_size = 64,
			tint = inputs.base_tint and adjust_alpha(inputs.base_tint, 1), -- Ensure non-transparent.
		},
		{
			icon = "__prismatic-belts__/graphics/icons/aai-loaders/" .. icon_type .. "-icon-mask.png",
			icon_size = 64,
			tint = inputs.mask_tint,
		},
		{
			icon = "__prismatic-belts__/graphics/icons/aai-loaders/" .. icon_type .. "-icon-highlights.png",
			icon_size = 64,
			tint = { 1, 1, 1, 0 },
		},
	}

	if inputs.arrow_tint then
		table.insert(icon_data, {
			icon = "__prismatic-belts__/graphics/icons/aai-loaders/" .. icon_type .. "-icon-arrows.png",
			icon_size = 64,
			tint = inputs.arrow_tint,
		})
	end

	return icon_data
end

---@class PrismaticBelts.SpriteTintInputs
---Color to tint the base sprite (gears, rails)
---@field base_tint data.Color?
---
---When true, the color blending for the `base_tint` will use Overlay rules.
---@field tint_base_as_overlay boolean?
---
---Color to tint the mask sprite (belt surface, arrows)
---@field mask_tint data.Color?
---
---When true, the color blending for the `mask_tint` will use Overlay rules.
---@field tint_mask_as_overlay boolean?
---
---When true, the mask layer will be omitted. Use when the base belt layer is sufficient and the
---arrow layer is desired.
---@field omit_mask_layer boolean?
---
---Color to tint the arrow layer; when `nil`, the arrow layer will not be included. The layer is
---inserted at the top of the stack with `additive-soft` blending; use to increase the brightness of
---the arrows when used with a particularly dark `mask_tint`.
---@field arrow_tint data.Color?
---@field arrow_blend_mode data.BlendMode?
---@field tint_arrow_as_overlay boolean?

---@class PrismaticBelts.TransportBeltAnimationSetInputs: PrismaticBelts.SpriteTintInputs
---Spritesheet to use for the animation set; if omitted, defaults to a suitable spritesheet.
---@field belt_sprites PrismaticBelts.Api.Defines.BeltSprites?

---Returns a complete `TransportBeltAnimationSet` definition.
---@param inputs PrismaticBelts.TransportBeltAnimationSetInputs
---@return data.TransportBeltAnimationSetWithCorners
function api.get_transport_belt_animation_set(inputs)
	local belt_sprites = inputs.belt_sprites or api.defines.belt_sprites.standard

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
			filename = "__prismatic-belts__/graphics/entity/standard/transport-belt-" .. belt_sprites .. "-" .. layer_inputs.layer .. ".png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5,
			frame_count = 16 * (2 ^ (belt_sprites - 1)),
			tint = layer_inputs.tint,
			tint_as_overlay = layer_inputs.tint_as_overlay,
			blend_mode = layer_inputs.blend_mode,
			direction_count = 20,
		}

		return layer
	end

	-- Setup belt transport set
	---@type data.TransportBeltAnimationSetWithCorners
	local transport_belt_animation_set = {
		alternate = belt_sprites == 3,
		animation_set = {
			layers = {
				return_belt_animation_set_layer({
					layer = "base",
					tint = inputs.base_tint and adjust_alpha(inputs.base_tint, 1) or nil,
					tint_as_overlay = inputs.base_tint ~= nil and (inputs.tint_base_as_overlay ~= false),
				}),
			},
		},
		frozen_patch = api.get_transport_belt_frozen_patch(belt_sprites),
	}

	if not inputs.omit_mask_layer then
		table.insert(
			transport_belt_animation_set.animation_set.layers,
			return_belt_animation_set_layer({
				layer = "mask",
				tint = inputs.mask_tint,
				tint_as_overlay = inputs.tint_mask_as_overlay ~= false,
			})
		)
	end

	if inputs.arrow_tint then
		table.insert(
			transport_belt_animation_set.animation_set.layers,
			return_belt_animation_set_layer({
				layer = "arrows",
				tint = inputs.arrow_tint,
				tint_as_overlay = inputs.tint_arrow_as_overlay,
				blend_mode = inputs.arrow_blend_mode or "additive-soft",
			})
		)
	end

	-- Add belt reader sprites.
	meld(transport_belt_animation_set, belt_reader_gfx)

	return transport_belt_animation_set
end

local function create_or_update_remnants_core(transport_belt_name, animation)
	-- Fetch remnant
	local remnants = data.raw["corpse"][transport_belt_name .. "-remnants"]

	-- If there is no existing remnant, create one
	if not remnants then
		remnants = {
			type = "corpse",
			name = "prismatic-belts-" .. transport_belt_name .. "-remnants",
			localised_name = {
				"",
				(data.raw["transport-belt"][transport_belt_name].localised_name or { "entity-name." .. transport_belt_name }),
				" (remnant)",
			},
			icons = data.raw["transport-belt"][transport_belt_name].icons,
			icon = data.raw["transport-belt"][transport_belt_name].icon,
			icon_size = data.raw["transport-belt"][transport_belt_name].icon_size,
			flags = { "placeable-neutral", "not-on-map" },
			subgroup = "belt-remnants",
			order = (data.raw.item[transport_belt_name] and data.raw.item[transport_belt_name].order) and data.raw.item[transport_belt_name].order .. "-a[" .. transport_belt_name .. "-remnants]" or "a-a-a",
			selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
			tile_width = 1,
			tile_height = 1,
			selectable_in_game = false,
			time_before_removed = 60 * 60 * 15, -- 15 minutes
			final_render_layer = "remnants",
			animation = animation,
		}

		data:extend({ remnants })

		-- Assign the corpse
		data.raw["transport-belt"][transport_belt_name].corpse = "prismatic-belts-" .. transport_belt_name .. "-remnants"
	else
		remnants.icons = data.raw["transport-belt"][transport_belt_name].icons
		remnants.icon = data.raw["transport-belt"][transport_belt_name].icon
		remnants.icon_size = data.raw["transport-belt"][transport_belt_name].icon_size
		remnants.animation = animation
	end
end

---Creates or updates remnant sprites for a transport belt prototype.
---
---If no remnant exists, it creates a new corpse prototype; otherwise, it updates the existing one
---with the prismatic sprite layers.
---@param name data.EntityID The prototype name of the transport belt.
---@param inputs PrismaticBelts.SpriteTintInputs Table of parameters that configure the remnant sprites.
---@deprecated Method renamed, use `api.create_or_update_remnants(name, inputs)` instead
function api.create_remnant(name, inputs)
	api.create_or_update_remnants(name, inputs)
end

---Creates or updates remnant sprites for a transport belt prototype.
---
---If no remnant exists, it creates a new corpse prototype; otherwise, it updates the existing one
---with the prismatic sprite layers.
---@param transport_belt_name data.EntityID The prototype name of the transport belt.
---@param inputs PrismaticBelts.SpriteTintInputs Table of parameters that configure the remnant sprites.
function api.create_or_update_remnants(transport_belt_name, inputs)
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
			tint_as_overlay = inputs.base_tint ~= nil and (inputs.tint_base_as_overlay ~= false),
		}),
		return_remnant_layer({
			layer = "mask",
			tint = inputs.mask_tint,
			tint_as_overlay = inputs.tint_mask_as_overlay ~= false,
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

	local animation = make_rotated_animation_variations_from_sheet(2, { layers = remnant_layers })
	create_or_update_remnants_core(transport_belt_name, animation)
end

-- Computes an integer hash code using a djb2-style algorithm for the provided string.
---@param s string
---@return integer
local function hash_string(s)
	local h = 5381
	for i = 1, #s do
		h = (h * 33 + string.byte(s, i)) % 2147483647
	end
	return h
end

---Converts the provided tint to a string.
---@param t data.Color
---@return string
local function format_tint(t)
	if not t then
		return ""
	end
	return string.format("_t%.3f_%.3f_%.3f_%.3f", t.r or t[1] or 0, t.g or t[2] or 0, t.b or t[3] or 0, t.a or t[4] or 0)
end

---Computes a hash code that uniquely identifies an animation set in use by the provided `entity` by
---filename(s), tint(s), and speed.
---
---Tint and speed are required to differentiate belt animation sets that are reused either as
---colored sprite sets or for multiple belt speeds.
---@param entity data.TransportBeltConnectablePrototype
---@return integer? # The hash code, if an animation set exists; otherwise, `nil`.
local function get_animation_set_identity(entity)
	if not entity.belt_animation_set or not entity.belt_animation_set.animation_set then
		return
	end

	local animation_set = entity.belt_animation_set.animation_set
	local speed = tostring(entity.speed)

	if animation_set.filename then
		return hash_string(animation_set.filename .. format_tint(animation_set.tint) .. speed)
	elseif animation_set.layers then
		local parts = {}
		for i, layer in ipairs(animation_set.layers) do
			if layer.filename then
				parts[i] = layer.filename .. format_tint(layer.tint) .. speed
			end
		end
		return hash_string(table.concat(parts, "|"))
	end
end

local supported_types = {
	"splitter",
	"lane-splitter",
	"underground-belt",
	"loader-1x1",
	"loader",
}

---Applies the given `animation_set` to the provided `transport_belt` entity, and updates the belt
---animation set across all transport belt connectable prototypes that use the transport belt.
---
---Note: it is important that the `belt_animation_set` property of the transport belt have not
---already been updated, as the belt animation set to be replaced is used to identify all related
---transport belt connectable prototypes.
---
---@param transport_belt data.TransportBeltPrototype
---@param animation_set data.TransportBeltAnimationSetWithCorners
---@param icon_inputs PrismaticBelts.TransportBeltIconInputs?
function api.apply_belt_animation_set_and_update_related_connectables(transport_belt, animation_set, icon_inputs)
	-- The hashed identifier of the belt animation set to be replaced
	local set_id_to_replace = get_animation_set_identity(transport_belt)
	if not set_id_to_replace then
		error("Unable to resolve transport belt animation set identity for belt '" .. transport_belt.name .. "'.")
	end

	-- Replace the animation set after we have the identity.
	transport_belt.belt_animation_set = animation_set

	-- Find all entities sharing the old animation set and update the animation set.
	for _, type_name in pairs(supported_types) do
		for _, entity in pairs(data.raw[type_name]) do
			---@cast entity data.TransportBeltConnectablePrototype
			local entity_set_id = get_animation_set_identity(entity)
			if entity_set_id ~= set_id_to_replace then
				goto continue
			end

			entity.belt_animation_set = animation_set

			if not icon_inputs then
				goto continue
			end

			-- stylua: ignore start
			if entity.name == "aai-loader"
				or entity.name:find("^aai%-.+%-loader$")
				or entity.name:find("^aai%-.+%-lane%-filtering$")
				or entity.name:find("^aai%-.+%-stacking$") then
				local patch_layers = get_aai_loader_icon_belt_layers(icon_inputs)
				local entity_icon = sprite_utils.icons.get_icon_from_prototype(entity)

				sprite_utils.icons.assign_deferrable_icon({
					name = entity.name,
					type_name = entity.type,
					icon_data = sprite_utils.icons.compose_icons("default", entity_icon[1], patch_layers, table.unpack(entity_icon, 2)),
				})

				-- TODO: rework this process to single scan for icons in certain target entities
				-- that have icons that contain the two-layer AAI Loader sprites and insert the patch.
				-- Basically: confirm the icon we're updating is a valid target rather than assuming
				-- that it is as we currently do.

				local recipe = data.raw["recipe"][entity.name]
				if recipe and not recipe.main_product then
					recipe.icons = entity.icons
				end

				local function try_patch_tech_icon(technology_name)
					local technology = data.raw["technology"][technology_name]
					if not technology then
						return
					end

					local tech_patch_layers = get_aai_loader_technology_icon_belt_layers(icon_inputs)
					local tech_icon = sprite_utils.icons.get_icon_from_prototype(technology)

					if icon_inputs.use_three_arrow_variant then
						table.insert(
							tech_patch_layers,
							util.merge({ tech_icon[2], {
								icon = "__prismatic-belts__/graphics/technology/aai-loaders/ub-loader-technology-icon-arrow.png",
								icon_size = 256,
							} })
						)
					end

					sprite_utils.icons.assign_deferrable_icon({
						name = technology.name,
						type_name = technology.type,
						icon_data = sprite_utils.icons.compose_icons("technology", tech_icon[1], tech_patch_layers, table.unpack(tech_icon, 2)),
					})
				end

				try_patch_tech_icon(entity.name)
				try_patch_tech_icon(entity.name .. "-stacking")
			end
			-- stylua: ignore end

			::continue::
		end
	end
end

---Implementation for `transform_belt_and_related_connectables` using a preset sprite set.
---@param entity data.TransportBeltPrototype
---@param inputs PrismaticBelts.PresetTransformBeltInputs
local function transform_belt_and_related_connectables_preset(entity, inputs)
	local preset = api.get_preset(inputs.preset)

	sprite_utils.icons.assign_deferrable_icon({
		name = entity.name,
		type_name = entity.type,
		icon_datum = preset.icon,
	})

	if inputs.logistics_technology_name then
		sprite_utils.icons.assign_deferrable_icon({
			name = inputs.logistics_technology_name,
			type_name = "technology",
			icon_datum = preset.technology_icon,
		})
	end

	api.apply_belt_animation_set_and_update_related_connectables(entity, preset.belt_animation_set, {
		mask_tint = preset.tint,
	})
	create_or_update_remnants_core(entity.name, preset.remnants_animation)

	for _, forced_entity in pairs(inputs.forced_connectable_belt_entities or {}) do
		local target_entity = data.raw[forced_entity.type_name][forced_entity.name]
		if target_entity then
			target_entity.belt_animation_set = entity.belt_animation_set
		end
	end
end

---Implementation for `transform_belt_and_related_connectables` using the layered, tintable sprite set.
---@param entity data.TransportBeltPrototype
---@param inputs PrismaticBelts.TransformBeltInputs?
local function transform_belt_and_related_connectables_layered(entity, inputs)
	---@type PrismaticBelts.TransportBeltAnimationSetInputs
	local animation_set_inputs = inputs and inputs.belt_animation_set or {}

	---@type PrismaticBelts.TransportBeltIconInputs
	local belt_icon_inputs = inputs and inputs.belt_icon or {}

	---@type PrismaticBelts.LogisticsTechnologyInputs
	local logistics_technology_inputs = inputs and inputs.logistics_technology or {}

	---@type PrismaticBelts.TransportBeltConnectableEntity[]
	local forced_entities = inputs and inputs.forced_connectable_belt_entities or {}

	sprite_utils.icons.assign_deferrable_icon({
		name = entity.name,
		type_name = entity.type,
		icon_data = api.get_transport_belt_icon({
			use_three_arrow_variant = belt_icon_inputs.use_three_arrow_variant,
			base_tint = belt_icon_inputs.base_tint or animation_set_inputs.base_tint,
			mask_tint = belt_icon_inputs.mask_tint or animation_set_inputs.mask_tint,
			arrow_tint = belt_icon_inputs.arrow_tint or animation_set_inputs.arrow_tint,
		}),
	})

	if logistics_technology_inputs.name then
		sprite_utils.icons.assign_deferrable_icon({
			name = logistics_technology_inputs.name,
			type_name = "technology",
			icon_data = api.get_transport_belt_technology_icon({
				base_tint = logistics_technology_inputs.base_tint or animation_set_inputs.base_tint,
				mask_tint = logistics_technology_inputs.mask_tint or animation_set_inputs.mask_tint,
				structure_tint = logistics_technology_inputs.structure_tint or logistics_technology_inputs.mask_tint or animation_set_inputs.mask_tint,
				arrow_tint = logistics_technology_inputs.arrow_tint or animation_set_inputs.arrow_tint,
			}),
		})
	end

	if not animation_set_inputs.belt_sprites then
		-- Determine the appropriate set of sprites to use based on the configured belt speed.
		if entity.speed < (30 / 480) then
			animation_set_inputs.belt_sprites = api.defines.belt_sprites.standard
		elseif entity.speed < (60 / 480) then
			animation_set_inputs.belt_sprites = api.defines.belt_sprites.fast
		else
			animation_set_inputs.belt_sprites = api.defines.belt_sprites.turbo
		end
	end

	local animation_set = api.get_transport_belt_animation_set(animation_set_inputs)
	api.apply_belt_animation_set_and_update_related_connectables(entity, animation_set, {
		use_three_arrow_variant = belt_icon_inputs.use_three_arrow_variant,
		base_tint = belt_icon_inputs.base_tint or animation_set_inputs.base_tint,
		mask_tint = belt_icon_inputs.mask_tint or animation_set_inputs.mask_tint,
		arrow_tint = belt_icon_inputs.arrow_tint or animation_set_inputs.arrow_tint,
	})
	api.create_or_update_remnants(entity.name, animation_set_inputs)

	for _, forced_entity in pairs(forced_entities) do
		local target_entity = data.raw[forced_entity.type_name][forced_entity.name]
		if target_entity then
			target_entity.belt_animation_set = entity.belt_animation_set
		end
	end
end

---@class PrismaticBelts.TransportBeltConnectableEntity
---The name of the transport belt connectable entity for which the belt_animation_set property
---should be set.
---@field name data.EntityID
---The type of the transport belt connectable entity.
---@field type_name "splitter"|"lane-splitter"|"underground-belt"|"loader-1x1"|"loader"

---@class PrismaticBelts.LogisticsTechnologyInputs:PrismaticBelts.LogisticsTechnologyIconInputs
---The technology prototype name of a technology that unlocks the associated transport belt, and
---which should use a Logistics-style technology icon that has been colored like the transport belts.
---@field name data.TechnologyID

---@class PrismaticBelts.PresetTransformBeltInputs
---@field preset PrismaticBelts.Api.Defines.BeltPresets
---The technology prototype name of a technology that unlocks the associated transport belt, and
---which should use a Logistics-style technology icon that has been colored like the transport belts.
---
---Omit if there is no corresponding technology.
---@field logistics_technology_name data.TechnologyID?
---
---A list of entities to forcibly set to the `belt_animation_set` of the reference belt. Use when
---the automatic resolution of reference belts does not resolve correctly.
---@field forced_connectable_belt_entities PrismaticBelts.TransportBeltConnectableEntity[]?

---@class PrismaticBelts.TransformBeltInputs
---The options that configured how the transport belt will be colored, and which spritesheet to use.
---@field belt_animation_set PrismaticBelts.TransportBeltAnimationSetInputs
---
---The options that configure how the transport belt icon will be handled. Omit to use the same
---options as in the `animation_set` field.
---@field belt_icon PrismaticBelts.TransportBeltIconInputs?
---
---The options that configure how a technology unlocking the belt, having a Logistics-style
---technology icon, will be transformed; omit if no technology, or the unlocking technology does not
---use a Logistics-style technology icon.
---@field logistics_technology PrismaticBelts.LogisticsTechnologyInputs?
---
---A list of entities to forcibly set to the `belt_animation_set` of the reference belt. Use when
---the automatic resolution of reference belts does not resolve correctly.
---@field forced_connectable_belt_entities PrismaticBelts.TransportBeltConnectableEntity[]?

---For the transport belt with the specified `name`, updates the sprites to use the tinted prismatic
---belt sprites and automatically updates entities that use the transport belt.
---@param name data.EntityID
---@param inputs (PrismaticBelts.TransformBeltInputs|PrismaticBelts.PresetTransformBeltInputs)?
function api.transform_belt_and_related_connectables(name, inputs)
	local entity = data.raw["transport-belt"][name]
	if not entity then
		return
	end

	if inputs and inputs.preset then
		transform_belt_and_related_connectables_preset(entity, inputs)
	else
		transform_belt_and_related_connectables_layered(entity, inputs)
	end
end

---@alias PrismaticBelts.TransportBeltInputsMapping { [data.EntityID]: PrismaticBelts.TransformBeltInputs|PrismaticBelts.PresetTransformBeltInputs }

---For the set of transport belt inputs, updates the sprites to use the tinted prismatic belt
---sprites and automatically updates entities that use each transport belt.
---@param transport_belt_inputs_map PrismaticBelts.TransportBeltInputsMapping
function api.transform_belts_and_related_connectables(transport_belt_inputs_map)
	for name, inputs in pairs(transport_belt_inputs_map) do
		api.transform_belt_and_related_connectables(name, inputs)
	end
end

return api
