-- Paranoidal artwork and Angels 2.0 ingot IDs, without editing Reskins.
-- Apply after atlas remapping so its original-path comparisons still match.
local replacements = require("tweaks.custom.reskins-overrides-data")
local seen = {}
local function replace(node)
    if seen[node] then return end
    seen[node] = true
    for key, value in pairs(node) do
        if type(value) == "table" then
            replace(value)
        elseif type(value) == "string" and replacements[value] then
            node[key] = replacements[value]
        end
    end
end

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
                item.pictures[#item.pictures + 1] = {
                    filename = directory .. (variant == 0 and "" or "-" .. variant) .. ".png",
                    flags = {"icon"}, size = 64, mipmap_count = 4, scale = 0.5,
                }
            end
        end
    end
end

replace(data.raw)
