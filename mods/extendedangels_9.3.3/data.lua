require("prototypes.subgroups")

-- For Angel's Petrochem
require("prototypes.items.petrochem")

-- For Angel's Smelting
require("prototypes.items.smelting")
require("prototypes.recipes.smelting")
require("prototypes.technology.smelting-technology")

-- For Angel's Bio Processing
require("prototypes.buildings.bioprocessing")


-- For Angel's Petrochem
require("prototypes.buildings.petrochem")


-- For Angel's Refining
require("prototypes.buildings.refining")

-- For Angel's Extra Warehouses
if mods["angelsaddons-warehouses"] then
    require("prototypes.buildings.warehouses")
end

