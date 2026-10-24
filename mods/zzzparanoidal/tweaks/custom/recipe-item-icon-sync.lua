-- Crafting-menu icons are authoritative. Never choose between different recipe icons.
local M = {}

-- Recipes of these item groups never give their icon to an item (Yuoki exchange/transmutation
-- recipes would otherwise make ores, plates and fuels conflict or wear the exchange icon).
local foreign_icon_groups = {
    yuoki = true, ["yuoki-energy"] = true, ["yuoki-atomics"] = true, yuoki_liquids = true,
    j_yuoki_logistics = true, yi_engines = true, yie_harvest = true,
}

local function equal(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for k, v in pairs(a) do if not equal(v, b[k]) then return false end end
    for k in pairs(b) do if a[k] == nil then return false end end
    return true
end

local function icon_layers(prototype)
    if prototype.icons then
        local layers = table.deepcopy(prototype.icons)
        for _, layer in ipairs(layers) do layer.icon_size = layer.icon_size or 64 end
        return layers
    elseif prototype.icon then
        return {{icon = prototype.icon, icon_size = prototype.icon_size or 64}}
    end
end

function M.apply(raw, item_types, emit)
    local items, candidates, blocked = {}, {}, {}
    local report = {changed = {}, conflicts = {}, ambiguous = {}}
    for item_type in pairs(item_types) do
        for name, item in pairs(raw[item_type] or {}) do items[name] = item end
    end

    -- Collect before writing: recipe fallback must not depend on traversal order.
    local subgroups = raw["item-subgroup"] or {}
    local function foreign(subgroup_name)
        local subgroup = subgroup_name and subgroups[subgroup_name]
        return subgroup and foreign_icon_groups[subgroup.group] or false
    end
    -- A foreign-group recipe still speaks for items of its own groups.
    local function ignored(recipe, item_name)
        local item = items[item_name]
        return foreign(recipe.subgroup) and not (item and foreign(item.subgroup))
    end
    for name, recipe in pairs(raw.recipe or {}) do
        if not recipe.hidden then
            local results = recipe.results or {}
            local product = #results == 1 and results[1] or nil
            if product and (product.type or "item") == "item" and items[product.name]
                and not ignored(recipe, product.name) then
                local layers = icon_layers(recipe)
                if layers then
                    local list = candidates[product.name] or {}
                    candidates[product.name] = list
                    list[#list + 1] = {name = name, layers = layers}
                end
            elseif #results > 1 then
                report.ambiguous[#report.ambiguous + 1] = name
                for _, result in ipairs(results) do
                    if (result.type or "item") == "item" and not ignored(recipe, result.name) then
                        blocked[result.name] = true
                    end
                end
            end
        end
    end

    local names = {}
    for name in pairs(candidates) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
        local list = candidates[name]
        table.sort(list, function(a, b) return a.name < b.name end)
        local conflict = blocked[name] and "multiple-products" or nil
        for _, candidate in ipairs(list) do
            if not equal(candidate.layers, list[1].layers) then conflict = "different-icons" end
        end
        if conflict then
            local recipes = {}
            for _, candidate in ipairs(list) do recipes[#recipes + 1] = candidate.name end
            local entry = name .. " [" .. conflict .. "]: " .. table.concat(recipes, ", ")
            report.conflicts[#report.conflicts + 1] = entry
            emit("[recipe-item-icon-sync] skipped " .. entry)
        elseif not equal(icon_layers(items[name]), list[1].layers) then
            local item = items[name]
            item.icons = table.deepcopy(list[1].layers)
            item.icon = nil
            item.icon_size = nil
            item.icon_mipmaps = nil
            -- Alt-mode artwork is a separate, intentionally higher-contrast icon.
            report.changed[#report.changed + 1] = name
            emit("[recipe-item-icon-sync] changed " .. name .. " <- " .. list[1].name)
        end
    end
    table.sort(report.ambiguous)
    for _, name in ipairs(report.ambiguous) do
        emit("[recipe-item-icon-sync] multiple-products " .. name)
    end
    emit(string.format("[recipe-item-icon-sync] changed=%d conflicts=%d multiple-products=%d",
        #report.changed, #report.conflicts, #report.ambiguous))
    return report
end

return M
