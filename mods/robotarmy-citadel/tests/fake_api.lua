-- A small fake of the Factorio 2.0 control API for the pure Lua tests (tests/control_mock_test.lua,
-- tests/harness_mock_run.lua): surface with a spatial index, entities, forces, unit groups (they
-- never move), events, remote interfaces, settings. Sets the globals and returns the helpers.
-- Not engine evidence: pathing, combat, power and real placement are not simulated.
package.path = "./?.lua;" .. package.path
local S = require("lib.shared")

local F = {}

local function enum(list)
  local t = {}
  for i, n in ipairs(list) do t[n] = i end
  return t
end
defines = {
  direction = {north = 0, east = 4, south = 8, west = 12},
  wire_connector_id = {pole_copper = 1},
  wire_origin = {player = 0, radars = 1, script = 2},
  command = enum({"attack", "attack_area", "build_base", "compound", "flee", "go_to_location", "group", "stop", "wander"}),
  distraction = enum({"by_anything", "by_damage", "by_enemy", "none"}),
  compound_command = enum({"logical_and", "logical_or", "return_last"}),
  group_state = enum({"gathering", "moving", "attacking_distraction", "attacking_target", "finished", "pathfinding", "wander_in_group"}),
  events = enum({"on_entity_died", "on_runtime_mod_setting_changed", "on_force_created", "on_forces_merged",
    "on_player_changed_force", "on_player_created", "on_technology_effects_reset", "on_tick"}),
}

local defaults = {}
data = {extend = function(_, list) for _, s in pairs(list) do defaults[s.name] = s.default_value end end}
dofile("settings.lua")
data = nil
settings = {global = {}}
for name, v in pairs(defaults) do settings.global[name] = {value = v} end

local type_of = {}
for _, n in pairs(S.all_unit_names()) do type_of[n] = "unit" end
for _, n in pairs(S.entity) do type_of[n] = type_of[n] or "simple-entity-with-owner" end
for _, n in pairs(S.turrets) do type_of[n] = "electric-turret" end
type_of[S.entity.wall], type_of[S.entity.gate] = "wall", "gate"
type_of[S.entity.pylon], type_of[S.entity.lamp] = "electric-pole", "lamp"
type_of[S.entity.reactor], type_of[S.entity.accumulator] = "electric-energy-interface", "accumulator"
type_of[S.entity.radar], type_of[S.entity.land_mine], type_of[S.entity.shield_tower] = "radar", "land-mine", "container"
type_of["biter-spawner"], type_of["stone-furnace"], type_of["gun-turret"] = "unit-spawner", "furnace", "ammo-turret"
type_of["small-worm-turret"], type_of["wooden-chest"], type_of["item-on-ground"] = "turret", "container", "item-entity"
type_of["droid-rifle"], type_of["droid-smg"], type_of["small-biter"] = "unit", "unit", "unit"
F.type_of = type_of

local LOOT = {{item = "iron-gear-wheel", probability = 1, count_min = 1, count_max = 2}}
local CORE_LOOT = {{item = S.core_item, probability = 1, count_min = 1, count_max = 2}}
prototypes = {entity = {}, item = {["repair-pack"] = {}}, ammo_category = {},
  tile = {[S.tile_floor] = {}, [S.tile_road] = {}}}
for n, t in pairs(type_of) do
  prototypes.entity[n] = {name = n, type = t, loot = (t == "unit" and n:find("^replicator%-")) and LOOT or nil}
end
-- the key buildings drop replicator cores (prototypes/loot.lua)
for _, n in pairs({S.entity.core, S.entity.radar, S.entity.depot, S.entity.armory}) do prototypes.entity[n].loot = CORE_LOOT end
for _, c in pairs(S.ammo_categories) do prototypes.ammo_category[c] = {} end

storage = {}
F.handlers, F.nth = {}, {}
F.printed = {}
F.logged = {}
script = {
  on_init = function(f) F.init = f end,
  on_load = function(f) F.on_load = f end,
  on_configuration_changed = function(f) F.on_configuration_changed = f end,
  on_nth_tick = function(n, f) F.nth[n] = f end,
  on_event = function(id, f, filter)
    F.handlers[id] = f
    if id == defines.events.on_entity_died then F.died_filter = filter end
  end,
}
remote = {interfaces = {}}
local impl = {}
function remote.add_interface(name, f)
  impl[name] = f
  local names = {}
  for k in pairs(f) do names[k] = true end
  remote.interfaces[name] = names
end
function remote.call(i, f, ...) return impl[i][f](...) end
commands = {add_command = function() end}
helpers = {create_profiler = function() return {stop = function() end, reset = function() end, restart = function() end} end}
serpent = {line = function(v)
  if type(v) ~= "table" then return tostring(v) end
  local parts = {}
  for k, x in pairs(v) do parts[#parts + 1] = tostring(k) .. "=" .. (type(x) == "table" and "{..}" or tostring(x)) end
  table.sort(parts)
  return "{" .. table.concat(parts, ", ") .. "}"
end}
local function flat(m)
  if type(m) ~= "table" then return tostring(m) end
  if m[1] == nil then return "<object>" end -- a profiler inside a localised string
  local out = {}
  for i = 2, #m do out[#out + 1] = flat(m[i]) end
  return (m[1] == "" and "" or m[1] .. " ") .. table.concat(out, "")
end
function log(m) F.logged[#F.logged + 1] = flat(m) end

local function key_of_msg(m) return type(m) == "table" and m[1] or tostring(m) end

local entities, next_un = {}, 0
local chunks = {}
F.entities = entities
F.died_names = {}
F.kills = 0
local function ckey(x, y) return math.floor(x / 32) * 100000 + math.floor(y / 32) end

local function make_force(name, index)
  local f = {valid = true, name = name, index = index, players = {}, ai_controllable = name == "enemy", cease = {},
    technologies = {}, recipes = {[S.decrypt_recipe] = {enabled = false}}, evolution = 0, bonus = {}, tags = {}, charted = {}}
  f.set_friend = function() end
  f.get_friend = function() return false end
  f.set_cease_fire = function(o, v) f.cease[o.name or o] = v end
  f.get_cease_fire = function(o) return f.cease[o.name or o] == true end
  f.is_enemy = function(o) local n = o.name or o return n ~= f.name and n ~= "neutral" and not f.cease[n] end
  f.get_evolution_factor = function() return f.evolution end
  f.set_evolution_factor = function(v) f.evolution = v end
  f.get_spawn_position = function() return {x = 0, y = 0} end
  f.print = function(m) F.printed[#F.printed + 1] = key_of_msg(m) end
  f.chart = function(_, a)
    for cx = math.floor(a[1][1] / 32), math.floor(a[2][1] / 32) do
      for cy = math.floor(a[1][2] / 32), math.floor(a[2][2] / 32) do f.charted[cx .. "," .. cy] = true end
    end
  end
  f.add_chart_tag = function(_, tag)
    local p = tag.position
    if not f.charted[math.floor(p.x / 32) .. "," .. math.floor(p.y / 32)] then return nil end
    local t = {position = p, icon = tag.icon, valid = true}
    t.destroy = function() t.valid = false end
    f.tags[#f.tags + 1] = t
    return t
  end
  f.find_chart_tags = function(_, a)
    local out = {}
    for _, t in pairs(f.tags) do
      if t.valid and t.position.x >= a[1][1] and t.position.x <= a[2][1] and t.position.y >= a[1][2] and t.position.y <= a[2][2] then
        out[#out + 1] = t
      end
    end
    return out
  end
  f.is_chunk_charted = function(_, c) return f.charted[(c.x or c[1]) .. "," .. (c.y or c[2])] == true end
  f.unchart_chunk = function(c) f.charted[(c.x or c[1]) .. "," .. (c.y or c[2])] = nil end
  f.set_ammo_damage_modifier = function(c, v) f.bonus["damage-" .. c] = v end
  f.set_gun_speed_modifier = function(c, v) f.bonus["rate-" .. c] = v end
  f.get_ammo_damage_modifier = function(c) return f.bonus["damage-" .. c] or 0 end
  f.get_gun_speed_modifier = function(c) return f.bonus["rate-" .. c] or 0 end
  f.reset_technology_effects = function() f.bonus = {} end
  local function tech(tname, max)
    f.technologies[tname] = {name = tname, researched = false, level = 1, prototype = {level = 1, max_level = max}}
  end
  tech("turret-shields-base", 1)
  tech("turret-shields-size", 25)
  tech("turret-shields-speed", 25)
  for i = 1, 10 do tech("repair-turret-range-" .. i, 1) end
  return f
end

game = {tick = 0, forces = {}, print = function(m) F.printed[#F.printed + 1] = key_of_msg(m) end}
game.forces.player = make_force("player", 1)
game.forces.enemy = make_force("enemy", 2)
game.forces.neutral = make_force("neutral", 3)
game.create_force = function(name)
  local f = make_force(name, 4)
  game.forces[name] = f
  return f
end
game.map_settings = {enemy_expansion = {enabled = true}}

local function pos_of(p) return {x = p.x or p[1], y = p.y or p[2]} end
F.pos_of = pos_of
local function in_area(p, a)
  local x1, y1 = a[1].x or a[1][1], a[1].y or a[1][2]
  local x2, y2 = a[2].x or a[2][1], a[2].y or a[2][2]
  return p.x >= x1 and p.x < x2 and p.y >= y1 and p.y < y2
end
local function as_set(v)
  if v == nil then return nil end
  local s = {}
  if type(v) ~= "table" or v.name then s[type(v) == "table" and v.name or v] = true return s end
  for _, x in pairs(v) do s[type(x) == "table" and x.name or x] = true end
  return s
end

local surface
F.groups = {}

local function remove(e)
  e.valid = false
  entities[e.unit_number] = nil
  chunks[e.ckey][e.unit_number] = nil
  if e.group then
    for i, m in ipairs(e.group.list) do if m == e then table.remove(e.group.list, i) break end end
    e.group = nil
  end
end

local function new_entity(p)
  next_un = next_un + 1
  local name = p.name
  local e = {valid = true, name = name, type = type_of[name] or "simple-entity", position = pos_of(p.position),
    force = type(p.force) == "table" and p.force or game.forces[p.force or "neutral"], surface = surface,
    unit_number = next_un, health = 100, max_health = 100, direction = p.direction or 0, energy = 100}
  e.destroy = function() remove(e) return true end
  e.die = function(force, cause)
    if not e.valid then return false end
    if F.died_names[e.name] then -- the event comes while the entity is still valid
      F.kills = F.kills + 1
      F.handlers[defines.events.on_entity_died]({entity = e, force = force or game.forces.player, cause = cause,
        damage_type = {name = "laser"}, tick = game.tick})
    end
    local loot = prototypes.entity[e.name] and prototypes.entity[e.name].loot
    remove(e)
    if loot then
      local it = new_entity({name = "item-on-ground", position = e.position, force = "neutral"})
      it.stack = {name = loot[1].item, count = 1}
    end
    return true
  end
  e.get_wire_connector = function() return {connect_to = function() return true end} end
  e.teleport = function(p)
    chunks[e.ckey][e.unit_number] = nil
    e.position = pos_of(p)
    e.ckey = ckey(e.position.x, e.position.y)
    chunks[e.ckey] = chunks[e.ckey] or {}
    chunks[e.ckey][e.unit_number] = e
    return true
  end
  e.insert = function() return 1 end
  if e.type == "unit" then e.commandable = {parent_group = nil} end
  entities[next_un] = e
  e.ckey = ckey(e.position.x, e.position.y)
  chunks[e.ckey] = chunks[e.ckey] or {}
  chunks[e.ckey][next_un] = e
  return e
end
F.new_entity = new_entity

local function matches(e, f)
  if f.area and not in_area(e.position, f.area) then return false end
  if f.position and f.radius then
    local p = pos_of(f.position)
    local dx, dy = e.position.x - p.x, e.position.y - p.y
    if dx * dx + dy * dy > f.radius * f.radius then return false end
  end
  local names, forces, types = as_set(f.name), as_set(f.force), as_set(f.type)
  if names and not names[e.name] then return false end
  if forces and not forces[e.force.name] then return false end
  if types and not types[e.type] then return false end
  return true
end

local tiles = {}
surface = {name = "nauvis", index = 1, map_gen_settings = {seed = 123}, valid = true}
surface.find_entities_filtered = function(f)
  local x1, y1, x2, y2
  if f.area then
    x1, y1 = f.area[1].x or f.area[1][1], f.area[1].y or f.area[1][2]
    x2, y2 = f.area[2].x or f.area[2][1], f.area[2].y or f.area[2][2]
  elseif f.position then
    local p = pos_of(f.position)
    x1, y1, x2, y2 = p.x - f.radius, p.y - f.radius, p.x + f.radius, p.y + f.radius
  end
  local candidates = {}
  if x1 then
    for cx = math.floor(x1 / 32), math.floor((x2 - 0.001) / 32) do
      for cy = math.floor(y1 / 32), math.floor((y2 - 0.001) / 32) do
        for un in pairs(chunks[cx * 100000 + cy] or {}) do candidates[#candidates + 1] = un end
      end
    end
  else
    for un in pairs(entities) do candidates[#candidates + 1] = un end
  end
  table.sort(candidates)
  local out = {}
  for _, un in ipairs(candidates) do
    local e = entities[un]
    if e and matches(e, f) then
      out[#out + 1] = e
      if f.limit and #out >= f.limit then break end
    end
  end
  return out
end
surface.count_entities_filtered = function(f) return #surface.find_entities_filtered(f) end
surface.count_tiles_filtered = function(f)
  if not f.name then return 0 end
  local names, n = as_set(f.name), 0
  local x1, y1 = f.area[1][1], f.area[1][2]
  for x = x1, f.area[2][1] - 1 do
    for y = y1, f.area[2][2] - 1 do
      if names[tiles[x .. "," .. y]] then n = n + 1 end
    end
  end
  return n
end
surface.is_chunk_generated = function() return true end
surface.request_to_generate_chunks = function() end
surface.force_generate_chunk_requests = function() end
surface.destroy_decoratives = function() end
surface.set_tiles = function(list)
  for _, t in pairs(list) do tiles[(t.position[1] or t.position.x) .. "," .. (t.position[2] or t.position.y)] = t.name end
end
-- as the engine for a script placement: items on the ground and units in the footprint block it
surface.can_place_entity = function(p)
  local size = S.size[p.name] or {1, 1}
  local c = pos_of(p.position)
  local hw, hh = size[1] / 2 - 0.1, size[2] / 2 - 0.1
  local found = surface.find_entities_filtered({area = {{c.x - hw, c.y - hh}, {c.x + hw, c.y + hh}}, type = {"item-entity", "unit"}})
  return #found == 0
end
surface.find_non_colliding_position = function(_, p) return pos_of(p) end
surface.create_entity = function(p)
  if p.name == "big-explosion" then return nil end
  if type_of[p.name] == nil then error("create_entity of unknown " .. tostring(p.name)) end
  return new_entity(p)
end
surface.create_unit_group = function(p)
  local g = {valid = true, list = {}, position = pos_of(p.position), state = defines.group_state.gathering, has_command = false}
  g.add_member = function(e)
    if e.group then
      for i, m in ipairs(e.group.list) do if m == e then table.remove(e.group.list, i) break end end
    end
    e.group = g
    e.commandable.parent_group = g
    g.list[#g.list + 1] = e
  end
  setmetatable(g, {__index = function(t, k) if k == "members" then return {(table.unpack or unpack)(t.list)} end end})
  g.set_command = function(cmd)
    assert(cmd.type, "command without type")
    g.has_command = true
    g.state = defines.group_state.moving
    g.cmd = cmd
  end
  g.start_moving = function() end
  g.destroy = function()
    g.valid = false
    for _, e in ipairs(g.list) do e.group = nil e.commandable.parent_group = nil end
  end
  F.groups[#F.groups + 1] = g
  return g
end
game.surfaces = {nauvis = surface, [1] = surface}
game.get_surface = function() return surface end
F.surface = surface

--- Loads the citadel control.lua and fills the death filter names.
function F.load_citadel()
  dofile("control.lua")
  for _, f in pairs(F.died_filter) do
    -- as the engine: LuaEntityDiedEventFilter.name is one entity name
    assert(f.filter == "name" and type(f.name) == "string", "event filter name must be a string")
    F.died_names[f.name] = true
  end
end

--- Runs ticks: nth tick handlers, then on_tick, then each().
function F.run(ticks, each)
  for _ = 1, ticks do
    game.tick = game.tick + 1
    for n, fn in pairs(F.nth) do
      if fn and game.tick % n == 0 then fn({tick = game.tick}) end
    end
    local on_tick = F.handlers[defines.events.on_tick]
    if on_tick then on_tick({tick = game.tick}) end
    if each then each() end
  end
end

function F.said(key)
  for _, m in ipairs(F.printed) do if m == key then return true end end
  return false
end

return F
