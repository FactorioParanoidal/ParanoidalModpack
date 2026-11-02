-- Rain loop (Dynamic Rain rain-sound): one hidden programmable speaker per rain surface and listening force,
-- playing a seamless cyclic note in "surface" mode. Volume follows the ramp and the stage.
-- The note does not survive save/load, so speakers are recreated after a game is loaded (queue_all) and when a
-- player joins; while a restart is pending the surface waits one tick (blocked), then retries for 60 ticks.
local R = require("scripts.registry")

local M = {}
R.sound = M

local SOURCE = "prain-sound-source"
local INSTRUMENT, NOTE = 1, 1
local RETRY_TICKS = 60

local function st()
  local s = storage.sound
  if not s then
    s = { sources = {}, retry = {} }
    storage.sound = s
  end
  return s
end

local function destroy_source(source)
  local entity = source and source.entity
  if entity and entity.valid then
    local parameters = entity.parameters
    parameters.playback_volume = 0
    entity.parameters = parameters
    entity.destroy()
  end
end

local function destroy_surface(index)
  local s = st()
  local sources = s.sources[index]
  s.sources[index] = nil
  if sources then
    for _, source in pairs(sources) do destroy_source(source) end
  end
end

function M.stop(index)
  destroy_surface(index)
  local s = st()
  s.retry[index] = nil
  if s.pending then s.pending[index] = nil end
  if s.blocked then s.blocked[index] = nil end
end

function M.stop_all()
  local s = st()
  for index in pairs(s.sources) do destroy_surface(index) end
  s.pending, s.blocked, s.retry = nil, nil, {}
end

local function create_source(surface, player, volume)
  local entity = surface.create_entity { name = SOURCE, position = player.position, force = player.force }
  if not (entity and entity.valid) then return nil end
  entity.destructible = false
  entity.parameters = {
    playback_volume = volume,
    playback_mode = "surface",
    allow_polyphony = false,
    volume_controlled_by_signal = false,
  }
  if not entity.play_note(INSTRUMENT, NOTE) then
    entity.destroy()
    return nil
  end
  return { entity = entity, volume = volume }
end

function M.queue_all()
  st().pending = { all = true }
end

function M.queue(index)
  local s = st()
  s.pending = s.pending or {}
  s.pending[index] = true
end

function M.process_restarts()
  local s = st()
  local pending = s.pending
  s.blocked = pending
  s.pending = nil
  if not pending then return end
  local deadline = game.tick + RETRY_TICKS
  if pending.all then
    local surfaces = {}
    for index in pairs(s.sources) do surfaces[index] = true end
    for _, index in ipairs(R.surfaces.rain_indices()) do surfaces[index] = true end
    for index in pairs(s.sources) do destroy_surface(index) end
    for index in pairs(surfaces) do s.retry[index] = deadline end
    return
  end
  for index in pairs(pending) do
    if R.surfaces.is_rain(index) then
      destroy_surface(index)
      s.retry[index] = deadline
    else
      M.stop(index)
    end
  end
end

-- Drop speakers of surfaces that no longer rain (settings changed).
function M.reconcile()
  local s = st()
  for index in pairs(s.sources) do
    if not (storage.cfg.enabled and R.surfaces.is_rain(index)) then M.stop(index) end
  end
  for index in pairs(s.retry) do
    if not (storage.cfg.enabled and R.surfaces.is_rain(index)) then M.stop(index) end
  end
end

function M.sync(index, surface, players, volume)
  local s = st()
  local blocked = s.blocked
  if blocked and (blocked.all or blocked[index]) then return end
  if volume <= 0 or #players == 0 then
    if s.sources[index] then M.stop(index) end
    return
  end
  volume = math.floor(volume * 50 + 0.5) / 50 -- fewer parameter writes during the ramp
  local sources = s.sources[index]
  if not sources then
    sources = {}
    s.sources[index] = sources
  end
  local listeners = {}
  for i = 1, #players do
    local player = players[i]
    listeners[player.force_index] = player
  end
  for force_index, source in pairs(sources) do
    -- a force merge can move a speaker to another force
    if not listeners[force_index] or not source.entity.valid or source.entity.force_index ~= force_index then
      destroy_source(source)
      sources[force_index] = nil
    end
  end
  local deadline = s.retry[index]
  if deadline and game.tick > deadline then
    s.retry[index] = nil
    deadline = nil
  end
  for force_index, player in pairs(listeners) do
    local source = sources[force_index]
    if not source then
      sources[force_index] = create_source(surface, player, volume)
    else
      if source.volume ~= volume then
        local parameters = source.entity.parameters
        parameters.playback_volume = volume
        source.entity.parameters = parameters
        source.volume = volume
      end
      if deadline then source.entity.play_note(INSTRUMENT, NOTE) end
    end
  end
end

return M
