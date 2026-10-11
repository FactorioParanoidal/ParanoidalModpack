script.on_init(function()
  for _, surface in pairs(game.surfaces) do
    surface.generate_with_lab_tiles = true
    surface.clear()
  end

  for _, planet in pairs(game.planets) do
    surface = planet.create_surface()
    surface.generate_with_lab_tiles = true
  end

  for _, force in pairs(game.forces) do
    force.research_all_technologies()
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)

  local character = player.character
  player.character = nil
  if character then
    character.destroy()
  end

  player.cheat_mode = true
  player.toggle_map_editor()
  game.tick_paused = false

  player.print{"messages.universe-of-sandboxes-intro"}
end)