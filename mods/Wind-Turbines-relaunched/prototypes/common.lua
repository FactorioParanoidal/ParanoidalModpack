---
--- Created by xyzzycgn.
--- DateTime: 02.10.25 14:16
---
local handle_settings = require("scripts/handle_settings")


local function recipeCosts(set)
    local ingredients = {}
    for k, v in pairs(set) do
        local name, amount = table.unpack(v)
        ingredients[#ingredients + 1] = { type = "item", name = name, amount = amount }
    end

    return ingredients
end

local function make_recipe(base, cheap, expensive)
    local set = handle_settings.constructionMoreExpensive() and expensive or cheap

    base.energy = set.energy
    base.ingredients = recipeCosts(set.ingredients)

    return base
end


local common = {
    make_recipe = make_recipe
}

return common