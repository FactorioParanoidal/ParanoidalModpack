--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview custom-inputs-updates.lua:
	* Generation of custom inputs.
]]

local shortcuts = {
	"artillery-jammer-tool",

	"flashlight-toggle",
	"signal-flare",
	"draw-grid",
	"rail-block-visualization-toggle",
	"player-trash-not-requested",
	"big-zoom",
	"minimap",

	"tree-killer",

	"belt-immunity-equipment",
	"night-vision-equipment",
	"active-defense-equipment",

	"driver-is-gunner",
	"vehicle-logistics-while-moving",
	"vehicle-logistic-requests",
	"vehicle-trash-not-requested",
	"targeting-with-gunner",
	"targeting-without-gunner",
	"train-mode-toggle",
}

for _, name in pairs(shortcuts) do
	if data.raw.shortcut[name] then
		data:extend({{
			type = "custom-input",
			name = data.raw.shortcut[name].name,
			localised_name = data.raw.shortcut[name].localised_name,
			order = data.raw.shortcut[name].order,
			key_sequence = ""
		}})
		data.raw.shortcut[name].localised_name = {"", data.raw.shortcut[name].localised_name, " ", {"Shortcuts-ick.control-" .. name}}
	end
end
