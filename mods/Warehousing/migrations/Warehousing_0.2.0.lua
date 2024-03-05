--[[ Copyright (c) 2019 dgw
 * Part of the Warehousing mod
 *
 * See License.txt in the project directory for license information.
--]]
-- migrate from old single logistic research to the new pair of techs
-- relies on JSON migration to rename the old tech to level 2 first

for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  if technologies["warehouse-logistics-research-2"].researched then
    technologies["warehouse-logistics-research-1"].researched = true
  end
end
