-- Wipe stored values
local function init_global()
  global = global or {}
  global.renamer = {}
end

script.on_configuration_changed(init_global)
script.on_init(init_global)

-- Renamer hotkey is pressed
script.on_event("rename", function(event)
  local player = game.players[event.player_index]
  if player.gui.screen.renamer_frame then
    player.gui.screen.renamer_frame.destroy()
  end
  local selection = player.selected
  if selection then
    if selection.supports_backer_name() then
      global.renamer[event.player_index] = selection
      SpawnGUI(player)
    end
  end
end)

-- Enter is pressed in a Lua GUI
script.on_event(defines.events.on_gui_confirmed, function(event)
  if event.element.name == "renamer_textfield" then
    CommitRename(game.players[event.player_index])
  end
end)

-- Escape is pressed in a Lua GUI
script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == "renamer_textfield" then
    CancelRename(game.players[event.player_index])
  end
end)

-- Lua GUI is clicked
script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "renamer_cancel" then
    CancelRename(game.players[event.player_index])
  elseif event.element.name == "renamer_commit" then
    CommitRename(game.players[event.player_index])
  elseif event.element.name == "renamer_reset" then
    ResetRename(game.players[event.player_index])
  elseif event.element.name == "renamer_random" then
    RandomName(game.players[event.player_index], event.tick)
  end
end)

-- Close GUI without making any changes to name
function CancelRename(player)
  if player.gui.screen.renamer_frame then
    player.gui.screen.renamer_frame.destroy()
  end
  global.renamer[player.index] = nil
end

-- Write name to entity and close GUI
function CommitRename(player)
  if player.gui.screen.renamer_frame then
    if global.renamer[player.index] and global.renamer[player.index].valid then
      global.renamer[player.index].backer_name = player.gui.screen.renamer_frame.renamer_content_flow.renamer_textfield.text
      end
    player.gui.screen.renamer_frame.destroy()
  end
  global.renamer[player.index] = nil
end

-- Reset GUI text field contents to entity backer name
function ResetRename(player)
  if player.gui.screen.renamer_frame then
    local textfield = player.gui.screen.renamer_frame.renamer_content_flow.renamer_textfield
    if global.renamer[player.index] and global.renamer[player.index].valid then
      textfield.text = global.renamer[player.index].backer_name
    end
    textfield.select_all()
    textfield.focus()
  end
end

-- Replace GUI text field contents with random name from Randoname mod
function RandomName(player, tick)
  if player.gui.screen.renamer_frame then
    local textfield = player.gui.screen.renamer_frame.renamer_content_flow.renamer_textfield
    if global.renamer[player.index] and global.renamer[player.index].valid then
      if remote.interfaces["Namelists"] then
        textfield.text = remote.call("Namelists", "pick_name", global.renamer[player.index])
      else
        textfield.text = game.backer_names[math.random(#game.backer_names)]
      end
    end
    textfield.select_all()
    textfield.focus()
  end
end

function SpawnGUI(player)
  local frame = player.gui.screen.add{type = "frame", name = "renamer_frame", style = "frame", direction = "vertical"}
  frame.style.bottom_padding = 4
  local title = frame.add{type = "flow", name = "renamer_titlebar_flow", style = "renamer_titlebar_flow"}
  local label = title.add {type = "label", name = "renamer_titlebar_label", style = "frame_title", caption = "Rename"}
  label.drag_target = frame
  local filler = title.add{type = "empty-widget", name = "renamer_title_filler", style = "draggable_space_header"}
  filler.style.horizontally_stretchable = true
  filler.style.natural_height = 24
  filler.style.right_margin = 7
  filler.style.left_margin = 7
  filler.drag_target = frame
  title.add{type = "sprite-button", name = "renamer_cancel", sprite = "utility/close_white", style = "frame_action_button"}
  local content = frame.add{type = "flow", name = "renamer_content_flow"}
  content.style.vertical_align = "center"
  local shuffle = content.add{type = "sprite-button", name = "renamer_random", sprite = "utility/shuffle", style = "tool_button", tooltip = {"renamer-gui-tooltips.random"}}
  shuffle.style.top_margin = 1
  -- end
  local reset = content.add{type = "sprite-button", name = "renamer_reset", sprite = "utility/refresh", style = "tool_button", tooltip = {"renamer-gui-tooltips.reset"}}
  reset.style.top_margin = 1
  local textfield = content.add{type = "textfield", name = "renamer_textfield", text = global.renamer[player.index].backer_name}
  local commit = content.add{type = "sprite-button", name = "renamer_commit", sprite = "renamer-black-check", style = "tool_button", tooltip = {"renamer-gui-tooltips.commit"}}
  commit.style.top_margin = 1
  textfield.select_all()
  textfield.focus()
  frame.force_auto_center()
  player.opened = textfield
end