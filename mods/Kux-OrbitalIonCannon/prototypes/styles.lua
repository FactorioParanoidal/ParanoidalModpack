data.raw["gui-style"].default["ion-cannon-button-style"] =
{
	type = "button_style",
	parent = "button",
	width = 32,
	height = 32,
	padding = 0,
	margin = 2,
	font = "default",
	default_graphical_set =
	{
			filename = mod.path.."graphics/Button.png",
			priority = "extra-high-no-scale",
			width = 64,
			height = 64,
			x = 0,
			y = 0,
	},
	hovered_graphical_set =
	{
			filename = mod.path.."graphics/Button.png",
			priority = "extra-high-no-scale",
			width = 64,
			height = 64,
			x = 64,
			y = 0,
	},
	clicked_graphical_set =
	{
			filename = mod.path.."graphics/Button.png",
			width = 64,
			height = 64,
			x = 0,
			y = 0,
	},
	left_click_sound =
	{
		filename = "__core__/sound/gui-click.ogg",
		volume = 1
	}
}

data.raw["gui-style"].default["ion-cannon-remove-button-style"] =
{
	type = "button_style",
	parent = "button",
	width = 32,
	height = 32,
    padding = 0,
	font = "default",
	default_graphical_set =
	{
			filename = mod.path.."graphics/RemoveButton.png",
			priority = "extra-high-no-scale",
			width = 64,
			height = 64,
			x = 0,
			y = 0,
	},
	hovered_graphical_set =
	{
			filename = mod.path.."graphics/RemoveButton.png",
			priority = "extra-high-no-scale",
			width = 64,
			height = 64,
			x = 64,
			y = 0,
	},
	clicked_graphical_set =
	{
			filename = mod.path.."graphics/RemoveButton.png",
			width = 64,
			height = 64,
			x = 0,
			y = 0,
	},
	left_click_sound =
	{
		filename = "__core__/sound/gui-click.ogg",
		volume = 1
	}
}