-- Quality and the Paranoidal defect system (ic-more-qualities), recyclers.
local lib = require("prototypes.content.lib")

-- Top tier of every ic-more-qualities family and the three final qualities.
local LADDER = {"uncommon-t5", "rare-t5", "epic-t5", "legendary-t5", "unique-t5", "astral-t5", "quantum-t5",
  "infernal-t2", "unbreakable", "godly", "extreme"}

return lib.list(
  {id = "butterfingers", kind = "produce", item = "iron-gear-wheel", quality = "ic-defect-5", amount = 1000},
  {id = "defect-plan", kind = "produce", item = "electronic-circuit", quality = "ic-defect-1", amount = 1e6},
  {id = "quality-control", kind = "build", entity = "ic-control-post"},
  {id = "repair-shop", kind = "build", entity = "ic-refine-workshop"},
  {id = "six-sigma", kind = "research", technology = "ic-defect-control-10"},
  lib.each(LADDER, function(quality)
    return {id = "ladder-" .. quality, kind = "produce", item = "iron-gear-wheel", quality = quality,
      amount = 1, name_key = "quality-ladder", name_from_quality = true}
  end),
  {id = "haute-couture", kind = "equip", item = "power-armor-mk2", quality = "godly"},
  {id = "fancy-fish", kind = "use-item", item = "raw-fish", quality = "extreme"},
  {id = "recycler-1", kind = "build", entity = "recycler-1"},
  {id = "recycler-2", kind = "build", entity = "recycler-2"},
  {id = "recycler-3", kind = "build", entity = "recycler-3"},
  {id = "recycler-4", kind = "build", entity = "recycler"}
)
