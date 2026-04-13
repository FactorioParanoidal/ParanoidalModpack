minime.entered_file()

------------------------------------------------------------------------------------
-- Remove toggle buttons for "Available Characters" GUI from button flow, as they --
-- are moved to the bottom of the selector GUI in version 1.1.23.                 --
------------------------------------------------------------------------------------
local buttons
local toggle_name = "minime_available_chars_toggle_button"

for p, player in pairs(game.players) do
  buttons = mod_gui.get_button_flow(player)

  if buttons and buttons[toggle_name] and buttons[toggle_name].valid then
    minime.writeDebug("%s: Removing %s.",
                      {minime.argprint(player), minime.argprint(buttons[toggle_name])})
    buttons[toggle_name].destroy()
  end
end

minime.entered_file("leave")
