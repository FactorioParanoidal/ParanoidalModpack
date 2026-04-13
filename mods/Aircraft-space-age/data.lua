require("prototypes.entity.particles")
require("prototypes.entity.projectiles")
require("prototypes.entity.entities")
require("prototypes.items")
require("prototypes.recipes")
require("prototypes.technologies")
require("prototypes.equipment-grid")
require("prototypes.equipment")

if mods["space-age"] then
    require("prototypes.carbon-fiber-aircraft")
end
require("prototypes.recipe-updates") --Mod Compatibility
require("prototypes.technologies-updates") --Mod Compatibility
require("compat.planet-muluna") --Mod Compatibility
