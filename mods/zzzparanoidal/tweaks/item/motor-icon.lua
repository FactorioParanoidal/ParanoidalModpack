-- Beta 8 motor icon (AAI 1.1 motor.png): AAI 2.0 replaced it with single-cylinder-engine.png,
-- while the Components menu already gives the recipe the Beta 8 icon. The item, its recycling
-- recipe and other recipes without their own icon follow the item.
local item = data.raw.item["motor"]
if item then
    item.icon = "__zzzparanoidal__/graphics/components-menu-beta8/00ec0cffebec2ffa866e.png"
    item.icon_size = 64
    item.icon_mipmaps = nil
    item.icons = nil
end
