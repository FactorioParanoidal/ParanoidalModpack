
data:extend{
    --[[{
        type = "item-group",
        name = "textplates",
        order = "d-b", -- after combat, before fluids
        icon = "__textplates__/graphics/text-plates-group.png"
    },
    {
        type = "item-subgroup",
        name = "textplates-blanks",
        group = "textplates",
        order = "a",
    },
    {
        type = "item-subgroup",
        name = "textplates-symbols",
        group = "textplates",
        order = "b",
    },]]--
    {
        type = "item-subgroup",
        name = "textplates",
        group = "logistics",
        order = "z",
    },
}
