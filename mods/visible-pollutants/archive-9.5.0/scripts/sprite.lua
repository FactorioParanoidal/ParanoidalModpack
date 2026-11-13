local Sprite = {}
local Visuals = require("scripts.visuals")

Sprite.RenderLayer = "smoke"
Sprite.OutOfBoundsSpriteTTL = 10 * 60 * 60
Sprite.Opacity = 0.75
Sprite.MaxImportantOpacity = 0.25
Sprite.MaxNearbyOpacity = 0.4
Sprite.SpriteUpdateInterval = 1
Sprite.MaxUpdatesPerTick = 20
Sprite.MaxCreatesPerTick = 4
Sprite.MaxMaintenancePerTick = 8
Sprite.CacheLimit = 8192 -- includes clean sampled cells, not just render objects
Sprite.SampleInterval = 60
Sprite.UpdateInterval = 3
Sprite.BlendIn = 0.15
Sprite.DesiredStateEpsilon = 0.005
Sprite.BlendReferenceTicks = 2
Sprite.MotionEnabled = false
Sprite.WindHalfLifeTicks = 120
Sprite.FootprintHalfExtent = Visuals.FootprintHalfExtent
Sprite.LegacyFadeTicks = 60 -- one-time old-resource fade, independent of user blend

function Sprite.prepare_storage()
  if not storage.sprites_by_surface_cells then storage.sprites_by_surface_cells = {} end
  if not storage.sprite_update_ticks then storage.sprite_update_ticks = {} end
  if not storage.visual_cache then
    local legacy = storage.sprite_cleanup_queue or {}
    storage.visual_cache = { slots = {}, by_surface = {}, sweep = 1, generation = 1,
      legacy = legacy, legacy_index = 1, legacy_count = #legacy }
    -- Keep old render handles until the bounded maintenance worker adopts them.
    storage.sprite_cleanup_queue = nil
    storage.sprite_cleanup_index = nil
    storage.sprite_update_queue = nil
    storage.sprite_update_queue_index = nil
  end
  local cache = storage.visual_cache
  if cache.pending_footprints == nil then
    -- Existing slots are conservatively old until normal work classifies them.
    cache.pending_footprints = #cache.slots
  end
  return cache
end

function Sprite.get_footprint_half_extent()
  local cache = Sprite.prepare_storage()
  if cache.pending_footprints > 0 or cache.legacy_index <= cache.legacy_count then
    return math.max(Visuals.LegacyFootprintHalfExtent, Sprite.FootprintHalfExtent)
  end
  return Sprite.FootprintHalfExtent
end

function Sprite.init_storage()
  -- Fresh game only; settings/configuration changes do not clear rendering.
  rendering.clear(script.mod_name)
  storage.sprites_by_surface_cells = {}
  storage.sprite_update_ticks = {}
  storage.sprite_cleanup_queue = nil
  storage.visual_cache = nil
  Sprite.prepare_storage()
end

function Sprite.invalidate_samples()
  local cache = Sprite.prepare_storage()
  cache.generation = cache.generation + 1
end

local function forget_update_time(surface_index, key, sprite)
  local times = storage.sprite_update_ticks
  local row = times and times[surface_index]
  local state = row and row[key]
  if state and state.sprite == sprite then
    row[key] = nil
    if not next(row) then times[surface_index] = nil end
  end
end

local function update_time(surface_index, key, sprite)
  if not storage.sprite_update_ticks then storage.sprite_update_ticks = {} end
  local times = storage.sprite_update_ticks
  if not times[surface_index] then times[surface_index] = {} end
  local state = times[surface_index][key]
  if not state or state.sprite ~= sprite then
    state = { sprite = sprite, tick = game.tick - Sprite.BlendReferenceTicks }
    times[surface_index][key] = state
  end
  return state
end

local function drop_render(surface_index, key, sprite)
  local row = storage.sprites_by_surface_cells[surface_index]
  if row and row[key] == sprite then
    row[key] = nil
    if not next(row) then storage.sprites_by_surface_cells[surface_index] = nil end
  end
  forget_update_time(surface_index, key, sprite)
  if sprite.valid then sprite.destroy() end
end

local function release_footprint(cache, entry)
  if not entry.current_footprint then
    entry.current_footprint = true
    cache.pending_footprints = cache.pending_footprints - 1
  end
end

local function is_legacy(sprite)
  return sprite and sprite.valid and sprite.type == "sprite" and sprite.sprite == Visuals.LegacySprite
end

local function wants_animation(surface_index, cell)
  return Sprite.MotionEnabled and Visuals.for_cell(surface_index, cell) == Visuals.sprite_name("veil")
end

local function sync_animation_motion(sprite)
  if not sprite or not sprite.valid or sprite.type ~= "animation" then return end
  local speed = Sprite.MotionEnabled and Visuals.AnimationSpeed or 0
  if sprite.animation_speed ~= speed then
    -- Rendering's phase is tick * speed + offset. Preserve it when pausing.
    local phase = (game.tick * sprite.animation_speed + sprite.animation_offset) % Visuals.FrameCount
    sprite.animation_offset = (phase - game.tick * speed) % Visuals.FrameCount
    sprite.animation_speed = speed
  end
end

local function settle_footprint(cache, entry)
  if not is_legacy(entry.sprite) then release_footprint(cache, entry) end
end

local function remove_entry(cache, entry, stats)
  release_footprint(cache, entry)
  if entry.sprite then
    if entry.sprite.valid and stats then stats.removals = stats.removals + 1 end
    drop_render(entry.surface, entry.key, entry.sprite)
  end
  local row = cache.by_surface[entry.surface]
  if row and row[entry.key] == entry then
    row[entry.key] = nil
    if not next(row) then cache.by_surface[entry.surface] = nil end
  end
  local slot, last = entry.slot, cache.slots[#cache.slots]
  cache.slots[slot] = last
  last.slot = slot
  cache.slots[#cache.slots] = nil
end

local function insert_entry(cache, surface, cell, sprite)
  local entry = { surface = surface.index, surface_object = surface, key = cell.key,
    cell = cell, sprite = sprite, seen = game.tick, slot = #cache.slots + 1,
    current_footprint = not is_legacy(sprite) }
  if not entry.current_footprint then cache.pending_footprints = cache.pending_footprints + 1 end
  if not cache.by_surface[surface.index] then cache.by_surface[surface.index] = {} end
  cache.by_surface[surface.index][cell.key] = entry
  cache.slots[entry.slot] = entry
  return entry
end

local function entry_for(cache, surface_index, key)
  local row = cache.by_surface[surface_index]
  return row and row[key]
end

function Sprite.get(surface, cell)
  local row = storage.sprites_by_surface_cells[surface.index]
  local sprite = row and row[cell.key]
  if sprite and sprite.valid and sprite.surface == surface then return sprite end
  return nil
end

function Sprite.cleanup_expired(stats, retention)
  local cache = Sprite.prepare_storage()
  local remaining = Sprite.MaxMaintenancePerTick
  while remaining > 0 and cache.legacy_index <= cache.legacy_count do
    local index = cache.legacy_index
    local old = cache.legacy[index]
    cache.legacy[index] = nil
    cache.legacy_index = index + 1
    remaining = remaining - 1
    if stats then stats.legacy_steps = stats.legacy_steps + 1 end
    if old then
      local sprite = old.sprite
      local row = storage.sprites_by_surface_cells[old.surface]
      local existing = entry_for(cache, old.surface, old.key)
      if sprite.valid and row and row[old.key] == sprite and not existing
          and #cache.slots < Sprite.CacheLimit then
        insert_entry(cache, sprite.surface, Grid.from_map_position(sprite.target.position), sprite)
      elseif not existing or existing.sprite ~= sprite then
        if sprite.valid and stats then stats.removals = stats.removals + 1 end
        drop_render(old.surface, old.key, sprite)
      end
    end
  end
  if cache.legacy_index > cache.legacy_count then cache.legacy = nil end
  local count = math.min(remaining, #cache.slots)
  local index = cache.sweep
  for _ = 1, count do
    if index > #cache.slots then index = 1 end
    local entry = cache.slots[index]
    local idle_limit = math.min(Sprite.OutOfBoundsSpriteTTL, retention or 120)
    if not entry.surface_object.valid or (entry.sprite and not entry.sprite.valid)
        or game.tick - entry.seen > idle_limit or #cache.slots > Sprite.CacheLimit then
      remove_entry(cache, entry, stats)
    else
      sync_animation_motion(entry.sprite) -- bounded convergence even outside current demand
      settle_footprint(cache, entry)
      index = index + 1
    end
  end
  cache.sweep = index
end

local function maximum_opacity(surface_index, key, important)
  local cells = important and important[surface_index]
  if cells and cells.important[key] then return Sprite.MaxImportantOpacity end
  if cells and cells.nearby[key] then return Sprite.MaxNearbyOpacity end
  return 1
end

local function create_render(surface, cell, thickness, important)
  local opacity = math.min(Sprite.Opacity * thickness, maximum_opacity(surface.index, cell.key, important))
  if opacity <= 0 then return nil end
  local name, target, orientation, phase = Visuals.for_cell(surface.index, cell)
  local spec = {
    render_layer = Sprite.RenderLayer, surface = surface, target = target, orientation = orientation,
    time_to_live = Sprite.OutOfBoundsSpriteTTL, light_mode = "occluder",
    tint = Pollution.color(surface, 0), -- enter through the normal elapsed-tick blend
  }
  local sprite
  if wants_animation(surface.index, cell) then
    spec.animation, spec.animation_offset, spec.animation_speed = Visuals.Animation, phase, Visuals.AnimationSpeed
    sprite = rendering.draw_animation(spec)
  else
    spec.sprite = name
    sprite = rendering.draw_sprite(spec)
  end
  local row = storage.sprites_by_surface_cells[surface.index] or {}
  storage.sprites_by_surface_cells[surface.index] = row
  row[cell.key] = sprite
  update_time(surface.index, cell.key, sprite).tick = game.tick
  return sprite
end

-- Low-level entry point retained for focused lifecycle fixtures. Runtime uses service().
function Sprite.ensure_existence_if_polluted(surface, cell)
  local cache = Sprite.prepare_storage()
  local sprite = Sprite.get(surface, cell)
  if sprite then return sprite end
  local entry = entry_for(cache, surface.index, cell.key)
  if not entry then
    if #cache.slots + math.max(0, cache.legacy_count - cache.legacy_index + 1) >= Sprite.CacheLimit then return nil end
    entry = insert_entry(cache, surface, cell)
  elseif entry.sprite then
    drop_render(surface.index, cell.key, entry.sprite)
  end
  entry.sprite = create_render(surface, cell, Pollution.thickness(surface, cell.center))
  settle_footprint(cache, entry)
  return entry.sprite
end

local function update_motion(sprite, cell, state, elapsed, wind)
  sync_animation_motion(sprite)
  if not Sprite.MotionEnabled or is_legacy(sprite) then return end
  local surface = sprite.surface
  local vector = wind and wind[surface.index]
  if not vector then
    local speed = math.max(0, surface.wind_speed)
    local distance = Visuals.MotionRadius * speed / (speed + 0.01)
    local angle = surface.wind_orientation * 2 * math.pi
    vector = { x = math.sin(angle) * distance, y = -math.cos(angle) * distance }
    if wind then wind[surface.index] = vector end
  end
  if not state.base_target then
    local _, target = Visuals.for_cell(surface.index, cell)
    state.base_target = target
  end
  local base, position = state.base_target, sprite.target.position
  local blend = 1 - math.pow(0.5, elapsed / Sprite.WindHalfLifeTicks)
  sprite.target = { x = position.x + (base.x + vector.x - position.x) * blend,
    y = position.y + (base.y + vector.y - position.y) * blend }
end

function Sprite.update_sprite(queued, important_cells, wind_directions, sampled_thickness)
  if not queued.sprite or not queued.sprite.valid then return end
  local surface, sprite = queued.sprite.surface, queued.sprite
  local state = update_time(surface.index, queued.cell.key, sprite)
  local elapsed = math.max(0, game.tick - state.tick)
  state.tick = game.tick
  update_motion(sprite, queued.cell, state, elapsed, wind_directions)
  if sprite.render_layer ~= Sprite.RenderLayer then sprite.render_layer = Sprite.RenderLayer end
  local thickness = sampled_thickness
  if thickness == nil then thickness = Pollution.thickness(surface, queued.cell.center) end
  local desired = math.min(Sprite.Opacity * thickness, maximum_opacity(surface.index, queued.cell.key, important_cells))
  local previous = sprite.color.a
  local legacy = is_legacy(sprite)
  local animation = wants_animation(surface.index, queued.cell)
  if legacy or (sprite.type == "animation") ~= animation then
    -- Freeze/fade before changing kind; service() accounts for retirement and
    -- creates the replacement on a later budgeted visit, never a second layer.
    if not state.upgrade_tick then
      state.upgrade_tick, state.upgrade_alpha = game.tick, previous
    end
    local remaining = math.max(0, 1 - (game.tick - state.upgrade_tick) / Sprite.LegacyFadeTicks)
    local alpha = math.min(previous, state.upgrade_alpha * remaining)
    sprite.color = Pollution.color(surface, alpha)
    if alpha == 0 then
      if desired == 0 or not legacy or animation then
        drop_render(surface.index, queued.cell.key, sprite)
      else
        local name, target, orientation = Visuals.for_cell(surface.index, queued.cell)
        sprite.sprite, sprite.target, sprite.orientation = name, target, orientation
        sprite.x_scale, sprite.y_scale = 1, 1
        state.upgrade_tick, state.upgrade_alpha = nil, nil
      end
    end
    return
  end
  -- A toggle back to this object's kind cancels the pending fade from its current alpha.
  state.upgrade_tick, state.upgrade_alpha = nil, nil
  -- Keep tint premultiplied via Pollution.color; visual gain is deliberately 1.
  local blend = 1 - math.pow(1 - Sprite.BlendIn, elapsed / Sprite.BlendReferenceTicks)
  local blended = previous + (desired - previous) * blend
  if math.abs(desired - blended) <= Sprite.DesiredStateEpsilon then blended = desired end
  if desired == 0 and blended == 0 then
    drop_render(surface.index, queued.cell.key, sprite)
  elseif blended ~= previous then
    sprite.color = Pollution.color(surface, blended)
  end
end

-- One visit is at most one pollution read and one render creation/update.
-- Returns false only when this cell must wait for the next tick's work budget.
function Sprite.service(surface, cell, important, wind, stats)
  local cache = Sprite.prepare_storage()
  local entry = entry_for(cache, surface.index, cell.key)
  if entry and entry.surface_object ~= surface then return true, false end
  if not entry then
    -- A legacy render is adopted by maintenance, never duplicated by discovery.
    if Sprite.get(surface, cell) then return true, true end
    if #cache.slots + math.max(0, cache.legacy_count - cache.legacy_index + 1) >= Sprite.CacheLimit then
      stats.capacity_waits = stats.capacity_waits + 1
      return true
    end
    if stats.work >= Sprite.MaxUpdatesPerTick then return false end
    entry = insert_entry(cache, surface, cell)
  end
  entry.seen = game.tick
  if entry.sprite and not entry.sprite.valid then
    drop_render(surface.index, cell.key, entry.sprite)
    entry.sprite = nil
  end
  local sample_due = not entry.sample_tick or game.tick - entry.sample_tick >= Sprite.SampleInterval
      or entry.generation ~= cache.generation
  local update_due = entry.sprite and (not entry.update_tick or game.tick - entry.update_tick >= Sprite.UpdateInterval)
  local create_due = not entry.sprite and (sample_due or (entry.thickness or 0) > 0)
  if not sample_due and not update_due and not create_due then return true, entry.sprite ~= nil end
  if stats.work >= Sprite.MaxUpdatesPerTick then return false end
  if create_due and stats.creates >= Sprite.MaxCreatesPerTick then return false end
  stats.work = stats.work + 1
  if sample_due then
    entry.thickness = Pollution.thickness(surface, cell.center)
    entry.sample_tick, entry.generation = game.tick, cache.generation
    stats.samples = stats.samples + 1
  end
  if entry.sprite then
    local sprite = entry.sprite
    Sprite.update_sprite(entry, important, wind, entry.thickness)
    stats.updates = stats.updates + 1
    if not sprite.valid then
      stats.removals = stats.removals + 1
      entry.sprite = nil
    elseif not entry.refreshed or game.tick - entry.refreshed >= 60 then
      sprite.time_to_live = Sprite.OutOfBoundsSpriteTTL
      entry.refreshed = game.tick
    end
    entry.update_tick = game.tick
  elseif entry.thickness > 0 then
    entry.sprite = create_render(surface, cell, entry.thickness, important)
    entry.update_tick, entry.refreshed = game.tick, game.tick
    stats.creates = stats.creates + 1
  end
  settle_footprint(cache, entry)
  return true, entry.sprite ~= nil
end

return Sprite
