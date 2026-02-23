local Proximity = {}

-- A radius of 4 covers the default zoom limit at the edge of changing to chart view
Proximity.VisibleChunkRadius = 4
Proximity.FullScanInterval = 5 * 60 -- every 5 seconds

--- @class ImportantCells
--- @field important table<number, GridCell>
--- @field nearby table<number, GridCell>

function Proximity.init_storage()
  storage.player_cells = {}
  for _, player in pairs(game.players) do
    storage.player_cells[player.index] = Grid.from_map_position(player.position)
  end
  storage.player_cell_neighbors = {}
  storage.player_selection_cells = {}
end

---@param player_index uint
function Proximity.remove_player_storage(player_index)
  storage.player_cells[player_index] = nil
  storage.player_cell_neighbors[player_index] = nil
  storage.player_selection_cells[player_index] = nil
end

---@param player LuaPlayer
---@return { x: number, y: number }
local function determine_max_visible_chunk_radii(player)
  local divisor = player.zoom * 32 * 32 * 2 -- pixels per tile, then tiles per chunk, then diameter to radius
  local resolution = player.display_resolution
  return {
    x = math.min(Proximity.VisibleChunkRadius, math.ceil(resolution.width / divisor)),
    y = math.min(Proximity.VisibleChunkRadius, math.ceil(resolution.height / divisor)),
  }
end

---@param player LuaPlayer
---@return { x: number, y: number }
local function determine_max_draggable_chunk_radii(player)
  local visible_radius = determine_max_visible_chunk_radii(player)
  return {
    x = math.ceil(visible_radius.x * 3),
    y = math.ceil(visible_radius.y * 3),
  }
end

---@param sprites SpriteUpdateQueueItem[]
---@param player LuaPlayer
local function get_sprites_near_player(sprites, player)
  local i = #table + 1
  if not player.surface.pollutant_type then return end
  if player.render_mode == defines.render_mode.chart then return end
  local nearby_cells = storage.player_cell_neighbors[player.index] or {}
  for _, cell in pairs(nearby_cells) do
    local sprite = Sprite.get(player.surface, cell)
    if sprite then
      sprites[i] = {
        cell = cell,
        sprite = sprite,
      }
      i = i + 1
    end
  end
end

---@return SpriteUpdateQueueItem[] sprites
function Proximity.get_sprites_near_players()
  local sprites = {}
  for _, player in pairs(game.players) do
    if player.connected then
      get_sprites_near_player(sprites, player)
    end
  end
  return sprites
end

---@param player LuaPlayer
function Proximity.get_sprites_near_player( player)
  local sprites = {}
  get_sprites_near_player(sprites, player)
  return sprites
end

function Proximity.add_sprites_near_players()
  for _, player in pairs(game.players) do
    if player.connected then
      Proximity.add_sprites_near_player(player)
    end
  end
end

---@param player LuaPlayer
function Proximity.add_sprites_near_player(player)
  storage.player_cell_neighbors[player.index] = {}
  if not player.surface.pollutant_type then return end
  local player_cell = Grid.from_map_position(player.position)
  storage.player_cells[player.index] = player_cell
  local wide_radius = determine_max_draggable_chunk_radii(player)
  local visible_radius = determine_max_visible_chunk_radii(player)
  local nearby_cells = Grid.compute_neighbours(player_cell, wide_radius.x, wide_radius.y)
  for _, cell in ipairs(nearby_cells) do
    Sprite.ensure_existence_if_polluted(player.surface, cell)
    if Grid.is_within_radius(player_cell, visible_radius.x, visible_radius.y, cell) then
      storage.player_cell_neighbors[player.index][cell.key] = cell
    end
  end
end

function Proximity.add_sprites_near_players_if_moved()
  for _, player in pairs(game.players) do
    if player.connected then
      Proximity.add_sprites_near_player_if_moved(player)
    end
  end
end

---@param player LuaPlayer
function Proximity.add_sprites_near_player_if_moved(player)
  if not player.surface.pollutant_type then return end
  -- Reduce update rate while in wide chart mode
  if player.render_mode == defines.render_mode.chart and game.tick % 3 > 0 then
    return
  end
  local last_player_cell = storage.player_cells[player.index]
  local player_cell = Grid.from_map_position(player.position)
  if last_player_cell
      and last_player_cell.x == player_cell.x
      and last_player_cell.y == player_cell.y
  then return end
  storage.player_cells[player.index] = player_cell

  local wide_radius = determine_max_draggable_chunk_radii(player)
  local visible_radius = determine_max_visible_chunk_radii(player)

  local new_cells = {}
  local new_visible_cells = {}
  if player_cell.x == last_player_cell.x - 1 then
    new_cells = Grid.compute_left_edges(player_cell, wide_radius.x, wide_radius.y)
    new_visible_cells = Grid.compute_left_edges(player_cell, visible_radius.x, visible_radius.y)
  elseif player_cell.y == last_player_cell.y - 1 then
    new_cells = Grid.compute_top_edges(player_cell, wide_radius.x, wide_radius.y)
    new_visible_cells = Grid.compute_top_edges(player_cell, visible_radius.x, visible_radius.y)
  elseif player_cell.x == last_player_cell.x + 1 then
    new_cells = Grid.compute_right_edges(player_cell, wide_radius.x, wide_radius.y)
    new_visible_cells = Grid.compute_right_edges(player_cell, visible_radius.x, visible_radius.y)
  elseif player_cell.y == last_player_cell.y + 1 then
    new_cells = Grid.compute_bottom_edges(player_cell, wide_radius.x, wide_radius.y)
    new_visible_cells = Grid.compute_bottom_edges(player_cell, visible_radius.x, visible_radius.y)
  else
    new_cells = Grid.compute_neighbours(player_cell, wide_radius.x, wide_radius.y)
    new_visible_cells = Grid.compute_neighbours(player_cell, visible_radius.x, visible_radius.y)
  end

  for _, cell in ipairs(new_cells) do
    Sprite.ensure_existence_if_polluted(player.surface, cell)
  end

  if not storage.player_cell_neighbors[player.index] then
    storage.player_cell_neighbors[player.index] = {}
  end
  for _, cell in ipairs(new_visible_cells) do
    storage.player_cell_neighbors[player.index][cell.key] = cell
  end
end

function Proximity.set_selections_for_players()
  for _, player in pairs(game.players) do
    Proximity.set_selections_for_player(player)
  end
end

---@param player LuaPlayer
function Proximity.set_selections_for_player(player)
  storage.player_selection_cells[player.index] = nil
  if not player.connected then return end
  if not player.surface.pollutant_type then return end
  if player.render_mode == defines.render_mode.chart then return end
  local selected = player.selected
  if selected then
    storage.player_selection_cells[player.index] = Grid.from_map_position(selected.position)
  else
  end
end

---@return ImportantCells
function Proximity.get_important_cells()
  --- @type ImportantCells
  local important_cells = {
    important = {},
    nearby = {},
  }
  for _, cell in pairs(storage.player_cells) do
    if cell and not important_cells.important[cell.key] then
      important_cells.important[cell.key] = cell
      for _, nearby in pairs(Grid.compute_neighbours(cell, 1, 1)) do
        important_cells.nearby[nearby.key] = nearby
      end
    end
  end
  for _, selected in pairs(storage.player_selection_cells) do
    if selected and not important_cells.important[selected.key] then
      important_cells.important[selected.key] = selected
      for _, nearby in pairs(Grid.compute_neighbours(selected, 1, 1)) do
        important_cells.nearby[nearby.key] = nearby
      end
    end
  end
  return important_cells
end

return Proximity
