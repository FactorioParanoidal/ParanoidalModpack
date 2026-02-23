-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api.sprites" then
	return require("__reskins-library__.api.sprites")
end

--- Provides methods for manipulating sprites.
---
---### Examples
---```lua
---local _sprites = require("__reskins-library__.api.sprites")
---```
---@class Reskins.Lib.Sprites
local _sprites = {
	---@type Reskins.Lib.Sprites.Belts
	belts = require("__reskins-library__.api.sprites.belts"),

	---@type Reskins.Lib.Sprites.ChemicalPlants
	chemical_plants = require("__reskins-library__.api.sprites.chemical-plants"),

	---@type Reskins.Lib.Sprites.Pipes
	pipes = require("__reskins-library__.api.sprites.pipes"),
}

---@type Reskins.Lib.Icons
local _icons = require("__reskins-library__.api.icons")

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
---local sprite = reskins.tools.sprites.create_sprite_from_icons(icon_data, 1.0)
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
---local sprite = reskins.tools.sprites.create_sprite_from_icon(icon_datum, 1.0)
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

---@alias LightSpriteNames
--- | "atomic-artillery-shell" The name of the sprite for a a radioactive atomic artillery shell.
--- | "aura-bullet"            The name of the sprite for a bullet with a glowing aura.
--- | "aura-projectile"        The name of the sprite for a projectile component with a glowing aura.
--- | "aura-rocket"            The name of the sprite for a rocket with a glowing aura.
--- | "aura-shotgun-shell"     The name of the sprite for a shotgun shell with a glowing aura.
--- | "aura-warhead"           The name of the sprite for a warhead with a glowing aura.
--- | "electric-bullet"        The name of the sprite for an electric bullet.
--- | "electric-projectile"    The name of the sprite for an electric projectile component.
--- | "electric-rocket"        The name of the sprite for an electric rocket.
--- | "electric-shotgun-shell" The name of the sprite for an electric shotgun shell.
--- | "electric-warhead"       The name of the sprite for an electric warhead.
--- | "fuel"                   The name of the sprite for a fuel item, such as nuclear fuel.
--- | "fuel-cell"              The name of the sprite for a reactor fuel cell.
--- | "laser-rifle-battery"    The name of the sprite for a laser rifle battery.
--- | "rocket"                 The name of the sprite for a rocket, such as a uranium-tipped rocket.
--- | "rounds-magazine"        The name of the sprite for a magazine, such as uranium rounds.

---
---Creates a `Sprite` object configured for use as a light layer for the given `light_type`,
---with the given `tint`.
---
---### Examples
---```lua
----- Gets a light layer for an projectile with a blue tint.
---local sprite = sprites.get_sprite_light_layer("aura-projectile", util.color("#1280b2"))
---```
---
---### Parameters
---@param light_name LightSpriteNames # The name of the light sprite used to create the light layer.
---@param tint? data.Color # The tint of the light layer. Default `nil`.
---### Returns
---@return data.Sprite # A `Sprite` object configured for use as a light layer.
---@nodiscard
function _sprites.get_sprite_light_layer(light_name, tint)
	---@type data.Sprite
	local sprite = {
		flags = { "light", "icon" },
		draw_as_light = true,
		filename = "__reskins-library__/graphics/icons/lights/" .. light_name .. "-light.png",
		size = 64,
		mipmap_count = 4,
		scale = 0.5,
		tint = tint,
	}

	return sprite
end

---
---Creates a `SpriteVariations` object with `num_variations` using the the sprite variations
---in the given `directory` and with the given `sprite_name`.
---Provide a `tint` to include a light layer.
---
---### Examples
---```lua
----- Create 5 sprite variations for the "shot" item in Bob's Warfare mod.
---local folder_path = "__reskins-bobs__/graphics/icons/warfare/components/shot"
---
---local sprite_variations = sprites.create_sprite_variations(folder_path, "shot", 5)
---```
---
---### Remarks
---Images are expected to be named `{sprite_name}-#.png`, where `#` is the variation number, except the
---first, which is `{sprite_name}.png`.
---
---For example, `shot.png`, `shot-2.png`, `shot-3.png`, `shot-4.png`, `shot-5.png`.
---
---### Parameters
---@param directory string # The path to the directory containing the sprite variations, with-or-without trailing forward slash.
---@param sprite_name string # The name of the sprite variations, without number or extensions, e.g. `{sprite_name}.png` or `{sprite_name}-#.png`.
---@param num_variations integer # The number of sprite variations; this must match the number of files.
---@param is_light? boolean # Whether the sprite variations include a light layer. Defaults to `false`.
---@param tint? data.Color # The tint of the light layer. Defaults to `{ r = 0.3, g = 0.3, b = 0.3, a = 0.3 }`.
---### Returns
---@return data.SpriteVariations[] # The `SpriteVariations` object for the given parameters.
---
---### Exceptions
---*@throws* `string` — Thrown when `directory` is not a non-empty string.<br/>
---*@throws* `string` — Thrown when `sprite_name` is not a non-empty string.<br/>
---*@throws* `string` — Thrown when `num_variations` is not a positive integer.
---@nodiscard
function _sprites.create_sprite_variations(directory, sprite_name, num_variations, is_light, tint)
	assert(directory and type(directory) == "string" and directory ~= "", "Invalid parameter: `directory` must not be non-empty string.")
	assert(sprite_name and type(sprite_name) == "string" and sprite_name ~= "", "Invalid parameter: `sprite_name` must not be non-empty string.")
	assert(num_variations and num_variations > 0 and num_variations % 1 == 0, "Invalid parameter: `num_variations` must be a positive integer.")

	if not directory:match("/$") then
		directory = directory .. "/"
	end

	---@type data.SpriteVariations[]
	local sprites = {}
	for n = 1, num_variations do
		local file_name = sprite_name .. ((n > 1) and ("-" .. (n - 1) .. ".png") or ".png")

		if is_light then
			---@type data.Sprite
			local sprite = {
				layers = {
					{
						filename = directory .. file_name,
						flags = { "icon" },
						size = 64,
						mipmap_count = 4,
						scale = 0.5,
					},
					{
						filename = directory .. file_name,
						flags = { "icon" },
						size = 64,
						tint = tint or { r = 0.3, g = 0.3, b = 0.3, a = 0.3 },
						mipmap_count = 4,
						scale = 0.5,
						draw_as_light = true,
						blend_mode = "additive",
					},
				},
			}

			table.insert(sprites, sprite)
		else
			---@type data.Sprite
			local sprite = {
				filename = directory .. file_name,
				flags = { "icon" },
				size = 64,
				mipmap_count = 4,
				scale = 0.5,
			}

			table.insert(sprites, sprite)
		end
	end

	return sprites
end

---Provides additional fields for the `data.Animation` object when using a sprite sheet with
---frames laid out in vertical stripes instead of the standard convention of horizontal stripes.
---@class VerticallyOrientableAnimation : data.Animation
---When `true`, indicates that the Animation sprites are laid out vertically and should be processed
---accordingly by `_sprites.make_4way_animation_from_spritesheet`.
---@field vertically_oriented? boolean
---
---If this property is present, all Animation definitions have to be placed as entries in the array,
---and they will all be loaded from there. layers may not be an empty table. Each definition in the
---array may also have the layers property.
---
---`animation_speed` and `max_advance` of the first layer are used for all layers. All layers will
---run at the same speed.
---
---If this property is present, all other properties, including those inherited from
---AnimationParameters, are ignored.
---@field layers? VerticallyOrientableAnimation[]

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
---    filename = "__modname__/graphics/entity/prototype/prototype.png",
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

return _sprites
