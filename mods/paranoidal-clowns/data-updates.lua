---------------------------------------------------------------------------------------------------
-- Nuclear
---------------------------------------------------------------------------------------------------
clowns.functions.add_unlock("kovarex-enrichment-process", "depleted-uranium-reprocessing")
clowns.functions.add_unlock("kovarex-enrichment-process", "clowns-centrifuging-80pc")
clowns.functions.add_unlock("kovarex-enrichment-process", "clowns-centrifuging-75pc")
clowns.functions.add_unlock("kovarex-enrichment-process", "clowns-centrifuging-70pc")
clowns.functions.add_unlock("kovarex-enrichment-process", "clowns-centrifuging-65pc")
clowns.functions.add_unlock("kovarex-enrichment-process", "clowns-centrifuging-55pc")
clowns.functions.add_unlock("kovarex-enrichment-process", "clowns-centrifuging-45pc")
clowns.functions.add_unlock("kovarex-enrichment-process", "nuclear-fuel")

clowns.functions.replace_ing("uranium-fuel-cell", "uranium-235", "35pc-uranium", "ing")

---------------------------------------------------------------------------------------------------
-- Processing
---------------------------------------------------------------------------------------------------
data.raw.recipe["advanced-uranium-processing"].subgroup = "angels-power-nuclear-processing"
data.raw.recipe["advanced-uranium-processing"].order = "a[uranium]-b[adv-processing]"

require("prototypes.technology-updates")

angelsmods.functions.allow_productivity("clowns-plate-osmium")
angelsmods.functions.allow_productivity("clowns-plate-depleted-uranium")

---------------------------------------------------------------------------------------------------
-- AngelBob nuclear
---------------------------------------------------------------------------------------------------
require("prototypes.angelbob.technology-overrides")
require("prototypes.angelbob.more-overrides")
