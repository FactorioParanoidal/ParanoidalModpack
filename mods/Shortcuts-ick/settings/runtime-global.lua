--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of runtime-global.lua
	* Enable Emergency locator beacon
	* Enable Zoom out of world
	* Prepare a startup setting change or uninstallation
]]

data:extend(
{
	{
		setting_type = "runtime-global",
		name = "disable-flare",
		localised_name = {"", {"gui-sync-mods-with-save.enable"}, " ", {"Shortcuts-ick.signal-flare"}},
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "runtime-global",
		name = "disable-zoom",
		localised_name = {"", {"gui-sync-mods-with-save.enable"}, " ", {"controls.alt-zoom-out"}},
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "runtime-global",
		name = "ick-prepare-uninstall",
		localised_description = {"mod-setting-description.ick-prepare-uninstall", {"Shortcuts-ick.artillery-toggle"}, {"equipment-name.personal-laser-defense-equipment"}, {"item-name.belt-immunity-equipment"}, {"technology-name.night-vision-equipment"}},
		type = "string-setting",
		allow_blank = true,
		default_value = ""
	}
})