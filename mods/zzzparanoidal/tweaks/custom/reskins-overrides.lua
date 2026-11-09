-- Paranoidal artwork and Angels 2.0 ingot IDs, without editing Reskins.
-- Existing strings are replaced in the atlas visitor AFTER its remap/downscale.
-- Only these fresh pictures are created afterwards; they must bypass the atlas.
local replacements = require("tweaks.custom.reskins-overrides-data")

if mods["angelssmelting"] and reskins and reskins.angels
    and reskins.angels.triggers.smelting.items
    and reskins.lib.settings.get_value("reskins-angels-use-item-variations") then
    for _, material in ipairs({
        "aluminium", "chrome", "cobalt", "copper", "gold", "iron", "steel", "lead",
        "manganese", "nickel", "platinum", "silicon", "silver", "tin", "titanium", "zinc",
    }) do
        local item = data.raw.item["angels-ingot-" .. material]
        if item then
            local directory = "__reskins-angels__/graphics/icons/smelting/ingots/" .. material .. "/ingot-" .. material
            item.pictures = {}
            for variant = 0, 8 do
                local filename = directory .. (variant == 0 and "" or "-" .. variant) .. ".png"
                item.pictures[#item.pictures + 1] = {
                    filename = replacements[filename] or filename,
                    flags = {"icon"}, size = 64, mipmap_count = 4, scale = 0.5,
                }
            end
        end
    end
end
