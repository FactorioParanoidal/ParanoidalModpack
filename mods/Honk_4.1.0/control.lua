local function build_honks()
  global = global or {}
  -- build a table in the form global.honks[current_state][previous_state] = sound to play
  global.honks = { }
  if settings.global["honk-sound-start"].value ~= "none" then
    global.honks[defines.train_state.on_the_path] = {
      -- play start honk if previous state was one of the below
      [defines.train_state.path_lost] = settings.global["honk-sound-start"].value,
      [defines.train_state.no_schedule] = settings.global["honk-sound-start"].value,
      [defines.train_state.no_path] = settings.global["honk-sound-start"].value,
      [defines.train_state.arrive_signal] = nil,
      [defines.train_state.wait_signal] = settings.global["honk-sound-start"].value,
      [defines.train_state.arrive_station] = nil,
      [defines.train_state.wait_station] = settings.global["honk-sound-start"].value,
      [defines.train_state.manual_control_stop] = settings.global["honk-sound-start"].value,
      [defines.train_state.manual_control] = settings.global["honk-sound-start"].value
    }
    -- definition for auto-selected keypress starting honk
    global.honks.manual_start = settings.global["honk-sound-start"].value
  end
  if settings.global["honk-sound-lost"].value ~= "none" then
    global.honks[defines.train_state.path_lost] = {
      -- play lost honk if previous state was one of the below
      [defines.train_state.on_the_path] = settings.global["honk-sound-lost"].value,
      [defines.train_state.arrive_signal] = settings.global["honk-sound-lost"].value,
      [defines.train_state.arrive_station] = settings.global["honk-sound-lost"].value
    }
    global.honks[defines.train_state.manual_control_stop] = {
      -- play lost honk if previous state was one of the below
      [defines.train_state.on_the_path] = settings.global["honk-sound-lost"].value,
      [defines.train_state.arrive_signal] = settings.global["honk-sound-lost"].value,
      [defines.train_state.arrive_station] = settings.global["honk-sound-lost"].value
    }
    -- definition for auto-selected keypress braking honk
    global.honks.manual_stop = settings.global["honk-sound-lost"].value
  end
  if settings.global["honk-sound-station"].value ~= "none" then
    global.honks[defines.train_state.arrive_station] = {
      -- play station honk only if previous state was normal pathing
      [defines.train_state.on_the_path] = settings.global["honk-sound-station"].value
    }
    -- fallback definition for auto-selected keypress braking honk
    global.honks.manual_stop = global.honks.manual_stop or settings.global["honk-sound-station"].value
  end
  if settings.global["honk-sound-signal"].value ~= "none" then
    global.honks[defines.train_state.arrive_signal] = {
      -- play signal honk only if previous state was normal pathing
      [defines.train_state.on_the_path] = settings.global["honk-sound-signal"].value
    }
    -- second fallback definition for auto-selected keypress braking honk
    global.honks.manual_stop = global.honks.manual_stop or settings.global["honk-sound-signal"].value
  end
  if settings.global["honk-sound-manual"].value == "auto" then
    global.honks.auto = true
  elseif settings.global["honk-sound-manual"].value ~= "none" then
    -- not auto, use this value
    global.honks.manual = settings.global["honk-sound-manual"].value
  end
  if settings.global["honk-sound-manual-alt"].value ~= "none" then
    global.honks.alt = settings.global["honk-sound-manual-alt"].value
  end
  -- game.print("Honks (re)built")
end

script.on_configuration_changed(build_honks)
script.on_init(build_honks)

-- Detect setting changes during session
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  build_honks()
end)

function playSoundAtEntity(sound, entity)
  entity.surface.play_sound
  {
    path = sound,
    position = entity.position
  }
end

-- Find loco(s) to emit honks in train
-- A stationary train will honk at front- and rear-facing locos if both are present
function findLocoToHonk(sound, train)
  if train.speed >= 0 and #train.locomotives.front_movers > 0 then
    playSoundAtEntity(sound, train.locomotives.front_movers[1])
  end
  if train.speed <= 0 and #train.locomotives.back_movers > 0 then
    playSoundAtEntity(sound, train.locomotives.back_movers[#train.locomotives.back_movers])
  end 
end

-- Manual honk
script.on_event("honk", function(event)
  local player = game.players[event.player_index]
  if player.vehicle and
  player.vehicle.type == "locomotive" then
    if global.honks.auto then -- choose honk based on whether or not train is moving
      if player.vehicle.train.speed == 0 then
        if global.honks.manual_start then
          playSoundAtEntity(global.honks.manual_start, player.vehicle)
        end
      else
        if global.honks.manual_stop then
          playSoundAtEntity(global.honks.manual_stop, player.vehicle)
        end
      end
    else -- not automatic mode, play the player-selected sound
      if global.honks.manual then
        playSoundAtEntity(global.honks.manual, player.vehicle)
      end
    end
  end
end)

-- Manual alt honk
script.on_event("honk-alt", function(event)
  local player = game.players[event.player_index]
  if player.vehicle and
  player.vehicle.type == "locomotive" and
  global.honks.alt then
    playSoundAtEntity(global.honks.alt, player.vehicle)
  end
end)


-- Toggle manual/automatic control
script.on_event("toggle-train-control", function(event)
  local player = game.players[event.player_index]
  if player.vehicle then
    if player.vehicle.type == "locomotive" then
      player.vehicle.train.manual_mode = not player.vehicle.train.manual_mode
      if player.vehicle.train.manual_mode then
        player.create_local_flying_text{text={"gui-train.manual-mode"}, position=player.vehicle.position}
      else
        player.create_local_flying_text{text={"gui-train.automatic-mode"}, position=player.vehicle.position}
      end
    end
  end
end)

script.on_event(defines.events.on_train_changed_state, function(event)
  if global.honks[event.train.state] and
  global.honks[event.train.state][event.old_state] then
    findLocoToHonk(global.honks[event.train.state][event.old_state], event.train)
  end
end)