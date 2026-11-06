-- Loot of the droids and buildings, parts of the decrypted core: from the final items of the build.
require("prototypes.loot")
-- Rows of the droids and buildings in the "Enemies" tab of the entity lists (turret priority targets).
require("prototypes.list-rows")

-- No spoilers before contact: every citadel prototype (buildings, droids, tiles, core item and its
-- recipe) is hidden in the Factoriopedia, which shows it from the start of the game.
local P = require("lib.shared").prefix
for _, protos in pairs(data.raw) do
  for name, proto in pairs(protos) do
    if type(name) == "string" and name:sub(1, #P) == P then proto.hidden_in_factoriopedia = true end
  end
end
