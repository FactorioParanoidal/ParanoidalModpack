-- Recipe-only source marks, after item sync, energy-port and final artwork replacements.
local M = {}
local sources = {
    ["bi-wood-fuel-brick"] = "bi-woodpulp",
    ["angels-wood-pellets"] = "angels-cellulose-fiber",
    ["angels-pellet-coke"] = "angels-solid-coke",
    ["bi-coke-coal"] = "coal",
    ["bi-pellet-coke"] = "solid-fuel",
    ["bi-pellet-coke-2"] = "angels-solid-carbon",
    ["landfill"] = "stone",
    ["angels-solid-mud-landfill"] = "angels-solid-mud",
    ["pmma-glass"] = "solid-pmma",
    ["pc-glass"] = "solid-pc",
    ["angels-solid-lithium"] = "angels-thermal-water",
    ["angels-algae-brown-burning"] = "angels-algae-brown",
    ["angels-filter-ceramic"] = "angels-filter-frame",
    ["angels-filter-ceramic-refurbish"] = "angels-filter-ceramic-used",
    ["y_granulate_wood"] = "wood",
    ["ye_granulate_vuger"] = "ye_corn_b",
    ["ye_granulate_corn"] = "ye_corn_a",
}

local function icon_layers(prototype)
    if not prototype then return end
    if prototype.icons then return table.deepcopy(prototype.icons) end
    if prototype.icon then
        return {{icon = prototype.icon, icon_size = prototype.icon_size or 64}}
    end
end

function M.apply(raw)
    local changed = 0
    for name, source_name in pairs(sources) do
        local recipe = raw.recipe[name]
        if recipe then
            local source
            for _, ingredient in ipairs(recipe.ingredients or {}) do
                if ingredient.name == source_name then
                    source = (raw[ingredient.type or "item"] or {})[source_name]
                    break
                end
            end
            local base = icon_layers(recipe)
            if not base then
                local result = recipe.results and recipe.results[1]
                base = result and icon_layers((raw[result.type or "item"] or {})[result.name])
            end
            local marks = icon_layers(source)
            if base and marks then
                for _, layer in ipairs(marks) do
                    layer.icon_size = layer.icon_size or source.icon_size or 64
                    -- Shrink the whole 32px source composition, retaining tint and relative offsets.
                    layer.scale = (layer.scale or 32 / layer.icon_size) * 14 / 32
                    local shift = layer.shift or {0, 0}
                    layer.shift = {9 + (shift.x or shift[1]) * 14 / 32,
                        -9 + (shift.y or shift[2]) * 14 / 32}
                    base[#base + 1] = layer
                end
                recipe.icons = base
                recipe.icon, recipe.icon_size, recipe.icon_mipmaps = nil, nil, nil
                changed = changed + 1
            end
        end
    end
    return changed
end

return M
