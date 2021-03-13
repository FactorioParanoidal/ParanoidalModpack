--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio.
 * This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-equipment.lua:
	* Belt immunity equipment shortcut and custom input
	* Discharge defense remote shortcut and custom input
	* Night vision equipment shortcut and custom input
	* Personal laser defense shortcut and custom input
]]

if settings.startup["belt-immunity-equipment"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "belt-immunity-equipment",
			localised_name = {"", {"Shortcuts-ick.equipment"}, {"item-name.belt-immunity-equipment"}, {"Shortcuts-ick.control", "belt-immunity-equipment"}},
			order = "c[equipment-c[belt-immunity-equipment]",
			--associated_control_input = "belt-immunity-equipment",
			action = "lua",
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x32.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			disabled_icon =
			{
				filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
		{
			type = "custom-input",
			name = "belt-immunity-equipment",
			localised_name = {"", {"Shortcuts-ick.equipment"}, {"item-name.belt-immunity-equipment"}},
			order = "c[equipment]-c[belt-immunity-equipment]",
			key_sequence = "",
		},
	})
end


if settings.startup["discharge-defense-remote"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "discharge-defense-remote",
			localised_name = {"", {"Shortcuts-ick.equipment"}, {"item-name.discharge-defense-remote"}, {"Shortcuts-ick.control", "discharge-defense-remote"}},
			order = "c[equipment]-d[discharge-defense-remote]",
			--associated_control_input = "discharge-defense-remote",
			action = "lua",
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/discharge-defense-remote-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/discharge-defense-remote-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
		{
			type = "custom-input",
			name = "discharge-defense-remote",
			localised_name = {"", {"Shortcuts-ick.equipment"}, {"item-name.discharge-defense-remote"}},
			order = "c[equipment]-d[discharge-defense-remote]",
			key_sequence = "",
		},
	})
end


if settings.startup["night-vision-equipment"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "night-vision-equipment",
			localised_name = {"", {"Shortcuts-ick.equipment"}, {"technology-name.night-vision-equipment"}, {"Shortcuts-ick.control", "night-vision-equipment"}},
			order = "c[equipment]-e[night-vision-equipment]",
			--associated_control_input = "night-vision-equipment",
			action = "lua",
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x32.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			disabled_icon =
			{
				filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
		{
			type = "custom-input",
			name = "night-vision-equipment",
			order = "c[equipment]-e[night-vision-equipment]",
			localised_name = {"", {"Shortcuts-ick.equipment"}, {"technology-name.night-vision-equipment"}},
			key_sequence = "",
		},
	})
end


if settings.startup["active-defense-equipment"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "active-defense-equipment",
			localised_name = {"", {"Shortcuts-ick.equipment"}, {"equipment-name.personal-laser-defense-equipment"}, {"Shortcuts-ick.control", "active-defense-equipment"}},
			order = "c[equipment]-f[active-defense-equipment]",
			--associated_control_input = "active-defense-equipment",
			action = "lua",
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x32.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			disabled_icon =
			{
				filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 0.5,
				flags = {"gui-icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 0.5,
				flags = {"gui-icon"}
			},
		},
		{
			type = "custom-input",
			name = "active-defense-equipment",
			localised_name = {"", {"Shortcuts-ick.equipment"}, {"equipment-name.personal-laser-defense-equipment"}},
			order = "c[equipment]-f[active-defense-equipment]",
			key_sequence = "",
		},
	})
end
