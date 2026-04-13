--- Migration helper functions
--- @class StdLib.Misc.Migrate : StdLib.Core
local Migrate = {
    __class = 'Migrate',
    __index = require('__Kux-CoreLib__/stdlib/core')
}
setmetatable(Migrate, Migrate)

local Is = require('__Kux-CoreLib__/stdlib/utils/is')

--- Migrate a dictionary of recipe -> tech names
--- @param dictionary {[string]: string} dictionary of recipe -> tech names
function Migrate.Recipes(dictionary)
    Is.Assert.Table(dictionary, 'dictionary of recipes->technology not found')
    for _, force in pairs(game.forces) do
        for recipe, tech in pairs(dictionary) do
            if force.technologies[tech] and force.technologies[tech].researched then
                if force.recipes[recipe] then
                    force.recipes[recipe].enabled = true
                end
            end
        end
    end
end

function Migrate.all_recipes()
    for _, force in pairs(game.forces) do
        for _, tech in pairs(force.technologies) do
            if tech.researched then
                for _, unlock in pairs(tech.effects or {}) do
                    if unlock.type == 'unlock-recipe' then
                        force.recipes[unlock.recipe].enabled = true
                    end
                end
            end
        end
    end
end

return Migrate
