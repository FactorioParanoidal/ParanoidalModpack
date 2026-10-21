function open_fli_gui(player, ent)
  if not ent or not ent.valid then
    for _, entityname in ipairs(flientities) do
      if ent.name ~= entityname then
        return
      end
    end
  end

  if not player then
    return
  end
  
  storage.currentfliunitnumber = ent.unit_number
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
  storage.currentfliunitnumber = nil
end


function set_fli_type(event)

  local player = game.players[event.player_index]
  if not player then
    return
  end
  if storage.currentfliunitnumber == nil then
    return
  end
  storage.flitype[storage.currentfliunitnumber] = event.element.selected_index
end