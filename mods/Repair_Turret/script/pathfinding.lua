
--Minimizes number of hops through the network.

local max = math.huge
local insert = table.insert

local cache

local lowest_f_score = function(set, f_score)
  local lowest = max
  local best_cell
  for unit_number, cell in pairs(set) do
    local score = f_score[unit_number]
    if score <= lowest then
      lowest = score
      best_cell = cell
    end
  end
  return best_cell
end

local unwind_path
unwind_path = function(flat_path, map, current_cell)
  local index = current_cell.owner.unit_number
  local node = map[index]
  if node then
    insert(flat_path, 1, node)
    return unwind_path(flat_path, map, node)
  else
    return flat_path
  end
end

local flat = true

local get_path = function(start, goal, origin_position)
  --print("Starting path find")
  local closed_set = {}
  local open_set = {}
  local came_from = {}

  local origin_x, origin_y = origin_position.x, origin_position.y
  local heuristic = function(cell)
    local cell_position = cell.owner.position
    local dx, dy = cell_position.x - origin_x, cell_position.y - origin_y
    return (dx * dx) + (dy * dy)
  end

  local start_index = start.owner.unit_number
  local goal_index = goal.owner.unit_number
  open_set[start_index] = start

  local g_score = {}
  g_score[start_index] = 0

  local f_score = {}
  f_score[start_index] = heuristic(start)

  local insert = table.insert
  local dist = dist
  local lowest_f_score = lowest_f_score
  while next(open_set) do
    local current = lowest_f_score(open_set, f_score)

    if current == goal then
      local path = unwind_path({}, came_from, goal)
      insert(path, goal)
      --print("A* path find complete")
      return path
    end

    local current_index = current.owner.unit_number
    open_set[current_index] = nil
    closed_set[current_index] = current

    for k, neighbour in pairs(current.neighbours) do
      local neighbour_index = neighbour.owner.unit_number

      if not closed_set[neighbour_index] then

        local tentative_g_score = g_score[current_index] + 1
        local new_node = not open_set[neighbour_index]

        if new_node then
          open_set[neighbour_index] = neighbour
          f_score[neighbour_index] = max
        end

        if new_node or (tentative_g_score < g_score[neighbour_index]) then
          came_from[neighbour_index] = current
          g_score[neighbour_index] = tentative_g_score
          f_score[neighbour_index] = g_score[neighbour_index] + heuristic(neighbour)
        end

      end

    end

  end
  return nil -- no valid path
end

local lib = {}

lib.cache = {}

lib.get_cell_path = function(source, destination_cell)

  local logistic_network = destination_cell.logistic_network
  if not logistic_network then return end

  local origin_cell = logistic_network.find_cell_closest_to(source.position)
  if not destination_cell and origin_cell then return end

  local origin_cache = lib.cache[source.unit_number]
  if not origin_cache then
    origin_cache = {}
    lib.cache[source.unit_number] = origin_cache
  end

  local owner = destination_cell.owner

  local cached_path = origin_cache[owner.unit_number]
  if cached_path then
    return cached_path
  end

  local path = get_path(origin_cell, destination_cell, owner.position)

  origin_cache[destination_cell.owner.unit_number] = path

  return path

end


return lib