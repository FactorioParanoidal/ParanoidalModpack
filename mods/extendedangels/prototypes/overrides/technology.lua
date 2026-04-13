local OV = angelsmods.functions.OV

OV.add_unlock("angels-advanced-chemistry-5", "angels-advanced-chemical-plant-3")
OV.add_unlock("angels-tungsten-smelting-3", "angels-solid-tungsten-trioxide-smelting")
OV.add_unlock("angels-tungsten-smelting-3", "angels-pellet-tungsten-smelting-2")
OV.add_unlock("angels-tungsten-smelting-3", "angels-solid-sodium-tungstate-smelting")
OV.add_unlock("angels-tungsten-smelting-3", "angels-casting-powder-tungsten-3")
OV.add_unlock("angels-zinc-smelting-2", "angels-powder-zinc")
OV.add_unlock("angels-nitrogen-processing-1", "angels-gas-argon")
OV.add_unlock("angels-advanced-chemistry-4", "angels-air-filter-4")
OV.add_prereq("angels-tungsten-smelting-3", "angels-manganese-smelting-3")
OV.add_prereq("angels-tungsten-smelting-3", "angels-zinc-smelting-2")
OV.add_prereq("angels-tungsten-smelting-3", "angels-sodium-processing-3")
OV.add_prereq("bob-tungsten-alloy-processing", "angels-tungsten-carbide-smelting-1")
OV.add_prereq("angels-advanced-chemistry-4", "angels-nitrogen-processing-3")
OV.add_unlock("angels-advanced-ore-refining-3", "angels-ore-crusher-4")
OV.add_unlock("angels-advanced-ore-refining-4", "angels-ore-floatation-cell-4")
OV.add_unlock("angels-water-treatment-4", "angels-hydro-plant-4")
OV.add_prereq("angels-advanced-chemistry-5", "angels-stone-smelting-4")
OV.add_prereq("angels-advanced-ore-refining-4", "angels-stone-smelting-4")
OV.add_prereq("angels-metallurgy-5", "angels-stone-smelting-4")
OV.add_prereq("angels-powder-metallurgy-5", "angels-stone-smelting-4")
OV.add_prereq("angels-ore-processing-4", "angels-stone-smelting-4")
OV.add_prereq("angels-strand-casting-4", "angels-stone-smelting-4")


if mods["bobplates"] then
OV.add_prereq("bob-tungsten-alloy-processing", "angels-copper-tungsten-smelting-1")
OV.add_prereq("angels-warehouses-2","bob-zinc-processing")
OV.add_prereq("angels-warehouses-2","angels-invar-smelting-1")
OV.add_prereq("angels-warehouses-3","bob-ceramics")
OV.add_prereq("angels-warehouses-4","bob-nitinol-processing")
OV.add_prereq("angels-logistic-warehouses-2","bob-zinc-processing")
OV.add_prereq("angels-logistic-warehouses-2","angels-invar-smelting-1")
OV.add_prereq("angels-logistic-warehouses-3","bob-ceramics")
OV.add_prereq("angels-logistic-warehouses-4","bob-nitinol-processing")
OV.add_prereq("angels-logistic-warehouses-4","bob-advanced-processing-unit")
OV.add_prereq("angels-water-washing-3", "bob-zinc-processing")
OV.add_prereq("angels-water-washing-4","bob-titanium-processing")
OV.add_prereq("angels-advanced-ore-refining-5", "bob-tungsten-alloy-processing")
OV.add_prereq(
    "angels-water-treatment-5",
  { 
    "bob-advanced-processing-unit",
    "bob-tungsten-alloy-processing",
  })

else
OV.add_unlock("angels-tungsten-smelting-3", "angels-solid-tungsten-oxide-smelting-2")
OV.add_prereq("angels-warehouses-2","angels-aluminium-smelting-1")
OV.add_prereq("angels-warehouses-3","angels-titanium-smelting-1")
OV.add_prereq("angels-warehouses-4","angels-tungsten-smelting-1")
OV.add_prereq("angels-logistic-warehouses-2","angels-aluminium-smelting-1")
OV.add_prereq("angels-logistic-warehouses-3","angels-titanium-smelting-1")
OV.add_prereq("angels-logistic-warehouses-3","processing-unit") 
OV.add_prereq("angels-logistic-warehouses-4","angels-tungsten-smelting-1")
OV.add_prereq("angels-logistic-warehouses-4","processing-unit") 
OV.add_prereq("angels-water-washing-4","angels-titanium-smelting-1")
OV.add_prereq("angels-water-treatment-5", "angels-tungsten-smelting-1")
end
if mods["Clowns-Processing"] then
  OV.add_unlock("phosphorus-processing-2", "angels-solid-disodium-phosphate")
  OV.add_unlock("phosphorus-processing-2", "angels-solid-tetrasodium-pyrophosphate")
  OV.add_unlock("angels-water-treatment-5", "angels-salination-plant-3")
  OV.add_prereq("angels-water-treatment-5", "angels-stone-smelting-4")
  OV.add_prereq("angels-tungsten-smelting-3", "phosphorus-processing-2")
end

if  mods["Clowns-Extended-Minerals"] then
   OV.add_unlock("angels-water-washing-3", "angels-washing-plant-3")
end

if angelsmods.bioprocessing then
  OV.add_unlock("angels-bio-arboretum-2", "angels-bio-generator-temperate-2")
  OV.add_unlock("angels-bio-arboretum-2", "angels-bio-generator-swamp-2")
  OV.add_unlock("angels-bio-arboretum-2", "angels-bio-generator-desert-2")
  OV.add_unlock("angels-bio-arboretum-2", "angels-bio-arboretum-2")
  OV.add_unlock("angels-bio-arboretum-3", "angels-bio-generator-temperate-3")
  OV.add_unlock("angels-bio-arboretum-3", "angels-bio-generator-swamp-3")
  OV.add_unlock("angels-bio-arboretum-3", "angels-bio-generator-desert-3")
  OV.add_unlock("angels-bio-arboretum-3", "angels-bio-arboretum-3")
  OV.add_unlock("angels-bio-refugium-butchery-2", "angels-bio-butchery-2")
  OV.add_unlock("angels-bio-refugium-biter-2", "angels-bio-refugium-biter-2")
  OV.add_prereq("angels-bio-refugium-biter-2", "angels-stone-smelting-4")
  OV.add_unlock("angels-bio-refugium-biter-3", "angels-bio-refugium-biter-3")
  OV.add_unlock("angels-bio-farm-2", "angels-crop-farm-2")
  OV.add_unlock("angels-bio-farm-2", "angels-composter-2")
  OV.add_unlock("angels-bio-farm-2", "angels-bio-processor-2")
  OV.add_unlock("angels-bio-pressing-2", "angels-bio-press-2")
  OV.add_unlock("angels-gardens-2", "angels-seed-extractor-2")
  OV.add_unlock("angels-gardens-3", "angels-seed-extractor-3")
  OV.add_prereq("angels-gardens-3", "angels-aluminium-smelting-1")
  OV.add_prereq({
  "angels-advanced-bio-processing",
  "angels-bio-refugium-butchery-3",
  "angels-bio-farm-advanced-upgrade-1",
  "angels-bio-refugium-hatchery-2",
  "angels-bio-nutrient-paste-3",
  "angels-bio-refugium-fish-4",
  "angels-bio-pressing-3",
  },
  "processing-unit"
  )
  if mods["bobplates"] then
    OV.add_prereq("angels-gardens-2", "bob-alloy-processing")
    OV.add_prereq({
      "angels-bio-refugium-butchery-2",
      "angels-gardens-3",
      "angels-bio-farm-3",
      "angels-bio-nutrient-paste-2",
      "angels-bio-refugium-fish-3",
    },
      "bob-zinc-processing"
    )
    OV.add_prereq({
      "angels-bio-refugium-biter-2",
      "angels-bio-farm-advanced-upgrade-2",
      "angels-bio-refugium-hatchery-3",
      "angels-bio-refugium-puffer-5",
    },
      "bob-advanced-processing-unit"
      )

    OV.add_prereq({
      "angels-bio-refugium-biter-2",
      "angels-bio-farm-advanced-upgrade-2",
      "angels-bio-refugium-hatchery-3",
      "angels-bio-refugium-puffer-5",
    },
      "bob-tungsten-alloy-processing"
      )
    OV.add_prereq({
      "angels-advanced-bio-processing",
      "angels-bio-refugium-butchery-3",
      "angels-bio-farm-advanced-upgrade-1",
      "angels-bio-refugium-hatchery-2",
      "angels-bio-nutrient-paste-3",
      "angels-bio-refugium-fish-4",
      "angels-bio-pressing-3",
    },
      "bob-titanium-processing"
    )
  else
    OV.add_prereq({
      "angels-advanced-bio-processing",
      "angels-bio-refugium-butchery-3",
      "angels-bio-farm-advanced-upgrade-1",
      "angels-bio-refugium-hatchery-2",
      "angels-bio-nutrient-paste-3",
      "angels-bio-refugium-fish-4",
      "angels-bio-pressing-3",
    },
      "angels-titanium-smelting-1"
  )
    OV.add_prereq({
      "angels-bio-refugium-biter-2",
      "angels-bio-farm-advanced-upgrade-2",
      "angels-bio-refugium-hatchery-3",
      "angels-bio-refugium-puffer-5",
    },
      "angels-tungsten-smelting-1"
      )
  end
end

if mods["angelsaddons-storage"] then
  if data.raw.tool["bob-advanced-logistic-science-pack"] then
    bobmods.lib.tech.replace_science_pack(
      "angels-logistic-warehouses-2",
      "utility-science-pack",
      "bob-advanced-logistic-science-pack"
    )
    bobmods.lib.tech.replace_science_pack(
      "angels-logistic-warehouses-3",
      "production-science-pack",
      "bob-advanced-logistic-science-pack"
    )
    bobmods.lib.tech.add_science_pack(
      "ngels-logistic-warehouses-4",
      "bob-advanced-logistic-science-pack",
      1
    )
    bobmods.lib.tech.add_science_pack(
      "angels-warehouses-4",
      "bob-advanced-logistic-science-pack",
      1
    )
  end
end
