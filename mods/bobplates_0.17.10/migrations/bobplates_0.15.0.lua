game.reload_script()

for index, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()

  force.recipes["void-oxygen"].enabled = true
  force.recipes["void-hydrogen"].enabled = true
  force.recipes["void-nitrogen"].enabled = true
  force.recipes["void-chlorine"].enabled = true
  force.recipes["void-sulfur-dioxide"].enabled = true
end


