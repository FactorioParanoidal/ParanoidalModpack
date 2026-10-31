-- Paranoidal Ruins: random ruins in new chunks (scripts/spawner.lua), the Paranoidal ruin set with
-- the "base" set, the discovery journal and the legendary ruins (legendary/).
--
-- The ruin set is built from local tables on every load, so on_load stays deterministic and
-- writes nothing to storage.

local spawner = require("scripts.spawner")
local balance_base = require("ruins.base-balance")
local legendary = require("legendary.init")

local ERASER = "Delete-Chunk-Tool-reforged"

local own = {
  small = require("ruins.small"),
  medium = require("ruins.medium"),
  large = require("ruins.large"),
}

-- Discovery radius around a ruin's border, in tiles.
local DISCOVERY_MARGIN = 20
local CHECK_INTERVAL = 120

---@type table<string, string> "<size>/<ruin name>" -> "danger"|"rare"
local tags = {}
---@type table<string, integer> size -> number of distinct ruins in the current set
local totals = {}

local function setting(name)
  local s = settings.global[name]
  return s and s.value
end

local function has_hostile(ruin)
  for _, e in pairs(ruin.entities or {}) do
    if e[3] and e[3].force and e[3].force ~= "neutral" then return true end
  end
  return false
end

-- Factorio 2.0 has no "curved-rail". The 1.1 rail ruins of the "base" set are rebuilt with the
-- legacy rails that 2.0 keeps for old saves: same geometry and positions, they connect to each
-- other and to orthogonal straight rails, and give ordinary rails when mined.
local DIAGONAL = { northeast = true, southeast = true, southwest = true, northwest = true }
local function port_rails(ruin)
  for _, entity in pairs(ruin.entities or {}) do
    local name, opts = entity[1], entity[3]
    if name == "curved-rail" or name == "curved-rail-remnants" then
      entity[1] = "legacy-" .. name
    elseif (name == "straight-rail" or name == "straight-rail-remnants") and opts and DIAGONAL[opts.dir] then
      entity[1] = "legacy-" .. name
    end
  end
end

-- The "base" set (vanilla ruins of "Abandoned Ruins - Base" 0.1.8) with Paranoidal salvage limits
-- and 2.0 rails, prepared once per load.
local base = require("ruins.base.ruin_set")
for size, ruins in pairs(base) do
  for _, ruin in pairs(ruins) do
    balance_base(size, ruin)
    port_rails(ruin)
  end
end

local function build_set()
  local set = { small = {}, medium = {}, large = {} }
  tags, totals = {}, {}
  if setting("pd-ruins-include-base") then
    for size, ruins in pairs(base) do
      for _, ruin in ipairs(ruins) do set[size][#set[size] + 1] = ruin end
    end
  end
  for size, ruins in pairs(own) do
    for _, ruin in ipairs(ruins) do set[size][#set[size] + 1] = ruin end
  end
  for size, ruins in pairs(set) do
    totals[size] = #ruins
    for _, ruin in pairs(ruins) do
      local key = size .. "/" .. (ruin.name or "?")
      tags[key] = ruin.pd_tag or (has_hostile(ruin) and "danger" or nil)
    end
  end
  spawner.set = set
end

-- Discovery journal --------------------------------------------------------------------

local function chunk_key(surface_index, x, y)
  return surface_index .. ":" .. math.floor(x / 32) .. ":" .. math.floor(y / 32)
end

local function journal()
  storage.pending = storage.pending or {}   -- chunk key -> list of spawned, undiscovered ruins
  storage.found = storage.found or {}       -- force index -> {["size/name"] = count}
  return storage.pending, storage.found
end

local function ruin_caption(size, name)
  local stem = name:gsub("%d+$", "")
  return { "?", { "pd-ruin-name." .. name }, { "pd-ruin-name." .. stem }, { "pd-ruins.unknown-name", name } }
end

---A ruin of the set was spawned (spawner.on_spawned).
local function on_ruin_spawned(data)
  local pending = journal()
  local key = chunk_key(data.surface.index, data.center.x, data.center.y)
  pending[key] = pending[key] or {}
  table.insert(pending[key], {
    name = data.ruin_name, size = data.size, x = data.center.x, y = data.center.y,
    half = data.half_size or 8, surface = data.surface.index,
  })
end
spawner.on_spawned = on_ruin_spawned

local function count_found(found_force, size)
  local n = 0
  for key in pairs(found_force) do
    if size == nil then
      if key:sub(1, 10) ~= "legendary/" then n = n + 1 end
    elseif key:sub(1, #size + 1) == size .. "/" then
      n = n + 1
    end
  end
  return n
end

local function total_types()
  local n = 0
  for _, t in pairs(totals) do n = n + t end
  return n
end

local ICONS = { danger = "signal-skull", rare = "signal-star" }
local SIGNAL_ICON = { type = "virtual", name = "signal-question-mark" }

-- Radar signals: ruin.signals[force index] is true while the force waits for the chunk to be
-- charted, then the "?" chart tag. storage.signal_wait[force index][chunk key] marks waiting chunks.
local function clear_signals(ruin)
  for _, tag in pairs(ruin.signals or {}) do
    if tag ~= true and tag.valid then tag.destroy() end
  end
  ruin.signals = nil
end

local function place_signal(force, ruin)
  local surface = game.get_surface(ruin.surface)
  local tag = surface and force.add_chart_tag(surface, { position = { ruin.x, ruin.y }, icon = SIGNAL_ICON })
  if tag then ruin.signals[force.index] = tag end
  return tag ~= nil
end

---@param surface_index integer
---@param force_index integer
---@return MapPosition? center of a random undiscovered ruin not yet signalled to the force
local function signal_ruin(surface_index, force_index)
  local force = game.forces[force_index]
  if not (force and storage.pending) then return nil end
  local choice, seen = nil, 0
  for _, bucket in pairs(storage.pending) do
    for _, ruin in pairs(bucket) do
      if ruin.surface == surface_index and not (ruin.signals and ruin.signals[force_index]) then
        seen = seen + 1
        if math.random(seen) == 1 then choice = ruin end
      end
    end
  end
  if not choice then return nil end
  choice.signals = choice.signals or {}
  choice.signals[force_index] = true
  local cx, cy = math.floor(choice.x / 32), math.floor(choice.y / 32)
  local surface = game.get_surface(surface_index)
  if not (surface and force.is_chunk_charted(surface, { cx, cy }) and place_signal(force, choice)) then
    storage.signal_wait = storage.signal_wait or {}
    storage.signal_wait[force_index] = storage.signal_wait[force_index] or {}
    storage.signal_wait[force_index][chunk_key(surface_index, choice.x, choice.y)] = true
  end
  return { x = choice.x, y = choice.y }
end

local function on_chunk_charted(event)
  local wait = storage.signal_wait
  local list = wait and wait[event.force.index]
  if not list then return end
  local key = event.surface_index .. ":" .. event.position.x .. ":" .. event.position.y
  if not list[key] then return end
  list[key] = nil
  if next(list) == nil then wait[event.force.index] = nil end
  for _, ruin in pairs(storage.pending and storage.pending[key] or {}) do
    if ruin.signals and ruin.signals[event.force.index] == true then place_signal(event.force, ruin) end
  end
end

local function discover(player, ruin)
  clear_signals(ruin)
  local _, found = journal()
  local force = player.force
  found[force.index] = found[force.index] or {}
  local key = ruin.size .. "/" .. ruin.name
  local first = found[force.index][key] == nil
  found[force.index][key] = (found[force.index][key] or 0) + 1
  -- tick of the first ruin this force found (journal statistics for other mods)
  storage.first_found = storage.first_found or {}
  storage.first_found[force.index] = storage.first_found[force.index] or game.tick

  if setting("pd-ruins-discovery-messages") then
    local caption = ruin_caption(ruin.size, ruin.name)
    if first then
      force.print({ "pd-ruins.discovered-new", player.name, caption, count_found(found[force.index]), total_types() })
    else
      player.print({ "pd-ruins.discovered-again", caption })
    end
    if tags[key] == "danger" then player.print({ "pd-ruins.danger-hint" }) end
  end
  if setting("pd-ruins-map-tags") then
    local surface = game.surfaces[ruin.surface]
    if surface then
      force.add_chart_tag(surface, {
        position = { ruin.x, ruin.y },
        icon = { type = "virtual", name = ICONS[tags[key]] or "signal-map-marker" },
      })
    end
  end
end

local function check_players()
  local pending = storage.pending
  if not pending or next(pending) == nil then return end
  for _, player in pairs(game.connected_players) do
    if player.valid and player.character and player.character.valid then
      local pos, surface = player.position, player.surface_index
      local cx, cy = math.floor(pos.x / 32), math.floor(pos.y / 32)
      for dx = -1, 1 do
        for dy = -1, 1 do
          local key = surface .. ":" .. (cx + dx) .. ":" .. (cy + dy)
          local bucket = pending[key]
          if bucket then
            for i = #bucket, 1, -1 do
              local ruin = bucket[i]
              local reach = ruin.half + DISCOVERY_MARGIN
              if math.abs(ruin.x - pos.x) <= reach and math.abs(ruin.y - pos.y) <= reach then
                table.remove(bucket, i)
                discover(player, ruin)
              end
            end
            if #bucket == 0 then pending[key] = nil end
          end
        end
      end
    end
  end
end

local function show_progress(command)
  local player = command.player_index and game.get_player(command.player_index)
  if not player then return end
  local _, found = journal()
  local mine = found[player.force.index] or {}
  player.print({ "pd-ruins.progress", count_found(mine), total_types(),
    count_found(mine, "small"), totals.small or 0,
    count_found(mine, "medium"), totals.medium or 0,
    count_found(mine, "large"), totals.large or 0 })
  -- no spoilers: the legendary ruins are counted only after the first one is found
  local legendary_found = legendary.found(mine)
  if legendary_found > 0 then
    player.print({ "pd-legendary.progress", legendary_found, legendary.total() })
  else
    player.print({ "pd-legendary.progress-none" })
  end
end

-- Admin command for tests and showcases: /legendary-spawn <name> places a legendary ruin a few
-- chunks east of the player, ignoring the distance rule. Without a name it lists the names.
local function spawn_legendary_command(command)
  local player = command.player_index and game.get_player(command.player_index)
  if not player then return end
  if not player.admin then
    player.print({ "pd-legendary.admin-only" })
    return
  end
  local name = command.parameter and command.parameter:match("^%s*(%S+)")
  local kind = name and legendary.kinds.by_name[name]
  if not kind then
    local names = {}
    for _, k in ipairs(legendary.kinds.list) do names[#names + 1] = k.name end
    player.print({ "pd-legendary.spawn-help", table.concat(names, ", ") })
    return
  end
  local offset = kind.size / 2 + 48
  local site = legendary.site.force_spawn(player.surface, { x = player.position.x + offset, y = player.position.y }, name)
  if site then
    legendary.spawned_by_command(player)
    player.print({ "pd-legendary.spawned", { "pd-legendary-name." .. name },
      string.format("[gps=%d,%d,%s]", site.x, site.y, player.surface.name) })
  end
end

-- Life cycle --------------------------------------------------------------------------------

local function load_state()
  spawner.read_settings()
  build_set()
  spawner.sync_tick()
end

script.on_init(function()
  spawner.init_storage()
  load_state()
  spawner.apply_diplomacy()
  journal()
  legendary.on_init()
end)

script.on_load(load_state)

script.on_configuration_changed(function()
  spawner.init_storage()
  spawner.apply_diplomacy()
  journal()
  legendary.on_configuration_changed()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  local name = event.setting
  if name == "current-ruin-set" or name:sub(1, 6) == "ruins-" then
    local old_interval = spawner.interval()
    spawner.read_settings()
    if name == "ruins-enemy-not-cease-fire" then spawner.apply_diplomacy() end
    if name == "ruins-spawn-tick-seconds" then spawner.set_interval(old_interval) end
  elseif name == "pd-ruins-include-base" then
    build_set()
  end
  legendary.on_setting_changed(name)
end)

script.on_event(defines.events.on_force_created, function()
  spawner.apply_diplomacy()
  legendary.on_force_created()
end)

-- One question to Delete-Chunk-Tool-reforged per chunk, and only when a ruin would be placed.
script.on_event(defines.events.on_chunk_generated, function(event)
  local asked, deleted = false, false
  local function deleted_before()
    if not asked then
      asked = true
      local eraser = remote.interfaces[ERASER]
      deleted = (eraser and eraser.is_regenerated and remote.call(ERASER, "is_regenerated", event.surface.index, event.position)) == true
    end
    return deleted
  end
  spawner.on_chunk_generated(event, deleted_before)
  legendary.on_chunk_generated(event, deleted_before)
end)

script.on_event({ defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area }, spawner.on_selected_area)

-- A deleted surface leaves the exclusion list (it may come back as a normal one).
script.on_event(defines.events.on_pre_surface_deleted, function(event)
  local surface = game.get_surface(event.surface_index)
  if surface and storage.excluded then storage.excluded[surface.name] = nil end
end)

-- Clearing removes the ruins too, so their journal entries and signals go with them.
script.on_event({ defines.events.on_surface_deleted, defines.events.on_surface_cleared }, function(event)
  legendary.on_surface_removed(event.surface_index)
  local pending = storage.pending
  if not pending then return end
  local prefix = event.surface_index .. ":"
  for key in pairs(pending) do
    if key:sub(1, #prefix) == prefix then pending[key] = nil end
  end
  for force_index, list in pairs(storage.signal_wait or {}) do
    for key in pairs(list) do
      if key:sub(1, #prefix) == prefix then list[key] = nil end
    end
    if next(list) == nil then storage.signal_wait[force_index] = nil end
  end
end)

script.on_event(defines.events.on_chunk_charted, on_chunk_charted)

script.on_nth_tick(CHECK_INTERVAL, check_players)

-- Legendary ruins (legendary/init.lua) ------------------------------------------------------
script.on_event(defines.events.on_tick, legendary.on_tick)
script.on_event(defines.events.on_built_entity, legendary.on_built)
script.on_event(defines.events.on_robot_built_entity, legendary.on_built)
script.on_event(defines.events.script_raised_built, legendary.on_built)
script.on_event(defines.events.on_player_built_tile, legendary.on_built_tile)
script.on_event(defines.events.on_robot_built_tile, legendary.on_built_tile)
script.on_event(defines.events.on_player_mined_tile, legendary.on_mined_tile)
script.on_event(defines.events.on_robot_mined_tile, legendary.on_mined_tile)
script.on_event(defines.events.on_player_mined_entity, legendary.on_mined)
script.on_event(defines.events.on_robot_mined_entity, legendary.on_mined)
script.on_event(defines.events.on_marked_for_deconstruction, legendary.on_marked_for_deconstruction,
  { { filter = "name", name = "pd-legend-lever" } })
script.on_event(defines.events.on_object_destroyed, legendary.on_object_destroyed)
script.on_event(defines.events.on_player_changed_position, legendary.on_player_changed_position)
script.on_event(defines.events.on_pre_player_died, legendary.on_pre_player_died)
script.on_event(defines.events.on_player_respawned, legendary.on_player_respawned)
script.on_event(defines.events.on_chunk_deleted, legendary.on_chunk_deleted)
do
  -- relics that die in battle (not mined) are gone: fact "relic-died"
  local filters = {}
  for _, name in ipairs(legendary.relic_prototypes()) do filters[#filters + 1] = { filter = "name", name = name } end
  if #filters > 0 then script.on_event(defines.events.on_entity_died, legendary.on_entity_died, filters) end
end

-- Old mines for RSO Reforged: these ruins of the set are placed next to rich ore fields.
local MINES = {
  small = { "pd-geologist-box" },
  medium = { "pd-miners-village", "pd-prospect-drill" },
  large = { "pd-mining-camp" },
}

local function spawn_mine(surface_index, center, size)
  local names = MINES[size]
  local surface = game.get_surface(surface_index)
  if not (names and surface and type(center) == "table") then return false end
  if legendary.reserved(surface_index, center, 40) then return false end
  local pick = names[math.random(#names)]
  for _, ruin in ipairs(own[size]) do
    if ruin.name == pick then return spawner.spawn_now(ruin, size, { x = center.x, y = center.y }, surface) end
  end
  return false
end

-- Interface of the former core "Abandoned Ruins" that other mods call: surfaces without ruins
-- (minime, Blueprint Sandboxes), claim-tool force changes (carbon-capture2), spawned ruins
-- (Flammable Oils traps). Subscribe to the events in on_init and on_load.
remote.add_interface("AbandonedRuins", {
  -- Data: entity (LuaEntity, its new force is entity.force), force (LuaForce, the old force).
  get_on_entity_force_changed_event = function() return spawner.force_changed_event end,
  -- Data: surface, center, half_size, size, ruin_set ("paranoidal"), ruin_name.
  get_on_ruin_spawned_event = function() return spawner.ruin_spawned_event end,
  -- A surface whose name contains this string gets no ruins (internal or hidden surfaces only).
  exclude_surface = spawner.exclude_surface,
  reinclude_surface = spawner.reinclude_surface,
})

-- Read-only statistics for diagnostics and other mods, ruin signals for OreRadar and old mines
-- for RSO Reforged.
remote.add_interface("AbandonedRuins-paranoidal", {
  ---@return {pending: integer, types: table<string, integer>, found: table<integer, integer>}
  get_stats = function()
    local pending = 0
    for _, bucket in pairs(storage.pending or {}) do pending = pending + #bucket end
    local found = {}
    for force_index, list in pairs(storage.found or {}) do found[force_index] = count_found(list) end
    return { pending = pending, types = totals, found = found }
  end,
  -- Discovery summary of a force for the base journal of paranoidal-CodexRPG. As in /ruins, legendary
  -- ruins are counted only after the first one is found (no spoilers).
  get_force_summary = function(force_index)
    local mine = (storage.found or {})[force_index] or {}
    local visits = 0
    for key, n in pairs(mine) do
      if key:sub(1, 10) ~= "legendary/" then visits = visits + n end
    end
    local sizes = {}
    for _, size in ipairs({ "small", "medium", "large" }) do
      sizes[size] = { found = count_found(mine, size), total = totals[size] or 0 }
    end
    local legendary_found = legendary.found(mine)
    local solved, first_legend, first_won = 0, nil, nil
    if legendary_found > 0 and storage.legend then
      for _, site in pairs(storage.legend.sites or {}) do
        local t = site.found and site.found[force_index]
        if type(t) == "number" and (not first_legend or t < first_legend) then first_legend = t end
        if site.state == "solved" and t then
          solved = solved + 1
          if type(site.solved) == "number" and (not first_won or site.solved < first_won) then first_won = site.solved end
        end
      end
    end
    return {
      found_types = count_found(mine), total_types = total_types(), found_total = visits, sizes = sizes,
      legendary_found = legendary_found, legendary_solved = solved,
      legendary_total = legendary_found > 0 and legendary.total() or nil,
      -- ticks; nil when unknown
      first_found = (storage.first_found or {})[force_index],
      legendary_first_found = first_legend, legendary_first_solved = first_won,
    }
  end,
  -- Used by OreRadar: marks a random undiscovered ruin on the surface with a "?" chart tag for the
  -- force (once the chunk is charted) and returns its center. The tag is removed on discovery.
  signal_ruin = signal_ruin,
  -- Used by RSO Reforged: places an old mine ruin of the given size ("small", "medium", "large")
  -- centered at the position. Returns true if it was spawned (the journal records it as usual).
  spawn_mine = spawn_mine,
  -- Legendary ruins: custom event with facts about them (found, solved, feats, relics...), see
  -- legendary/feats.lua. MxlChievements-Reforged builds its achievements on it.
  get_on_legendary_event = function() return legendary.feats_event end,
  -- Legendary ruins: is the position inside (or within `margin` tiles of) a legendary site?
  legendary_reserved = function(surface_index, position, margin)
    return legendary.reserved(surface_index, position, margin)
  end,
  -- Legendary ruins: chunk rectangles {x1, y1, x2, y2} (inclusive) of the sites of the surface that
  -- are not lost; deleting any of these chunks loses the site. Used by Delete-Chunk-Tool-reforged.
  legendary_chunks = function(surface_index)
    return legendary.site.chunk_rects(surface_index)
  end,
  -- Legendary ruins: plans the named legendary ruin around the position (distance rules ignored).
  -- Returns the site center or nil.
  spawn_legendary = function(surface_index, position, name)
    local surface = game.get_surface(surface_index)
    local site = surface and legendary.site.force_spawn(surface, position, name)
    return site and { x = site.x, y = site.y } or nil
  end,
})

commands.add_command("ruins", { "pd-ruins.command-help" }, show_progress)
commands.add_command("legendary-spawn", { "pd-legendary.spawn-command-help" }, spawn_legendary_command)
