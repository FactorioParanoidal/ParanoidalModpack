for i, force in pairs(game.forces) do 
  force.reset_recipes()
  force.reset_technologies()

  for _, force in pairs(game.forces) do
    if force.technologies["fluid-level-indicator"].researched then
      force.recipes["fluid-level-indicator"].enabled = true
      force.recipes["fluid-level-indicator-straight"].enabled = true
    end    
  end
end
if storage.flikocka ~= nil then
  storage.flikocka = nil
end