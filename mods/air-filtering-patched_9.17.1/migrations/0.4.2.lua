for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  recipes["unused-air-filter"].enabled = technologies["air-filtering"].researched
end