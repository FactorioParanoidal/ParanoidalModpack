-- The opened indicator is remembered per player (storage.fli_open[player_index]): with one shared
-- value, two players with open indicators changed each other's indicator type.
local function open_table()
  local t = storage.fli_open
  if not t then
    t = {}
    storage.fli_open = t
  end
  return t
end

function open_fli_gui(player, ent)
  if not (ent and ent.valid) then
    return
  end

  if not player then
    return
  end
  
  open_table()[player.index] = ent.unit_number
  local frame_flow = player.gui
  if frame_flow.relative.fli_picker then
    frame_flow.relative.fli_picker.destroy()
  end
  
  local fli_picker = frame_flow.relative.add(
  {
    type = "frame",
    name = "fli_picker",
    direction = "vertical",
    anchor = { gui = defines.relative_gui_type.storage_tank_gui, position = defines.relative_gui_position.bottom  },
  })
  
  local fli_title = fli_picker.add(
  {
    type = "label",
    caption = {"fli.pick-indicator-type"},
    tooltip = {"fli.pick-indicator-tooltip"}
  })

  local fli_dropdown = fli_picker.add(
  {
    type = "drop-down",
    items = {{"fli.high-ideal"}, {"fli.mid-ideal"}, {"fli.low-ideal"}},
    selected_index = storage.flitype[ent.unit_number],
    name = "fli_dropdown"
  })
end    


function close_fli_gui(player, ent)

  if not player then
    return
  end
  local frame_flow = player.gui.relative
  if frame_flow.fli_picker then
    frame_flow.fli_picker.destroy()
  end
  open_table()[player.index] = nil
end


function set_fli_type(event)

  local player = game.players[event.player_index]
  if not player then
    return
  end
  local unit_number = open_table()[event.player_index]
  if unit_number == nil or not storage.flis[unit_number] then
    return
  end
  storage.flitype[unit_number] = event.element.selected_index
end
