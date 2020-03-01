-- TRAIN_STATE = {
  -- [defines.train_state.on_the_path] = "on_the_path",
  -- [defines.train_state.path_lost] = "path_lost",
  -- [defines.train_state.no_schedule] = "no_schedule",
  -- [defines.train_state.no_path] = "no_path",
  -- [defines.train_state.arrive_signal] = "arrive_signal",
  -- [defines.train_state.wait_signal] = "wait_signal",
  -- [defines.train_state.arrive_station] = "arrive_station",
  -- [defines.train_state.wait_station] = "wait_station",
  -- [defines.train_state.manual_control_stop] = "manual_control_stop",
  -- [defines.train_state.manual_control] = "manual_control"
  -- -- [defines.train_state.stop_for_auto_control] = "stop_for_auto_control"
-- }

HONK_OPTIONS_MAP = {
  ["honk-single"] = "honk-single",
  ["honk-double"] = "honk-double",
  ["none"] = false
}

BRAKING_HONK = "honk-single"
STARTING_HONK = "honk-double"

HONK_ON_START = HONK_OPTIONS_MAP[settings.global["honk-sound-start"].value]
HONK_FOR_STATION = HONK_OPTIONS_MAP[settings.global["honk-sound-station"].value]
HONK_FOR_SIGNAL = HONK_OPTIONS_MAP[settings.global["honk-sound-signal"].value]
HONK_FOR_LOST = HONK_OPTIONS_MAP[settings.global["honk-sound-lost"].value]

-- Convert seconds into ticks
HONK_COOLDOWN = settings.global["honk-cooldown"].value * 60
-- Convert to 0.0-1.0 float
HONK_VOLUME = settings.global["honk-volume"].value * 0.01
-- Are we using iHonk2.0?
HONK_ADVANCED = settings.global["honk-advanced"].value
-- Max range at which honks are audible
HONK_RANGE = settings.global["honk-range"].value

local function init_global()
  global = global or {}
  global.honks = {}
end

-- Wipe cooldown table when config changes, in case of any data leaks
script.on_configuration_changed(init_global)
script.on_init(init_global)

-- Detect setting changes during session
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  HONK_COOLDOWN = settings.global["honk-cooldown"].value * 60
  HONK_VOLUME = settings.global["honk-volume"].value * 0.01
  HONK_ADVANCED = settings.global["honk-advanced"].value
  HONK_RANGE = settings.global["honk-range"].value
  HONK_ON_START = HONK_OPTIONS_MAP[settings.global["honk-sound-start"].value]
  HONK_FOR_STATION = HONK_OPTIONS_MAP[settings.global["honk-sound-station"].value]
  HONK_FOR_SIGNAL = HONK_OPTIONS_MAP[settings.global["honk-sound-signal"].value]
  HONK_FOR_LOST = HONK_OPTIONS_MAP[settings.global["honk-sound-lost"].value]
end)

-- Old style honk, plays sound at loco
function playSoundAtEntity(sound, entity)
  entity.surface.play_sound
  {
    path = sound,
    position = entity.position,
    volume_modifier = HONK_VOLUME
  }
end

-- Loop over each player and play sound at volume proportional to distance
function playSoundAtEachPlayer(sound, entity)
  for i, player in pairs(game.players) do
    if player.surface == entity.surface then
      -- Get chamfer distance - better than Manhattan but cheaper than Euclidean
      local x = math.abs(entity.position.x - player.position.x)
      local y = math.abs(entity.position.y - player.position.y)
      local distance = (math.max(x, y) * 5 + math.min(x, y) * (2)) / 5
      if distance < HONK_RANGE then
        player.play_sound
        {
          path = sound,
          volume_modifier = (1 - (distance / HONK_RANGE)) * HONK_VOLUME
        }
      end
    end
  end
end

function attemptHonk(sound, entity, tick)
  global.honks[entity.unit_number] = global.honks[entity.unit_number] or {}
  if global.honks[entity.unit_number][sound]
    and tick - global.honks[entity.unit_number][sound] < HONK_COOLDOWN then
    -- Cooldown not yet reached, do nothing
  else
    -- Do a honking
    if HONK_ADVANCED then
      playSoundAtEachPlayer(sound, entity)
    else
      playSoundAtEntity(sound, entity)
    end
    -- Set cooldown
    global.honks[entity.unit_number][sound] = tick
  end
end

-- Find loco(s) to emit honks in train
function findLocoToHonk(sound, train, tick)
  if train.speed >= 0 and #train.locomotives.front_movers > 0 then
    attemptHonk(sound, train.locomotives.front_movers[1], tick)
  end
  if train.speed <= 0 and #train.locomotives.back_movers > 0 then
    attemptHonk(sound, train.locomotives.back_movers[#train.locomotives.back_movers], tick)
  end 
end

-- Manual honk
script.on_event("honk", function(event)
  local player = game.players[event.player_index]
  if player.vehicle then
    if player.vehicle.type == "locomotive" and player.vehicle.train.manual_mode then
      if player.vehicle.train.speed == 0 then
        -- Train not moving, using starting honk
        if HONK_ADVANCED then
          playSoundAtEachPlayer(STARTING_HONK, player.vehicle)
        else
          playSoundAtEntity(STARTING_HONK, player.vehicle)
        end
      else
        -- Train moving, use braking honk
        if  HONK_ADVANCED then
          playSoundAtEachPlayer(BRAKING_HONK, player.vehicle)
        else
          playSoundAtEntity(BRAKING_HONK, player.vehicle)
        end
      end
    end
  end
end)

-- Toggle manual/automatic control
script.on_event("toggle-train-control", function(event)
  local player = game.players[event.player_index]
  if player.vehicle then
    if player.vehicle.type == "locomotive" then
      player.vehicle.train.manual_mode = not player.vehicle.train.manual_mode
    end
  end
end)

script.on_event(defines.events.on_train_changed_state, function(event)
  if HONK_ON_START and event.train.state == defines.train_state.on_the_path then
    -- Entering travelling state, i.e. starting to move
    findLocoToHonk(HONK_ON_START, event.train, event.tick)
  elseif HONK_FOR_STATION and event.train.state == defines.train_state.arrive_station then
    -- Beginning to brake before arriving at station
    findLocoToHonk(HONK_FOR_STATION, event.train, event.tick)
  elseif HONK_FOR_SIGNAL and event.train.state == defines.train_state.arrive_signal then
    -- Beginning to brake for signal
    findLocoToHonk(HONK_FOR_SIGNAL, event.train, event.tick)
  elseif HONK_FOR_LOST and event.train.state == defines.train_state.path_lost then
    -- Train is lost, begin mournful honking
    findLocoToHonk(HONK_FOR_LOST, event.train, event.tick)
  end
end)

-- Wipe cooldown entry from global table, no longer needed
on_entity_removed = function (event)
  if event.entity.type == "locomotive" then
    global.honks[event.entity.unit_number] = nil
  end
end

script.on_event(defines.events.on_pre_player_mined_item, on_entity_removed)
script.on_event(defines.events.on_robot_pre_mined, on_entity_removed)
script.on_event(defines.events.on_entity_died, on_entity_removed)