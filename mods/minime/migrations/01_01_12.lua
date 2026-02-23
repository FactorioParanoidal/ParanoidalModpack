minime.entered_file()

------------------------------------------------------------------------------------
--                            Remove old toggle buttons                           --
------------------------------------------------------------------------------------
local button = "minime_toggle_list"
local main_frame = "minime_character_list"

local buttons, frames

for p, player in pairs(game.players) do
minime.show("player", player.name)

  buttons = player.gui.top and player.gui.top.mod_gui_top_frame and
            player.gui.top.mod_gui_top_frame.mod_gui_inner_frame
  frames = player.gui.screen

  -- Remove button?
  if buttons and buttons[button] and buttons[button].valid then
    minime.writeDebug("Player %s: Removing %s.", {p, minime.argprint(buttons[button])})
    buttons[button].destroy()
  end

  -- Remove main frame?
  if frames and frames[main_frame] and frames[main_frame].valid then
    minime.writeDebug("Player %s: Removing %s.", {p, minime.argprint(frames[main_frame])})
    frames[main_frame].destroy()
  end
end


------------------------------------------------------------------------------------
--     Remove global tables for character pages (moved to global.player_data)     --
------------------------------------------------------------------------------------
for t, tab in pairs({"gui_character_pages", "gui_character_pages_lookup"}) do
  if storage[tab] then
    storage[tab] = nil
    minime.writeDebug("Removed storage.%s.", {tab})
  end
end

minime.entered_file("leave")
