require "prototypes.mod-data.control-constants"
require "scripts.constants"
_G.maraxsis = {}
_G.maraxsis_constants = data.raw["mod-data"]["maraxsis-constants"].data
require "lib.lib"

require "prototypes.damage-types"
require "prototypes.spidertron-patrols"
require "prototypes.entity.water-shader"
require "prototypes.entity.submarine"
require "prototypes.entity.rocks"
require "prototypes.entity.trench-duct"
require "prototypes.entity.fish"
require "prototypes.entity.cliffs"
require "prototypes.entity.regulator"
require "prototypes.entity.pressure-dome"
require "prototypes.entity.fishing-tower"
require "prototypes.entity.bubbles"
require "prototypes.entity.coral"
require "prototypes.entity.offshore-pump"
require "prototypes.entity.hydro-plant"
require "prototypes.entity.sonar"
require "prototypes.recipe.sand-extraction"
require "prototypes.entity.conduit"
require "prototypes.entity.oversized-steam-turbine"
require "prototypes.entity.geothermal-generator"

require "prototypes.technology.abyssal-diving-gear"
require "prototypes.technology.technology"
require "prototypes.technology.piscary"
require "prototypes.technology.fat-man"
require "prototypes.technology.depth-charges"
require "prototypes.technology.atmosphere"
require "prototypes.technology.project-seadragon"
require "prototypes.technology.glass"
require "prototypes.technology.wyrm"
require "prototypes.technology.water-treatment"
require "prototypes.technology.hydraulic-science-pack"
require "prototypes.technology.omega-3"
require "prototypes.technology.stone-centrifuging"
require "prototypes.technology.deepsea-research"
require "prototypes.fluid.supercritical-steam"
require "prototypes.recipe.recipes"

require "prototypes.circuit-connector-definitions"
require "prototypes.tiles"
require "prototypes.planet.space-location"
require "prototypes.nuke-effects"
require "prototypes.achievements"
require "prototypes.custom-input"
require "prototypes.music"
require "prototypes.tips-and-tricks"

require "compat.krastorio-2"

data.raw["mining-drill"]["burner-mining-drill"].maraxsis_buildability_rules = { water = false, dome = false, coral = false, trench = false, trench_entrance = false, trench_lava = false }
data.raw["assembling-machine"]["chemical-plant"].maraxsis_buildability_rules = { water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false }
data.raw["electric-energy-interface"]["electric-energy-interface"].maraxsis_buildability_rules = { water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false }

-- Any Planet Start integration. Register Maraxsis as a custom starting planet so
-- any-planet-start runs the maraxsis-start content only when it is selected.
if mods["any-planet-start"] then
    APS.add_planet {
        name = "maraxsis",
        filename = "__maraxsis__/maraxsis-start/maraxsis.lua",
        technology = "planet-discovery-maraxsis",
    }

    if settings.startup["aps-planet"] and settings.startup["aps-planet"].value == "maraxsis" then
        require "maraxsis-start.data"
    end
end
