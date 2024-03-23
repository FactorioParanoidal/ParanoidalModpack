if angelsmods.bioprocessing then
	data.raw["assembling-machine"]["algae-farm-4"].next_upgrade = "algae-farm-5"
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
	data.raw["assembling-machine"]["angels-air-filter-3"].next_upgrade = "angels-air-filter-4"
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
	-- data.raw["assembling-machine"]["crystallizer-2"].next_upgrade = "crystallizer-3"
	-- data.raw["assembling-machine"]["filtration-unit-3"].next_upgrade = "filtration-unit-3"
end

if (mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses) then
	data.raw["container"]["angels-warehouse"].next_upgrade = "warehouse-mk2"
	data.raw["logistic-container"]["angels-warehouse-passive-provider"].next_upgrade = "warehouse-passive-provider-mk2"
	data.raw["logistic-container"]["angels-warehouse-active-provider"].next_upgrade = "warehouse-active-provider-mk2"
	data.raw["logistic-container"]["angels-warehouse-storage"].next_upgrade = "warehouse-storage-mk2"
	data.raw["logistic-container"]["angels-warehouse-requester"].next_upgrade = "warehouse-requester-mk2"
	data.raw["logistic-container"]["angels-warehouse-buffer"].next_upgrade = "warehouse-buffer-mk2"
end