table.insert(data.raw["technology"]["angels-advanced-chemistry-4"].effects, {type = "unlock-recipe", recipe = "hydrofluoric-acid-separation"})
table.insert(data.raw["technology"]["chlorine-processing-3"].effects, {type = "unlock-recipe", recipe = "hydrochloric-acid-separation"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalytic-air-separation-oxygen"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalytic-air-separation-nitrogen"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalytic-water-separation-oxygen"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalytic-water-separation-hydrogen"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalyst-metal-violet"})

table.insert(data.raw["technology"]["water-washing-1"].effects, {type = "unlock-recipe", recipe = "sluicer"})
if data.raw.recipe["sand-sluicing"] then -- may not activate under all conditions
  table.insert(data.raw["technology"]["water-washing-1"].effects, {type = "unlock-recipe", recipe = "sand-sluicing"})
  table.insert(data.raw["technology"]["water-washing-2"].effects, {type = "unlock-recipe", recipe = "sluicer-2"})
end

table.insert(data.raw["technology"]["water-treatment-4"].effects, {type = "unlock-recipe", recipe = "intermediate-salination"})

if data.raw.recipe["nickel-piercing-rounds-magazine"] then
  table.insert(data.raw["technology"]["military-2"].effects, {type = "unlock-recipe", recipe = "nickel-piercing-rounds-magazine"})
end

if data.raw.recipe["molten-aluminium-smelting-4"] then
  table.insert(data.raw["technology"]["angels-aluminium-smelting-2"].effects, {type = "unlock-recipe", recipe = "molten-aluminium-smelting-4"})
end
if data.raw.recipe["molten-aluminium-smelting-5"] then
  table.insert(data.raw["technology"]["angels-aluminium-smelting-3"].effects, {type = "unlock-recipe", recipe = "molten-aluminium-smelting-5"})
end

if data.raw.recipe["molten-iron-smelting-6"] then
  table.insert(data.raw["technology"]["angels-iron-smelting-3"].effects, {type = "unlock-recipe", recipe = "molten-iron-smelting-6"})
end

if data.raw.recipe["angels-brass-smelting-4"] then
  table.insert(data.raw["technology"]["angels-brass-smelting-3"].effects, {type = "unlock-recipe", recipe = "angels-brass-smelting-4"})
end

if angelsmods.trigger.smelting_products["titanium"].plate then
  table.insert(data.raw["technology"]["angels-titanium-smelting-2"].effects, {type = "unlock-recipe", recipe = "sponge-magnesium-titanium-smelting"})
  table.insert(data.raw["technology"]["angels-titanium-smelting-3"].effects, {type = "unlock-recipe", recipe = "pellet-magnesium-titanium-smelting"})
  table.insert(data.raw["technology"]["angels-titanium-smelting-2"].prerequisites, "sodium-processing")
end
if data.raw.recipe["molten-steel-smelting-c2"] then
  table.insert(data.raw["technology"]["angels-steel-smelting-2"].effects, {type = "unlock-recipe", recipe = "molten-steel-smelting-c2"})
end