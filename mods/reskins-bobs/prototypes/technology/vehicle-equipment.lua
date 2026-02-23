-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.vehicle_equipment.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "vehicle-equipment",
	type = "technology",
	technology_icon_extras = { reskins.lib.technology_equipment_overlay({ is_vehicle = true, scale = 1 }) },
	technology_icon_size = 256,
}

---@type CreateIconsFromListTable
local technologies = {
	-- Plasma cannons
	["bob-vehicle-big-turret-equipment-1"] = { icon_name = "vehicle-plasma-turret", tier = 1, prog_tier = 3 },
	["bob-vehicle-big-turret-equipment-2"] = { icon_name = "vehicle-plasma-turret", tier = 2, prog_tier = 4 },
	["bob-vehicle-big-turret-equipment-3"] = { icon_name = "vehicle-plasma-turret", tier = 3, prog_tier = 5 },
	["bob-vehicle-big-turret-equipment-4"] = { icon_name = "vehicle-plasma-turret", tier = 4, prog_tier = 6 },

	-- Roboport modular equipment
	["bob-vehicle-roboport-modular-equipment-1"] = { group = "equipment", icon_name = "modular-equipment", icon_base = "modular-equipment-1", tier = 1, prog_tier = 2 },
	["bob-vehicle-roboport-modular-equipment-2"] = { group = "equipment", icon_name = "modular-equipment", icon_base = "modular-equipment-2", tier = 2, prog_tier = 3 },
	["bob-vehicle-roboport-modular-equipment-3"] = { group = "equipment", icon_name = "modular-equipment", icon_base = "modular-equipment-3", tier = 3, prog_tier = 4 },
	["bob-vehicle-roboport-modular-equipment-4"] = { group = "equipment", icon_name = "modular-equipment", icon_base = "modular-equipment-4", tier = 4, prog_tier = 5 },

	-- Fusion cells
	["bob-vehicle-fission-cell-equipment-1"] = { icon_name = "vehicle-fission-cell", tier = 1 },
	["bob-vehicle-fission-cell-equipment-2"] = { icon_name = "vehicle-fission-cell", tier = 2 },
	["bob-vehicle-fission-cell-equipment-3"] = { icon_name = "vehicle-fission-cell", tier = 3 },
	["bob-vehicle-fission-cell-equipment-4"] = { icon_name = "vehicle-fission-cell", tier = 4 },
	["bob-vehicle-fission-cell-equipment-5"] = { icon_name = "vehicle-fission-cell", tier = 5 },
	["bob-vehicle-fission-cell-equipment-6"] = { icon_name = "vehicle-fission-cell", tier = 6 },

	-- Solar panels
	["bob-vehicle-solar-panel-equipment-1"] = { group = "equipment", icon_name = "solar-panel", tier = 1, prog_tier = 2 },
	["bob-vehicle-solar-panel-equipment-2"] = { group = "equipment", icon_name = "solar-panel", tier = 2, prog_tier = 3 },
	["bob-vehicle-solar-panel-equipment-3"] = { group = "equipment", icon_name = "solar-panel", tier = 3, prog_tier = 4 },
	["bob-vehicle-solar-panel-equipment-4"] = { group = "equipment", icon_name = "solar-panel", tier = 4, prog_tier = 5 },
	["bob-vehicle-solar-panel-equipment-5"] = { group = "equipment", icon_name = "solar-panel", tier = 5, prog_tier = 6 },

	-- Batteries
	["bob-vehicle-battery-equipment-1"] = { icon_name = "vehicle-battery", tier = 1 },
	["bob-vehicle-battery-equipment-2"] = { icon_name = "vehicle-battery", tier = 2 },
	["bob-vehicle-battery-equipment-3"] = { icon_name = "vehicle-battery", tier = 3 },
	["bob-vehicle-battery-equipment-4"] = { icon_name = "vehicle-battery", tier = 4 },
	["bob-vehicle-battery-equipment-5"] = { icon_name = "vehicle-battery", tier = 5 },
	["bob-vehicle-battery-equipment-6"] = { icon_name = "vehicle-battery", tier = 6 },

	-- Laser defense
	["bob-vehicle-laser-defense-equipment-1"] = { group = "equipment", icon_name = "laser-defense", tier = 1 },
	["bob-vehicle-laser-defense-equipment-2"] = { group = "equipment", icon_name = "laser-defense", tier = 2 },
	["bob-vehicle-laser-defense-equipment-3"] = { group = "equipment", icon_name = "laser-defense", tier = 3 },
	["bob-vehicle-laser-defense-equipment-4"] = { group = "equipment", icon_name = "laser-defense", tier = 4 },
	["bob-vehicle-laser-defense-equipment-5"] = { group = "equipment", icon_name = "laser-defense", tier = 5 },
	["bob-vehicle-laser-defense-equipment-6"] = { group = "equipment", icon_name = "laser-defense", tier = 6 },

	-- Fusion reactors
	["bob-vehicle-fission-reactor-equipment-1"] = { group = "equipment", icon_name = "fission-reactor", tier = 1 },
	["bob-vehicle-fission-reactor-equipment-2"] = { group = "equipment", icon_name = "fission-reactor", tier = 2 },
	["bob-vehicle-fission-reactor-equipment-3"] = { group = "equipment", icon_name = "fission-reactor", tier = 3 },
	["bob-vehicle-fission-reactor-equipment-4"] = { group = "equipment", icon_name = "fission-reactor", tier = 4 },
	["bob-vehicle-fission-reactor-equipment-5"] = { group = "equipment", icon_name = "fission-reactor", tier = 5 },
	["bob-vehicle-fission-reactor-equipment-6"] = { group = "equipment", icon_name = "fission-reactor", tier = 6 },

	-- Mobility
	["bob-vehicle-motor-equipment"] = { flat_icon = true },
	["bob-vehicle-engine-equipment"] = { flat_icon = true },
	["bob-vehicle-belt-immunity-equipment"] = { flat_icon = true },

	-- Energy Shields
	["bob-vehicle-shield-equipment-1"] = { icon_name = "vehicle-energy-shield", tier = 1 },
	["bob-vehicle-shield-equipment-2"] = { icon_name = "vehicle-energy-shield", tier = 2 },
	["bob-vehicle-shield-equipment-3"] = { icon_name = "vehicle-energy-shield", tier = 3 },
	["bob-vehicle-shield-equipment-4"] = { icon_name = "vehicle-energy-shield", tier = 4 },
	["bob-vehicle-shield-equipment-5"] = { icon_name = "vehicle-energy-shield", tier = 5 },
	["bob-vehicle-shield-equipment-6"] = { icon_name = "vehicle-energy-shield", tier = 6 },

	-- Roboports
	["bob-vehicle-roboport-equipment-1"] = { group = "equipment", icon_name = "personal-roboport-1", tier = 1, prog_tier = 2 },
	["bob-vehicle-roboport-equipment-2"] = { group = "equipment", icon_name = "personal-roboport-1", tier = 2, prog_tier = 3 },
	["bob-vehicle-roboport-equipment-3"] = { group = "equipment", icon_name = "personal-roboport-2", tier = 3, prog_tier = 4 },
	["bob-vehicle-roboport-equipment-4"] = { group = "equipment", icon_name = "personal-roboport-2", tier = 4, prog_tier = 5 },
}

reskins.internal.create_icons_from_list(technologies, inputs)
