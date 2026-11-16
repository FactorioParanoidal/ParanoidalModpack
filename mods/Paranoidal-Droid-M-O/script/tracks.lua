-- The engineer is WALL-E here: walking on the ground he picks up dirt, and stepping onto the paving he leaves muddy
-- prints until it's worn off. Д-ОК follows the prints, and goes for the engineer himself while he is still dirty.
local shared = require("shared")
local paving = require("script.paving")
local state = require("script.state")

local tracks = {}

-- Dirt is 0..100 (shown as his scanner's percentage): a tile of ground adds, a print on the paving wears it off.
local dirt_per_ground_tile = 4
local dirt_per_print = 8
local dirt_per_vehicle_print = 6
tracks.max_dirt = 100

local settings_cache = {}
local tracks_enabled = function()
  local value = settings_cache.tracks
  if value == nil then
    value = settings.global[shared.settings.tracks].value
    settings_cache.tracks = value
  end
  return value
end

tracks.get = function(player_index)
  local players = state.s.players
  local record = players[player_index]
  if not record then
    record = {dirt = 0}
    players[player_index] = record
  end
  return record
end

tracks.dirt = function(player_index)
  local record = state.s.players[player_index]
  return record and record.dirt or 0
end

tracks.clean = function(player_index, amount)
  local record = tracks.get(player_index)
  record.dirt = amount and math.max(0, record.dirt - amount) or 0
  return record.dirt
end

-- Whether any of a force's docks is on a surface: prints are left only where a Д-ОК could clean them.
local has_docks = function(surface_index, force_index)
  local counts = state.s.dock_counts[surface_index]
  return counts and (counts[force_index] or 0) > 0
end

local vehicle_types = {car = true, ["spider-vehicle"] = true}

tracks.on_player_changed_position = function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local vehicle = player.vehicle
  local body
  if vehicle then
    if not vehicle_types[vehicle.type] then return end
    body = vehicle
  else
    body = player.character
  end
  if not (body and body.valid) then return end
  local position = body.position
  local tx, ty = math.floor(position.x), math.floor(position.y)
  local record = tracks.get(player.index)
  -- Remote view and the like move the player, not the body: only a new tile under the body counts.
  if record.tx == tx and record.ty == ty and record.surface == body.surface_index then return end
  record.tx, record.ty, record.surface = tx, ty, body.surface_index
  local surface = body.surface
  if not paving.is_paved(surface.get_tile(tx, ty).name) then
    record.dirt = math.min(tracks.max_dirt, record.dirt + dirt_per_ground_tile)
    return
  end
  if record.dirt <= 0 then return end
  if tracks_enabled() and has_docks(surface.index, player.force_index) then
    surface.create_decoratives
    {
      check_collision = false,
      decoratives = {{name = vehicle and shared.mud or shared.footprints, position = {x = tx, y = ty}, amount = 1}}
    }
    -- Fresh prints are noticed at once, not when the scan next comes round.
    if tracks.notice then
      tracks.notice(surface.index, player.force_index, tx, ty)
    end
  end
  record.dirt = math.max(0, record.dirt - (vehicle and dirt_per_vehicle_print or dirt_per_print))
end

tracks.on_setting_changed = function(event)
  if event.setting == shared.settings.tracks then
    settings_cache.tracks = nil
  end
end

tracks.on_player_removed = function(event)
  state.s.players[event.player_index] = nil
end

return tracks
