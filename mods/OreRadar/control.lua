-- Ore Radar: each radar has a mode chosen in a window opened by clicking the radar. In the resource
-- mode (default) a completed scan reveals a generated chunk with resources; in the signal mode it
-- marks an undiscovered ruin of AbandonedRuins-paranoidal; in the survey mode RSO Reforged marks on
-- the map the nearest field that is planned but not generated yet. The last two fall back to ore.
local WORK_PER_TICK = 8
local SCANS_PER_TICK = 4
-- Random picks per ore scan: depleted chunks are dropped, chunks unknown to the force are preferred.
local PICKS_PER_SCAN = 8
local RUINS = "AbandonedRuins-paranoidal"
local RSO = "RSO"
local SURVEY = "survey"
local NAME = "ore-radar"
local FRAME = "ore-radar-mode"
-- storage.modes[unit number] = true for radars in the signal mode, "survey" in the survey mode;
-- absent means resources.
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

local function forecast(surface, force, position)
  local interface = remote.interfaces[RSO]
  if not (interface and interface.forecast) then return false end
  return remote.call(RSO, "forecast", surface.index, force.index, position) ~= nil
end

local function modes()
  storage.modes = storage.modes or {}
  return storage.modes
end

-- false (resources), true (signals) or "survey"
local function mode_of(entity)
  return storage.modes ~= nil and storage.modes[entity.unit_number] or false
end

local function is_signal(entity)
  return mode_of(entity) == true
end

local function scan_step()
  -- A table entry is a scan kept while its ore index was being built; older saves store the radar.
  local entry = pop(storage.scans)
  if type(entry) ~= "table" then entry = {radar = entry} end
  local radar = entry.radar
  if not radar.valid then return end
  local surface, force = radar.surface, radar.force
  -- The mode is read when the scan is processed; a kept scan looks for a ruin only once.
  if not entry.tried then
    local mode = mode_of(radar)
    if mode then
      entry.tried = true
      if mode == SURVEY then
        if forecast(surface, force, radar.position) then return end
      elseif reveal_ruin(surface, force) then
        return
      end
    end
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

-- Mode window --------------------------------------------------------------------------------
-- Radars have no openable window in 2.0, so a click on the radar (linked to the "open-gui"
-- control) opens a standalone window. storage.open[player index] is the radar shown to the player.

local function ruins_available()
  local interface = remote.interfaces[RUINS]
  return interface ~= nil and interface.signal_ruin ~= nil
end

local function survey_available()
  local interface = remote.interfaces[RSO]
  return interface ~= nil and interface.forecast ~= nil
end

local function close_window(player)
  local frame = player.gui.screen[FRAME]
  if frame then frame.destroy() end
  if storage.open then storage.open[player.index] = nil end
end

local function update_window(player, entity)
  local frame = player.gui.screen[FRAME]
  if not frame then return end
  local mode = mode_of(entity)
  frame.inner.resources.state = mode == false
  frame.inner.signals.state = mode == true
  frame.inner.survey.state = mode == SURVEY
end

local function open_window(player, entity)
  close_window(player)
  local available = ruins_available()
  local frame = player.gui.screen.add{type = "frame", name = FRAME, direction = "vertical"}
  local bar = frame.add{type = "flow", direction = "horizontal"}
  bar.drag_target = frame
  bar.style.horizontal_spacing = 8
  bar.add{type = "label", style = "frame_title", caption = {"ore-radar.mode-caption"}, ignored_by_interaction = true}
  local filler = bar.add{type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true}
  filler.style.horizontally_stretchable = true
  filler.style.height = 24
  filler.style.minimal_width = 24
  bar.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close",
    tags = {ore_radar_close = true}}
  local inner = frame.add{type = "frame", name = "inner", style = "inside_shallow_frame_with_padding",
    direction = "vertical"}
  inner.add{type = "radiobutton", name = "resources", state = true, caption = {"ore-radar.mode-resources"},
    tooltip = {"ore-radar.mode-resources-tooltip"}, tags = {ore_radar_mode = false}}
  inner.add{type = "radiobutton", name = "signals", state = false, caption = {"ore-radar.mode-signals"},
    tooltip = available and {"ore-radar.mode-signals-tooltip"} or {"ore-radar.mode-signals-unavailable"},
    enabled = available, tags = {ore_radar_mode = true}}
  local survey = survey_available()
  inner.add{type = "radiobutton", name = "survey", state = false, caption = {"ore-radar.mode-survey"},
    tooltip = survey and {"ore-radar.mode-survey-tooltip"} or {"ore-radar.mode-survey-unavailable"},
    enabled = survey, tags = {ore_radar_mode = SURVEY}}
  frame.force_auto_center()
  storage.open = storage.open or {}
  storage.open[player.index] = entity
  update_window(player, entity)
  player.opened = frame
end

local function set_mode(entity, mode)
  if mode then
    modes()[entity.unit_number] = mode
    script.register_on_object_destroyed(entity)
  elseif storage.modes then
    storage.modes[entity.unit_number] = nil
  end
  for player_index, opened in pairs(storage.open or {}) do
    if opened.valid and opened == entity then update_window(game.get_player(player_index), entity) end
  end
end

script.on_event("ore-radar-open", function(event)
  local player = game.get_player(event.player_index)
  local entity = player and player.selected
  if not (entity and entity.valid and entity.name == NAME) then return end
  -- Holding an item or a ghost in the cursor means the click builds, not opens.
  if (player.cursor_stack and player.cursor_stack.valid_for_read) or player.cursor_ghost then return end
  if not (entity.force == player.force or player.force.get_friend(entity.force)) then return end
  open_window(player, entity)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local element = event.element
  if element and element.valid and element.name == FRAME then close_window(game.get_player(event.player_index)) end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.valid and event.element.tags.ore_radar_close then
    close_window(game.get_player(event.player_index))
  end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local mode = event.element.tags.ore_radar_mode
  if mode == nil then return end
  local player = game.get_player(event.player_index)
  local entity = storage.open and storage.open[player.index]
  if not (entity and entity.valid) then
    close_window(player)
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
  if source.name == NAME and destination.name == NAME then set_mode(destination, mode_of(source)) end
end)

script.on_event(defines.events.on_entity_cloned, function(event)
  local mode = mode_of(event.source)
  if mode then set_mode(event.destination, mode) end
end, {{filter = "name", name = NAME}})

local function on_built(event)
  local tags = event.tags
  if tags and tags.ore_radar_signal then set_mode(event.entity, true) end
  if tags and tags.ore_radar_survey then set_mode(event.entity, SURVEY) end
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
    if entity.valid and entity.name == NAME then
      local mode = mode_of(entity)
      if mode == true then
        blueprint.set_blueprint_entity_tag(i, "ore_radar_signal", true)
      elseif mode == SURVEY then
        blueprint.set_blueprint_entity_tag(i, "ore_radar_survey", true)
      end
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
