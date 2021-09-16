local GUIPATH = "__GUI_Unifyer__/graphics/gui/"
local trans = {0, 0, 0, 0}
local white = {1, 1, 1, 0.9}
local black = {0, 0, 0, 0.9}

------------------
-- BUTTON STYLE --
------------------

local slot_button_notext = {
	type = "button_style",
	parent = "slot_button",
	default_font_color = trans,
  hovered_font_color = trans,
	clicked_font_color = trans,
	disabled_font_color = trans,
	selected_font_color = trans,
	selected_hovered_font_color = trans,
	selected_clicked_font_color = trans,
	strikethrough_color = trans,
}
data.raw["gui-style"].default["slot_button_notext"] = slot_button_notext

local slot_button_notext_selected = {
  type = "button_style",
  parent = "slot_button_notext",
  default_graphical_set = {
    base = {border = 4, position = {160, 736}, size = 80},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
  },
}
data.raw["gui-style"].default["slot_button_notext_selected"] = slot_button_notext_selected

local slot_button_whitetext = {
	type = "button_style",
	parent = "slot_button",
	default_font_color = white,
	hovered_font_color = white,
	clicked_font_color = white,
	disabled_font_color = white,
	selected_font_color = white,
	selected_hovered_font_color = white,
	selected_clicked_font_color = white,
	strikethrough_color = white,
}
data.raw["gui-style"].default["slot_button_whitetext"] = slot_button_whitetext

local slot_sized_button_notext = {
	type = "button_style",
	parent = "slot_sized_button",
	default_font_color = trans,
	hovered_font_color = trans,
	clicked_font_color = trans,
	disabled_font_color = trans,
	selected_font_color = trans,
	selected_hovered_font_color = trans,
	selected_clicked_font_color = trans,
	strikethrough_color = trans,
}
data.raw["gui-style"].default["slot_sized_button_notext"] = slot_sized_button_notext

local slot_sized_button_notext_selected = {
  type = "button_style",
  parent = "slot_sized_button_notext",
  default_graphical_set = {
    base = {position = {363, 744}, corner_size = 8},
    shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
  },
}
data.raw["gui-style"].default["slot_sized_button_notext_selected"] = slot_sized_button_notext_selected

local slot_sized_button_blacktext = {
	type = "button_style",
	parent = "slot_sized_button",
	default_font_color = black,
	hovered_font_color = black,
	clicked_font_color = black,
	disabled_font_color = black,
	selected_font_color = black,
	selected_hovered_font_color = black,
	selected_clicked_font_color = black,
	strikethrough_color = black,
}
data.raw["gui-style"].default["slot_sized_button_blacktext"] = slot_sized_button_blacktext

local slot_button_notext_transparent =
{
  type = "button_style",
  parent = "slot_button_notext",
  draw_shadow_under_picture = true,
  size = 40,
  padding = 0,
  default_graphical_set =
  {
    base = {border = 4, position = {0, 736}, size = 80, opacity = 0.5},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
  },
  hovered_graphical_set =
  {
    base = {border = 4, position = {80, 736}, size = 80, opacity = 0.5},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100}),
    glow = offset_by_2_rounded_corners_glow({225, 177, 106, 255})
  },
  clicked_graphical_set =
  {
    base = {border = 4, position = {160, 736}, size = 80, opacity = 0.5},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
  },
  selected_graphical_set =
  {
    base = {border = 4, position = {80, 736}, size = 80, opacity = 0.5},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
  },
  selected_hovered_graphical_set =
  {
    base = {border = 4, position = {80, 736}, size = 80, opacity = 0.5},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100}),
    glow = offset_by_2_rounded_corners_glow({225, 177, 106, 255})
  },
  selected_clicked_graphical_set =
  {
    base = {border = 4, position = {160, 736}, size = 80, opacity = 0.5},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
  },
  pie_progress_color = {0.98, 0.66, 0.22, 0.5},
}
data.raw["gui-style"].default["slot_button_notext_transparent"] = slot_button_notext_transparent

local slot_button_notext_transparent_selected =
{
  type = "button_style",
  parent = "slot_button_notext_transparent",
  default_graphical_set =
  {
    base = {border = 4, position = {0, 736}, size = 80, opacity = 0.5},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
  },
}
data.raw["gui-style"].default["slot_button_notext_transparent_selected"] = slot_button_notext_transparent_selected

local function make_button_style(stylename, filename, imgsize, border, opacity)
  data.raw["gui-style"].default[stylename] = {
    type = "button_style",
    parent = "slot_button_notext",
    draw_shadow_under_picture = true,
    size = (imgsize / 2),
    padding = 0,
    default_graphical_set =           { base = {type = "composition", filename = filename, border = border, position = {0, 0}, size = imgsize, opacity = opacity}, },
    hovered_graphical_set =           { base = {type = "composition", filename = filename, border = border, position = {imgsize, 0}, size = imgsize, opacity = opacity}, },
    selected_graphical_set =          { base = {type = "composition", filename = filename, border = border, position = {imgsize, 0}, size = imgsize, opacity = opacity}, },
    selected_hovered_graphical_set =  { base = {type = "composition", filename = filename, border = border, position = {imgsize, 0}, size = imgsize, opacity = opacity}, },
    selected_clicked_graphical_set =  { base = {type = "composition", filename = filename, border = border, position = {(imgsize * 2), 0}, size = imgsize, opacity = opacity}, },
    clicked_graphical_set =           { base = {type = "composition", filename = filename, border = border, position = {(imgsize * 2), 0}, size = imgsize, opacity = opacity}, },
  }
  data.raw["gui-style"].default[stylename .. "_selected"] = {
    type = "button_style",
    parent = stylename,
    default_graphical_set =           { base = {type = "composition", filename = filename, border = border, position = {(imgsize * 2), 0}, size = imgsize, opacity = opacity}, },
  }
end

make_button_style("gui_unifyer_gui_01", GUIPATH .. "gui_unifyer_gui_01.png", 80, 4, 1)
make_button_style("gui_unifyer_gui_02", GUIPATH .. "gui_unifyer_gui_02.png", 80, 4, 1)
make_button_style("gui_unifyer_gui_03", GUIPATH .. "gui_unifyer_gui_03.png", 80, 4, 0.9)
make_button_style("gui_unifyer_gui_04", GUIPATH .. "gui_unifyer_gui_04.png", 80, 4, 0.9)
make_button_style("gui_unifyer_gui_05", GUIPATH .. "gui_unifyer_gui_05.png", 80, 4, 0.8)
make_button_style("gui_unifyer_gui_06", GUIPATH .. "gui_unifyer_gui_06.png", 80, 4, 0.8)
make_button_style("gui_unifyer_gui_07", GUIPATH .. "gui_unifyer_gui_07.png", 80, 4, 1)
make_button_style("gui_unifyer_gui_08", GUIPATH .. "gui_unifyer_gui_08.png", 80, 4, 0.9)

--data.raw["gui-style"].default["attach-notes-add-button"]
--data.raw["gui-style"].default["attach-notes-edit-button"]
--data.raw["gui-style"].default["attach-notes-view-button"]