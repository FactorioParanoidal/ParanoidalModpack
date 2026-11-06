local CybersynCombinator = require "scripts.combinator"

if not storage.player_data then return end

for _, player_data in pairs(storage.player_data) do
  if player_data and player_data.state and player_data.state.combinator then
    local combi = player_data.state.combinator
    setmetatable(combi, { __index = CybersynCombinator })
    combi:ensure_metatable()
  end
end
