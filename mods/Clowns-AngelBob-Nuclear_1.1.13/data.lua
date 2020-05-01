--require("prototypes.items.thorium")
require("prototypes.items.isotopes")
require("prototypes.items.fuels")
require("prototypes.items.water-treatment")

require("prototypes.recipes.clowns-centrifuging")
if data.raw.item["thorium-ore"] then
  require("prototypes.recipes.thorium")
end
require("prototypes.recipes.nuclear-reprocessing")
require("prototypes.recipes.fuels")
require("prototypes.recipes.water-treatment")

--require("prototypes.technology.thorium")
require("prototypes.technology.fuels")
require("prototypes.technology.nuclear-reprocessing")

require("prototypes.overrides")
