-- Pollution, Bio Industries, Angels bioprocessing, fish and trees.
local lib = require("prototypes.content.lib")

return lib.list(
  {id = "breathe", kind = "equip", item = "respirator"},
  {id = "agroholding", kind = "build", entity = "bi-bio-farm-3", amount = 10},
  {id = "filter-it", kind = "produce", item = "CW-air-filter", amount = 1e4},
  {id = "landfill", kind = "build", entity = "zcs-trash-landfill"},
  {id = "captain-planet", kind = "produce", item = "bob-pollution-clean-module-8", amount = 100},
  {id = "captain-smog", kind = "produce", item = "bob-pollution-create-module-8", amount = 100},
  {id = "fish-day", kind = "use-item", item = "raw-fish", amount = 1000},
  lib.each({1, 2, 3}, function(fish)
    return {id = "alien-fish-" .. fish, kind = "use-item", item = "angels-alien-fish-" .. fish .. "-raw",
      name_key = "alien-cuisine"}
  end),
  {id = "pet", kind = "produce", item = "angels-biter-big", amount = 1},
  {id = "puffer", kind = "produce", item = "angels-bio-puffer-5", amount = 1},
  {id = "egg", kind = "produce", item = "angels-bio-puffer-egg-5", amount = 1},
  {id = "meat-plant", kind = "produce", item = "angels-bio-alien-processed-meat", amount = 1e6},
  lib.each({"desert", "swamp", "temperate"}, function(tree)
    return {id = "tree-" .. tree, kind = "produce", item = "angels-" .. tree .. "-tree", amount = 1000,
      name_key = "gardener"}
  end),
  {id = "cellulose", kind = "produce", item = "angels-cellulose-fiber", amount = 1e6}
)
