local function append_icon(icons, prototype, x, y)
    local layers = prototype.icons or {{icon = prototype.icon, icon_size = prototype.icon_size or 64}}
    for _, original in ipairs(layers) do
        local layer = table.deepcopy(original)
        local size = layer.icon_size or prototype.icon_size or 64
        local shift = layer.shift or {0, 0}
        layer.icon_size = size
        layer.scale = (layer.scale or 32 / size) * 0.625
        layer.shift = {
            (shift[1] or shift.x or 0) * 0.625 + x,
            (shift[2] or shift.y or 0) * 0.625 + y,
        }
        icons[#icons + 1] = layer
    end
end

local function lamp_count(recipe)
    local count = 0
    for _, ingredient in ipairs(recipe and recipe.ingredients or {}) do
        if ingredient.name == "small-lamp" then count = count + (ingredient.amount or 0) end
    end
    return count
end

-- Upgrade recipe "source pole + iron sticks + steel -> target pole", sorted and unlocked with the target's own recipe.
local function add_upgrade(name, source_name, target_name, order, extra_ingredients)
    local source = data.raw.item[source_name]
    local target = data.raw.item[target_name]
    local ordinary = data.raw.recipe[target_name]
    if not source or not target or not ordinary then return end

    local icons = {}
    append_icon(icons, source, -6, 6)
    append_icon(icons, target, 6, -6)
    icons[#icons + 1] = {
        icon = "__base__/graphics/icons/arrows/up-right-arrow.png",
        icon_size = 64,
        scale = 0.25,
    }

    local ingredients = {
        {type = "item", name = source_name, amount = 1},
        {type = "item", name = "iron-stick", amount = 2},
        {type = "item", name = "steel-plate", amount = 2},
    }
    for _, ingredient in ipairs(extra_ingredients or {}) do
        ingredients[#ingredients + 1] = ingredient
    end

    data:extend({{
        type = "recipe",
        name = name,
        localised_name = {"recipe-name." .. name},
        categories = {"crafting"},
        enabled = ordinary.enabled == true,
        energy_required = ordinary.energy_required or 0.5,
        allow_productivity = false,
        subgroup = source.subgroup,
        order = order,
        icons = icons,
        ingredients = ingredients,
        results = {{type = "item", name = target_name, amount = 1}},
    }})

    -- Follow the target recipe's final unlock after all technology overrides.
    for _, technology in pairs(data.raw.technology) do
        for _, effect in ipairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == ordinary.name then
                technology.effects[#technology.effects + 1] = {type = "unlock-recipe", recipe = name}
                break
            end
        end
    end
end

add_upgrade("small-iron-electric-pole-to-medium-electric-pole",
    "small-iron-electric-pole", "medium-electric-pole", "03")

-- Lighted variant (paranoidal-lighting): the medium pole may carry more lamps than the iron one.
local extra_lamps = lamp_count(data.raw.recipe["lighted-medium-electric-pole"])
    - lamp_count(data.raw.recipe["lighted-small-iron-electric-pole"])
add_upgrade("lighted-small-iron-electric-pole-to-lighted-medium-electric-pole",
    "lighted-small-iron-electric-pole", "lighted-medium-electric-pole", "04",
    extra_lamps > 0 and {{type = "item", name = "small-lamp", amount = extra_lamps}} or nil)
