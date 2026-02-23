minime.entered_file()

------------------------------------------------------------------------------------
--            Store current character with players, not just the name!            --
------------------------------------------------------------------------------------
local p_data, char

for p, player in pairs(game.players) do
  p_data = storage.player_data and storage.player_data[p]
  char = player.character
  if p_data and char and char.valid then
    minime.writeDebug("Storing %s as p_data.char_entity.", {minime.argprint(char)})
    p_data.char_entity = player.character
  else
    minime.writeDebug("Ignoring %s as p_data.char_entity.", {minime.argprint(char)})
  end
end

minime.entered_file("leave")
