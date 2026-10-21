-- Ammunition and weapon recipes; ingredients, amounts and times are Beta 8.
-- Beta 8 → 2.0 identities: liquid-fuel-oil → angels-liquid-fuel-oil, liquid-naphtha → angels-liquid-naphtha.
local recipe = require("prototypes.recipe-util")

local fuel_oil = data.raw.fluid["angels-liquid-fuel-oil"] and "angels-liquid-fuel-oil" or "light-oil"
local naphtha = data.raw.fluid["angels-liquid-naphtha"] and "angels-liquid-naphtha" or "heavy-oil"

data:extend({
  recipe({name = "explosive-autocannon-shell", time = 8, ingredients = {{"steel-plate", 2}, {"plastic-bar", 2}, {"explosives", 2}}}),
  recipe({name = "explosive-uranium-autocannon-shell", time = 12, ingredients = {{"explosive-autocannon-shell", 1}, {"uranium-238", 1}}}),
  recipe({name = "incendiary-autocannon-shell", category = "chemistry", time = 8,
    ingredients = {{"steel-plate", 2}, {fuel_oil, 100, "fluid"}, {naphtha, 100, "fluid"}}}),

  recipe({name = "cannon-H1-shell", time = 20, ingredients = {{"steel-plate", 4}, {"plastic-bar", 4}, {"explosives", 2}}}),
  recipe({name = "cannon-H2-shell", time = 80, ingredients = {{"steel-plate", 12}, {"plastic-bar", 12}, {"explosives", 6}}}),
  recipe({name = "explosive-cannon-H1-shell", time = 20, ingredients = {{"steel-plate", 4}, {"plastic-bar", 4}, {"explosives", 4}}}),
  recipe({name = "explosive-cannon-H2-shell", time = 80, ingredients = {{"steel-plate", 12}, {"plastic-bar", 12}, {"explosives", 12}}}),
  recipe({name = "uranium-cannon-H1-shell", time = 30, ingredients = {{"cannon-H1-shell", 1}, {"uranium-238", 2}}}),
  recipe({name = "uranium-cannon-H2-shell", time = 120, ingredients = {{"cannon-H2-shell", 1}, {"uranium-238", 6}}}),
  recipe({name = "explosive-uranium-cannon-H1-shell", time = 30, ingredients = {{"explosive-cannon-H1-shell", 1}, {"uranium-238", 2}}}),
  recipe({name = "explosive-uranium-cannon-H2-shell", time = 120, ingredients = {{"explosive-cannon-H2-shell", 1}, {"uranium-238", 6}}}),

  recipe({name = "Schall-incendiary-rocket", category = "chemistry", time = 40, count = 5,
    ingredients = {{"rocket", 5}, {"steel-plate", 2}, {fuel_oil, 100, "fluid"}, {naphtha, 100, "fluid"}}}),

  recipe({name = "Schall-sniper-rifle", time = 30, ingredients = {{"iron-gear-wheel", 10}, {"copper-plate", 5}, {"steel-plate", 10}}}),
  recipe({name = "Schall-sniper-firearm-magazine", time = 1, ingredients = {{"iron-plate", 4}}}),
  recipe({name = "Schall-sniper-piercing-rounds-magazine", time = 3,
    ingredients = {{"Schall-sniper-firearm-magazine", 1}, {"steel-plate", 1}, {"copper-plate", 5}}}),
  recipe({name = "Schall-sniper-uranium-rounds-magazine", time = 10,
    ingredients = {{"Schall-sniper-piercing-rounds-magazine", 1}, {"uranium-238", 1}}}),
})
