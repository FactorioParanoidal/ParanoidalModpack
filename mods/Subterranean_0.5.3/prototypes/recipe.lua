data:extend(
    {
        {
            type = "recipe",
            name = "subterranean-belt",
            enabled = false,
            energy_required = 1,
            ingredients = {
                {"iron-plate", 200},
                {"transport-belt", 250}
            },
            result_count = 2,
            result = "subterranean-belt",
            requester_paste_multiplier = 4
        },
        {
            type = "recipe",
            name = "fast-subterranean-belt",
            enabled = false,
            ingredients = {
                {"steel-gear-wheel", 100},
				{"fast-transport-belt", 250},
                {"subterranean-belt", 2}
            },
            result_count = 2,
            result = "fast-subterranean-belt",
            requester_paste_multiplier = 4
        },
        {
            type = "recipe",
            name = "express-subterranean-belt",
            category = "crafting-with-fluid",
            enabled = false,
            ingredients = {
                {"titanium-gear-wheel", 100},
				{"express-transport-belt", 250},
                {"fast-subterranean-belt", 2},
                {type = "fluid", name = "lubricant", amount = 400}
            },
            result_count = 2,
            result = "express-subterranean-belt"
        },
        {
            type = "recipe",
            name = "subterranean-pipe",
            enabled = false,
            ingredients = {
                {"steel-pipe", 250},
                {"steel-plate", 200}
            },
            result_count = 2,
            result = "subterranean-pipe",
            requester_paste_multiplier = 4
        }
    }
)
