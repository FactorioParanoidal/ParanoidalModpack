local DLL = require("prototypes.globals")

data:extend({
    {
        name = DLL.name,
        type = "recipe",
        enabled = false,
        ingredients = {
            { "electronic-circuit", 1 },
            { "copper-cable", 4 },
            { "iron-plate", 6 },
        },
        result = DLL.name,
    },
    {
        name = DLL.copper_name,
        type = "recipe",
        enabled = true,
        ingredients = {
            { "copper-plate", 6 },
        },
        result = DLL.copper_name,
    },
	{
		name = DLL.copper_name.."-burning",
		type = "recipe",
		enabled = true,
		hidden = true,
		hide_from_stats = true,
		icon = string.format("%s/copper-lamp.png", DLL.icon_path),
		icon_size = 64,
		icon_mipmaps = 4,
		category = "lamp-burning",
		ingredients = {},
		results = {},
		subgroup = "other",
		energy_required = 25000/60, -- one "result" = one factorio day
	},
	{
		name = "lamp-burning",
		type = "recipe-category",
	},
    {
        name = DLL.floor_name,
        type = "recipe",
        enabled = false,
        ingredients = {
            { "electronic-circuit", 1 },
            { "copper-cable", 4 },
            { "iron-plate", 6 },
        },
        result = DLL.floor_name,
    },
})
