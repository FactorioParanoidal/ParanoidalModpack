-- Отдельный третий тир Beta 8, удалённый в Angels 2.0.
-- Копируем уже адаптированный MK2; собственные скорость/слоты и цена нового здания — из 1.1.
local previous = "angels-electro-whinning-cell-2"
local name = "angels-electro-whinning-cell-3"
local source = data.raw["assembling-machine"][previous]
if not source or data.raw["assembling-machine"][name] then return end

local entity = table.deepcopy(source)
local item = table.deepcopy(data.raw.item[previous])
local recipe = table.deepcopy(data.raw.recipe[previous])
local technology = assert(data.raw.technology["angels-advanced-ore-refining-4"])
local colour = {r = 0.2, g = 0.7058823529411765, b = 1}

-- Синий цвет и метка III: только слои маски, без перекрашивания основания.
local function tier_three(value)
    if type(value) ~= "table" then return end
    local path = value.icon or value.filename
    if path and path:find("electrowinning%-cell.*%-mask") then
        value.tint = table.deepcopy(colour)
    elseif value.icon and value.icon:find("/tiers/") then
        value.icon = value.icon:gsub("/2%.png$", "/3.png")
        if value.tint then
            local alpha = value.tint.a
            value.tint = table.deepcopy(colour)
            value.tint.a = alpha
        end
    end
    for _, child in pairs(value) do tier_three(child) end
end

entity.name = name
entity.localised_name = {"entity-name." .. name}
entity.localised_description = {"entity-description." .. name}
entity.minable.result = name
entity.next_upgrade = nil
entity.crafting_speed = 1.5
entity.module_slots = 3
entity.energy_usage = "300kW"
entity.energy_source.emissions_per_minute = {pollution = 2.4}
entity.order = "03"
tier_three(entity)

item.name = name
item.localised_name = entity.localised_name
item.localised_description = entity.localised_description
item.place_result = name
item.order = "03"
item.icon, item.icon_size = nil, nil
item.icons = table.deepcopy(entity.icons)
tier_three(item.pictures)

recipe.name = name
recipe.localised_name = entity.localised_name
recipe.enabled = false
recipe.energy_required = 5
recipe.ingredients = {
    {type = "item", name = "tungsten-plate", amount = 16},
    {type = "item", name = "bob-advanced-processing-unit", amount = 8},
    {type = "item", name = "refined-concrete", amount = 20},
    {type = "item", name = "bob-tungsten-pipe", amount = 18},
    {type = "item", name = previous, amount = 2},
}
recipe.results = {{type = "item", name = name, amount = 1}}
recipe.order = "03"
recipe.icon, recipe.icon_size = nil, nil
recipe.icons = table.deepcopy(entity.icons)

data:extend({entity, item, recipe})
source.next_upgrade = name
technology.effects = technology.effects or {}
table.insert(technology.effects, {type = "unlock-recipe", recipe = name})
