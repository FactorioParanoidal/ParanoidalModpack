-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.equipment.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	type = "technology",
	mod = "bobs",
	group = "equipment",
	technology_icon_extras = { reskins.lib.technology_equipment_overlay({ scale = 1 }) },
	technology_icon_size = 256,
}

---@type CreateIconsFromListTable
local technologies = {
	-- Roboport modular equipment
	["bob-personal-roboport-modular-equipment-1"] = { icon_name = "modular-equipment", icon_base = "modular-equipment-1", tier = 1, prog_tier = 2 },
	["bob-personal-roboport-modular-equipment-2"] = { icon_name = "modular-equipment", icon_base = "modular-equipment-2", tier = 2, prog_tier = 3 },
	["bob-personal-roboport-modular-equipment-3"] = { icon_name = "modular-equipment", icon_base = "modular-equipment-3", tier = 3, prog_tier = 4 },
	["bob-personal-roboport-modular-equipment-4"] = { icon_name = "modular-equipment", icon_base = "modular-equipment-4", tier = 4, prog_tier = 5 },

	-- Solar panels
	["solar-panel-equipment"] = { icon_name = "solar-panel", tier = 1, prog_tier = 2 },
	["bob-solar-panel-equipment-2"] = { icon_name = "solar-panel", tier = 2, prog_tier = 3 },
	["bob-solar-panel-equipment-3"] = { icon_name = "solar-panel", tier = 3, prog_tier = 4 },
	["bob-solar-panel-equipment-4"] = { icon_name = "solar-panel", tier = 4, prog_tier = 5 },

	-- Batteries
	["battery-equipment"] = { icon_name = "battery", tier = 1 },
	["battery-mk2-equipment"] = { icon_name = "battery", tier = 2 },
	["bob-battery-equipment-3"] = { icon_name = "battery", tier = 3 },
	["bob-battery-equipment-4"] = { icon_name = "battery", tier = 4 },
	["bob-battery-equipment-5"] = { icon_name = "battery", tier = 5 },
	["bob-battery-equipment-6"] = { icon_name = "battery", tier = 6 },

	-- Shields
	["energy-shield-equipment"] = { icon_name = "energy-shield", tier = 1 },
	["energy-shield-mk2-equipment"] = { icon_name = "energy-shield", tier = 2 },
	["bob-energy-shield-equipment-3"] = { icon_name = "energy-shield", tier = 3 },
	["bob-energy-shield-equipment-4"] = { icon_name = "energy-shield", tier = 4 },
	["bob-energy-shield-equipment-5"] = { icon_name = "energy-shield", tier = 5 },
	["bob-energy-shield-equipment-6"] = { icon_name = "energy-shield", tier = 6 },

	-- Laser defense
	["personal-laser-defense-equipment"] = { icon_name = "laser-defense", tier = 1 },
	["bob-personal-laser-defense-equipment-2"] = { icon_name = "laser-defense", tier = 2 },
	["bob-personal-laser-defense-equipment-3"] = { icon_name = "laser-defense", tier = 3 },
	["bob-personal-laser-defense-equipment-4"] = { icon_name = "laser-defense", tier = 4 },
	["bob-personal-laser-defense-equipment-5"] = { icon_name = "laser-defense", tier = 5 },
	["bob-personal-laser-defense-equipment-6"] = { icon_name = "laser-defense", tier = 6 },

	-- Fusion Reactors
	["fission-reactor-equipment"] = { icon_name = "fission-reactor", tier = 1, prog_tier = 3 },
	["bob-fission-reactor-equipment-2"] = { icon_name = "fission-reactor", tier = 2, prog_tier = 4 },
	["bob-fission-reactor-equipment-3"] = { icon_name = "fission-reactor", tier = 3, prog_tier = 5 },
	["bob-fission-reactor-equipment-4"] = { icon_name = "fission-reactor", tier = 4, prog_tier = 6 },

	-- Night vision
	["night-vision-equipment"] = { icon_name = "night-vision", tier = 1, prog_tier = 2 },
	["bob-night-vision-equipment-2"] = { icon_name = "night-vision", tier = 2, prog_tier = 3 },
	["bob-night-vision-equipment-3"] = { icon_name = "night-vision", tier = 3, prog_tier = 5 },

	-- Exoskeleton
	["exoskeleton-equipment"] = { icon_name = "exoskeleton", tier = 1, prog_tier = 2 },
	["bob-exoskeleton-equipment-2"] = { icon_name = "exoskeleton", tier = 2, prog_tier = 3 },
	["bob-exoskeleton-equipment-3"] = { icon_name = "exoskeleton", tier = 3, prog_tier = 5 },

	-- Roboports
	["personal-roboport-equipment"] = { icon_name = "personal-roboport-1", tier = 1, prog_tier = 2 },
	["personal-roboport-mk2-equipment"] = { icon_name = "personal-roboport-1", tier = 2, prog_tier = 3 },
	["bob-personal-roboport-mk3-equipment"] = { icon_name = "personal-roboport-2", tier = 3, prog_tier = 4 },
	["bob-personal-roboport-mk4-equipment"] = { icon_name = "personal-roboport-2", tier = 4, prog_tier = 5 },
}

reskins.internal.create_icons_from_list(technologies, inputs)
