-- Paranoidal ruin set for "Abandoned Ruins - Updated" plus a discovery journal.
--
-- Ruin sets are not saved by the core, so the set is registered again in on_init and on_load.
-- Everything done in on_load must be deterministic and must not write storage.

local SET_NAME = "paranoidal"
local CORE = "AbandonedRuins"
local balance_base = require("ruins.base-balance")
local legendary = require("legendary.init")

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
-- remote.call returns a copy, so the "base" set itself is not changed.
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

local function build_set()
  local set = { small = {}, medium = {}, large = {} }
  tags, totals = {}, {}
  if setting("pd-ruins-include-base") and script.active_mods["AbandonedRuins-base"] then
    local base = remote.call(CORE, "get_ruin_set", "base")
    for size, ruins in pairs(base or {}) do
      set[size] = set[size] or {}
      for _, ruin in pairs(ruins) do
        balance_base(size, ruin)
        port_rails(ruin)
        set[size][#set[size] + 1] = ruin
      end
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
  remote.call(CORE, "add_ruin_sets", SET_NAME, set)
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

local function on_ruin_spawned(event)
  if event.ruin_set ~= SET_NAME or not (event.surface and event.surface.valid) then return end
  local pending = journal()
  local key = chunk_key(event.surface.index, event.center.x, event.center.y)
  pending[key] = pending[key] or {}
  table.insert(pending[key], {
    name = event.ruin_name, size = event.size, x = event.center.x, y = event.center.y,
    half = event.half_size or 8, surface = event.surface.index,
  })
end

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

local function subscribe()
  if remote.interfaces[CORE] and remote.interfaces[CORE]["get_on_ruin_spawned_event"] then
    script.on_event(remote.call(CORE, "get_on_ruin_spawned_event"), on_ruin_spawned)
  end
end

local function on_init()
  build_set()
  subscribe()
  journal()
end

script.on_init(function()
  on_init()
  legendary.on_init()
end)
script.on_load(function()
  build_set()
  subscribe()
end)
script.on_configuration_changed(function()
  build_set()
  journal()
  legendary.on_configuration_changed()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "pd-ruins-include-base" then build_set() end
  legendary.on_setting_changed(event.setting)
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
script.on_event(defines.events.on_chunk_generated, legendary.on_chunk_generated)
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
script.on_event(defines.events.on_force_created, legendary.on_force_created)
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
  local core = remote.interfaces[CORE]
  if not (names and core and core.spawn_ruin) or setting("current-ruin-set") ~= SET_NAME then return false end
  if legendary.reserved(surface_index, center, 40) then return false end
  local pick = names[math.random(#names)]
  for _, ruin in ipairs(own[size]) do
    if ruin.name == pick then
      return remote.call(CORE, "spawn_ruin", ruin, size, center, surface_index, SET_NAME) == true
    end
  end
  return false
end

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
