--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of startup-basic.lua
	* Character lamp
	* Emergency locator beacon
	* Grid
	* Show rail block visualization
	* Zoom out of world
	* Show minimap
	* Toggle personal logistic requests
	* MOD: Max rate calculator
]]

data:extend(
{
	{
    	setting_type = "startup",
		name = "flashlight-toggle",
		localised_name = {"", {"Shortcuts-ick.basic"}, {"Shortcuts-ick.flashlight-toggle"}},
		order = "a[basic]-b[flashlight-toggle]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "signal-flare",
		localised_name = {"", {"Shortcuts-ick.basic"}, {"Shortcuts-ick.signal-flare"}},
		order = "a[basic]-c[signal-flare]",
		type = "bool-setting",
		default_value = true
	},
	{
    	setting_type = "startup",
		name = "draw-grid",
		localised_name = {"", {"Shortcuts-ick.basic"}, {"gui.grid"}},
		order = "a[basic]-d[draw-grid]",
		type = "bool-setting",
		default_value = true
	},
	{
    	setting_type = "startup",
		name = "rail-block-visualization-toggle",
		localised_name = {"", {"Shortcuts-ick.basic"}, {"gui-interface-settings.show-rail-block-visualization"}},
		order = "a[basic]-e[rail-block-visualization-toggle]",
		type = "bool-setting",
		default_value = true
	},
	{
    	setting_type = "startup",
		name = "big-zoom",
		localised_name = {"", {"Shortcuts-ick.basic"}, {"controls.alt-zoom-out"}},
		order = "a[basic]-g[big-zoom]",
		type = "bool-setting",
		default_value = true
	},
	{
    	setting_type = "startup",
		name = "minimap",
		localised_name = {"", {"Shortcuts-ick.basic"}, {"gui-interface-settings.show-minimap"}},
		order = "a[basic]-h[minimap]",
		type = "bool-setting",
		default_value = true
	}
})

if mods["PersonalLogisticsShortcut"] then
else
	data:extend({{
		setting_type = "startup",
		name = "toggle-personal-logistic-requests",
		localised_name = {"", {"Shortcuts-ick.basic"}, {"shortcut.toggle-personal-logistic-requests"}},
		order = "a[basic]-f[toggle-personal-logistic-requests]",
		type = "bool-setting",
		default_value = true
	}})
end

if mods["MaxRateCalculator"] then
	data:extend({{
		setting_type = "startup",
		name = "max-rate-calculator",
		localised_name = {"", {"Shortcuts-ick.basic"}, {"item-name.max-rate-calculator"}},
		order = "a[basic]-i[max-rate-calculator]",
		type = "bool-setting",
		default_value = true
  	}})
end
