data:extend(
	{
	  {
		type = "font",
		name = "shuttle-train-font",
		from = "default",
		size = 12
	  },
	  {
		type = "font",
		name = "shuttle-train-font-bold",
		from = "default-bold",
		size = 16
	  }
	}
)

data.raw["gui-style"].default["st_top_button_frame_style"] =
{
type = "frame",
	parent = "frame",
	width = 33,
	height = 33,
	left_padding = 0,
	right_padding = 0,
	top_padding = 0,
	bottom_padding = 0,
}

data.raw["gui-style"].default["st_top_image_button_style"] = {
    type = "button",
    parent = "button",
    width = 33,
    height = 33,
    default_graphical_set = {
        type="monolith",
        monolith_image = {
            filename = "__JunkTrain3__/graphics/icon_JunkTrain.png",
            width = 32,
            height = 32
        }
    },
    hovered_graphical_set = {
        type="monolith",
        monolith_image = {
            filename = "__JunkTrain3__/graphics/icon_JunkTrain.png",
            width = 32,
            height = 32
        }
    },
    clicked_graphical_set = {
        type="monolith",
        monolith_image = {
            filename = "__JunkTrain3__/graphics/icon_JunkTrain.png",
            width = 32,
            height = 32
        }
    },
    disabled_graphical_set = {
        type="monolith",
        monolith_image = {
            filename = "__JunkTrain3__/graphics/icon_JunkTrain.png",
            width = 32,
            height = 32
        }
    }
}

data.raw["gui-style"].default["st_label_title"] =
{
	type = "label",
	parent = "label",
	width = 160,
	align = "center",
	font = "shuttle-train-font-bold",
	font_color = {r = 1, g = 1, b = 1}
}


data.raw["gui-style"].default["st_label_simple_text"] =
{
	type = "label",
	parent = "label",
	width = 35,
	left_padding = 5,
	right_padding = 5,
	align = "center",
	font = "shuttle-train-font",
	font_color = {r = 1, g = 1, b = 1}
}


data.raw["gui-style"].default["st_textfield"] =
{
	type = "textfield",
	left_padding = 5,
	right_padding = 5,
	minimal_width = 115,
	maximal_width = 115,
	font = "shuttle-train-font",
	font_color = {},
	graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {16, 0}
	},
	selection_background_color= {r=0.66, g=0.7, b=0.83}
}


data.raw["gui-style"].default["st-station-button"] =
{
	type = "button",
	parent = "button",
	font = "shuttle-train-font",
	default_font_color = {r = 1, g = 1, b = 1},
	align = "center",
	minimal_width = 160,
	top_padding = 5,
	right_padding = 5,
	bottom_padding = 5,
	left_padding = 5,
	default_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
	hovered_font_color = {r = 1, g = 1, b = 1},
	hovered_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 8}
	},
	clicked_font_color = {r = 1, g = 1, b = 1},
	clicked_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 16}
	},
	disabled_font_color = {r = 0.5, g = 0.5, b = 0.5},
	disabled_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
	pie_progress_color = {r = 1, g = 1, b = 1},
	left_click_sound =
	{
		filename = "__core__/sound/gui-click.ogg",
		volume = 1
	}
}

data.raw["gui-style"].default["st-nav-button-pagination"] =
{
	type = "button",
	parent = "button",
	font = "shuttle-train-font",
	default_font_color = {r = 1, g = 1, b = 1},
	align = "center",
	top_padding = 5,
	right_padding = 5,
	bottom_padding = 5,
	left_padding = 5,
	minimal_width = 95,
	maximal_width = 95,
	default_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
	hovered_font_color = {r = 1, g = 1, b = 1},
	hovered_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		corner_size = {3, 3},
		position = {0, 0}
	},
	clicked_font_color = {r = 1, g = 1, b = 1},
	clicked_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		corner_size = {3, 3},
		position = {0, 0}
    },
	disabled_font_color = {r = 0.5, g = 0.5, b = 0.5},
	disabled_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
	pie_progress_color = {r = 1, g = 1, b = 1},
	left_click_sound =
	{
		filename = "__core__/sound/gui-click.ogg",
		volume = 1
	}
}


data.raw["gui-style"].default["st-nav-button-arrow"] =
{
	type = "button",
	parent = "button",
	font = "shuttle-train-font",
	default_font_color = {r = 1, g = 1, b = 1},
	align = "center",
	top_padding = 5,
	right_padding = 5,
	bottom_padding = 5,
	left_padding = 5,
	minimal_width = 25,
	maximal_width = 25,
	default_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
	hovered_font_color = {r = 1, g = 1, b = 1},
	hovered_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 8}
	},
	clicked_font_color = {r = 1, g = 1, b = 1},
	clicked_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 16}
	},
	disabled_font_color = {r = 0.5, g = 0.5, b = 0.5},
	disabled_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
	pie_progress_color = {r = 1, g = 1, b = 1},
	left_click_sound =
	{
		filename = "__core__/sound/gui-click.ogg",
		volume = 1
	}
}

data.raw["gui-style"].default["st-nav-button-arrow-disabled"] =
{
	type = "button",
	parent = "st-nav-button-arrow",
	default_font_color = {r = 0.34, g = 0.34, b = 0.34},
	hovered_font_color = {r = 0.34, g = 0.34, b = 0.38},
	hovered_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		corner_size = {3, 3},
		position = {0, 0}
	},
	clicked_font_color = {r = 0.34, g = 0.34, b = 0.38},
	clicked_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		corner_size = {3, 3},
		position = {0, 0}
    },
}
