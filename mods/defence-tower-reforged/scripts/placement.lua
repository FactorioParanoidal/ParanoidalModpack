-- World overlays only. The engine tracks the build cursor, so no tick handler is needed.
local P = {}
local TOWER = require("shared").turret
local built_color = {r = 0.30, g = 0.70, b = 0.40, a = 0.70}
local preview_color = {r = 0.65, g = 1, b = 0.85, a = 1}

local function holds_tower(player)
  local stack = player.cursor_stack
  local item
  if stack and stack.valid_for_read then
    item = stack.prototype
  else
    local ghost = player.cursor_ghost
    item = ghost and ghost.name
  end
  local result = item and item.place_result
  return result and result.name == TOWER
end

local function view_of(index)
  return storage.dtr_placement and storage.dtr_placement[index]
end

function P.active(index)
  return view_of(index) ~= nil
end

function P.clear(index)
  local view = view_of(index)
  if not view then return end
  view.preview.destroy()
  for _, box in pairs(view.built) do box.destroy() end
  storage.dtr_placement[index] = nil
end

function P.clear_all(surface_index)
  for index, view in pairs(storage.dtr_placement or {}) do
    if not surface_index or view.surface == surface_index then P.clear(index) end
  end
end

local function corner(entity, distance)
  if entity then return {entity = entity, offset = {distance, distance}} end
  return {type = "build-cursor", offset = {distance, distance}}
end

local function area(view, index, entity)
  return rendering.draw_rectangle{
    left_top = corner(entity, -view.range), right_bottom = corner(entity, view.range),
    surface = view.surface, players = {index},
    color = entity and built_color or preview_color, width = entity and 2 or 3,
    draw_on_ground = entity ~= nil, render_mode = entity and "game" or "build-cursor",
  }
end

local function refresh_entity(view, index, entity)
  local unit = entity.unit_number
  local box = view.built[unit]
  if entity.force_index == view.force and entity.surface_index == view.surface then
    if not (box and box.valid) then view.built[unit] = area(view, index, entity) end
  elseif box then
    box.destroy()
    view.built[unit] = nil
  end
end

function P.sync(player, towers, range_of)
  local index = player.index
  if not (player.connected and holds_tower(player)) then
    P.clear(index)
    return
  end
  local surface, force = player.surface_index, player.force.index
  local view = view_of(index)
  if view and view.surface == surface and view.force == force and view.preview.valid then return end
  P.clear(index)
  view = {surface = surface, force = force, range = range_of(force), built = {}}
  view.preview = area(view, index)
  storage.dtr_placement = storage.dtr_placement or {}
  storage.dtr_placement[index] = view
  for _, tower in pairs(towers) do
    if tower.entity.valid then refresh_entity(view, index, tower.entity) end
  end
end

function P.tower_changed(entity)
  if not storage.dtr_placement then return end
  for index, view in pairs(storage.dtr_placement) do refresh_entity(view, index, entity) end
end

function P.tower_removed(unit)
  for _, view in pairs(storage.dtr_placement or {}) do
    local box = view.built[unit]
    if box then
      box.destroy()
      view.built[unit] = nil
    end
  end
end

local function resize(box, range, entity)
  box.left_top = corner(entity, -range)
  box.right_bottom = corner(entity, range)
end

function P.range_changed(force, range, towers)
  for index, view in pairs(storage.dtr_placement or {}) do
    if view.force == force and view.range ~= range then
      view.range = range
      if view.preview.valid then
        resize(view.preview, range)
      else
        view.preview = area(view, index)
      end
      for unit, box in pairs(view.built) do
        local tower = towers[unit]
        if box.valid and tower and tower.entity.valid then resize(box, range, tower.entity) end
      end
    end
  end
end

return P
