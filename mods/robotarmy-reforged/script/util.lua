-- Small helpers shared by the control modules.
local cache = require("script.settings_cache")

local util = {}

local sqrt = math.sqrt

function util.distance(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return sqrt(dx * dx + dy * dy)
end

function util.distance2(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return dx * dx + dy * dy
end

function util.copy_position(p)
  return {x = p.x, y = p.y}
end

--- Debug line in factorio-current.log; arguments are only formatted when debug is on.
function util.debug(fmt, ...)
  if cache.debug then
    log(string.format(fmt, ...))
  end
end

--- Squad status message to a force (can be turned off in map settings).
function util.squad_message(force, message)
  if cache.squad_messages and force.valid then
    force.print(message)
  end
end

--- Rich text link to a map position.
function util.gps(position, surface)
  return string.format("[gps=%d,%d,%s]", position.x, position.y, surface.name)
end

--- Alert (with map marker) for every connected player of the force, pointing at `entity`.
--- An older alert with the same icon is replaced.
function util.alert(force, entity, icon, message)
  if not (entity and entity.valid and force.valid) then return end
  for _, player in pairs(force.connected_players) do
    player.remove_alert({type = defines.alert_type.custom, icon = icon})
    player.add_custom_alert(entity, icon, message, true)
  end
end

--- Removes the alerts with this icon from every player of the force.
function util.clear_alert(force, icon)
  if not force.valid then return end
  for _, player in pairs(force.connected_players) do
    player.remove_alert({type = defines.alert_type.custom, icon = icon})
  end
end

util.ICON_QRF = {type = "virtual", name = "signal-droid-alive-count"}
util.ICON_NO_ASSEMBLER = {type = "item", name = "droid-assembling-machine"}
util.ICON_STUCK = {type = "item", name = "droid-selection-tool"}

--- First valid member of a squad (for alerts and labels).
function util.leader(squad)
  for _, member in pairs(squad.members) do
    if member.valid then return member end
  end
end

--- Whether a connected player on that surface is close enough to see the position.
function util.seen_by_player(surface_index, position, radius)
  local r2 = radius * radius
  for _, player in pairs(game.connected_players) do
    if player.surface_index == surface_index and util.distance2(player.position, position) < r2 then
      return true
    end
  end
  return false
end

return util
