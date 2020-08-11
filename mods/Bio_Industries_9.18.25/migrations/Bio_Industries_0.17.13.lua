local BioInd = require('__Bio_Industries__/common')('Bio_Industries')

--~ game.reload_script()


for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  if game.technology_prototypes["electric-energy-accumulators"] and
     technologies["electric-energy-accumulators"].researched then
    if game.item_prototypes["bi-bio-accumulator"] then
      recipes["bi-bio-accumulator"].enabled = true
      recipes["bi-bio-accumulator"].reload()
    end
  end

  force.reset_recipes()
  force.reset_technologies()
end
