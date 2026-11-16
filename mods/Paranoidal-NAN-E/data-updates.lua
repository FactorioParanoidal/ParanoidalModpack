local shared = require("shared")

-- Paranoidal's first circuit board is Bob's basic one (bobelectronics loads after this mod's data stage): her recipe
-- takes it instead of the electronic circuit where it exists.
local recipe = data.raw.recipe[shared.item]
if recipe and data.raw.item["bob-basic-circuit-board"] then
  for _, ingredient in pairs(recipe.ingredients) do
    if ingredient.name == "electronic-circuit" then
      ingredient.name = "bob-basic-circuit-board"
    end
  end
end
