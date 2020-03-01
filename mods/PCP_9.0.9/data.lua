--data:extend({{type = "damage-type",name = "pcp-chemical"}})
require("prototypes.items")
require("prototypes.fluids")
require("prototypes.recipes")
require("prototypes.technology")
--[[if settings.startup["pcp-enable-experimental"].value then
require ("prototypes.chemical-cloud")
require ("prototypes.entity.chemical-turret")
require ("prototypes.entity.tile")
require ("prototypes.entity.wall")
end]]