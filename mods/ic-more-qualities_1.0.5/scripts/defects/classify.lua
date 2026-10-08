-- Data-stage classification of finished products. Pure function over data.raw:
-- used by data-final-fixes, stored in a mod-data prototype and read at runtime.
local M = {}

M.item_types = {
    "item", "ammo", "armor", "capsule", "gun", "item-with-entity-data", "item-with-inventory",
    "item-with-label", "item-with-tags", "module", "rail-planner", "repair-tool", "selection-tool",
    "blueprint", "blueprint-book", "copy-paste-tool", "deconstruction-item", "upgrade-item",
    "spidertron-remote", "tool", "space-platform-starter-pack",
}
M.modes = {materials = true, ["intermediate-ingredients"] = true, ["all-ingredients"] = true}
M.recycling = {recycling = true, ["recycling-or-hand-crafting"] = true}
local usable = {ammo = true, armor = true, gun = true, capsule = true, module = true, ["repair-tool"] = true}
local pipe_entities = {pipe = true, ["pipe-to-ground"] = true}

-- Accept long and old short forms while walking intermediate Lua tables.
local function entries(list)
    local out = {}
    for _, e in pairs(list or {}) do
        if type(e) == "table" then
            local name = e.name or e[1]
            if type(name) == "string" then out[#out + 1] = {type = e.type or "item", name = name} end
        end
    end
    return out
end

function M.products(recipe)
    local list = recipe.results
    if not list and recipe.result then list = {{type = "item", name = recipe.result}} end
    return entries(list)
end

function M.ingredients(recipe)
    return entries(recipe.ingredients)
end

local function add_minable(minable, out)
    if type(minable) ~= "table" then return end
    if type(minable.result) == "string" then out[minable.result] = true end
    for _, product in ipairs(entries(minable.results)) do
        if product.type == "item" then out[product.name] = true end
    end
end

-- Returns finished = {name = true}, reasons = {name = reason} for excluded items.
function M.classify(raw, mode)
    mode = mode or "materials"
    assert(M.modes[mode], "Unknown defect ingredient mode: " .. tostring(mode))
    local raw_items = {wood = true, coal = true, stone = true}
    for _, kind in ipairs({"resource", "tree", "fish"}) do
        for _, entity in pairs(raw[kind] or {}) do add_minable(entity.minable, raw_items) end
    end
    for _, entity in pairs(raw["simple-entity"] or {}) do
        if entity.count_as_rock_for_filtered_deconstruction then add_minable(entity.minable, raw_items) end
    end
    local science = {}
    for _, lab in pairs(raw.lab or {}) do
        for _, name in pairs(lab.inputs or {}) do science[name] = true end
    end
    local pipes = {}
    for kind in pairs(pipe_entities) do
        for name in pairs(raw[kind] or {}) do pipes[name] = true end
    end

    local finished, reasons = {}, {}
    for _, kind in ipairs(M.item_types) do
        for name, item in pairs(raw[kind] or {}) do
            if raw_items[name] then reasons[name] = "raw"
            elseif item.parameter then reasons[name] = "parameter"
            elseif science[name] then finished[name] = true
            -- User decision: pipes, bricks/concrete/landfill (tiles) and rails are materials.
            elseif item.place_as_tile then reasons[name] = "material-tile"
            elseif kind == "rail-planner" then reasons[name] = "material-rail"
            elseif item.place_result and pipes[item.place_result] then reasons[name] = "material-pipe"
            elseif usable[kind] or item.place_result or item.place_as_equipment_result then
                finished[name] = true
            end
        end
    end
    if mode == "materials" then return finished, reasons end

    -- A recipe of quality Q requires every ingredient at Q. A finished item that
    -- feeds a white (intermediate) product or a science pack must stay white,
    -- otherwise its defective copies block that recipe. Iterate to a fixpoint:
    -- excluding a product can make its own finished ingredients blocking too.
    local changed = true
    while changed do
        changed = false
        for _, recipe in pairs(raw.recipe or {}) do
            if not M.recycling[recipe.category or "crafting"] then
                local consumer = mode == "all-ingredients"
                if not consumer then
                    for _, product in ipairs(M.products(recipe)) do
                        if product.type == "item" and (not finished[product.name] or science[product.name]) then
                            consumer = true
                            break
                        end
                    end
                end
                if consumer then
                    for _, ingredient in ipairs(M.ingredients(recipe)) do
                        if ingredient.type == "item" and finished[ingredient.name] then
                            finished[ingredient.name] = nil
                            reasons[ingredient.name] = "ingredient"
                            changed = true
                        end
                    end
                end
            end
        end
    end
    return finished, reasons
end

-- True when a recipe may receive native positive quality: every item product finished.
function M.quality_allowed(recipe, finished)
    local any = false
    for _, product in ipairs(M.products(recipe)) do
        if product.type == "item" then
            any = true
            if not finished[product.name] then return false end
        end
    end
    return any
end

return M
