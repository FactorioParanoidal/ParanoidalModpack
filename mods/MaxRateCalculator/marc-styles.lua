local default_gui = data.raw["gui-style"].default

default_gui.sprite_obj_marc_style = 
{
	type="button_style",
	-- parent="button_style",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	height = 32,
	width = 32,
	scalable = false
}

default_gui.marcalc_button_style = 
{
	type="button_style",
	-- parent="button_style",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	height = 40,
	width = 40,
	scalable = false
}

default_gui.table_marc_style =
{
	type = "table_style",
	horizontal_spacing = 5,
	vertical_spacing = 1,
	resize_row_to_width = false,
	resize_to_row_height = false,
}

default_gui.scroll_pane_marc_style =
{
	type = "scroll_pane_style",
	-- parent="scroll_pane_style",
	-- flow_style =
	-- {
	-- 	type = "flow_style",
	-- 	parent = "flow_style"
	-- },
	resize_row_to_width = true,
	resize_to_row_height = false,
	minimal_height=128,
	maximal_height=400,
	max_on_row = 1,
}

data:extend(
{
	{
	type = "sprite",
	name = "sprite_marc_close",
	filename = "__core__/graphics/cancel.png",
	width = 64,
	height = 64
	},
	{
		type = "sprite",
		name = "sprite_marc_calculator",
		filename = "__MaxRateCalculator__/graphics/calculator.png",
		width = 64,
		height = 64
	}
})