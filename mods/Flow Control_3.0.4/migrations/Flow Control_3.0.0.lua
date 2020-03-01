-- Reload recipes and technologies
for i, player in ipairs(game.players) do
  player.force.reset_recipes()
  player.force.reset_technologies()
end

for index, force in pairs(game.forces) do
  -- Generate technology and recipe tables
  local tech = force.technologies
  local recipes = force.recipes

  -- Unlock researched recipes
  if tech["fluid-handling"] and tech["fluid-handling"].researched then
    if recipes["check-valve"] then
      recipes["check-valve"].enabled = true
    end
    if recipes["overflow-valve"] then
      recipes["overflow-valve"].enabled = true
    end
    if recipes["underflow-valve"] then
      recipes["underflow-valve"].enabled = true
    end
  end
end