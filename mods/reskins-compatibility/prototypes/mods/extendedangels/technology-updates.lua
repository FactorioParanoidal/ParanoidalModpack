-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then
	return
end
if not (reskins.angels and reskins.angels.triggers.storage.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "compatibility",
	group = "extendedangels",
	type = "technology",
	technology_icon_size = 256,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local technologies = {}

-- Reskin warehouse technologies
technologies["angels-logistic-warehouses-2"] = { mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-logistic-warehouses" }
technologies["angels-logistic-warehouses-3"] = { mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-logistic-warehouses" }
technologies["angels-logistic-warehouses-4"] = { mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-logistic-warehouses" }
technologies["angels-warehouses-2"] = { mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-warehouses" }
technologies["angels-warehouses-3"] = { mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-warehouses" }
technologies["angels-warehouses-4"] = { mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-warehouses" }

-- Reskin silo technologies
-- technologies["logistic-silos"] = {subgroup = "silos"}
-- technologies["ore-silos"] = {subgroup = "silos"}

reskins.internal.create_icons_from_list(technologies, inputs)
