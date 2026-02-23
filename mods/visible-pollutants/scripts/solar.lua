local Solar = {}

Solar.OcclusionEnabled = false
Solar.ChunkUpdateInterval = 5
Solar.MaxUpdatesPerTick = 10
Solar.QualityEfficiencyIncrease = 0.3 -- +30% for each level
Solar.MaxEfficiencyReduction = 0.5 -- resulting in 50% of the original production of a normal panel

--- @class SolarSurface
--- @field index number
--- @field base_effectiveness number Amount of pure solar power on this surface
--- @field reduced_effectiveness number Amount of solar power on this surface, each value reduced by pollution
--- @field cells_by_key table<number, SolarCell> Chunks with Solar power on this Surface, indexed by their hashed key

--- @class SolarCell
--- @field key number
--- @field center MapPosition Center position of the chunk in map coordinates
--- @field pollution number Amount of pollution in this chunk
--- @field base_effectiveness number Amount of pure solar power in this chunk
--- @field reduced_effectiveness number Amount of solar power in this chunk, each value reduced by pollution
--- @field panels number Amount of panels in this chunk
--- @field panels_by_quality table<number, number> Amount of panels in this chunk, indexed by quality level

--- @class SolarChunkQueueItem
--- @field surface_index number
--- @field cell_key number

--- @class SolarRegistration
--- @field surface_index number
--- @field cell_key number
--- @field quality number

function Solar.init_storage()
  storage.solar_surfaces = {}
  storage.solar_registrations = {}
  storage.solar_pollution_update_queue = {}
  storage.solar_pollution_update_queue_index = 1
  storage.solar_pollution_update_queue_surface_index = 1
  storage.solar_full_synchronize_tick = 0
end

---@param quality number
local function calculate_base_effectiveness(quality)
  return 1 + quality * Solar.QualityEfficiencyIncrease
end

---@param pollution number
local function calculate_effectiveness_reduction(pollution)
  local reduced = pollution * Solar.MaxEfficiencyReduction
  if reduced < 0 then return 0 end
  if reduced > Solar.MaxEfficiencyReduction then return Solar.MaxEfficiencyReduction end
  return reduced
end

---@param surface LuaSurface
---@return SolarSurface
local function get_or_create_surface_data(surface)
  if not storage.solar_surfaces then storage.solar_surfaces = {} end
  ---@type SolarSurface | nil
  local surface_data = storage.solar_surfaces[surface.index]
  if not surface_data then
    surface_data = {
      index = surface.index,
      base_effectiveness = 0,
      reduced_effectiveness = 0,
      cells_by_key = {},
    }
    storage.solar_surfaces[surface.index] = surface_data
  end
  return surface_data
end

---@param surface_data SolarSurface
---@param position MapPosition
---@return SolarCell
local function get_or_create_cell_data(surface_data, position)
  local key = Grid.key_from_map_position(position)
  ----@type SolarCell | nil
  local cell_data = surface_data.cells_by_key[key]
  if not cell_data then
    cell_data = {
      key = key,
      center = position, -- not actually, but it does not matter
      pollution = Pollution.thickness(game.surfaces[surface_data.index], position),
      base_effectiveness = 0,
      reduced_effectiveness = 0,
      panels = 0,
      panels_by_quality = {},
    }
    surface_data.cells_by_key[key] = cell_data
  end
  return cell_data
end

---@param cell_data SolarCell
---@param quality number
---@param panel LuaEntity
local function register_panel(cell_data, quality, panel)
  local registration = script.register_on_object_destroyed(panel)
  storage.solar_registrations[registration] = {
    surface_index = panel.surface_index,
    cell_key = cell_data.key,
    quality = quality,
  }
end

---@param surface_data SolarSurface
local function update_solar_multiplier(surface_data)
  local surface = game.surfaces[surface_data.index]
  if not surface then
    log("Solar Surface referencing an unknown Surface index: " .. surface_data.index)
    return
  end
  if Solar.OcclusionEnabled and surface_data.base_effectiveness > 0 then
    local multiplier = surface_data.reduced_effectiveness / surface_data.base_effectiveness
    if multiplier < 0 then multiplier = 0 end
    surface.solar_power_multiplier = multiplier
  else
    surface.solar_power_multiplier = 1
  end
end

---@param surface_data SolarSurface
---@param cell_data SolarCell
---@param quality number
local function add_panel_to_surface(surface_data, cell_data, quality)
  local base_effectiveness = calculate_base_effectiveness(quality)
  local reduced_effectiveness = base_effectiveness - calculate_effectiveness_reduction(cell_data.pollution)

  surface_data.base_effectiveness = surface_data.base_effectiveness + base_effectiveness
  surface_data.reduced_effectiveness = surface_data.reduced_effectiveness + reduced_effectiveness

  cell_data.base_effectiveness = cell_data.base_effectiveness + base_effectiveness
  cell_data.reduced_effectiveness = cell_data.reduced_effectiveness + reduced_effectiveness
  cell_data.panels = cell_data.panels + 1
  cell_data.panels_by_quality[quality] = (cell_data.panels_by_quality[quality] or 0) + 1
end

---@param surface_data SolarSurface
---@param cell_data SolarCell
---@param quality number
local function remove_panel_from_surface(surface_data, cell_data, quality)
  local base_effectiveness = calculate_base_effectiveness(quality)
  local reduced_effectiveness = base_effectiveness - calculate_effectiveness_reduction(cell_data.pollution)

  surface_data.base_effectiveness = surface_data.base_effectiveness - base_effectiveness
  surface_data.reduced_effectiveness = surface_data.reduced_effectiveness - reduced_effectiveness

  cell_data.panels = cell_data.panels - 1
  cell_data.panels_by_quality[quality] = (cell_data.panels_by_quality[quality] or 1) - 1

  if cell_data.panels <= 0 then
    surface_data.cells_by_key[cell_data.key] = nil
  else
    cell_data.base_effectiveness = cell_data.base_effectiveness - base_effectiveness
    cell_data.reduced_effectiveness = cell_data.reduced_effectiveness - reduced_effectiveness
  end
end

---@param panel LuaEntity
function Solar.on_panel_placed(panel)
  local surface_data = get_or_create_surface_data(panel.surface)
  local cell_data = get_or_create_cell_data(surface_data, panel.position)
  local quality = panel.quality.level
  register_panel(cell_data, quality, panel)
  add_panel_to_surface(surface_data, cell_data, quality)
  update_solar_multiplier(surface_data)
end

---@param from MapPosition
---@param panel LuaEntity
function Solar.on_panel_moved(from, panel)
  local surface_data = get_or_create_surface_data(panel.surface)
  local old_cell = get_or_create_cell_data(surface_data, from)
  local cell = get_or_create_cell_data(surface_data, panel.position)
  if old_cell.key == cell.key then
    return
  end
  local quality = panel.quality.level
  remove_panel_from_surface(surface_data, old_cell, quality)
  add_panel_to_surface(surface_data, cell, quality)
  update_solar_multiplier(surface_data)
end

---@param registration_key number
function Solar.on_panel_destroyed(registration_key)
  ---@type SolarRegistration | nil
  local registration = storage.solar_registrations[registration_key]
  if not registration then
    return
  end
  storage.solar_registrations[registration_key] = nil

  ---@type SolarSurface | nil
  local surface_data = storage.solar_surfaces[registration.surface_index]
  if not surface_data then
    log("Registered Object referenced a Surface that we are not tracking: " .. serpent.block(registration))
    return
  end

  ---@type SolarCell | nil
  local cell_data = surface_data.cells_by_key[registration.cell_key]
  if not cell_data then
    log("Registered Object referenced a Cell that we are not tracking: " .. serpent.block(registration))
    return
  end

  remove_panel_from_surface(surface_data, cell_data, registration.quality)
  update_solar_multiplier(surface_data)
end

---@param cell_data SolarCell
local function recompute_cell(cell_data)
  cell_data.base_effectiveness = 0
  cell_data.reduced_effectiveness = 0
  for quality, count in pairs(cell_data.panels_by_quality) do
    local base_effectiveness = calculate_base_effectiveness(quality)
    local reduced_effectiveness = base_effectiveness - calculate_effectiveness_reduction(cell_data.pollution)
    cell_data.base_effectiveness = cell_data.base_effectiveness + (base_effectiveness * count)
    cell_data.reduced_effectiveness = cell_data.reduced_effectiveness + (reduced_effectiveness * count)
  end
end

---@param surface_data SolarSurface
---@param include_cells boolean
local function recompute_surface(surface_data, include_cells)
  surface_data.base_effectiveness = 0
  surface_data.reduced_effectiveness = 0
  for _, cell_data in pairs(surface_data.cells_by_key) do
    if include_cells then recompute_cell(cell_data) end
    surface_data.base_effectiveness = surface_data.base_effectiveness + cell_data.base_effectiveness
    surface_data.reduced_effectiveness = surface_data.reduced_effectiveness + cell_data.reduced_effectiveness
  end
end

---@param surface LuaSurface
---@param surface_data SolarSurface
---@param cell_data SolarCell
local function update_cell_pollution(surface, surface_data, cell_data)
  cell_data.pollution = Pollution.thickness(surface, cell_data.center)
  local last_base_effectiveness = cell_data.base_effectiveness
  local last_reduced_effectiveness = cell_data.reduced_effectiveness
  recompute_cell(cell_data)

  local base_effectiveness_delta = cell_data.base_effectiveness - last_base_effectiveness
  local reduced_effectiveness_delta = cell_data.reduced_effectiveness - last_reduced_effectiveness
  surface_data.base_effectiveness = surface_data.base_effectiveness + base_effectiveness_delta
  surface_data.reduced_effectiveness = surface_data.reduced_effectiveness + reduced_effectiveness_delta
  update_solar_multiplier(surface_data)
end

---@param chunk SolarChunkQueueItem
local function update_queued_chunk(chunk)
  local surface = game.surfaces[chunk.surface_index]
  if not surface then
    log("Solar Chunk referencing an unknown Surface index: " .. chunk.surface_index)
    return
  end
  local surface_data = get_or_create_surface_data(surface)
  local cell_data = surface_data.cells_by_key[chunk.cell_key]
  if not cell_data then
    log("Solar Chunk referencing an unknown Cell key: " .. chunk.cell_key)
    return
  end
  update_cell_pollution(surface, surface_data, cell_data)
end

function Solar.queue_chunks_for_update()
  ---@type SolarChunkQueueItem[]
  local queue = {}
  local queue_index = 1
  for surface_index, surface_data in pairs(storage.solar_surfaces) do
    for cell_key, cell in pairs(surface_data.cells_by_key) do
      queue[queue_index] = {
        surface_index = surface_index,
        cell_key = cell.key,
      }
      queue_index = queue_index + 1
    end
    recompute_surface(surface_data, false)
  end
  storage.solar_pollution_update_queue = queue
  storage.solar_pollution_update_queue_index = 1
end

---@return boolean finished if all chunks have been updated
function Solar.incrementally_update_chunks_in_queue()
  local queue_length = #storage.solar_pollution_update_queue
  if queue_length <= 0 then
    storage.solar_pollution_update_queue_index = 1
    return true
  end
  local next_index = math.min(storage.solar_pollution_update_queue_index, queue_length)
  local end_index = math.min(next_index + Solar.MaxUpdatesPerTick, queue_length)
  for i = next_index, end_index do
    update_queued_chunk(storage.solar_pollution_update_queue[i])
  end
  if end_index >= queue_length then
    storage.solar_pollution_update_queue = {}
    storage.solar_pollution_update_queue_index = 1
    return false -- finish on the next run
  else
    storage.solar_pollution_update_queue_index = end_index + 1
    return false
  end
end

function Solar.full_recompute()
  for _, surface in pairs(game.surfaces) do
    local surface_data = get_or_create_surface_data(surface)
    recompute_surface(surface_data, true)
    update_solar_multiplier(surface_data)
  end
end

function Solar.full_synchronize()
  if storage.solar_full_synchronize_tick == game.tick then return end
  Solar.init_storage()
  storage.solar_full_synchronize_tick = game.tick
  for _, surface in pairs(game.surfaces) do
    local surface_data = get_or_create_surface_data(surface)
    if Solar.OcclusionEnabled then
      local panels = surface.find_entities_filtered({
        type = "solar-panel",
      })
      for _, panel in pairs(panels) do
        local cell_data = get_or_create_cell_data(surface_data, panel.position)
        local quality = panel.quality.level
        register_panel(cell_data, quality, panel)
        add_panel_to_surface(surface_data, cell_data, quality)
      end
    end
    update_solar_multiplier(surface_data)
  end
end

---@param setting string
function Solar.on_setting_changed(setting)
  if setting == Settings.SolarEfficiencyReduction then
    Solar.full_recompute()
  elseif setting == Settings.EnableSolarOcclusion
      or setting == Settings.MinConsideredPollution
      or setting == Settings.MaxConsideredPollution
      or setting == Settings.PollutionRangeExponent
  then
    Solar.full_synchronize()
  end
end

return Solar
