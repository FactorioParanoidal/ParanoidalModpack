require("prototypes.buildings.duct-cross")
require("prototypes.buildings.duct-curve")
require("prototypes.buildings.duct-intake")
require("prototypes.buildings.duct-exhaust")
require("prototypes.buildings.duct-long")
require("prototypes.buildings.duct")
require("prototypes.buildings.duct-small")
require("prototypes.buildings.duct-t-junction")
require("prototypes.buildings.duct-underground")
require("prototypes.buildings.non-return-duct")

require("prototypes.item-subgroups")
require("prototypes.technologies")
require("prototypes.tips-and-tricks")

-- Duct joining
if settings.startup["fmf-enable-duct-auto-join"].value then
  data.raw["storage-tank"]["duct"].minable = { mining_time = 0.8, result = "duct-small", count = 2 }
  data.raw["storage-tank"]["duct"].placeable_by = { item = "duct-small", count = 2 }
  data.raw["storage-tank"]["duct-long"].minable = { mining_time = 0.8, result = "duct-small", count = 4 }
  data.raw["storage-tank"]["duct-long"].placeable_by = { item = "duct-small", count = 4 }
end

require("prototypes.compatibility.bobs-mods")
require("prototypes.compatibility.space-exploration")
require("prototypes.compatibility.squeak-through-2")
