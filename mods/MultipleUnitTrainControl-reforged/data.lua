-- Technologies and the label icon. MU twins are made in data-final-fixes from the final locomotives.
local shared = require("shared")
local graphics = shared.path .. "/graphics/"

local function note(key)
  return {type = "nothing", effect_description = {"modifier-description." .. key},
          icon = graphics .. "mu-overlay.png", icon_size = 32}
end

data:extend({
  {
    type = "sprite",
    name = shared.sprite,
    filename = graphics .. "mu-overlay.png",
    size = 32,
    tint = {r = 1, g = 0.82, b = 0.25},
    flags = {"gui-icon"},
  },
  {
    type = "technology",
    name = shared.tech_basic,
    icon = graphics .. "mu-control.png",
    icon_size = 128,
    prerequisites = {"automated-rail-transportation"},
    effects = {note("mutc-basic")},
    unit = {
      count = 150,
      ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
      time = 30,
    },
    order = "c-g-c",
  },
  {
    type = "technology",
    name = shared.tech_wireless,
    icon = graphics .. "adv-mu-control.png",
    icon_size = 128,
    prerequisites = {shared.tech_basic, "chemical-science-pack"},
    effects = {note("mutc-wireless")},
    unit = {
      count = 250,
      ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}},
      time = 30,
    },
    order = "c-g-d",
  },
})
