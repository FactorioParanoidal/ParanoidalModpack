--------------------------
---- data-updates.lua ----
--------------------------

if not mods ["boblibrary"] then return end

-- Fetch functions from bob's library
local replace_tech_prerequisite = bobmods.lib.tech.replace_prerequisite
local add_tech_prerequisite = bobmods.lib.tech.add_prerequisite
local add_tech_recipe_unlock = bobmods.lib.tech.add_recipe_unlock
local remove_tech_recipe_unlock = bobmods.lib.tech.remove_recipe_unlock
local replace_recipe_ingredient = bobmods.lib.recipe.replace_ingredient
local replace_science_pack = bobmods.lib.tech.replace_science_pack

local water_miner_setting = settings.startup["bobmods-mining-waterminers"]
local oil_miner_setting = settings.startup["bobmods-mining-pumpjacks"]


-- Do bob's water pumpjacks stuff
if water_miner_setting and water_miner_setting.value == true then

	-- Water miners list
	local water_miners =
	{
		["water-miner-1"] = "water-miner-2",
		["water-miner-2"] = "water-miner-3",
		["water-miner-3"] = "water-miner-4",
		["water-miner-4"] = "water-miner-5",
		["water-miner-5"] = ""
	}

	-- Assign fast replaceable group
	for water_miner, _ in pairs(water_miners) do
		if data.raw["mining-drill"][water_miner] then
			data.raw["mining-drill"][water_miner].fast_replaceable_group = "water-miner"
		end
	end

	-- Restrict bob's water pumpjacks to lithia water
	if data.raw.resource["lithia-water"] then
		local resource_category = util.table.deepcopy(data.raw["resource-category"]["basic-fluid"])
		resource_category.name = "bob-lithia-water"
		data:extend({resource_category})

		for water_miner, _ in pairs(water_miners) do
			if data.raw["mining-drill"][water_miner] then
				data.raw["mining-drill"][water_miner].resource_categories = {"bob-lithia-water"}
				data.raw["resource"]["lithia-water"].category = "bob-lithia-water"
			end
		end
	end

	-- Make water pumpjacks upgradeable
	for water_miner, upgrade in pairs(water_miners) do
		if data.raw.item[water_miner] and (not data.raw.item[water_miner].OSM_removed or data.raw.item[water_miner].OSM_removed == false) then
			if data.raw["mining-drill"][water_miner] and data.raw["mining-drill"][upgrade] then
				data.raw["mining-drill"][water_miner].next_upgrade = upgrade
			end
		end
	end

	-- Adjust tech
	local water_pumpjack_setting = settings.startup["osm-pumps-enable-ground-water-pumpjacks"]
	if water_pumpjack_setting and water_pumpjack_setting.value == true then
	
		local disable_prototype = OSM.lib.prototype.disable_prototype
		
		-- Add
		add_tech_recipe_unlock("water-pumpjack-1", "water-miner-1")
		add_tech_recipe_unlock("water-pumpjack-2", "water-miner-2")
		add_tech_recipe_unlock("water-pumpjack-3", "water-miner-3")
		add_tech_recipe_unlock("water-pumpjack-4", "water-miner-4")
		add_tech_recipe_unlock("water-pumpjack-5", "water-miner-5")
		disable_prototype("water-miner-1", "technology")
		disable_prototype("water-miner-2", "technology")
		disable_prototype("water-miner-3", "technology")
		disable_prototype("water-miner-4", "technology")
		disable_prototype("water-miner-5", "technology")
	end
end

-- Do bob's oil pumpjacks stuff
if oil_miner_setting and oil_miner_setting.value == true then

	-- Oil pumpjacks list
	local oil_miners =
	{
		["pumpjack"] = "bob-pumpjack-1",
		["bob-pumpjack-1"] = "bob-pumpjack-2",
		["bob-pumpjack-2"] = "bob-pumpjack-3",
		["bob-pumpjack-3"] = "bob-pumpjack-4",
		["bob-pumpjack-4"] = ""
	}

	-- Assign fast replaceable group
	for pumpjack, _ in pairs(oil_miners) do
		if data.raw["mining-drill"][pumpjack] then
			data.raw["mining-drill"][pumpjack].fast_replaceable_group = "oil-pumpjack"
		end
	end

	-- Make oil pumpjacks upgradeable
	for pumpjack, upgrade in pairs(oil_miners) do
		if data.raw.item[pumpjack] and (not data.raw.item[pumpjack].OSM_removed or data.raw.item[pumpjack].OSM_removed == false) then
			if data.raw["mining-drill"][pumpjack] and data.raw["mining-drill"][upgrade] then
				data.raw["mining-drill"][pumpjack].next_upgrade = upgrade
			elseif data.raw["assembling-machine"][pumpjack] and data.raw["assembling-machine"][upgrade] then
				data.raw["assembling-machine"][pumpjack].next_upgrade = upgrade
			end
		end
	end
end

-- Remove bob's inconsistent ground water patches
if data.raw.resource["ground-water"] then
	data.raw.resource["ground-water"] = nil
end

-- Edit recipes and techs for bob mods
if data.raw.item["titanium-plate"] and data.raw.item["nitinol-alloy"] then

	-- Replace gear wheels
	replace_recipe_ingredient("offshore-pump-2", "iron-gear-wheel",	"steel-gear-wheel", 5)
	replace_recipe_ingredient("offshore-pump-3", "iron-gear-wheel",	"titanium-gear-wheel", 5)
	replace_recipe_ingredient("offshore-pump-4", "iron-gear-wheel",	"nitinol-gear-wheel", 5)

	--Replace plates
	if data.raw.item["steel-pipe"] and data.raw.item["titanium-pipe"] and data.raw.item["nitinol-pipe"] then
		replace_recipe_ingredient("offshore-pump-2", "steel-plate",	"steel-pipe", 1)
		replace_recipe_ingredient("offshore-pump-3", "steel-plate",	"titanium-pipe", 1)
		replace_recipe_ingredient("offshore-pump-4", "steel-plate",	"nitinol-pipe", 1)
	else
		replace_recipe_ingredient("offshore-pump-2", "steel-plate",	"steel-plate", 1)
		replace_recipe_ingredient("offshore-pump-3", "steel-plate",	"titanium-plate", 1)
		replace_recipe_ingredient("offshore-pump-4", "steel-plate",	"nitinol-alloy", 1)
	end

	-- Reassign techs
	if data.raw.technology["bob-fluid-handling-2"] and data.raw.technology["bob-fluid-handling-3"] and data.raw.technology["bob-fluid-handling-4"] then
		replace_tech_prerequisite ("offshore-pump-2", "fluid-handling", "bob-fluid-handling-2")
		add_tech_prerequisite("offshore-pump-3", "bob-fluid-handling-3")
		add_tech_prerequisite("offshore-pump-4", "bob-fluid-handling-4")
	else
		add_tech_prerequisite("offshore-pump-3", "titanium-processing")
		add_tech_prerequisite("offshore-pump-4", "nitinol-processing")
	end
end

if data.raw.technology["advanced-electronics-2"] and data.raw.technology["advanced-electronics-3"] then
	add_tech_prerequisite("offshore-pump-2", "advanced-electronics")
	replace_tech_prerequisite ("offshore-pump-3", "advanced-electronics", "advanced-electronics-2")
	replace_tech_prerequisite ("offshore-pump-4", "advanced-electronics-2", "advanced-electronics-3")
end