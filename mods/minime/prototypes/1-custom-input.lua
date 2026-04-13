minime.entered_file()

if not minime.character_selector then
  minime.entered_file("leave", "character selector is not active")
  return
end


------------------------------------------------------------------------------------
-- Define custom input for toggling the main GUI
local toggle_selector = {
  type = "custom-input",
  name = minime.toggle_gui_input_shortcut_name,
  localised_name = {"controls.minime-toggle-selector-gui"},
  -- Must be assigned by player!
  key_sequence = "",
  controller_key_sequence = "",
  action = "lua",
  consuming = "none",
  enabled = true,
  enabled_while_spectating = false,
  enabled_while_in_cutscene = false,
  include_selected_prototype = false,
}

data:extend({toggle_selector})
minime.created_msg(toggle_selector)



------------------------------------------------------------------------------------
minime.entered_file("leave")
