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
	group = "industries",
	make_icon_pictures = false,
	flat_icon = true,
}

-- Check to see if reskinning needs to be done.
if not mods["angelspetrochem"] then
	return
end

---@param light_name LightSpriteNames
---@return CreateIconsFromListOverrides
local function get_fuel_overrides(light_name)
	---@type CreateIconsFromListOverrides
	local override = {
		subgroup = "nuclear",
		make_icon_pictures = true,
		icon_picture_extras = {
			reskins.lib.sprites.get_sprite_light_layer(light_name),
		},
	}

	return override
end

---@param name string
---@return CreateIconsFromListOverrides
local function get_isotope_overrides(name)
	---@type CreateIconsFromListOverrides
	local override = {
		subgroup = "nuclear",
		make_icon_pictures = true,
		icon_picture_extras = {
			{
				filename = "__reskins-angels__/graphics/icons/industries/nuclear/" .. name .. ".png",
				flags = { "icon" },
				size = 64,
				tint = { r = 0.3, g = 0.3, b = 0.3, a = 0.3 },
				mipmap_count = 4,
				draw_as_light = true,
				blend_mode = "additive",
				scale = 0.5,
			},
		},
	}

	return override
end

---@type CreateIconsFromListTable
local intermediates = {
	----------------------------------------------------------------------------------------------------
	-- Intermediates
	----------------------------------------------------------------------------------------------------
	-- Nuclear fuel cells
	["angels-deuterium-fuel-cell"] = get_fuel_overrides("fuel-cell"),
	["angels-mixed-oxide-cell"] = util.merge({ { image = "AMOX-cell" }, get_fuel_overrides("fuel-cell") }),
	["angels-thorium-fuel-cell"] = get_fuel_overrides("fuel-cell"),
	["angels-uranium-fuel-cell"] = get_fuel_overrides("fuel-cell"),
	["uranium-fuel-cell"] = get_fuel_overrides("fuel-cell"),

	-- Nuclear fuel
	["angels-nuclear-fuel"] = get_fuel_overrides("fuel"),
	["angels-nuclear-fuel-2"] = get_fuel_overrides("fuel"),

	-- Nuclear isotopes
	["angels-americium-241"] = util.merge({ { image = "americium-241" }, get_isotope_overrides("americium-241") }),
	["angels-curium-245"] = util.merge({ { image = "curium-245" }, get_isotope_overrides("curium-245") }),
	["angels-neptunium-240"] = util.merge({ { image = "neptunium-240" }, get_isotope_overrides("neptunium-240") }),
	["bob-plutonium-239"] = util.merge({ { image = "plutonium-240" }, get_isotope_overrides("plutonium-240") }),
	["bob-thorium-232"] = util.merge({ { image = "thorium-232" }, get_isotope_overrides("thorium-232") }),
	["angels-uranium-234"] = util.merge({ { image = "uranium-234" }, get_isotope_overrides("uranium-234") }),
	["uranium-235"] = get_isotope_overrides("uranium-235"),
}

reskins.internal.create_icons_from_list(intermediates, inputs)
