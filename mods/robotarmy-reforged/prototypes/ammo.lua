-- Ammo categories of the droid weapons: their own damage / rate of fire research
-- (prototypes/technologies.lua); the vanilla bonuses do not apply to droids.
local shared = require("lib.shared")

local ICONS = shared.mod_path .. "/graphics/icons/"
local A = shared.ammo

local CATEGORIES = {
  {A.bullet, "droid_rifle_undep.png"},
  {A.rocket, "droid_rocket_undep.png"},
  {A.energy, "terminator_undep.png"},
  {A.flame, "droid_flame_undep.png"},
  {A.electric, "destroyer_unit_undep.png"},
}

local prototypes = {}
for i, c in pairs(CATEGORIES) do
  prototypes[i] = {
    type = "ammo-category",
    name = c[1],
    icon = ICONS .. c[2],
    icon_size = 64,
    bonus_gui_order = string.format("z[robotarmy]-%02d", i),
  }
end
data:extend(prototypes)
