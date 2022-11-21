require("data-nuke-terrain")
require("data-radiation")
require("data-nukes-intermediate")
require("data-nukes-warheads-create")
require("data-nukes-warheads-weapon-appearance")
require("data-nukes-technology")
require("data-nukes-achievements")

if mods["space-exploration"] then
  require("compatibility.SE")
end
if mods["Krastorio2"] then
  require("compatibility.K2")
end
if mods["SchallTankPlatoon"] then
  require("compatibility.STP")
end

if mods["Nuclear Fuel"] then
  require("compatibility.nuclear-fuel")
end
if mods["PlutoniumEnergy"] then
  require("compatibility.plutonium-energy")
end
if mods["Clowns-Nuclear"] then
  require("compatibility.clowns-nuclear")
end
if mods["apm_nuclear_ldinc"] then
  require("compatibility.apm-nuclear")
end
if mods["bobwarfare"] then
  data.raw.technology["bob-atomic-artillery-shell"] = nil
end