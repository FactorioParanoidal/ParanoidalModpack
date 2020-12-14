--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio.
 * This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-artillery.lua:
	* Artillery targeting remote shortcut and custom input
	* AdvArtilleryRemotes shortcuts and custom inputs
	* Toggle artillery cannon fire
		- configuration
		- shortcut
		- custom input
		- selection tool
]]

if settings.startup["artillery-targeting-remote"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "artillery-targeting-remote",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-targeting-remote"}, {"Shortcuts-ick.control-artillery-targeting-remote"}},
			order = "d[artillery]-a[artillery-targeting-remote]",
			--associated_control_input = "artillery-targeting-remote",
			action = "lua",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-targeting-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-targeting-remote-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
		{
			type = "custom-input",
			name = "artillery-targeting-remote",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-targeting-remote"}},
			order = "d[artillery]-a[artillery-targeting-remote]",
			key_sequence = "",
		},
	})
end

if mods["AdvArtilleryRemotes"] and settings.startup["artillery-targeting-remote"].value == true then
	if data.raw.capsule["artillery-cluster-remote"] then
		data:extend(
		{
			{
				type = "shortcut",
				name = "artillery-cluster-remote",
				localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-cluster-remote"}, {"Shortcuts-ick.control-artillery-cluster-remote"}},
				order = "d[artillery]-b[artillery-cluster-remote]",
				--associated_control_input = "artillery-cluster-remote",
				action = "lua",
				style = "red",
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/artillery-cluster-remote-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 0.5,
					flags = {"gui-icon"}
				},
			},
		  {
				type = "custom-input",
		    name = "artillery-cluster-remote",
				localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-cluster-remote"}},
				order = "d[artillery]-b[artillery-cluster-remote]",
				action = "create-blueprint-item",
				item_to_create = "artillery-cluster-remote",
		    key_sequence = "",
		  },
		})
	end

	if data.raw.capsule["artillery-discovery-remote"] then
		data:extend(
		{
			{
				type = "shortcut",
				name = "artillery-discovery-remote",
				localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-discovery-remote"}, {"Shortcuts-ick.control-artillery-discovery-remote"}},
				order = "d[artillery]-c[artillery-discovery-remote]",
				--associated_control_input = "artillery-discovery-remote",
				action = "lua",
				style = "red",
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/artillery-discovery-remote-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 0.5,
					flags = {"gui-icon"}
				},
			},
		  {
				type = "custom-input",
		    name = "artillery-discovery-remote",
				localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-discovery-remote"}},
				order = "d[artillery]-c[artillery-discovery-remote]",
				action = "create-blueprint-item",
				item_to_create = "artillery-discovery-remote",
		    key_sequence = "",
		  },
		})
	end
end

if settings.startup["artillery-toggle"].value == "both" or settings.startup["artillery-toggle"].value == "artillery-wagon" or settings.startup["artillery-toggle"].value == "artillery-turret" then

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
			name = "artillery-jammer-tool",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-jammer-tool"}, {"Shortcuts-ick.control-artillery-jammer-tool"}},
			order = "d[artillery]-d[artillery-jammer-tool]",
			--associated_control_input = "artillery-jammer-tool",
			action = "lua",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-jammer-tool-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/artillery-jammer-tool-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
		{
			type = "custom-input",
			name = "artillery-jammer-tool",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-jammer-tool"}},
			order = "d[artillery]-d[artillery-jammer-tool]",
			key_sequence = "",
		},
		{
			type = "selection-tool",
			name = "artillery-jammer-tool",
			subgroup = "tool",
			order = "c[automated-construction]-a[artillery-jammer-tool]",
			icon = "__Shortcuts-ick__/graphics/artillery-jammer-tool-red.png",
			icon_size = 32,
			flags = {"hidden", "only-in-cursor", "not-stackable"},
			stack_size = 1,
			stackable = false,
			selection_color = { r = 1, g = 0, b = 0 },
			alt_selection_color = { r = 1, g = 0, b = 0 },
			selection_mode = {"blueprint"},
			alt_selection_mode = {"blueprint"},
			selection_cursor_box_type = "not-allowed",
			alt_selection_cursor_box_type = "not-allowed",
			entity_type_filters = disable_turret_list,
			tile_filters = {"lab-dark-1"},
			entity_filter_mode = "whitelist",
			tile_filter_mode = "whitelist",
			alt_entity_type_filters = disable_turret_list,
			alt_tile_filters = {"lab-dark-1"},
			alt_entity_filter_mode = "whitelist",
			alt_tile_filter_mode = "whitelist",
		},
	})
end

if mods["MIRV"] and data.raw.capsule["mirv-targeting-remote"] and settings.startup["mirv-targeting-remote"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "mirv-targeting-remote",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.mirv-targeting-remote"}, {"Shortcuts-ick.control-mirv-targeting-remote"}},
			order = "d[artillery]-f[mirv-targeting-remote]",
			--associated_control_input = "mirv-targeting-remote",
			action = "lua",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/mirv-targeting-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/mirv-targeting-remote-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
	  {
			type = "custom-input",
	    name = "mirv-targeting-remote",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.mirv-targeting-remote"}},
			order = "d[artillery]-f[mirv-targeting-remote]",
	    key_sequence = "",
	  },
	})
end
