-- Bounded personal observations, not an ecosystem simulation or map cache.
local M = {CELL = 128, PER_PLAYER = 128, TOTAL = 512, VISIT_INTERVAL = 3600}
local function cell(surface, x, y)
  return surface .. ":" .. math.floor(x / M.CELL) .. ":" .. math.floor(y / M.CELL)
end
M.cell = cell

function M.new()
  return {schema = 1, players = {}, cells = {}, count = 0}
end

function M.player(state, index)
  if not state.players[index] then
    state.players[index] = {records = {}, collection = {}, count = 0,
      page = 1, next_probe = 0, next_sound = 0}
  end
  return state.players[index]
end

local function index_record(state, owner, record)
  local bucket = state.cells[record.cell] or {}
  state.cells[record.cell] = bucket
  bucket[owner .. "/" .. record.key] = {owner = owner, key = record.key}
end

local function remove(state, owner, key)
  local player = state.players[owner]
  local record = player and player.records[key]
  if not record then return end
  local bucket = state.cells[record.cell]
  if bucket then
    bucket[owner .. "/" .. key] = nil
    if not next(bucket) then state.cells[record.cell] = nil end
  end
  player.records[key] = nil
  player.count, state.count = player.count - 1, state.count - 1
  if player.selected == key then player.selected = nil end
end

local function evict(state, only_owner)
  local victim, owner
  for player_index, player in pairs(state.players) do
    if not only_owner or player_index == only_owner then
      for _, record in pairs(player.records) do
        if not victim or record.last_tick < victim.last_tick
          or record.last_tick == victim.last_tick and (player_index < owner
          or player_index == owner and record.key < victim.key) then
          victim, owner = record, player_index
        end
      end
    end
  end
  if victim then remove(state, owner, victim.key) end
end

function M.observe(state, owner, info, tick)
  local player = M.player(state, owner)
  local sector = cell(info.surface_index, info.position.x, info.position.y)
  local key = sector .. "/" .. info.habitat
  local record = player.records[key]
  local created = not record
  if created then
    if player.count >= M.PER_PLAYER then evict(state, owner) end
    if state.count >= M.TOTAL then evict(state) end
    record = {key = key, cell = sector, habitat = info.habitat,
      surface_index = info.surface_index, surface_name = info.surface_name,
      first_tick = tick, last_visit_tick = tick, visits = 1, seasons = {}}
    player.records[key] = record
    player.count, state.count = player.count + 1, state.count + 1
    index_record(state, owner, record)
  elseif tick - record.last_visit_tick >= M.VISIT_INTERVAL then
    record.visits = math.min(9999, record.visits + 1)
    record.last_visit_tick = tick
  end
  -- This is the most recently examined anchor, not a computed habitat centre.
  record.position = {x = info.position.x, y = info.position.y}
  record.anchor_name = info.anchor_name
  record.last_tick = tick
  record.season = info.season
  if info.season then record.seasons[info.season] = true end
  if info.industry then record.industry_tick = record.industry_tick or tick end
  player.collection[info.habitat] = true
  player.selected = key
  return record, created
end

function M.nearby(state, surface, position)
  local result = {}
  local x, y = math.floor(position.x / M.CELL), math.floor(position.y / M.CELL)
  for dx = -1, 1 do
    for dy = -1, 1 do
      local bucket = state.cells[surface .. ":" .. (x + dx) .. ":" .. (y + dy)]
      for _, link in pairs(bucket or {}) do
        local record = state.players[link.owner].records[link.key]
        result[#result + 1] = {owner = link.owner, record = record}
      end
    end
  end
  return result
end

function M.removed(state, info, tick)
  for _, entry in ipairs(M.nearby(state, info.surface_index, info.position)) do
    local r = entry.record
    local dx, dy = r.position.x - info.position.x, r.position.y - info.position.y
    if info.tree and dx * dx + dy * dy <= 24 * 24 then
      r.clearing_tick = r.clearing_tick or tick
    elseif info.name == r.anchor_name and dx * dx + dy * dy < 0.0001 then
      r.removed_tick = r.removed_tick or tick
      r.removed_reason = r.removed_reason or info.reason
    end
  end
end

function M.drop_player(state, owner)
  local player = state.players[owner]
  if not player then return end
  local keys = {}
  for key in pairs(player.records) do keys[#keys + 1] = key end
  for _, key in ipairs(keys) do remove(state, owner, key) end
  state.players[owner] = nil
end

function M.drop_surface(state, surface)
  for owner, player in pairs(state.players) do
    local keys = {}
    for key, record in pairs(player.records) do
      if record.surface_index == surface then keys[#keys + 1] = key end
    end
    for _, key in ipairs(keys) do remove(state, owner, key) end
  end
end

function M.reindex(state)
  assert(state.schema == 1, "Unsupported Alien Biomes fieldbook schema")
  state.cells, state.count = {}, 0
  for owner, player in pairs(state.players) do
    player.count = 0
    for _, record in pairs(player.records) do
      player.count, state.count = player.count + 1, state.count + 1
      index_record(state, owner, record)
    end
    while player.count > M.PER_PLAYER do evict(state, owner) end
  end
  while state.count > M.TOTAL do evict(state) end
end

function M.sorted(player)
  local records = {}
  for _, record in pairs(player.records) do records[#records + 1] = record end
  table.sort(records, function(a, b)
    if a.last_tick == b.last_tick then return a.key < b.key end
    return a.last_tick > b.last_tick
  end)
  return records
end
return M
