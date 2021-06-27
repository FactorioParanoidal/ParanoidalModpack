require("prototypes.data-tables")
if mods["angelsindustries"] and angelsmods.industries.components then
    for n, item in pairs(shielding) do
        data:extend({
            {
                type = "item",
                name = "angels-shielding-coil-" .. item.metal,
                icon = "__angelssmelting__/graphics/icons/wire-coil-" .. item.metal .. ".png",
                icon_size = 64,
                subgroup = "angels-" .. item.metal .. "-casting",
                order = item.order,
                stack_size = 200
            }
        })
    end
end