local Proximity = {}

-- A radius of 4 covers the default zoom limit at the edge of changing to chart view
Proximity.VisibleChunkRadius = 4
Proximity.FullScanInterval = 5 * 60 -- every 5 seconds

--- @class ImportantCells
--- @field important table<number, GridCell>
--- @field nearby table<number, GridCell>

-- Derived only from persistent player state; rebuilding after load is safe.
local important_by_surface

function Proximity.invalidate_important_cells()
  important_by_surface = nil
end

function Proximity.init_storage()
  storage.player_cells = {}
  storage.player_surfaces = {}
  storage.player_scan_cells = {}
  for _, player in pairs(game.players) do
    storage.player_cells[player.index] = Grid.from_map_position(player.position)
    storage.player_surfaces[player.index] = player.surface.index
  end
  storage.player_cell_neighbors = {}
  storage.player_selection_cells = {}
  storage.player_selection_surfaces = {}
  Proximity.invalidate_important_cells()
end

---@param player_index uint
function Proximity.remove_player_storage(player_index)
  storage.player_cells[player_index] = nil
  storage.player_surfaces[player_index] = nil
  storage.player_scan_cells[player_index] = nil
  storage.player_cell_neighbors[player_index] = nil
  storage.player_selection_cells[player_index] = nil
  storage.player_selection_surfaces[player_index] = nil
  Proximity.invalidate_important_cells()
end

---@param player LuaPlayer
local function visible_radii(player)
  local divisor = player.zoom * 32 * 32 * 2
  local resolution = player.display_resolution
  return math.min(Proximity.VisibleChunkRadius, math.ceil(resolution.width / divisor)),
      math.min(Proximity.VisibleChunkRadius, math.ceil(resolution.height / divisor))
end

local function get_sprites_near_player(sprites, seen_by_surface, player)
  local surface = player.surface
  if not surface.pollutant_type then return end
  if player.render_mode == defines.render_mode.chart then return end
  local seen = seen_by_surface[surface.index]
  if not seen then
    seen = {}
    seen_by_surface[surface.index] = seen
  end
  for _, cell in pairs(storage.player_cell_neighbors[player.index] or {}) do
    if not seen[cell.key] then
      local sprite = Sprite.get(surface, cell)
      if sprite then
        sprites[#sprites + 1] = { cell = cell, sprite = sprite }
        seen[cell.key] = true
      end
    end
  end
end

---@return SpriteUpdateQueueItem[]
function Proximity.get_sprites_near_players()
  local sprites, seen = {}, {}
  for _, player in pairs(game.connected_players) do
    get_sprites_near_player(sprites, seen, player)
  end
  return sprites
end

---@param player LuaPlayer
function Proximity.get_sprites_near_player(player)
  local sprites = {}
  get_sprites_near_player(sprites, {}, player)
  return sprites
end

local function set_visible_cells(player_index, player_cell, cells, x_radius, y_radius)
  local visible = {}
  for _, cell in ipairs(cells) do
    if Grid.is_within_radius(player_cell, x_radius, y_radius, cell) then
      visible[cell.key] = cell
    end
  end
  storage.player_cell_neighbors[player_index] = visible
end

function Proximity.add_sprites_near_players()
  local checked = {}
  for _, player in pairs(game.connected_players) do
    Proximity.add_sprites_near_player(player, checked)
  end
end

---@param player LuaPlayer
function Proximity.add_sprites_near_player(player, checked_by_surface)
  local index, surface = player.index, player.surface
  local player_cell = Grid.from_map_position(player.position)
  storage.player_cells[index] = player_cell
  storage.player_surfaces[index] = surface.index
  Proximity.invalidate_important_cells()
  if not surface.pollutant_type then
    storage.player_cell_neighbors[index] = {}
    storage.player_scan_cells[index] = nil
    return
  end
  local vx, vy = visible_radii(player)
  local wx, wy = math.ceil(vx * 3), math.ceil(vy * 3)
  local scan = storage.player_scan_cells[index]
  if not scan or scan.key ~= player_cell.key or scan.surface ~= surface.index
      or scan.x ~= wx or scan.y ~= wy then
    scan = { key = player_cell.key, surface = surface.index, x = wx, y = wy,
      cells = Grid.compute_neighbours(player_cell, wx, wy) }
    storage.player_scan_cells[index] = scan
  end
  local checked
  if checked_by_surface then
    checked = checked_by_surface[surface.index] or {}
    checked_by_surface[surface.index] = checked
  end
  for _, cell in ipairs(scan.cells) do
    if not checked or not checked[cell.key] then
      Sprite.ensure_existence_if_polluted(surface, cell)
      if checked then checked[cell.key] = true end
    end
  end
  set_visible_cells(index, player_cell, scan.cells, vx, vy)
end

---@param player LuaPlayer
function Proximity.add_sprites_near_player_if_moved(player)
  local index, surface = player.index, player.surface
  if not surface.pollutant_type then return end
  if player.render_mode == defines.render_mode.chart and game.tick % 3 > 0 then return end

  local previous = storage.player_cells[index]
  local position = player.position
  -- Most tile-change events do not cross a chunk; avoid allocating a GridCell.
  if previous and previous.key == Grid.key_from_map_position(position)
      and storage.player_surfaces[index] == surface.index then return end
  local vx, vy = visible_radii(player)
  local wx, wy = math.ceil(vx * 3), math.ceil(vy * 3)
  local scan = storage.player_scan_cells[index]
  if not previous or storage.player_surfaces[index] ~= surface.index
      or not scan or scan.x ~= wx or scan.y ~= wy then
    Proximity.add_sprites_near_player(player)
    return
  end

  local cell = Grid.from_map_position(position)
  storage.player_cells[index] = cell
  -- Keep the radii, but invalidate the full-scan layout until the next full scan.
  scan.key = nil
  scan.cells = nil
  Proximity.invalidate_important_cells()
  for _, exposed in ipairs(Grid.compute_exposed(cell, previous, wx, wy)) do
    Sprite.ensure_existence_if_polluted(surface, exposed)
  end
  set_visible_cells(index, cell, Grid.compute_neighbours(cell, vx, vy), vx, vy)
end

function Proximity.set_selections_for_players()
  for _, player in pairs(game.players) do
    Proximity.set_selections_for_player(player)
  end
end

---@param player LuaPlayer
function Proximity.set_selections_for_player(player)
  local index = player.index
  local selected = player.connected and player.surface.pollutant_type
      and player.render_mode ~= defines.render_mode.chart and player.selected
  local cell = selected and Grid.from_map_position(selected.position) or nil
  local surface = selected and selected.surface.index or nil
  local previous = storage.player_selection_cells[index]
  if (previous and previous.key) ~= (cell and cell.key)
      or storage.player_selection_surfaces[index] ~= surface then
    storage.player_selection_cells[index] = cell
    storage.player_selection_surfaces[index] = surface
    Proximity.invalidate_important_cells()
  end
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
    add(storage.player_surfaces[index], storage.player_cells[index])
    add(storage.player_selection_surfaces[index], storage.player_selection_cells[index])
  end
  return important_by_surface
end

return Proximity
