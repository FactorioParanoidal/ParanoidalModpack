local OV = angelsmods.functions.OV
local unlock_lists = {
  {"angels-advanced-chemistry-4","hydrofluoric-acid-separation"},
  {"angels-chlorine-processing-3","hydrochloric-acid-separation"},
  {"angels-advanced-chemistry-3","catalytic-air-separation-oxygen"},
  {"angels-advanced-chemistry-3","catalytic-air-separation-nitrogen"},
  {"angels-advanced-chemistry-3","catalytic-water-separation-oxygen"},
  {"angels-advanced-chemistry-3","catalytic-water-separation-hydrogen"},
  {"angels-advanced-chemistry-3","clowns-catalyst-metal-violet"},
  {"angels-water-washing-1","clowns-sluicer"},
  {"angels-water-treatment-4","intermediate-salination"},
}
if data.raw.recipe["sand-sluicing"] then
  table.insert(unlock_lists,{"angels-water-washing-1","sand-sluicing"})
  table.insert(unlock_lists,{"angels-water-washing-2","clowns-sluicer-2"})
  OV.remove_unlock("angels-composting", "angels-solid-sand")
  OV.remove_unlock("angels-stone-smelting-1", "angels-solid-sand")
  OV.add_unlock("angels-water-washing-1", "angels-solid-sand")
  OV.add_prereq("angels-water-washing-2", "concrete")
end
if data.raw.recipe["nickel-piercing-rounds-magazine"] then
  table.insert(unlock_lists,{"military-2","nickel-piercing-rounds-magazine"})
end
if data.raw.recipe["copper-nickel-firearm-magazine"] then
  table.insert(unlock_lists,{"angels-lead-smelting-1","copper-nickel-firearm-magazine"})
end
if data.raw.recipe["angels-brass-smelting-4"] then
  table.insert(unlock_lists,{"angels-brass-smelting-3","angels-brass-smelting-4"})
  OV.add_prereq("angels-brass-smelting-3", "phosphorus-processing-2")
end
if angelsmods.trigger.smelting_products["zinc"].plate then
	OV.add_unlock("advanced-magnesium-smelting-2", "molten-aluminium-smelting-5")
	OV.add_prereq("advanced-magnesium-smelting-2", "angels-zinc-smelting-3")
end
if angelsmods.trigger.smelting_products["titanium"].plate then
  table.insert(unlock_lists,{"angels-titanium-smelting-2","angels-sponge-magnesium-titanium-smelting"})
  table.insert(unlock_lists,{"advanced-magnesium-smelting-2","angels-pellet-magnesium-titanium-smelting"})
  OV.add_prereq("advanced-magnesium-smelting-2", "angels-titanium-smelting-3")
  if data.raw.technology["angels-sodium-processing"] then
    OV.add_prereq("angels-titanium-smelting-2", "angels-sodium-processing")
  else
    OV.add_prereq("angels-titanium-smelting-2", "angels-sodium-processing-1")
  end
end
--run the update table
for _, tech in pairs(unlock_lists) do
  OV.add_unlock(tech[1],tech[2])
end

OV.add_prereq("angels-advanced-chemistry-3", "mercury-processing-1")
OV.add_prereq("uranium-ammo", "advanced-depleted-uranium-smelting-1")
if mods["bobplates"] then
OV.add_prereq("centrifuging-2", "bob-tungsten-alloy-processing")
--OV.add_prereq("centrifuging-2", "bob-tungsten-processing")
end