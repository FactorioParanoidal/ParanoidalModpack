aai_industry = true
if not logged_mods_once then logged_mods_once = true log("Log mods once: "..serpent.block(mods)) end

require("prototypes/phase-1/light")
require("prototypes/phase-1/tile/stone-path")
require("prototypes/phase-1/item/item")
require("prototypes/phase-1/recipe/recipe")
require("prototypes/phase-1/recipe/base-recipe-changes")
require("prototypes/phase-1/entity/resources")
require("prototypes/phase-1/entity/entity")
require("prototypes/phase-1/entity/entity-walls")
require("prototypes/phase-1/entity/entity-gates") -- after entity-walls
require("prototypes/phase-1/entity/entity-burner-lab")
require("prototypes/phase-1/entity/entity-offshore-pump")
require("prototypes/phase-1/entity/entity-burner-turbine")
require("prototypes/phase-1/entity/entity-burner-assembling-machine")

require("prototypes/phase-1/combined/processed-fuel")

require("prototypes/phase-1/technology/technology")

require("prototypes/phase-1/combined/industrial-furnace")

require("prototypes/phase-1/combined/area-mining-drill")

require("prototypes/phase-1/compatibility/space-age")
