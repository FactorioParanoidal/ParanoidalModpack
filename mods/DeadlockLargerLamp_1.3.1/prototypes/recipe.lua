local DLL = require("prototypes.globals")

data:extend({
    {
        enabled = false,
        ingredients = {
            { "electronic-circuit", 1 },
            { "copper-cable", 9 },
            { "iron-plate", 6 },
        },
        name = DLL.name,
        result = DLL.name,
        type = "recipe",
    },
    {
        enabled = true,
        ingredients = {
            { "copper-plate", 8 },
        },
        name = DLL.copper_name,
        result = DLL.copper_name,
        type = "recipe",
    },
	{
		name = "deadlock-lamp-burning",
		type = "recipe-category",
	},
})
