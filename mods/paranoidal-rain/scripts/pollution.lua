-- Rain washes pollution out of the air (Dynamic Rain pollution.lua): every chunk of the surface is visited once a
-- minute in random order (a shuffled list, a cursor), at most prain-pollution-chunks-per-tick per tick, and loses up
-- to prain-pollution-cleanup-per-minute. The chunk list is built when the first rain needs it and kept up to date
-- by on_chunk_generated. Raises on_rain_pollution_cleaned for other mods.
local R = require("scripts.registry")
local events = require("scripts.events")

local M = {}
R.pollution = M

local random, floor, min = math.random, math.floor, math.min
local INTERVAL = 3600

local function add_chunk(st, x, y)
  local chunks = st.chunks
  local n = #chunks + 1
  chunks[n] = { x = x, y = y }
  if st.cursor > n then st.cursor = 1 end
  local swap = random(st.cursor, n)
  chunks[n], chunks[swap] = chunks[swap], chunks[n]
end

local function build(index)
  local surface = game.surfaces[index]
  local st = { chunks = {}, cursor = 1, quota = 0 }
  if surface then
    for chunk in surface.get_chunks() do add_chunk(st, chunk.x, chunk.y) end
  end
  storage.pollution = storage.pollution or {}
  storage.pollution[index] = st
  return st
end

local function next_chunk(st)
  local chunks = st.chunks
  local n = #chunks
  if st.cursor > n then st.cursor = 1 end
  local cursor = st.cursor
  local pick = random(cursor, n)
  chunks[cursor], chunks[pick] = chunks[pick], chunks[cursor]
  st.cursor = cursor + 1
  return chunks[cursor]
end

function M.on_chunk_generated(index, position)
  local st = storage.pollution and storage.pollution[index]
  if st then add_chunk(st, position.x, position.y) end
end

function M.reconcile()
  if not storage.pollution then return end
  if storage.cfg.pollution_cleanup <= 0 then
    storage.pollution = nil
    return
  end
  for index in pairs(storage.pollution) do
    if not R.surfaces.is_rain(index) then storage.pollution[index] = nil end
  end
end

function M.forget(index)
  if storage.pollution then storage.pollution[index] = nil end
end

function M.on_tick(index, surface)
  local per_minute = R.weather.option(index, "pollution_cleanup_per_minute") or storage.cfg.pollution_cleanup
  if per_minute <= 0 then return end
  local st = storage.pollution and storage.pollution[index] or build(index)
  local count = #st.chunks
  if count == 0 then return end
  st.quota = st.quota + count / INTERVAL
  if st.quota < 1 then return end
  local desired = floor(st.quota)
  local limit = R.weather.option(index, "pollution_max_chunks_per_tick") or storage.cfg.pollution_chunks
  local process = min(desired, limit)
  st.quota = st.quota - desired
  local per_chunk = per_minute * desired / process
  local cleaned
  for _ = 1, process do
    local chunk = next_chunk(st)
    local position = { x = chunk.x * 32 + 16, y = chunk.y * 32 + 16 }
    local current = surface.get_pollution(position)
    if current > 0 then
      local removed = min(current, per_chunk)
      surface.pollute(position, -removed, "prain-pollution-cleaner")
      cleaned = cleaned or {}
      cleaned[#cleaned + 1] = { chunk_position = { x = chunk.x, y = chunk.y }, pollution_before = current,
        pollution_removed = removed, pollution_after = current - removed }
    end
  end
  if cleaned then
    script.raise_event(events.on_rain_pollution_cleaned, { surface_index = index, chunks = cleaned })
  end
end

return M
