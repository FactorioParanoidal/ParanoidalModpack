--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 * This mod has been modified by ickputzdirwech.
]]

--[[ Overview of settings.lua
 * Mod settings
]]

data:extend(
{
---------------------------------------------------------------------------------------------------
-- PER PLAYER
---------------------------------------------------------------------------------------------------
  {
    type = "double-setting",
    name = "zoom-level",
	  localised_name = {"", {"controls.alt-zoom-out"}, " ", {"description.module-bonus-limit"}},
    setting_type = "runtime-per-user",
    default_value = 0.1,
	  minimum_value = 0.0,
	  maximum_value = 16.0,
  },
  {
    type = "double-setting",
    name = "grid-chunk-line-width",
	  localised_name = {"", {"gui.grid"}, " Chunk ", {"gui-map-editor-tool.line-selection"}, " ", {"gui-map-generator.map-width"}},
    setting_type = "runtime-per-user",
    default_value = 5,
	  minimum_value = 0.0
  },
  {
    type = "double-setting",
    name = "grid-line-width",
	  localised_name = {"", {"gui.grid"}, " ", {"gui-map-editor-tool.line-selection"}, " ", {"gui-map-generator.map-width"}},
    setting_type = "runtime-per-user",
    default_value = 0.25,
	  minimum_value = 0.0
  },
  {
    type = "bool-setting",
    name = "grid-chunk-align",
	  localised_name = {"", {"gui.grid"}, " ", {"gui-map-editor-clone-editor.snap-to-chunk"}},
    setting_type = "runtime-per-user",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "grid-ground",
    localised_name = {"", {"gui-graphics-settings.graphics-quality-low"}, " ", {"gui.grid"}},
    setting_type = "runtime-per-user",
    default_value = true
  },
  {
    type = "int-setting",
    name = "grid-radius",
    localised_name = {"", {"gui.grid"}, " ", {"description.range"}},
    setting_type = "runtime-per-user",
    default_value = 128,
    minimum_value = 0
  },
  {
    type = "int-setting",
    name = "grid-step",
    localised_name = {"", {"gui.grid"}, " ", {"gui-map-generator.scale"}},
    setting_type = "runtime-per-user",
    default_value = 1,
    minimum_value = 0
  },

---------------------------------------------------------------------------------------------------
-- SERVER
---------------------------------------------------------------------------------------------------
  {
    type = "bool-setting",
    name = "disable-zoom",
    localised_name = {"", {"gui-control-behavior-modes.enable-disable"}, " ", {"controls.alt-zoom-out"}},
    setting_type = "runtime-global",
    default_value = true,
  },
  {
    type = "bool-setting",
    name = "disable-flare",
    localised_name = {"", {"gui-control-behavior-modes.enable-disable"}, " ", {"Shortcuts-ick.signal-flare"}},
    setting_type = "runtime-global",
    default_value = true,
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
		default_value = true,
	},
	{
    setting_type = "startup",
		name = "signal-flare",
    localised_name = {"", {"Shortcuts-ick.basic"}, {"Shortcuts-ick.signal-flare"}},
    order = "a[basic]-c[signal-flare]",
		type = "bool-setting",
		default_value = true,
	},
	{
    setting_type = "startup",
		name = "draw-grid",
    localised_name = {"", {"Shortcuts-ick.basic"}, {"gui.grid"}},
    order = "a[basic]-d[draw-grid]",
		type = "bool-setting",
		default_value = true,
	},
	{
    setting_type = "startup",
		name = "rail-block-visualization-toggle",
    localised_name = {"", {"Shortcuts-ick.basic"}, {"gui-interface-settings.show-rail-block-visualization"}},
    order = "a[basic]-e[rail-block-visualization-toggle]",
		type = "bool-setting",
		default_value = true,
	},
	{
    setting_type = "startup",
		name = "toggle-personal-logistic-requests",
    localised_name = {"", {"Shortcuts-ick.basic"}, {"shortcut.toggle-personal-logistic-requests"}},
    order = "a[basic]-f[toggle-personal-logistic-requests]",
		type = "bool-setting",
		default_value = true,
	},
	{
    setting_type = "startup",
		name = "big-zoom",
    localised_name = {"", {"Shortcuts-ick.basic"}, {"controls.alt-zoom-out"}},
    order = "a[basic]-g[big-zoom]",
		type = "bool-setting",
		default_value = true,
	},
})

if mods["MaxRateCalculator"] then
  data:extend({{
      setting_type = "startup",
  		name = "max-rate-calculator",
			localised_name = {"", {"Shortcuts-ick.basic"}, {"item-name.max-rate-calculator"}},
      order = "a[basic]-h[max-rate-calculator]",
      type = "bool-setting",
  		default_value = true,
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
    localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.trees-and-rocks-only"}, ")"},
    order = "b[blueprint]-g[tree-killer]",
		type = "bool-setting",
		default_value = true,
	},
})

if mods["OutpostPlanner"] or mods["OutpostPlannerUpdated"] then
  data:extend({{
      setting_type = "startup",
  		name = "outpost-builder",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.outpost-builder"}},
			order = "b[blueprint]-i[outpost-builder]",
      type = "bool-setting",
  		default_value = true,
  	}})
end

if mods["WellPlanner"] then
  data:extend({{
      setting_type = "startup",
  		name = "well-planner",
			localised_name = {"", "[color=blue]", {"item-name.blueprint"}, ": [/color]", {"item-name.well-planner"}},
			order = "b[blueprint]-j[well-planner]",
      type = "bool-setting",
  		default_value = true,
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
    default_value = true,
  },
	{
    setting_type = "startup",
		name = "discharge-defense-remote",
    localised_name = {"", {"Shortcuts-ick.equipment"}, {"item-name.discharge-defense-remote"}},
    order = "c[equipment]-d[discharge-defense-remote]",
		type = "bool-setting",
		default_value = true,
	},
	{
    setting_type = "startup",
		name = "night-vision-equipment",
    localised_name = {"", {"Shortcuts-ick.equipment"}, {"technology-name.night-vision-equipment"}},
    order = "c[equipment]-e[night-vision-equipment]",
		type = "bool-setting",
		default_value = true,
	},
	{
    setting_type = "startup",
		name = "active-defense-equipment",
    localised_name = {"", {"Shortcuts-ick.equipment"}, {"equipment-name.personal-laser-defense-equipment"}},
    order = "c[equipment]-f[active-defense-equipment]",
		type = "bool-setting",
		default_value = true,
	},

---------------------------------------------------------------------------------------------------
-- STARTUP: ARTILLERY
---------------------------------------------------------------------------------------------------
	{
    setting_type = "startup",
		name = "artillery-targeting-remote",
    localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.artillery-targeting-remote"}},
    order = "d[artillery]-a[artillery-targeting-remote]",
		type = "bool-setting",
		default_value = true,
	},
  {
    setting_type = "startup",
    name = "artillery-toggle",
    localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"Shortcuts-ick.artillery-toggle"}},
    order = "d[artillery]-d[artillery-jammer-tool]",
    type = "string-setting",
    allowed_values = {"disabled", "both", "artillery-wagon", "artillery-turret"},
    default_value = "both",
  },
})

if mods["Orbital Ion Cannon"] then
  data:extend({{
      setting_type = "startup",
  		name = "ion-cannon-targeter",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.ion-cannon-targeter"}},
			order = "d[artillery]-e[ion-cannon-targeter]",
      type = "bool-setting",
  		default_value = true,
  	}})
end

if mods["MIRV"] then
  data:extend({{
      setting_type = "startup",
  		name = "mirv-targeting-remote",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.mirv-targeting-remote"}},
			order = "d[artillery]-f[mirv-targeting-remote]",
      type = "bool-setting",
  		default_value = true,
  	}})
end

---------------------------------------------------------------------------------------------------
-- STARTUP: VEHICLES
---------------------------------------------------------------------------------------------------
data:extend(
{
  {
    setting_type = "startup",
    name = "spidertron-remote",
    localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"item-name.spidertron-remote"}},
    order = "e[vehicle]-a[spidertron-remote]",
    type = "string-setting",
    allowed_values = {"disabled", "enabled", "enabled-hidden"},
    default_value = "enabled",
  },
  {
    setting_type = "startup",
    name = "spidertron-logistics",
    localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"entity-name.spidertron"}, " ", {"gui.enable-logistics-while-moving"}},
    order = "e[vehicle]-b[spidertron-logistics]",
    type = "bool-setting",
    default_value = true,
  },
  {
    setting_type = "startup",
    name = "spidertron-automatic-targeting",
    localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"entity-name.spidertron"}, " ", {"gui-car.automatic-targeting"}},
    order = "e[vehicle]-c[spidertron-automatic-targeting]",
    type = "bool-setting",
    default_value = true,
  },
  {
    setting_type = "startup",
    name = "train-mode-toggle",
    localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]", {"tooltip-category.train"}, " ", {"gui-trains.manual-mode"}},
    order = "e[vehicle]-d[spidertron-automatic-targeting]",
    type = "bool-setting",
    default_value = true,
  },
})

if mods["aai-programmable-vehicles"] then
  data:extend({{
      setting_type = "startup",
      name = "aai-remote-controls",
      localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color] AAI Programmable Vehicles ", {"item-name.unit-remote-control"}},
      order = "e[vehicle]-f[aai-remote-controls]",
      type = "bool-setting",
      default_value = true,
  	}})
end

if mods["VehicleWagon2"] then
  data:extend({{
      setting_type = "startup",
  		name = "winch",
			localised_name = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color] Vehicle Wagon 2 ", {"item-name.winch"}},
      order = "e[vehicle]-h[winch]",
  		type = "bool-setting",
  		default_value = true,
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
    order = "f[other]-b[autogen-color]",
    type = "string-setting",
    allowed_values = {"disabled", "default", "red", "green", "blue"},
    default_value = "default",
  },
})
