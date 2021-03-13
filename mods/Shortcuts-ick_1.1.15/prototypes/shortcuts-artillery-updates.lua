--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio.
 * This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-artillery-updates.lua:
	* Ion cannon targeter shortcut and custom input
]]

if mods["Orbital Ion Cannon"] and data.raw.item["ion-cannon-targeter"] and settings.startup["ion-cannon-targeter"].value == true then
	if data.raw.item["ion-cannon-targeter"].flags then
		table.insert(data.raw.item["ion-cannon-targeter"].flags, "only-in-cursor")
		table.insert(data.raw.item["ion-cannon-targeter"].flags, "spawnable")
	else
		data.raw.item["ion-cannon-targeter"].flags = {"only-in-cursor", "spawnable"}
	end
	data:extend(
	{
		{
			type = "shortcut",
			name = "ion-cannon-targeter",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.ion-cannon-targeter"}, {"Shortcuts-ick.control", "ion-cannon-targeter"}},
			order = "d[artillery]-e[ion-cannon-targeter]",
			--associated_control_input = "ion-cannon-targeter",
			action = "lua",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/ion-cannon-targeter-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/ion-cannon-targeter-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
	  {
			type = "custom-input",
	    name = "ion-cannon-targeter",
			localised_name = {"", "[color=red]", {"technology-name.artillery"}, ": [/color]", {"item-name.ion-cannon-targeter"}},
			order = "d[artillery]-e[ion-cannon-targeter]",
	    key_sequence = "",
	  },
	})
end
