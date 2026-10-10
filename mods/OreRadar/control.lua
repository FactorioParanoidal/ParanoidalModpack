-- OreRadar 0.0.3 (Factorio 1.1): one random resource chunk per completed scan.
local WORK_PER_TICK = 8
local SCANS_PER_TICK = 4
local on_tick

local function queue()
  return {first = 1, last = 0}
end

local function push(q, value)
  q.last = q.last + 1
  q[q.last] = value
end

local function pop(q)
  local value = q[q.first]
  q[q.first] = nil
  q.first = q.first + 1
  if q.first > q.last then q.first, q.last = 1, 0 end
  return value
end

local function pending()
  return storage.work and (storage.work.last > 0 or storage.scans.last > 0)
end

local function wake()
  script.on_event(defines.events.on_tick, on_tick)
end

local function key(p)
  return p.x .. ":" .. p.y
end

local function area(p)
  return {{p.x * 32, p.y * 32}, {p.x * 32 + 32, p.y * 32 + 32}}
end

local function remove_chunk(index, position)
  local k = key(position)
  local i = index.lookup[k]
  if not i then return end
  local last = index.chunks[#index.chunks]
  index.chunks[i] = last
  index.lookup[key(last)] = i
  index.chunks[#index.chunks] = nil
  index.lookup[k] = nil
end

local function get_index(surface_index)
  local index = storage.surfaces[surface_index]
  if not index then
    index = {chunks = {}, lookup = {}, ready = true, pending = 0}
    storage.surfaces[surface_index] = index
  end
  return index
end

local function index_chunk(surface, position)
  if not surface.is_chunk_generated(position) then return end
  local index = get_index(surface.index)
  if surface.count_entities_filtered{area = area(position), type = "resource", limit = 1} > 0 then
    local k = key(position)
    if not index.lookup[k] then
      index.chunks[#index.chunks + 1] = {x = position.x, y = position.y}
      index.lookup[k] = #index.chunks
    end
  else
    remove_chunk(index, position)
  end
end

local function work_step()
  local q = storage.work
  local job = q[q.first]
  local surface = game.get_surface(job.surface_index)
  if not surface then pop(q); return end
  -- Clearing a surface invalidates work for its previous resource index.
  if job.index and storage.surfaces[job.surface_index] ~= job.index then pop(q); return end
  if job.iterator then
    if not job.iterator.valid then job.index.ready = true; pop(q); return end
    local position = job.iterator()
    if position then
      index_chunk(surface, position)
    else
      job.index.ready = true
      pop(q)
    end
  elseif job.positions then
    local index = storage.surfaces[job.surface_index]
    if index then remove_chunk(index, job.positions[job.cursor]) end
    job.cursor = job.cursor + 1
    if job.cursor > #job.positions then pop(q) end
  else
    index_chunk(surface, job.position)
    job.index.pending = job.index.pending - 1
    pop(q)
  end
end

local function scan_step()
  local radar = pop(storage.scans)
  if not radar.valid then return end
  local surface = radar.surface
  local index = storage.surfaces[surface.index]
  if index and (not index.ready or (#index.chunks == 0 and index.pending > 0)) then
    -- Retain paid scans during indexing and let ready surfaces take their turn.
    push(storage.scans, radar)
    return
  end
  if not index or #index.chunks == 0 then return end
  local position = index.chunks[math.random(#index.chunks)]
  local bounds = area(position)
  if surface.count_entities_filtered{area = bounds, type = "resource", limit = 1} == 0 then
    -- Swap with the last entry instead of shifting a potentially large ore index.
    remove_chunk(index, position)
    return
  end
  -- chart's upper bound is inclusive; stop inside this chunk.
  bounds[2][1], bounds[2][2] = bounds[2][1] - 1, bounds[2][2] - 1
  radar.force.chart(surface, bounds)
end

on_tick = function()
  local remaining = WORK_PER_TICK
  local attempts = math.min(SCANS_PER_TICK, storage.scans.last - storage.scans.first + 1)
  for _ = 1, attempts do
    scan_step()
    remaining = remaining - 1
  end
  for _ = 1, remaining do
    if storage.work.last == 0 then break end
    work_step()
  end
  if not pending() then script.on_event(defines.events.on_tick, nil) end
end

local function rebuild()
  storage.surfaces = {}
  storage.work = queue()
  storage.scans = storage.scans or queue()
  for _, surface in pairs(game.surfaces) do
    local index = get_index(surface.index)
    index.ready = false
    push(storage.work, {surface_index = surface.index, iterator = surface.get_chunks(), index = index})
  end
  if pending() then wake() else script.on_event(defines.events.on_tick, nil) end
end

script.on_init(rebuild)
script.on_configuration_changed(rebuild)
script.on_load(function()
  if pending() then wake() end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
  local index = get_index(event.surface.index)
  index.pending = index.pending + 1
  push(storage.work, {surface_index = event.surface.index, position = event.position, index = index})
  wake()
end)

script.on_event(defines.events.on_sector_scanned, function(event)
  push(storage.scans, event.radar)
  wake()
end, {{filter = "name", name = "ore-radar"}})

script.on_event(defines.events.on_chunk_deleted, function(event)
  if #event.positions == 0 then return end
  push(storage.work, {surface_index = event.surface_index, positions = event.positions, cursor = 1})
  wake()
end)

script.on_event({defines.events.on_surface_deleted, defines.events.on_surface_cleared}, function(event)
  storage.surfaces[event.surface_index] = nil
end)
