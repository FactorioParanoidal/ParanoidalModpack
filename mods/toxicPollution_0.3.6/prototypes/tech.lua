local function getIngredients(num)
    local res = {}
    local c = math.floor(num / 5)
    table.insert(res, {"automation-science-pack", 1})
    if (c > 0) then
        table.insert(res, {"logistic-science-pack", 1})
    end
    if (c > 1) then
        table.insert(res, {"military-science-pack", 1})
    end
    if (c > 2) then
        table.insert(res, {"chemical-science-pack", 1})
    end
    if (c > 3) then
        table.insert(res, {"utility-science-pack", 1})
    end
    return res
end

require('util.tech')

data:extend({
    {
        type = "technology",
        name = TechName .. "-1",
        icon = "__toxicPollution__/graphics/respirator.png",
        icon_size = 128,
        effects = {
            {type = "nothing", effect_description={"Inc-absorb-armor"}}
        },
        unit = {
            count = 10,
            ingredients = getIngredients(1),
            time = 5
        },
        upgrade = true,
        order = "c-k-f-e"
    }
})

for i = 2, TechLevels do
    data:extend({
        {
            type = "technology",
            name = TechName .. "-" .. i,
            icon = "__toxicPollution__/graphics/respirator.png",
            icon_size = 128,
            effects = {
                {type = "nothing", effect_description={"Inc-absorb-armor"}}
            },
            prerequisites = {"armor-absorb-"..(i - 1)},
            unit = {
                count = i*10,
                ingredients = getIngredients(i),
                time = i*5
            },
            upgrade = true,
            order = "c-k-f-e"
        }
    })
end