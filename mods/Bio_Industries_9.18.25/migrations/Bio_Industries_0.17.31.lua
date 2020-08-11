local BioInd = require('__Bio_Industries__/common')('Bio_Industries')

--~ game.reload_script()

for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  if game.technology_prototypes["bi-tech-bio-farming"] and recipes["bi-wood-from-pulp"] then
    recipes["bi-wood-from-pulp"].enabled = true
    recipes["bi-wood-from-pulp"].reload()
  end

  force.reset_recipes()
  force.reset_technologies()
end
