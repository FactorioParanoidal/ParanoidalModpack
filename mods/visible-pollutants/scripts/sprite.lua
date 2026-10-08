local Sprite = {}

Sprite.RenderLayer = "arrow"
Sprite.OutOfBoundsSpriteTTL = 10 * 60 * 60 -- 10 minutes
Sprite.Opacity = 0.75
Sprite.MaxImportantOpacity = 0.25
Sprite.MaxNearbyOpacity = 0.4

Sprite.SpriteUpdateInterval = 1
Sprite.MaxUpdatesPerTick = 20

Sprite.BlendIn = 0.15
Sprite.DesiredStateEpsilon = 0.005

Sprite.RotationsPerSecond = 0.04
Sprite.MaxRotationsPerUpdate = 0.0015
Sprite.OrientationDelta = math.min(
  Sprite.MaxRotationsPerUpdate,
  Sprite.RotationsPerSecond * (Sprite.SpriteUpdateInterval / 60)
)

--- @class SpriteUpdateQueueItem
--- @field cell GridCell
--- @field sprite LuaRenderObject

function Sprite.init_storage()
  rendering.clear(script.mod_name)
  storage.sprites_by_surface_cells = {}
  storage.sprite_update_queue = {}
  storage.sprite_update_queue_index = 1
  storage.sprite_cleanup_queue = {}
  storage.sprite_cleanup_index = 1
end

-- Bounded sweep: expired render objects must not leave an ever-growing map cache.
function Sprite.cleanup_expired()
  local queue = storage.sprite_cleanup_queue
  local index = storage.sprite_cleanup_index
  for _ = 1, math.min(8, #queue) do
    if index > #queue then index = 1 end
    local entry = queue[index]
    if entry.sprite.valid then
      index = index + 1
    else
      local cached = storage.sprites_by_surface_cells[entry.surface]
      if cached and cached[entry.key] == entry.sprite then cached[entry.key] = nil end
      queue[index] = queue[#queue]
      queue[#queue] = nil
    end
  end
  storage.sprite_cleanup_index = index
end

--- @param surface LuaSurface
--- @param key number
--- @param sprite LuaRenderObject
local function add_to_cache(surface, key, sprite)
  if not storage.sprites_by_surface_cells[surface.index] then
    storage.sprites_by_surface_cells[surface.index] = {}
  end
  storage.sprites_by_surface_cells[surface.index][key] = sprite
  local queue = storage.sprite_cleanup_queue
  queue[#queue + 1] = { surface = surface.index, key = key, sprite = sprite }
end

--- @param surface LuaSurface
--- @param key number
--- @return LuaRenderObject | nil
local function get_from_cache(surface, key)
  if not storage.sprites_by_surface_cells[surface.index] then
    return nil
  end
  ---@type LuaRenderObject | nil
  local cached = storage.sprites_by_surface_cells[surface.index][key]
  if cached and cached.valid then
    return cached
  elseif cached then
    storage.sprites_by_surface_cells[surface.index][key] = nil
  end
  return nil
end

--- @param surface LuaSurface
--- @param cell GridCell
--- @return LuaRenderObject | nil
function Sprite.get(surface, cell)
  return get_from_cache(surface, cell.key)
end

--- @param surface LuaSurface
--- @param cell GridCell
--- @return LuaRenderObject | nil
function Sprite.ensure_existence_if_polluted(surface, cell)
  local cached = get_from_cache(surface, cell.key)
  if cached then
    cached.time_to_live = Sprite.OutOfBoundsSpriteTTL
    return cached
  end

  local pollution = Sprite.Opacity * Pollution.thickness(surface, cell.center)
  if pollution <= 0 then
    return nil
  end

  local created = rendering.draw_sprite {
    sprite = "visible-pollutants-pollution",
    render_layer = Sprite.RenderLayer,
    surface = surface,
    target = {
      x = cell.center.x + math.random(-2, 2),
      y = cell.center.y + math.random(-2, 2),
    },
    orientation = math.random(),
    time_to_live = Sprite.OutOfBoundsSpriteTTL,
    tint = Pollution.color(surface, pollution),
  }

  add_to_cache(surface, cell.key, created)
  return created
end

local function queue_sprites_near_players_for_update()
  storage.sprite_update_queue = Proximity.get_sprites_near_players()
end

function Sprite.queue_sprites_for_update()
  queue_sprites_near_players_for_update()
end

---@return boolean finished if all sprites have been updated
function Sprite.incrementally_update_sprites_in_queue()
  local queue_length = #storage.sprite_update_queue
  if queue_length <= 0 then
    storage.sprite_update_queue_index = 1
    return true
  end
  local important_cells = Proximity.get_important_cells()
  local wind_directions = {}
  local next_index = math.min(storage.sprite_update_queue_index, queue_length)
  local end_index = math.min(next_index + Sprite.MaxUpdatesPerTick, queue_length)
  for i = next_index, end_index do
    Sprite.update_sprite(storage.sprite_update_queue[i], important_cells, wind_directions)
  end
  if end_index >= queue_length then
    storage.sprite_update_queue = {}
    storage.sprite_update_queue_index = 1
    return false -- finish on the next run
  else
    storage.sprite_update_queue_index = end_index + 1
    return false
  end
end

---@param queued SpriteUpdateQueueItem
---@param important_cells table<number, ImportantCells>
function Sprite.update_sprite(queued, important_cells, wind_directions)
  if not queued.sprite or not queued.sprite.valid then return end
  local surface = queued.sprite.surface
  local surface_index = surface.index
  local direction = wind_directions and wind_directions[surface_index]
  if direction == nil then
    direction = (surface.wind_orientation + 0.5) % 1 - 0.5
    if direction > 0 then direction = 1
    elseif direction < 0 then direction = -1
    else direction = 0 end
    if wind_directions then wind_directions[surface_index] = direction end
  end

  queued.sprite.orientation = (
    queued.sprite.orientation
    + Sprite.OrientationDelta
    * math.random()
    * direction
  ) % 1

  local max_opacity = 1
  local cells = important_cells[surface_index]
  if cells then
    if cells.important[queued.cell.key] then
      max_opacity = Sprite.MaxImportantOpacity
    elseif cells.nearby[queued.cell.key] then
      max_opacity = Sprite.MaxNearbyOpacity
    end
  end

  local desired_thickness = Sprite.Opacity * Pollution.thickness(surface, queued.sprite.target.position)
  if desired_thickness > max_opacity then
    desired_thickness = max_opacity
  end

  local last_thickness = queued.sprite.color.a
  local thickness_difference = desired_thickness - last_thickness
  if thickness_difference > Sprite.DesiredStateEpsilon or thickness_difference < -Sprite.DesiredStateEpsilon then
    local blended = last_thickness * (1 - Sprite.BlendIn) + desired_thickness * Sprite.BlendIn
    queued.sprite.color = Pollution.color(surface, blended)
  end
end

return Sprite
