local OV = angelsmods.functions.OV

OV.add_prereq("tungsten-alloy-processing", "angels-copper-tungsten-smelting-1")
OV.disable_recipe({ "copper-tungsten-alloy" })
OV.disable_recipe({ "tungsten-carbide" })
OV.disable_recipe({ "tungsten-carbide-2" })
OV.disable_recipe({ "pellet-tungsten-smelting" })

OV.add_unlock("angels-advanced-chemistry-5", "advanced-chemical-plant-3")
OV.add_unlock("angels-tungsten-smelting-3", "solid-tungsten-trioxide-smelting")
OV.add_unlock("angels-tungsten-smelting-3", "pellet-tungsten-smelting-2")
OV.add_unlock("angels-tungsten-smelting-3", "solid-sodium-tungstate-smelting")
OV.add_unlock("angels-tungsten-smelting-3", "casting-powder-tungsten-3")
OV.add_unlock("angels-zinc-smelting-2", "powder-zinc")
OV.add_unlock("angels-nitrogen-processing-1", "gas-argon")
OV.add_unlock("angels-advanced-chemistry-4", "angels-air-filter-4")
OV.add_prereq("angels-tungsten-smelting-3", "angels-manganese-smelting-3")
OV.add_prereq("angels-tungsten-smelting-3", "angels-zinc-smelting-2")
OV.add_prereq("angels-tungsten-smelting-3", "sodium-processing-3")

OV.add_unlock("advanced-ore-refining-3", "ore-crusher-4")
OV.add_unlock("advanced-ore-refining-4", "ore-floatation-cell-4")
OV.add_unlock("water-treatment-4", "hydro-plant-4")

if mods["boblogistics"] then
  OV.remove_prereq("bob-repair-pack-5", "tungsten-alloy-processing")
  OV.remove_prereq("bob-robots-3", "tungsten-alloy-processing")
  OV.add_prereq("bob-repair-pack-5", "angels-tungsten-carbide-smelting-1")
  OV.add_prereq("bob-robots-3", "angels-tungsten-carbide-smelting-1")
end

if mods["bobrevamp"] then
  OV.remove_prereq("heat-shield", "tungsten-alloy-processing")
  OV.add_prereq("heat-shield", "angels-tungsten-carbide-smelting-1")
end

if mods["bobwarfare"] then
  OV.remove_prereq("tankotron", "tungsten-alloy-processing")
  OV.add_prereq("tankotron", "angels-tungsten-carbide-smelting-1")
end

if mods["Clowns-Extended-Minerals"] then
    OV.add_unlock("water-washing-3", "washing-plant-3")
end

if mods["Clowns-Processing"] then
    OV.add_unlock("phosphorus-processing-2", "solid-disodium-phosphate")
    OV.add_unlock("phosphorus-processing-2", "solid-tetrasodium-pyrophosphate")
    OV.add_unlock("water-treatment-5", "salination-plant-3")
end

if angelsmods.bioprocessing then
    OV.add_unlock("bio-arboretum-2", "bio-generator-temperate-2")
    OV.add_unlock("bio-arboretum-2", "bio-generator-swamp-2")
    OV.add_unlock("bio-arboretum-2", "bio-generator-desert-2")
    OV.add_unlock("bio-arboretum-2", "bio-arboretum-2")
    OV.add_unlock("bio-arboretum-3", "bio-generator-temperate-3")
    OV.add_unlock("bio-arboretum-3", "bio-generator-swamp-3")
    OV.add_unlock("bio-arboretum-3", "bio-generator-desert-3")
    OV.add_unlock("bio-arboretum-3", "bio-arboretum-3")
    OV.add_unlock("bio-refugium-butchery-2", "bio-butchery-2")
    OV.add_unlock("bio-refugium-puffer-4", "bio-refugium-puffer-2")
    OV.add_unlock("bio-refugium-puffer-4", "bio-refugium-puffer-3")
    OV.add_unlock("bio-refugium-biter-2", "bio-refugium-biter-2")
    OV.add_unlock("bio-refugium-biter-3", "bio-refugium-biter-3")
    OV.add_unlock("bio-farm-2", "crop-farm-2")
    OV.add_unlock("bio-farm-2", "composter-2")
    OV.add_unlock("bio-farm-2", "bio-processor-2")
    OV.add_unlock("bio-pressing-2", "bio-press-2")
    OV.add_unlock("bio-pressing-2", "bio-press-3")
    OV.add_unlock("gardens-2", "seed-extractor-2")
    OV.add_unlock("gardens-3", "seed-extractor-3")
end

if mods["angelsaddons-storage"] then
    if data.raw.tool["advanced-logistic-science-pack"] then
        bobmods.lib.tech.replace_science_pack("logistic-warehouses-3", "production-science-pack", "advanced-logistic-science-pack")
        bobmods.lib.tech.replace_science_pack("logistic-warehouses-4", "production-science-pack", "advanced-logistic-science-pack")
        bobmods.lib.tech.replace_science_pack("warehouses-4", "production-science-pack", "advanced-logistic-science-pack")
    end
end
