local technology_unlocks = {
  ["gardens-2"] = "seed-extractor-2",
  ["gardens-3"] = "seed-extractor-3",
}

for _, force in pairs(game.forces) do
  for technology_name, recipe_name in pairs(technology_unlocks) do
    local technology = force.technologies[technology_name]
    local recipe = force.recipes[recipe_name]

    if technology and recipe and technology.researched then
      recipe.enabled = true
    end
  end
end
