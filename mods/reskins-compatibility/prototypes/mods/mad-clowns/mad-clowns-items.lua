-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.mad_clowns.is_active) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "compatibility",
	group = "mad-clowns",
	make_icon_pictures = false,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local intermediates = {
	------------------------------------------------------------------------------------------------
	-- Intermediates
	------------------------------------------------------------------------------------------------
	["processed-depleted-uranium"] = { subgroup = "processed-ores" },
	["processed-magnesium"] = { subgroup = "processed-ores" },
	["processed-osmium"] = { subgroup = "processed-ores" },

	["powder-depleted-uranium"] = { subgroup = "powders/depleted-uranium" },
	["casting-powder-depleted-uranium"] = { subgroup = "powders/depleted-uranium-mixture", image = "powder-depleted-uranium-mixture" },
	["powder-osmium"] = { subgroup = "powders/osmium" },
	["casting-powder-osmium"] = { subgroup = "powders/osmium-mixture", image = "powder-osmium-mixture" },

	["clowns-plate-depleted-uranium"] = { subgroup = "plates" },
	["clowns-plate-magnesium"] = { subgroup = "plates" },
	["clowns-plate-osmium"] = { subgroup = "plates" },

	["angels-liquid-molten-magnesium"] = { type = "fluid", subgroup = "liquid-material" },

	["pellet-depleted-uranium"] = { subgroup = "pellets" },
	["pellet-magnesium"] = { subgroup = "pellets" },
	["pellet-osmium"] = { subgroup = "pellets" },

	["ingot-magnesium"] = { subgroup = "ingots/magnesium" },

	------------------------------------------------------------------------------------------------
	-- Recipes
	------------------------------------------------------------------------------------------------
	["pellet-magnesium-titanium-smelting"] = { type = "recipe", mod = "angels", group = "smelting", subgroup = "ingots/titanium", image = "ingot-titanium", icon_extras = reskins.angels.num_tier(3, "smelting") },

	["casting-powder-depleted-uranium-1"] = { type = "recipe", subgroup = "powders/depleted-uranium-mixture", image = "powder-depleted-uranium-mixture", icon_extras = reskins.angels.num_tier(1, "smelting") },
	["casting-powder-depleted-uranium-2"] = { type = "recipe", subgroup = "powders/depleted-uranium-mixture", image = "powder-depleted-uranium-mixture", icon_extras = reskins.angels.num_tier(2, "smelting") },

	-- ["molten-aluminium-smelting-3"] = {type = "recipe", mod = "angels", group = "smelting", subgroup = "liquid-material", image = "angels-liquid-molten-aluminium", icon_extras = reskins.angels.num_tier(4, "smelting")},
	-- ["molten-aluminium-smelting-4"] = {type = "recipe", mod = "angels", group = "smelting", subgroup = "liquid-material", image = "angels-liquid-molten-aluminium", icon_extras = reskins.angels.num_tier(3, "smelting")},
	-- ["molten-aluminium-smelting-5"] = {type = "recipe", mod = "angels", group = "smelting", subgroup = "liquid-material", image = "angels-liquid-molten-aluminium", icon_extras = reskins.angels.num_tier(5, "smelting")},

	-- ["molten-iron-smelting-6"] = {type = "recipe", mod = "angels", group = "smelting", subgroup = "liquid-material", image = "angels-liquid-molten-iron", icon_extras = reskins.angels.num_tier(6, "smelting")},

	-- ["angels-brass-smelting-4"] = {type = "recipe", mod = "angels", group = "smelting", subgroup = "liquid-material", image = "angels-liquid-molten-brass", icon_extras = reskins.angels.num_tier(4, "smelting")},

	["magnesium-pellet-smelting"] = { type = "recipe", subgroup = "ingots/magnesium", image = "ingot-magnesium" },
}

reskins.internal.create_icons_from_list(intermediates, inputs)

-- local composite_recipes = {}

-- for name, sources in pairs(composite_recipes) do
--     reskins.lib.composite_existing_icons(name, "recipe", sources)
-- end

-- Make variations for ingots
if reskins.lib.settings.get_value("reskins-angels-use-item-variations") then
	local ingot_variations = {
		"magnesium",
	}

	for _, ingot in pairs(ingot_variations) do
		local item = data.raw.item["ingot-" .. ingot]
		if not item then
			goto continue
		end

		-- Setup initial pictures table with primary icon
		item.pictures = {
			{
				filename = "__reskins-compatibility__/graphics/icons/mad-clowns/ingots/" .. ingot .. "/ingot-" .. ingot .. ".png",
				flags = { "icon" },
				size = 64,
				mipmap_count = 4,
				scale = 0.25,
			},
		}

		for i = 1, 8, 1 do
			table.insert(item.pictures, {
				filename = "__reskins-compatibility__/graphics/icons/mad-clowns/ingots/" .. ingot .. "/ingot-" .. ingot .. "-" .. i .. ".png",
				flags = { "icon" },
				size = 64,
				mipmap_count = 4,
				scale = 0.25,
			})
		end

		::continue::
	end
end

-- Make variations for powders
local powder_variations = {
	["powder-depleted-uranium"] = "depleted-uranium",
	["casting-powder-depleted-uranium"] = "depleted-uranium-mixture",
	["powder-osmium"] = "osmium",
	["casting-powder-osmium"] = "osmium-mixture",
}

for powder, material in pairs(powder_variations) do
	local item = data.raw.item[powder]
	if not item then
		goto continue
	end

	-- Setup initial pictures table
	item.pictures = {}

	for i = 1, 6, 1 do
		table.insert(item.pictures, {
			filename = "__reskins-compatibility__/graphics/icons/mad-clowns/powders/" .. material .. "/powder-" .. material .. "-" .. i .. ".png",
			flags = { "icon" },
			size = 64,
			mipmap_count = 4,
			scale = 0.25,
		})
	end

	::continue::
end
