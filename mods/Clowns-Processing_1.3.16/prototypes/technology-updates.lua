local OV = angelsmods.functions.OV
local unlock_lists = {
  {"angels-advanced-chemistry-4","hydrofluoric-acid-separation"},
  {"chlorine-processing-3","hydrochloric-acid-separation"},
  {"angels-advanced-chemistry-3","catalytic-air-separation-oxygen"},
  {"angels-advanced-chemistry-3","catalytic-air-separation-nitrogen"},
  {"angels-advanced-chemistry-3","catalytic-water-separation-oxygen"},
  {"angels-advanced-chemistry-3","catalytic-water-separation-hydrogen"},
  {"angels-advanced-chemistry-3","catalyst-metal-violet"},
  {"water-washing-1","sluicer"},
  {"water-treatment-4","intermediate-salination"},
}
if data.raw.recipe["sand-sluicing"] then
  table.insert(unlock_lists,{"water-washing-1","sand-sluicing"})
  table.insert(unlock_lists,{"water-washing-2","sluicer-2"})
end
if data.raw.recipe["nickel-piercing-rounds-magazine"] then
  table.insert(unlock_lists,{"military-2","nickel-piercing-rounds-magazine"})
end
if data.raw.recipe["molten-aluminium-smelting-4"] then
  table.insert(unlock_lists,{"angels-aluminium-smelting-2","molten-aluminium-smelting-4"})
end
if data.raw.recipe["molten-aluminium-smelting-5"] then
  table.insert(unlock_lists,{"angels-aluminium-smelting-3","molten-aluminium-smelting-5"})
end
if data.raw.recipe["molten-iron-smelting-6"] then
  table.insert(unlock_lists,{"angels-iron-smelting-3","molten-iron-smelting-6"})
end
if data.raw.recipe["angels-brass-smelting-4"] then
  table.insert(unlock_lists,{"angels-brass-smelting-3","angels-brass-smelting-4"})
end
if angelsmods.trigger.smelting_products["titanium"].plate then
  table.insert(unlock_lists,{"angels-titanium-smelting-2","sponge-magnesium-titanium-smelting"})
  table.insert(unlock_lists,{"angels-titanium-smelting-3","pellet-magnesium-titanium-smelting"})
  OV.add_prereq("angels-titanium-smelting-2", "sodium-processing")
end
if data.raw.recipe["molten-steel-smelting-c2"] then
  table.insert(unlock_lists,{"angels-steel-smelting-2","molten-steel-smelting-c2"})
end
--run the update table
for _, tech in pairs(unlock_lists) do
  OV.add_unlock(tech[1],tech[2])
end
