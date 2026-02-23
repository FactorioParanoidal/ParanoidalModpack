--group updates? should this be moved to the actual recipes?
data.raw.recipe["advanced-uranium-processing"].subgroup = "angels-power-nuclear-processing"
data.raw.recipe["advanced-uranium-processing"].order = "a[uranium]-b[adv-processing]"

require("prototypes.technology-updates")

angelsmods.functions.allow_productivity("clowns-plate-osmium")
angelsmods.functions.allow_productivity("clowns-plate-depleted-uranium")

--update advanced uranium processing results in case that has changed
if not mods["Clowns-Nuclear"] then
  data.raw.recipe["advanced-uranium-processing"].results = data.raw.recipe["uranium-processing"].results
end