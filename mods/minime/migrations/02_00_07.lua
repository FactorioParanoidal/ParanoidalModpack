minime.entered_file()

------------------------------------------------------------------------------------
--         Disable checkbox for current character in available chars GUIs!        --
------------------------------------------------------------------------------------
local p_data, char

mod = storage

minime.writeDebugNewBlock("Updating checkboxes in 'available characters' GUI!")
for p, player in pairs(game.players) do
  p_data = storage.player_data and storage.player_data[p]
  char = player.character

  minime.writeDebugNewBlock("Update checkboxes in GUI of %s?",
                            {minime.argprint(player)})
  if p_data and char and char.valid then
    minime.writeDebug("Yes!")
    minime_gui.available.update_all_checkboxes(player)
  else
    minime.writeDebug("No: %s!", {
      p_data and  "player doesn't have a valid character" or
                  "no data stored for player"
    })
  end
end

minime.entered_file("leave")
