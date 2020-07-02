require("prototypes.group-updates")
require("prototypes.technology-updates")



--[[if mods["Clowns-Extended-Minerals"] then
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
end]]

angelsmods.functions.allow_productivity("clowns-plate-osmium")

if settings.startup["depleted-uranium"].value == true then
	angelsmods.functions.allow_productivity("clowns-plate-depleted-uranium")
end
--update advanced uranium processing results in case that has changed
if not mods["Clowns-Nuclear"] then
  data.raw.recipe["advanced-uranium-processing"].results = data.raw.recipe["uranium-processing"].results
end
