-- --Prototypes loading with priority order

-- Loading items
require("prototypes.1-items")

-- Loading entity
require("prototypes.2-entity")

-- Loading recipes
require("prototypes.3-recipes")

-- Loading tecnologies
require("prototypes.4-tecnologies")

-- -- Apply compatibility scripts (data stage)
----------------------------------------------------------
require("compatibility-scripts/data/squeak_through_fix")
require("compatibility-scripts/data/ab_fix")
----------------------------------------------------------
