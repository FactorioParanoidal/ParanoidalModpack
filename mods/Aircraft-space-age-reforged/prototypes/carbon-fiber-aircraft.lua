local aircraft = require("shared.aircraft")
if not (mods["space-age"] and settings.startup["carbon-fiber-aircraft"].value) then return end

for _, spec in ipairs(aircraft.aircraft) do
  local name = aircraft.name(spec, true)
  local item = table.deepcopy(data.raw["item-with-entity-data"][spec.name])
  item.name, item.place_result, item.icon = name, name, aircraft.icon(spec, true)
  local recipe = table.deepcopy(data.raw.recipe[spec.name])
  recipe.name, recipe.results = name, {{type = "item", name = name, amount = 1}}
  recipe.icon, recipe.icons, recipe.icon_size = aircraft.icon(spec, true), nil, 64
  if spec.name == "jet" then
    for _, ingredient in ipairs(recipe.ingredients) do
      if ingredient.name == "low-density-structure" then ingredient.name = "carbon-fiber" end
    end
  else
    for _, ingredient in ipairs(recipe.ingredients) do
      if ingredient.name == "steel-plate" then
        if spec.name == "flying-fortress" then
          ingredient.amount = 1000
          recipe.ingredients[#recipe.ingredients + 1] = {type = "item", name = "carbon-fiber", amount = 1000}
        else
          ingredient.name = "carbon-fiber"
        end
        break
      end
    end
  end
  if spec.name == "flying-fortress" then
    for i = #recipe.ingredients, 1, -1 do
      local ingredient = recipe.ingredients[i]
      if ingredient.name == "advanced-circuit" then table.remove(recipe.ingredients, i)
      elseif ingredient.name == "processing-unit" then ingredient.amount = 120 end
    end
  end
  local technology = table.deepcopy(data.raw.technology[spec.technology])
  technology.name, technology.icon = spec.technology .. "-carbon-fiber", aircraft.path .. "graphics/technology/" .. spec.technology .. "-carbon.png"
  technology.unit.count = technology.unit.count * 2
  technology.prerequisites = {spec.technology, "carbon-fiber"}
  technology.effects = {{type = "unlock-recipe", recipe = name}}
  data:extend({item, recipe, technology})
end
