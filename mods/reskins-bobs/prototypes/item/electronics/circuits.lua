-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobelectronics"] then
	return
end
if not reskins.lib.settings.get_value("reskins-bobs-do-bobelectronics-colored-circuits") then
	return
end

local circuit_map = {
	["bob-basic-circuit-board"] = { tier = 1, image_name = "basic-circuit-board" },
	["electronic-circuit"] = { tier = 2, image_name = "basic-electronic-circuit-board" },
	["advanced-circuit"] = { tier = 3, image_name = "electronic-circuit-board" },
	["processing-unit"] = { tier = 4, image_name = "electronic-logic-board" },
	["bob-advanced-processing-unit"] = { tier = 5, image_name = "electronic-processing-board" },

	["bob-circuit-board"] = { tier = 3, image_name = "circuit-board" },
	["bob-superior-circuit-board"] = { tier = 4, image_name = "superior-circuit-board" },
	["bob-multi-layer-circuit-board"] = { tier = 5, image_name = "multi-layer-circuit-board" },
}

local do_custom_color = reskins.lib.settings.get_value("reskins-lib-customize-tier-colors")

---Gets a pre-rendered colored circuit icon assignable to the item prototype with the given `prototype_name`.
---@param prototype_name data.ItemID The name of the item prototype associated with the icon.
---@param icon_name string The name of the icon without extension or suffixes.
---@return DeferrableIconDatum
local function get_rendered_circuit_icon(prototype_name, icon_name)
	---@type DeferrableIconDatum
	local deferrable_icon = {
		name = prototype_name,
		type_name = "item",
		icon_datum = {
			icon = "__reskins-bobs__/graphics/icons/electronics/circuits-rendered/" .. icon_name .. ".png",
			icon_size = 64,
		},
	}

	return deferrable_icon
end

---Gets a tinted colored circuit icon assignable to the item prototype with the given `prototype_name`.
---@param prototype_name data.ItemID The name of the item prototype associated with the icon.
---@param icon_name string The name of the icon without extension or suffixes.
---@return DeferrableIconData
local function get_tinted_circuit_icon(prototype_name, icon_name, tier)
	---@type DeferrableIconData
	local deferrable_icon = {
		name = prototype_name,
		type_name = "item",
		icon_data = {
			{
				icon = "__reskins-bobs__/graphics/icons/electronics/circuits-tintable/" .. icon_name .. "/" .. icon_name .. "-icon-base.png",
				icon_size = 64,
				tint = util.get_color_with_alpha(reskins.lib.tiers.get_tint(tier), 1),
			},
			{
				icon = "__reskins-bobs__/graphics/icons/electronics/circuits-tintable/" .. icon_name .. "/" .. icon_name .. "-icon-highlights.png",
				icon_size = 64,
				tint = { 1, 1, 1, 0 },
			},
			{
				icon = "__reskins-bobs__/graphics/icons/electronics/circuits-tintable/" .. icon_name .. "/" .. icon_name .. "-traces.png",
				icon_size = 64,
			},
		},
	}

	return deferrable_icon
end

for name, data in pairs(circuit_map) do
	local deferrable_icon = do_custom_color and get_tinted_circuit_icon(name, data.image_name, data.tier) or get_rendered_circuit_icon(name, data.image_name)

	reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
end
