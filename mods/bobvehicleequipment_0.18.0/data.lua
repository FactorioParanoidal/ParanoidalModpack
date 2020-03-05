if not bobmods then bobmods = {} end
if not bobmods.equipment then bobmods.equipment = {} end

data:extend(
{
  {
    type = "damage-type",
    name = "plasma"
  },
}
)


require("prototypes.category")
require("prototypes.equipment-grid")

require("prototypes.entities")
require("prototypes.projectiles")
require("prototypes.beams")

require("prototypes.battery")
require("prototypes.generator")
require("prototypes.laser-defense")
require("prototypes.roboport")
require("prototypes.shield")
require("prototypes.solar-panel")
require("prototypes.speed")

