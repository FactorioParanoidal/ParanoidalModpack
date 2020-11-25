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

table.insert(data.raw["spider-vehicle"]["spidertron"].resistances, { type = "poison", decrease = 15, percent = 80 })
table.insert(data.raw["spider-vehicle"]["spidertron"].resistances, { type = "plasma", decrease = 0, percent = 90 })
table.insert(data.raw["spider-vehicle"]["spidertron"].resistances, { type = "bob-pierce", decrease = 0, percent = 50 })
