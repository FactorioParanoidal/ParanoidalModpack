-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.mining.technologies) then
	return
end

-- Setup standard inputs
local inputs = {
	mod = "bobs",
	group = "mining",
	type = "technology",
	technology_icon_size = 256,
}

---@return CreateIconsFromListOverrides
local function get_steel_axe_overrides()
	---@type CreateIconsFromListOverrides
	local override = {
		technology_icon_filename = "__base__/graphics/technology/steel-axe.png",
		technology_icon_extras = { reskins.lib.return_technology_effect_icon("mining") },
		flat_icon = true,
	}

	return override
end

---@param tier? integer # The tier of the icon. An integer value from 0 to 6. Default `0`.
---@param prog_tier? integer # The tier of the icon, as determined by the progression map. An integer value from 0 to 6. Default `0`.
---@return CreateIconsFromListOverrides
local function get_mining_drill_overrides(tier, prog_tier)
	---@type CreateIconsFromListOverrides
	local override = {
		tier = tier,
		prog_tier = prog_tier,
		icon_name = "mining-drill",
		technology_icon_size = 128,
	}

	return override
end

---@param tier? integer # The tier of the icon. An integer value from 0 to 6. Default `0`.
---@param prog_tier? integer # The tier of the icon, as determined by the progression map. An integer value from 0 to 6. Default `0`.
---@return CreateIconsFromListOverrides
local function get_area_mining_drill_overrides(tier, prog_tier)
	---@type CreateIconsFromListOverrides
	local override = {
		tier = tier,
		prog_tier = prog_tier,
		icon_name = "mining-drill",
		icon_base = "area-mining-drill",
		technology_icon_size = 128,
	}

	return override
end

---@param tier? integer # The tier of the icon. An integer value from 0 to 6. Default `0`.
---@param prog_tier? integer # The tier of the icon, as determined by the progression map. An integer value from 0 to 6. Default `0`.
---@return CreateIconsFromListOverrides
local function get_water_pumpjack_overrides(tier, prog_tier)
	---@type CreateIconsFromListOverrides
	local override = {
		tier = tier,
		prog_tier = prog_tier,
		icon_name = "pumpjack",
		icon_base = "water-pumpjack",
	}

	return override
end

---@param tier? integer # The tier of the icon. An integer value from 0 to 6. Default `0`.
---@param prog_tier? integer # The tier of the icon, as determined by the progression map. An integer value from 0 to 6. Default `0`.
---@return CreateIconsFromListOverrides
local function get_pumpjack_overrides(tier, prog_tier)
	---@type CreateIconsFromListOverrides
	local override = {
		tier = tier,
		prog_tier = prog_tier,
		icon_name = "pumpjack",
	}

	return override
end

local technologies = {
	-- Standard Drills
	["bob-drills-2"] = get_mining_drill_overrides(2),
	["bob-drills-3"] = get_mining_drill_overrides(3),
	["bob-drills-4"] = get_mining_drill_overrides(4),
	["bob-drills-5"] = get_mining_drill_overrides(5),

	-- Area Drills
	["bob-area-drills-1"] = get_area_mining_drill_overrides(1, 2),
	["bob-area-drills-2"] = get_area_mining_drill_overrides(2, 3),
	["bob-area-drills-3"] = get_area_mining_drill_overrides(3, 4),
	["bob-area-drills-4"] = get_area_mining_drill_overrides(4, 5),

	-- Water pumpjacks
	["bob-water-miner-1"] = get_water_pumpjack_overrides(1),
	["bob-water-miner-2"] = get_water_pumpjack_overrides(2),
	["bob-water-miner-3"] = get_water_pumpjack_overrides(3),
	["bob-water-miner-4"] = get_water_pumpjack_overrides(4),

	-- Oil pumpjacks
	["oil-gathering"] = get_pumpjack_overrides(1, 2),
	["bob-pumpjacks-2"] = get_pumpjack_overrides(2, 3),
	["bob-pumpjacks-3"] = get_pumpjack_overrides(3, 4),
	["bob-pumpjacks-4"] = get_pumpjack_overrides(4, 5),

	-- Technology effects
	["steel-axe"] = get_steel_axe_overrides(),
	["bob-steel-axe-2"] = get_steel_axe_overrides(),
	["bob-steel-axe-3"] = get_steel_axe_overrides(),
	["bob-steel-axe-4"] = get_steel_axe_overrides(),
	["bob-steel-axe-5"] = get_steel_axe_overrides(),
	["bob-steel-axe-6"] = get_steel_axe_overrides(),
}

if mods["aai-industry"] then
	technologies["electric-mining"] = { tier = 1, icon_name = "mining-drill", technology_icon_size = 128 }
end

reskins.internal.create_icons_from_list(technologies, inputs)
