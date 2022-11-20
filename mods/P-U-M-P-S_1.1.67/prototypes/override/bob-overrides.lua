--------------------------
---- data-updates.lua ----
--------------------------

local mining_drill = data.raw["mining-drill"]
local resource = data.raw["resource"]
local assembling_machine = data.raw["assembling-machine"]


local bob_water_miner = OSM.lib.get_setting_boolean("bobmods-mining-waterminers")
local bob_oil_miner = OSM.lib.get_setting_boolean("bobmods-mining-pumpjacks")
local water_pumpjack_enabled = OSM.lib.get_setting_boolean("osm-pumps-enable-ground-water-pumpjacks")

-- Water miners list
local water_miners =
{
	["water-miner-1"] = "water-miner-2",
	["water-miner-2"] = "water-miner-3",
	["water-miner-3"] = "water-miner-4",
	["water-miner-4"] = "water-miner-5",
	["water-miner-5"] = ""
}

-- Oil pumpjacks list
local oil_miners =
{
	["pumpjack"] = "bob-pumpjack-1",
	["bob-pumpjack-1"] = "bob-pumpjack-2",
	["bob-pumpjack-2"] = "bob-pumpjack-3",
	["bob-pumpjack-3"] = "bob-pumpjack-4",
	["bob-pumpjack-4"] = ""
}


-- Do bob's water pumpjacks stuff
if bob_water_miner then

	-- Restrict bob's water pumpjacks to lithia water
	if resource["lithia-water"] then

		local resource_category = table.deepcopy(data.raw["resource-category"]["basic-fluid"])

		resource_category.name = "bob-lithia-water"
		data:extend({resource_category})
		
		resource["lithia-water"].category = "bob-lithia-water"
	end

	-- Assign categories and upgrades
	for water_miner, upgrade in pairs(water_miners) do
		if mining_drill[water_miner] and data.raw.item[water_miner] and not data.raw.item[water_miner].OSM_removed then
	
			mining_drill[water_miner].fast_replaceable_group = "water-miner"

			if mining_drill[upgrade] then
				mining_drill[water_miner].next_upgrade = upgrade
			end

			if resource["lithia-water"] then
				mining_drill[water_miner].resource_categories = {"bob-lithia-water"}
			end
		end
	end

	if water_pumpjack_enabled then
		
		-- Remove bob's inconsistent ground water patches
		OSM.lib.disable_prototype("resource", "ground-water")
		
		-- Add bob's water miners to water pumpjack technology
		OSM.lib.technology_add_unlock("water-miner-1", "water-pumpjack-1")
		OSM.lib.technology_add_unlock("water-miner-2", "water-pumpjack-2")
		OSM.lib.technology_add_unlock("water-miner-3", "water-pumpjack-3")
		OSM.lib.technology_add_unlock("water-miner-4", "water-pumpjack-4")
		OSM.lib.technology_add_unlock("water-miner-5", "water-pumpjack-5")
		
		OSM.lib.disable_prototype("technology-chain", "water-miner")
	end
end

-- Do bob's oil pumpjacks stuff
if bob_oil_miner then
	for pumpjack, upgrade in pairs(oil_miners) do
		if mining_drill[pumpjack] and data.raw.item[pumpjack] and not data.raw.item[pumpjack].OSM_removed then
			
			mining_drill[pumpjack].fast_replaceable_group = "oil-pumpjack"
			
			if mining_drill[upgrade] then
				mining_drill[pumpjack].next_upgrade = upgrade
			elseif assembling_machine[pumpjack] and assembling_machine[upgrade] then
				assembling_machine[pumpjack].next_upgrade = upgrade
			end
		end
	end
end

-- Edit recipes and techs for bob mods
if data.raw.item["titanium-plate"] and data.raw.item["nitinol-alloy"] then

	-- Replace gear wheels
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", {"steel-gear-wheel", 5}, "offshore-pump-2")
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", {"titanium-gear-wheel", 5}, "offshore-pump-3")
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", {"nitinol-gear-wheel", 5}, "offshore-pump-4")

	--Replace plates
	if data.raw.item["steel-pipe"] and data.raw.item["titanium-pipe"] and data.raw.item["nitinol-pipe"] then
		OSM.lib.recipe_replace_ingredient("steel-plate", {"steel-pipe", 1}, "offshore-pump-2")
		OSM.lib.recipe_replace_ingredient("steel-plate", {"titanium-pipe", 1}, "offshore-pump-3")
		OSM.lib.recipe_replace_ingredient("steel-plate", {"nitinol-pipe", 1}, "offshore-pump-4")
	else
		OSM.lib.recipe_replace_ingredient("steel-plate", {"steel-plate", 1}, "offshore-pump-2")
		OSM.lib.recipe_replace_ingredient("steel-plate", {"titanium-plate", 1}, "offshore-pump-3")
		OSM.lib.recipe_replace_ingredient("steel-plate", {"nitinol-plate", 1}, "offshore-pump-4")
	end

	-- Reassign techs
	if data.raw.technology["bob-fluid-handling-2"] and data.raw.technology["bob-fluid-handling-3"] and data.raw.technology["bob-fluid-handling-4"] then
		 OSM.lib.technology_replace_prerequisite("fluid-handling", "bob-fluid-handling-2", "offshore-pump-2")
		 OSM.lib.technology_add_prerequisite("offshore-pump-3", "bob-fluid-handling-3")
		 OSM.lib.technology_add_prerequisite("offshore-pump-4", "bob-fluid-handling-4")
	else
		OSM.lib.technology_add_prerequisite("offshore-pump-3", "titanium-processing")
		OSM.lib.technology_add_prerequisite("offshore-pump-4", "nitinol-processing")
	end
end

if data.raw.technology["advanced-electronics-2"] and data.raw.technology["advanced-electronics-3"] then
	OSM.lib.technology_add_prerequisite("offshore-pump-2", "advanced-electronics")
	OSM.lib.technology_replace_prerequisite("offshore-pump-3", "advanced-electronics", "advanced-electronics-2")
	OSM.lib.technology_replace_prerequisite("offshore-pump-4", "advanced-electronics-2", "advanced-electronics-3")
end