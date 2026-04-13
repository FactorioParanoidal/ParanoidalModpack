-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.electronics.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "electronics",
	make_icon_pictures = false,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local intermediates = {
	-- Wires
	["bob-gilded-copper-cable"] = { mod = "lib", group = "shared", subgroup = "items", image = "gilded-copper-cable" },
	["bob-tinned-copper-cable"] = { subgroup = "wires" },
	["bob-insulated-cable"] = { subgroup = "wires" },

	-- Intermediates
	["bob-solder"] = { mod = "lib", group = "shared", subgroup = "items", image = "solder" },
}

-- Items and recipes shared with other mods within Bob's suite
if not mods["bobplates"] then
	-- Intermediates
	intermediates["solder-alloy"] = { mod = "lib", group = "shared", subgroup = "items" }
	intermediates["rubber"] = { mod = "lib", group = "shared", subgroup = "items" }
	intermediates["resin"] = { group = "plates", subgroup = "items" }
	intermediates["ferric-chloride-solution"] = { type = "fluid", group = "plates", subgroup = "fluids" }
	intermediates["silicon-wafer"] = { mod = "lib", group = "shared", subgroup = "items" }

	-- Recipes
	intermediates["coal-cracking"] = { type = "recipe", group = "plates", subgroup = "recipes" }
	intermediates["bob-synthetic-wood"] = { type = "recipe", group = "plates", subgroup = "recipes" }
	intermediates["bob-resin-wood"] = { type = "recipe", group = "plates", subgroup = "recipes" }
	intermediates["bob-resin-oil"] = { type = "recipe", group = "plates", subgroup = "recipes" }
end

reskins.internal.create_icons_from_list(intermediates, inputs)
