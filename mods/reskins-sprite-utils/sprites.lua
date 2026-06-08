--- Provides methods for manipulating sprites.
---
---### Examples
---```lua
---local _sprites = require("__reskins-sprite-utils__.sprites")
---```
---@class Reskins.SpriteUtils.Sprites
local _sprites = {}

local _icons = require("__reskins-sprite-utils__.icons")

---@param icon_layer data.IconData # An icon layer.
---@param scale? double # The scale to apply to the sprite.
---@return data.Sprite # A layer of sprite data.
local function convert_icon_layer_to_sprite_layer(icon_layer, scale)
	local icon_copy = _icons.add_missing_icon_defaults(icon_layer)
	local scale_to_apply = scale and scale * icon_copy.scale or icon_copy.scale or 32 / icon_copy.icon_size

	-- Icon shift is in pixels, so we need to scale it down to 32 pixels per tile.
	local converted_shift = icon_copy.shift and util.mul_shift(icon_copy.shift, scale_to_apply * 1 / 32) or nil

	---@type data.Sprite
	local sprite_layer = {
		flags = { "icon" },
		filename = icon_copy.icon,
		size = icon_copy.icon_size,
		scale = scale_to_apply,
		shift = converted_shift,
		tint = icon_copy.tint,
	}

	return sprite_layer
end

---
---Creates a `Sprite` object from the given `icon_data` array, at the given `scale`.
---
---`icon_data` is assumed to be an entity, item, or recipe icon. Technology icons are not supported.
---
---Missing icon fields are set to default values as appropriate.
---`icon_data` is not modified.
---
---### Examples
---```lua
------@type data.IconData[]
---local icon_data = {
---    {
---        icon = "__base__/graphics/icons/iron-plate.png",
---        icon_size = 64,
---        scale = 0.5,
---    },
---    {
---        icon = "__base__/graphics/icons/copper-wire.png",
---        icon_size = 64,
---        scale = 0.25,
---        shift = { -16, -16 }
---    },
---}
---
---local sprite = _sprites.create_sprite_from_icons(icon_data, 1.0)
---```
---
---### Parameters
---@param icon_data data.IconData[] # An array of `IconData` objects.
---@param scale? double # The scale to apply to the sprite.
---### Returns
---@return data.Sprite # A `Sprite` object created from `icon_data`.
---
---### Exceptions
---*@throws* `string` — Thrown when `icon_data` is `nil`.<br/>
---*@throws* `string` — Thrown when `icon_data[n].icon` is not an absolute file path with a valid extension.<br/>
---*@throws* `string` — Thrown when `icon_data[n].icon_size` is not a positive integer.<br/>
---@nodiscard
function _sprites.create_sprite_from_icons(icon_data, scale)
	assert(icon_data, "Invalid parameter: 'icon_data' must not be nil.")

	---@type data.Sprite
	local sprite = {}
	if #icon_data == 1 then
		sprite = convert_icon_layer_to_sprite_layer(icon_data[1], scale)
	else
		sprite = { layers = {} }
		for n = 1, #icon_data do
			sprite.layers[n] = convert_icon_layer_to_sprite_layer(icon_data[n], scale)
		end
	end

	return sprite
end

---
---Creates a sprite from the given `icon_datum`, at the given `scale`.
---
---`icon_datum` is assumed to be an entity, item, or recipe icon. Technology icons are not supported.
---
---Missing icon fields are set to default values as appropriate.
---`icon_datum` is not modified.
---
---### Examples
---```lua
------@type data.IconData
---local icon_datum = {
---    icon = "__base__/graphics/icons/iron-plate.png",
---    icon_size = 64,
---    scale = 0.5,
---}
---
---local sprite = _sprites.create_sprite_from_icon(icon_datum, 1.0)
---```
---
---### Parameters
---@param icon_datum data.IconData  # An `IconData` object.
---@param scale? double # The scale to apply to the sprite.
---### Returns
---@return data.Sprite # A `Sprite` object created from `icon_datum`.
---
---### Exceptions
---*@throws* `string` — Thrown when `icon_datum` is `nil`.<br/>
---*@throws* `string` — Thrown when `icon_datum` is not an IconData object.<br/>
---*@throws* `string` — Thrown when `icon_datum.icon` is not an absolute file path with a valid extension.<br/>
---*@throws* `string` — Thrown when `icon_datum.icon_size` is not a positive integer.<br/>
---@nodiscard
function _sprites.create_sprite_from_icon(icon_datum, scale)
	assert(icon_datum, "Invalid parameter: 'icon_datum' must not be nil.")

	return convert_icon_layer_to_sprite_layer(icon_datum, scale)
end

---
---Creates an `Animation4Way` object using the given `animation`, parsing the `line_length`
---and `frame_count` fields to slice a sprite sheet into direction-based `Animation` objects.
---
---### Returns
---@return data.Animation4Way|data.Sprite4Way # The 4-way animation object created from `animation`.
---
---### Remarks
---Extends the functionality of `make_rotated_animation_variations_from_sheet` to include handling
---of vertically oriented sprite sheets (set `vertically_oriented` to `true`), and of the additional
---parameters `run_mode` and `frame_sequence`.
---
---`animation` is not modified.
---
---### Examples
---To use the `vertically_oriented` parameter, include it in the `animation` object:
---```lua
---{
---    filename = "__mod-name__/graphics/entity/prototype/prototype.png",
---    priority = "extra-high",
---    vertically_oriented = true,
---    width = 660,
---    height = 460,
---    shift = util.by_pixel_hr(100, 20),
---    scale = 0.5,
---},
---```
---For a real-world example, see the Advanced Gas Refinery sprite sheets in Artisanal Reskins:
---Angel's Mods.
---
---### Parameters
---@param animation VerticallyOrientableAnimation|data.Animation # The animation object to create the 4-way animation from.
---@nodiscard
function _sprites.make_4way_animation_from_spritesheet(animation)
	local animation_copy = util.copy(animation)

	---@class DirectionDefines : integer
	local defines = {
		north = 0,
		east = 1,
		south = 2,
		west = 3,
	}

	---
	---Creates the `data.Animation` object for the given `direction` using the given
	---`source_animation`.
	---
	---### Returns
	---@return data.Animation # The new animation for the given `direction`.
	---
	---### Parameters
	---@param direction DirectionDefines # The direction to create the animation for.
	---@param source_animation VerticallyOrientableAnimation # The source animation object with a sprite sheet supporting direction-based configurations.
	local function make_animation_layer_for_direction(direction, source_animation)
		local start_frame = (source_animation.frame_count or 1) * direction
		local x, y = 0, 0

		-- Extend vanilla function with handling for vertically_oriented sprite sheets.
		if source_animation.vertically_oriented then
			if source_animation.line_length then
				y = direction * source_animation.height * math.floor(start_frame / (source_animation.line_length or 1))
			else
				y = direction * source_animation.height
			end
		else
			if source_animation.line_length then
				y = source_animation.height * math.floor(start_frame / (source_animation.line_length or 1))
			else
				x = direction * source_animation.width
			end
		end

		---@type data.Animation
		local animation_for_direction = {
			filename = source_animation.filename,
			priority = source_animation.priority or "high",
			flags = source_animation.flags,
			x = x,
			y = y,
			width = source_animation.width,
			height = source_animation.height,
			frame_count = source_animation.frame_count,
			line_length = source_animation.line_length,
			repeat_count = source_animation.repeat_count,
			shift = source_animation.shift,
			draw_as_shadow = source_animation.draw_as_shadow,
			draw_as_glow = source_animation.draw_as_glow,
			draw_as_light = source_animation.draw_as_light,
			apply_runtime_tint = source_animation.apply_runtime_tint,
			animation_speed = source_animation.animation_speed,
			scale = source_animation.scale or 1,
			tint = source_animation.tint,
			blend_mode = source_animation.blend_mode,
			load_in_minimal_mode = source_animation.load_in_minimal_mode,
			premul_alpha = source_animation.premul_alpha,
			generate_sdf = source_animation.generate_sdf,

			-- Extend vanilla function with additional parameters.
			run_mode = source_animation.run_mode,
			frame_sequence = source_animation.frame_sequence,
		}

		return animation_for_direction
	end

	---
	---Creates the `data.Animation` object for the given `direction` using the given
	---`source_animation`.
	---
	---### Returns
	---@return data.Animation # The new animation for the given `direction`.
	---
	---### Parameters
	---@param direction DirectionDefines # The direction to create the animation for.
	local function make_animation_for_direction(direction)
		if animation_copy.layers then
			---@type data.Animation
			local new_animation = { layers = {} }
			for _, v in ipairs(animation_copy.layers) do
				table.insert(new_animation.layers, make_animation_layer_for_direction(direction, v))
			end
			return new_animation
		else
			return make_animation_layer_for_direction(direction, animation_copy)
		end
	end

	---@type data.Animation4Way
	local animation_4way = {
		north = make_animation_for_direction(defines.north),
		east = make_animation_for_direction(defines.east),
		south = make_animation_for_direction(defines.south),
		west = make_animation_for_direction(defines.west),
	}

	return animation_4way
end

---
---Creates a `RotatedAnimationVariations` object from the given `sheet`, slicing the sprite sheet
---into `variation_count` individual `RotatedAnimation` objects by computing the Y offset for each.
---
---Each variation is assumed to occupy the same vertical span on the sheet, derived from
---`frame_count`, `line_length`, and `direction_count` on the source animation layer.
---
---### Returns
---@return data.RotatedAnimationVariations # An array of `RotatedAnimation` objects, one per variation.
---
---### Examples
---```lua
---local variations = _sprites.make_rotated_animation_variations_from_spritesheet(4, {
---    filename = "__mod-name__/graphics/entity/prototype/prototype.png",
---    priority = "high",
---    width = 128,
---    height = 128,
---    direction_count = 36,
---    frame_count = 1,
---})
---```
---
---### Parameters
---@param variation_count integer # The number of variations to slice from `sheet`.
---@param sheet data.RotatedAnimation # The source animation referencing a sprite sheet with all variations stacked vertically.
function _sprites.make_rotated_animation_variations_from_spritesheet(variation_count, sheet)
	---@type data.RotatedAnimationVariations
	local result = {}

	---@param variation data.RotatedAnimation
	---@param i integer
	local function set_y_offset(variation, i)
		local frame_count = variation.frame_count or 1
		local line_length = variation.line_length or frame_count
		if line_length < 1 then
			line_length = frame_count
		end

		local height_in_frames = math.floor((frame_count * variation.direction_count + line_length - 1) / line_length)
		variation.y = variation.height * (i - 1) * height_in_frames
	end

	for i = 1, variation_count do
		local variation = util.copy(sheet) --[[@as data.RotatedAnimation]]

		if variation.layers then
			for _, layer in pairs(variation.layers) do
				set_y_offset(layer, i)
			end
		else
			set_y_offset(variation, i)
		end

		table.insert(result, variation)
	end
	return result
end

-- Filtering tables for rescale_entity
local included_fields = {
	["shift"] = true,
	["scale"] = true,
	["collision_box"] = true,
	["selection_box"] = true,
	["north_position"] = true,
	["south_position"] = true,
	["east_position"] = true,
	["west_position"] = true,
	["position"] = true,
	["window_bounding_box"] = true,
	["circuit_wire_connection_points"] = true,
}

local excluded_fields = {
	["fluid_boxes"] = true,
	["fluid_box"] = true,
	["energy_source"] = true,
	["input_fluid_box"] = true,
}

---Resizes the given `prototype` by the given `scalar`.
---
---Recursively iterates through the given `prototype` and applies the given `scalar` to all the numeric values
---in the fields listed in `included_fields`.
---
---### Remarks
---`scalar` is recommended to be the ratio of the new tile and the original tile size.
---For example, if rescaling a 5 x 5 tile entity to a 3 x 3 tile entity, `scalar` should be `3 / 5`.
---
---### Examples
---```lua
----- Rescale the "big-electric-pole" by a factor of 2.
----- The resulting entity will have a 4 x 4 tile footprint, and sprite to match.
---_sprites.rescale_prototype(data.raw["electric-pole"]["big-electric-pole"], 2)
---
----- Rescale the "oil-refinery" by a factor of 3 / 5.
----- The resulting entity will have a 3 x 3 tile footprint, and sprite to match.
---_sprites.rescale_prototype(data.raw["assembling-machine"]["oil-refinery"], 3 / 5)
---```
---
---### Parameters
---@param entity_prototype any # The entity prototype to rescale.
---@param scalar double # The scale factor to resize the prototype by.
function _sprites.rescale_prototype(entity_prototype, scalar)
	---
	---Recursively scales all numeric values in the given `table`, regardless of depth.
	---
	---### Returns
	---@return table # The rescaled table.
	---
	---### Parameters
	---@param table table # The table to rescale.
	local function rescale_table_recursively(table)
		for key, value in pairs(table) do
			if type(value) == "table" then
				table[key] = rescale_table_recursively(value)
			elseif type(value) == "number" then
				table[key] = value * scalar
			else
				-- Do nothing.
			end
		end

		return table
	end

	for key, value in pairs(entity_prototype) do
		-- Because Factorio assumes the value of the scale field if left undefined,
		-- we need to ensure it's defined. Use canon-typical violence.
		if entity_prototype.filename or entity_prototype.stripes or entity_prototype.filenames then
			entity_prototype.scale = entity_prototype.scale or 0.5
		end

		if included_fields[key] then
			if type(value) == "table" then
				entity_prototype[key] = rescale_table_recursively(util.copy(value))
			elseif type(value) == "number" then
				entity_prototype[key] = value * scalar
			else
				-- Do nothing.
			end
		elseif excluded_fields[key] then
			-- Do nothing.
		elseif type(value) == "table" then
			_sprites.rescale_prototype(value, scalar)

			-- Scale is not a supported property of stripes, but will be added in child tables.
			-- FIXME: This is a hacky solution to a problem of unused prototypes, and it would be better
			-- to provide some context to the recursive calls so that scale is not added in the first place.
			if key == "stripes" then
				for _, stripe in pairs(value) do
					stripe.scale = nil
				end
			end
		end
	end
end

---Returns a rescaled copy of the given `prototype`, resized by the given `scalar`.
---
---Recursively iterates through a copy of the given `prototype` and applies the given `scalar` to all
---the numeric values in the fields listed in `included_fields`.
---
---### Returns
---@generic T
---@return T # A rescaled copy of `entity_prototype`.
---
---### Remarks
---`scalar` is recommended to be the ratio of the new tile and the original tile size.
---For example, if rescaling a 5 x 5 tile entity to a 3 x 3 tile entity, `scalar` should be `3 / 5`.
---
---`prototype` is not modified.
---
---### Examples
---```lua
----- Get a rescaled copy of the "big-electric-pole" by a factor of 2.
----- The resulting entity will have a 4 x 4 tile footprint, and sprite to match.
---local rescaled = _sprites.get_rescaled_prototype(data.raw["electric-pole"]["big-electric-pole"], 2)
---
----- Get a rescaled copy of the "oil-refinery" by a factor of 3 / 5.
----- The resulting entity will have a 3 x 3 tile footprint, and sprite to match.
---local rescaled = _sprites.get_rescaled_prototype(data.raw["assembling-machine"]["oil-refinery"], 3 / 5)
---```
---
---### Parameters
---@param entity_prototype T # The entity prototype to rescale.
---@param scalar double # The scale factor to resize the prototype by.
---
---### See Also
---@see Reskins.SpriteUtils.Sprites.rescale_prototype
---@nodiscard
function _sprites.get_rescaled_prototype(entity_prototype, scalar)
	local entity_prototype_copy = util.copy(entity_prototype)
	_sprites.rescale_prototype(entity_prototype_copy, scalar)
	return entity_prototype_copy
end

---Resizes a copy of the `CorpsePrototype` associated with the given `prototype` by the given
---`scalar`, and assigns the rescaled copy to `prototype`. The name of the rescaled copy is
---prefixed with "rescaled-".
---
---### Remarks
---`scalar` is recommended to be the ratio of the new tile and the original tile size.
---For example, if rescaling a 5 x 5 tile entity to a 3 x 3 tile entity, `scalar` should be `3 / 5`.
---
---### Examples
---```lua
----- Rescale the remnants of the "big-electric-pole" by a factor of 2.
----- The resulting entity will have a 4 x 4 tile footprint, and sprite to match.
---_sprites.rescale_remnants_of_prototype(data.raw["electric-pole"]["big-electric-pole"], 2)
---```
---
---### Parameters
---@param prototype data.EntityWithHealthPrototype # The entity with the remnants to rescale.
---@param scalar double # The scale factor to resize the prototype by.
---
---### See Also
---@see Reskins.SpriteUtils.Sprites.rescale_prototype
function _sprites.rescale_remnants_of_prototype(prototype, scalar)
	-- Check the entity exists
	if not prototype then
		return
	end

	-- Fetch remnant
	local remnant_name = prototype.corpse

	-- Create, rescale, and assign rescaled remnant
	if remnant_name then
		local remnant = data.raw.corpse[remnant_name]

		if remnant then
			local rescaled_remnant = util.copy(remnant)
			rescaled_remnant.name = "rescaled-" .. rescaled_remnant.name

			_sprites.rescale_prototype(rescaled_remnant, scalar)
			data:extend({ rescaled_remnant })

			prototype.corpse = rescaled_remnant.name
		end
	end
end

return _sprites
