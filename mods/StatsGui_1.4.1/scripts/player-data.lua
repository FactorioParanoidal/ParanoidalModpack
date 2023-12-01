local player_data = {}

local constants = require("constants")

local stats_gui = require("scripts.stats-gui")

function player_data.init(player_index)
  global.players[player_index] = {
    settings = {},
  }
end

function player_data.update_settings(player, player_table)
  local mod_settings = player.mod_settings
  local settings = {
    adjust_for_clock = mod_settings["statsgui-adjust-for-clock"].value,
    adjust_for_ups = mod_settings["statsgui-adjust-for-fps-ups"].value,
    single_line = mod_settings["statsgui-single-line"].value,
  }

  for _, sensor_data in pairs(constants.builtin_sensors) do
    local sensor_name = sensor_data.name
    settings["show_" .. sensor_name] = mod_settings["statsgui-show-sensor-" .. sensor_name].value
  end

  player_table.settings = settings
end

function player_data.refresh(player, player_table)
  stats_gui.destroy(player_table)

  player_data.update_settings(player, player_table)

  stats_gui.build(player, player_table)
end

return player_data
