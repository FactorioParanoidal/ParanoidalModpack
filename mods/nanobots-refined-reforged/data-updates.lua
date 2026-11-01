-- Recipe and technology edits, the same results the stdlib2 Recipe/Technology helpers gave.
local function replace_ingredient(recipe_name, old, new)
    local recipe = data.raw.recipe[recipe_name]
    if not (recipe and data.raw.item[new]) then return end
    for i, ingredient in pairs(recipe.ingredients or {}) do
        if ingredient[1] == old or ingredient.name == old then
            recipe.ingredients[i] = {type = 'item', name = new, amount = ingredient[2] or ingredient.amount}
            return
        end
    end
end

local function add_ingredient(recipe_name, name)
    local recipe = data.raw.recipe[recipe_name]
    if not (recipe and data.raw.item[name]) then return end
    recipe.ingredients = recipe.ingredients or {}
    recipe.ingredients[#recipe.ingredients + 1] = {type = 'item', name = name, amount = 1}
end

require('prototypes/technology/shortcuts')

-- bobmods recipe changes
if mods['bobelectronics'] then

    local key = 'bobmods-logistics-disableroboports'
    if settings["startup"][key] and settings["startup"][key].value then
        replace_ingredient('roboport-interface', 'roboport', 'bob-logistic-zone-expander')
    end
    replace_ingredient('gun-nano-emitter', 'electronic-circuit', 'bob-basic-circuit-board')
    replace_ingredient('ammo-nano-constructors', 'electronic-circuit', 'bob-basic-circuit-board')
    replace_ingredient('ammo-nano-levelers', 'electronic-circuit', 'bob-basic-circuit-board')

    add_ingredient('equipment-bot-chip-items', 'bob-robot-brain')
    add_ingredient('equipment-bot-chip-trees', 'bob-robot-brain')
    add_ingredient('equipment-bot-chip-nanointerface', 'bob-robot-brain')
    add_ingredient('equipment-bot-chip-launcher', 'bob-robot-brain')
    add_ingredient('equipment-bot-chip-feeder', 'bob-robot-brain')
end

if mods['aai-industry'] then
    local tech = data.raw.technology['nanobots']
    if tech then
        local pre = tech.prerequisites or {}
        for i = #pre, 1, -1 do
            if pre[i] == 'logistics' then
                table.remove(pre, i)
                break
            end
        end
        if data.raw.technology['electronics'] then
            local found = false
            for _, name in pairs(pre) do
                if name == 'electronics' then found = true end
            end
            if not found then pre[#pre + 1] = 'electronics' end
        end
        tech.prerequisites = #pre > 0 and pre or nil
    end
    --removing logistics is debatable, but most people would have it by that point anyway, 
    --and it's a pretty arbitrary prereq in the first place
end

if not settings.startup["nanobots-auto"].value then
    --(... and settings.startup["nanobots-network-limits"].value)
    -- ^if I decide to put that setting back in
    data.raw.recipe["equipment-bot-chip-nanointerface"].hidden = true
end
