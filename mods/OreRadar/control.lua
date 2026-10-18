-- Ore Radar: each radar has a mode chosen in a panel next to its window. In the resource mode
-- (default) a completed scan reveals a generated chunk with resources; in the signal mode it marks
-- an undiscovered ruin of AbandonedRuins-paranoidal and falls back to ore when no ruin is left.
local WORK_PER_TICK = 8
local SCANS_PER_TICK = 4
-- Random picks per ore scan: depleted chunks are dropped, chunks unknown to the force are preferred.
local PICKS_PER_SCAN = 8
local RUINS = "AbandonedRuins-paranoidal"
local NAME = "ore-radar"
local FRAME = "ore-radar-mode"
-- storage.modes[unit number] = true for radars in the signal mode; absent means resources.
-- The radar window type is not documented for 2.0, so the panel is anchored to both candidates;
-- the engine shows only the one matching the opened window.
local ANCHORS = {"entity_with_energy_source_gui", "generic_on_off_entity_gui"}
local on_tick

local function queue()
  return {first = 1, last = 0}
end

local function push(q, value)
  q.last = q.last + 1
  q[q.last] = value
end

local function pop(q)
  local value = q[q.first]
  q[q.first] = nil
  q.first = q.first + 1
  if q.first > q.last then q.first, q.last = 1, 0 end
  return value
end

local function pending()
  return storage.work and (storage.work.last > 0 or storage.scans.last > 0)
end

local function wake()
  script.on_event(defines.events.on_tick, on_tick)
end

local function key(p)
  return p.x .. ":" .. p.y
end

local function area(p)
  return {{p.x * 32, p.y * 32}, {p.x * 32 + 32, p.y * 32 + 32}}
end

local function remove_chunk(index, position)
  local k = key(position)
  local i = index.lookup[k]
  if not i then return end
  local last = index.chunks[#index.chunks]
  index.chunks[i] = last
  index.lookup[key(last)] = i
  index.chunks[#index.chunks] = nil
  index.lookup[k] = nil
end

local function get_index(surface_index)
  local index = storage.surfaces[surface_index]
  if not index then
    index = {chunks = {}, lookup = {}, ready = true, pending = 0}
    storage.surfaces[surface_index] = index
  end
  return index
end

local function index_chunk(surface, position)
  if not surface.is_chunk_generated(position) then return end
  local index = get_index(surface.index)
  if surface.count_entities_filtered{area = area(position), type = "resource", limit = 1} > 0 then
    local k = key(position)
    if not index.lookup[k] then
      index.chunks[#index.chunks + 1] = {x = position.x, y = position.y}
      index.lookup[k] = #index.chunks
    end
  else
    remove_chunk(index, position)
  end
end

local function work_step()
  local q = storage.work
  local job = q[q.first]
  local surface = game.get_surface(job.surface_index)
  if not surface then pop(q); return end
  -- Clearing a surface invalidates work for its previous resource index.
  if job.index and storage.surfaces[job.surface_index] ~= job.index then pop(q); return end
  if job.iterator then
    if not job.iterator.valid then job.index.ready = true; pop(q); return end
    local position = job.iterator()
    if position then
      index_chunk(surface, position)
    else
      job.index.ready = true
      pop(q)
    end
  elseif job.positions then
    local index = storage.surfaces[job.surface_index]
    if index then remove_chunk(index, job.positions[job.cursor]) end
    job.cursor = job.cursor + 1
    if job.cursor > #job.positions then pop(q) end
  else
    index_chunk(surface, job.position)
    job.index.pending = job.index.pending - 1
    pop(q)
  end
end

local function chart_chunk(force, surface, position)
  -- chart's upper bound is inclusive; stop inside this chunk.
  local bounds = area(position)
  bounds[2][1], bounds[2][2] = bounds[2][1] - 1, bounds[2][2] - 1
  force.chart(surface, bounds)
end

local function reveal_ore(surface, force, index)
  local fallback
  for _ = 1, PICKS_PER_SCAN do
    local count = #index.chunks
    if count == 0 then break end
    local position = index.chunks[math.random(count)]
    if surface.count_entities_filtered{area = area(position), type = "resource", limit = 1} == 0 then
      -- Swap with the last entry instead of shifting a potentially large ore index.
      remove_chunk(index, position)
    elseif not force.is_chunk_charted(surface, position) then
      chart_chunk(force, surface, position)
      return true
    else
      fallback = fallback or position
    end
  end
  -- Every pick was already known: refresh one of them, as the 1.1 radar did.
  if fallback then chart_chunk(force, surface, fallback) end
  return fallback ~= nil
end

local function reveal_ruin(surface, force)
  local interface = remote.interfaces[RUINS]
  if not (interface and interface.signal_ruin) then return false end
  local position = remote.call(RUINS, "signal_ruin", surface.index, force.index)
  if not position then return false end
  chart_chunk(force, surface, {x = math.floor(position.x / 32), y = math.floor(position.y / 32)})
  force.print({"ore-radar.unusual-signal",
    string.format("[gps=%d,%d,%s]", math.floor(position.x), math.floor(position.y), surface.name)})
  return true
end

local function modes()
  storage.modes = storage.modes or {}
  return storage.modes
end

local function is_signal(entity)
  return storage.modes ~= nil and storage.modes[entity.unit_number] == true
end

local function scan_step()
  -- A table entry is a scan kept while its ore index was being built; older saves store the radar.
  local entry = pop(storage.scans)
  if type(entry) ~= "table" then entry = {radar = entry} end
  local radar = entry.radar
  if not radar.valid then return end
  local surface, force = radar.surface, radar.force
  -- The mode is read when the scan is processed; a kept scan looks for a ruin only once.
  if not entry.tried and is_signal(radar) then
    entry.tried = true
    if reveal_ruin(surface, force) then return end
  end
  local index = storage.surfaces[surface.index]
  if index and (not index.ready or (#index.chunks == 0 and index.pending > 0)) then
    -- Retain the paid scan and let ready surfaces take their turn.
    push(storage.scans, entry)
    return
  end
  if index then reveal_ore(surface, force, index) end
end

on_tick = function()
  local remaining = WORK_PER_TICK
  local attempts = math.min(SCANS_PER_TICK, storage.scans.last - storage.scans.first + 1)
  for _ = 1, attempts do
    scan_step()
    remaining = remaining - 1
  end
  for _ = 1, remaining do
    if storage.work.last == 0 then break end
    work_step()
  end
  if not pending() then script.on_event(defines.events.on_tick, nil) end
end

local function rebuild()
  modes()
  storage.surfaces = {}
  storage.work = queue()
  storage.scans = storage.scans or queue()
  for _, surface in pairs(game.surfaces) do
    local index = get_index(surface.index)
    index.ready = false
    push(storage.work, {surface_index = surface.index, iterator = surface.get_chunks(), index = index})
  end
  if pending() then wake() else script.on_event(defines.events.on_tick, nil) end
end

script.on_init(rebuild)
script.on_configuration_changed(function(event)
  -- Depleted and deleted chunks are dropped lazily, so only a new radar version needs a full rescan.
  if not storage.surfaces or event.mod_changes[script.mod_name] then rebuild() end
end)
script.on_load(function()
  if pending() then wake() end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
  local index = get_index(event.surface.index)
  index.pending = index.pending + 1
  push(storage.work, {surface_index = event.surface.index, position = event.position, index = index})
  wake()
end)

script.on_event(defines.events.on_sector_scanned, function(event)
  push(storage.scans, {radar = event.radar})
  wake()
end, {{filter = "name", name = NAME}})

-- Mode panel ----------------------------------------------------------------------------------

local function ruins_available()
  local interface = remote.interfaces[RUINS]
  return interface ~= nil and interface.signal_ruin ~= nil
end

local function destroy_panels(player)
  for _, anchor in ipairs(ANCHORS) do
    local frame = player.gui.relative[FRAME .. "-" .. anchor]
    if frame then frame.destroy() end
  end
end

local function update_panels(player, entity)
  local signal = is_signal(entity)
  for _, anchor in ipairs(ANCHORS) do
    local frame = player.gui.relative[FRAME .. "-" .. anchor]
    if frame then
      local inner = frame.inner
      inner.resources.state = not signal
      inner.signals.state = signal
    end
  end
end

local function create_panels(player, entity)
  destroy_panels(player)
  local available = ruins_available()
  for _, anchor in ipairs(ANCHORS) do
    local frame = player.gui.relative.add{
      type = "frame", name = FRAME .. "-" .. anchor, caption = {"ore-radar.mode-caption"},
      direction = "vertical",
      anchor = {gui = defines.relative_gui_type[anchor], position = defines.relative_gui_position.right,
        name = NAME}
    }
    local inner = frame.add{type = "frame", name = "inner", style = "inside_shallow_frame_with_padding",
      direction = "vertical"}
    inner.add{type = "radiobutton", name = "resources", state = true, caption = {"ore-radar.mode-resources"},
      tooltip = {"ore-radar.mode-resources-tooltip"}, tags = {ore_radar_mode = false}}
    inner.add{type = "radiobutton", name = "signals", state = false, caption = {"ore-radar.mode-signals"},
      tooltip = available and {"ore-radar.mode-signals-tooltip"} or {"ore-radar.mode-signals-unavailable"},
      enabled = available, tags = {ore_radar_mode = true}}
  end
  update_panels(player, entity)
end

local function set_mode(entity, signal)
  if signal then
    modes()[entity.unit_number] = true
    script.register_on_object_destroyed(entity)
  elseif storage.modes then
    storage.modes[entity.unit_number] = nil
  end
  for _, player in pairs(game.connected_players) do
    if player.opened == entity then update_panels(player, entity) end
  end
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == NAME then
    create_panels(game.get_player(event.player_index), entity)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == NAME then destroy_panels(game.get_player(event.player_index)) end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local element = event.element
  local mode = element.tags.ore_radar_mode
  if mode == nil then return end
  local player = game.get_player(event.player_index)
  local entity = player.opened
  if not (entity and entity.object_name == "LuaEntity" and entity.valid and entity.name == NAME) then
    destroy_panels(player)
    return
  end
  set_mode(entity, mode)
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  if storage.modes and event.type == defines.target_type.entity and event.useful_id then
    storage.modes[event.useful_id] = nil
  end
end)

-- Copy-paste, cloning and blueprints keep the mode.
script.on_event(defines.events.on_entity_settings_pasted, function(event)
  local source, destination = event.source, event.destination
  if source.name == NAME and destination.name == NAME then set_mode(destination, is_signal(source)) end
end)

script.on_event(defines.events.on_entity_cloned, function(event)
  if is_signal(event.source) then set_mode(event.destination, true) end
end, {{filter = "name", name = NAME}})

local function on_built(event)
  local tags = event.tags
  if tags and tags.ore_radar_signal then set_mode(event.entity, true) end
end
script.on_event(defines.events.on_built_entity, on_built, {{filter = "name", name = NAME}})
script.on_event(defines.events.on_robot_built_entity, on_built, {{filter = "name", name = NAME}})
script.on_event(defines.events.script_raised_built, on_built, {{filter = "name", name = NAME}})

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  if not storage.modes or next(storage.modes) == nil then return end
  local blueprint = event.stack
  if not (blueprint and blueprint.valid_for_read and blueprint.is_blueprint) then blueprint = event.record end
  if not (blueprint and blueprint.valid) then return end
  for i, entity in pairs(event.mapping.get()) do
    if entity.valid and entity.name == NAME and is_signal(entity) then
      blueprint.set_blueprint_entity_tag(i, "ore_radar_signal", true)
    end
  end
end)

script.on_event(defines.events.on_chunk_deleted, function(event)
  if #event.positions == 0 then return end
  push(storage.work, {surface_index = event.surface_index, positions = event.positions, cursor = 1})
  wake()
end)

script.on_event({defines.events.on_surface_deleted, defines.events.on_surface_cleared}, function(event)
  storage.surfaces[event.surface_index] = nil
end)
