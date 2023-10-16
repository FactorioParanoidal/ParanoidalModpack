local event = require("__flib__.event")
local migration = require("__flib__.migration")

local constants = require("constants")

local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local preprocessors = require("scripts.preprocessors")
local sensors = require("scripts.sensors")
local stats_gui = require("scripts.stats-gui")

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

event.on_init(function()
  global.players = {}
  global.research_progress_samples = {}
  global.research_progress_strings = {}
  for i, player in pairs(game.players) do
    player_data.init(i)
    player_data.refresh(player, global.players[i])
  end
end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations) then
    global.research_progress_samples = {}
    for i, player in pairs(game.players) do
      player_data.refresh(player, global.players[i])
    end
  end
end)

-- PLAYER

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  player_data.init(e.player_index)
  player_data.refresh(player, global.players[e.player_index])
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.register({
  defines.events.on_player_display_resolution_changed,
  defines.events.on_player_display_scale_changed,
}, function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  stats_gui.set_width(player, player_table)
end)

-- SETTINGS

event.on_runtime_mod_setting_changed(function(e)
  if string.sub(e.setting, 1, 8) == "statsgui" then
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    if
      e.setting == "statsgui-single-line"
      or e.setting == "statsgui-adjust-for-fps-ups"
      or e.setting == "statsgui-adjust-for-clock"
    then
      -- recreate the GUI to change the frame direction and/or padding
      player_data.refresh(player, player_table)
    else
      player_data.update_settings(player, player_table)
    end
  end
end)

-- TICK

-- update stats once per second
event.on_nth_tick(60, function()
  -- run preprocessors
  for _, preprocessor in pairs(preprocessors) do
    preprocessor()
  end
  -- update GUIs
  for _, player in pairs(game.connected_players) do
    local player_table = global.players[player.index]
    stats_gui.update(player, player_table)
  end
end)

-- -----------------------------------------------------------------------------
-- REMOTE INTERFACE

remote.add_interface("StatsGui", {
  add_preprocessor = function(interface, func)
    -- create a dummy function that calls the specified remote interface and returns what it returns
    preprocessors[#preprocessors + 1] = function()
      return remote.call(interface, func)
    end
  end,
  add_sensor = function(interface, func)
    -- create a dummy function that calls the specified remote interface and returns what it returns
    sensors[#sensors + 1] = function(player)
      return remote.call(interface, func, player)
    end
  end,
  version = function()
    return constants.interface_version
  end,
})
