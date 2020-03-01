require("prototypes.globals")

data:extend({
	{
		type = "item",
		name = DLL.name,
		order = "a[light]-b[large-lamp]",
		stack_size = 100,
		icon = string.format("%s/deadlock-large-lamp-64.png", DLL.icon_path),
		icon_size = 64,
		subgroup = "circuit-network",
		place_result = DLL.name,
	},
	{
		type = "item",
		name = DLL.copper_name,
		order = "a[light]-a[aardvark-lamp]",
		stack_size = 100,
		icon = string.format("%s/deadlock-copper-lamp-64.png", DLL.icon_path),
		icon_size = 64,
		subgroup = "circuit-network",
		place_result = DLL.copper_name,
	},
})
