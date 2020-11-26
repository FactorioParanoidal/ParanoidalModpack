PIPE_TYPES =
{
  ["pipe-elbow"] = true,
  ["pipe-junction"] = true,
  ["pipe-straight"] = true
}

script.on_event(defines.events.on_gui_opened, function(event)
  if event.gui_type == defines.gui_type.entity and event.entity and PIPE_TYPES[event.entity.name] then
    game.players[event.player_index].opened = nil
  end
end)