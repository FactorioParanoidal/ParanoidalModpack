-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "angels",
	group = "petrochem",
	make_icon_pictures = false,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local intermediates = {
	----------------------------------------------------------------------------------------------------
	-- Intermediates
	----------------------------------------------------------------------------------------------------
	-- Miscellaneous
	["angels-pellet-coke"] = { subgroup = "intermediates", image = "pellet-coke" },

	----------------------------------------------------------------------------------------------------
	-- Recipes
	----------------------------------------------------------------------------------------------------
	-- Miscellaneous
	["bob-rubber"] = { type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "rubber", icon_extras = reskins.angels.num_tier(1, inputs.group) }, -- "1"
	["angels-solid-rubber"] = { type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "rubber", icon_extras = reskins.angels.num_tier(2, inputs.group) }, -- "2"
}

if mods["reskins-bobs"] then
	intermediates["bob-resin-wood"] = { type = "recipe", mod = "bobs", group = "plates", subgroup = "items", image = "bob-resin", icon_extras = reskins.angels.num_tier(1, inputs.group) }
	intermediates["angels-solid-resin"] = { type = "recipe", mod = "bobs", group = "plates", subgroup = "items", image = "bob-resin" }
end

if not data.raw.recipe["bob-rubber"] then
	intermediates["angels-solid-rubber"].icon_extras = nil
	intermediates["angels-solid-rubber"].type = nil
end

reskins.internal.create_icons_from_list(intermediates, inputs)

-- A map of recipe names to the icon sources used to create a combined icon.
-- The first entry in each IconSources is the first layer of the created icon.
---@type { [string]: IconSources }
local recipe_icon_source_map = {
	["bio-resin-wood-reprocessing"] = {
		{ name = reskins.lib.prototypes.get_name_of_first_item_that_exists("bob-resin", "solid-resin"), type_name = "item" },
		{ name = "wood", type_name = "item", scale = 0.5, shift = { -8, -8 } },
	},
}

reskins.lib.icons.create_and_assign_combined_icons_from_sources_to_recipe(recipe_icon_source_map)
