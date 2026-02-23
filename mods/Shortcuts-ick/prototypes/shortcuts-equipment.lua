--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-equipment.lua:
	* Belt immunity equipment shortcut.
	* Night vision equipment shortcut.
	* Personal laser defense shortcut.
	* (Jetpack shortcut.)
]]

-- TAGS
local belt_immunity_equipment
local night_vision_equipment
local personal_laser_defense_equipment
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"Shortcuts-ick.equipment"}
	belt_immunity_equipment = tag
	night_vision_equipment = tag
	personal_laser_defense_equipment = tag
elseif settings.startup["ick-tags"].value == "icons" then
	belt_immunity_equipment = "[img=item/belt-immunity-equipment] "
	night_vision_equipment = "[img=item/night-vision-equipment] "
	personal_laser_defense_equipment = "[img=item/personal-laser-defense-equipment] "
else
	belt_immunity_equipment = ""
	night_vision_equipment = ""
	personal_laser_defense_equipment = ""
end

-- BELT IMMUNITY EQUIPMENT
if settings.startup["belt-immunity-equipment"].value then
	data:extend({{
		type = "shortcut",
		name = "belt-immunity-equipment",
		localised_name = {"", belt_immunity_equipment, {"item-name.belt-immunity-equipment"}},
		order = "c[equipment-c[belt-immunity-equipment]",
		action = "lua",
		toggleable = true,
		icon = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x32.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x24.png",
		small_icon_size = 24
	}})
end

-- NIGHT VISION EQUIPMENT
if settings.startup["night-vision-equipment"].value then
	data:extend({{
		type = "shortcut",
		name = "night-vision-equipment",
		localised_name = {"", night_vision_equipment, {"technology-name.night-vision-equipment"}},
		order = "c[equipment]-e[night-vision-equipment]",
		action = "lua",
		toggleable = true,
		icon = "__Shortcuts-ick__/graphics/night-vision-toggle-x32.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/night-vision-toggle-x24.png",
		small_icon_size = 24
	}})
end

-- PERSONAL LASER DEFENSE
if settings.startup["active-defense-equipment"].value then
	data:extend({{
		type = "shortcut",
		name = "active-defense-equipment",
		localised_name = {"", personal_laser_defense_equipment, {"equipment-name.personal-laser-defense-equipment"}},
		order = "c[equipment]-f[active-defense-equipment]",
		action = "lua",
		toggleable = true,
		icon = "__Shortcuts-ick__/graphics/active-defense-equipment-x32.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/active-defense-equipment-x24.png",
		small_icon_size = 24
	}})
end
