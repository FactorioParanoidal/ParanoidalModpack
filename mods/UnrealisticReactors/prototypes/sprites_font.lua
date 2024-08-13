local colors = {
"r" ,
"y" ,
"b" ,
"a" ,
"ry" ,
"rb" ,
"ra" ,
"yb" ,
"ya" ,
"ba" ,
"rya",
"ryb" ,
"rba" ,
"yba" ,
"ryba" }

for _, color in pairs(colors) do
	data:extend{
		{
			type="sprite",
			name="rr-"..color,
			filename = "__UnrealisticReactors__/graphics/sprites/"..color..".png",
			priority = "extra-high",
			width = 1,
			height = 1,
		}
	}
end


data:extend({
	{
		type = "font",
		name = "rr-small-bold",
		from = "default-bold",
		size = 9,
	},
	{
		type="sprite",
		name="rr-black",
		filename = "__UnrealisticReactors__/graphics/sprites/black.png",
		priority = "extra-high",
		width = 1,
		height = 1,
	},
	{
		type="sprite",
		name="rr-black-background",
		filename = "__UnrealisticReactors__/graphics/black192x101.png",
		priority = "extra-high",
		width = 192,
		height = 101,
		flags = {"linear-magnification"},
	},
	{
		type="sprite",
		name="rr-button-x",
		filename = "__UnrealisticReactors__/graphics/sprites/button_x.png",
		priority = "extra-high",
		width = 32,
		height = 32,
	},
	{
		type="sprite",
		name="rr-button-graph",
		filename = "__UnrealisticReactors__/graphics/sprites/button_graph.png",
		priority = "extra-high",
		width = 61,
		height = 32,
	},
	{
		type="sprite",
		name="rr-button-graph-off",
		filename = "__UnrealisticReactors__/graphics/sprites/button_graph_off.png",
		priority = "extra-high",
		width = 61,
		height = 32,
	},
	{
		type="sprite",
		name="rr-button-signals",
		filename = "__UnrealisticReactors__/graphics/sprites/button_signals.png",
		priority = "extra-high",
		width = 90,
		height = 32,
	},
	{
		type="sprite",
		name="rr-button-signals-off",
		filename = "__UnrealisticReactors__/graphics/sprites/button_signals_off.png",
		priority = "extra-high",
		width = 90,
		height = 32,
	},
	{
		type="sprite",
		name="rr-button-progress",
		filename = "__UnrealisticReactors__/graphics/sprites/button_progress.png",
		priority = "extra-high",
		width = 61,
		height = 32,
	},
	{
		type="sprite",
		name="rr-button-progress-off",
		filename = "__UnrealisticReactors__/graphics/sprites/button_progress_off.png",
		priority = "extra-high",
		width = 61,
		height = 32,
	},
	{
		type="sprite",
		name="rr-bonuscell-sprite",
		filename = "__UnrealisticReactors__/graphics/icons/bonuscell_sprite.png",
		priority = "extra-high",
		width = 32,
		height = 32,
	},
	{
		type="sprite",
		name="rr-transparent-sprite",
		filename = "__UnrealisticReactors__/graphics/transparent32.png",
		priority = "extra-high",
		width = 32,
		height = 32,
	},
	{
		type="sprite",
		name="rr-mini-sprite",
		filename = "__core__/graphics/empty.png",
		priority = "high",
		width = 1,
		height = 1,
	},
})

data.raw["gui-style"].default.rr_button = {
	name = "rr_button",
	type = "button_style",
	parent = "image_tab_slot",
	scalable = false,
	width = 25,
	height = 25,
	padding = 0,
	default_graphical_set =
	{
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		width = 36,
		height = 36,
		x = 111,
		y = 144
	},
	hovered_graphical_set =
	{
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		width = 36,
		height = 36,
		x = 148,
		y = 144
	},
	clicked_graphical_set =
	{
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		width = 36,
		height = 36,
		x = 111,
		y = 0
	}
}

