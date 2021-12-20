require("prototypes.data-tables")
if mods["angelsindustries"] and angelsmods.industries.components then
    for n, item in pairs(ASE.tables.shielding) do
        data:extend({
            {
                type = "item",
                name = "angels-shielding-coil-" .. item.metal,
                icons = {
                    { icon = "__angelssmelting__/graphics/icons/wire-coil-" .. item.metal .. ".png", icon_size = 64,},
                    { icon = "__angelsindustries__/graphics/icons/cable-shield-"..n..".png", icon_size = 32, scale = 0.4375, shift = {10, -10}}
                },
                
                subgroup = "angels-" .. item.metal .. "-casting",
                order = item.order,
                stack_size = 200
            }
        })
    end
end