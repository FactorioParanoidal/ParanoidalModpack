for index, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()
  force.reset_technology_effects()
  local changed_tech = {
    "angels-platinum-smelting-1",
    "angels-platinum-smelting-2",
    "angels-platinum-smelting-3",
    "angels-platinum-casting-1",
    "angels-platinum-casting-2",
  }
  
  for index, force in pairs(game.forces) do
    force.reset_recipes()
    force.reset_technologies()
    force.reset_technology_effects()
  
    for _, tech_name in pairs(changed_tech) do
      local tech = force.technologies[tech_name]
      if tech and tech.enabled ~= tech.prototype.enabled then
        tech.enabled = tech.prototype.enabled
      end
    end
  end
end