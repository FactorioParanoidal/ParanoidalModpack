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

--[[
-- Setup water pumpjack host table
local water_miners_table =
{
	["water-miner-1"] = "water-pumpjack-1",
	["water-miner-2"] = "water-pumpjack-2",
	["water-miner-3"] = "water-pumpjack-3",
	["water-miner-4"] = "water-pumpjack-4",
	["water-miner-5"] = "water-pumpjack-5"
}

-- Setup oil pumpjacks host table
local oil_pumpjacks_table =
{
	"pumpjack",
	"bob-pumpjack-1",
	"bob-pumpjack-2",
	"bob-pumpjack-3",
	"bob-pumpjack-4"
}

-- Do bobmining stuff
if settings.startup["bobmods-mining-waterminers"] and settings.startup["bobmods-mining-waterminers"].value == true then

	local old_miner
	local old_jack

	-- Assign energy usage
	local power_draw_table =
	{
		["water-pumpjack-2"] = "550kW",
		["water-pumpjack-3"] = "750kW",
		["water-pumpjack-4"] = "1000kW",
		["water-pumpjack-5"] = "1250kW"
	}

	-- Generate higher tier ground water pumpjacks
	for water_miner, pumpjack in pairs(water_miners_table) do

		-- Entity
		if data.raw["mining-drill"][water_miner] then		
			local entity = table.deepcopy(data.raw["assembling-machine"]["water-pumpjack-1"])
			entity.name = pumpjack
			entity.minable.result = pumpjack
			entity.crafting_speed = data.raw["mining-drill"][water_miner].mining_speed
			data:extend({entity})
		end

		-- Item
		if data.raw.item[water_miner] then
			local item = table.deepcopy(data.raw.item["water-pumpjack-1"])
			item.name = pumpjack
			item.place_result = pumpjack
			data:extend({item})
		end

		-- Recipe
		if data.raw.recipe[water_miner] then
			local recipe = table.deepcopy(data.raw.recipe[water_miner])
			recipe.name = pumpjack
			recipe.result = pumpjack
			data:extend({recipe})
		end

		-- Technology
		if data.raw.technology[water_miner] then

			-- Add ground water pumpjacks to bobmining techs
			data.raw.technology["water-pumpjack"] = nil
			add_tech_recipe_unlock(water_miner, pumpjack)

			-- Replace bobmining tech icon
			data.raw.technology[water_miner].icon = "__P-U-M-P-S__/graphics/technology/water-pumpjack.png"
			data.raw.technology[water_miner].icon_size = 256
			data.raw.technology[water_miner].icon_mipmaps = 4
		end
		
		-- Replace ingredient with appropriate pumpjack
		replace_recipe_ingredient(pumpjack, old_miner, old_jack)
		old_miner = water_miner
		old_jack = pumpjack
	end

	-- Assign correct energy usage to ground water pumpjacks
	for pumpjack, energy_usage in pairs(power_draw_table) do
		if data.raw.item[pumpjack] then
			data.raw["assembling-machine"][pumpjack].energy_usage = energy_usage
		end
	end
	
	-- Make  water pumpjacks upgradable
	for water_miner, _ in pairs(water_miners_table) do
		data.raw["mining-drill"][water_miner].fast_replaceable_group = "water-miner"
	end
	data.raw["mining-drill"]["water-miner-1"].next_upgrade = "water-miner-2"
	data.raw["mining-drill"]["water-miner-2"].next_upgrade = "water-miner-3"
	data.raw["mining-drill"]["water-miner-3"].next_upgrade = "water-miner-4"
	data.raw["mining-drill"]["water-miner-4"].next_upgrade = "water-miner-5"
	data.raw["assembling-machine"]["water-pumpjack-1"].next_upgrade = "water-pumpjack-2"
	data.raw["assembling-machine"]["water-pumpjack-2"].next_upgrade = "water-pumpjack-3"
	data.raw["assembling-machine"]["water-pumpjack-3"].next_upgrade = "water-pumpjack-4"
	data.raw["assembling-machine"]["water-pumpjack-4"].next_upgrade = "water-pumpjack-5"
end

-- Do more bobmining stuff
if settings.startup["bobmods-mining-pumpjacks"] and settings.startup["bobmods-mining-pumpjacks"].value == true then
	
	-- Make oil pumpjacks upgradable
	for _, oil_pumpjack in pairs(oil_pumpjacks_table) do
		data.raw["mining-drill"][oil_pumpjack].fast_replaceable_group = "oil-pumpjacks"
	end
	data.raw["mining-drill"]["pumpjack"].next_upgrade = "bob-pumpjack-1"
	data.raw["mining-drill"]["bob-pumpjack-1"].next_upgrade = "bob-pumpjack-2"
	data.raw["mining-drill"]["bob-pumpjack-2"].next_upgrade = "bob-pumpjack-3"
	data.raw["mining-drill"]["bob-pumpjack-3"].next_upgrade = "bob-pumpjack-4"
end

-- Use copper pipes for water pumpjacks
if data.raw.item["copper-pipe"] then
	replace_recipe_ingredient("water-pumpjack", "pipe", "copper-pipe")
end

-- Remove bob's inconsistent ground water patches
if data.raw.resource["ground-water"] then
	data.raw.resource["ground-water"] = nil
end

-- Restrict bob's water pumpjacks to lithia water
if data.raw.resource["lithia-water"] then
	local resource_category = util.table.deepcopy(data.raw["resource-category"]["basic-fluid"])
	resource_category.name = "bob-lithia-water"
	data:extend({resource_category})

	for water_miner, _ in pairs(water_miners_table) do
		if data.raw["mining-drill"][water_miner] then
			data.raw["mining-drill"][water_miner].resource_categories = {"bob-lithia-water"}
			data.raw["resource"]["lithia-water"].category = "bob-lithia-water"
		end
	end
end
]]--

-- Replace science packs for bobs tech
if data.raw.tool["advanced-logistic-science-pack"] then
	replace_science_pack("offshore-pump-tech_4", "production-science-pack", "advanced-logistic-science-pack")
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
		replace_tech_prerequisite ("offshore-pump-tech_2", "fluid-handling", "bob-fluid-handling-2")
		add_tech_prerequisite("offshore-pump-tech_3", "bob-fluid-handling-3")
		add_tech_prerequisite("offshore-pump-tech_4", "bob-fluid-handling-4")
	else
		add_tech_prerequisite("offshore-pump-tech_3", "titanium-processing")
		add_tech_prerequisite("offshore-pump-tech_4", "nitinol-processing")
	end
end
--[[
if data.raw.technology["advanced-electronics-2"] and data.raw.technology["advanced-electronics-3"] then
	add_tech_prerequisite("offshore-pump-tech_2", "advanced-electronics")
	replace_tech_prerequisite ("offshore-pump-tech_3", "advanced-electronics", "advanced-electronics-2")
	replace_tech_prerequisite ("offshore-pump-tech_4", "advanced-electronics-2", "advanced-electronics-3")
end
]]--