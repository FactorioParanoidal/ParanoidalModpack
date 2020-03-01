table.insert(data.raw["technology"]["angels-advanced-chemistry-4"].effects, {type = "unlock-recipe", recipe = "hydrofluoric-acid-separation"})
table.insert(data.raw["technology"]["chlorine-processing-3"].effects, {type = "unlock-recipe", recipe = "hydrochloric-acid-separation"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalytic-air-separation-oxygen"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalytic-air-separation-nitrogen"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalytic-water-separation-oxygen"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalytic-water-separation-hydrogen"})
table.insert(data.raw["technology"]["angels-advanced-chemistry-3"].effects, {type = "unlock-recipe", recipe = "catalyst-metal-violet"})

table.insert(data.raw["technology"]["water-washing-1"].effects, {type = "unlock-recipe", recipe = "sluicer"})
table.insert(data.raw["technology"]["water-washing-1"].effects, {type = "unlock-recipe", recipe = "sand-sluicing"})

table.insert(data.raw["technology"]["water-treatment-4"].effects, {type = "unlock-recipe", recipe = "intermediate-salination"})

table.insert(data.raw["technology"]["angels-aluminium-smelting-2"].effects, {type = "unlock-recipe", recipe = "molten-aluminium-smelting-4"})
table.insert(data.raw["technology"]["angels-aluminium-smelting-3"].effects, {type = "unlock-recipe", recipe = "molten-aluminium-smelting-5"})
table.insert(data.raw["technology"]["angels-iron-smelting-3"].effects, {type = "unlock-recipe", recipe = "molten-iron-smelting-6"})
table.insert(data.raw["technology"]["angels-brass-smelting-3"].effects, {type = "unlock-recipe", recipe = "angels-brass-smelting-4"})
table.insert(data.raw["technology"]["angels-titanium-smelting-2"].effects, {type = "unlock-recipe", recipe = "sponge-magnesium-titanium-smelting"})
table.insert(data.raw["technology"]["angels-titanium-smelting-3"].effects, {type = "unlock-recipe", recipe = "pellet-magnesium-titanium-smelting"})

table.insert(data.raw["technology"]["angels-titanium-smelting-2"].prerequisites, "sodium-processing")

if mods["Clowns-Extended-Minerals"] then
	table.insert(data.raw["technology"]["advanced-ore-refining-1"].effects, {type = "unlock-recipe", recipe = "manganese-pure-processing"})
	table.insert(data.raw["technology"]["advanced-ore-refining-1"].effects, {type = "unlock-recipe", recipe = "phosphorus-pure-processing"})
	table.insert(data.raw["technology"]["advanced-ore-refining-3"].effects, {type = "unlock-recipe", recipe = "chrome-pure-processing"})
	table.insert(data.raw["technology"]["advanced-ore-refining-4"].effects, {type = "unlock-recipe", recipe = "platinum-pure-processing"})
	table.insert(data.raw["technology"]["advanced-ore-refining-4"].effects, {type = "unlock-recipe", recipe = "osmium-pure-processing"})
	table.insert(data.raw["technology"]["advanced-ore-refining-2"].effects, {type = "unlock-recipe", recipe = "magnesium-pure-processing"})
	
	angelsmods.functions.allow_productivity("manganese-pure-processing")
	angelsmods.functions.allow_productivity("phosphorus-pure-processing")
	angelsmods.functions.allow_productivity("chrome-pure-processing")
	angelsmods.functions.allow_productivity("platinum-pure-processing")
	angelsmods.functions.allow_productivity("osmium-pure-processing")
	angelsmods.functions.allow_productivity("magnesium-pure-processing")
	if mods["Clowns-Nuclear"] then
		table.insert(data.raw["technology"]["advanced-ore-refining-3"].effects, {type = "unlock-recipe", recipe = "thorium-pure-processing"})
		angelsmods.functions.allow_productivity("thorium-pure-processing")
	end
end

angelsmods.functions.allow_productivity("clowns-plate-osmium")

if settings.startup["depleted-uranium"].value == true then
	angelsmods.functions.allow_productivity("clowns-plate-depleted-uranium")
end