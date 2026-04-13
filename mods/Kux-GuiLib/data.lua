local changelog = require("data-changelog")
local styles = data.raw["gui-style"].default

changelog.start_snapshot("gui-style","font")

local sizes = { 8, 9, 10, 11, 12, 14, 16, 18, 20 }

--from = "NotoMono", --> locale/LANG/info.json
for _, size in ipairs(sizes) do
	data:extend{ {type = "font", name = "NotoMono-"..size, from = "NotoMono", size = size} }
	data:extend{ {type = "font", name = "default-"..size, from = "default", size = size} }
	data:extend{ {type = "font", name = "default-bold-"..size, from = "default-bold", size = size} }
end

styles["Kux-GuiLib-dark-code-textbox"] = {
    type = "textbox_style",
    parent = "textbox",
    minimal_width = 650,
    minimal_height = 200,
	font = "NotoMono-14",
	font_color = { 241, 241, 241}, -- hell
	vertically_stretchable="on",
	vertically_squashable="on",
	active_background = {
		base = {
			position = {248, 0},
			corner_size = 8,
			tint = { r = 0.3, g = 0.3, b = 0.3 },
		},
		shadow = {
			position = {240, 783},
			corner_size = 16,
			draw_type = "outer",
			tint = { r = 0.2, g = 0.2, b = 0.2 },
			top_outer_border_shift = 4,
			bottom_outer_border_shift = -4,
			left_outer_border_shift = 4,
			right_outer_border_shift = -4
		}
	},
	default_background = {
		base = {
			position = {248, 0},
			corner_size = 8,
			tint = { r = 0.4, g = 0.4, b = 0.4 }
		},
		shadow = {
			position = {240, 783},
			corner_size = 16,
			draw_type = "outer",
			tint = { r = 0.2, g = 0.2, b = 0.2 },
			top_outer_border_shift = 4,
			bottom_outer_border_shift = -4,
			left_outer_border_shift = 4,
			right_outer_border_shift = -4
		}
	  },
	disabled_background = {},
	disabled_font_color = {a = 0.5, b = 0.5, g = 0.5, r = 0.5 },
	rich_text_setting = "disabled",
	selection_background_color = {0, 120, 212 },
}


changelog.final_snapshot({"gui-style","font"})