--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-blueprint.lua:
	* Tree killer
		- Tree killer deconstruction planner.
		- Environment shortcut.
		- Trees/rocks shortcut.
		- Cliff/Fish/Item on ground shortcut.
	* WellPlanner shortcut.
]]

local deconstruction_planner = ""
local well_planner = ""
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]"}
	deconstruction_planner = tag
	well_planner = tag
elseif settings.startup["ick-tags"].value == "icons" then
	deconstruction_planner = "[img=entity/tree-01] "
	well_planner = "[img=item/well-planner] "
end


-- TREE KILLER
local tree_killer = settings.startup["tree-killer"].value

if tree_killer == "all-in-one" or tree_killer == "both" or tree_killer == "trees-rocks" or tree_killer == "cliff-fish" then

	local decon_tree = util.table.deepcopy(data.raw["deconstruction-item"]["deconstruction-planner"])
		decon_tree.name = "tree-killer"
		decon_tree.localised_name = {"", {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.trees-and-rocks-only"}, ")"}
		decon_tree.flags = {"only-in-cursor", "hidden"}
		decon_tree.entity_filter_count = 255
	data:extend({decon_tree})

end


if tree_killer == "all-in-one" then
	data:extend(
	{
		{
			type = "shortcut",
			name = "environment-killer",
			localised_name = {"", deconstruction_planner, {"item-name.deconstruction-planner"}, " (", {"item-group-name.environment"}, ")"},
			order = "b[blueprint]-g[environment-killer]",
			--associated_control_input = "environment-killer",
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
			}
		}
	})
end


if tree_killer == "both" or tree_killer == "trees-rocks" then
	data:extend(
	{
		{
			type = "shortcut",
			name = "tree-killer",
			localised_name = {"", deconstruction_planner, {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.trees-and-rocks-only"}, ")"},
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
			}
		}
	})
end

if tree_killer == "both" or tree_killer == "cliff-fish" then
	data:extend(
		{
			{
			type = "shortcut",
			name = "cliff-fish-item-on-ground",
			localised_name = {"", deconstruction_planner, {"item-name.deconstruction-planner"}, " (", {"entity-name.cliff"}, "/", {"entity-name.fish"}, "/", {"entity-name.item-on-ground"}, ")"},
			order = "b[blueprint]-h[tree-killer]",
			--associated_control_input = "cliff-fish-item-on-ground",
			action = "lua",
			technology_to_unlock = "construction-robotics",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/cliff-fish-item-on-ground-x32-white-new.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			}
		}
	})
end


-- WELL PLANNER
if settings.startup["well-planner"] and settings.startup["well-planner"].value and data.raw["selection-tool"]["well-planner"] then
	data:extend(
	{
		{
			type = "shortcut",
			name = "well-planner",
			localised_name = {"", well_planner, {"item-name.well-planner"}},
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
			}
		}
	})
end
