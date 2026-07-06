for _, type in pairs(textplates.types) do
  local size = type.size
  local material = type.material
  local tech = data.raw.technology["textplates-"..type.material]
  local recipe = {
    type = "recipe",
    name = type.name,
    icon = "__textplates__/graphics/entity/" .. material .. "/blank.png",
    icon_size = 128,
    category = "crafting",
    enabled = tech == nil,
    energy_required = 0.25,
    ingredients = {{type = "item", name = type.ingredient, amount = 1}},
    results= {{type = "item", name = type.name, amount = 1}},
  }
  if size == "large"  then
    recipe.ingredients[1].amount = 4
    recipe.energy_required = 0.5
    recipe.icon = "__textplates__/graphics/entity/" .. material .. "/square.png"
  end
  if tech then
    table.insert(tech.effects, { type = "unlock-recipe", recipe = type.name})
  end
  data:extend({recipe})
end
