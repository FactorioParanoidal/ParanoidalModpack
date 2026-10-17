-- Power: wind turbines, RITEG, nuclear cycles, Bio Industries, burner generators, battery trains.
local lib = require("prototypes.content.lib")

return lib.list(
  {id = "winds-of-change", kind = "build", entity = "texugo-wind-turbine3"},
  {id = "riteg", kind = "build", entity = "RITEG-1"},
  {id = "thorium-cycle", kind = "produce", item = {"bob-thorium-fuel-cell", "angels-thorium-fuel-cell"}, amount = 1e4},
  {id = "plutonium", kind = "produce", item = {"bob-plutonium-239", "angels-plutonium-239"}, amount = 1e6},
  {id = "heavy-water", kind = "produce", item = {"bob-deuterium-fuel-cell-2", "angels-deuterium-fuel-cell"},
    amount = 1e4},
  {id = "fe-c", kind = "produce", item = "fe-c-accumulator", amount = 1000},
  {id = "bio-boiler", kind = "build", entity = "bi-bio-boiler"},
  {id = "fire-engine", kind = "build", entity = "big-burner-generator"},
  {id = "oil-tycoon", kind = "energy", entity = "petroleum-generator"},
  {id = "charged", kind = "produce", item = "bet-fuel-4-full", amount = 1e5},
  {id = "electric-train", kind = "build", entity = "bet-locomotive"},
  {id = "high-voltage", kind = "build", entity = "bet-charger-3"},
  {id = "buried-cable", kind = "build", entity = "ued-small-db", amount = 1000}
)
