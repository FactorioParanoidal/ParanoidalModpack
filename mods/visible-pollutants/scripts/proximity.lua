local Proximity = {}

Proximity.FullScanInterval = 5 * 60
Proximity.ContextPollInterval = 15
Proximity.DiscoveryChecksPerTick = 32
Proximity.CreatesPerTick = 2
Proximity.QueueChecksPerRefill = 32

-- Original 96-tile square, arbitrary rotation and +/-2-tile target jitter.
local cloud_margin = 48 * math.sqrt(2) + 2

--- @class ImportantCells
--- @field important table<number, GridCell>
--- @field nearby table<number, GridCell>

-- Derived only from persistent player state; rebuilding after load is safe.
local important_by_surface, priority_cells

function Proximity.invalidate_important_cells()
  important_by_surface, priority_cells = nil, nil
end

local function init_camera_storage()
  storage.player_view_requests = {}
  storage.camera_discovery_player = 1
  storage.camera_update_player = 1
  storage.camera_poll_player = 1
  storage.camera_discovery_next_tick = 0
  storage.sprite_priority_cursor = 1
  -- Retire old derived rectangle arrays, not render objects or their queues.
  storage.player_scan_cells = {}
  storage.player_cell_neighbors = {}
end

function Proximity.init_storage()
  storage.player_cells = {}
  storage.player_surfaces = {}
  storage.player_selection_cells = {}
  storage.player_selection_surfaces = {}
  init_camera_storage()
  Proximity.invalidate_important_cells()
end

-- A same-version code update need not deliver on_configuration_changed.
-- Called only from ordinary events, never on_load; existing renders survive.
function Proximity.ensure_camera_storage()
  if storage.player_view_requests then return end
  init_camera_storage()
  Proximity.invalidate_important_cells()
  Proximity.add_sprites_near_players()
end

---@param player_index uint
function Proximity.remove_player_storage(player_index)
  storage.player_cells[player_index] = nil
  storage.player_surfaces[player_index] = nil
  storage.player_scan_cells[player_index] = nil
  storage.player_cell_neighbors[player_index] = nil
  storage.player_selection_cells[player_index] = nil
  storage.player_selection_surfaces[player_index] = nil
  if storage.player_view_requests then
    storage.player_view_requests[player_index] = nil
  end
  Proximity.invalidate_important_cells()
end

---@param player LuaPlayer
function Proximity.set_selections_for_player(player)
  local index = player.index
  local selected = player.connected and player.surface.pollutant_type
      and player.render_mode ~= defines.render_mode.chart and player.selected
  if selected and not selected.valid then selected = nil end
  local previous = storage.player_selection_cells[index]
  local key = selected and Grid.key_from_map_position(selected.position) or nil
  local surface = selected and selected.surface.index or nil
  if (previous and previous.key) ~= key
      or storage.player_selection_surfaces[index] ~= surface then
    storage.player_selection_cells[index] = selected and Grid.from_map_position(selected.position) or nil
    storage.player_selection_surfaces[index] = surface
    Proximity.invalidate_important_cells()
  end
end

---@param player LuaPlayer
function Proximity.add_sprites_near_player(player)
  Proximity.ensure_camera_storage()
  local index, surface = player.index, player.surface
  local active = player.connected and surface.pollutant_type
      and player.render_mode ~= defines.render_mode.chart
  local position = player.position -- Current controller, including remote view, not character.position.
  local previous = storage.player_cells[index]
  local key = active and Grid.key_from_map_position(position) or nil
  local surface_index = active and surface.index or nil
  if (previous and previous.key) ~= key or storage.player_surfaces[index] ~= surface_index then
    storage.player_cells[index] = active and Grid.from_map_position(position) or nil
    storage.player_surfaces[index] = surface_index
    Proximity.invalidate_important_cells()
  end
  Proximity.set_selections_for_player(player)
  if not active then
    storage.player_view_requests[index] = nil
    return
  end

  -- Resolution is in screen pixels; GUI display_scale is not world zoom.
  local resolution = player.display_resolution
  local half_width = resolution.width / (64 * player.zoom)
  local half_height = resolution.height / (64 * player.zoom)
  -- Cell centres are at 32*n+16. Ceil/floor also cover negative coordinates.
  local left = math.ceil((position.x - half_width - cloud_margin - 16) / 32)
  local right = math.floor((position.x + half_width + cloud_margin - 16) / 32)
  local top = math.ceil((position.y - half_height - cloud_margin - 16) / 32)
  local bottom = math.floor((position.y + half_height + cloud_margin - 16) / 32)
  local view = storage.player_view_requests[index]
  if view and view.surface == surface_index and view.left == left and view.right == right
      and view.top == top and view.bottom == bottom then return end
  if not view or view.surface ~= surface_index then
    view = { scan_cursor = 0, update_cursor = 0 }
    storage.player_view_requests[index] = view
  end
  view.surface = surface_index
  view.left, view.right, view.top, view.bottom = left, right, top, bottom
  view.width = right - left + 1
  view.count = view.width * (bottom - top + 1)
  -- Keep relative progress across pans/zoom changes instead of restarting at a corner.
  view.scan_cursor = view.scan_cursor % view.count
  view.update_cursor = view.update_cursor % view.count
  view.scan_remaining = view.count
  view.next_scan_tick = game.tick
  storage.camera_discovery_next_tick = game.tick
end

function Proximity.add_sprites_near_players()
  for _, player in pairs(game.connected_players) do
    Proximity.add_sprites_near_player(player)
  end
end

---@param player LuaPlayer
function Proximity.add_sprites_near_player_if_moved(player)
  local previous = storage.player_cells[player.index]
  if previous and previous.key == Grid.key_from_map_position(player.position)
      and storage.player_surfaces[player.index] == player.surface.index
      and player.render_mode ~= defines.render_mode.chart then return end
  Proximity.add_sprites_near_player(player)
end

-- No zoom/render-mode event exists in 2.1.24. Sample one camera, not every player, per poll.
function Proximity.poll_camera()
  Proximity.ensure_camera_storage()
  local players = game.connected_players
  if #players == 0 then return end
  local index = (storage.camera_poll_player - 1) % #players + 1
  Proximity.add_sprites_near_player(players[index])
  storage.camera_poll_player = index % #players + 1
end

local function next_coordinate(view, cursor_name)
  local cursor = view[cursor_name]
  local x = view.left + cursor % view.width
  local y = view.top + math.floor(cursor / view.width)
  view[cursor_name] = (cursor + 1) % view.count
  return x, y, (x + 1e7) * 1e7 + (y + 1e7) -- Same numeric key as Grid, no string conversion.
end

function Proximity.discover_sprites()
  Proximity.ensure_camera_storage()
  if game.tick < storage.camera_discovery_next_tick then return end
  local players = game.connected_players
  local count = #players
  if count == 0 then
    storage.camera_discovery_next_tick = game.tick + Proximity.FullScanInterval
    return
  end
  local index = (storage.camera_discovery_player - 1) % count + 1
  local created, idle = 0, 0
  local next_scan_tick = game.tick + Proximity.FullScanInterval
  local checked_by_surface
  -- Even inactive cameras/overlaps consume a slot: work never multiplies by player count.
  for _ = 1, Proximity.DiscoveryChecksPerTick do
    local player = players[index]
    local view = storage.player_view_requests[player.index]
    if view and (player.render_mode == defines.render_mode.chart
        or player.surface.index ~= view.surface) then
      Proximity.add_sprites_near_player(player)
      view = storage.player_view_requests[player.index]
    end
    if view and view.scan_remaining == 0 and game.tick >= view.next_scan_tick then
      view.scan_remaining = view.count
    end
    if view and view.scan_remaining > 0 then
      idle = 0
      local x, y, key = next_coordinate(view, "scan_cursor")
      view.scan_remaining = view.scan_remaining - 1
      if not checked_by_surface then checked_by_surface = {} end
      local checked = checked_by_surface[view.surface]
      if not checked then
        checked = {}
        checked_by_surface[view.surface] = checked
      end
      if not checked[key] then
        checked[key] = true
        local cached = Sprite.get_by_key(view.surface, key)
        if cached then
          cached.time_to_live = Sprite.OutOfBoundsSpriteTTL
        else
          local surface = game.surfaces[view.surface]
          if surface and surface.valid then
            local _, was_created = Sprite.ensure_existence_if_polluted(surface,
              Grid.from_cell_position({ x = x, y = y }))
            if was_created then created = created + 1 end
          end
        end
      end
      if view.scan_remaining == 0 then
        view.next_scan_tick = game.tick + Proximity.FullScanInterval
      end
    else
      idle = idle + 1
      if view then next_scan_tick = math.min(next_scan_tick, view.next_scan_tick) end
    end
    index = index % count + 1
    if idle >= count then
      storage.camera_discovery_next_tick = next_scan_tick
      break
    end
    if created >= Proximity.CreatesPerTick then break end
  end
  storage.camera_discovery_player = index
end

---@return table<number, ImportantCells>
function Proximity.get_important_cells()
  if important_by_surface then return important_by_surface end
  important_by_surface = {}
  local function add(surface, cell)
    if not surface or not cell then return end
    local cells = important_by_surface[surface]
    if not cells then
      cells = { important = {}, nearby = {} }
      important_by_surface[surface] = cells
    end
    if cells.important[cell.key] then return end
    cells.important[cell.key] = cell
    for _, nearby in ipairs(Grid.compute_neighbours(cell, 1, 1)) do
      cells.nearby[nearby.key] = nearby
    end
  end
  for _, player in pairs(game.connected_players) do
    local index = player.index
    add(storage.player_selection_surfaces[index], storage.player_selection_cells[index])
    add(storage.player_surfaces[index], storage.player_cells[index])
  end
  return important_by_surface
end

local function get_priority_cells()
  if priority_cells then return priority_cells end
  priority_cells = {}
  local important = Proximity.get_important_cells()
  for surface, cells in pairs(important) do
    for _, cell in pairs(cells.important) do
      priority_cells[#priority_cells + 1] = { surface = surface, cell = cell }
    end
  end
  for surface, cells in pairs(important) do
    for key, cell in pairs(cells.nearby) do
      if not cells.important[key] then
        priority_cells[#priority_cells + 1] = { surface = surface, cell = cell }
      end
    end
  end
  return priority_cells
end

local function append_cached(queue, seen_by_surface, surface, key)
  local seen = seen_by_surface[surface]
  if seen and seen[key] then return end
  local sprite = Sprite.get_by_key(surface, key)
  if not sprite then return end
  if not seen then
    seen = {}
    seen_by_surface[surface] = seen
  end
  seen[key] = true
  queue[#queue + 1] = { key = key, sprite = sprite }
end

-- Refill the existing queue, never enumerate a viewport or build its GridCell array.
---@return SpriteUpdateQueueItem[]
function Proximity.get_sprites_near_players()
  Proximity.ensure_camera_storage()
  local queue, seen = {}, {}
  local limit = math.min(80, Sprite.MaxUpdatesPerTick * 4)
  local priority = get_priority_cells()
  if #priority > 0 then
    local cursor = (storage.sprite_priority_cursor - 1) % #priority + 1
    for _ = 1, math.min(18, #priority, math.floor(limit / 3)) do
      local entry = priority[cursor]
      append_cached(queue, seen, entry.surface, entry.cell.key)
      cursor = cursor % #priority + 1
    end
    storage.sprite_priority_cursor = cursor
  end

  local players = game.connected_players
  local count = #players
  if count == 0 then return queue end
  local index = (storage.camera_update_player - 1) % count + 1
  local idle = 0
  for _ = 1, Proximity.QueueChecksPerRefill do
    local player = players[index]
    local view = storage.player_view_requests[player.index]
    if view and player.render_mode ~= defines.render_mode.chart
        and player.surface.index == view.surface then
      idle = 0
      local _, _, key = next_coordinate(view, "update_cursor")
      append_cached(queue, seen, view.surface, key)
    else
      idle = idle + 1
    end
    index = index % count + 1
    if #queue >= limit or idle >= count then break end
  end
  storage.camera_update_player = index
  return queue
end

function Proximity.on_surface_deleted(surface_index)
  for index, view in pairs(storage.player_view_requests or {}) do
    if view.surface == surface_index then
      Proximity.remove_player_storage(index)
    end
  end
  Proximity.invalidate_important_cells()
end

return Proximity
