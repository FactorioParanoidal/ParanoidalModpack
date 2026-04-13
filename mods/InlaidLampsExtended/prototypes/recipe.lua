-- recipe/inlaid lamp

-- Flat Lamp Recipe
local lamp = util.table.deepcopy(data.raw["recipe"]["small-lamp"])
--~ lamp.name = "flat-lamp-c"
lamp.name = "flat-lamp"
--~ lamp.result = "flat-lamp"
lamp.result = nil
lamp.result_count = nil
lamp.results = { {type = "item", name = "flat-lamp", amount = 1} }
lamp.enabled = false
lamp.ingredients = {
  {type = "item", name = "small-lamp", amount = 1},
  {type = "item", name = "steel-plate", amount = 2},
  {type = "item", name = "concrete", amount = 2}
}
data:extend({lamp})

log("Recipe for small lamp: "..serpent.block(lamp))


-- 2x2 Flat Lamp Recipe
local factor = 4

--~ local lamp_big = util.table.deepcopy(data.raw["recipe"]["flat-lamp-c"])
local lamp_big = util.table.deepcopy(data.raw.recipe[lamp.name])
lamp_big.name = "flat-lamp-big"
lamp_big.results[1].name = lamp_big.name

--~ for i, ingredient in pairs(lamp_big.ingredients) do
  --~ ingredient[2] = ingredient[2] * factor
--~ end
lamp_big.ingredients = {
  {type = "item", name = lamp.name, amount = 1 * factor},
  {type = "item", name = "concrete", amount = 2},
  {type = "item", name = "steel-plate", amount = 2},
  {type = "item", name = "electronic-circuit", amount = 0.5 * factor},
  {type = "item", name = "copper-cable", amount = 1 * factor},
}
lamp_big.energy_required = (lamp_big.energy_required or 0.5) * factor

data:extend({lamp_big})



log("Recipe for big lamp: "..serpent.block(lamp_big))
