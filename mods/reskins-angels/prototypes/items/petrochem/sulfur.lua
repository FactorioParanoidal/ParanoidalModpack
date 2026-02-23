-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.items) then
	return
end

---@type DeferrableIconDatum
local deferrable_icon = {
	name = "sulfur",
	type_name = "item",
	icon_datum = {
		icon = "__base__/graphics/icons/sulfur.png",
		icon_size = 64,
		scale = 0.5,
	},
}

reskins.lib.icons.assign_deferrable_icon(deferrable_icon)

-- Fix recipe icons, but in the lazy hard-coded way we'll come back to later.
-- TO-DO: Make this a more general, robust process rather than a one-off
if data.raw.recipe["solid-sulfur"] and data.raw.recipe["solid-sulfur"].icons and data.raw.recipe["solid-sulfur"].icons[5] then
	data.raw.recipe["solid-sulfur"].icons[5] = {
		icon = deferrable_icon.icon_datum.icon,
		icon_size = 64,
		scale = 0.16,
		shift = { -11.5, 12 },
	}
end

if data.raw.recipe["yellow-waste-water-purification"] and data.raw.recipe["yellow-waste-water-purification"].icons and data.raw.recipe["yellow-waste-water-purification"].icons[12] then
	data.raw.recipe["yellow-waste-water-purification"].icons[12] = {
		icon = deferrable_icon.icon_datum.icon,
		icon_size = 64,
		scale = 0.16,
		shift = { 0, 12 },
	}
end
