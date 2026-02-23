game.simulation.camera_position = { 0, 0.5 }

storage.player = game.simulation.create_test_player({ name = "foo" })
storage.character = storage.player.character
storage.character.teleport({ 0, 3 })

game.simulation.camera_player = storage.player

step_0 = function()
  game.simulation.camera_player_cursor_position = { 0, 3 }
  game.simulation.camera_player_cursor_direction = defines.direction.east
  target_cursor_position = { -5, -1 }
  script.on_nth_tick(1, function()
    local finished = game.simulation.move_cursor({ position = target_cursor_position })
    if finished then
      step_1()
    end
  end)
end

step_1 = function()
  storage.character.cursor_stack.set_stack({ name = "duct-small", count = 10 })
  target_cursor_position = { 5, -1 }
  script.on_nth_tick(1, function()
    local finished = game.simulation.move_cursor({ position = target_cursor_position, speed = 0.1 })

    if storage.player.can_build_from_cursor({ position = game.simulation.camera_player_cursor_position }) then
      storage.player.build_from_cursor({
        position = game.simulation.camera_player_cursor_position,
        direction = defines.direction.east,
      })
    end

    if finished then
      step_2()
    end
  end)
end

step_2 = function()
  target_cursor_position = { 0, 3 }
  script.on_nth_tick(1, function()
    local finished = game.simulation.move_cursor({ position = target_cursor_position })
    if finished then
      finish()
    end
  end)
end

finish = function()
  storage.finished_tick = game.tick

  script.on_nth_tick(1, function()
    if game.tick == storage.finished_tick + 90 then
      for _, entity in pairs(game.surfaces[1].find_entities_filtered({ name = { "duct", "duct-long" } })) do
        entity.destroy()
      end
      step_0()
    end
  end)
end

step_0()
