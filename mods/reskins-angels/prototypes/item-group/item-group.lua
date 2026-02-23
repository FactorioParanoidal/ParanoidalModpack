-- Copyright (c) 2025 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

if angelsmods.industries and angelsmods.industries.overhaul then
	if data.raw["item-group"]["bob-gems"] then
		-- gems group
		data.raw["item-group"]["bob-gems"].icon = nil
		data.raw["item-group"]["bob-gems"].icon_size = nil
		data.raw["item-group"]["bob-gems"].icons = {
			{
				icon = "__reskins-bobs__/graphics/item-group/bob-gems.png",
				icon_size = 128,
			},
			{
				icon = "__angelsrefininggraphics__/graphics/icons/bobs-logo.png",
				icon_size = 1080,
				scale = 64 / 1080 * 0.35,
				shift = { 20, -20 },
			},
		}
	end
end
