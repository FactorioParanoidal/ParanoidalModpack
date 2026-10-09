-- One lighting badge for menu, inventory and entity icons, after all menu overrides.
if not mods["Lighted-Poles-Plus"] then return end

local badge_icon = "__zzzparanoidal__/graphics/logistics-menu-beta8/1790a2d6cd5fc871fd86.png"
local old_badges = {
    [badge_icon] = true,
    ["__Lighted-Poles-Plus__/graphics/icons/lighted.png"] = true,
    ["__Lighted-Poles-Plus__/graphics/icons/lighted_2.png"] = true,
}

-- Keep the approved Beta 8 artwork of the lighted wooden pole.
local menu_overrides = {
    ["small-electric-pole"] = {
        icon = "__zzzparanoidal__/graphics/logistics-menu-beta8/8bd1054b2e21600efe89.png",
        icon_size = 64,
    },
}

local function lighted_icons(prototype)
    local layers = {}
    if prototype.icons then
        for _, layer in ipairs(prototype.icons) do
            if not old_badges[layer.icon] then
                layers[#layers + 1] = table.deepcopy(layer)
            end
        end
    elseif prototype.icon then
        layers[1] = {icon = prototype.icon, icon_size = prototype.icon_size or 64}
    end
    if not layers[1] then return end

    local base = layers[1]
    local size = base.icon_size or prototype.icon_size or 64
    local scale = size * (base.scale or 32 / size) / 32
    -- The 32px Beta 8 badge has its glow in the bottom-left 9px square.
    -- Shrink it to 8px, keeping its center in the top right.
    local badge_scale = scale * 8 / 9
    local badge_shift = 11.5 * (scale + badge_scale)
    -- Floating keeps the badge's transparent canvas out of GUI bounds.
    layers[#layers + 1] = {
        icon = badge_icon,
        icon_size = 32,
        scale = badge_scale,
        shift = {badge_shift, -badge_shift},
        tint = {r = 1, g = 1, b = 1, a = 0.85},
        floating = true,
    }
    return layers
end

local function set_icons(prototype, layers)
    if not prototype or not layers then return end
    prototype.icons = table.deepcopy(layers)
    prototype.icon = nil
    prototype.icon_size = nil
    prototype.icon_mipmaps = nil
end

for name, item in pairs(data.raw.item) do
    local base_name = name:match("^lighted%-(.+)$")
    local base_item = base_name and data.raw.item[base_name]
    local pole = data.raw["electric-pole"][item.place_result or ""]
    if base_item and pole then
        local base_recipe = data.raw.recipe[base_name]
        local source = menu_overrides[base_name]
            or (base_recipe and (base_recipe.icon or base_recipe.icons) and base_recipe)
            or base_item
        local menu_icons = lighted_icons(source)
        set_icons(item, menu_icons)
        set_icons(data.raw.recipe[name], menu_icons)

        local entity_icons = lighted_icons(pole)
        set_icons(pole, entity_icons)
        set_icons(data.raw.lamp[pole.name .. "-lamp"], entity_icons)
    end
end
