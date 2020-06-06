-- For Angel's Bio Processing
require("prototypes.recipes.bioprocessing")

-- For Angel's Petrochem
require("prototypes.recipes.petrochem")

-- For Angel's Refining
require("prototypes.recipes.refining")

-- For Changing Technologies
require("prototypes.technology-overrides")

-- For Chaning Recipes
require("prototypes.recipes-overrides")


-- For Angel's Extra Warehouses
if mods["angelsaddons-warehouses"] then
	require("prototypes.recipes.warehouses")	
	if mods["angelsindustries"] and settings.startup["angels-enable-tech"].value==true then
		bobmods.lib.recipe.replace_ingredient_in_all("brass-gear-wheel","angels-roller-chain")
		bobmods.lib.recipe.replace_ingredient_in_all("advanced-processing-unit","circuit-yellow-loaded")
		end
		
	if angelsmods and angelsmods.refining then
		if angelsmods.logistics then
			  data.raw["item-subgroup"]["angels-warehouses"-2].group = "angels-logistics"
			  data.raw["item-subgroup"]["angels-warehouses"-3].group = "angels-logistics"
			  data.raw["item-subgroup"]["angels-warehouses"-4].group = "angels-logistics"
			else
			  data.raw["item-subgroup"]["angels-warehouses-2"].group = "resource-refining"
			  data.raw["item-subgroup"]["angels-warehouses-3"].group = "resource-refining"
			  data.raw["item-subgroup"]["angels-warehouses-4"].group = "resource-refining"
			end
		end

		if angelsmods.industries then
			data.raw["item-subgroup"]["angels-warehouses-2"].group = "angels-logistics"
			data.raw["item-subgroup"]["angels-warehouses-3"].group = "angels-logistics"
			data.raw["item-subgroup"]["angels-warehouses-4"].group = "angels-logistics"
			data.raw["item-subgroup"]["angels-warehouses-2"].order = "ad[chests-warehouse]"
			data.raw["item-subgroup"]["angels-warehouses-3"].order = "ad[chests-warehouse]"
			data.raw["item-subgroup"]["angels-warehouses-4"].order = "ad[chests-warehouse]"
		  end

	if angelsmods.addons.warehouse_icon then
		data.raw["container"]["warehouse-mk2"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-passive-provider-mk2"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-active-provider-mk2"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-storage-mk2"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-requester-mk2"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-buffer-mk2"].scale_info_icons = true
		data.raw["container"]["warehouse-mk3"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-passive-provider-mk3"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-active-provider-mk3"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-storage-mk3"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-requester-mk3"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-buffer-mk3"].scale_info_icons = true
    	data.raw["container"]["warehouse-mk4"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-passive-provider-mk4"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-active-provider-mk4"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-storage-mk4"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-requester-mk4"].scale_info_icons = true
		data.raw["logistic-container"]["warehouse-buffer-mk4"].scale_info_icons = true
	end
end



-- Upgrdae Planner Fixes
if angelsmods.bioprocessing then
	data.raw["assembling-machine"]["algae-farm-3"].next_upgrade = "algae-farm-4"
	data.raw["assembling-machine"]["bio-arboretum-1"].next_upgrade = "bio-arboretum-2"
	data.raw["assembling-machine"]["bio-generator-temperate-1"].next_upgrade = "bio-generator-temperate-2"
	data.raw["assembling-machine"]["bio-generator-swamp-1"].next_upgrade = "bio-generator-swamp-2"
	data.raw["assembling-machine"]["bio-generator-desert-1"].next_upgrade = "bio-generator-desert-2"
	data.raw["assembling-machine"]["bio-press"].next_upgrade = "bio-press-2"
	data.raw["assembling-machine"]["bio-processor"].next_upgrade = "bio-processor-2"
	data.raw["assembling-machine"]["crop-farm"].next_upgrade = "crop-farm-2"
	data.raw["assembling-machine"]["seed-extractor"].next_upgrade = "seed-extractor-2"
	data.raw["assembling-machine"]["temperate-farm"].next_upgrade = "temperate-farm-2"
	data.raw["assembling-machine"]["desert-farm"].next_upgrade = "desert-farm-2"
	data.raw["recipe"]["desert-farm"].order = "bd"
	data.raw["assembling-machine"]["swamp-farm"].next_upgrade = "swamp-farm-2"
	data.raw["assembling-machine"]["nutrient-extractor"].next_upgrade = "nutrient-extractor-2"
	data.raw["assembling-machine"]["bio-refugium-fish"].next_upgrade = "bio-refugium-fish-2"
	data.raw["assembling-machine"]["bio-refugium-puffer"].next_upgrade = "bio-refugium-puffer-2"
	data.raw["assembling-machine"]["bio-refugium-biter"].next_upgrade = "bio-refugium-biter-2"
	data.raw["recipe"]["swamp-farm"].order = "bg"
	data.raw["furnace"]["bio-hatchery"].next_upgrade = "bio-hatchery-2"
	data.raw["furnace"]["bio-butchery"].next_upgrade = "bio-butchery-2"
	data.raw["furnace"]["composter"].next_upgrade = "composter-2"
end

if angelsmods.petrochem then
	data.raw["assembling-machine"]["advanced-chemical-plant-2"].next_upgrade = "advanced-chemical-plant-3"
	data.raw["assembling-machine"]["angels-air-filter-2"].next_upgrade = "angels-air-filter-3"
	data.raw["assembling-machine"]["gas-refinery-3"].next_upgrade = "gas-refinery-4"
end

if angelsmods.refining then
	data.raw["assembling-machine"]["hydro-plant-3"].next_upgrade = "hydro-plant-4"
	data.raw["assembling-machine"]["salination-plant-2"].next_upgrade = "salination-plant-3"
	data.raw["assembling-machine"]["washing-plant-2"].next_upgrade = "washing-plant-3"
	data.raw["assembling-machine"]["ore-crusher-3"].next_upgrade = "ore-crusher-4"
	data.raw["assembling-machine"]["ore-floatation-cell-3"].next_upgrade = "ore-floatation-cell-4"
	data.raw["assembling-machine"]["ore-leaching-plant-3"].next_upgrade = "ore-leaching-plant-4"
	data.raw["assembling-machine"]["ore-refinery-2"].next_upgrade = "ore-refinery-3"
	data.raw["assembling-machine"]["crystallizer-2"].next_upgrade = "crystallizer-3"
	data.raw["assembling-machine"]["filtration-unit-3"].next_upgrade = "filtration-unit-3"
end

if mods["angelsaddons-warehouses"] then
	data.raw["container"]["angels-warehouse"].next_upgrade = "warehouse-mk2"
	data.raw["logistic-container"]["angels-warehouse-passive-provider"].next_upgrade = "warehouse-passive-provider-mk2"
	data.raw["logistic-container"]["angels-warehouse-active-provider"].next_upgrade = "warehouse-active-provider-mk2"
	data.raw["logistic-container"]["angels-warehouse-storage"].next_upgrade = "warehouse-storage-mk2"
	data.raw["logistic-container"]["angels-warehouse-requester"].next_upgrade = "warehouse-requester-mk2"
	data.raw["logistic-container"]["angels-warehouse-buffer"].next_upgrade = "warehouse-buffer-mk2"	
end