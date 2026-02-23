--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of startup-other.lua
	* Disable all technology requirement changes
	* Choose whether you want tags or icons
]]

data:extend(
{
	{
		setting_type = "startup",
		name = "ick-compatibility-mode",
		localised_name = {"", "[color=yellow]", {"gui-menu.other"}, ": [/color]", {"Shortcuts-ick.compatibility-mode"}},
		order = "f[other]-b[compatibility-mode]",
		type = "bool-setting",
		default_value = false
	},
	{
		setting_type = "startup",
		name = "ick-tags",
		localised_name = {"", "[color=yellow]", {"gui-menu.other"}, ": [/color]", {"Shortcuts-ick.tags"}},
		order = "f[other]-c[autogen-color]",
		type = "string-setting",
		allowed_values = {"disabled", "tags", "icons"},
		default_value = "tags"
	}
})
