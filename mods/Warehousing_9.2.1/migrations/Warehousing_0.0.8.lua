--[[ Copyright (c) 2017 David-John Miller AKA Anoyomouse
 * Part of the Warehousing mod
 *
 * See License.txt in the project directory for license information.
--]]
-- Borrowed from FreeER
-- - https://forums.factorio.com/viewtopic.php?f=14&t=7161&start=10#p67540
-- reload recipes and technologies in game from prototypes (aka update existing ones with changes)
--
for i, player in ipairs(game.players) do
  player.force.reset_recipes()
  player.force.reset_technologies()
end

for index, force in pairs(game.forces) do
  -- generate technology / recipes tables once and store them
  local tech = force.technologies
  local recipes = force.recipes

  -- if this tech exists and is researched then
  if tech["warehouse-research"] and tech["warehouse-research"].researched then
    -- these checks are really only for if another mod changes things
    if recipes["storehouse-basic"] then
      recipes["storehouse-basic"].enabled = true
    end
  end

  if tech["warehouse-logistics-research"] and tech["warehouse-logistics-research"].researched then
    if recipes["storehouse-passive-provider"] then
      recipes["storehouse-passive-provider"].enabled = true
    end
    if recipes["storehouse-storage"] then
      recipes["storehouse-storage"].enabled = true
    end
    if recipes["storehouse-active-provider"] then
      recipes["storehouse-active-provider"].enabled = true
    end
    if recipes["storehouse-requester"] then
      recipes["storehouse-requester"].enabled = true
    end
  end
  
  if tech["warehouse-smart-research"] and tech["warehouse-smart-research"].researched then
    if recipes["storehouse-smart"] then
      recipes["storehouse-smart"].enabled = true
    end
  end
end

