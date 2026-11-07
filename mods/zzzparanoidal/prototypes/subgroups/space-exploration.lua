-- SpaceX Get a Room (Ober3550): https://mods.factorio.com/mod/SpaceXGAR
-- Keep legacy IDs: RCU and the final crafting-menu passes consume these groups.
data:extend{{
    type = "item-group",
    name = "space-exploration",
    order = "x",
    inventory_order = "x",
    icon = "__zzzparanoidal__/graphics/icons/space-exploration.png",
    icon_size = 64,
}}

for _, suffix in ipairs{"a", "b", "c", "d", "e", "x", "y"} do
    data:extend{{
        type = "item-subgroup",
        name = "space-exploration-" .. suffix,
        group = "space-exploration",
        order = suffix,
    }}
end
