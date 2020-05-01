require("prototypes.overides")
require("prototypes.recipe.recipe-updates")
require("prototypes.technology.technology-updates")
require("prototypes.productivity-limitations")

require("prototypes.robots-updates")
require("prototypes.train-updates")
require("prototypes.recipe.drone-updates")

if settings.startup["bobmods-warfare-drainlesslaserturrets"].value == true then
  for index, turret in pairs(data.raw["electric-turret"]) do
    turret.energy_source.drain = "0W"
  end
end

table.insert(data.raw.car.tank.resistances, { type = "plasma", decrease = 15, percent = 50 })
