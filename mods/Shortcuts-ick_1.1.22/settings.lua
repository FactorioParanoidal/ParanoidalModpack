--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of settings.lua
	* Per player
	* Map
	* Startup
		- Basic
		- Blueprint
		- Equipment
		- Artillery
		- Vehicle
		- Other
]]


data:extend(
{
---------------------------------------------------------------------------------------------------
-- PER PLAYER
---------------------------------------------------------------------------------------------------
	{
		type = "string-setting",
		name = "grid-chunk-align",
		order = "a[grid]-a[chunk-align]",
		setting_type = "runtime-per-user",
		allowed_values = {"chunk", "player"},
		default_value = "chunk"
	},
	{
		type = "int-setting",
		name = "grid-radius",
		order = "a[grid]-b[radius]",
		setting_type = "runtime-per-user",
		default_value = 128,
		minimum_value = 1
	},
	{
		type = "string-setting",
		name = "grid-ground",
		order = "a[grid]-c[ground]",
		setting_type = "runtime-per-user",
		allowed_values = {"ground", "above"},
		default_value = "ground"
	},
	{
		type = "int-setting",
		name = "grid-chunk-size",
		order = "a[grid]-d[chunk-size]",
		setting_type = "runtime-per-user",
		default_value = 32,
		minimum_value = 1
	},
	{
		type = "double-setting",
		name = "grid-chunk-line-width",
		order = "a[grid]-e[chunk-line-width]",
		setting_type = "runtime-per-user",
		default_value = 5,
		minimum_value = 0.0,
		maximum_value = 32.0
	},
	{
		type = "int-setting",
		name = "grid-step",
		order = "a[grid]-f[step]",
		setting_type = "runtime-per-user",
		default_value = 1,
		minimum_value = 1
	},
	{
		type = "double-setting",
		name = "grid-line-width",
		order = "a[grid]-g[line-width]",
		setting_type = "runtime-per-user",
		default_value = 0.25,
		minimum_value = 0.0,
		maximum_value = 32.0
	},
	{
		type = "double-setting",
		name = "zoom-level",
		order = "b[zoom]",
		localised_name = {"", {"controls.alt-zoom-out"}, " ", {"description.module-bonus-limit"}},
		setting_type = "runtime-per-user",
		default_value = 0.1,
		minimum_value = 0.0,
		maximum_value = 20.0
	},

---------------------------------------------------------------------------------------------------
-- SERVER
---------------------------------------------------------------------------------------------------
	{
		type = "bool-setting",
		name = "disable-flare",
		localised_name = {"", {"gui-sync-mods-with-save.enable"}, " ", {"Shortcuts-ick.signal-flare"}},
		setting_type = "runtime-global",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "disable-zoom",
		localised_name = {"", {"gui-sync-mods-with-save.enable"}, " ", {"controls.alt-zoom-out"}},
		setting_type = "runtime-global",
		default_value = true
	},

---------------------------------------------------------------------------------------------------
-- STARTUP: BASIC
---------------------------------------------------------------------------------------------------
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
		order = "a[basic]-h[max-rate-calculator]",
		type = "bool-setting",
		default_value = true
  	}})
end

---------------------------------------------------------------------------------------------------
-- STARTUP: BLUEPRINT
---------------------------------------------------------------------------------------------------
data:extend(
{
	{
		setting_type = "startup",
		name = "tree-killer",
		localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.deconstruction-planner"}, " ", {"item-group-name.environment"}},
		order = "b[blueprint]-g[tree-killer]",
		type = "string-setting",
		allowed_values = {"disabled", "all-in-one", "both", "trees-rocks", "cliff-fish"},
		default_value = "all-in-one"
	}
})

if mods["WellPlanner"] then
	data:extend({{
		setting_type = "startup",
		name = "well-planner",
		localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.well-planner"}},
		order = "b[blueprint]-j[well-planner]",
    	type = "bool-setting",
		default_value = true
	}})
end


---------------------------------------------------------------------------------------------------
-- STARTUP: EQUIPMENT
---------------------------------------------------------------------------------------------------
data:extend(
{
	{
		setting_type = "startup",
		name = "belt-immunity-equipment",
		localised_name = {"", {"Shortcuts-ick.equipment"}, {"item-name.belt-immunity-equipment"}},
		order = "c[equipment]-c[belt-immunity-equipment]",
		type = "bool-setting",
		default_value = true
	},
	{
    	setting_type = "startup",
		name = "discharge-defense-remote",
		localised_name = {"", {"Shortcuts-ick.equipment"}, {"item-name.discharge-defense-remote"}},
		order = "c[equipment]-d[discharge-defense-remote]",
		type = "bool-setting",
		default_value = true
	},
	{
    	setting_type = "startup",
		name = "night-vision-equipment",
    	localised_name = {"", {"Shortcuts-ick.equipment"}, {"technology-name.night-vision-equipment"}},
    	order = "c[equipment]-e[night-vision-equipment]",
		type = "bool-setting",
		default_value = true
	},
	{
    	setting_type = "startup",
		name = "active-defense-equipment",
    	localised_name = {"", {"Shortcuts-ick.equipment"}, {"equipment-name.personal-laser-defense-equipment"}},
    	order = "c[equipment]-f[active-defense-equipment]",
		type = "bool-setting",
		default_value = true
	}
})

--[[This shortcut doesn't work yet
if mods["jetpack"] then
	data:extend({{
		setting_type = "startup",
		name = "jetpack",
		localised_name = {"", {"Shortcuts-ick.equipment"}, {"mod-name.jetpack"}},
		order = "c[equipment]-g[jetpack]",
		type = "bool-setting",
		default_value = true
	}})
end
]]

---------------------------------------------------------------------------------------------------
-- STARTUP: ARTILLERY
---------------------------------------------------------------------------------------------------
data:extend(
{
	{
    	setting_type = "startup",
		name = "artillery-targeting-remote",
    	localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-targeting-remote"}},
    	order = "d[artillery]-a[artillery-targeting-remote]",
		type = "bool-setting",
		default_value = true
	},
	{
		setting_type = "startup",
		name = "artillery-toggle",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"Shortcuts-ick.artillery-toggle"}},
		order = "d[artillery]-d[artillery-jammer-tool]",
		type = "string-setting",
		allowed_values = {"disabled", "both", "artillery-wagon", "artillery-turret"},
		default_value = "both"
	}
})

if mods["AdvancedArtilleryRemotesContinued"] then -- only here to allow checks in control.lua
	data:extend({{
		setting_type = "startup",
		name = "advanced-artillery-remote",
		hidden = true,
		type = "bool-setting",
		default_value = true,
		forced_value = true
	}})
end

if mods["MIRV"] then
	data:extend({{
		setting_type = "startup",
		name = "mirv-targeting-remote",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.mirv-targeting-remote"}},
		order = "d[artillery]-f[mirv-targeting-remote]",
		type = "bool-setting",
		default_value = true
	}})
end

if mods["AtomicArtilleryRemote"] then
	data:extend({{
		setting_type = "startup",
		name = "atomic-artillery-targeting-remote",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.atomic-artillery-targeting-remote"}},
		order = "d[artillery]-g[atomic-artillery-targeting-remote]",
		type = "bool-setting",
		default_value = true
	}})
end

if mods["landmine-thrower"] then
	data:extend({{
		setting_type = "startup",
		name = "landmine-thrower-remote",
		localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.landmine-thrower-remote"}},
		order = "d[artillery]-h[landmine-thrower-remote]",
		type = "bool-setting",
		default_value = true
	}})
end

---------------------------------------------------------------------------------------------------
-- STARTUP: VEHICLE
---------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------
-- STARTUP: OTHER
---------------------------------------------------------------------------------------------------
data:extend(
{
	{
		setting_type = "startup",
		name = "autogen-color",
		localised_name = {"", "[color=yellow]", {"gui-menu.other"}, ": [/color]", {"Shortcuts-ick.autogen-color"}},
		order = "f[other]-a[autogen-color]",
		type = "string-setting",
		allowed_values = {"disabled", "default", "red", "green", "blue"},
		default_value = "default"
	},
	{
		setting_type = "startup",
		name = "ick-compatibility-mode",
		localised_name = {"", "[color=yellow]", {"gui-menu.other"}, ": [/color]", {"Shortcuts-ick.compatibility-mode"}, "[font=default-small] [img=info][/font]"},
		order = "f[other]-b[compatibility-mode]",
		type = "bool-setting",
		default_value = false
	},
	{
		setting_type = "startup",
		name = "ick-tags",
		localised_name = {"", "[color=yellow]", {"gui-menu.other"}, ": [/color]", {"Shortcuts-ick.tags"}, "[font=default-small] [img=info][/font]"},
		order = "f[other]-c[autogen-color]",
		type = "string-setting",
		allowed_values = {"disabled", "tags", "icons"},
		default_value = "tags"
	}
})
