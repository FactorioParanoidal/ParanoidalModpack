-- New Group for New Recipes
data:extend({
    {
        type = "item-group",
        name = BPSB.name,
        icon = BPSB.path .. "/graphics/icon-x56.png",
        icon_size = 56,
        order = "z",
    },
    {
        type = "item-subgroup",
        name = BPSB.pfx .. "loaders",
        group = BPSB.name,
        order = "a[loaders]",
    },
    {
        type = "item-subgroup",
        name = BPSB.pfx .. "infinity",
        group = BPSB.name,
        order = "b[infinity]",
    },
})
