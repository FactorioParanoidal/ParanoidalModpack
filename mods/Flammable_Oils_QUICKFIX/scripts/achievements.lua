-- Achievements of the fork (prototypes in data-updates.lua). unlock_achievement only acts for
-- the local player, so calling it for every peer's player is multiplayer-safe.
local FO = require("scripts.registry")

local M = {}
FO.ach = M

---Award to connected players within radius of a position.
function M.near(name, surface, pos, radius)
  if not prototypes.achievement[name] then return end
  local index, r2 = surface.index, radius * radius
  for _, player in pairs(game.connected_players) do
    if player.surface.index == index then
      local p = player.position
      local dx, dy = p.x - pos.x, p.y - pos.y
      if dx * dx + dy * dy <= r2 then player.unlock_achievement(name) end
    end
  end
end

function M.player(name, player)
  if prototypes.achievement[name] and player.valid then player.unlock_achievement(name) end
end

return M
