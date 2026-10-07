-- Crafting layout is authoritative; item/fluid selectors and Factoriopedia use products.
local M = {}
local protected_groups = {
    ["angels-bio-processing-nauvis"] = true,
    ["angels-bio-processing-vegetables"] = true,
    ["angels-bio-processing-alien"] = true,
    ["bio-industries"] = true,
}
-- These tabs were merged for recipes; uncrafted products must follow the same merge.
local merged_groups = {satellites = "space-exploration", ["angels-power"] = "intermediate-products",
    ["angels-vehicles"] = "transport"}
local fallback_rows = {
    ["satellite-data"] = "paranoidal-organized-space-exploration-research",
    ["space-mining"] = "paranoidal-organized-space-exploration-unboxing",
    buildings = "paranoidal-organized-space-exploration-ground",
    ["angels-power-nuclear-fuel-cell"] = "paranoidal-components-fuel-cells",
    ["angels-power-nuclear-processing"] = "paranoidal-organized-intermediate-products-nuclear-processing",
}
local fallback_recipes = {
    ["probe-data"] = "probe-data-processing",
    ["landed-shuttle"] = "refurbish-space-shuttle",
    ["landed-mining-shuttle"] = "refurbish-mining-shuttle",
    ["landed-spy-shuttle"] = "refurbish-spy-shuttle",
    ["landed-fabricator-shuttle"] = "refurbish-fabricator-shuttle",
}
-- Alternative metallurgy recipes also occur in the generic tungsten row.
local preferred_recipes = {
    ["item/tungsten-carbide"] = "angels-plate-tungsten-carbide",
    ["item/bob-copper-tungsten-alloy"] = "angels-molten-copper-tungsten-smelting-1",
}

function M.apply(raw, types, emit)
    local products, candidates, plan = {}, {}, {}
    local report = {changed = {}, anchored = {}, pinned = {}, linked = {}, conflicts = {}}
    local function key(kind, name) return kind .. "/" .. name end
    local function group(subgroup)
        return raw["item-subgroup"][subgroup or ""]
    end
    local function group_name(subgroup)
        local row = group(subgroup)
        return row and row.group
    end
    local function add_products(kind, prototype_type)
        for name, prototype in pairs(raw[prototype_type] or {}) do
            products[key(kind, name)] = {prototype = prototype, type = prototype_type, kind = kind}
        end
    end
    for kind in pairs(types.item) do add_products("item", kind) end
    add_products("fluid", "fluid")

    local function main_product(recipe)
        if recipe.main_product == "" then return end
        local results = recipe.results or {}
        for _, result in ipairs(results) do
            if result.name == recipe.main_product or (not recipe.main_product and #results == 1) then
                return products[key(result.type or "item", result.name)]
            end
        end
    end
    local function placement(recipe)
        local product = main_product(recipe)
        local prototype = product and product.prototype
        return recipe.subgroup or (prototype and prototype.subgroup),
            recipe.order or (prototype and prototype.order) or ""
    end
    local function positive_output(recipe, result)
        if result.probability == 0 then return false end
        local amount = result.amount or result.amount_max or 0
        for _, ingredient in ipairs(recipe.ingredients or {}) do
            if ingredient.name == result.name and (ingredient.type or "item") == (result.type or "item") then
                amount = amount - (ingredient.amount or 0)
            end
        end
        return amount > 0
    end

    for name, recipe in pairs(raw.recipe) do
        local subgroup, order = placement(recipe)
        local recipe_group = group_name(subgroup)
        if not recipe.hidden and recipe_group and not protected_groups[recipe_group] then
            local results = recipe.results or {}
            for _, result in ipairs(results) do
                local id = key(result.type or "item", result.name)
                local product = products[id]
                local prototype = product and product.prototype
                local original_group = prototype and group_name(prototype.subgroup)
                local target_group = merged_groups[original_group] or original_group
                if prototype and not prototype.hidden and not protected_groups[original_group] then
                    local rank
                    if name == result.name then rank = 1
                    elseif recipe.main_product == result.name then rank = 2
                    elseif #results == 1 then rank = 3
                    elseif not recipe.main_product and target_group == recipe_group
                        and positive_output(recipe, result) then rank = 4 end
                    -- Delivery/unboxing is not the home of raw materials or science packs.
                    if recipe_group == "space-exploration" and target_group ~= recipe_group
                        and name ~= result.name then rank = nil end
                    if rank then
                        if preferred_recipes[id] == name then rank = 0 end
                        local list = candidates[id] or {}
                        candidates[id] = list
                        list[#list + 1] = {recipe = name, subgroup = subgroup, order = order,
                            rank = rank, same_group = target_group == recipe_group}
                    end
                end
            end
        end
    end

    for id, product in pairs(products) do
        local prototype = product.prototype
        local original_group = group_name(prototype.subgroup)
        if not candidates[id] and not prototype.hidden and merged_groups[original_group] then
            local recipe = raw.recipe[fallback_recipes[prototype.name] or ""]
            local subgroup, order
            if recipe and not recipe.hidden then subgroup, order = placement(recipe) end
            subgroup = subgroup or fallback_rows[prototype.subgroup]
            if group_name(subgroup) == merged_groups[original_group] then
                candidates[id] = {{subgroup = subgroup, order = order or ("z-" .. (prototype.order or ""):sub(1, 198)),
                    recipe = recipe and recipe.name or nil, rank = 5, same_group = true}}
            end
        end
    end

    local function before(a, b)
        if a.rank ~= b.rank then return a.rank < b.rank end
        if a.same_group ~= b.same_group then return a.same_group end
        local ag, bg = raw["item-group"][group_name(a.subgroup)], raw["item-group"][group_name(b.subgroup)]
        if (ag.order or "") ~= (bg.order or "") then return (ag.order or "") < (bg.order or "") end
        if ag.name ~= bg.name then return ag.name < bg.name end
        local ar, br = group(a.subgroup), group(b.subgroup)
        if (ar.order or "") ~= (br.order or "") then return (ar.order or "") < (br.order or "") end
        if a.subgroup ~= b.subgroup then return a.subgroup < b.subgroup end
        if a.order ~= b.order then return a.order < b.order end
        return a.recipe < b.recipe
    end
    local ids = {}
    for id in pairs(candidates) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local list = candidates[id]
        table.sort(list, before)
        local chosen = list[1]
        -- An inherited-only recipe does not prescribe a new layout.
        local prototype = products[id].prototype
        report.anchored[id] = chosen
        if prototype.subgroup ~= chosen.subgroup or (prototype.order or "") ~= chosen.order then
            plan[id] = chosen
        end
    end

    -- Freeze inherited presentation before moving products: no recipe may move as a side effect.
    for name, recipe in pairs(raw.recipe) do
        local product = main_product(recipe)
        if product and plan[key(product.kind, product.prototype.name)] then
            local subgroup, order = placement(recipe)
            local fields = {}
            if not recipe.subgroup and subgroup then recipe.subgroup = subgroup; fields[#fields + 1] = "subgroup" end
            if not recipe.order then recipe.order = order; fields[#fields + 1] = "order" end
            if #fields > 0 then report.pinned[name] = fields end
        end
    end
    for _, id in ipairs(ids) do
        local chosen = plan[id]
        if chosen then
            local prototype = products[id].prototype
            prototype.subgroup, prototype.order = chosen.subgroup, chosen.order
            report.changed[id] = chosen
        end
    end

    -- Linked entity/equipment pages can have explicit legacy placement of their own.
    local entities, equipment, links = {}, {}, {}
    for kind in pairs(types.entity or {}) do
        for name, prototype in pairs(raw[kind] or {}) do entities[name] = {type = kind, prototype = prototype} end
    end
    for kind in pairs(types.equipment or {}) do
        for name, prototype in pairs(raw[kind] or {}) do equipment[name] = {type = kind, prototype = prototype} end
    end
    for id in pairs(report.anchored) do
        local product = products[id]
        if product.kind == "item" then
            local item = product.prototype
            for _, linked in pairs({entity = entities[item.place_result or ""],
                equipment = equipment[item.place_as_equipment_result or ""]}) do
                local prototype = linked.prototype
                if not prototype.hidden and not prototype.hidden_in_factoriopedia
                    and not protected_groups[group_name(prototype.subgroup)] then
                    local link_id = key(linked.type, prototype.name)
                    local list = links[link_id] or {}
                    links[link_id] = list
                    list[#list + 1] = {item = item, linked = linked}
                end
            end
        end
    end
    for id, list in pairs(links) do
        table.sort(list, function(a, b) return a.item.name < b.item.name end)
        local chosen, conflict = list[1], false
        for _, link in ipairs(list) do
            if link.item.subgroup ~= chosen.item.subgroup or link.item.order ~= chosen.item.order then conflict = true end
        end
        if conflict then
            report.conflicts[#report.conflicts + 1] = id
            emit("[recipe-product-menu-sync] ambiguous placement items: " .. id)
        else
            local prototype, item = chosen.linked.prototype, chosen.item
            if prototype.subgroup ~= item.subgroup or prototype.order ~= item.order then
                prototype.subgroup, prototype.order = item.subgroup, item.order
                report.linked[id] = item.name
            end
        end
    end
    local function count(t) local n = 0; for _ in pairs(t) do n = n + 1 end; return n end
    emit(string.format("[recipe-product-menu-sync] products=%d pinned-recipes=%d linked=%d conflicts=%d",
        count(report.changed), count(report.pinned), count(report.linked), #report.conflicts))
    return report
end

return M
