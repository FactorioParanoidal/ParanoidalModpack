for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  recipes["atomic-cannon-shell"].enabled = technologies["californium-processing"].researched
  --if mods["SchallTankPlatoon"] then
    --recipes["atomic-autocannon-shell"].enabled = technologies["californium-processing"].researched
    --recipes["atomic-cannon-H1-shell"].enabled = technologies["californium-processing"].researched
    --recipes["atomic-cannon-H2-shell"].enabled = technologies["californium-processing"].researched
    --if(settings.startup["enable-thermobaric"].value) then
      --recipes["thermobaric-autocannon-shell"].enabled = technologies["thermobaric-weaponry"].researched
      --recipes["thermobaric-cannon-H1-shell"].enabled = technologies["thermobaric-weaponry"].researched
      --recipes["thermobaric-cannon-H2-shell"].enabled = technologies["thermobaric-weaponry"].researched
    --end
  --end
  recipes["TN-small-atomic-artillery-shell"].enabled = technologies["atomic-artillery-shells"].researched
  recipes["TN-atomic-artillery-shell"].enabled = technologies["atomic-artillery-shells"].researched

  if(settings.startup["use-californium"].value) then
    recipes["californium-processing"].enabled = technologies["californium-processing"].researched
  end
  recipes["atomic-rounds-magazine"].enabled = technologies["californium-processing"].researched
  
  
  recipes["big-atomic-bomb"].enabled = technologies["scary-atomic-weapons"].researched
  recipes["big-atomic-rounds-magazine"].enabled = technologies["scary-atomic-weapons"].researched
  recipes["TN-big-atomic-artillery-shell"].enabled = technologies["scary-atomic-weapons"].researched
  --if mods["SchallTankPlatoon"] then
    --recipes["big-atomic-autocannon-shell"].enabled = technologies["scary-atomic-weapons"].researched
    --recipes["big-atomic-cannon-H1-shell"].enabled = technologies["scary-atomic-weapons"].researched
    --recipes["big-atomic-cannon-H2-shell"].enabled = technologies["scary-atomic-weapons"].researched
  --end
  recipes["TN-very-big-atomic-artillery-shell"].enabled = technologies["fusion-weapons"].researched
end
