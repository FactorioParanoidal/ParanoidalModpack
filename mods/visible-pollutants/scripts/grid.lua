local Grid = {}

--- A grid is defined by its size and offset
--- @class GridDefinition
--- @field name string
--- @field width number The width of each cell
--- @field height number The height of each cell

---@type GridDefinition
Grid.ChunkAligned = {
  name = "chunk-aligned",
  width = 32,
  height = 32,
}
local grid = Grid.ChunkAligned

--- A cell in a grid has a few important positions
--- @class GridCell
--- @field key number A unique hash for this cell
--- @field x number The x-coordinate in the grid
--- @field y number The y-coordinate in the grid
--- @field center MapPosition The center position of the cell in map coordinates

--- Simplified function described here; note the few inline optimizations on changes
--- @param x number
--- @param y number
--- @return number
local function storage_key(x, y)
  return (x + 1e7) * 1e7 + (y + 1e7)
end

---@param position MapPosition
---@return number
function Grid.key_from_map_position(position)
  local x = position.x / grid.width
  x = x - x % 1 -- fast floor
  local y = position.y / grid.height
  y = y - y % 1 -- fast floor
  return (x + 1e7) * 1e7 + (y + 1e7) -- storage_key
end

---@param position MapPosition
---@return GridCell
function Grid.from_map_position(position)
  local x = position.x / grid.width
  x = x - x % 1 -- fast floor
  local y = position.y / grid.height
  y = y - y % 1 -- fast floor
  local left = x * grid.width
  local top = y * grid.height
  return {
    key = (x + 1e7) * 1e7 + (y + 1e7), -- storage_key
    x = x,
    y = y,
    center = { x = left + (grid.width / 2), y = top + (grid.height / 2) }
  }
end

---@param position MapPosition
---@return GridCell
function Grid.from_cell_position(position)
  local left = position.x * grid.width
  local top = position.y * grid.height
  return {
    key = (position.x + 1e7) * 1e7 + (position.y + 1e7), -- storage_key
    x = position.x,
    y = position.y,
    center = { x = left + (grid.width / 2), y = top + (grid.height / 2) }
  }
end

---@param center GridCell
---@param x_radius number
---@param y_radius number
---@param cell GridCell
---@return boolean
function Grid.is_within_radius(center, x_radius, y_radius, cell)
  local x_difference = cell.x - center.x
  local y_difference = cell.y - center.y
  return (-x_radius <= x_difference and x_difference <= x_radius) and (-y_radius <= y_difference and y_difference <= y_radius)
end

---@param cell GridCell
---@param x_radius number
---@param y_radius number
---@return GridCell[]
function Grid.compute_neighbours(cell, x_radius, y_radius)
  local neighbours = {}
  local i = 1
  for x = -x_radius, x_radius do
    for y = -y_radius, y_radius do
      local cx, cy = cell.x + x, cell.y + y
      neighbours[i] = {
        key = storage_key(cx, cy),
        x = cx,
        y = cy,
        center = { x = cx * grid.width + grid.width / 2, y = cy * grid.height + grid.height / 2 },
      }
      i = i + 1
    end
  end
  return neighbours
end

---@param cell GridCell
---@param x_radius number
---@param y_radius number
---@return GridCell[]
function Grid.compute_left_edges(cell, x_radius, y_radius)
  return Grid.compute_neighbours(Grid.from_cell_position({
    x = cell.x - x_radius,
    y = cell.y,
  }), 0, y_radius)
end

---@param cell GridCell
---@param x_radius number
---@param y_radius number
---@return GridCell[]
function Grid.compute_top_edges(cell, x_radius, y_radius)
  return Grid.compute_neighbours(Grid.from_cell_position({
    x = cell.x,
    y = cell.y - y_radius,
  }), x_radius, 0)
end

---@param cell GridCell
---@param x_radius number
---@param y_radius number
---@return GridCell[]
function Grid.compute_right_edges(cell, x_radius, y_radius)
  return Grid.compute_neighbours(Grid.from_cell_position({
    x = cell.x + x_radius,
    y = cell.y,
  }), 0, y_radius)
end

---@param cell GridCell
---@param x_radius number
---@param y_radius number
---@return GridCell[]
function Grid.compute_bottom_edges(cell, x_radius, y_radius)
  return Grid.compute_neighbours(Grid.from_cell_position({
    x = cell.x,
    y = cell.y + y_radius,
  }), x_radius, 0)
end

--- Cells exposed by moving a rectangle, without allocating its overlapping interior.
--- Strips are disjoint, including diagonal moves and long teleports.
function Grid.compute_exposed(cell, previous, x_radius, y_radius)
  local cells = {}
  local left, right = cell.x - x_radius, cell.x + x_radius
  local top, bottom = cell.y - y_radius, cell.y + y_radius
  local old_left, old_right = previous.x - x_radius, previous.x + x_radius
  local old_top, old_bottom = previous.y - y_radius, previous.y + y_radius
  local function append(x1, x2, y1, y2)
    for x = x1, x2 do
      for y = y1, y2 do
        cells[#cells + 1] = Grid.from_cell_position({ x = x, y = y })
      end
    end
  end
  append(left, math.min(right, old_left - 1), top, bottom)
  append(math.max(left, old_right + 1), right, top, bottom)
  local overlap_left, overlap_right = math.max(left, old_left), math.min(right, old_right)
  append(overlap_left, overlap_right, top, math.min(bottom, old_top - 1))
  append(overlap_left, overlap_right, math.max(top, old_bottom + 1), bottom)
  return cells
end

return Grid
