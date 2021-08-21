--------------------------
---- data-updates.lua ----
--------------------------

-- Fetch functions from library
local remove_tech_recipe = require("utils.lib").remove_tech_recipe
local replace_ingredient_all_recipes = require("utils.lib").replace_ingredient_all_recipes


-- Remove bob's  (redundant) water miners
if data.raw.resource["angels-fissure"] then
		
	local water_miners =
	{
		["water-miner-1"] = "pumpjack",
		["water-miner-2"] = "bob-pumpjack-1",
		["water-miner-3"] = "bob-pumpjack-2",
		["water-miner-4"] = "bob-pumpjack-3",
		["water-miner-5"] = "bob-pumpjack-4"
	}
	
	for water_miner, pumpjack in pairs(water_miners) do
		if data.raw.item[water_miner] and data.raw.item[pumpjack] then
			replace_ingredient_all_recipes(water_miner, pumpjack)
			remove_tech_recipe(water_miner, water_miner)
			data.raw.recipe[water_miner] = nil
			data.raw.item[water_miner] = nil
			data.raw["mining-drill"][water_miner] = nil
		end
	end
end