-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.items) then
	return
end

---@class OreSpriteVariationsParameters
---@field key "angels"|"lib"
---@field subfolder string # e.g. "smelting/ores"; a folder under reskins[key].directory .. "/graphics/icons"
---@field num_variations? integer # Default 4.
---@field is_light? boolean # Default `nil`.

---Dictionary of ore names and their sprite variation parameters.
---Ore names are shared with the name of the icon subfolder and file.
---@type { [string]: OreSpriteVariationsParameters }
local ores = {
	-- ["angels-ore2"]   = { key = "angels", subfolder = "smelting/ores" }, -- Jivolite
	-- ["angels-ore4"]   = { key = "angels", subfolder = "smelting/ores" }, -- Crotinnium
	-- ["chrome-ore"]    = { key = "angels", subfolder = "smelting/ores" },
	-- ["manganese-ore"] = { key = "angels", subfolder = "smelting/ores" },
	-- ["platinum-ore"]  = { key = "angels", subfolder = "smelting/ores" },
	["bauxite-ore"] = { key = "lib", subfolder = "shared/ores", num_variations = 8 },
	["cobalt-ore"] = { key = "lib", subfolder = "shared/ores" },
	["gold-ore"] = { key = "lib", subfolder = "shared/ores" },
	["lead-ore"] = { key = "angels", subfolder = "smelting/ores" }, -- A cooler black than Bob's
	["nickel-ore"] = { key = "lib", subfolder = "shared/ores" },
	["quartz"] = { key = "lib", subfolder = "shared/ores" },
	["rutile-ore"] = { key = "angels", subfolder = "smelting/ores", sprite_name = "angels-rutile-ore" }, -- Titanium (dark purple)
	["silver-ore"] = { key = "lib", subfolder = "shared/ores" },
	["thorium-ore"] = { key = "angels", subfolder = "smelting/ores", num_variations = 4, is_light = true }, -- Red
	["tin-ore"] = { key = "angels", subfolder = "smelting/ores", num_variations = 8 }, -- (green)
	["tungsten-ore"] = { key = "lib", subfolder = "shared/ores", num_variations = 8 },
	["zinc-ore"] = { key = "lib", subfolder = "shared/ores" },
}

-- TODO: Not implemented. Needs sprites.
if reskins.lib.settings.get_value("reskins-angels-use-vanilla-style-ores") then
	table.insert(ores, {
		-- ["angels-ore1"] = { key = "angels", subfolder = "smelting/ores" }, -- Saphirite
		-- ["angels-ore3"] = { key = "angels", subfolder = "smelting/ores" }, -- Stiratite
		-- ["angels-ore5"] = { key = "angels", subfolder = "smelting/ores" }, -- Rubyte
		-- ["angels-ore6"] = { key = "angels", subfolder = "smelting/ores" }, -- Bobmonium
	})
end

for ore_name, params in pairs(ores) do
	-- FIXME: https://github.com/kirazy/reskins-library/issues/11
	local sprite_name = "bob-" .. ore_name

	---@type data.IconData[]
	local icon_data = { {
		icon = reskins[params.key].directory .. "/graphics/icons/" .. params.subfolder .. "/" .. sprite_name .. "/" .. sprite_name .. ".png",
		icon_size = 64,
		scale = 0.5,
	} }

	local pictures = reskins.internal.create_sprite_variations(params.key, params.subfolder, sprite_name, params.num_variations or 4, params.is_light)

	reskins.lib.icons.assign_deferrable_icon({
		name = "bob-" .. ore_name,
		type_name = "item",
		icon_data = icon_data,
		pictures = pictures,
	})

	reskins.lib.icons.assign_deferrable_icon({
		name = "angels-" .. ore_name,
		type_name = "item",
		icon_data = icon_data,
		pictures = pictures,
	})
end

-- Setup recipe bases

---Creates the base icon layer for the Ore Sorting Machine ore recipes.
---@return data.IconData
local function make_sorting_icon_base()
	return {
		icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png",
		icon_size = 32,
	}
end

---Creates the base icon layer for the Crystalizer slag processing recipes.
---@return data.IconData[]
local function make_slag_processing_icon_base()
	return {
		{
			icon = "__angelsrefininggraphics__/graphics/icons/angels-liquid/liquid-recipe-base.png",
			icon_size = 600,
			tint = util.color("#404040b2"),
		},
		{
			icon = "__angelsrefininggraphics__/graphics/icons/angels-liquid/liquid-recipe-top.png",
			icon_size = 600,
			tint = util.color("#ca6311"),
		},
		{
			icon = "__angelsrefininggraphics__/graphics/icons/angels-liquid/liquid-recipe-mid.png",
			icon_size = 600,
			tint = util.color("#613414"),
		},
		{
			icon = "__angelsrefininggraphics__/graphics/icons/angels-liquid/liquid-recipe-bot.png",
			icon_size = 600,
			tint = util.color("#613414"),
		},
	}
end

local shift = { 10, 10 }
local scale = 0.5

-- A map of recipe names to the icon sources used to create a combined icon.
-- The first entry in each IconSources is the first layer of the created icon.
---@type { [string]: IconSources }
local recipe_icon_source_map = {
	-- Ore Sorting Machine Recipes

	-- Lead
	["angels-ore-crushed-mix3-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-lead-ore"), type_name = "item", shift = shift, scale = scale },
	},
	-- Tin
	["angels-ore-crushed-mix4-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-tin-ore"), type_name = "item", shift = shift, scale = scale },
	},
	-- Silicon
	["angels-ore-chunk-mix1-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-quartz"), type_name = "item", shift = shift, scale = scale },
		{ name = angelsmods.functions.get_ore_name("bob-quartz"), type_name = "item", shift = shift, scale = scale },
	},
	-- Nickel
	["angels-ore-chunk-mix2-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-nickel-ore"), type_name = "item", shift = shift, scale = scale },
	},
	-- Aluminium
	["angels-ore-chunk-mix3-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-bauxite-ore"), type_name = "item", shift = shift, scale = scale },
	},
	-- Zinc
	["angels-ore-chunk-mix4-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-zinc-ore"), type_name = "item", shift = shift, scale = scale },
	},

	-- -- Fluorite
	-- ["angels-ore-chunk-mix5-processing"]   = {
	--     { icon_datum = make_sorting_icon_base() },
	--     { name = angelsmods.functions.get_ore_name("fluorite-ore"), type_name = "item", shift = shift, scale = scale },
	-- },
	-- -- Manganese?
	-- ["angels-ore-chunk-mix6-processing"]   = {
	--     { icon_datum = make_sorting_icon_base() },
	--     { name = angelsmods.functions.get_ore_name("manganese-ore"), type_name = "item", shift = shift, scale = scale },
	-- },

	-- Titanium
	["angels-ore-crystal-mix1-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-rutile-ore"), type_name = "item", shift = shift, scale = scale },
	},

	-- Gold
	["angels-ore-crystal-mix2-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-gold-ore"), type_name = "item", shift = shift, scale = scale },
	},

	-- Cobalt
	["angels-ore-crystal-mix3-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-cobalt-ore"), type_name = "item", shift = shift, scale = scale },
	},

	-- Silver
	["angels-ore-crystal-mix4-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-silver-ore"), type_name = "item", shift = shift, scale = scale },
	},

	-- Uranium
	["angels-ore-crystal-mix5-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("uranium-ore"), type_name = "item", shift = shift, scale = scale },
	},

	-- Thorium
	["angels-ore-crystal-mix6-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-thorium-ore"), type_name = "item", shift = shift, scale = scale },
	},

	-- Tungsten
	["angels-ore-pure-mix1-processing"] = {
		{ icon_datum = make_sorting_icon_base() },
		{ name = angelsmods.functions.get_ore_name("bob-tungsten-ore"), type_name = "item", shift = shift, scale = scale },
	},

	-- -- Platinum
	-- ["angels-ore-pure-mix2-processing"]    = {
	--     { icon_datum = make_sorting_icon_base() },
	--     { name = angelsmods.functions.get_ore_name("platinum-ore"), type_name = "item", shift = shift, scale = scale },
	-- },

	-- -- Chrome?
	-- ["angels-ore-pure-mix3-processing"]    = {
	--     { icon_datum = make_sorting_icon_base() },
	--     { name = angelsmods.functions.get_ore_name("chrome-ore"), type_name = "item", shift = shift, scale = scale },
	-- },
}

-- Build Crystalizer slag processing recipes
local slag_processing_recipe_names = {
	"angels-slag-processing-2",
	"angels-slag-processing-3",
	"angels-slag-processing-4",
	"angels-slag-processing-5",
	"angels-slag-processing-6",
	"angels-slag-processing-7",
	"angels-slag-processing-8",
	"angels-slag-processing-9",
}

---@type data.Vector[]
local slag_recipe_shifts = {
	{ -11.5, 12 },
	{ 11.5, 12 },
	{ 0, 12 },
}

for _, name in pairs(slag_processing_recipe_names) do
	-- Check the recipe exists
	local recipe = data.raw.recipe[name]
	if not recipe then
		goto continue
	end

	---@type data.ProductPrototype[]
	local recipe_results = recipe.results

	-- Build icon overlays based on recipe ingredients
	if recipe_results[1].name ~= "angels-void" then
		-- Add the base layer icon source.
		recipe_icon_source_map[name] = { { icon_data = make_slag_processing_icon_base() } }

		-- Add up to three products.
		for i, product in pairs(recipe_results) do
			-- More than 3 products is unhandled, but also not expected in the first place.
			if i > 3 then
				goto continue
			end

			---@type PrototypeIconSource
			local icon_source = {
				name = product.name,
				type_name = "item",
				shift = slag_recipe_shifts[i],
				scale = 0.32,
			}

			table.insert(recipe_icon_source_map[name], icon_source)
		end
	end

	::continue::
end

reskins.lib.icons.create_and_assign_combined_icons_from_sources_to_recipe(recipe_icon_source_map)
