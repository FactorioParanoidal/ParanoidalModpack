-- Read-only projections. Native/client earned flags are deliberately not inferred.
local naming = require("prototypes.naming")
local sandbox = require("scripts.sandbox")
local M = {}
M.themes = {"factory", "quality", "energy", "logistics", "world", "stories", "after-rocket"}
M.curated = {"robinson", "handcraft", "jack-of-all-trades", "chemist", "restorer", "not-discard", "order-accepted",
  "don-quixote", "dead-calm", "hurricane", "district-control", "push-pull", "overload", "tardis", "factory-in-factory",
  "no-emissions", "factory-24-7", "quiet-sky", "plane-crash", "jumper", "prospector", "survey-confirmed",
  "archaeologist", "archaeologist-all", "first-winter", "all-seasons", "bounty-hunter", "short-circuit", "guard-breaker",
  "mo-cycle", "memory-restored", "rpg-level", "specialist", "marathon", "pilot", "evolution", "immortal",
  "spaceport", "rocket-conveyor", "houston", "liftoff", "orbital-tank", "space-miner", "porthole"}
local curated = {}
for _, id in ipairs(M.curated) do curated[id] = true end
local entries, by_id, owned_names = {}, {}, {}
for _, entry in ipairs(require("prototypes.scripted")) do
  entries[#entries + 1] = entry;by_id[entry.id] = entry
  for tier = 1, #naming.amounts(entry) do owned_names[naming.name(entry, tier)] = true end
end
for _, id in ipairs(M.curated) do assert(by_id[id], "Unknown Atlas card: " .. id) end
local themes = {resources = "factory", quality = "quality", energy = "energy", logistics = "logistics",
  combat = "world", nature = "world", challenges = "world", space = "after-rocket", character = "stories"}
local function theme(entry)
  if entry.id == "prospector" or entry.id == "survey-confirmed" or entry.id == "robinson" then return "world" end
  return themes[entry.theme] or "stories"
end
local counters = {handcraft = {"player", "crafted"}, ["handcraft-variety"] = {"player", "crafted_kind_count"},
  workshop = {"force", "repaired"}, ["electric-kills"] = {"force", "electric_kills"}, launches = {"force", "launches"},
  deaths = {"player", "tracked_deaths"}, walk = {"player", "walked"}, paint = {"force", "paints"}}
local PERSONAL = {wreck=true, handcraft=true, ["handcraft-variety"]=true, ["factory-floor"]=true, teleport=true,
  deaths=true, ["deja-vu"]=true, ["own-goal"]=true, ["car-death"]=true, walk=true, fly=true, speed=true,
  ["rpg-level"]=true, ["rpg-attribute"]=true, rename=true, ["belt-reverse"]=true, ["night-build"]=true, unstuck=true, immortal=true}
local WORLD = {evolution=true, season=true, nights=true, ["robot-crash"]=true, chunks=true, years=true}
local function scope_of(entry)
  if entry.tracker == "legendary" then return entry.params.scope == "player" and "player" or "force" end
  return PERSONAL[entry.tracker] and "player" or WORLD[entry.tracker] and "world" or "force"
end
local function done(unlocked, player, force, name, scope)
  if not unlocked then return false end
  if scope == "world" then return unlocked.world and unlocked.world[name] == true end
  local own, index
  if scope == "player" then own, index = unlocked.players, player.index
  else own, index = unlocked.forces, force.index end
  return own and own[index] and own[index][name] == true
end
local function display_force(player)
  local storage_force, force = get_display_storage_force(player.force)
  return force or player.force, storage_force
end
function M.cards(player, archive)
  local force = display_force(player)
  local state = storage.mxlr
  local unlocked = state and state.unlocked
  local rows = {}
  for _, entry in ipairs(entries) do
    if archive or curated[entry.id] then
      local amounts, completed, available, names = naming.amounts(entry), 0, 0, {}
      local next_target
      local scope = scope_of(entry)
      for tier = 1, #amounts do
        local name = naming.name(entry, tier)
        if prototypes.achievement[name] then available = available + 1;names[#names + 1] = name end
        if done(unlocked, player, force, name, scope) then completed = completed + 1
        elseif next_target == nil then next_target = amounts[tier] end
      end
      local secret = entry.id == "memory-restored" and completed == 0
      local value
      local spec = counters[entry.tracker]
      if state and spec then
        local data
        if spec[1] == "player" then data = state.players[player.index] else data = state.forces[force.index] end
        local field = entry.tracker == "workshop" and entry.params and entry.params.normalized and "normalized_repairs" or spec[2]
        value = data and data[field]
      end
      if entry.tracker == "owner-facts" then
        local data = state and state.forces[force.index]
        if data and data.owner_facts and data.owner_facts[entry.params.source] then value = 1 end
      end
      local prototype = names[1] and prototypes.achievement[names[1]]
      local title = secret and {"atlas.hidden-title"} or curated[entry.id] and {"mxlr-name." .. entry.id}
        or prototype and prototype.localised_name or entry.id
      local status = completed == #amounts and "complete" or available < #amounts and "unavailable"
        or (value ~= nil or completed > 0) and "progress" or "unknown"
      if available == #amounts and completed < #amounts and entry.tracker == "immortal" then
        local history = state and state.players[player.index]
        if history and (history.deaths or 0) > 0 then status = "failed"
        elseif history and history.deaths_known == true then status = "eligible" end
      end
      if completed < #amounts and status ~= "failed" and state and state.broken and state.broken[entry.tracker] then status = "stopped" end
      local setting = settings.global["mxlr-scripted-achievements"]
      if available == #amounts and completed < #amounts and status ~= "failed" and status ~= "stopped"
        and setting and setting.value == false then status = "paused" end
      rows[#rows + 1] = {id = entry.id, translation_id = entry.id .. (secret and ":hidden" or ""),
        title = title, theme = theme(entry), scope = scope, status = status, completed = completed, stages = #amounts,
        value = value, target = next_target or amounts[#amounts],
        description = secret and {"atlas.hidden-description"} or prototype and prototype.localised_description or {"atlas.unavailable"},
        sprite = not secret and names[1] and "achievement/" .. names[1]}
    end
  end
  return rows
end
local record_index, native_index
local function product_name(value)
  if type(value) == "string" then return value end
  return value and value.name
end
local function build_native_index()
  local records, native = {}, {}
  for name, prototype in pairs(prototypes.achievement) do
    local kind = prototype.type
    if kind == "produce-achievement" or kind == "produce-per-hour-achievement" then
      local item, fluid = product_name(prototype.item_product), product_name(prototype.fluid_product)
      local family, product = item and "item" or "fluid", item or fluid
      if product then
        local key = family .. "/" .. product
        local own = records[key]
        if not own then own = {id = key, family = family, name = product, native_stages = 0};records[key] = own end
        own.native_stages = own.native_stages + 1
      end
    elseif not owned_names[name] then native[#native + 1] = name end
  end
  record_index, native_index = {}, native
  for _, record in pairs(records) do record_index[#record_index + 1] = record end
  table.sort(record_index, function(a, b) return a.id < b.id end);table.sort(native_index)
end
function M.records()
  if not record_index then build_native_index() end
  local rows = {}
  for _, record in ipairs(record_index) do
    local prototype = prototypes[record.family][record.name]
    if prototype then rows[#rows + 1] = {id = record.id, translation_id = record.id, title = prototype.localised_name,
      family = record.family, name = record.name, native_stages = record.native_stages, sprite = record.family .. "/" .. record.name} end
  end
  return rows
end
function M.native_archive()
  if not native_index then build_native_index() end
  local rows = {}
  for _, name in ipairs(native_index) do
    local prototype = prototypes.achievement[name]
    rows[#rows + 1] = {id = name, translation_id = name, title = prototype.localised_name,
      description = prototype.localised_description, status = "native", theme = "stories", sprite = "achievement/" .. name}
  end
  return rows
end
function M.chronicle(player)
  local _, force = display_force(player)
  local rows = {}
  for _, milestone in ipairs(force and force.complete_milestones or {}) do
    local family = milestone.type == "technology" and "technology" or milestone.type == "kill" and "entity"
      or milestone.type:find("fluid", 1, true) and "fluid" or "item"
    local prototype = prototypes[family][milestone.name]
    rows[#rows + 1] = {id = tostring(milestone.id or milestone.name), translation_id = family .. "/" .. milestone.name,
      title = prototype and prototype.localised_name or milestone.name, quantity = milestone.quantity,
      tick = milestone.completion_tick, lower_bound_tick = milestone.lower_bound_tick,
      sprite = prototype and family .. "/" .. milestone.name}
  end
  table.sort(rows, function(a, b)
    if a.tick ~= b.tick then return (a.tick or -1) > (b.tick or -1) end
    return a.id < b.id
  end)
  return rows
end
-- Records remain consumers of the existing Milestones cycle: never a second statistics reader.
local requests, cache, requested_by_force = {}, {}, {}
function M.request_records(player, rows)
  local force = display_force(player)
  requests[player.index] = {force = force.name, force_index = force.index, rows = rows}
end
function M.clear_request(player_index) requests[player_index] = nil end
function M.record_value(player, row)
  local force = display_force(player)
  local values = cache[force.index]
  return values and values[row.id]
end
add_statistics_consumer{
  needs = function(force_name)
    local force = game.forces[force_name]
    if not (force and force.valid) or sandbox.is_force_name(force_name) then return end
    local needed
    for index, request in pairs(requests) do
      local player = game.get_player(index)
      if player and player.valid and player.connected and player.gui.screen.pd_atlas and request.force == force_name and request.force_index == force.index then
        needed = needed or {item_in = {}, item_out = {}, fluid_in = {}, fluid_out = {}}
        for _, row in ipairs(request.rows) do
          needed[row.family .. "_in"][row.name] = true;needed[row.family .. "_out"][row.name] = true
        end
      end
    end
    requested_by_force[force_name] = needed and {force = force.index, names = needed} or nil
    return needed
  end,
  receive = function(force_name, totals)
    local snapshot = requested_by_force[force_name]
    local force = game.forces[force_name]
    if not (snapshot and force and force.valid and force.index == snapshot.force) then return end
    local own = cache[force.index] or {};cache[force.index] = own
    for _, family in ipairs({"item", "fluid"}) do
      local produced, consumed = totals[family .. "_in"], totals[family .. "_out"]
      if produced and consumed then
        for name in pairs(snapshot.names[family .. "_in"]) do
          -- Completed sparse dictionary reads mean zero, but only for names actually requested.
          own[family .. "/" .. name] = {produced = produced[name] or 0, consumed = consumed[name] or 0, tick = game.tick}
        end
      end
    end
  end,
}
return M
