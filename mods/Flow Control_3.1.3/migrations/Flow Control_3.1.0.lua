for index, force in pairs(game.forces) do
  -- Generate technology and recipe tables
  local tech = force.technologies
  local recipes = force.recipes

  -- Unlock researched recipes
  if tech["flow_control_valves_tech"] and not tech["flow_control_valves_tech"].researched then
    if recipes["check-valve"] and recipes["check-valve"].enabled then
      recipes["check-valve"].enabled = false
    end
    if recipes["overflow-valve"] and recipes["overflow-valve"].enabled then
      recipes["overflow-valve"].enabled = false
    end
    if recipes["underflow-valve"] and recipes["underflow-valve"].enabled then
      recipes["underflow-valve"].enabled = false
    end
  end
end
