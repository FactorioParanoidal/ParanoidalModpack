local BioInd = require('__Bio_Industries__/common')('Bio_Industries')
------------------------------------------------------------------------------------
-- For some reason, the recipe for bi-biomass-2 was more advanced than the recipe
-- for bi-biomass-3. This worked because we changed their order whereever they've
-- been used, but it wasn't intuitive and caused confusion.
-- The recipes have been renamed in 0.17.58/0.18.27, now we need to make sure that
-- the recipes in bio-reactors making bio-mass are exchanged as well!
------------------------------------------------------------------------------------

BioInd.writeDebug("Entered migration script 0.18.27+0.17.58")


-- Look for bio-reactors on all surfaces
local reactors, recipe

for s, surface in pairs(game.surfaces) do
  reactors = surface.find_entities_filtered{
    type = "assembling-machine",
    name = "bi-bio-reactor"
  }
  BioInd.writeDebug("Found %g bio-reactors on surface \"%s\".",
                                    {#reactors, surface.name})

  -- Get recipe of reactors
  for r, reactor in ipairs(reactors) do
    recipe = reactor.get_recipe()
    recipe = recipe and recipe.name or ""
    BioInd.writeDebug("Reactor %g has recipe \"%s\".",
                                      {reactor.unit_number, recipe})

    -- Exchange "bi-biomass-2" against "bi-biomass-3"
    if recipe == "bi-biomass-2" then
      reactor.set_recipe("bi-biomass-3")
      BioInd.writeDebug("Set recipe to %s.", {reactor.get_recipe().name})

    -- Exchange "bi-biomass-3" against "bi-biomass-2"
    elseif recipe == "bi-biomass-3" then
      reactor.set_recipe("bi-biomass-2")
      BioInd.writeDebug("Set recipe to %s.", {reactor.get_recipe().name})
    end
  end

end

BioInd.writeDebug("End of migration script 0.18.27+0.17.58")
