local compat
local factorio = require "baseversion"()
--local factorio = "0.16"
--	factorio = "0.17"
do
	if factorio == "0.16" then
		local function compat_factorio_016(t)
			return {
				type = "monolith",
				monolith_image = t
			}
		end
		compat = compat_factorio_016
	else
		local function compat_factorio_017(t)
			return t
		end
		compat = compat_factorio_017
	end
end


local modname = "__blueprint_flip_and_turn__"

data:extend(
{
	{
		type = "font",
		name = "blpflip_font",
		from = "default",
		size = 10
	}
}
)

data.raw["gui-style"].default["blpflip_button_horizontal"] =
{
	type = "button_style",
	parent = "button",
	width = 36,
	height = 36,
	top_padding = 6,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	font = "blpflip_font",
	default_graphical_set = compat {
		filename = modname .. "/graphics/gui.png",
		priority = "extra-high-no-scale",
		width = 36,
		height = 36,
		x = 0,
		y = 0,
	},
	hovered_graphical_set = compat {
		filename = modname .. "/graphics/gui.png",
		priority = "extra-high-no-scale",
		width = 36,
		height = 36,
		x = 0,
		y = 36,
	},
	clicked_graphical_set = compat {
		filename = modname .. "/graphics/gui.png",
		width = 36,
		height = 36,
		x = 0,
		y = 36,
	},
	left_click_sound =
	{
		filename = "__core__/sound/gui-click.ogg",
		volume = 1
	}
}

data.raw["gui-style"].default["blpflip_button_vertical"] =
{
	type = "button_style",
	parent = "button",
	width = 36,
	height = 36,
	top_padding = 6,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	font = "blpflip_font",
	default_graphical_set = compat {
		filename = modname .. "/graphics/gui.png",
		priority = "extra-high-no-scale",
		width = 36,
		height = 36,
		x = 36,
		y = 0,
	},
	hovered_graphical_set = compat {
		filename = modname .. "/graphics/gui.png",
		priority = "extra-high-no-scale",
		width = 36,
		height = 36,
		x = 36,
		y = 36,
	},
	clicked_graphical_set = compat {
		filename = modname .. "/graphics/gui.png",
		width = 36,
		height = 36,
		x = 36,
		y = 36,
	},
	left_click_sound =
	{
		filename = "__core__/sound/gui-click.ogg",
		volume = 1
	}
}
