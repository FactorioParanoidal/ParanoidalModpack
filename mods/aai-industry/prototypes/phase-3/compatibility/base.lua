--Fix for the bulk crafting tips and tricks no longer having belts and inserters unlocked with no technologies researched causing the simulation to crash
data.raw["tips-and-tricks-item"]["bulk-crafting"].simulation.init = table.concat({
    'local force = game.forces["player"]',
    'force.technologies["basic-logistics"].researched = true',
    'force.technologies["burner-mechanics"].researched = true',
    data.raw["tips-and-tricks-item"]["bulk-crafting"].simulation.init
  }, "\n")

-- Make the crash site spaceship have the "no-automated-item-removal" and "no-automated-item-insertion" flag
table.insert(data.raw.container["crash-site-spaceship"].flags, "no-automated-item-removal")
table.insert(data.raw.container["crash-site-spaceship"].flags, "no-automated-item-insertion")