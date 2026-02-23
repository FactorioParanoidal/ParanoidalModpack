minime.entered_file()

if not minime.character_selector then
  minime.entered_file("leave", "character selector is not active")
  return
end

------------------------------------------------------------------------------------
-- Define GUI styles
------------------------------------------------------------------------------------
local styles = data.raw["gui-style"].default

local new_styles = {}
new_styles.minime_button_off = {
  type = "button_style",
  parent = "button",
  padding = 4,
}

-- Used for the buttons used to switch characters
new_styles.minime_character_button_on = {
  type = "button_style",
  parent = "green_button",
  padding = 4,
  tooltip = ""
}

-- Used for character removal buttons (god/editor mode)
new_styles.minime_nocharacter_button_on = {
  type = "button_style",
  parent = "red_button",
  padding = 4,
}

-- Used for the toggle button of the character selector GUI
new_styles.minime_toggle_button_in_flow = {
  type = "button_style",
  parent = "mod_gui_button",
  padding = 4,
}

-- Used for the toggle button of the "Available characters" GUI, which was moved
-- from the top button flow to the bottom of the character selector GUI (ver 1.1.23)
new_styles.minime_toggle_button_in_gui = {
  type = "button_style",
  parent = "button",
  padding = 4,
}

-- Used for the character page switchers in the selector GUI. They only show an
-- arrow pointing left or right and should therefore be narrower than the buttons
-- for selecting characters.
new_styles.minime_arrow_button_on = {
  type = "button_style",
  parent = "green_button",
  padding = 4,
  tooltip = "",
  natural_width = 10,
  minimal_width = 10,
  maximal_width = 30,
  horizontally_stretchable = "on",
  horizontally_squashable = "on",
}
new_styles.minime_arrow_button_off = table.deepcopy(new_styles.minime_arrow_button_on)
new_styles.minime_arrow_button_off.parent = "button"

for s_name, style in pairs(new_styles) do
  style.name = s_name
  styles[s_name] = style
  minime.created_msg(style)
end


------------------------------------------------------------------------------------
minime.entered_file("leave")
