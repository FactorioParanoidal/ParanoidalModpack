local effects = data.raw.technology['nanobots'].effects

local constructors = {
    type = 'recipe',
    name = 'ammo-nano-constructors',
    enabled = false,
    energy_required = 1,
    results = {
        {type = 'item', name = 'ammo-nano-constructors', amount = 1}
    }
}

local levelers = {
    type = 'recipe',
    name = 'ammo-nano-levelers',
    enabled = false,
    energy_required = 2,
    results = {
        {type = 'item', name = 'ammo-nano-levelers', amount = 2}
    }
}

local recipe_version = settings.startup["nanobots-recipe-version"].value
if recipe_version == "legacy" then
    constructors.ingredients = {
        {type = 'item', name = 'iron-stick', amount = 1},
        {type = 'item', name = 'repair-pack', amount = 1}
    }
    levelers.ingredients = {
        {type = 'item', name = 'iron-stick', amount = 1},
        {type = 'item', name = 'electronic-circuit', amount = 1}
    }
    if not mods['aai-industry'] then
        table.insert(effects, {type = 'unlock-recipe', recipe = 'iron-stick'})
        --AAI already unlocks the iron stick before this
    end
    
elseif recipe_version == "standard" then
    constructors.ingredients = {
        {type = 'item', name = 'electronic-circuit', amount = 1},
        {type = 'item', name = 'repair-pack', amount = 1},
        {type = 'item', name = 'firearm-magazine', amount = 1}
    }
    levelers.ingredients = {
        {type = 'item', name = 'electronic-circuit', amount = 1},
        {type = 'item', name = 'iron-gear-wheel', amount = 1},
        {type = 'item', name = 'firearm-magazine', amount = 1}
    }
    
    constructors.results[1].amount = 2
    levelers.results[1].amount = 3
    
elseif recipe_version == "basic" then
    constructors.ingredients = {
        {type = 'item', name = 'electronic-circuit', amount = 1},
        {type = 'item', name = 'repair-pack', amount = 1}
    }
    levelers.ingredients = {
        {type = 'item', name = 'electronic-circuit', amount = 1},
        {type = 'item', name = 'iron-gear-wheel', amount = 1}
    }
else
    --i would throw an error but idk how to do that
end

data:extend({constructors, levelers})
table.insert(effects, {type = 'unlock-recipe', recipe = 'ammo-nano-levelers'})
table.insert(effects, {type = 'unlock-recipe', recipe = 'ammo-nano-constructors'})
