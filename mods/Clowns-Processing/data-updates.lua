require("prototypes.group-updates")
require("prototypes.technology-updates")

angelsmods.functions.allow_productivity("clowns-plate-osmium")

if settings.startup["depleted-uranium"].value == true then
	angelsmods.functions.allow_productivity("clowns-plate-depleted-uranium")
end
--update advanced uranium processing results in case that has changed
if not mods["Clowns-Nuclear"] then
  data.raw.recipe["advanced-uranium-processing"].results = data.raw.recipe["uranium-processing"].results
end