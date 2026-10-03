-- Final Beta 8 values, after the current pack's recipe/menu/stack patches.
-- New-game port: save migrations are intentionally outside this component.
local prototypes = require("prototypes.modules-beta8.data")
local integration = require("prototypes.modules-beta8.integration")

for _, prototype in ipairs(prototypes) do
    -- Module research consumes actual tools. Bob 2.0 defines these as items.
    if prototype.type == "tool" then
        data.raw.item[prototype.name] = nil
    end
end
data:extend(prototypes)

for _, entry in ipairs(integration.machine_categories) do
    local machine = assert(data.raw["assembling-machine"][entry.name])
    for _, category in ipairs(entry.categories) do
        local found = false
        for _, existing in ipairs(machine.crafting_categories) do
            if existing == category then found = true; break end
        end
        if not found then table.insert(machine.crafting_categories, category) end
    end
end

for _, entry in ipairs(integration.beacons) do
    local beacon = assert(data.raw.beacon[entry.name])
    beacon.icon = nil
    beacon.icons = nil
    for field, value in pairs(entry.fields) do beacon[field] = table.deepcopy(value) end
end

local module_technologies = {}
for _, name in ipairs(integration.module_technologies) do module_technologies[name] = true end
for _, entry in ipairs(integration.downstream) do
    local technology = assert(data.raw.technology[entry.name])
    local prerequisites = {}
    for _, name in ipairs(technology.prerequisites or {}) do
        if not module_technologies[name] then prerequisites[#prerequisites + 1] = name end
    end
    for _, name in ipairs(entry.prerequisites) do prerequisites[#prerequisites + 1] = name end
    technology.prerequisites = prerequisites
end

local restored = {}
for _, name in ipairs(integration.items) do restored[name] = true end
for name, module in pairs(data.raw.module) do
    if not restored[name] and not name:find("^creative%-mod_") then
        module.hidden = true
        local recipe = data.raw.recipe[name]
        if recipe then recipe.enabled = false; recipe.hidden = true end
    end
end

-- Replace only module inputs here; unrelated current material costs are untouched.
for _, entry in ipairs(integration.consumers) do
    local recipe = assert(data.raw.recipe[entry.name], "Missing module consumer: " .. entry.name)
    local ingredients = {}
    for _, ingredient in ipairs(recipe.ingredients or {}) do
        local name = ingredient.name or ingredient[1]
        if not data.raw.module[name] then ingredients[#ingredients + 1] = ingredient end
    end
    for _, ingredient in ipairs(entry.modules) do
        ingredients[#ingredients + 1] = table.deepcopy(ingredient)
    end
    recipe.ingredients = ingredients
end

-- 1.1 used a whitelist per module. 2.0 uses productivity and category gates
-- on the recipe. Keep the different God / ordinary / Raw restrictions.
local allowed = {}
for category, recipes in pairs(integration.limits) do
    for _, name in ipairs(recipes) do
        allowed[name] = allowed[name] or {}
        allowed[name][category] = true
    end
end
for name, recipe in pairs(data.raw.recipe) do
    local permitted = allowed[name] or {}
    local categories = {}
    for category in pairs(data.raw["module-category"]) do
        if integration.limits[category] == nil or permitted[category] then
            categories[#categories + 1] = category
        end
    end
    table.sort(categories)
    recipe.allowed_module_categories = categories
    recipe.allow_productivity = next(permitted) ~= nil
end
