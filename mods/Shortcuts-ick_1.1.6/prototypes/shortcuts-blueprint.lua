--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio.
 * This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-blueprint.lua:
	* Trees/rocks only item, shortcut and custom input
	* Cliff/Fish/Item on ground shortcut and custom input
	* OutpostPlanner shortcut and custom input
	* WellPlanner shortcut and custom input
]]

if settings.startup["tree-killer"].value == true then

	local decon_tree = util.table.deepcopy(data.raw["deconstruction-item"]["deconstruction-planner"])
	decon_tree.name = "tree-killer"
	decon_tree.localised_name =  {"", {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.trees-and-rocks-only"}, ")"}
	decon_tree.flags = {"only-in-cursor", "hidden"}
	data:extend({decon_tree})

	data:extend(
	{
		{
			type = "shortcut",
			name = "tree-killer",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.trees-and-rocks-only"}, ") ", {"Shortcuts-ick.control-tree-killer"}},
			order = "b[blueprint]-g[tree-killer]",
			--associated_control_input = "tree-killer",
			action = "lua",
			technology_to_unlock = "construction-robotics",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/tree-killer-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/tree-killer-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
	  {
			type = "custom-input",
	    name = "tree-killer",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.trees-and-rocks-only"}, ")"},
			order = "b[blueprint]-g[tree-killer]",
	    key_sequence = "",
	  },
		{
			type = "shortcut",
			name = "cliff-fish-item-on-ground",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.deconstruction-planner"}, " (", {"entity-name.cliff"}, "/", {"entity-name.fish"}, "/", {"entity-name.item-on-ground"}, ") ", {"Shortcuts-ick.control-cliff-fish-item-on-ground"}},
			order = "b[blueprint]-h[tree-killer]",
			--associated_control_input = "cliff-fish-item-on-ground",
			action = "lua",
			technology_to_unlock = "construction-robotics",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/cliff-fish-item-on-ground-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
	  {
			type = "custom-input",
	    name = "cliff-fish-item-on-ground",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.deconstruction-planner"}, " (", {"entity-name.cliff"}, "/", {"entity-name.fish"}, "/", {"entity-name.item-on-ground"}, ") "},
			order = "b[blueprint]-h[tree-killer]",
	    key_sequence = "",
	  },
	})
end

if (mods["OutpostPlanner"] or mods["OutpostPlannerUpdated"] or mods["OutpostPlanner1-1"]) and (mods["PlannerCore"] or mods["PlannerCore1-1"]) and data.raw["selection-tool"]["outpost-builder"] and settings.startup["outpost-builder"].value == true then

	local planner = data.raw["selection-tool"]["outpost-builder"]
	if planner.flags then
		table.insert(planner.flags, "spawnable")
	else
		planner.flags = {"spawnable"}
	end

	data:extend(
	{
		{
			type = "shortcut",
			name = "outpost-builder",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.outpost-builder"}, {"Shortcuts-ick.control-outpost-builder"}},
			order = "b[blueprint]-i[outpost-builder]",
			--associated_control_input = "outpost-builder",
			action = "spawn-item",
			item_to_spawn = "outpost-builder",
			style = "blue",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/outpost-builder-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/outpost-builder-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
		{
			type = "custom-input",
			name = "outpost-builder",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.outpost-builder"}},
			order = "b[blueprint]-i[outpost-builder]",
			action = "spawn-item",
			item_to_spawn = "outpost-builder",
			key_sequence = "",
		},
	})
end

if mods["WellPlanner"] and data.raw["selection-tool"]["well-planner"] and settings.startup["well-planner"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "well-planner",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.well-planner"}, {"Shortcuts-ick.control-well-planner"}},
			order = "b[blueprint]-j[well-planner]",
			--associated_control_input = "well-planner",
			action = "lua",
			icon =
			{
				filename = "__WellPlanner__/graphics/well-planner.png",
				priority = "extra-high-no-scale",
				size = 64,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
		{
			type = "custom-input",
			name = "well-planner",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.well-planner"}},
			order = "b[blueprint]-j[well-planner]",
			key_sequence = "",
		},
	})
end
