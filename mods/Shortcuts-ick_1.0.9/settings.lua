--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * settings.lua
 * Mod settings
--]]

-- This code has been modified by ickputzdirwech.

data:extend(
{
	--	PER PLAYER
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

  --	SERVER
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
    localised_name = {"", {"gui-control-behavior-modes.enable-disable"}, " ", "Emergency locator beacon"},
    setting_type = "runtime-global",
    default_value = true,
  },

  -- STARTUP
  -- BASIC
	{
		type = "bool-setting",
		name = "flashlight-toggle",
		localised_name = {"", "[color=green]Basic:[/color] ", {"entity-name.character"}, " ", {"entity-name.small-lamp"}},
		setting_type = "startup",
		default_value = true,
    order = "a[basic]-b[flashlight-toggle]",
	},
	{
		type = "bool-setting",
		name = "signal-flare",
    localised_name = "[color=green]Basic:[/color] Emergency locator beacon",
    setting_type = "startup",
		default_value = true,
    order = "a[basic]-c[signal-flare]",
	},
	{
		type = "bool-setting",
		name = "draw-grid",
		localised_name = {"", "[color=green]Basic:[/color] ", {"gui.grid"}},
		setting_type = "startup",
		default_value = true,
    order = "a[basic]-d[draw-grid]",
	},
	{
		type = "bool-setting",
		name = "rail-block-visualization-toggle",
		localised_name = {"", "[color=green]Basic:[/color] ", {"gui-interface-settings.show-rail-block-visualization"}},
		setting_type = "startup",
		default_value = true,
    order = "a[basic]-e[rail-block-visualization-toggle]",
	},
	{
		type = "bool-setting",
		name = "big-zoom",
		localised_name = {"", "[color=green]Basic:[/color] ", {"controls.alt-zoom-out"}},
		setting_type = "startup",
		default_value = true,
    order = "a[basic]-f[big-zoom]",
	},

  -- BLUEPRINT
	{
		type = "bool-setting",
		name = "tree-killer",
		localised_name = {"", "[color=blue]Blueprint:[/color] ", {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.whitelist-trees-and-rocks"}, ")"},
		setting_type = "startup",
		default_value = true,
    order = "b[blueprint]-g[tree-killer]",
	},

  -- TOGGLES
  {
    type = "bool-setting",
    name = "belt-immunity-equipment",
    localised_name = {"", "[color=purple]Equipment:[/color] ", {"equipment-name.belt-immunity-equipment"}},
    setting_type = "startup",
    default_value = true,
    order = "c[toggles]-c[belt-immunity-equipment]",
  },
	{
		type = "bool-setting",
		name = "night-vision-equipment",
		localised_name = {"", "[color=purple]Equipment:[/color] ", {"equipment-name.night-vision-equipment"}},
		setting_type = "startup",
		default_value = true,
    order = "c[toggles]-d[night-vision-equipment]",
	},
	{
		type = "bool-setting",
		name = "active-defense-equipment",
		localised_name = {"", "[color=purple]Equipment:[/color] ", {"equipment-name.personal-laser-defense-equipment"}},
		setting_type = "startup",
		default_value = true,
    order = "c[toggles]-f[active-defense-equipment]",
	},

  -- REMOTES
	{
		type = "bool-setting",
		name = "artillery-targeting-remote",
		localised_name = {"", "[color=orange]Remotes:[/color] ", {"item-name.artillery-targeting-remote"}},
		setting_type = "startup",
		default_value = true,
    order = "d[remotes]-a[artillery-targeting-remote]",
	},
  {
    type = "string-setting",
    name = "artillery-toggle",
    localised_name = {"", "[color=orange]Remotes:[/color] ", {"item-name.artillery-wagon-cannon"}, " toggle and select affected entities"},
    setting_type = "startup",
    allowed_values = {"disabled", "both", "Artillery wagon", "Artillery turret"},
    default_value = "both",
    order = "d[remotes]-b[artillery-jammer-remote]",
  },
	{
		type = "bool-setting",
		name = "discharge-defense-remote",
		localised_name = {"", "[color=orange]Remotes:[/color] ", {"item-name.discharge-defense-remote"}},
		setting_type = "startup",
		default_value = true,
    order = "d[remotes]-c[discharge-defense-remote]",
	},
  {
    type = "string-setting",
    name = "spidertron-remote",
    localised_name = {"", "[color=orange]Remotes:[/color] ",{"item-name.spidertron-remote"}},
    setting_type = "startup",
    allowed_values = {"disabled", "enabled", "enabled (hide remote from inventory)"},
    default_value = "enabled",
    order = "d[remotes]-d[spidertron-remote]",
  },

  -- MODS
  {
    type = "string-setting",
    name = "autogen-color",
    localised_name = "[color=red]Mod:[/color] Automatically generate mod shortcuts and select their color",
    setting_type = "startup",
    allowed_values = {"disabled", "default", "red", "green", "blue"},
    default_value = "default",
    order = "e[mods]-a",
  },
})

if mods["aai-programmable-vehicles"] then
  data:extend({{
      type = "bool-setting",
      name = "aai-remote-controls",
      setting_type = "startup",
      default_value = true,
      order = "e[mods]-b[aai-remote-controls]",
  	}})
end

if mods["Orbital Ion Cannon"] then
  data:extend({{
      type = "bool-setting",
  		name = "ion-cannon-targeter",
  		setting_type = "startup",
  		default_value = true,
      order = "e[mods]-c[ion-cannon-targeter]",
  	}})
end

if mods["MaxRateCalculator"] then
  data:extend({{
      type = "bool-setting",
  		name = "max-rate-calculator",
  		setting_type = "startup",
  		default_value = true,
      order = "e[mods]-d[max-rate-calculator]",
  	}})
end

if mods["OutpostPlanner"] then
  data:extend({{
      type = "bool-setting",
  		name = "outpost-builder",
      setting_type = "startup",
  		default_value = true,
      order = "e[mods]-e[outpost-builder]",
  	}})
end

if mods["VehicleWagon2"] then
  data:extend({{
  		type = "bool-setting",
  		name = "vehicle-wagon-2-winch",
  		setting_type = "startup",
  		default_value = true,
      order = "e[mods]-f[vehicle-wagon-2-winch]",
  	}})
end
