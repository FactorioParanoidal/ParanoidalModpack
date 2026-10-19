-- Map alerts and chat messages: what caught fire and why. Off with the "flo-map-alerts" setting.
local FO = require("scripts.registry")
local C = require("scripts.config")

local M = {}
FO.alerts = M

local ICONS = {
  fire = { type = "virtual", name = "signal-fire" },
  tank = { type = "item", name = "storage-tank" },
  cookoff = { type = "item", name = "explosives" },
  toxic = { type = "virtual", name = "signal-skull" },
}
local FALLBACK = { type = "virtual", name = "signal-alert" }

local function icon(kind)
  local signal = ICONS[kind]
  local exists = signal.type == "item" and prototypes.item[signal.name] or
      (signal.type == "virtual" and prototypes.virtual_signal[signal.name])
  return exists and signal or FALLBACK
end

local function enabled()
  return settings.global["flo-map-alerts"].value
end

local function gps(surface, pos)
  return string.format("[gps=%d,%d,%s]", math.floor(pos.x), math.floor(pos.y), surface.name)
end

-- Owners' players; for neutral/enemy property (ruins) everybody.
local function players_of(force)
  local list = force and force.valid and force.connected_players
  if not list or #list == 0 then list = game.connected_players end
  return list
end

-- One alert per kind and chunk per C.ALERT_COOLDOWN.
local function fresh(kind, surface, pos)
  local seen = storage.alert_seen
  if not seen then
    seen = { n = 0 }
    storage.alert_seen = seen
  end
  local tick = game.tick
  local key = string.format("%s:%d:%d:%d", kind, surface.index, math.floor(pos.x / 32), math.floor(pos.y / 32))
  local last = seen[key]
  if last and tick - last < C.ALERT_COOLDOWN then return false end
  seen[key] = tick
  seen.n = seen.n + 1
  if seen.n > 200 then -- drop expired entries
    local fresh_seen = { n = 0 }
    for k, t in pairs(seen) do
      if k ~= "n" and tick - t < C.ALERT_COOLDOWN then
        fresh_seen[k] = t
        fresh_seen.n = fresh_seen.n + 1
      end
    end
    storage.alert_seen = fresh_seen
  end
  return true
end

local function alert(players, target, kind, message)
  if not (target and target.valid) then return end
  local signal = icon(kind)
  for _, player in pairs(players) do
    player.add_custom_alert(target, signal, message, true)
  end
end

local function say(players, message)
  for _, player in pairs(players) do player.print(message) end
end

function M.explosion(rec, flame)
  if not enabled() or not fresh("fire", rec.surface, rec.position) then return end
  local players = players_of(rec.force)
  local message = { "flo-alert.fire", rec.what or { "flo-alert.unknown" }, rec.cause or { "flo-cause.unknown" } }
  alert(players, flame, "fire", message)
  if rec.catastrophe then
    say(players, { "", { "flo-alert.catastrophe", rec.what or { "flo-alert.unknown" } }, " ", gps(rec.surface, rec.position) })
  end
end

function M.tank(entity, ticks, cause)
  if not enabled() then return end
  local players = players_of(entity.force)
  local seconds = math.ceil(ticks / 60)
  alert(players, entity, "tank", { "flo-alert.tank", entity.localised_name, seconds })
  say(players, { "", { "flo-alert.tank-chat", entity.localised_name, cause or { "flo-cause.unknown" }, seconds }, " ",
    gps(entity.surface, entity.position) })
end

function M.tank_smoke(entity, ticks_left)
  if not enabled() then return end
  say(players_of(entity.force), { "", { "flo-alert.tank-smoke", math.ceil(ticks_left / 60) }, " ",
    gps(entity.surface, entity.position) })
end

function M.tank_saved(entity)
  if not enabled() then return end
  local players = players_of(entity.force)
  for _, player in pairs(players) do
    player.remove_alert { entity = entity }
  end
  say(players, { "", { "flo-alert.tank-saved", entity.localised_name }, " ", gps(entity.surface, entity.position) })
end

function M.cookoff(entity)
  if not enabled() or not fresh("cookoff", entity.surface, entity.position) then return end
  local players = players_of(entity.force)
  alert(players, entity, "cookoff", { "flo-alert.cookoff", entity.localised_name })
  say(players, { "", { "flo-alert.cookoff", entity.localised_name }, " ", gps(entity.surface, entity.position) })
end

function M.toxic(entity, cloud)
  if not enabled() or not fresh("toxic", entity.surface, entity.position) then return end
  local players = players_of(entity.force)
  alert(players, cloud, "toxic", { "flo-alert.toxic", entity.localised_name })
  say(players, { "", { "flo-alert.toxic", entity.localised_name }, " ", gps(entity.surface, entity.position) })
end

function M.trap(flame)
  if not enabled() or not (flame and flame.valid) then return end
  alert(game.connected_players, flame, "fire", { "flo-alert.trap" })
end

return M
