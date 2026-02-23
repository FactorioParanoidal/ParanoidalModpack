--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of startup-artillery.lua
	* Artillery cannon toggle
]]

data:extend({{
	setting_type = "startup",
	name = "artillery-toggle",
	localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"Shortcuts-ick.artillery-toggle"}},
	order = "d[artillery]-a[artillery-jammer-tool]",
	type = "string-setting",
	allowed_values = {"disabled", "both", "artillery-wagon", "artillery-turret"},
	default_value = "both"
}})
