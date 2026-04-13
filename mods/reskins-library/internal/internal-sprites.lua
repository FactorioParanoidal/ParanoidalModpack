-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---
---Creates a `SpriteVariations` object with `num_variations` using the the sprite variations
---under the given folder in an Artisanal Reksins mod, with the given `sprite_name`.
---Provide a `tint` to include a light layer.
---
---Convenience method. Expects files at `reskins[mod_key].directory .. "/graphics/icons/{folder}/{sprite_name}/{sprite_name}.png"`.
---
---### Examples
---
---```
----- Create 5 sprite variations for the "shot" item in Bob's Warfare mod.
---local sprite_variations = reskins._internal.create_sprite_variations("bobs", "warfare/components", "shot", 5)
---```
---
---### Remarks
---Images are expected to be named `{sprite_name}-#.png`, where `#` is the variation number, except the
---first, which is `{sprite_name}.png`.
---
---For example, `shot.png`, `shot-2.png`, `shot-3.png`, `shot-4.png`, `shot-5.png`.
---
---
---### Parameters
---@param key "lib"|"bobs"|"angels"|"compatibility" # The key to the mod directory containing the files.
---@param subfolder string # The partial folder path under the `"graphics/icons"` directory containing the sprite variations, e.g. `"warfare/components"`.
---@param sprite_name string # The name of the sprite variations, without number or extensions, e.g. `{sprite_name}.png` or `{sprite_name}-#.png`.
---@param num_variations integer # The number of sprite variations; this must match the number of files.
---@param is_light? boolean # Whether the sprite variations include a light layer. Defaults to `false`.
---@param tint? data.Color # The tint of the light layer. Defaults to `{ r = 0.3, g = 0.3, b = 0.3, a = 0.3 }`.
---### Returns
---@return data.SpriteVariations[] # The `SpriteVariations` object for the given parameters.
---
---### Exceptions
---*@throws* `string` — Thrown when `reskins[mod_key].directory` does not exist.<br/>
---
---### See Also
---@see Reskins.Lib.Sprites.create_sprite_variations
---@nodiscard
function reskins.internal.create_sprite_variations(key, subfolder, sprite_name, num_variations, is_light, tint)
	assert(key and reskins[key] and reskins[key].directory, "Invalid parameter: `mod_key` must be a valid key to the directory of a mod in the reskins global.")
	---@type string
	local directory = reskins[key].directory .. "/graphics/icons/" .. subfolder .. "/" .. sprite_name

	return reskins.lib.sprites.create_sprite_variations(directory, sprite_name, num_variations, is_light, tint)
end
