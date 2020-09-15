--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * shortcuts.lua
 * Shortcuts and mod compatibility
--]]

-- This code has been modified by ickputzdirwech.

if settings.startup["artillery-targeting-remote"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "artillery-targeting-remote",
			order = "d[remotes]-a[artillery-targeting-remote]",
			action = "lua",
			localised_name = {"item-name.artillery-targeting-remote"},
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-targeting-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-targeting-remote-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-targeting-remote-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end

if settings.startup["artillery-toggle"].value == "both" or settings.startup["artillery-toggle"].value == "Artillery wagon" or settings.startup["artillery-toggle"].value == "Artillery turret" then

	local disable_turret_list = {}

	if settings.startup["artillery-toggle"].value == "both" then
		disable_turret_list = {"artillery-wagon", "artillery-turret"}
	elseif settings.startup["artillery-toggle"].value == "artillery-wagon" then
		disable_turret_list = {"artillery-wagon"}
	elseif settings.startup["artillery-toggle"].value == "artillery-turret" then
		disable_turret_list = {"artillery-turret"}
	end

	data:extend(
	{
		{
			type = "shortcut",
			name = "artillery-jammer-remote",
			order = "d[remotes]-b[artillery-jammer-remote]",
			action = "lua",
			localised_name = {"", {"gui-mod-info.toggle"}, " ", {"entity-name.artillery-wagon"}, " ", {"damage-type-name.fire"}},
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-jammer-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-jammer-remote-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-jammer-remote-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
		{
			type = "selection-tool",
			name = "artillery-jammer-tool",
			icon = "__Shortcuts-ick__/graphics/artillery-jammer-remote.png",
			icon_size = 32,
			localised_name = {"", {"gui-mod-info.toggle"}, " ", {"entity-name.artillery-wagon"}, " ", {"damage-type-name.fire"}},
			flags = {"hidden", "only-in-cursor"},
			subgroup = "tool",
			order = "c[automated-construction]-a[artillery-jammer-tool]",
			stack_size = 1,
			stackable = false,
			selection_color = { r = 1, g = 0, b = 0 },
			alt_selection_color = { r = 1, g = 0, b = 0 },
			selection_mode = {"blueprint"},
			alt_selection_mode = {"blueprint"},
			selection_cursor_box_type = "copy",
			alt_selection_cursor_box_type = "copy",
			entity_type_filters = disable_turret_list,
			tile_filters = {"lab-dark-1"},
			entity_filter_mode = "whitelist",
			tile_filter_mode = "whitelist",
			alt_entity_type_filters = disable_turret_list,
			alt_tile_filters = {"lab-dark-1"},
			alt_entity_filter_mode = "whitelist",
			alt_tile_filter_mode = "whitelist",
			show_in_library = false,
			always_include_tiles = false
		},
	})
end

if settings.startup["discharge-defense-remote"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "discharge-defense-remote",
			order = "d[remotes]-c[discharge-defense-remote]",
			action = "lua",
			localised_name = {"item-name.discharge-defense-remote"},
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/discharge-defense-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/discharge-defense-remote-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/discharge-defense-remote-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end

if settings.startup["spidertron-remote"].value == "enabled" or "enabled (hide remote from inventory)" then
	data:extend(
	{
		{
			type = "shortcut",
			name = "spidertron-remote",
			order = "d[remotes]-d[spidertron-remote]",
			action = "lua",
			localised_name = {"item-name.spidertron-remote"},
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/spidertron-remote-x40-white.png",
				priority = "extra-high-no-scale",
				size = 40,
				scale = 1,
				flags = {"icon"},
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/spidertron-remote-x40-white.png",
				priority = "extra-high-no-scale",
				size = 40,
				scale = 1,
				flags = {"icon"},
				tint = {},
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/spidertron-remote-x40-white.png",
				priority = "extra-high-no-scale",
				size = 40,
				scale = 1,
				flags = {"icon"},
			},
		},
	})
end
