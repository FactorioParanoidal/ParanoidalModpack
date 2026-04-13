--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of startup-vehicle.lua
	* Driver is gunner
	* Spidertron remote
	* Spidertron Enable/disable logistics while moving
	* Vehicle logistics
	* Spidertron Auto targeting with gunner
	* Spidertron Auto targeting without gunner
	* Train Manual mode
]]

data:extend(
{
	{
		setting_type = "startup",
		name = "driver-is-gunner",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"Shortcuts-ick.driver-is-gunner"}},
		order = "e[vehicle]-a[driver-is-gunner]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "vehicle-logistics-while-moving",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"gui.enable-logistics-while-moving"}},
		order = "e[vehicle]-c[vehicle-logistics]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "vehicle-logistic-requests",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"gui-logistic.vehicle-logistics-and-trash"}},
		order = "e[vehicle]-d[vehicle-logistics]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "vehicle-trash-not-requested",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"trash-not-requested-items"}},
		order = "e[vehicle]-e[vehicle-trash-not-requested]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "targeting-with-gunner",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"entity-name.spidertron"}, " ", {"gui-car.automatic-targeting"}, " ", {"gui-car.with-gunner"}},
		order = "e[vehicle]-f[targeting-with-gunner]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "targeting-without-gunner",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"entity-name.spidertron"}, " ", {"gui-car.automatic-targeting"}, " ", {"gui-car.without-gunner"}},
		order = "e[vehicle]-g[targeting-without-gunner]",
		type = "bool-setting",
		default_value = false
	},
	{
		setting_type = "startup",
		name = "train-mode-toggle",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"tooltip-category.train"}, " ", {"gui-trains.manual-mode"}},
		order = "e[vehicle]-h[targeting-with-gunner]",
		type = "bool-setting",
		default_value = true
	}
})
