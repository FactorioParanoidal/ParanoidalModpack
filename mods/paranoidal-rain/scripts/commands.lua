-- /prain status | rain [minutes] | dry [minutes] | stage <name> [minutes] | strike
-- Changing the weather: anyone in single player, admins in multiplayer.
local R = require("scripts.registry")

local M = {}

local STAGE_NAMES = { drizzle = true, rain = true, heavy = true, storm = true, monsoon = true }

local function words(text)
  local list = {}
  for word in string.gmatch(text or "", "%S+") do list[#list + 1] = string.lower(word) end
  return list
end

local function duration(value)
  local minutes = tonumber(value)
  if not minutes or minutes ~= minutes or minutes < 0.1 or minutes > 10080 then return nil end
  return math.floor(minutes * 3600 + 0.5)
end

local function may_change(player)
  return player.admin or not game.is_multiplayer()
end

local function status(player, index, name)
  local w = storage.weather and storage.weather[index]
  if not w then return end
  local seconds = math.ceil(w.tLeft / 60)
  local stage = w.phase == "wet" and { "prain-stage." .. (w.stage or "rain") } or { "prain-command.dry" }
  player.print({ "prain-command.status", stage, name, math.floor(seconds / 60), seconds % 60 })
  local s = storage.stats or {}
  player.print({ "prain-command.stats", s.strikes or 0, s.fires_lit or 0, s.fires_quenched or 0, s.brownouts or 0,
    s.radar_outages or 0, s.kills or 0 })
end

local function run(command)
  local player = command.player_index and game.get_player(command.player_index)
  if not player then return end
  local list = words(command.parameter)
  local action = list[1] or "status"
  local index = player.surface_index
  local name = R.surfaces.name(index) or player.surface.name

  if not storage.cfg.enabled then
    player.print({ "prain-command.disabled" })
    return
  end
  if not R.surfaces.is_rain(index) then
    player.print({ "prain-command.unsupported", name })
    return
  end
  if action == "status" then
    status(player, index, name)
    return
  end
  if not may_change(player) then
    player.print({ "prain-command.admin-only" })
    return
  end

  if action == "rain" or action == "dry" then
    local phase = action == "rain" and "wet" or "dry"
    if R.weather.request(index, phase, duration(list[2])) then
      player.print({ "prain-command.started", { "prain-command." .. action }, name })
    else
      player.print({ "prain-command.already", { "prain-command." .. action }, name })
    end
  elseif action == "stage" and STAGE_NAMES[list[2] or ""] then
    R.weather.request(index, "wet", duration(list[3]), list[2])
    player.print({ "prain-command.started", { "prain-stage." .. list[2] }, name })
  elseif action == "strike" then
    local p = player.position
    local angle = math.random() * 2 * math.pi
    local distance = 15 + math.random() * 15
    R.lightning.strike(player.surface, { x = p.x + math.cos(angle) * distance, y = p.y + math.sin(angle) * distance },
      { visible = true, players = R.players.on_surface(index) })
  else
    player.print({ "prain-command.usage" })
  end
end

function M.register()
  commands.add_command("prain", { "prain-command.help" }, run)
end

return M
