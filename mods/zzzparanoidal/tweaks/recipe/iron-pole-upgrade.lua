local source = data.raw.item["small-iron-electric-pole"]
local target = data.raw.item["medium-electric-pole"]
local ordinary = data.raw.recipe["medium-electric-pole"]
if not source or not target or not ordinary then return end

local name = "small-iron-electric-pole-to-medium-electric-pole"
local icons = {}
local function append_icon(prototype, x, y)
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
append_icon(source, -6, 6)
append_icon(target, 6, -6)
icons[#icons + 1] = {
    icon = "__base__/graphics/icons/arrows/up-right-arrow.png",
    icon_size = 64,
    scale = 0.25,
}

data:extend({{
    type = "recipe",
    name = name,
    localised_name = {"recipe-name." .. name},
    category = "crafting",
    enabled = ordinary.enabled == true,
    energy_required = ordinary.energy_required or 0.5,
    allow_productivity = false,
    subgroup = source.subgroup,
    order = "03",
    icons = icons,
    ingredients = {
        {type = "item", name = "small-iron-electric-pole", amount = 1},
        {type = "item", name = "iron-stick", amount = 2},
        {type = "item", name = "steel-plate", amount = 2},
    },
    results = {{type = "item", name = "medium-electric-pole", amount = 1}},
}})

-- Follow the ordinary recipe's final unlock after all technology overrides.
for _, technology in pairs(data.raw.technology) do
    for _, effect in ipairs(technology.effects or {}) do
        if effect.type == "unlock-recipe" and effect.recipe == ordinary.name then
            technology.effects[#technology.effects + 1] = {type = "unlock-recipe", recipe = name}
            break
        end
    end
end
