game.reload_script()


for index, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()

  if force.technologies["chemical-processing-2"].researched then
    force.technologies["chemical-steel-furnace"].researched = true --automatically unlock it
  end
end



