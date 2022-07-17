--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-basic.lua:
	* Character Lamp shortcut.
	* Emergency locator beacon shortcut.
	* Grid shortcut.
	* Show rail block visualization shortcut.
	* Toggle Personal logistics requests shortcut.
	* Zoom out of world shortcut.
	* Minimap shortcut.
	* MaxRateCalculator shortcut.
]]

-- TAGS
local small_lamp = ""
local alert_icon = ""
local draw_grid = ""
local rail_signal = ""
local logistics_robot = ""
local big_zoom = ""
local minimap = ""
local max_rate_calculator = ""
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"Shortcuts-ick.basic"}
	small_lamp = tag
	alert_icon = tag
	draw_grid = tag
	rail_signal = tag
	logistics_robot = tag
	big_zoom = tag
	minimap = tag
	max_rate_calculator = tag
elseif settings.startup["ick-tags"].value == "icons" then
	small_lamp = "[img=item/small-lamp] "
	alert_icon = "[img=utility.danger_icon] "
	draw_grid = "[img=utility.equipment_grid] "
	rail_signal = "[img=item/rail-signal] "
	logistics_robot = "[img=item/logistic-robot] "
	big_zoom = "[img=utility.search_white] "
	minimap = "[img=utility.map] "
	max_rate_calculator = "[img=item/max-rate-calculator] "
end

-- CHARACTER LAMP
if settings.startup["flashlight-toggle"].value then
	data:extend({{
		type = "shortcut",
		name = "flashlight-toggle",
		localised_name = {"", small_lamp, {"Shortcuts-ick.flashlight-toggle"}},
		order = "a[basic]-b[flashlight-toggle]",
		action = "lua",
		toggleable = true,
		icon = {
			filename = "__Shortcuts-ick__/graphics/flashlight-toggle-x32.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/flashlight-toggle-x24.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		disabled_icon = {
			filename = "__Shortcuts-ick__/graphics/flashlight-toggle-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		disabled_small_icon = {
			filename = "__Shortcuts-ick__/graphics/flashlight-toggle-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- EMERGENCY LOCATOR BEACON
if settings.startup["signal-flare"].value then
	data:extend({{
		type = "shortcut",
		name = "signal-flare",
		localised_name = {"", alert_icon, {"Shortcuts-ick.signal-flare"}},
		order = "a[basic]-c[signal-flare]",
		action = "lua",
		toggleable = true,
		style = "red",
		icon = {
			filename = "__Shortcuts-ick__/graphics/signal-flare-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/signal-flare-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- GRID
if settings.startup["draw-grid"].value then
	data:extend({{
		type = "shortcut",
		name = "draw-grid",
		localised_name = {"", draw_grid, {"gui.grid"}},
		order = "a[basic]-d[draw-grid]",
		action = "lua",
		toggleable = true,
		style = "blue",
		icon = {
			filename = "__Shortcuts-ick__/graphics/grid-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/grid-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- RAIL BLOCK VISUALIZATION
if settings.startup["rail-block-visualization-toggle"].value then
	data:extend({{
		type = "shortcut",
		name = "rail-block-visualization-toggle",
		localised_name = {"", rail_signal, {"gui-interface-settings.show-rail-block-visualization"}},
		order = "a[basic]-e[rail-block-visualization-toggle]",
		action = "lua",
		toggleable = true,
		icon = {
			filename = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x32-2.png",
			priority = "extra-high-no-scale",
			size = 32,
			mipmap_count = 2,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x32-2.png",
			priority = "extra-high-no-scale",
			size = 32,
			mipmap_count = 2,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		disabled_icon = {
			filename = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x32-2-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			mipmap_count = 2,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		disabled_small_icon = {
			filename = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x32-2-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			mipmap_count = 2,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- PERSONAL LOGISTICS REQUESTS
if settings.startup["toggle-personal-logistic-requests"] and settings.startup["toggle-personal-logistic-requests"].value then
	-- taken from mods.factorio.com/mod/PersonalLogisticsShortcut from Haxtorio, modified by ickputzdirwech
	data:extend({{
		type = "shortcut",
		name = "toggle-personal-logistic-requests",
		localised_name = {"", logistics_robot, {"shortcut.toggle-personal-logistic-requests"}},
		order = "a[basic]-f[toggle-personal-logistic-requests]",
		action = "toggle-personal-logistic-requests",
		associated_control_input = "toggle-personal-logistic-requests",
		technology_to_unlock = "logistic-robotics",
		icon = {
			filename = "__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-logistics-x32.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			mipmap_count = 2,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-logistics-x24.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			mipmap_count = 2,
			flags = {"gui-icon"}
		},
		disabled_icon = {
			filename = "__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-logistics-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			mipmap_count = 2,
			flags = {"gui-icon"}
		},
		disabled_small_icon = {
			filename = "__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-logistics-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			mipmap_count = 2,
			flags = {"gui-icon"}
		}
	}})
	-- end Haxtorio
end

-- ZOOM OUT OF WORLD
if settings.startup["big-zoom"].value then
	data:extend({{
		type = "shortcut",
		name = "big-zoom",
		localised_name = {"", big_zoom, {"controls.alt-zoom-out"}},
		order = "a[basic]-g[big-zoom]",
		action = "lua",
		toggleable = true,
		style = "blue",
		icon = {
			filename = "__Shortcuts-ick__/graphics/big-zoom-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/big-zoom-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- MINIMAP
if settings.startup["minimap"].value then
	data:extend({{
		type = "shortcut",
		name = "minimap",
		localised_name = {"", minimap, {"gui-interface-settings.show-minimap"}},
		order = "a[basic]-h[minimap]",
		action = "lua",
		toggleable = true,
		style = "blue",
		icon = {
			filename = "__core__/graphics/icons/mip/map.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end

-- MAX RATE CALCULATOR
if mods["MaxRateCalculator"] and data.raw["selection-tool"]["max-rate-calculator"] and settings.startup["max-rate-calculator"].value then

	data.raw["selection-tool"]["max-rate-calculator"].icon = "__MaxRateCalculator__/graphics/calculator.png"
	data.raw["selection-tool"]["max-rate-calculator"].icon_size = 64
	table.insert(data.raw["selection-tool"]["max-rate-calculator"].flags, "spawnable")

	data:extend({{
		type = "shortcut",
		name = "max-rate-shortcut",
		localised_name = {"", max_rate_calculator, {"item-name.max-rate-calculator"}, " ", {"Shortcuts-ick.control", "marc_hotkey"}},
		order = "a[basic]-i[max-rate-shortcut]",
		action = "spawn-item",
		item_to_spawn = "max-rate-calculator",
		style = "blue",
		icon = {
			filename = "__Shortcuts-ick__/graphics/max-rate-calculator-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Shortcuts-ick__/graphics/max-rate-calculator-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			flags = {"gui-icon"}
		}
	}})
end
