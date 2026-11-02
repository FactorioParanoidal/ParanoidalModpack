-- Connection point for lightning attractors (rods) of other mods; scripts/rods.lua describes the fields.
-- Other mods add entries at the data or data-updates stage:
--   data.raw["mod-data"]["paranoidal-rain-attractors"].data.attractors["my-rod"] = { range = 12, mode = "absorb" }
-- data-final-fixes.lua checks them and copies them into mod-data "paranoidal-rain".attractors.
data:extend({
  {
    type = "mod-data",
    name = "paranoidal-rain-attractors",
    data = { version = 1, attractors = {} },
  },
})
