--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * settings.lua
 * Mod settings
--]]

--[[ This code has been modified by ickputzdirwech. Removed code is commented out like the following line: ]]
--[[ ORIGINAL: ... ]]
--[[ New lines are marked at the end like the following line: ]]
-- ickputzdirwech

data:extend({
	--	player
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

	--	server
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
		localised_name = {"", {"gui-control-behavior-modes.enable-disable"}, " ", {"technology-name.military"}, " ", {"entity-name.beacon"}},
        setting_type = "runtime-global",
        default_value = true,
    },

	--startup
	{
        type = "string-setting",
        name = "artillery-toggle",
		localised_name = {"", {"item-name.artillery-wagon-cannon"}, " ", {"gui-mod-info.toggle"}, " ", {"description.decorative-type"}},
        setting_type = "startup",
		allowed_values = {"both", "artillery-wagon", "artillery-turret"},
        default_value = "both",
		order = "a"
    },
	{
        type = "string-setting",
        name = "autogen-color",
		localised_name = {"", "Auto-", {"gui-new-game.create"}, " ", {"gui-update.mod"}, " shortcuts ", {"gui-train.color"}},
        setting_type = "startup",
		allowed_values = {"default", "red", "green", "blue"},
        default_value = "default",
		order = "a"
    },
	{
        type = "bool-setting",
        name = "autogen",
		localised_name = {"", "Auto-", {"gui-new-game.create"}, " ", {"gui-update.mod"}, " shortcuts"},
		localised_description = {"", {""}, "Automatically generate shortcuts for mods which are not officially supported by this mod through a script."},
		setting_type = "startup",
		default_value = true,
		order = "a"
    },


	{	--	for each shortcut (to free up space for other modded shortcuts)
		type = "bool-setting",
		name = "artillery-targeting-remote",
		localised_name = {"", {"item-name.artillery-targeting-remote"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	},
	{
		type = "bool-setting",
		name = "draw-grid",
		localised_name = {"", {"gui.grid"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	},
	{
		type = "bool-setting",
		name = "rail-block-visualization-toggle",
		localised_name = {"", {"gui-interface-settings.show-rail-block-visualization"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	},
	{
		type = "bool-setting",
		name = "artillery-jammer-remote",
		localised_name = {"", {"gui-mod-info.toggle"}, " ", {"entity-name.artillery-wagon"}, " ", {"damage-type-name.fire"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	},
	{
		type = "bool-setting",
		name = "tree-killer",
		localised_name = {"", {"item-name.deconstruction-planner"}, " (", {"gui-deconstruction.whitelist-trees-and-rocks"}, ") ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	},
	{
		type = "bool-setting",
		name = "discharge-defense-remote",
		localised_name = {"", {"item-name.discharge-defense-remote"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	},
	{
		type = "bool-setting",
		name = "flashlight-toggle",
		localised_name = {"", {"entity-name.small-lamp"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	},
	{
		type = "bool-setting",
		name = "big-zoom",
		localised_name = {"", {"controls.alt-zoom-out"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	},
	{
		type = "bool-setting",
		name = "signal-flare",
		localised_name = {"", {"technology-name.military"}, " ", {"entity-name.beacon"}, " (", {"description.force"}, " ", {"deconstruction-tile-mode.only"}, ") ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "za"
	}
})

	--	Since we cannot conditionally extend mod settings, we have to implement them whether the mod is enabled or not :(
	--	This can break the localization of the shortcut if the mod is not installed
data:extend(
{
  --[[ ORIGINAL:
	{
		type = "bool-setting",
		name = "resource-monitor",
		localised_name = {"", {"item-name.resource-monitor"}, " ", {"gui-mod-info.toggle"}, " (LEGACY YARM)"},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = false,
		order = "zz"
	},
  ]]
	{
		type = "bool-setting",
		name = "path-remote-control",
    --[[ ORIGINAL:
		localised_name = {"", {"item-name.path-remote-control"}, " ", {"gui-mod-info.toggle"}, " (LEGACY AAI)"},
    ]]
    localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = false,
		order = "zz"
	},
	{
		type = "bool-setting",
		name = "unit-remote-control",
    --[[ ORIGINAL:
		localised_name = {"", {"item-name.unit-remote-control"}, " ", {"gui-mod-info.toggle"}, " (LEGACY AAI)"},
    ]]
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = false,
		order = "zz"
	},
	{
		type = "bool-setting",
		name = "outpost-builder",
    --[[ ORIGINAL:
		localised_name = {"", {"item-name.outpost-builder"}, " ", {"gui-mod-info.toggle"}},
    ]]
    localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
    setting_type = "startup",
		default_value = true,
		order = "zz"
	},
	{
		type = "bool-setting",
		name = "ion-cannon-targeter",
    --[[ ORIGINAL:
		localised_name = {"", {"item-name.ion-cannon-targeter"}, " ", {"gui-mod-info.toggle"}},
    ]]
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "zz"
	},
	{
		type = "bool-setting",
		name = "max-rate-calculator",
    --[[ ORIGINAL:
		localised_name = {"", {"item-name.max-rate-calculator"}, " ", {"gui-mod-info.toggle"}},
    ]]
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "zz"
	},
	{
		type = "bool-setting",
		name = "module-inserter",
    --[[ ORIGINAL:
		localised_name = {"", {"item-name.module-inserter"}, " ", {"gui-mod-info.toggle"}},
    ]]
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "zz"
	},
	{
		type = "bool-setting",
		name = "night-vision-equipment",
		localised_name = {"", {"equipment-name.night-vision-equipment"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "zz"
	},
	{
		type = "bool-setting",
		name = "active-defense-equipment",
		localised_name = {"", {"equipment-name.personal-laser-defense-equipment"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "zz"
	},
	{
		type = "bool-setting",
		name = "belt-immunity-equipment",
		localised_name = {"", {"equipment-name.belt-immunity-equipment"}, " ", {"gui-mod-info.toggle"}},
		localised_description = {"", {""}, "Disable specific shortcuts to free up space for other modded shortcuts, or to slightly increase performance and load time."},
		setting_type = "startup",
		default_value = true,
		order = "zz"
	}
})
