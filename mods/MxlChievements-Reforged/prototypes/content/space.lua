-- Rocket silo construction, space science and the SpaceX spaceship.
local lib = require("prototypes.content.lib")

return lib.list(
  {id = "excavation", kind = "build", item = "rsc-excavation-site"},
  {id = "stargazer", kind = "research", technology = "space-telescope-research-21"},
  {id = "shuttle", kind = "produce", item = "space-shuttle", amount = 1},
  lib.each({"command", "astrometrics", "ftl-drive", "habitation", "life-support", "protection-field",
    "hull-component"}, function(part)
    return {id = "ship-" .. part, kind = "produce", item = part, amount = 1, name_key = "spaceship"}
  end)
)
