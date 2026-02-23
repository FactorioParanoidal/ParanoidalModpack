-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api.sprites.belts" then
	return require("__reskins-library__.api.sprites.belts")
end

--- Provides methods for getting sprites for belt-type entities.
---
---### Examples
---```lua
---local _belts = require("__reskins-library__.api.sprites.belts")
---```
---@class Reskins.Lib.Sprites.Belts
local _belts = {}

---
---Gets the belt animation set for the given `belt_sprites`, tinted with the given `tint`.
---
---### Returns
---@return data.TransportBeltAnimationSet # A tinted belt animation set.
---
---### Examples
---```lua
----- Get the belt animation set for a slow belt, colored with a red tint.
---local tint = util.color("#ff0000")
---local belt_animation_set = _belts.get_belt_animation_set(_defines.belt_sprites.standard, tint)
---
----- Set it on the transport belt prototype.
---local belt = data.raw["transport-belt"]["transport-belt"]
---belt.belt_animation_set = belt_animation_set
---```
---
---### Parameters
---@param belt_sprites Reskins.Lib.Defines.BeltSprites # The type of belt animation set to get.
---@param tint data.Color # The tint to apply to the belt animation set.
---
---### Exceptions
---*@throws* `string` — Thrown when `belt_sprites` is an unsupported type.
function _belts.get_belt_animation_set(belt_sprites, tint)
	---@type data.TransportBeltAnimationSet
	local belt_animation_set

	if belt_sprites == reskins.lib.defines.belt_sprites.standard then
		---@type data.TransportBeltAnimationSet
		belt_animation_set = {
			---`direction_count` is defined as a required property, but is not needed at the root
			---because `layers` is defined, and `direction_count` is defined within `layers`.
			---@diagnostic disable-next-line: missing-fields
			animation_set = {
				layers = {
					-- Base
					{
						filename = "__reskins-library__/graphics/entity/base/transport-belt/transport-belt-1-base.png",
						priority = "extra-high",
						width = 128,
						height = 128,
						scale = 0.5,
						frame_count = 16,
						direction_count = 20,
					},
					-- Mask
					{
						filename = "__reskins-library__/graphics/entity/base/transport-belt/transport-belt-1-mask.png",
						priority = "extra-high",
						width = 128,
						height = 128,
						scale = 0.5,
						frame_count = 16,
						tint = tint,
						direction_count = 20,
					},
					-- Highlights
					{
						filename = "__reskins-library__/graphics/entity/base/transport-belt/transport-belt-1-highlights.png",
						priority = "extra-high",
						width = 128,
						height = 128,
						scale = 0.5,
						frame_count = 16,
						blend_mode = reskins.lib.settings.blend_mode,
						direction_count = 20,
					},
				},
			},
		}
	elseif belt_sprites == reskins.lib.defines.belt_sprites.express then
		---@type data.TransportBeltAnimationSet
		belt_animation_set = {
			---`direction_count` is defined as a required property, but is not needed at the root
			---because `layers` is defined, and `direction_count` is defined within `layers`.
			---@diagnostic disable-next-line: missing-fields
			animation_set = {
				layers = {
					-- Base
					{
						filename = "__reskins-library__/graphics/entity/base/transport-belt/transport-belt-2-base.png",
						priority = "extra-high",
						width = 128,
						height = 128,
						scale = 0.5,
						frame_count = 32,
						direction_count = 20,
					},
					-- Mask
					{
						filename = "__reskins-library__/graphics/entity/base/transport-belt/transport-belt-2-mask.png",
						priority = "extra-high",
						width = 128,
						height = 128,
						scale = 0.5,
						frame_count = 32,
						tint = tint,
						direction_count = 20,
					},
					-- Highlights
					{
						filename = "__reskins-library__/graphics/entity/base/transport-belt/transport-belt-2-highlights.png",
						priority = "extra-high",
						width = 128,
						height = 128,
						scale = 0.5,
						frame_count = 32,
						blend_mode = reskins.lib.settings.blend_mode,
						direction_count = 20,
					},
				},
			},
		}
	else
		error("Unsupported: 'belt_sprites' must be either slow (" .. reskins.lib.defines.belt_sprites.standard .. ") or " .. "fast (" .. reskins.lib.defines.belt_sprites.express .. ").")
	end
	return belt_animation_set
end

return _belts
