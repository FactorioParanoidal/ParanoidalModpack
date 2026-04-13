-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "warfare",
	type = "technology",
	technology_icon_size = 256,
}

---@type CreateIconsFromListTable
local technologies = {
	-- Gun turrets
	["gun-turret"] = { icon_name = "gun-turrets", tier = 1 }, -- t1 gun, technically part of revamp
	["bob-turrets-2"] = { icon_name = "gun-turrets", tier = 2 }, -- t2 turret
	["bob-turrets-3"] = { icon_name = "gun-turrets", tier = 3 }, -- t3 turret
	["bob-turrets-4"] = { icon_name = "gun-turrets", tier = 4 }, -- t4 turret
	["bob-turrets-5"] = { icon_name = "gun-turrets", tier = 5 }, -- t5 turret

	-- Sniper turrets
	["bob-sniper-turrets-1"] = { icon_name = "sniper-turrets", tier = 1, prog_tier = 1 }, -- t1 sniper
	["bob-sniper-turrets-2"] = { icon_name = "sniper-turrets", tier = 2, prog_tier = 3 }, -- t3 sniper
	["bob-sniper-turrets-3"] = { icon_name = "sniper-turrets", tier = 3, prog_tier = 5 }, -- t5 sniper

	-- Laser turrets
	["laser-turret"] = { icon_name = "laser-turrets", tier = 1 }, -- t1 laser
	["bob-laser-turrets-2"] = { icon_name = "laser-turrets", tier = 2 }, -- t2 laser
	["bob-laser-turrets-3"] = { icon_name = "laser-turrets", tier = 3 }, -- t3 laser
	["bob-laser-turrets-4"] = { icon_name = "laser-turrets", tier = 4 }, -- t4 laser
	["bob-laser-turrets-5"] = { icon_name = "laser-turrets", tier = 5 }, -- t5 laser

	-- Plasma turrets
	["bob-plasma-turrets-1"] = { icon_name = "plasma-turrets", tier = 1, prog_tier = 3 }, -- t1 plasma
	["bob-plasma-turrets-2"] = { icon_name = "plasma-turrets", tier = 2, prog_tier = 4 },
	["bob-plasma-turrets-3"] = { icon_name = "plasma-turrets", tier = 3, prog_tier = 5 },
	["bob-plasma-turrets-4"] = { icon_name = "plasma-turrets", tier = 4, prog_tier = 6 },

	-- Artillery and artillery wagons
	["artillery"] = { icon_name = "artillery", tier = 1, prog_tier = 3 }, -- t3 arty/train arty
	["bob-artillery-turret-2"] = { icon_name = "artillery", tier = 2, prog_tier = 4 }, -- t4 arty
	["bob-artillery-turret-3"] = { icon_name = "artillery", tier = 3, prog_tier = 5 }, -- t5 arty
	["bob-artillery-wagon-2"] = { icon_name = "artillery-wagons", tier = 2, prog_tier = 4 }, -- t4 train arty
	["bob-artillery-wagon-3"] = { icon_name = "artillery-wagons", tier = 3, prog_tier = 5 }, -- t5 train arty

	-- Military progression
	-- ["military"] = {},
	-- ["military-3"] = {}, -- poison/slowdown capsules, auto shotty, napalm, sniper
	-- ["military-4"] = {}, -- piercing shotgun shells, cluster grenade

	-- Armor
	-- ["heavy-armor"] = {}, -- probably fine? Depends how armor is handled
	-- ["bob-armor-making-3"] = { subgroup = "armor", flat_icon = true }, -- invar cobalt-steel armor (heavy-armor-2)
	-- ["bob-armor-making-4"] = { subgroup = "armor", flat_icon = true }, -- titanium-ceramic armor
	-- ["power-armor"] = {}, -- power armor first entry
	-- ["power-armor-mk2"] = {}, -- 2nd power armor
	["bob-power-armor-3"] = { subgroup = "armor", flat_icon = true },
	["bob-power-armor-4"] = { subgroup = "armor", flat_icon = true },
	["bob-power-armor-5"] = { subgroup = "armor", flat_icon = true },

	-- Tanks
	["tank"] = { icon_name = "tank", tier = 1, prog_tier = 3 }, -- t2 tank
	["bob-tanks-2"] = { icon_name = "tank", tier = 2, prog_tier = 4 }, -- t4 tank
	["bob-tanks-3"] = { icon_name = "tank", tier = 3, prog_tier = 5 },

	-- Tank robots
	["bob-robot-gun-drones"] = { icon_name = "drone", tint = util.color("#f2f230") },
	["bob-robot-laser-drones"] = { icon_name = "drone", tint = util.color("#30f271") },
	["bob-robot-flamethrower-drones"] = { icon_name = "drone", tint = util.color("#f25730") },
	["bob-robot-plasma-drones"] = { icon_name = "drone", tint = util.color("#30a5f2") },

	-- Robots
	["bob-laser-robot"] = { subgroup = "robots", flat_icon = true },

	-- Spidertrons
	["bob-walking-vehicle"] = { subgroup = "spidertron", flat_icon = true }, -- "Antron"
	["bob-tankotron"] = { subgroup = "spidertron", flat_icon = true }, -- "Tankotron"
	["bob-logistic-spidertron"] = { subgroup = "spidertron", flat_icon = true }, -- "Logitron"
	-- ["spidertron"] = {}, -- "Spidertron"
	["bob-heavy-spidertron"] = { subgroup = "spidertron", flat_icon = true }, -- "Heavy spidertron"
}

reskins.internal.create_icons_from_list(technologies, inputs)
