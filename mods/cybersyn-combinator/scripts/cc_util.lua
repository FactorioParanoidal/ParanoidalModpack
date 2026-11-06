local cc_util = {}

local INVALID_VIRTUAL_SIGNALS = {
  ["signal-everything"] = true,
  ["signal-anything"] = true,
  ["signal-each"] = true
}

--- @param player_index PlayerIdentification?
--- @return table?
function cc_util.get_player_data(player_index)
  if not player_index then return end
  --- @type LuaPlayer?
  local player
  if type(player_index) == "number" or type(player_index) == "string" then
    player = game.get_player(player_index)
  else
    player = player_index --[[@as LuaPlayer]]
  end
  if not player or not player.valid then
    return nil
  end
  player_index = player.index
  if not storage.player_data then storage.player_data = {} end
  if not storage.player_data[player_index] then
    storage.player_data[player_index] = {}
  end
  return storage.player_data[player_index]
end

--- @param signal Signal|SignalID?
--- @return boolean
function cc_util.is_valid_output_signal(signal)
  if not signal or type(signal) ~= "table" then return false end
  if signal.signal then signal = signal.signal end
  if not signal.name or signal.name == "" then return false end
  if signal.type ~= "virtual" then return true end
  return not INVALID_VIRTUAL_SIGNALS[signal.name]
end

return cc_util
