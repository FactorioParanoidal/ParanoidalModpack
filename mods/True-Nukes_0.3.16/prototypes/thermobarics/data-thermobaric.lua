require("data-thermobaric-warheads")
require("data-thermobaric-warheads-weapon-appearance")

local thermobaric_tech = table.deepcopy(data.raw["technology"]["military-3"])
thermobaric_tech.name = "thermobaric-weaponry"
thermobaric_tech.effects = {}
  

if not mods["bobplates"] then
  thermobaric_tech.prerequisites = {"rocket-fuel", "flamethrower", "military-3"}
else
  thermobaric_tech.prerequisites = {"advanced-oil-processing", "flamethrower", "military-3"}
end
thermobaric_tech.prerequisites = {"rocket-fuel", "flamethrower", "military-3"}
thermobaric_tech.icon = "__True-Nukes__/graphics/thermobaric-tech.png"
thermobaric_tech.icon_mipmaps = 1
thermobaric_tech.unit.count=250
data:extend{thermobaric_tech}
