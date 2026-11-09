local util = require("util")

local Public = {}

--== Icon/image effect helpers ==--
-- Ported from "Muluna, Moon of Nauvis" (planet-muluna/lib/images.lua).

--- Returns a copy of the given icons that appears blurred, by layering many nearly-transparent,
--- slightly offset duplicates of every entry using a multiplicative blend mode. Useful for
--- obfuscating a technology's icon (for example, a technology the player has not yet unlocked).
--- The original icons are not modified.
--- @param icons table IconData array to blur.
--- @param blurriness number How far the offset duplicates are displaced. Must be greater than 0.
--- @return table IconData array.
function Public.blur_technology_icon(icons, blurriness)
	assert(
		type(blurriness) == "number" and blurriness > 0,
		"PlanetsLib.blur_technology_icon(icons, blurriness) - blurriness must be a number greater than 0."
	)

	local blur_count = 8
	local blur_shift_max = 5 * blurriness
	local blur_shift_start = 1 * blurriness
	local blur_shift_steps = 1 * blurriness
	local brightness_modifier = 1
	local sprites_list = util.table.deepcopy(icons)
	icons = {}
	local n = blur_count * (1 + (blur_shift_max - blur_shift_start) / blur_shift_steps)
	for _, child_original in pairs(sprites_list) do
		local copy = util.table.deepcopy(child_original)
		copy.tint = { 1, 1, 1 } -- Make sure that none of the sprite is transparent where it shouldn't be.
		table.insert(icons, copy)
		local child = util.table.deepcopy(child_original)
		for i = 1, blur_count do
			for blur_shift = blur_shift_start, blur_shift_max, blur_shift_steps do
				local shift_x = blur_shift * math.cos(i * 2 * math.pi / blur_count)
				local shift_y = blur_shift * math.sin(i * 2 * math.pi / blur_count)

				if child.shift then
					if not child.shift[1] then
						child.shift[1] = shift_x
					else
						child.shift[1] = child.shift[1] + shift_x
					end
					if not child.shift[2] then
						child.shift[2] = shift_y
					else
						child.shift[2] = child.shift[2] + shift_y
					end
				else
					child.shift = { shift_x, shift_y }
				end

				child.tint = {
					brightness_modifier / n,
					brightness_modifier / n,
					brightness_modifier / n,
					brightness_modifier / n,
				}
				child.blend_mode = "multiplicative-with-alpha"
				table.insert(icons, child)
			end
		end
	end
	return icons
end

return Public
