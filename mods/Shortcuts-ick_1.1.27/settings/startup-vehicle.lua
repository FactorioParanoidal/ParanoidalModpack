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
	* Spidertron Logistic request
	* Spidertron Auto targeting with gunner
	* Spidertron Auto targeting without gunner
	* Train Manual mode
	* MOD: AAI programmable vehicles remote controls
	* MOD: Vehicle waggon 2 winch
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
		name = "spidertron-remote",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"item-name.spidertron-remote"}},
		order = "e[vehicle]-b[spidertron-remote]",
		type = "string-setting",
		allowed_values = {"disabled", "enabled", "enabled-hidden"},
		default_value = "enabled"
	},
	{
		setting_type = "startup",
		name = "spidertron-logistics",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"entity-name.spidertron"}, " ", {"gui.enable-logistics-while-moving"}},
		order = "e[vehicle]-c[spidertron-logistics]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "spidertron-logistic-requests",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"entity-name.spidertron"}, " ", {"gui-logistic.title-request"}},
		order = "e[vehicle]-d[spidertron-logistics]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "targeting-with-gunner",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"entity-name.spidertron"}, " ", {"gui-car.automatic-targeting"}, " ", {"gui-car.with-gunner"}},
		order = "e[vehicle]-e[targeting-with-gunner]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "targeting-without-gunner",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"entity-name.spidertron"}, " ", {"gui-car.automatic-targeting"}, " ", {"gui-car.without-gunner"}},
		order = "e[vehicle]-f[targeting-without-gunner]",
		type = "bool-setting",
		default_value = false
	},
	{
		setting_type = "startup",
		name = "train-mode-toggle",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"tooltip-category.train"}, " ", {"gui-trains.manual-mode"}},
		order = "e[vehicle]-g[targeting-with-gunner]",
		type = "bool-setting",
		default_value = true
	}
})

if mods["aai-programmable-vehicles"] then
	data:extend({{
		setting_type = "startup",
		name = "aai-remote-controls",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color] AAI Programmable Vehicles ", {"item-name.unit-remote-control"}},
		order = "e[vehicle]-h[aai-remote-controls]",
		type = "bool-setting",
		default_value = true
		}})
end

if mods["VehicleWagon2"] then
  	data:extend({{
      	setting_type = "startup",
  		name = "winch",
		localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color] Vehicle Wagon 2 ", {"item-name.winch"}},
      	order = "e[vehicle]-j[winch]",
  		type = "bool-setting",
  		default_value = true
  	}})
end
