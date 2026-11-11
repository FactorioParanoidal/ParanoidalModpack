if not mods["planet-muluna"] then return end
local helper = require("lib.data-util")
local technology = data.raw.technology.afterburner
for i = #technology.unit.ingredients, 1, -1 do
  local ingredient = technology.unit.ingredients[i]
  if (ingredient.name or ingredient[1]) == "space-science-pack" then table.remove(technology.unit.ingredients, i) end
end
helper.remove_prerequisite("afterburner", "space-science-pack")
technology.unit.count = 500
