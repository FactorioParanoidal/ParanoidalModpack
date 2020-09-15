--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * shortcuts.lua
 * Shortcuts and mod compatibility
--]]

-- This code has been modified by ickputzdirwech.

if settings.startup["tree-killer"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "tree-killer",
			order = "b[blueprint]-g[tree-killer]",
			action = "lua",
			localised_name = {"", {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.whitelist-trees-and-rocks"}, ")"},
			technology_to_unlock = "construction-robotics",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/tree-killer-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/tree-killer-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/tree-killer-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end
