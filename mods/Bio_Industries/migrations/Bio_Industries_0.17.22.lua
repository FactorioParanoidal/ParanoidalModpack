local BioInd = require('__Bio_Industries__/common')('Bio_Industries')

--~ game.reload_script()

for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  if game.technology_prototypes["bi-tech-coal-processing-1"] then
    if game.item_prototypes["wood-bricks"] then
      if recipes["bi-wood-fuel-brick"] then
        recipes["bi-wood-fuel-brick"].enabled = true
        recipes["bi-wood-fuel-brick"].reload()
      end
      if recipes["bi-solid-fuel"] then
        recipes["bi-solid-fuel"].enabled = true
        recipes["bi-solid-fuel"].reload()
      end
    end
  end

  if game.technology_prototypes["bi-tech-coal-processing-2"] and
     recipes["bi-pellet-coke"] then

    recipes["bi-pellet-coke"].enabled = true
    recipes["bi-pellet-coke"].reload()
  end

  if game.technology_prototypes["bi-tech-bio-farming"] and
    recipes["bi-woodpulp"] then

    recipes["bi-woodpulp"].enabled = true
    recipes["bi-woodpulp"].reload()
  end

  force.reset_recipes()
  force.reset_technologies()
end
