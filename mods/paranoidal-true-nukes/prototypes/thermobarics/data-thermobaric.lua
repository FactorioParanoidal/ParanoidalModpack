require("data-thermobaric-warheads")
require("data-thermobaric-warheads-weapon-appearance")

local thermobaric_tech = table.deepcopy(data.raw["technology"]["military-3"])
thermobaric_tech.name = "thermobaric-weaponry"
thermobaric_tech.effects = {}


thermobaric_tech.prerequisites = {"rocket-fuel", "flamethrower", "military-3"}
thermobaric_tech.icon = "__paranoidal-true-nukes__/graphics/thermobaric-tech.png"
thermobaric_tech.icon_mipmaps = 1
thermobaric_tech.unit.count=250
data:extend{thermobaric_tech}
