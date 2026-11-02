-- Rain of paranoidal-rain slows the hazards down (it does not put them out: only fire safety turrets do):
-- burning storage tanks, the fuse through pipes and ammunition cook-off take slowdown(surface) times longer.
-- Asked through the remote "paranoidal-rain" (absent mod or no rain: 1), cached per surface and tick.
local FO = require("scripts.registry")

local M = {}
FO.weather = M

local cache_tick, cache = -1, {}

function M.slowdown(surface)
  if not remote.interfaces["paranoidal-rain"] then return 1 end
  local tick = game.tick
  if cache_tick ~= tick then cache_tick, cache = tick, {} end
  local index = surface.index
  local value = cache[index]
  if value == nil then
    value = remote.call("paranoidal-rain", "hazard_slowdown", index) or 1
    if type(value) ~= "number" or value < 1 then value = 1 end
    cache[index] = value
  end
  return value
end

return M
