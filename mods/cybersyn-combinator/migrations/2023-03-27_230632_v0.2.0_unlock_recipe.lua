local constants = require "scripts.constants"

for _, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  if technologies["cybersyn-train-network"] then
    recipes[constants.ENTITY_NAME].enabled = technologies["cybersyn-train-network"].researched
  else
    recipes[constants.ENTITY_NAME].enabled = technologies["circuit-network"].researched
  end
end
