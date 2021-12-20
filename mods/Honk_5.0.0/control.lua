local function buildHonkGroup(groupname)
  -- build a table in the form honkgroup[current_state][previous_state] = sound to play
  local group = {}

  local start = settings.global["honk-sound-start-"..groupname].value
  if start ~= "none" and game.is_valid_sound_path(start) then
    group[defines.train_state.on_the_path] = {
      -- play start honk if previous state was one of the below
      [defines.train_state.path_lost] = start,
      [defines.train_state.no_schedule] = start,
      [defines.train_state.no_path] = start,
      [defines.train_state.wait_signal] = start,
      [defines.train_state.wait_station] = start,
      [defines.train_state.manual_control_stop] = start,
      [defines.train_state.manual_control] = start
    }
    -- definition for auto-selected keypress starting honk
    group.manual_start = start
  end

  local lost = settings.global["honk-sound-lost-"..groupname].value
  if lost ~= "none" and game.is_valid_sound_path(lost) then
    group[defines.train_state.path_lost] = {
      -- play lost honk if previous state was one of the below
      [defines.train_state.on_the_path] = lost,
      [defines.train_state.arrive_signal] = lost,
      [defines.train_state.arrive_station] = lost
    }
    group[defines.train_state.manual_control_stop] = {
      -- play lost honk if previous state was one of the below
      [defines.train_state.on_the_path] = lost,
      [defines.train_state.arrive_signal] = lost,
      [defines.train_state.arrive_station] = lost
    }
    -- definition for auto-selected keypress braking honk
    group.manual_stop = lost
  end

  local station = settings.global["honk-sound-station-"..groupname].value
  if station ~= "none" and game.is_valid_sound_path(station) then
    group[defines.train_state.arrive_station] = {
      -- play station honk only if previous state was normal pathing
      [defines.train_state.on_the_path] = station
    }
    -- fallback definition for auto-selected keypress braking honk
    group.manual_stop = group.manual_stop or station
  end

  local signal = settings.global["honk-sound-signal-"..groupname].value
  if signal ~= "none" and game.is_valid_sound_path(signal) then
    group[defines.train_state.arrive_signal] = {
      -- play signal honk only if previous state was normal pathing
      [defines.train_state.on_the_path] = signal
    }
    -- second fallback definition for auto-selected keypress braking honk
    group.manual_stop = group.manual_stop or signal
  end

  local manual = settings.global["honk-sound-manual-"..groupname].value
  if manual == "auto" then
    group.auto = true
  elseif manual ~= "none" and game.is_valid_sound_path(manual) then
    -- not auto, use this value
    group.manual = manual
  end

  local manual_alt = settings.global["honk-sound-manual-alt-"..groupname].value
  if manual_alt ~= "none" and game.is_valid_sound_path(manual_alt) then
    group.alt = manual_alt
  end

  -- Extract list of locomotives to apply this sound to
  local namelist = settings.global["honk-sound-locos-"..groupname].value
  group.names = {}
  if namelist and namelist ~= "" then
    for name in string.gmatch(namelist, "([^,]+)") do
      group.names[name] = true
      group.names[name.."-mu"] = true  -- Compatibility with Multiple Unit Train Control
    end
  end

  return group
end


local function buildHonks()
  -- Clear existing maps and rebuild
  global.honks = nil  -- clear old table
  global.honkgroups = {}

  -- Make a list of the honk groups mapping each train state to a sound name
  local groups = {}
  local grouplist = settings.startup["honk-groups"].value
  if grouplist and grouplist ~= "" then
    for group in string.gmatch(grouplist, "([^,]+)") do
      if group ~= "none" then
        global.honkgroups[group] = buildHonkGroup(group)
      end
    end
  end

  local default_group = settings.global["honk-default-sound"].value

  local namelist = settings.global["honk-sound-locos-none"].value
  global.honkgroups["none"] = {names = {}}
  if namelist and namelist ~= "" then
    for name in string.gmatch(namelist, "([^,]+)") do
      global.honkgroups["none"].names[name] = true
      global.honkgroups["none"].names[name.."-mu"] = true  -- Compatibility with Multiple Unit Train Control
    end
  end

  -- Make a list of locomotive entities mapping each to a honk group name
  global.honkmap = {}
  for name, _ in pairs(game.get_filtered_entity_prototypes{{filter="type",type="locomotive"}}) do
    -- check if this locomotive is listed for any of the groups
    for groupname, group in pairs(global.honkgroups) do
      if group.names[name] then
        global.honkmap[name] = groupname
      end
    end
    global.honkmap[name] = global.honkmap[name] or default_group
  end

  log("Honk Global Map updated:\n"..serpent.block(global))
end

script.on_configuration_changed(buildHonks)
script.on_init(buildHonks)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if string.find(event.setting, "honk") then
    buildHonks()
  end
end)

function playSoundAtEntity(sound, entity)
  -- Play sound
  if sound and entity then
    entity.surface.play_sound{path = sound, position = entity.position}
  end
end

-- Find loco(s) to emit honks in train
-- A stationary train will honk at front- and rear-facing locos if both are present
function findLocoToHonk(train)
  if train.speed >= 0 and #train.locomotives.front_movers > 0 then
    return train.locomotives.front_movers[1]
  end
  if train.speed <= 0 and #train.locomotives.back_movers > 0 then
    return train.locomotives.back_movers[#train.locomotives.back_movers]
  end
end

-- Manual honk
script.on_event("honk", function(event)
  local player = game.players[event.player_index]
  if player.vehicle and player.vehicle.type == "locomotive" then
    local honktype = global.honkmap[player.vehicle.name]
    if honktype then
      local honkgroup = global.honkgroups[honktype]
      if honkgroup.auto then
        if player.vehicle.train.speed == 0 then
          if honkgroup.manual_start then
            playSoundAtEntity(honkgroup.manual_start, player.vehicle)
          end
        else
          if honkgroup.manual_stop then
            playSoundAtEntity(honkgroup.manual_stop, player.vehicle)
          end
        end
      else -- not automatic mode, play the player-selected sound
        if honkgroup.manual then
          playSoundAtEntity(honkgroup.manual, player.vehicle)
        end
      end
    end
  end
end)

-- Manual alt honk
script.on_event("honk-alt", function(event)
  local player = game.players[event.player_index]
  if player.vehicle and player.vehicle.type == "locomotive" then
    local loco = player.vehicle
    local honktype = global.honkmap[loco.name]
    if honktype then
      local honkgroup = global.honkgroups[honktype]
      if honkgroup and honkgroup.alt then
        playSoundAtEntity(honkgroup.alt, player.vehicle)
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
      if player.vehicle.train.manual_mode then
        player.create_local_flying_text{text={"gui-train.manual-mode"}, position=player.vehicle.position}
      else
        player.create_local_flying_text{text={"gui-train.automatic-mode"}, position=player.vehicle.position}
      end
    end
  end
end)

-- Play sound when train changes state
function onTrainChangedState(event)
  local entity = findLocoToHonk(event.train)
  if entity then
    local honktype = global.honkmap[entity.name]
    if honktype then
      local honkgroup = global.honkgroups[honktype]
      if honkgroup and honkgroup[event.train.state] and honkgroup[event.train.state][event.old_state] then
        playSoundAtEntity(honkgroup[event.train.state][event.old_state], entity)
      end
    end
  end
end
script.on_event(defines.events.on_train_changed_state, onTrainChangedState)

------------------------------------------------------------------------------------
--                    FIND LOCAL VARIABLES THAT ARE USED GLOBALLY                 --
--                              (Thanks to eradicator!)                           --
------------------------------------------------------------------------------------
--[[setmetatable(_ENV,{
  __newindex=function (self,key,value) --locked_global_write
    error('\n\n[ER Global Lock] Forbidden global *write*:\n'
      .. serpent.line{key=key or '<nil>',value=value or '<nil>'}..'\n')
    end,
  __index   =function (self,key) --locked_global_read
    error('\n\n[ER Global Lock] Forbidden global *read*:\n'
      .. serpent.line{key=key or '<nil>'}..'\n')
    end ,
  })
--]]
