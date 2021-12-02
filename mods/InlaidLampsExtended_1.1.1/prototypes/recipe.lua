-- recipe/inlaid lamp

-- Flat Lamp Recipe
local lamp = util.table.deepcopy(data.raw["recipe"]["small-lamp"])
lamp.name = "flat-lamp-c"
lamp.result = "flat-lamp"
lamp.enabled = false
lamp.ingredients = {
  {"small-lamp", 1},
  {"steel-plate", 2},
  {"stone-brick", 4}
}
data:extend({lamp})

log("Recipe for small lamp: " .. serpent.block(lamp))


-- 2x2 Flat Lamp Recipe
local factor = 4

local lampbig = util.table.deepcopy(data.raw["recipe"]["flat-lamp-c"])
lampbig.name = "flat-lamp-big"
lampbig.result = "flat-lamp-big"

for i, ingredient in pairs(lampbig.ingredients) do
  ingredient[2] = ingredient[2] * factor
end

lampbig.energy_required = (lampbig.energy_required or 0.5) * factor

data:extend({lampbig})



log("Recipe for big lamp: " .. serpent.block(lampbig))

--~ error("Break!")
