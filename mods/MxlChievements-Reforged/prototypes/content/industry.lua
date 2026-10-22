-- Machines, labs, modules, armor and science of Bob's mods and Miles' expansion.
local lib = require("prototypes.content.lib")

return lib.list(
  {id = "assembler-6", kind = "build", entity = "bob-assembling-machine-6"},
  {id = "assembler-9", kind = "build", entity = "assembling-machine-9"},
  {id = "deep-drilling", kind = "build", entity = "bob-mining-drill-4"},
  {id = "area-drilling", kind = "build", entity = "bob-area-mining-drill-4"},
  {id = "big-lab", kind = "build", entity = "big-lab"},
  {id = "hyper-lab", kind = "build", entity = "paranoidal-beta8-hyper-lab"},
  {id = "god-module", kind = "produce", item = "god-module-5", amounts = {1, 100, 1e4}},
  lib.each({"speed", "productivity", "efficiency"}, function(module)
    return {id = "module-8-" .. module, kind = "produce", item = "bob-" .. module .. "-module-8",
      amounts = {1, 100}, name_key = "module-8"}
  end),
  {id = "quality-squared", kind = "produce", item = "bob-quality-module-5", amount = 1},
  {id = "armoured-train", kind = "build", entity = "bob-armoured-locomotive-2"},
  {id = "sound-barrier", kind = "produce", item = "bob-ultimate-transport-belt", amount = 1e4},
  lib.each({"logistic", "construction"}, function(robot)
    return {id = "robot-mk5-" .. robot, kind = "produce", item = "bob-" .. robot .. "-robot-5",
      amount = 1000, name_key = "robot-mk5"}
  end),
  {id = "iron-man", kind = "equip", item = "bob-power-armor-mk5"},
  {id = "heavyweight", kind = "equip", item = "heavy-armor-3"},
  {id = "gold-science", kind = "science", item = "bob-science-pack-gold"},
  {id = "alien-science", kind = "science", item = "bob-alien-science-pack"},
  lib.each({"red", "orange", "yellow", "green", "blue", "purple"}, function(color)
    return {id = "alien-science-" .. color, kind = "science", item = "bob-alien-science-pack-" .. color,
      name_key = "six-colors"}
  end)
)
