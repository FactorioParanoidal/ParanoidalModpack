local BioInd = require('__Bio_Industries__/common')('Bio_Industries')

--~ game.reload_script()


for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  if game.technology_prototypes["steel-processing"] and
    technologies["steel-processing"].researched and
    recipes["bi-crushed-stone-1"] then

      recipes["bi-crushed-stone-1"].enabled = true
      recipes["bi-crushed-stone-1"].reload()
  end

  force.reset_recipes()
  force.reset_technologies()
end
