--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of shortcuts-vehicle.lua:
	* Driver is gunner shortcut.
	* Spidertron Enable/disable logistics while moving shortcut.
	* Vehicle logistic shortcut.
	* Spidertron Auto targeting with gunner shortcut.
	* Spidertron Auto targeting without gunner shortcut.
	* Train mode toggle shortcut.
]]

-- TAGS
local driver_is_gunner
local logistics
local spidertron
local train
if settings.startup["ick-tags"].value == "tags" then
	local tag = {"", "[color=orange]", {"tooltip-category.vehicle"}, ": [/color]"}
	driver_is_gunner = tag
	logistics = tag
	spidertron = tag
	train = tag
elseif settings.startup["ick-tags"].value == "icons" then
	driver_is_gunner = "[img=item/submachine-gun] "
	logistics = "[img=item/logistics-robot] "
	spidertron = "[img=item/spidertron] "
	train = "[img=item/locomotive] "
else
	driver_is_gunner = ""
	logistics = ""
	spidertron = ""
	train = ""
end

-- DRIVER IS GUNNER
if settings.startup["driver-is-gunner"].value then
	data:extend({{
		type = "shortcut",
		name = "driver-is-gunner",
		localised_name = {"", driver_is_gunner, {"Shortcuts-ick.driver-is-gunner"}},
		order = "e[vehicle]-a[driver-is-gunner]",
		action = "lua",
		toggleable = true,
		style = "red",
		icon = "__Shortcuts-ick__/graphics/driver-is-gunner-x32-2-white.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/driver-is-gunner-x32-2-white.png",
		small_icon_size = 32
	}})
end

-- VEHICLE LOGISTICS WHILE MOVING
if settings.startup["vehicle-logistics-while-moving"].value then
	data:extend({{
		type = "shortcut",
		name = "vehicle-logistics-while-moving",
		localised_name = {"", logistics, {"gui.enable-logistics-while-moving"}},
		order = "e[vehicle]-c[vehicle-logistics]",
		action = "lua",
		toggleable = true,
		style = "green",
		icon = "__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-roboport-x56.png",
		icon_size = 56,
		small_icon = "__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-roboport-x24.png",
		small_icon_size = 24
	}})
end

-- VEHICLE LOGISTIC
if settings.startup["vehicle-logistic-requests"].value then
	data:extend({{
		type = "shortcut",
		name = "vehicle-logistic-requests",
		localised_name = {"", logistics, {"gui-logistic.vehicle-logistics-and-trash"}},
		order = "e[vehicle]-d[vehicle-logistic-requests]",
		action = "lua",
		toggleable = true,
		style = "green",
		icons = {
			{
				icon = "__Shortcuts-ick__/graphics/toggle-personal-logistics-x32.png",
				icon_size = 32,
				scale = 2
			},
			{
				icon = "__Shortcuts-ick__/graphics/driver-is-gunner-x32-2-white.png",
				icon_size = 32,
				scale = 1.5,
				shift = {16, 16}
			}
		},
		small_icons = {
			{
				icon = "__Shortcuts-ick__/graphics/toggle-personal-logistics-x32.png",
				icon_size = 32,
				scale = 2
			},
			{
				icon = "__Shortcuts-ick__/graphics/driver-is-gunner-x32-2-white.png",
				icon_size = 32,
				scale = 1.5,
				shift = {16, 16}
			}
		}
	}})
end

-- VEHICLE TRASH UNREQUESTED
if settings.startup["vehicle-trash-not-requested"].value then
	data:extend({{
		type = "shortcut",
		name = "vehicle-trash-not-requested",
		localised_name = {"", logistics, {"trash-not-requested-items"}},
		order = "e[vehicle]-e[vehicle-trash-not-requested]",
		action = "lua",
		toggleable = true,
		style = "green",
		icons = {
			{
				icon = "__core__/graphics/icons/mip/trash.png",
				icon_size = 32,
				scale = 2
			},
			{
				icon = "__Shortcuts-ick__/graphics/driver-is-gunner-x32-2-white.png",
				icon_size = 32,
				scale = 1.5,
				shift = {16, 16}
			}
		},
		small_icons = {
			{
				icon = "__core__/graphics/icons/mip/trash.png",
				icon_size = 32,
				scale = 2
			},
			{
				icon = "__Shortcuts-ick__/graphics/driver-is-gunner-x32-2-white.png",
				icon_size = 32,
				scale = 1.5,
				shift = {16, 16}
			}
		}
	}})
end

-- SPIDERTRON TARGETING WITH GUNNER
if settings.startup["targeting-with-gunner"].value then
	data:extend({{
		type = "shortcut",
		name = "targeting-with-gunner",
		localised_name = {"", spidertron, {"entity-name.spidertron"}, " ", {"gui-car.automatic-targeting"}, " ", {"gui-car.with-gunner"}},
		order = "e[vehicle]-f[targeting-with-gunner]",
		action = "lua",
		toggleable = true,
		style = "green",
		icon = "__Shortcuts-ick__/graphics/spidertron-targeting-with-gunner-x32-2-white.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/spidertron-targeting-with-gunner-x32-2-white.png",
		small_icon_size = 32
	}})
end

-- SPIDERTRON TARGETING WITHOUT GUNNER
if settings.startup["targeting-without-gunner"].value then
	data:extend({{
		type = "shortcut",
		name = "targeting-without-gunner",
		localised_name = {"", spidertron, {"entity-name.spidertron"}, " ", {"gui-car.automatic-targeting"}, " ", {"gui-car.without-gunner"}},
		order = "e[vehicle]-g[targeting-with-gunner]",
		action = "lua",
		toggleable = true,
		style = "green",
		icon = "__Shortcuts-ick__/graphics/driver-is-gunner-x32-2-white.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/driver-is-gunner-x32-2-white.png",
		small_icon_size = 32
	}})
end

-- TRAIN MODE TOGGLE
if settings.startup["train-mode-toggle"].value then
	data:extend({{
		type = "shortcut",
		name = "train-mode-toggle",
		localised_name = {"", train, {"tooltip-category.train"}, " ", {"gui-trains.manual-mode"}},
		order = "e[vehicle]-h[train-mode-toggle]",
		action = "lua",
		toggleable = true,
		icon = "__Shortcuts-ick__/graphics/train-mode-toggle-x32-2.png",
		icon_size = 32,
		small_icon = "__Shortcuts-ick__/graphics/train-mode-toggle-x32-2.png",
		small_icon_size = 32
	}})
end
