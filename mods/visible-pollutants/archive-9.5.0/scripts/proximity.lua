local Proximity = {}

Proximity.MaxCandidatesPerTick = 64
Proximity.MaxPlayerRefreshesPerTick = 4
Proximity.ViewPollInterval = 15 -- zoom/dragging have no dedicated zoom event

local function new_player(state, index)
  if state.players[index] then return end
  local record = { index = index, slot = #state.roster + 1, dirty = true, cursor = 0, included = 0, demand = 0 }
  state.players[index] = record
  state.roster[record.slot] = index
end

local function current_state()
  if not storage.visual_proximity then
    local state = { players = {}, roster = {}, turn = 1, important = {}, demand_cells = 0 }
    storage.visual_proximity = state
    -- One topology snapshot at init/upgrade, never an all-player snapshot per tick.
    for _, player in pairs(game.connected_players) do new_player(state, player.index) end
    storage.player_cells = nil
    storage.player_surfaces = nil
    storage.player_scan_cells = nil
    storage.player_cell_neighbors = nil
    storage.player_selection_cells = nil
    storage.player_selection_surfaces = nil
  end
  return storage.visual_proximity
end

function Proximity.init_storage()
  storage.visual_proximity = nil
  current_state()
end

-- Event handlers only flag one context, without generating cells or rendering.
function Proximity.mark_player(index)
  local state = current_state()
  new_player(state, index)
  state.players[index].dirty = true
  state.players[index].sleep_until = nil
end

local function change_anchor(state, anchor, delta)
  if not anchor then return end
  local row = state.important[anchor.surface]
  if row and row.surface_object ~= anchor.surface_object then
    if delta < 0 then return end
    row = nil
  end
  if not row then
    if delta < 0 then return end
    row = { important = {}, nearby = {}, surface_object = anchor.surface_object }
    state.important[anchor.surface] = row
  end
  local function count(map, key)
    local value = (map[key] or 0) + delta
    map[key] = value > 0 and value or nil
  end
  count(row.important, anchor.cell.key)
  for x = -1, 1 do
    for y = -1, 1 do
      local cell = Grid.from_cell_position({ x = anchor.cell.x + x, y = anchor.cell.y + y })
      count(row.nearby, cell.key)
    end
  end
  if not next(row.important) and not next(row.nearby) then state.important[anchor.surface] = nil end
end

local function set_anchor(state, record, field, anchor)
  local old = record[field]
  if old and anchor and old.surface_object == anchor.surface_object and old.cell.key == anchor.cell.key then return end
  if not old and not anchor then return end
  change_anchor(state, old, -1)
  change_anchor(state, anchor, 1)
  record[field] = anchor
end

function Proximity.remove_player_storage(index)
  local state = current_state()
  local record = state.players[index]
  if not record then return end
  change_anchor(state, record.body, -1)
  change_anchor(state, record.selection, -1)
  state.demand_cells = state.demand_cells - record.demand
  local last = state.roster[#state.roster]
  state.roster[record.slot] = last
  state.players[last].slot = record.slot
  state.roster[#state.roster] = nil
  state.players[index] = nil
end

function Proximity.on_surface_deleted(index)
  local state = current_state()
  state.important[index] = nil
  -- Invalid surface handles are rejected by the bounded worker; no player scan.
end

function Proximity.get_important_cells()
  return current_state().important
end

local function refresh_player(state, record)
  local player = game.get_player(record.index)
  record.dirty = false
  record.next_poll = game.tick + Proximity.ViewPollInterval
  if not player or not player.valid or not player.connected then
    -- Scripts may move an offline player after its leave event. Do not retain
    -- that late context in the online roster or reduce other players' quotas.
    Proximity.remove_player_storage(record.index)
    record.surface = nil
    return
  end
  local eligible = player.render_mode ~= defines.render_mode.chart and player.surface.pollutant_type
  if not eligible then
    state.demand_cells = state.demand_cells - record.demand
    record.demand, record.surface = 0, nil
    set_anchor(state, record, "body", nil)
    set_anchor(state, record, "selection", nil)
    return
  end

  local surface, position = player.surface, player.position
  local center = Grid.from_map_position(position)
  local half_x = player.display_resolution.width / (player.zoom * 64)
  local half_y = player.display_resolution.height / (player.zoom * 64)
  local extent = Sprite.get_footprint_half_extent()
  -- Candidate centers are at 32*x+16, with rotation/jitter included in extent.
  local left = math.ceil((position.x - half_x - extent - 16) / 32)
  local right = math.floor((position.x + half_x + extent - 16) / 32)
  local top = math.ceil((position.y - half_y - extent - 16) / 32)
  local bottom = math.floor((position.y + half_y + extent - 16) / 32)
  local radius = math.max(center.x - left, right - center.x, center.y - top, bottom - center.y)
  -- Under extreme aggregate demand retain near-camera coverage fairly, rather
  -- than repeatedly evicting and recreating other players' visible clouds.
  local quota = math.max(1, math.floor(Sprite.CacheLimit / math.max(1, #state.roster)))
  local demand = math.min(quota, (right - left + 1) * (bottom - top + 1))
  local jumped = not record.center or record.surface ~= surface
      or math.abs(record.center.x - center.x) > 1 or math.abs(record.center.y - center.y) > 1
  if jumped or record.radius ~= radius or record.quota ~= quota then
    record.cursor, record.included = 0, 0
    record.cycle_live, record.sleep_until = false, nil
  end
  record.surface, record.center = surface, center
  record.left, record.right, record.top, record.bottom = left, right, top, bottom
  record.radius, record.quota = radius, quota
  state.demand_cells = state.demand_cells - record.demand + demand
  record.demand = demand
  set_anchor(state, record, "body", { surface = surface.index, surface_object = surface, cell = center })
  local selected = player.selected
  local selection = selected and selected.valid and { surface = selected.surface.index,
    surface_object = selected.surface, cell = Grid.from_map_position(selected.position) } or nil
  set_anchor(state, record, "selection", selection)
end

-- Center-out square spiral: O(1) coordinates, no area-sized array or job list.
local function candidate(record)
  if record.cursor >= (2 * record.radius + 1)^2 or record.included >= record.quota then
    record.cursor, record.included = 0, 0
    if not record.cycle_live then
      record.sleep_until = game.tick + Sprite.SampleInterval
      return nil, true
    end
    record.cycle_live = false
  end
  local n, x, y = record.cursor, 0, 0
  if n > 0 then
    local ring = math.ceil((math.sqrt(n + 1) - 1) / 2)
    local offset = n - (2 * ring - 1)^2
    local side, along = math.floor(offset / (2 * ring)), offset % (2 * ring)
    if side == 0 then x, y = ring, -ring + 1 + along
    elseif side == 1 then x, y = ring - 1 - along, ring
    elseif side == 2 then x, y = -ring, ring - 1 - along
    else x, y = -ring + 1 + along, -ring end
  end
  x, y = x + record.center.x, y + record.center.y
  if x < record.left or x > record.right or y < record.top or y > record.bottom then return nil end
  return Grid.from_cell_position({ x = x, y = y })
end

function Proximity.step()
  local state = current_state()
  local stats = { candidates = 0, player_refreshes = 0, work = 0, samples = 0,
    creates = 0, updates = 0, removals = 0, legacy_steps = 0, capacity_waits = 0 }
  storage.visual_last_step = stats
  local throughput = math.max(1, math.min(Sprite.MaxUpdatesPerTick, Sprite.MaxCreatesPerTick))
  local retention = math.max(120, math.ceil(state.demand_cells / throughput) * 3)
  Sprite.cleanup_expired(stats, retention)
  local seen, wind, idle_turns = {}, {}, 0
  for _ = 1, Proximity.MaxCandidatesPerTick do
    -- Stop BEFORE choosing the next player: exhaustion cannot starve the tail.
    if #state.roster == 0 or stats.work >= Sprite.MaxUpdatesPerTick
        or stats.creates >= Sprite.MaxCreatesPerTick then break end
    if state.turn > #state.roster then state.turn = 1 end
    local record = state.players[state.roster[state.turn]]
    stats.candidates = stats.candidates + 1
    local due = record.dirty or not record.next_poll or game.tick >= record.next_poll
    if due and stats.player_refreshes < Proximity.MaxPlayerRefreshesPerTick then
      refresh_player(state, record)
      stats.player_refreshes = stats.player_refreshes + 1
      due = false
    end
    if not due and record.surface and record.surface.valid
        and (not record.sleep_until or game.tick >= record.sleep_until) then
      local cell, sleeping = candidate(record)
      if not sleeping then
        idle_turns = 0
        if cell then
          local surface_seen = seen[record.surface.index]
          if not surface_seen then surface_seen = {}; seen[record.surface.index] = surface_seen end
          if surface_seen[cell.key] == nil then
            local handled, live = Sprite.service(record.surface, cell, state.important, wind, stats)
            if not handled then break end
            surface_seen[cell.key] = not not live
          end
          record.cycle_live = record.cycle_live or surface_seen[cell.key]
          record.included = record.included + 1
        end
        record.cursor = record.cursor + 1
      else
        idle_turns = idle_turns + 1
      end
    else
      idle_turns = idle_turns + 1
    end
    state.turn = state.turn + 1
    if idle_turns >= #state.roster then break end
  end
  return stats
end

return Proximity
