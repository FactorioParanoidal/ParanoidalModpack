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
]]

-- TAGS
local small_lamp
local alert_icon
local draw_grid
local rail_signal
local logistics_robot
local trash
local big_zoom
local minimap
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"Shortcuts-ick.basic"}
	small_lamp = tag
	alert_icon = tag
	draw_grid = tag
	rail_signal = tag
	logistics_robot = tag
	trash = tag
	big_zoom = tag
	minimap = tag
elseif settings.startup["ick-tags"].value == "icons" then
	small_lamp = "[img=item/small-lamp] "
	alert_icon = "[img=utility.danger_icon] "
	draw_grid = "[img=utility.equipment_grid] "
	rail_signal = "[img=item/rail-signal] "
	logistics_robot = "[img=item/logistic-robot] "
	trash = "[img=utility.trash] "
	big_zoom = "[img=utility.search_white] "
	minimap = "[img=utility.map] "
else
	small_lamp = ""
	alert_icon = ""
	draw_grid = ""
	rail_signal = ""
	logistics_robot = ""
	trash = ""
	big_zoom = ""
	minimap = ""
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
		icon = "__Shortcuts-ick__/graphics/flashlight-toggle-x32.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/flashlight-toggle-x24.png",
		small_icon_size = 24
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
		icon = "__Shortcuts-ick__/graphics/signal-flare-x32-white.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/signal-flare-x24-white.png",
		small_icon_size = 24
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
		icon = "__Shortcuts-ick__/graphics/grid-x32-white.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/grid-x24-white.png",
		small_icon_size = 24
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
		technology_to_unlock = "railway",
		unavailable_until_unlocked = true,
		toggleable = true,
		icon = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x32-2.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/rail-block-visualization-toggle-x32-2.png",
		small_icon_size = 32
	}})
end

-- PERSONAL LOGISTICS REQUESTS
if settings.startup["toggle-personal-logistic-requests"].value then
	-- taken from mods.factorio.com/mod/PersonalLogisticsShortcut from Haxtorio, modified by ickputzdirwech
	data:extend({{
		type = "shortcut",
		name = "toggle-personal-logistic-requests",
		localised_name = {"", logistics_robot, {"shortcut.toggle-personal-logistic-requests"}},
		order = "a[basic]-f[toggle-personal-logistic-requests]",
		action = "toggle-personal-logistic-requests",
		associated_control_input = "toggle-personal-logistic-requests",
		technology_to_unlock = "logistic-robotics",
		unavailable_until_unlocked = true,
		icon = "__Shortcuts-ick__/graphics/toggle-personal-logistics-x32.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/toggle-personal-logistics-x24.png",
		small_icon_size = 24
	}})
	-- end Haxtorio
end

-- TRASH NOT REQUESTED
if settings.startup["player-trash-not-requested"].value then
	data:extend({{
		type = "shortcut",
		name = "player-trash-not-requested",
		localised_name = {"", trash, {"trash-not-requested-items"}},
		order = "a[basic]-g[player-trash-not-requested]",
		action = "lua",
		technology_to_unlock = "logistic-robotics",
		unavailable_until_unlocked = true,
		toggleable = true,
		icon = "__core__/graphics/icons/mip/trash.png",
		icon_size = 32,
		small_icon = "__core__/graphics/icons/mip/trash.png",
		small_icon_size = 32
	}})
end

-- ZOOM OUT OF WORLD
if settings.startup["big-zoom"].value then
	data:extend({{
		type = "shortcut",
		name = "big-zoom",
		localised_name = {"", big_zoom, {"controls.alt-zoom-out"}},
		order = "a[basic]-h[big-zoom]",
		action = "lua",
		toggleable = true,
		style = "blue",
		icon = "__Shortcuts-ick__/graphics/big-zoom-x32-white.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/big-zoom-x24-white.png",
		small_icon_size = 24
	}})
end

-- MINIMAP
if settings.startup["minimap"].value then
	data:extend({{
		type = "shortcut",
		name = "minimap",
		localised_name = {"", minimap, {"gui-interface-settings.show-minimap"}},
		order = "a[basic]-i[minimap]",
		action = "lua",
		toggleable = true,
		style = "blue",
		icon = "__core__/graphics/icons/mip/map.png",
		icon_size = 32,
		small_icon = "__core__/graphics/icons/mip/map.png",
		small_icon_size = 32
	}})
end
