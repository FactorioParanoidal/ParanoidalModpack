--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of startup-blueprint.lua
	* Deconstruction planner Environment
]]

data:extend({{
	setting_type = "startup",
	name = "tree-killer",
	localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.deconstruction-planner"}, " ", {"item-group-name.environment"}},
	order = "b[blueprint]-g[tree-killer]",
	type = "bool-setting",
	default_value = true
}})
