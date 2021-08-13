for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  if(settings.startup["enable-very-small-atomic-artillery"].value) then
    recipes["TN-very-small-atomic-artillery-shell"].enabled = technologies["atomic-artillery-shells"].researched
  end
  if(settings.startup["use-californium"].value) then
    recipes["californium-processing"].enabled = technologies["californium-processing"].researched
  end
  if(settings.startup["enable-really-very-small-atomic-bomb"].value) then
    recipes["enable-really-very-small-atomic-bomb"].enabled = technologies["californium-processing"].researched
  end
  if(settings.startup["enable-very-small-atomic-bomb"].value) then
    recipes["enable-very-small-atomic-bomb"].enabled = technologies["scary-atomic-weapons"].researched
  end
  if(settings.startup["enable-small-atomic-bomb"].value) then
    recipes["enable-small-atomic-bomb"].enabled = technologies["scary-atomic-weapons"].researched
  end
end
