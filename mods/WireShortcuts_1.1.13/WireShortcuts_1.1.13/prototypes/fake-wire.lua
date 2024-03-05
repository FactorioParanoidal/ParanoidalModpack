if settings.startup["wire-shortcuts-is-retain-wire-crafting"].value then
    data:extend({
        {
            type = "item",
            name = "fake-red-wire",
            icon = "__WireShortcuts__/graphics/icons/fake-red-wire.png",
            icon_size = 64,
            icon_mipmaps = 4,
            subgroup = "circuit-network",
            order = "b[wires]-a[red-wire]",
            stack_size = 200,
            flags = {"hidden"}
        },
        {
            type = "item",
            name = "fake-green-wire",
            icon = "__WireShortcuts__/graphics/icons/fake-green-wire.png",
            icon_size = 64,
            icon_mipmaps = 4,
            subgroup = "circuit-network",
            order = "b[wires]-b[green-wire]",
            stack_size = 200,
            flags = {"hidden"}
        }

    })

    data:extend({
        {
            type = "recipe",
            name = "fake-red-wire",
            enabled = false,
            hidden = true,
            ingredients = {{"electronic-circuit", 1}, {"copper-cable", 1}},
            result = "fake-red-wire"
        },
        {
            type = "recipe",
            name = "fake-green-wire",
            enabled = false,
            hidden = true,
            ingredients = {{"electronic-circuit", 1}, {"copper-cable", 1}},
            result = "fake-green-wire"
        }
    })
end
