-- Crash counters per force: total and per minute for the last hour.
local M = {}

local MINUTE, HOUR_MINUTES = 3600, 60

function M.add(force_index)
  storage.crashes[force_index] = (storage.crashes[force_index] or 0) + 1
  local minute = math.floor(game.tick / MINUTE)
  local bins = storage.recent[force_index]
  if not bins then
    bins = {}
    storage.recent[force_index] = bins
  end
  local slot = minute % HOUR_MINUTES + 1
  local bin = bins[slot]
  if bin and bin[1] == minute then
    bin[2] = bin[2] + 1
  else
    bins[slot] = {minute, 1}
  end
end

function M.total(force_index)
  return storage.crashes[force_index] or 0
end

function M.last_hour(force_index)
  local bins = storage.recent[force_index]
  if not bins then return 0 end
  local oldest, sum = math.floor(game.tick / MINUTE) - HOUR_MINUTES, 0
  for _, bin in pairs(bins) do
    if bin[1] > oldest then sum = sum + bin[2] end
  end
  return sum
end

return M
