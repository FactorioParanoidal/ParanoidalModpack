-- Challenges for a whole playthrough and decorative buildings.
-- objective: amounts are hours to launch a rocket; dont-build / dont-craft: until the first rocket.
local lib = require("prototypes.content.lib")

return lib.list(
  {id = "speedrun", kind = "objective", amounts = {300, 200, 100}, icon = {item = "rocket-part"}},
  {id = "pedestrian", kind = "dont-build", entities = {patterns = {"."}, types = {"car"}}, icon = {entity = "car"}},
  {id = "luddite", kind = "dont-build", entities = {patterns = {"."}, types = {"roboport"}}},
  {id = "all-in-sight", kind = "dont-build", entities = {patterns = {"^factory%-%d$", "^space%-factory%-%d$"}}},
  {id = "no-portals", kind = "dont-build", entities = "teleporter"},
  {id = "old-school", kind = "dont-build", entities = "cybersyn-combinator"},
  {id = "no-bottomless", kind = "dont-build", entities = {"memory-unit", "fluid-memory-unit"}},
  {id = "almost-lazy", kind = "dont-craft", amount = 10000, icon = {item = "iron-gear-wheel"}},
  {id = "electrolysis", kind = "build", entity = "angels-electrolyser", hours = 10},
  {id = "silo-sprint", kind = "build", item = "rsc-excavation-site", hours = 100},
  {id = "geologist", kind = "build", entity = "ore-radar"},
  {id = "holo", kind = "build", entity = "hs_holo_sign", amount = 50},
  {id = "let-there-be-light", kind = "build", entity = "deadlock-large-lamp", amount = 100},
  {id = "city-lights", kind = "build", entity = "flat-lamp", amount = 1000}
)
