--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * shortcuts.lua
 * Shortcuts and mod compatibility
--]]

-- This code has been modified by ickputzdirwech.

if settings.startup["flashlight-toggle"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "flashlight-toggle",
			order = "a[basic]-b[flashlight-toggle]",
			action = "lua",
			localised_name = {"", {"entity-name.character"}, " ", {"entity-name.small-lamp"}},
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/flashlight-toggle-x32.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/flashlight-toggle-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/flashlight-toggle-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end

if settings.startup["signal-flare"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "signal-flare",
			order = "a[basic]-c[signal-flare]",
			action = "lua",
			localised_name = "Emergency locator beacon",
			toggleable = true,
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/signal-flare-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/signal-flare-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/signal-flare-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end

if settings.startup["draw-grid"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "draw-grid",
			order = "a[basic]-d[draw-grid]",
			action = "lua",
			localised_name = {"gui.grid"},
			style = "blue",
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/grid-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/grid-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/grid-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end

if settings.startup["rail-block-visualization-toggle"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "rail-block-visualization-toggle",
			order = "a[basic]-e[rail-block-visualization-toggle]",
			action = "lua",
			localised_name = {"gui-interface-settings.show-rail-block-visualization"},
			style = "default",
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x32.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_icon =
			{
				filename = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end

if settings.startup["big-zoom"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "big-zoom",
			order = "a[basic]-f[big-zoom]",
			action = "lua",
			localised_name = {"controls.alt-zoom-out"},
			toggleable = true,
			style = "blue",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/big-zoom-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/big-zoom-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/big-zoom-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end
