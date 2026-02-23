-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.plates.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "plates",
	make_icon_pictures = false,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local intermediates = {
	-- Plates
	["bob-aluminium-plate"] = { subgroup = "plates" },
	["bob-brass-alloy"] = { subgroup = "plates", defer_to_data_updates = true },
	["bob-bronze-alloy"] = { subgroup = "plates", defer_to_data_updates = true },
	["bob-cobalt-plate"] = { subgroup = "plates" },
	["bob-cobalt-steel-alloy"] = { subgroup = "plates", defer_to_data_updates = true },
	["bob-copper-tungsten-alloy"] = { subgroup = "plates" },
	["bob-gold-plate"] = { mod = "lib", group = "shared", subgroup = "items", image = "gold-plate" }, -- Shared with Angels
	["bob-gunmetal-alloy"] = { subgroup = "plates", defer_to_data_updates = true },
	["bob-invar-alloy"] = { subgroup = "plates", defer_to_data_updates = true },
	["bob-lead-plate"] = { subgroup = "plates" },
	["bob-lithium"] = { subgroup = "plates" },
	["bob-nickel-plate"] = { subgroup = "plates" },
	["bob-nitinol-alloy"] = { subgroup = "plates", defer_to_data_updates = true },
	["bob-silver-plate"] = { subgroup = "plates" },
	["bob-solder-alloy"] = { subgroup = "plates" }, -- Shared with Bob's Electronics
	["bob-tin-plate"] = { subgroup = "plates" },
	["bob-titanium-plate"] = { subgroup = "plates" },
	["bob-tungsten-carbide"] = { subgroup = "plates" },
	["bob-tungsten-plate"] = { subgroup = "plates" },
	["bob-zinc-plate"] = { subgroup = "plates" },
	["bob-alien-orange-alloy"] = { subgroup = "plates" },
	["bob-alien-blue-alloy"] = { subgroup = "plates" },

	-- Bearings
	["bob-ceramic-bearing"] = { subgroup = "bearings" },
	["bob-cobalt-steel-bearing"] = { subgroup = "bearings" },
	["bob-nitinol-bearing"] = { subgroup = "bearings" },
	["bob-steel-bearing"] = { subgroup = "bearings" },
	["bob-titanium-bearing"] = { subgroup = "bearings" },

	-- Bearing Balls
	["bob-ceramic-bearing-ball"] = { subgroup = "bearing-balls" },
	["bob-cobalt-steel-bearing-ball"] = { subgroup = "bearing-balls" },
	["bob-nitinol-bearing-ball"] = { subgroup = "bearing-balls" },
	["bob-steel-bearing-ball"] = { subgroup = "bearing-balls" },
	["bob-titanium-bearing-ball"] = { subgroup = "bearing-balls" },

	-- Gear Wheels
	["bob-brass-gear-wheel"] = { subgroup = "gears" },
	["bob-cobalt-steel-gear-wheel"] = { subgroup = "gears" },
	["bob-nitinol-gear-wheel"] = { subgroup = "gears" },
	["bob-steel-gear-wheel"] = { subgroup = "gears" },
	["bob-titanium-gear-wheel"] = { subgroup = "gears" },
	["bob-tungsten-gear-wheel"] = { subgroup = "gears" },

	-- Nuclear
	["bob-plutonium-fuel-cell"] = { subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = { reskins.lib.sprites.get_sprite_light_layer("fuel-cell") } },
	["bob-thorium-fuel-cell"] = { subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = { reskins.lib.sprites.get_sprite_light_layer("fuel-cell") } },
	["bob-thorium-plutonium-fuel-cell"] = { subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = { reskins.lib.sprites.get_sprite_light_layer("fuel-cell") } },
	["bob-deuterium-fuel-cell"] = { subgroup = "nuclear", image = "bob-deuterium-fuel-cell-pink", make_icon_pictures = true, icon_picture_extras = { reskins.lib.sprites.get_sprite_light_layer("fuel-cell") } },
	["bob-deuterium-fuel-cell-2"] = { subgroup = "nuclear", image = "bob-deuterium-fuel-cell-2-pink", make_icon_pictures = true, icon_picture_extras = { reskins.lib.sprites.get_sprite_light_layer("fuel-cell") } },
	["bob-depleted-thorium-fuel-cell"] = { subgroup = "nuclear" },
	["bob-depleted-deuterium-fuel-cell"] = { subgroup = "nuclear", image = "bob-depleted-deuterium-fuel-cell-pink" },
	["bob-plutonium-239"] = {
		subgroup = "nuclear",
		make_icon_pictures = true,
		icon_picture_extras = {
			{
				filename = "__reskins-bobs__/graphics/icons/plates/nuclear/bob-plutonium-239.png",
				flags = { "icon" },
				size = 64,
				mipmap_count = 4,
				tint = { r = 0.3, g = 0.3, b = 0.3, a = 0.3 },
				blend_mode = "additive",
				draw_as_light = true,
				scale = 0.5,
			},
		},
	},
	["bob-thorium-232"] = { subgroup = "nuclear" },

	-- Fluids
	["bob-liquid-air"] = { type = "fluid", subgroup = "fluids" },
	["bob-liquid-fuel"] = { type = "fluid", subgroup = "fluids" },
	["bob-ferric-chloride-solution"] = { type = "fluid", subgroup = "fluids" }, -- Shared with Bob's Electronics
	["bob-lithia-water"] = { type = "fluid", subgroup = "fluids", defer_to_data_updates = true }, -- Shared with Bob's Ores, Angels
	["bob-alien-acid"] = { type = "fluid", subgroup = "fluids" },
	["bob-alien-explosive"] = { type = "fluid", subgroup = "fluids" },
	["bob-alien-fire"] = { type = "fluid", subgroup = "fluids" },
	["bob-alien-poison"] = { type = "fluid", subgroup = "fluids" },

	-- Miscellaneous Items
	["bob-silicon-wafer"] = { mod = "lib", group = "shared", subgroup = "items", image = "silicon-wafer" },
	["bob-silicon-plate"] = { subgroup = "items", image = "silicon" },
	["bob-glass"] = { mod = "lib", group = "shared", subgroup = "items", image = "glass" },
	["bob-carbon"] = { subgroup = "items" },
	["bob-rubber"] = { mod = "lib", group = "shared", subgroup = "items", image = "rubber" }, -- Shared with Bob's Electronics, Angels
	["bob-resin"] = { subgroup = "items" }, -- Shared with Bob's Electronics
	["bob-enriched-fuel"] = { subgroup = "items" },
	["bob-grinding-wheel"] = { subgroup = "items", image = "grinding-wheel" },
	["bob-polishing-wheel"] = { subgroup = "items", image = "polishing-wheel" },
	["bob-polishing-compound"] = { subgroup = "items", image = "polishing-compound" },

	-- Powders -- TODO: https://github.com/kirazy/reskins-bobs/issues/31 Model and render out powder/particulate icons
	["bob-calcium-chloride"] = { subgroup = "powders" },
	["bob-sodium-hydroxide"] = { subgroup = "powders" },
	-- ["bob-lithium-chloride"] = {subgroup = "powders"}, -- Needs made-for-resolution icon
	-- ["bob-lithium-cobalt-oxide"] = {subgroup = "powders"}, -- Needs made-for-resolution icon
	-- ["bob-lithium-perchlorate"] = {subgroup = "powders"}, -- Needs made-for-resolution icon
	["bob-salt"] = { subgroup = "powders" },
	["bob-silicon-carbide"] = { subgroup = "powders" },
	["bob-silicon-nitride"] = { subgroup = "powders" },
	["bob-silicon-powder"] = { subgroup = "powders", defer_to_data_updates = true },
	-- ["bob-silver-oxide"] = {subgroup = "powders"}, -- Needs made-for-resolution icon

	-- Gemstones
	["bob-ruby-5"] = { subgroup = "gems", image = "ruby-5" },
	["bob-sapphire-5"] = { subgroup = "gems", image = "sapphire-5" },
	["bob-emerald-5"] = { subgroup = "gems", image = "emerald-5" },
	["bob-amethyst-5"] = { subgroup = "gems", image = "amethyst-5" },
	["bob-topaz-5"] = { subgroup = "gems", image = "topaz-5" },
	["bob-diamond-5"] = { subgroup = "gems", image = "diamond-5" },
}

-- Separate so that items and recipes with the same name can be handled differently.
local recipes = {
	-- Plates
	["bob-cobalt-oxide-from-copper"] = { type = "recipe", subgroup = "recipes" },
	["bob-silver-from-lead"] = { type = "recipe", subgroup = "recipes" },

	-- Nuclear
	["bob-thorium-processing"] = { type = "recipe", subgroup = "recipes" },
	["bob-thorium-fuel-reprocessing"] = { type = "recipe", subgroup = "recipes" },
	["bob-deuterium-fuel-reprocessing"] = { type = "recipe", subgroup = "recipes", image = "bob-deuterium-fuel-reprocessing-pink" },
	["bobingabout-enrichment-process"] = { type = "recipe", subgroup = "recipes" },

	-- Solid Fuels
	["bob-solid-fuel-from-hydrogen"] = { type = "recipe", subgroup = "recipes" },
	["bob-solid-fuel-from-sour-gas"] = { type = "recipe", subgroup = "recipes" }, -- Shared with Bob's Revamp
	["bob-enriched-fuel"] = { type = "recipe", subgroup = "recipes" },
	["bob-enriched-fuel-from-hydrazine"] = { type = "recipe", subgroup = "recipes" },

	-- Chemicals and Fluids
	-- ["sulfuric-nitric-acid"] = {type = "recipe", subgroup = "recipes"},
	-- ["pure-water"] = {type = "recipe", subgroup = "recipes"},
	-- ["pure-water-from-lithia"] = {type = "recipe", subgroup = "recipes"},
	["coal-cracking"] = { type = "recipe", subgroup = "recipes" }, -- Shared with Bob's Electronics
	["bob-petroleum-gas-cracking"] = { type = "recipe", subgroup = "recipes" },

	-- Wood
	["bob-resin-wood"] = { type = "recipe", subgroup = "recipes" }, -- Shared with Bob's Electronics
	["bob-resin-oil"] = { type = "recipe", subgroup = "recipes" }, -- Shared with Bob's Electronics
	["bob-synthetic-wood"] = { type = "recipe", subgroup = "recipes" }, -- Shared with Bob's Electronics
}

-- Advanced processing unit absent Bob's Electronics
if not mods["bobelectronics"] then
	intermediates["bob-advanced-processing-unit"] = { subgroup = "items" }
end

-- Handle deuterium color
if reskins.lib.settings.get_value("bobmods-plates-bluedeuterium") == true then
	intermediates["bob-deuterium-fuel-cell"].image = "bob-deuterium-fuel-cell-blue"
	intermediates["bob-deuterium-fuel-cell-2"].image = "bob-deuterium-fuel-cell-2-blue"
	intermediates["bob-depleted-deuterium-fuel-cell"].image = "bob-depleted-deuterium-fuel-cell-blue"
end

-- Handle nuclear update
if reskins.lib.settings.get_value("bobmods-plates-nuclearupdate") == true then
	recipes["nuclear-fuel-reprocessing"] = { type = "recipe", subgroup = "recipes", defer_to_data_updates = true }

	-- Handle deuterium's default process color
	if reskins.lib.settings.get_value("bobmods-plates-bluedeuterium") == true then
		recipes["bob-deuterium-fuel-reprocessing"].image = "bob-deuterium-fuel-reprocessing-blue"
	end
else
	recipes["bob-thorium-fuel-reprocessing"].image = "bob-thorium-fuel-reprocessing-alternate"

	-- Handle deuterium's alternate process color
	if reskins.lib.settings.get_value("bobmods-plates-bluedeuterium") == true then
		recipes["bob-deuterium-fuel-reprocessing"].image = "bob-deuterium-fuel-reprocessing-alternate-blue"
	else
		recipes["bob-deuterium-fuel-reprocessing"].image = "bob-deuterium-fuel-reprocessing-alternate-pink"
	end
end

reskins.internal.create_icons_from_list(intermediates, inputs)
reskins.internal.create_icons_from_list(recipes, inputs)

-- One-off fixes
if data.raw.item["bob-nickel-plate"] then
	reskins.lib.icons.clear_icon_from_prototype_by_name("bob-bob-nickel-plate", "recipe")
end
if data.raw.fluid["bob-liquid-air"] then
	reskins.lib.icons.clear_icon_from_prototype_by_name("bob-liquid-air", "recipe")
end
if data.raw.item["bob-lead-oxide"] then
	reskins.lib.icons.clear_icon_from_prototype_by_name("bob-lead-oxide-2", "recipe")
end
