local BioInd = require('__Bio_Industries__/common')('Bio_Industries')

--~ game.reload_script()


for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes



  if game.technology_prototypes["bi-tech-bio-cannon"] and
     technologies["bi-tech-bio-cannon"].researched and
     recipes["bi-bio-cannon-proto-ammo"] then

    recipes["bi-bio-cannon-proto-ammo"].enabled = true
    recipes["bi-bio-cannon-proto-ammo"].reload()
  end

  force.reset_recipes()
  force.reset_technologies()
end
