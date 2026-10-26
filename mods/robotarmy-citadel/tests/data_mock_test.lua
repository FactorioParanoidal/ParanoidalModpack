-- Data stage dry run without the game: lua tests/data_mock_test.lua <mock-raw.lua>
-- The mock raw is a Lua file with the base prototypes the citadel copies (made from a data-raw
-- dump). Runs data.lua, data-updates.lua and data-final-fixes.lua of the mod against it and checks
-- the new prototypes: names, required fields, sprite layers with files, animation frame counts,
-- the replicator droid copies and their loot. Not a Factorio check: the engine validates more.
package.path = "./?.lua;" .. package.path

local raw = dofile(arg[1])

local function deepcopy(t, seen)
  if type(t) ~= "table" then return t end
  seen = seen or {}
  if seen[t] then return seen[t] end
  local out = {}
  seen[t] = out
  for k, v in pairs(t) do out[deepcopy(k, seen)] = deepcopy(v, seen) end
  return out
end
package.preload["util"] = function()
  return {table = {deepcopy = deepcopy}, by_pixel = function(x, y) return {x / 32, y / 32} end}
end

local added = {}
data = {raw = raw}
function data:extend(list)
  for _, p in ipairs(list) do
    assert(p.type and p.name, "prototype without type/name")
    raw[p.type] = raw[p.type] or {}
    raw[p.type][p.name] = p
    added[#added + 1] = p
  end
end
mods = {["robotarmy-reforged"] = "9.0.0", ["defence-tower-reforged"] = "9.113.0", bobplates = "2.0"}
settings = {startup = {}}
function log() end

dofile("data.lua")
dofile("data-updates.lua")
dofile("data-final-fixes.lua")

local fails = 0
local function check(ok, msg)
  if not ok then
    fails = fails + 1
    print("FAIL " .. msg)
  end
end

local function layers_of(t, out)
  out = out or {}
  if type(t) ~= "table" then return out end
  if t.filename or t.filenames or t.stripes then
    out[#out + 1] = t
    return out
  end
  for k, v in pairs(t) do
    if type(v) == "table" and k ~= "sound" and k ~= "working_sound" then layers_of(v, out) end
  end
  return out
end

local S = require("lib.shared")
local counts = {}
for _, p in ipairs(added) do
  counts[p.type] = (counts[p.type] or 0) + 1
  local where = p.type .. "/" .. p.name
  if p.type == "simple-entity-with-owner" then
    check(p.picture or p.animations, where .. ": no picture")
    if p.animations then
      local frames
      for _, l in ipairs(layers_of(p.animations)) do
        local n = (l.frame_count or 1) * (l.repeat_count or 1)
        frames = frames or n
        check(n == frames, where .. ": layer frames " .. n .. " ~= " .. frames)
      end
    end
    if p.picture then
      for _, l in ipairs(layers_of(p.picture)) do
        check(l.direction_count == nil and l.frame_count == nil, where .. ": picture layer keeps animation keys")
      end
    end
  end
  if p.type ~= "recipe" and p.type ~= "item" and p.type ~= "tile" and p.type ~= "projectile"
    and p.type ~= "ammo-category" then
    check(p.max_health and p.max_health > 0, where .. ": max_health")
    check(p.selection_box and (p.collision_box or p.type == "unit"), where .. ": boxes") -- flying units may have none
    check(p.minable == nil, where .. ": minable")
  end
  for _, l in ipairs(layers_of(p)) do
    local f = l.filename or (l.filenames and l.filenames[1]) or (l.stripes and l.stripes[1].filename)
    check(type(f) == "string" and f:sub(1, 2) == "__", where .. ": layer without file")
  end
  if p.type == "electric-turret" then
    check(p.energy_source and p.energy_source.type == "electric", where .. ": energy")
    check(p.attack_parameters and p.attack_parameters.ammo_type and p.attack_parameters.ammo_type.energy_consumption,
      where .. ": ammo energy")
    check(p.folded_animation and p.graphics_set, where .. ": turret graphics")
    local player_creation = false
    for _, f in pairs(p.flags) do if f == "player-creation" then player_creation = true end end
    check(player_creation, where .. ": no player-creation (shields)")
  end
  local attack = p.attack_parameters
  if attack then
    local cats = attack.ammo_categories or {attack.ammo_category}
    check(#cats > 0, where .. ": attack without ammo category")
    for _, c in pairs(cats) do
      check(c:sub(1, #S.prefix) == S.prefix, where .. ": fires a shared ammo category " .. c)
      check(raw["ammo-category"] and raw["ammo-category"][c], where .. ": no ammo category " .. c)
    end
  end
  if p.type == "ammo-category" then check(p.hidden == true, where .. ": not hidden") end
  if p.type == "unit" then
    check(p.loot and #p.loot > 0, where .. ": no loot")
    check(p.run_animation, where .. ": run animation")
  end
end
local units = 0
for _, name in pairs(S.all_unit_names()) do
  if raw.unit[name] then units = units + 1 end
end
check(units == #S.kinds * (1 + S.marks * #S.focuses), "replicator units " .. units)
check(raw.unit["replicator-droid-rifle-mk3-kinetic"].max_health > raw.unit["replicator-droid-rifle"].max_health, "mark health")
for name in pairs(S.size) do
  local found = false
  for _, t in pairs(raw) do if t[name] then found = true end end
  check(found, "no prototype for " .. name)
end
local recipe = raw.recipe[S.decrypt_recipe]
check(recipe and #recipe.results >= 4, "decryption results")
check(raw["simple-entity-with-owner"][S.entity.core].loot[1].item == S.core_item, "core loot")

-- optional: the new prototypes as JSON (arg[2]) for the property check against prototype-api.json
if arg[2] then
  local function enc(v, seen)
    local t = type(v)
    if t == "table" then
      seen = seen or {}
      if seen[v] then return "null" end
      seen[v] = true
      local n = #v
      local is_array = n > 0
      local count = 0
      for _ in pairs(v) do count = count + 1 end
      if is_array and count ~= n then is_array = false end
      local parts = {}
      if is_array then
        for i = 1, n do parts[i] = enc(v[i], seen) end
        seen[v] = nil
        return "[" .. table.concat(parts, ",") .. "]"
      end
      local keys = {}
      for k in pairs(v) do keys[#keys + 1] = k end
      table.sort(keys, function(x, y) return tostring(x) < tostring(y) end)
      for _, k in ipairs(keys) do parts[#parts + 1] = string.format("%q", tostring(k)) .. ":" .. enc(v[k], seen) end
      seen[v] = nil
      return "{" .. table.concat(parts, ",") .. "}"
    elseif t == "string" then
      return (string.format("%q", v):gsub("\
", "\n"))
    elseif t == "number" then
      if v ~= v or v == math.huge or v == -math.huge then return "null" end
      if v == math.floor(v) and math.abs(v) < 1e15 then return string.format("%d", v) end
      return string.format("%.10g", v)
    elseif t == "boolean" then
      return tostring(v)
    end
    return "null"
  end
  local f = assert(io.open(arg[2], "w"))
  f:write(enc(added))
  f:close()
end

local summary = {}
for t, n in pairs(counts) do summary[#summary + 1] = t .. "=" .. n end
table.sort(summary)
print("added: " .. table.concat(summary, " "))
print(fails == 0 and "ALL PASS" or ("FAILS " .. fails))
os.exit(fails == 0 and 0 or 1)
