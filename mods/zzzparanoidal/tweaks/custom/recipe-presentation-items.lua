-- Approved item-icon fixes: the crafting-menu recipe artwork is authoritative.
-- Runs after the generic sync passes so nothing overwrites it. Only the main drawing
-- (first layer) is copied; process marks (I/II, melt, mold, raw) stay on recipes.
local function find_item(name)
    for item_type in pairs(defines.prototypes.item) do
        local item = data.raw[item_type] and data.raw[item_type][name]
        if item then return item end
    end
end

local function set_icons(item, layers)
    item.icons = layers
    item.icon, item.icon_size, item.icon_mipmaps = nil, nil, nil
end

local function main_layer(recipe)
    if recipe.icons and recipe.icons[1] and recipe.icons[1].icon then
        return table.deepcopy(recipe.icons[1])
    elseif recipe.icon then
        return {icon = recipe.icon, icon_size = recipe.icon_size or 64}
    end
end

-- item -> recipe whose main drawing is the sample
local from_main = {
    ["angels-processed-chrome"] = "angels-processed-chrome",
    ["angels-ingot-chrome"] = "angels-ingot-chrome",
    ["angels-processed-tin"] = "angels-processed-tin",
    ["angels-ingot-tin"] = "angels-ingot-tin",
    ["angels-roll-tin"] = "angels-roll-tin",
    ["bob-tinned-copper-cable"] = "angels-wire-tin",
    ["angels-wire-coil-tin"] = "angels-wire-coil-tin",
    ["angels-ingot-gold"] = "angels-ingot-gold",
    ["bob-gold-plate"] = "angels-plate-gold",
    ["angels-wire-coil-gold"] = "angels-wire-coil-gold",
    ["angels-roll-bronze"] = "angels-roll-bronze-casting",
    ["angels-roll-brass"] = "angels-roll-brass-casting",
    ["angels-roll-gunmetal"] = "angels-roll-gunmetal-casting",
    ["angels-roll-nitinol"] = "angels-roll-nitinol-casting",
    ["angels-roll-invar"] = "angels-roll-invar-casting",
    ["angels-roll-cobalt-steel"] = "angels-roll-cobalt-steel-casting",
    -- white lumps (sodium chloride)
    ["angels-solid-salt"] = "angels-solid-salt-from-saline",
}
for item_name, recipe_name in pairs(from_main) do
    local item, recipe = find_item(item_name), data.raw.recipe[recipe_name]
    local layer = recipe and main_layer(recipe)
    if item and layer then set_icons(item, {layer}) end
end

-- Turrets: whole ordinary-recipe icon (turret colour and level dots belong to the model).
for _, name in ipairs({"artillery-turret", "bob-artillery-turret-2", "bob-artillery-turret-3",
    "bob-sniper-turret-1", "bob-sniper-turret-2", "bob-sniper-turret-3",
    "bob-plasma-turret-1", "bob-plasma-turret-2", "bob-plasma-turret-3", "bob-plasma-turret-4"}) do
    local item, recipe = find_item(name), data.raw.recipe[name]
    if item and recipe and recipe.icons then set_icons(item, table.deepcopy(recipe.icons)) end
end
