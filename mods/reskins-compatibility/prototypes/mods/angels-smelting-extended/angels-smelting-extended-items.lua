-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["angels-smelting-extended"] then
	return
end
if not reskins.angels then
	return
end

----------------------------------------------------------------------------------------------------
-- ITEMS AND RECIPES
----------------------------------------------------------------------------------------------------

-- Fix ASE-sand-die and ASE-metal-die

---@type data.IconData[]
data.raw.item["ASE-sand-die"].icons = { {
	icon = "__angelssmeltinggraphics__/graphics/icons/expendable-mold.png",
	icon_size = 32,
	scale = 1,
} }

---@type data.IconData[]
data.raw.item["ASE-metal-die"].icons = { {
	icon = "__angelssmeltinggraphics__/graphics/icons/non-expendable-mold.png",
	icon_size = 32,
	scale = 1,
} }

---
---Creates the icon sources for a the given `recipe_name` uses the given list of `source_names`.
---
---A source prototype is treated as an `"item"`, or a `"fluid"` if `"liquid"` is in the name.
---
---@param recipes_icon_sources { [string]: IconSources }
---@param recipe_name string # The name of the recipe to build the sources for.
---@param source_names string[] # A list of prototype names to use as a PrototypeIconSource.
local function add_icon_sources_for_recipe(recipes_icon_sources, recipe_name, source_names)
	---@type IconSources
	local sources = {
		{ name = source_names[1], type_name = "item" },
		{ name = source_names[2], type_name = "item", scale = reskins.angels.constants.recipe_corner_scale, shift = { -10, -10 } },
	}

	if source_names[3] then
		sources[3] = { name = source_names[3], type_name = "item", scale = reskins.angels.constants.recipe_corner_scale, shift = { 10, -10 } }
	end

	-- Check for liquids and set type parameter
	for _, source in pairs(sources) do
		if string.find(source.name, "liquid") then
			source.type_name = "fluid"
		end
	end

	-- Assign to the recipe table
	recipes_icon_sources[recipe_name] = sources
end

-- A map of recipe names to the icon sources used to create a combined icon.
-- The first entry in each IconSources is the first layer of the created icon.
---@type { [string]: IconSources }
local recipe_icon_source_map = {}

-- A map of recipe names mapped to the list of prototype names to use when creating
-- PrototypeIconSource objects.
---@type { [string]: string[] }
local recipe_source_names_map = {
	-- Plate composite recipes
	["angels-plate-tungsten"] = { "bob-tungsten-plate", "casting-powder-tungsten" },
	["angels-plate-tungsten-2"] = { "bob-tungsten-plate", "angels-roll-tungsten" },
	["angels-plate-invar-2"] = { "bob-invar-alloy", "angels-roll-invar" },
	["angels-plate-nitinol-2"] = { "bob-nitinol-alloy", "angels-roll-nitinol" },
	-- ["angels-plate-cobalt-steel-2"] = { "bob-cobalt-steel-alloy", "angels-roll-cobalt-steel" },
	["angels-plate-cobalt-steel-1"] = { "bob-cobalt-steel-alloy", "angels-liquid-molten-iron", "angels-liquid-molten-cobalt" },
	["angels-plate-cobalt-steel-2"] = { "bob-cobalt-steel-alloy", "angels-liquid-molten-steel", "angels-liquid-molten-cobalt" },
	["angels-plate-brass-2"] = { "bob-brass-alloy", "angels-roll-brass" },
	["angels-plate-bronze-2"] = { "bob-bronze-alloy", "angels-roll-bronze" },
	["angels-plate-gunmetal-2"] = { "bob-gunmetal-alloy", "angels-roll-gunmetal" },
}

for recipe_name, source_names in pairs(recipe_source_names_map) do
	add_icon_sources_for_recipe(recipe_icon_source_map, recipe_name, source_names)
end

-- Setup gears and related recipes
local gear_materials = {
	"iron",
	"titanium",
	"steel",
	"tungsten",
	"nitinol",
	"cobalt-steel",
	"brass",
}

-- Build composite table entries for the gear materials
for _, material in pairs(gear_materials) do
	if material == "tungsten" then
		add_icon_sources_for_recipe(recipe_icon_source_map, "angels-" .. material .. "-gear-wheel-casting", { material .. "-gear-wheel", "casting-powder-" .. material })
	else
		add_icon_sources_for_recipe(recipe_icon_source_map, "angels-" .. material .. "-gear-wheel-casting", { material .. "-gear-wheel", "angels-liquid-molten-" .. material })
	end

	add_icon_sources_for_recipe(recipe_icon_source_map, "ASE-" .. material .. "-gear-casting-expendable", { material .. "-gear-wheel", "ASE-sand-die" })
	add_icon_sources_for_recipe(recipe_icon_source_map, "ASE-" .. material .. "-gear-casting-advanced", { material .. "-gear-wheel", "ASE-metal-die" })
end

reskins.lib.icons.create_and_assign_combined_icons_from_sources_to_recipe(recipe_icon_source_map)

-- Fix Mad Clown's brass casting recipe sorting
if data.raw["item-subgroup"]["angels-brass-casting"] and data.raw.recipe["angels-brass-smelting-4"] then
	data.raw.recipe["angels-brass-smelting-4"].order = "d"
	data.raw.recipe["angels-brass-smelting-4"].subgroup = "angels-brass-casting"
end
