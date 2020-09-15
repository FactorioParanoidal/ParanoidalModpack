--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * shortcuts.lua
 * Shortcuts and mod compatibility
--]]

-- This code has been modified by ickputzdirwech.

if mods["aai-programmable-vehicles"] and settings.startup["aai-remote-controls"].value == true then
	if data.raw["selection-tool"]["unit-remote-control"] then
		data:extend(
		{
			{
				type = "shortcut",
				name = "unit-remote-control",
				order = "e[mods]-a[unit-remote-control]",
				action = "lua",
				localised_name = {"item-name.unit-remote-control"},
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

	if data.raw["selection-tool"]["path-remote-control"] then
		data:extend(
		{
			{
				type = "shortcut",
				name = "path-remote-control",
				order = "e[mods]-b[path-remote-control]",
				action = "lua",
				localised_name = {"item-name.path-remote-control"},
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


if mods["AdvArtilleryRemotes"] and settings.startup["artillery-targeting-remote"] then
	if data.raw.capsule["artillery-cluster-remote"] then
		data:extend(
		{
			{
				type = "shortcut",
				name = "artillery-cluster-remote",
				order = "e[mods]-c[artillery-cluster-remote]",
				action = "lua",
				localised_name = {"item-name.artillery-cluster-remote"},
				style = "red",
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/artillery-cluster-remote-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
				small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/artillery-cluster-remote-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"},
					tint = {}
				},
				disabled_small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/artillery-cluster-remote-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
			}
		})
	end

	if data.raw.capsule["artillery-discovery-remote"] then
		data:extend(
		{
			{
				type = "shortcut",
				name = "artillery-discovery-remote",
				order = "e[mods]-c[artillery-discovery-remote]",
				action = "lua",
				localised_name = {"item-name.artillery-discovery-remote"},
				style = "red",
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/artillery-discovery-remote-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
				small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/artillery-discovery-remote-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"},
					tint = {}
				},
				disabled_small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/artillery-discovery-remote-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 1,
					flags = {"icon"}
				},
			}
		})
	end
end


if mods["MaxRateCalculator"] and data.raw["selection-tool"]["max-rate-calculator"] and settings.startup["max-rate-calculator"].value == true then

	if data.raw["selection-tool"]["max-rate-calculator"] then
		data.raw["selection-tool"]["max-rate-calculator"].icon = "__MaxRateCalculator__/graphics/calculator.png"
		data.raw["selection-tool"]["max-rate-calculator"].icon_size = 64
	end

	data:extend(
	{
		{
			type = "shortcut",
			name = "max-rate-shortcut",
			order = "e[mod]-d[max-rate-calculator]",
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


if mods["OutpostPlanner"] and mods["PlannerCore"] and data.raw["selection-tool"]["outpost-builder"] and settings.startup["outpost-builder"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "outpost-builder",
			order = "e[mod]-e[outpost-builder]",
			action = "create-blueprint-item",
			localised_name = {"item-name.outpost-builder"},
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


if mods["VehicleWagon2"] and settings.startup["vehicle-wagon-2-winch"].value == true then

	data.raw.technology["vehicle-wagons"].localised_description = "Vehicle wagons allow you to carry equipped and loaded vehicles on trains, so they are ready to deploy immediately upon arrival."

	data:extend(
  {
    {
      type = "shortcut",
      name = "vehicle-wagon-2-winch",
      order = "e[mod]-f[vehicle-wagon-2-winch]",
      action = "lua",
      localised_name = {"item-name.winch"},
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/module-inserter-x32.png",
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
			disabled_icon =
			{
				filename = "__Shortcuts-ick__/graphics/module-inserter-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
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
