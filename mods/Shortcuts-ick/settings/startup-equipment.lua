--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of startup-equipment.lua
	* Belt immunity equipment
	* Nightvision
	* Personal laser defense
]]

data:extend(
{
	{
		setting_type = "startup",
		name = "belt-immunity-equipment",
		localised_name = {"", {"Shortcuts-ick.equipment"}, {"item-name.belt-immunity-equipment"}},
		order = "c[equipment]-c[belt-immunity-equipment]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "night-vision-equipment",
		localised_name = {"", {"Shortcuts-ick.equipment"}, {"technology-name.night-vision-equipment"}},
		order = "c[equipment]-e[night-vision-equipment]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "active-defense-equipment",
		localised_name = {"", {"Shortcuts-ick.equipment"}, {"equipment-name.personal-laser-defense-equipment"}},
		order = "c[equipment]-f[active-defense-equipment]",
		type = "bool-setting",
		default_value = true
	}
})
