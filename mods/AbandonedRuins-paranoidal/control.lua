-- Paranoidal ruin set for "Abandoned Ruins - Updated" plus a discovery journal.
--
-- Ruin sets are not saved by the core, so the set is registered again in on_init and on_load.
-- Everything done in on_load must be deterministic and must not write storage.

local SET_NAME = "paranoidal"
local CORE = "AbandonedRuins"

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
    if size == nil or key:sub(1, #size + 1) == size .. "/" then n = n + 1 end
  end
  return n
end

local function total_types()
  local n = 0
  for _, t in pairs(totals) do n = n + t end
  return n
end

local ICONS = { danger = "signal-skull", rare = "signal-star" }

local function discover(player, ruin)
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

script.on_init(on_init)
script.on_load(function()
  build_set()
  subscribe()
end)
script.on_configuration_changed(function()
  build_set()
  journal()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "pd-ruins-include-base" then build_set() end
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  local pending = storage.pending
  if not pending then return end
  local prefix = event.surface_index .. ":"
  for key in pairs(pending) do
    if key:sub(1, #prefix) == prefix then pending[key] = nil end
  end
end)

script.on_nth_tick(CHECK_INTERVAL, check_players)

-- Read-only statistics for diagnostics and other mods.
remote.add_interface("AbandonedRuins-paranoidal", {
  ---@return {pending: integer, types: table<string, integer>, found: table<integer, integer>}
  get_stats = function()
    local pending = 0
    for _, bucket in pairs(storage.pending or {}) do pending = pending + #bucket end
    local found = {}
    for force_index, list in pairs(storage.found or {}) do found[force_index] = count_found(list) end
    return { pending = pending, types = totals, found = found }
  end,
})

commands.add_command("ruins", { "pd-ruins.command-help" }, show_progress)
