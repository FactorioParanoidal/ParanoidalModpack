-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "angels",
	group = "refining",
	make_icon_pictures = false,
	flat_icon = true,
}

local shift = reskins.angels.constants.recipe_corner_shift
local scale = reskins.angels.constants.recipe_corner_scale

-- TODO: https://github.com/kirazy/reskins-angels/issues/16 Improve handling of refining->smelting->refining icon processing

---@type CreateIconsFromListTable
local intermediates = {}

reskins.internal.create_icons_from_list(intermediates, inputs)

-- A map of recipe names to the icon sources used to create a combined icon.
-- The first entry in each IconSources is the first layer of the created icon.
---@type { [string]: IconSources }
local recipe_icon_source_map = {
	-- Lead plates
	["angels-ore5-crushed-smelting"] = {
		{ name = reskins.lib.prototypes.get_name_of_first_item_that_exists("bob-lead-plate", "angels-plate-lead"), type_name = "item" },
		{ name = "angels-ore5-crushed", type_name = "item", scale = scale, shift = shift }, -- Crushed rubyte
	},

	-- Tin plates
	["angels-ore6-crushed-smelting"] = {
		{ name = reskins.lib.prototypes.get_name_of_first_item_that_exists("bob-tin-plate", "angels-plate-tin"), type_name = "item" },
		{ name = "angels-ore6-crushed", type_name = "item", scale = scale, shift = shift }, -- Crushed bobmonium
	},
}

reskins.lib.icons.create_and_assign_combined_icons_from_sources_to_recipe(recipe_icon_source_map)
