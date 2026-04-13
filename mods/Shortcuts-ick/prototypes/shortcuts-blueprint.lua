--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-blueprint.lua:
	* Environment deconstruction planner
		- Tree killer deconstruction planner.
		- Tree killer shortcut.
]]

-- TAGS
local deconstruction_planner
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]"}
	deconstruction_planner = tag
elseif settings.startup["ick-tags"].value == "icons" then
	deconstruction_planner = "[img=entity/tree-01] "
else
	deconstruction_planner = ""
end

-- ENVIRONMENT DECONSTRUCTION PLANNER
if settings.startup["tree-killer"].value then
	local tree_killer = util.table.deepcopy(data.raw["deconstruction-item"]["deconstruction-planner"])
		tree_killer.name = "tree-killer"
		tree_killer.localised_name = {"", {"item-group-name.environment"}, " ", {"item-name.deconstruction-planner"}}
		tree_killer.flags = {"only-in-cursor", "spawnable"}
		tree_killer.hidden = true
		tree_killer.entity_filter_count = 255

	data:extend({
		tree_killer,
		{
			type = "shortcut",
			name = "tree-killer",
			localised_name = {"", deconstruction_planner, {"item-group-name.environment"}, " ", {"item-name.deconstruction-planner"}},
			order = "b[blueprint]-g[tree-killer]",
			action = "lua",
			technology_to_unlock = "construction-robotics",
			style = "red",
			icon = "__Shortcuts-ick__/graphics/tree-killer-x32-white.png",
			icon_size = 32,
			small_icon = "__Shortcuts-ick__/graphics/tree-killer-x24-white.png",
			small_icon_size = 24
		}
	})
end
