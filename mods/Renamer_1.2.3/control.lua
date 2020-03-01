local function init_global()
  global = global or {}
  global.renamer = global.renamer or {}
end

script.on_configuration_changed(init_global)
script.on_init(init_global)

script.on_event("rename", function(event)
  if game.players[event.player_index].gui.center.renameFrame then
    game.players[event.player_index].gui.center.renameFrame.destroy()
  end
  local selection = game.players[event.player_index].selected
  if selection then
    if selection.supports_backer_name() then
      global.renamer[event.player_index] = selection
      SpawnGUI(game.players[event.player_index])
    else
      -- game.players[event.player_index].print("Selection does not support renaming.")
    end
  end
end)

script.on_event("rename-commit", function(event)
  local player = game.players[event.player_index]
  if player.gui.center.renameFrame then
    if global.renamer[player.index].valid then
      global.renamer[player.index].backer_name =
        player.gui.center.renameFrame.renameTextfield.text
      end
    player.gui.center.renameFrame.destroy()
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "renamerX" then
    game.players[event.player_index].gui.center.renameFrame.destroy()
  elseif event.element.name == "renamerButton" then
    local player = game.players[event.player_index]
    if global.renamer[player.index].valid then
      global.renamer[player.index].backer_name =
          player.gui.center.renameFrame.renameTextfield.text
    end
    player.gui.center.renameFrame.destroy()
  end
end)

function SpawnGUI(player)
  -- if not player.gui.center.renameFrame then
    frame = player.gui.center.add
    {
      type="frame",
      name="renameFrame"
    }
    frame.add
    {
      type = "button",
      name = "renamerX",
      caption = "Cancel",
      style = "renamer-button-style"
    }
    frame.add
    {
      type="textfield",
      name="renameTextfield"
    }
    player.gui.center.renameFrame.renameTextfield.text =
        global.renamer[player.index].backer_name
    frame.add
    {
      type = "button",
      name = "renamerButton",
      caption = "OK",
      style = "renamer-button-style"
    }
    player.gui.center.renameFrame.renameTextfield.select_all()
    player.gui.center.renameFrame.renameTextfield.focus()
  -- end
end