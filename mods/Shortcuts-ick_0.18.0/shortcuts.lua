--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * shortcuts.lua
 * Shortcuts and mod compatibility
--]]

if settings.startup["artillery-targeting-remote"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "artillery-targeting-remote",
			order = "a[artillery-targeting-remote]",
			action = "create-blueprint-item",
			localised_name = {"item-name.artillery-targeting-remote"},
			technology_to_unlock = "artillery",
			item_to_create = "artillery-targeting-remote",
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

if settings.startup["draw-grid"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "draw-grid",
			order = "a[draw-grid]",
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
			order = "a[rail-block-visualization-toggle]",
			action = "lua",
			localised_name = {"gui-interface-settings.show-rail-block-visualization"},
			style = "default",
			technology_to_unlock = "railway",
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

if settings.startup["artillery-jammer-remote"].value == true then

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
			order = "a[artillery-jammer-remote]",
			action = "create-blueprint-item",
			localised_name = {"", {"gui-mod-info.toggle"}, " ", {"entity-name.artillery-wagon"}, " ", {"damage-type-name.fire"}},
			technology_to_unlock = "artillery",
			item_to_create = "artillery-jammer-tool",
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
			flags = {"hidden", "only-in-cursor"},
			subgroup = "other",
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

if settings.startup["tree-killer"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "tree-killer",
			order = "a[tree-killer]",
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

if settings.startup["discharge-defense-remote"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "discharge-defense-remote",
			order = "a[discharge-defense-remote]",
			action = "create-blueprint-item",
			localised_name = {"item-name.discharge-defense-remote"},
			technology_to_unlock = "discharge-defense-equipment",
			item_to_create = "discharge-defense-remote",
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

if settings.startup["flashlight-toggle"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "flashlight-toggle",
			order = "a[flashlight-toggle]",
			technology_to_unlock = "electronics",
			action = "lua",
			localised_name = {"entity-name.small-lamp"},
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

if settings.startup["big-zoom"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "big-zoom",
			order = "a[big-zoom]",
			technology_to_unlock = "optics",
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

if settings.startup["signal-flare"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "signal-flare",
			order = "a[signal-flare]",
			technology_to_unlock = "electronics",
			action = "lua",
			localised_name = {"", {"technology-name.military"}, " ", {"entity-name.beacon"}, " (", {"description.force"}, " ", {"deconstruction-tile-mode.only"}, ")"},
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

	-- Custom shortcut can be defined as follows:
	-- {
	--	 type = "shortcut",
	--	 name = "shortcut-name",
	--	 action = "lua",
	--	 toggleable = true, -- whether or not the shortcut button is a toggle button or not
	--	 order, localised_name, technology_to_unlock, icon, small_icon, disabled_icon, disabled_small_icon as above
	-- }

--[[ ORIGINAL:
--	legacy for older version of YARM (newer versions have the shortcut built in)
if mods["YARM"] and data.raw["item"]["resource-monitor"] and data.raw["technology"]["resource-monitoring"] and settings.startup["resource-monitor"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "resource-monitor",
			order = "a[resource-monitor]",
			action = "create-blueprint-item",
			localised_name = {"item-name.resource-monitor"},
			technology_to_unlock = "resource-monitoring",
			item_to_create = "resource-monitor",
			style = "green",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/resource-monitor-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/resource-monitor-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/resource-monitor-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		}
	})
end
]]

if mods["OutpostPlanner"] and mods["PlannerCore"] and data.raw["selection-tool"]["outpost-builder"] and settings.startup["outpost-builder"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "outpost-builder",
			order = "a[outpost-builder]",
			action = "create-blueprint-item",
			localised_name = {"item-name.outpost-builder"},
			-- technology_to_unlock = "resource-monitor",
			item_to_create = "outpost-builder",
			style = "green",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/outpost-builder-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/outpost-builder-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/outpost-builder-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		}
	})
end

if mods["Orbital Ion Cannon"] and data.raw["item"]["ion-cannon-targeter"] and data.raw["technology"]["orbital-ion-cannon"] and settings.startup["ion-cannon-targeter"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "ion-cannon-targeter",
			order = "a[ion-cannon-targeter]",
			action = "create-blueprint-item",
			localised_name = {"item-name.ion-cannon-targeter"},
			technology_to_unlock = "orbital-ion-cannon",
			item_to_create = "ion-cannon-targeter",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/ion-cannon-targeter-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/ion-cannon-targeter-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/ion-cannon-targeter-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		}
	})
end

if mods["MaxRateCalculator"] and data.raw["selection-tool"]["max-rate-calculator"] and settings.startup["max-rate-calculator"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "max-rate-calculator",
			order = "a[max-rate-calculator]",
			action = "create-blueprint-item",
			localised_name = {"item-name.max-rate-calculator"},
			item_to_create = "max-rate-calculator",
			style = "blue",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/max-rate-calculator-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/max-rate-calculator-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/max-rate-calculator-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		}
	})
end

if mods["ModuleInserter"] and data.raw["selection-tool"]["module-inserter"] and settings.startup["module-inserter"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "module-inserter",
			order = "a[module-inserter]",
			action = "create-blueprint-item",
			localised_name = {"item-name.module-inserter"},
			item_to_create = "module-inserter",
			technology_to_unlock = "modules",
			style = "blue",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/module-inserter-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/module-inserter-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/module-inserter-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		}
	})
end

if mods["aai-programmable-vehicles"] then
	if settings.startup["unit-remote-control"].value == true and data.raw["selection-tool"]["unit-remote-control"] then
		data:extend(
		{
			{
				type = "shortcut",
				name = "unit-remote-control",
				order = "a[unit-remote-control]",
				action = "create-blueprint-item",
				localised_name = {"item-name.unit-remote-control"},
				item_to_create = "unit-remote-control",
				technology_to_unlock = "automobilism",
				style = "blue",
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/unit-remote-control-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
				small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/unit-remote-control-x24.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
				disabled_small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/unit-remote-control-x24-white.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
			}
		})
	end

	if settings.startup["path-remote-control"].value == true and data.raw["selection-tool"]["path-remote-control"] then
		data:extend(
		{
			{
				type = "shortcut",
				name = "path-remote-control",
				order = "a[path-remote-control]",
				action = "create-blueprint-item",
				localised_name = {"item-name.path-remote-control"},
				item_to_create = "path-remote-control",
				technology_to_unlock = "automobilism",
				style = "blue",
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/path-remote-control-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
				small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/path-remote-control-x24.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
				disabled_small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/path-remote-control-x24-white.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
			}
		})
	end
end

if not mods["Nanobots"] then
	if settings.startup["night-vision-equipment"].value == true then
		data:extend(
		{
			{
				type = "shortcut",
				name = "night-vision-equipment",
				order = "a[night-vision-equipment]",
				action = "lua",
				localised_name = {"equipment-name.night-vision-equipment"},
				technology_to_unlock = "night-vision-equipment",
				toggleable = true,
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x32.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
				small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x24.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
				disabled_small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x24-white.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
			},
		})
	end

	if settings.startup["active-defense-equipment"].value == true then
		data:extend(
		{
			{
				type = "shortcut",
				name = "active-defense-equipment",
				order = "a[active-defense-equipment]",
				action = "lua",
				localised_name = {"equipment-name.personal-laser-defense-equipment"},
				technology_to_unlock = "personal-laser-defense-equipment",
				toggleable = true,
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x32.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
				small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x24.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
				disabled_small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x24-white.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
			},
		})
	end

	if settings.startup["belt-immunity-equipment"].value == true then
		data:extend(
		{
			{
				type = "shortcut",
				name = "belt-immunity-equipment",
				order = "a[belt-immunity-equipment]",
				action = "lua",
				localised_name = {"item-name.belt-immunity-equipment"},
				technology_to_unlock = "belt-immunity-equipment",
				toggleable = true,
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x32.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
				small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x24.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
				disabled_small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x24-white.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 1,
					flags = {"icon"}
				},
			}
		})
	end
end
