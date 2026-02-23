if angelsmods.bioprocessing then
  data.raw["assembling-machine"]["angels-algae-farm-4"].next_upgrade = "angels-algae-farm-5"
  data.raw["assembling-machine"]["angels-bio-arboretum-1"].next_upgrade = "angels-bio-arboretum-2"
  data.raw["assembling-machine"]["angels-bio-generator-temperate-1"].next_upgrade = "angels-bio-generator-temperate-2"
  data.raw["assembling-machine"]["angels-bio-generator-swamp-1"].next_upgrade = "angels-bio-generator-swamp-2"
  data.raw["assembling-machine"]["angels-bio-generator-desert-1"].next_upgrade = "angels-bio-generator-desert-2"
  data.raw["assembling-machine"]["angels-bio-press"].next_upgrade = "angels-bio-press-2"
  data.raw["assembling-machine"]["angels-bio-processor"].next_upgrade = "angels-bio-processor-2"
  data.raw["assembling-machine"]["angels-crop-farm"].next_upgrade = "angels-crop-farm-2"
  data.raw["assembling-machine"]["angels-seed-extractor"].next_upgrade = "angels-seed-extractor-2"
  data.raw["assembling-machine"]["angels-temperate-farm"].next_upgrade = "angels-temperate-farm-2"
  data.raw["assembling-machine"]["angels-desert-farm"].next_upgrade = "angels-desert-farm-2"
  data.raw["recipe"]["angels-desert-farm"].order = "bd"
  data.raw["assembling-machine"]["angels-swamp-farm"].next_upgrade = "angels-swamp-farm-2"
  data.raw["assembling-machine"]["angels-nutrient-extractor"].next_upgrade = "angels-nutrient-extractor-2"
  data.raw["assembling-machine"]["angels-bio-refugium-fish"].next_upgrade = "angels-bio-refugium-fish-2"
  data.raw["assembling-machine"]["angels-bio-refugium-puffer"].next_upgrade = "angels-bio-refugium-puffer-2"
  data.raw["assembling-machine"]["angels-bio-refugium-biter"].next_upgrade = "angels-bio-refugium-biter-2"
  data.raw["recipe"]["angels-swamp-farm"].order = "bg"
  data.raw["furnace"]["angels-bio-hatchery"].next_upgrade = "angels-bio-hatchery-2"
  data.raw["furnace"]["angels-bio-butchery"].next_upgrade = "angels-bio-butchery-2"
  data.raw["furnace"]["angels-composter"].next_upgrade = "angels-composter-2"
end

if angelsmods.petrochem then
  data.raw["assembling-machine"]["angels-advanced-chemical-plant-2"].next_upgrade = "angels-advanced-chemical-plant-3"
  data.raw["assembling-machine"]["angels-air-filter-3"].next_upgrade = "angels-air-filter-4"
end

if angelsmods.refining then
  data.raw["assembling-machine"]["angels-hydro-plant-3"].next_upgrade = "angels-hydro-plant-4"
  data.raw["assembling-machine"]["angels-salination-plant-2"].next_upgrade = "angels-salination-plant-3"
  data.raw["assembling-machine"]["angels-washing-plant-2"].next_upgrade = "angels-washing-plant-3"
  data.raw["assembling-machine"]["angels-ore-crusher-3"].next_upgrade = "angels-ore-crusher-4"
  data.raw["assembling-machine"]["angels-ore-floatation-cell-3"].next_upgrade = "angels-ore-floatation-cell-4"
  data.raw["assembling-machine"]["angels-ore-leaching-plant-3"].next_upgrade = "angels-ore-leaching-plant-4"
  data.raw["assembling-machine"]["angels-ore-refinery-2"].next_upgrade = "angels-ore-refinery-3"
end

if mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses then
  data.raw["container"]["angels-warehouse"].next_upgrade = "angels-warehouse-mk2"
  data.raw["logistic-container"]["angels-warehouse-passive-provider"].next_upgrade =
    "angels-warehouse-passive-provider-mk2"
  data.raw["logistic-container"]["angels-warehouse-active-provider"].next_upgrade =
    "angels-warehouse-active-provider-mk2"
  data.raw["logistic-container"]["angels-warehouse-storage"].next_upgrade = "angels-warehouse-storage-mk2"
  data.raw["logistic-container"]["angels-warehouse-requester"].next_upgrade = "angels-warehouse-requester-mk2"
  data.raw["logistic-container"]["angels-warehouse-buffer"].next_upgrade = "angels-warehouse-buffer-mk2"
end
