local M = {}

function M.get_player_data(player_index)
  if global.player_data == nil then
    global.player_data = {}
  end
  local player = game.players[player_index]
  if (player and player.valid) then
    if not global.player_data[player_index] then
      global.player_data[player_index] = {}
    end
    return global.player_data[player_index]
  end
end

function M.format_number(n, append_suffix)
  local amount = tonumber(n)
  if not amount then
    return n
  end
  local suffix = ""
  if append_suffix then
    local suffix_list = {
      ["T"] = 1000000000000,
      ["B"] = 1000000000,
      ["M"] = 1000000,
      ["k"] = 1000
    }
    local floor = math.floor
    local abs = math.abs
    for letter, limit in pairs (suffix_list) do
      if abs(amount) >= limit then
        amount = floor(amount/(limit/10))/10
        suffix = letter
        break
      end
    end
  end
  local formatted = amount
  local k
  local gsub = string.gsub
  while true do
    formatted, k = gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k == 0) then
      break
    end
  end
  return formatted..suffix
end

return M