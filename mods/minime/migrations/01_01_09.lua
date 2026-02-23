minime.entered_file()

------------------------------------------------------------------------------------
--    Remove old GUIs from player.gui.left, we're using player.gui.screen now!    --
------------------------------------------------------------------------------------
local gui

for p, player in pairs(game.players) do
  gui = player.gui.left and player.gui.left.mod_gui_frame_flow
  if gui and gui["minime_character_list"] and gui["minime_character_list"].valid then
    minime.writeDebug("Player %s: Removing %s.",
                      {p, minime.argprint(gui["minime_character_list"])})
    gui["minime_character_list"].destroy()
  end
end

minime.entered_file("leave")
