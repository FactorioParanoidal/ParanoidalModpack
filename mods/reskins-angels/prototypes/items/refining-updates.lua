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

---@type CreateIconsFromListTable
local intermediates = {
	----------------------------------------------------------------------------------------------------
	-- Intermediates
	----------------------------------------------------------------------------------------------------
	-- Miscellaneous
	["angels-solid-limestone"] = { subgroup = "intermediates", image = "solid-limestone" },
	["angels-slag"] = { subgroup = "intermediates", image = "slag" },
}

-- Check if we're using Angel's material colors
if mods["bobwarfare"] and mods["bobplates"] and reskins.lib.settings.get_value("reskins-angels-use-angels-material-colors") then
	intermediates["heavy-armor-2"] = { type = "armor", group = "smelting", subgroup = "armor" }
end

reskins.internal.create_icons_from_list(intermediates, inputs)

-- A map of recipe names to the icon sources used to create a combined icon.
-- The first entry in each IconSources is the first layer of the created icon.
---@type { [string]: IconSources }
local recipe_icon_source_map = {
	-- Mud water progression
	["angels-water-heavy-mud"] = {
		{ name = "angels-water-heavy-mud", type_name = "fluid" },
		{ icon_data = reskins.angels.num_tier(1, "refining") },
	},
	["angels-water-concentrated-mud"] = {
		{ name = "angels-water-concentrated-mud", type_name = "fluid" },
		{ icon_data = reskins.angels.num_tier(2, "refining") },
	},
	["angels-water-light-mud"] = {
		{ name = "angels-water-light-mud", type_name = "fluid" },
		{ icon_data = reskins.angels.num_tier(3, "refining") },
	},
	["angels-water-thin-mud"] = {
		{ name = "angels-water-thin-mud", type_name = "fluid" },
		{ icon_data = reskins.angels.num_tier(4, "refining") },
	},
	["angels-water-saline"] = {
		{ name = "angels-water-saline", type_name = "fluid" },
		{ icon_data = reskins.angels.num_tier(5, "refining") },
	},
}

reskins.lib.icons.create_and_assign_combined_icons_from_sources_to_recipe(recipe_icon_source_map)
