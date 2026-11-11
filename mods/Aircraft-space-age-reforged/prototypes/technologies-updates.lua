local aircraft = require("shared.aircraft")
local helper = require("lib.data-util")

if data.raw.item["bob-cobalt-steel-alloy"] then
  helper.material_gate("gunships", {"angels-cobalt-steel-smelting-1", "bob-cobalt-processing", "cobalt-processing"})
end
if data.raw.item["bob-nitinol-alloy"] then
  helper.material_gate("jets", {"angels-nitinol-smelting-1", "bob-nitinol-processing", "nitinol-processing"})
end
if data.raw.item["bob-copper-tungsten-alloy"] then
  helper.material_gate("flying-fortress", {"angels-copper-tungsten-smelting-1", "tungsten-alloy-processing", "bob-tungsten-processing"})
elseif data.raw.item["tungsten-plate"] then
  helper.material_gate("flying-fortress", {"tungsten-processing", "bob-tungsten-processing"})
end

-- Alternative Oil can remove Flammables; never overwrite this decision in the non-combat branch.
if data.raw.technology.hydrocarbons then helper.remove_prerequisite("napalm", "flammables") end

if mods["space-age"] then
  helper.science(data.raw.technology["flying-fortress"], "metallurgic-science-pack")
  helper.prerequisite("flying-fortress", "metallurgic-science-pack")
  local shield = data.raw.technology["aircraft-energy-shield"]
  shield.unit.count = 1000
  helper.science(shield, "space-science-pack")
  helper.science(shield, "electromagnetic-science-pack")
  helper.prerequisite("aircraft-energy-shield", "electromagnetic-science-pack")
  local afterburner = data.raw.technology.afterburner
  afterburner.unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"space-science-pack", 1}}
  helper.remove_prerequisite("afterburner", "utility-science-pack")
  helper.prerequisite("afterburner", "space-science-pack")
  if settings.startup["aircraft-change-vanilla-tech-tree"].value then
    helper.prerequisite("rocket-silo", "cargo-planes")
    helper.prerequisite("space-platform-thruster", "afterburner")
  end
end

for _, spec in ipairs(aircraft.aircraft) do
  local carbon = data.raw.technology[spec.technology .. "-carbon-fiber"]
  if carbon then
    carbon.unit = table.deepcopy(data.raw.technology[spec.technology].unit)
    carbon.unit.count = carbon.unit.count * 2
    helper.science(carbon, "agricultural-science-pack")
    helper.science(carbon, "space-science-pack")
  end
  if settings.startup["non-combat-mode"].value and spec.name ~= "cargo-plane" then
    data.raw.technology[spec.technology].enabled = false
    if carbon then carbon.enabled = false end
  end
end
