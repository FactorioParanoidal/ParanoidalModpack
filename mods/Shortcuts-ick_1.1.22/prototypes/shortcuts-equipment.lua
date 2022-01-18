--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-equipment.lua:
	* Belt immunity equipment shortcut.
	* Discharge defense remote shortcut.
	* Night vision equipment shortcut.
	* Personal laser defense shortcut.
	* (Jetpack shortcut.)
]]

local belt_immunity_equipment = ""
local discharge_defense_remote = ""
local night_vision_equipment = ""
local personal_laser_defense_equipment = ""
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"Shortcuts-ick.equipment"}
	belt_immunity_equipment = tag
	discharge_defense_remote = tag
	night_vision_equipment = tag
	personal_laser_defense_equipment = tag
elseif settings.startup["ick-tags"].value == "icons" then
	belt_immunity_equipment = "[img=item/belt-immunity-equipment] "
	discharge_defense_remote = "[img=item/discharge-defense-remote] "
	night_vision_equipment = "[img=item/night-vision-equipment] "
	personal_laser_defense_equipment = "[img=item/personal-laser-defense-equipment] "
end


if settings.startup["belt-immunity-equipment"].value then
	data:extend(
	{
		{
			type = "shortcut",
			name = "belt-immunity-equipment",
			localised_name = {"", belt_immunity_equipment, {"item-name.belt-immunity-equipment"}},
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
			}
		}
	})
end


if settings.startup["discharge-defense-remote"].value then
	data:extend(
	{
		{
			type = "shortcut",
			name = "discharge-defense-remote",
			localised_name = {"", discharge_defense_remote, {"item-name.discharge-defense-remote"}},
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
			}
		}
	})
end


if settings.startup["night-vision-equipment"].value then
	data:extend(
	{
		{
			type = "shortcut",
			name = "night-vision-equipment",
			localised_name = {"", night_vision_equipment, {"technology-name.night-vision-equipment"}},
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
			}
		}
	})
end


if settings.startup["active-defense-equipment"].value then
	data:extend(
	{
		{
			type = "shortcut",
			name = "active-defense-equipment",
			localised_name = {"", personal_laser_defense_equipment, {"equipment-name.personal-laser-defense-equipment"}},
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
			}
		}
	})
end


--[[
if mods["jetpack"] and settings.startup["jetpack"].value then
	if settings.startup["jetpack"].value then
		data:extend(
		{
			{
				type = "shortcut",
				name = "jetpack",
				localised_name = {"", {"Shortcuts-ick.equipment"}, {"mod-name.jetpack"}},
				order = "c[equipment]-g[jetpack]",
				associated_control_input = "jetpack",
				action = "lua",
				toggleable = true,
				icon =
				{
					filename = "__Shortcuts-ick__/graphics/jetpack-x32.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 0.5,
					mipmap_count = 2,
					flags = {"gui-icon"}
				},
				small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/jetpack-x24.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 0.5,
					flags = {"gui-icon"}
				},
				disabled_icon =
				{
					filename = "__Shortcuts-ick__/graphics/jetpack-x32-white.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 0.5,
					flags = {"gui-icon"}
				},
				disabled_small_icon =
				{
					filename = "__Shortcuts-ick__/graphics/jetpack-x24-white.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 0.5,
					flags = {"gui-icon"}
				}
			}
		})
	end
end
]]
