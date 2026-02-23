-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "angels",
	group = "smelting",
	type = "technology",
	technology_icon_size = 256,
}

---@param material string
---@return CreateIconsFromListOverrides
local function get_casting_overrides(material)
	---@type CreateIconsFromListOverrides
	local override = {
		subgroup = "casting",
		flat_icon = true,
		image = "casting-" .. material .. "-technology-icon",
	}

	return override
end

---@param material string
---@return CreateIconsFromListOverrides
local function get_smelting_overrides(material)
	---@type CreateIconsFromListOverrides
	local override = {
		subgroup = "smelting",
		flat_icon = true,
		image = "smelting-" .. material .. "-technology-icon",
	}

	return override
end

---@type CreateIconsFromListTable
local technologies = {
	-- Metallurgy
	["angels-metallurgy-1"] = { tier = 1, icon_name = "metallurgy" },
	["angels-metallurgy-2"] = { tier = 2, icon_name = "metallurgy" },
	["angels-metallurgy-3"] = { tier = 3, icon_name = "metallurgy" },
	["angels-metallurgy-4"] = { tier = 4, icon_name = "metallurgy" },
	["angels-metallurgy-5"] = { tier = 5, icon_name = "metallurgy" },

	-- Strand Casting
	["angels-strand-casting-1"] = { tier = 1, prog_tier = 2, icon_name = "strand-casting" },
	["angels-strand-casting-2"] = { tier = 2, prog_tier = 3, icon_name = "strand-casting" },
	["angels-strand-casting-3"] = { tier = 3, prog_tier = 4, icon_name = "strand-casting" },
	["angels-strand-casting-4"] = { tier = 4, prog_tier = 5, icon_name = "strand-casting" },

	-- Ore Processing
	["angels-ore-processing-1"] = { tier = 1, prog_tier = 2, icon_name = "ore-processing-machine" },
	["angels-ore-processing-2"] = { tier = 1, prog_tier = 3, icon_name = "pellet-press" },
	["angels-ore-processing-3"] = { tier = 2, prog_tier = 4, icon_name = "pellet-press" },
	["angels-ore-processing-4"] = { tier = 3, prog_tier = 5, icon_name = "pellet-press" },
	["angels-ore-processing-5"] = { tier = 4, prog_tier = 6, icon_name = "pellet-press" },

	-- Smelting
	["angels-solder-smelting-basic"] = get_casting_overrides("solder"),

	["angels-copper-smelting-1"] = get_casting_overrides("copper"),
	["angels-copper-smelting-2"] = get_smelting_overrides("copper"),
	["angels-copper-casting-2"] = get_casting_overrides("copper"),
	["angels-copper-smelting-3"] = get_smelting_overrides("copper"),
	["angels-copper-casting-3"] = get_casting_overrides("copper"),

	["angels-iron-smelting-1"] = get_casting_overrides("iron"),
	["angels-iron-smelting-2"] = get_smelting_overrides("iron"),
	["angels-iron-casting-2"] = get_casting_overrides("iron"),
	["angels-iron-smelting-3"] = get_smelting_overrides("iron"),
	["angels-iron-casting-3"] = get_casting_overrides("iron"),

	["angels-lead-smelting-1"] = get_casting_overrides("lead"),
	["angels-lead-smelting-2"] = get_smelting_overrides("lead"),
	["angels-lead-casting-2"] = get_casting_overrides("lead"),
	["angels-lead-smelting-3"] = get_smelting_overrides("lead"),
	["angels-lead-casting-3"] = get_casting_overrides("lead"),

	["angels-nickel-smelting-1"] = get_casting_overrides("nickel"),
	["angels-nickel-smelting-2"] = get_smelting_overrides("nickel"),
	["angels-nickel-casting-2"] = get_casting_overrides("nickel"),
	["angels-nickel-smelting-3"] = get_smelting_overrides("nickel"),
	["angels-nickel-casting-3"] = get_casting_overrides("nickel"),

	["angels-silicon-smelting-1"] = get_casting_overrides("silicon"),
	["angels-silicon-smelting-2"] = get_smelting_overrides("silicon"),
	["angels-silicon-casting-2"] = get_casting_overrides("silicon"),
	["angels-silicon-smelting-3"] = get_smelting_overrides("silicon"),
	["angels-silicon-casting-3"] = get_casting_overrides("silicon"),

	["angels-solder-smelting-1"] = get_casting_overrides("solder"),
	["angels-solder-smelting-2"] = get_casting_overrides("solder"),
	["angels-solder-smelting-3"] = get_casting_overrides("solder"),

	["angels-tin-smelting-1"] = get_casting_overrides("tin"),
	["angels-tin-smelting-2"] = get_smelting_overrides("tin"),
	["angels-tin-casting-2"] = get_casting_overrides("tin"),
	["angels-tin-smelting-3"] = get_smelting_overrides("tin"),
	["angels-tin-casting-3"] = get_casting_overrides("tin"),

	["angels-aluminium-smelting-1"] = get_casting_overrides("aluminium"),
	["angels-aluminium-smelting-2"] = get_smelting_overrides("aluminium"),
	["angels-aluminium-casting-2"] = get_casting_overrides("aluminium"),
	["angels-aluminium-smelting-3"] = get_smelting_overrides("aluminium"),
	["angels-aluminium-casting-3"] = get_casting_overrides("aluminium"),

	["angels-cobalt-smelting-1"] = get_casting_overrides("cobalt"),
	["angels-cobalt-smelting-2"] = get_smelting_overrides("cobalt"),
	["angels-cobalt-casting-2"] = get_casting_overrides("cobalt"),
	["angels-cobalt-smelting-3"] = get_smelting_overrides("cobalt"),
	["angels-cobalt-casting-3"] = get_casting_overrides("cobalt"),

	["angels-gold-smelting-1"] = get_casting_overrides("gold"),
	["angels-gold-smelting-2"] = get_smelting_overrides("gold"),
	["angels-gold-casting-2"] = get_casting_overrides("gold"),
	["angels-gold-smelting-3"] = get_smelting_overrides("gold"),
	["angels-gold-casting-3"] = get_casting_overrides("gold"),

	["angels-glass-smelting-1"] = get_casting_overrides("glass"),
	["angels-glass-smelting-2"] = get_casting_overrides("glass"),
	["angels-glass-smelting-3"] = get_casting_overrides("glass"),

	["angels-manganese-smelting-1"] = get_casting_overrides("manganese"),
	["angels-manganese-smelting-2"] = get_smelting_overrides("manganese"),
	["angels-manganese-casting-2"] = get_casting_overrides("manganese"),
	["angels-manganese-smelting-3"] = get_smelting_overrides("manganese"),
	["angels-manganese-casting-3"] = get_casting_overrides("manganese"),

	["angels-silver-smelting-1"] = get_casting_overrides("silver"),
	["angels-silver-smelting-2"] = get_smelting_overrides("silver"),
	["angels-silver-casting-2"] = get_casting_overrides("silver"),
	["angels-silver-smelting-3"] = get_smelting_overrides("silver"),
	["angels-silver-casting-3"] = get_casting_overrides("silver"),

	["angels-steel-smelting-1"] = get_casting_overrides("steel"),
	["angels-steel-smelting-2"] = get_casting_overrides("steel"),
	["angels-steel-smelting-3"] = get_casting_overrides("steel"),

	["angels-zinc-smelting-1"] = get_casting_overrides("zinc"),
	["angels-zinc-smelting-2"] = get_smelting_overrides("zinc"),
	["angels-zinc-casting-2"] = get_casting_overrides("zinc"),
	["angels-zinc-smelting-3"] = get_smelting_overrides("zinc"),
	["angels-zinc-casting-3"] = get_casting_overrides("zinc"),

	["angels-chrome-smelting-1"] = get_casting_overrides("chrome"),
	["angels-chrome-smelting-2"] = get_smelting_overrides("chrome"),
	["angels-chrome-casting-2"] = get_casting_overrides("chrome"),
	["angels-chrome-smelting-3"] = get_smelting_overrides("chrome"),
	["angels-chrome-casting-3"] = get_casting_overrides("chrome"),

	["angels-platinum-smelting-1"] = get_casting_overrides("platinum"),
	["angels-platinum-smelting-2"] = get_smelting_overrides("platinum"),
	["angels-platinum-casting-2"] = get_casting_overrides("platinum"),
	["angels-platinum-smelting-3"] = get_smelting_overrides("platinum"),
	["angels-platinum-casting-3"] = get_casting_overrides("platinum"),

	["angels-titanium-smelting-1"] = get_casting_overrides("titanium"),
	["angels-titanium-smelting-2"] = get_smelting_overrides("titanium"),
	["angels-titanium-casting-2"] = get_casting_overrides("titanium"),
	["angels-titanium-smelting-3"] = get_smelting_overrides("titanium"),
	["angels-titanium-casting-3"] = get_casting_overrides("titanium"),
}

-- Powder Metallurgy
if angelsmods.trigger.early_sintering_oven then
	technologies["angels-powder-metallurgy-1"] = { tier = 1, prog_tier = 1, icon_name = "powder-metallurgy", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-2"] = { tier = 2, prog_tier = 2, icon_name = "powder-metallurgy", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-3"] = { tier = 3, prog_tier = 3, icon_name = "powder-metallurgy", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-4"] = { tier = 4, prog_tier = 4, icon_name = "powder-metallurgy", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-5"] = { tier = 5, prog_tier = 5, icon_name = "powder-metallurgy", defer_to_data_updates = true }
else
	technologies["angels-powder-metallurgy-2"] = { tier = 1, prog_tier = 2, icon_name = "powder-metallurgy-special-vanilla", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-3"] = { tier = 2, prog_tier = 3, icon_name = "powder-metallurgy-special-vanilla", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-4"] = { tier = 3, prog_tier = 4, icon_name = "powder-metallurgy", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-5"] = { tier = 4, prog_tier = 5, icon_name = "powder-metallurgy", defer_to_data_updates = true }
end

-- Check for special vanilla and override the powder metallurgy technology icons
if angelsmods and angelsmods.functions.is_special_vanilla() then
	technologies["angels-powder-metallurgy-2"] = { tier = 1, prog_tier = 2, icon_name = "powder-metallurgy-special-vanilla", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-3"] = { tier = 2, prog_tier = 3, icon_name = "powder-metallurgy-special-vanilla", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-4"] = { tier = 3, prog_tier = 4, icon_name = "powder-metallurgy-special-vanilla", defer_to_data_updates = true }
	technologies["angels-powder-metallurgy-5"] = { tier = 4, prog_tier = 5, icon_name = "powder-metallurgy-special-vanilla", defer_to_data_updates = true }
end

-- Check if we're using Angel's material colors
if reskins.lib.settings.get_value("reskins-angels-use-angels-material-colors") then
	technologies["bob-armor-making-4"] = { subgroup = "armor", flat_icon = true }
	technologies["bob-power-armor-4"] = { subgroup = "armor", flat_icon = true }
	technologies["bob-power-armor-5"] = { subgroup = "armor", flat_icon = true }
end

reskins.internal.create_icons_from_list(technologies, inputs)
