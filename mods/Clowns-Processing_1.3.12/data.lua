require("prototypes.categories")

-- ITEMS
-- vanilla-items include things for angels-refining,smelting and petrochem
require("prototypes.buildings.sluicer")
require("prototypes.buildings.centrifuge")--active if setting

require("prototypes.items.vanilla-items")
require("prototypes.items.neurotoxin")
--angelsbioprocessing
require("prototypes.items.angels-bioprocessing")
--angelsindustries
--bobs

--RECIPES
--vanilla
require("prototypes.recipes.vanilla-recipes")
require("prototypes.recipes.angels-smelting")
require("prototypes.recipes.petrochem")
--angelsbioprocessing
require("prototypes.recipes.angels-bioprocessing")
--bobs
require("prototypes.recipes.bobs")


--if mods["angelsbioprocessing"] then
require("prototypes.technology.gardens")
--end
require("prototypes.technology.magnesium")
require("prototypes.technology.depleted-uranium")
require("prototypes.technology.osmium")
require("prototypes.technology.uranium")
require("prototypes.technology.mercury")
--if settings.startup["MCP_enable_centrifuges"].value then
require("prototypes.technology.centrifuging")
--end
require("prototypes.technology.salination")
require("prototypes.technology.phosphorus")

require("prototypes.overrides")
