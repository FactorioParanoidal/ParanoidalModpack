-- Use Bob's white titanium beam instead of Angel's purple plate, including recipe layers.
local icon = "__bobplates__/graphics/icons/plate/titanium-plate.png"
local titanium_icons = {
    [icon] = true,
    ["__reskins-bobs__/graphics/icons/plates/plates/bob-titanium-plate.png"] = true,
    ["__reskins-angels__/graphics/icons/smelting/plates/angels-plate-titanium.png"] = true,
    ["__angelssmeltinggraphics__/graphics/icons/plate-titanium.png"] = true,
}

for _, name in ipairs({"bob-titanium-plate", "angels-plate-titanium"}) do
    local item = data.raw.item[name]
    if item then
        item.icon = icon
        item.icon_size = 32
        item.icon_mipmaps = nil
        item.icons = nil
        item.pictures = nil -- Ground graphics also fall back to the white item icon.
    end
end

for _, recipe in pairs(data.raw.recipe) do
    if titanium_icons[recipe.icon] then
        recipe.icon = icon
        recipe.icon_size = 32
        recipe.icon_mipmaps = nil
    end
    for _, layer in ipairs(recipe.icons or {}) do
        if titanium_icons[layer.icon] then
            if layer.scale then
                layer.scale = layer.scale * (layer.icon_size or recipe.icon_size or 64) / 32
            end
            layer.icon = icon
            layer.icon_size = 32
            layer.icon_mipmaps = nil
            layer.tint = nil
        end
    end
end
