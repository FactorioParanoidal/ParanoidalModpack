require("api")
local rro = Muluna.rro 
require("prototypes.fuel-categories")
require("prototypes.overrides.vanilla-overrides")
require("prototypes.custom-inputs")
require("prototypes.custom-prototypes.heat-assembling-machine")
require("wood-gasification.data")
require("prototypes.tips-and-tricks")
require("prototypes.planet.planet")
require("prototypes.entity.index")
require("prototypes.water-treatment")
require("prototypes.item.index")
require("prototypes.planet.asteroids")
require("prototypes.technology.index")
require("vanilla-changes.asteroid-chunk-icons")
require("prototypes.sound.index")
require("prototypes.atmosphere")
require("prototypes.recipe.index")
require("prototypes.tiles.tiles")
-- Paranoidal fork: no data pump (upstream deep-copied the home pump, its item and recipe and defined them again under
-- the same name; the build then took the home pump for planet content).

require("prototypes.tiles.artificial-tiles")

-- Lunar rocks are created after tiles and items so that PlanetsLib can validate
-- the gravel floor and crushed-stone item used by their deconstruction rule.
require("prototypes.entity.environment-entities")

require("prototypes.radiation")
require("prototypes.vacuum-robots")
require("prototypes.entity.oxidized-boiler")
require("prototypes.entity.vacuum-heating-tower")
--null change
require("prototypes.subgroups")
require("prototypes.lunar-science-pack")
require("prototypes.technology.interstellar-technologies") --Also runs during data-updates
require("prototypes.nav-beacon")
require("prototypes.decoratives.muluna-decoratives")
require("prototypes.achievements")


require("compat.maraxsis")
require("compat.solar-productivity")
require("compat.tile-upgrade-planner-muluna")

--if mods["MT-lib"] then require("compat.MT-lib") end
if mods["any-planet-start"] then
    APS.add_planet{
        name = "muluna" , 
        filename = "__planet-muluna__/compat/any-planet-start", 
        fixes_filename = "__planet-muluna__/compat/any-planet-start-final-fixes",
        technology = "planet-discovery-muluna"
    }
end

for _,lab in pairs(data.raw["lab"]) do
    if lab.name ~= "cerys-lab" then
        rro.soft_insert(lab.inputs,"interstellar-science-pack")
    end
end
