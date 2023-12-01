--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of runtime-per-user.lua
	* Grid:
		- center
		- range
		- rendering layer
		- primary grid size
		- primary grid line width
		- secondary grid size
		- secondary grid line width
	* Zoom out of world: limit
	* Environment Deconstruction planner:
		- Trees
		- Rocks
		- Cliff
		- Fish
		- Item on ground
]]

data:extend(
{
	-- GRID
	{
		setting_type = "runtime-per-user",
		name = "grid-chunk-align",
		order = "a[grid]-a[chunk-align]",
		type = "string-setting",
		allowed_values = {"chunk", "player"},
		default_value = "chunk"
	},
	{
		setting_type = "runtime-per-user",
		name = "grid-radius",
		order = "a[grid]-b[radius]",
		type = "int-setting",
		default_value = 128,
		minimum_value = 1
	},
	{
		setting_type = "runtime-per-user",
		name = "grid-ground",
		order = "a[grid]-c[ground]",
		type = "string-setting",
		allowed_values = {"ground", "above"},
		default_value = "ground"
	},
	{
		setting_type = "runtime-per-user",
		name = "grid-chunk-size",
		order = "a[grid]-d[chunk-size]",
		type = "int-setting",
		default_value = 32,
		minimum_value = 1
	},
	{
		setting_type = "runtime-per-user",
		name = "grid-chunk-line-width",
		order = "a[grid]-e[chunk-line-width]",
		type = "double-setting",
		default_value = 5,
		minimum_value = 0.0,
		maximum_value = 32.0
	},
	{
		setting_type = "runtime-per-user",
		name = "grid-step",
		order = "a[grid]-f[step]",
		type = "int-setting",
		default_value = 1,
		minimum_value = 1
	},
	{
		setting_type = "runtime-per-user",
		name = "grid-line-width",
		order = "a[grid]-g[line-width]",
		type = "double-setting",
		default_value = 0.25,
		minimum_value = 0.0,
		maximum_value = 32.0
	},
	-- ZOOM OUT OF WORLD
	{
		setting_type = "runtime-per-user",
		name = "zoom-level",
		localised_name = {"", "[color=orange]", {"controls.alt-zoom-out"}, ":[/color] ", {"description.module-bonus-limit"}},
		order = "b[zoom]",
		type = "double-setting",
		default_value = 0.1,
		minimum_value = 0.0,
		maximum_value = 20.0
	},
	-- ENVIRONMENT DECONSTRUCTION PLANNER
	{
		setting_type = "runtime-per-user",
		name = "environment-killer-trees",
		localised_name = {"", "[color=blue]", {"item-group-name.environment"}, " ", {"item-name.deconstruction-planner"}, ":[/color] ", {"entity-name.tree-proxy"}},
		order = "c[environment]-a[trees]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "runtime-per-user",
		name = "environment-killer-rocks",
		order = "c[environment]-b[rocks]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "runtime-per-user",
		name = "environment-killer-cliff",
		localised_name = {"", "[color=blue]", {"item-group-name.environment"}, " ", {"item-name.deconstruction-planner"}, ":[/color] ", {"entity-name.cliff"}},
		order = "c[environment]-c[cliff]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "runtime-per-user",
		name = "environment-killer-fish",
		localised_name = {"", "[color=blue]", {"item-group-name.environment"}, " ", {"item-name.deconstruction-planner"}, ":[/color] ", {"entity-name.fish"}},
		order = "c[environment]-d[fish]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "runtime-per-user",
		name = "environment-killer-item",
		localised_name = {"", "[color=blue]", {"item-group-name.environment"}, " ", {"item-name.deconstruction-planner"}, ":[/color] ", {"entity-name.item-on-ground"}},
		order = "c[environment]-e[item]",
		type = "bool-setting",
		default_value = true
	}
})