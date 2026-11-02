-- Connected players grouped by surface, rebuilt at most once per tick (Dynamic Rain player-cache), and the
-- per-player setting prain-show-rain mirrored into storage.hide (reading player settings every tick is costly).
local R = require("scripts.registry")

local M = {}
R.players = M

local EMPTY = {}
local cached_tick, cached

function M.invalidate()
  cached_tick, cached = nil, nil
end

function M.by_surface()
  if cached_tick ~= game.tick or not cached then
    local result = {}
    for _, player in pairs(game.connected_players) do
      local index = player.surface_index
      local list = result[index]
      if not list then
        list = {}
        result[index] = list
      end
      list[#list + 1] = player
    end
    cached, cached_tick = result, game.tick
  end
  return cached
end

function M.on_surface(index)
  return M.by_surface()[index] or EMPTY
end

function M.refresh_hide(player_index)
  storage.hide = storage.hide or {}
  local player = game.get_player(player_index)
  if not player then
    storage.hide[player_index] = nil
    return
  end
  local setting = settings.get_player_settings(player)["prain-show-rain"]
  storage.hide[player_index] = (setting and setting.value == false) or nil
end

function M.refresh_all_hide()
  storage.hide = {}
  for _, player in pairs(game.players) do M.refresh_hide(player.index) end
end

function M.hidden(player)
  local hide = storage.hide
  return hide ~= nil and hide[player.index] == true
end

return M
