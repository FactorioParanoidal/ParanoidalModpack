-- Squads: lifecycle, membership, unit group repair and the basic orders.
--
-- squad = {
--   id, force, force_index, surface, surface_index,
--   group, group_id            -- LuaCommandable unit group and its unique_id
--   members = {unit_number -> LuaEntity}, size,
--   mode                       -- Squad.MODE
--   home                       -- guard post / creation position
--   station                    -- guard station unit_number (garrison squads)
--   pos                        -- cached position (refreshed every update)
--   order = {tick, dest, distance, dirty}
--   fail_tick, fail_response   -- unit group failure escalation
--   readd = {unit_number -> tick}  -- last time a member was re-added to the group
--   idle_searches              -- consecutive hunts without a target (search back-off)
--   retreat, retreat_at        -- target assembler unit_number, assemblers whose retreat sets hold the squad
--   qrf                        -- quick reaction force state (script/ai.lua)
--   hold                       -- recalled by a player: stays at its assembler, does not hunt
--   hold_pos                   -- landed from a drop pod: holds this position instead (with hold)
--   roles = {role -> {unit_number -> true}}, role_count = {role -> n}  -- repair droids, miners
--   bucket, deleted
-- }
local config = require("script.config")
local droids = require("script.droids")
local cache = require("script.settings_cache")
local util = require("script.util")

local distance, distance2, copy_position = util.distance, util.distance2, util.copy_position
local min, max = math.min, math.max
local command, distraction, group_state = defines.command, defines.distraction, defines.group_state
local direction = defines.direction

local Squad = {}

-- values kept from the original command enum; patrol: walks around the base (script/territory.lua)
local MODE = {assemble = 1, guard = 4, hunt = 6, patrol = 7}
Squad.MODE = MODE

local RESPONSE = {repeat_order = 1, retreat = 2, wander = 3, ignore = 4}

------------------------------------------------------------------------------------------
-- Force thresholds (army window)

function Squad.hunt_size(fd)
  return fd.thresholds.hunt_size
end

function Squad.retreat_size(fd)
  return fd.thresholds.retreat_size
end

function Squad.hunt_range(fd)
  return fd.thresholds.hunt_range
end

function Squad.should_hunt(squad, fd)
  local mode = squad.mode
  if mode == MODE.guard or mode == MODE.patrol or squad.hold then return false end
  local size = squad.size
  return size >= Squad.hunt_size(fd) or (mode == MODE.hunt and size > Squad.retreat_size(fd))
end

--- Short state of a squad for the GUI: "hunt", "fight", "retreat", "gather", "guard", "hold",
--- "patrol", "qrf", "qrf-return".
function Squad.status(squad)
  local qrf = squad.qrf
  if qrf then return qrf.returning and "qrf-return" or "qrf" end
  if squad.mode == MODE.guard then return "guard" end
  if squad.hold then return "hold" end
  local group = squad.group
  if group and group.valid and Squad.is_attacking(group) then return "fight" end
  if squad.mode == MODE.patrol then return "patrol" end
  if squad.mode == MODE.hunt then return "hunt" end
  if squad.retreat then return "retreat" end
  return "gather"
end

--- Where the squad is going (nil while it stays where it is).
function Squad.destination(squad)
  if squad.qrf then
    return squad.qrf.returning and squad.qrf.origin or squad.qrf.target
  end
  if squad.mode == MODE.hunt or squad.mode == MODE.patrol or squad.retreat or squad.hold_pos then return squad.order.dest end
  return nil
end

function Squad.is_attacking(group)
  local state = group.state
  return state == group_state.attacking_target or state == group_state.attacking_distraction
end

------------------------------------------------------------------------------------------
-- Update buckets

local function bucket_add(squad)
  local sizes = storage.bucket_sizes
  local best, best_size = 1, sizes[1]
  for i = 2, #sizes do
    if sizes[i] < best_size then
      best, best_size = i, sizes[i]
    end
  end
  storage.buckets[best][squad.id] = true
  sizes[best] = best_size + 1
  squad.bucket = best
end

local function bucket_remove(squad)
  local bucket = squad.bucket
  if bucket and storage.buckets[bucket][squad.id] then
    storage.buckets[bucket][squad.id] = nil
    storage.bucket_sizes[bucket] = storage.bucket_sizes[bucket] - 1
  end
  squad.bucket = nil
end

local function set_group(squad, group)
  if squad.group_id then
    storage.groups[squad.group_id] = nil
  end
  squad.group = group
  squad.group_id = group and group.unique_id or nil
  if group then
    storage.groups[squad.group_id] = squad.id
  end
end

------------------------------------------------------------------------------------------
-- Lifecycle

function Squad.create(fd, entity, mode, home)
  local id = storage.next_squad_id
  storage.next_squad_id = id + 1
  local position = entity.position
  local surface = entity.surface
  local squad = {
    id = id,
    force = fd.force,
    force_index = fd.force.index,
    surface = surface,
    surface_index = surface.index,
    members = {},
    size = 0,
    mode = mode or MODE.assemble,
    home = copy_position(home or position),
    pos = copy_position(position),
    order = {tick = 0, dest = copy_position(position), distance = 0, dirty = true},
    fail_tick = 0,
    fail_response = RESPONSE.repeat_order,
    readd = {},
    idle_searches = 0,
  }
  set_group(squad, surface.create_unit_group({position = position, force = fd.force}))
  storage.squads[id] = squad
  fd.squads[id] = squad
  bucket_add(squad)
  util.debug("robotarmy: created squad %d", id)
  return squad
end

function Squad.leave_retreat(squad)
  local at = squad.retreat_at
  if at then
    local fd = storage.forces[squad.force_index]
    for _, unit_number in pairs(at) do
      local set = fd and fd.retreats[unit_number]
      if set then
        set[squad.id] = nil
        if next(set) == nil then
          fd.retreats[unit_number] = nil
        end
      end
    end
  end
  squad.retreat = nil
  squad.retreat_at = nil
end

function Squad.delete(squad, quiet)
  if squad.deleted then return end
  squad.deleted = true
  local unit_squad = storage.unit_squad
  for unit_number in pairs(squad.members) do
    if unit_squad[unit_number] == squad.id then
      unit_squad[unit_number] = nil
    end
  end
  squad.members = {}
  squad.size = 0
  squad.roles = nil
  squad.role_count = nil
  local group = squad.group
  if group and group.valid then
    group.destroy()
  end
  set_group(squad, nil)
  Squad.leave_retreat(squad)
  bucket_remove(squad)
  storage.squads[squad.id] = nil
  local fd = storage.forces[squad.force_index]
  if fd then
    fd.squads[squad.id] = nil
    if squad.station and fd.station_squad[squad.station] == squad.id then
      fd.station_squad[squad.station] = nil
    end
  end
  if not quiet then
    if squad.surface.valid then
      util.squad_message(squad.force, {"robotarmy-message.squad-lost", squad.id, util.gps(squad.pos, squad.surface)})
    end
  end
  util.debug("robotarmy: deleted squad %d", squad.id)
end

--- Removes a member. The squad is deleted when it becomes empty.
function Squad.remove(squad, unit_number, quiet)
  if not squad.members[unit_number] then return end
  squad.members[unit_number] = nil
  squad.readd[unit_number] = nil
  squad.size = squad.size - 1
  local roles = squad.roles
  if roles then
    for role, set in pairs(roles) do
      if set[unit_number] then
        set[unit_number] = nil
        squad.role_count[role] = squad.role_count[role] - 1
      end
    end
  end
  if storage.unit_squad[unit_number] == squad.id then
    storage.unit_squad[unit_number] = nil
  end
  if squad.size <= 0 then
    Squad.delete(squad, quiet)
  elseif squad.mode == MODE.hunt and not squad.qrf then
    local fd = storage.forces[squad.force_index]
    if fd and not Squad.should_hunt(squad, fd) then
      squad.order.dirty = true -- too small to keep hunting: retreat on the next update
    end
  end
end

--- Position of the squad: unit group position, or the average of its members.
function Squad.position(squad)
  local pos = squad.pos
  local group = squad.group
  if group and group.valid then
    local p = group.position
    pos.x, pos.y = p.x, p.y
    return pos
  end
  local x, y, n = 0, 0, 0
  for _, member in pairs(squad.members) do
    if member.valid then
      local p = member.position
      x, y, n = x + p.x, y + p.y, n + 1
    end
  end
  if n > 0 then
    pos.x, pos.y = x / n, y / n
  end
  return pos
end

--- Valid unit group of the squad; recreates it (with all members) if it was lost.
function Squad.ensure_group(squad, position)
  local group = squad.group
  if group and group.valid then return group end
  if not squad.surface.valid then return nil end
  group = squad.surface.create_unit_group({position = position or Squad.position(squad), force = squad.force})
  set_group(squad, group)
  local surface_index = squad.surface_index
  for _, member in pairs(squad.members) do
    if member.valid and member.surface_index == surface_index then
      group.add_member(member)
    end
  end
  squad.order.dirty = true
  return group
end

function Squad.add(squad, droid)
  local unit_number = droid.unit_number
  local previous = storage.unit_squad[unit_number]
  if previous == squad.id then return end
  if previous then
    local other = storage.squads[previous]
    if other then Squad.remove(other, unit_number, true) end
  end
  local fd = storage.forces[squad.force_index]
  local was_hunting = Squad.should_hunt(squad, fd)
  squad.members[unit_number] = droid
  squad.size = squad.size + 1
  squad.readd[unit_number] = 0
  local role = droids.role[droid.name]
  if role then
    squad.roles = squad.roles or {}
    squad.role_count = squad.role_count or {}
    local set = squad.roles[role]
    if not set then
      set = {}
      squad.roles[role] = set
    end
    set[unit_number] = true
    squad.role_count[role] = (squad.role_count[role] or 0) + 1
  end
  storage.unit_squad[unit_number] = squad.id
  local group = Squad.ensure_group(squad, droid.position)
  if group and droid.surface_index == squad.surface_index then
    group.add_member(droid)
    group.start_moving()
  end
  if not was_hunting and Squad.should_hunt(squad, fd) then
    squad.order.dirty = true
  end
end

--- Merges two squads of the same force and surface; the bigger one survives and is returned.
function Squad.merge(a, b)
  if a.force_index ~= b.force_index or a.surface_index ~= b.surface_index then return nil end
  if a.size < b.size then a, b = b, a end
  util.debug("robotarmy: merging squad %d (%d) into squad %d (%d)", b.id, b.size, a.id, a.size)
  for _, member in pairs(b.members) do
    if member.valid then
      Squad.add(a, member) -- removes it from b; b is deleted quietly when empty
    end
  end
  if not b.deleted then Squad.delete(b, true) end
  a.fail_response = RESPONSE.repeat_order
  if Squad.should_hunt(a, storage.forces[a.force_index]) then
    a.order.dirty = true
  end
  return a
end

--- Nearest squad of the force on the surface within `range` of `position`.
function Squad.find_near(fd, surface_index, position, range, exclude)
  local best, best_d2 = nil, range * range
  local coarse = (range + 16) * (range + 16) -- cached positions may be up to one update old
  for _, squad in pairs(fd.squads) do
    if squad ~= exclude and squad.size > 0 and squad.surface_index == surface_index
      and distance2(squad.pos, position) < coarse then
      local group = squad.group
      if group and group.valid then
        local d2 = distance2(group.position, position)
        if d2 < best_d2 then
          best, best_d2 = squad, d2
        end
      end
    end
  end
  return best
end

------------------------------------------------------------------------------------------
-- Assemblers

--- Where squads gather at an assembler: its rally point, or a few tiles from its output side.
local function retreat_position(assembler)
  local record = storage.spawners[assembler.unit_number]
  local rally = record and record.rally
  if rally then return {x = rally.x, y = rally.y} end
  local p = assembler.position
  local x, y = p.x, p.y
  local d = assembler.direction
  local offset = config.SPAWN_OFFSET
  if d == direction.east then x = x - offset
  elseif d == direction.north then y = y + offset
  elseif d == direction.south then y = y - offset
  elseif d == direction.west then x = x + offset
  end
  return {x = x, y = y}
end
Squad.retreat_position = retreat_position

function Squad.nearest_assembler(fd, surface_index, position)
  local best, best_d2
  for _, assembler in pairs(fd.assemblers) do
    if assembler.valid and assembler.surface_index == surface_index then
      local d2 = distance2(assembler.position, position)
      if not best_d2 or d2 <= best_d2 then
        best, best_d2 = assembler, d2
      end
    end
  end
  return best
end

function Squad.near_assembler(fd, surface_index, position)
  local assembler = Squad.nearest_assembler(fd, surface_index, position)
  return assembler ~= nil and distance(retreat_position(assembler), position) < config.AT_ASSEMBLER_RANGE
end

local function join_retreat(squad, fd, target)
  Squad.leave_retreat(squad)
  local at = {}
  local center = target.position
  local range2 = config.AT_ASSEMBLER_RANGE * config.AT_ASSEMBLER_RANGE
  local surface_index = target.surface_index
  for unit_number, assembler in pairs(fd.assemblers) do
    if assembler.valid and assembler.surface_index == surface_index
      and distance2(assembler.position, center) < range2 then
      local set = fd.retreats[unit_number]
      if not set then
        set = {}
        fd.retreats[unit_number] = set
      end
      set[squad.id] = true
      at[#at + 1] = unit_number
    end
  end
  squad.retreat = target.unit_number
  squad.retreat_at = at
end

------------------------------------------------------------------------------------------
-- Orders

local function set_order(squad, dest, dist)
  local order = squad.order
  order.tick = game.tick
  order.dest = copy_position(dest)
  order.distance = dist
  order.dirty = false
end

--- Wander in place; `keep_mode` keeps a guard / patrol squad in its mode.
function Squad.order_wander(squad, position, keep_mode)
  local group = squad.group
  if not keep_mode then squad.mode = MODE.assemble end
  set_order(squad, position, distance(position, group.position))
  group.set_command({type = command.wander, destination = position, distraction = distraction.by_enemy})
  group.start_moving()
end

--- Attack-move to a position.
function Squad.order_attack(squad, position, radius)
  local group = squad.group
  Squad.leave_retreat(squad)
  squad.mode = MODE.hunt
  set_order(squad, position, distance(position, group.position))
  group.set_command({
    type = command.attack_area,
    destination = position,
    radius = radius or 2,
    distraction = distraction.by_anything,
  })
  group.start_moving()
end

--- Go somewhere, then keep wandering there: an expired command would make the units
--- wander off on their own (into the factory, for example).
local function go_then_wander(group, position, distraction_type)
  group.set_command({
    type = command.compound,
    structure_type = defines.compound_command.return_last,
    commands = {
      {type = command.go_to_location, destination = position, distraction = distraction_type},
      {type = command.wander, destination = position, distraction = distraction_type},
    },
  })
  group.start_moving()
end

--- Garrison squads go back to their station and stay around it.
function Squad.order_guard(squad)
  local group = squad.group
  squad.mode = MODE.guard
  set_order(squad, squad.home, distance(squad.home, group.position))
  go_then_wander(group, squad.home, distraction.by_enemy)
end

--- Patrol step: walk to a position (the next chunk of the base), fighting enemies on the way.
function Squad.order_patrol(squad, position)
  local group = squad.group
  squad.mode = MODE.patrol
  set_order(squad, position, distance(position, group.position))
  group.set_command({type = command.go_to_location, destination = position, radius = 4, distraction = distraction.by_enemy})
  group.start_moving()
end

function Squad.order_retreat(squad)
  local group = squad.group
  if not (group and group.valid) then return end
  if squad.mode == MODE.guard then
    Squad.order_guard(squad)
    return
  end
  if squad.hold and squad.hold_pos then
    -- landed from a drop pod: hold the landing site until released or sent
    squad.mode = MODE.assemble
    local dest = squad.hold_pos
    if distance(dest, group.position) > config.AT_ASSEMBLER_RANGE / 2 then
      go_then_wander(group, dest, distraction.by_enemy)
    else
      group.set_command({type = command.wander, destination = dest, distraction = distraction.by_enemy})
      group.start_moving()
    end
    set_order(squad, dest, distance(dest, group.position))
    return
  end
  local fd = storage.forces[squad.force_index]
  local here = group.position
  local assembler = Squad.nearest_assembler(fd, squad.surface_index, here)
  if not assembler then
    if not squad.warned_no_assembler then
      squad.warned_no_assembler = true
      if cache.squad_messages then
        util.alert(squad.force, util.leader(squad), util.ICON_NO_ASSEMBLER, {"robotarmy-message.no-assembler", squad.id})
      end
    end
    Squad.order_wander(squad, here)
    return
  end
  squad.warned_no_assembler = nil
  local dest = retreat_position(assembler)
  local dist = distance(dest, here)
  squad.mode = MODE.assemble
  if dist > config.AT_ASSEMBLER_RANGE then
    util.debug("robotarmy: squad %d (%d) retreats %d tiles to assembler %d", squad.id, squad.size, dist, assembler.unit_number)
    go_then_wander(group, dest, distraction.by_damage)
  end
  join_retreat(squad, fd, assembler)
  set_order(squad, dest, dist)
end

function Squad.order_due(squad)
  local order = squad.order
  local period = config.SANITY_CHECK_PERIOD * (order.distance / config.SANITY_CHECK_DISTANCE_DIVISOR + 1)
  local idle = squad.idle_searches
  if idle > 0 then
    period = max(period, min(config.SANITY_CHECK_PERIOD * 2 ^ idle, config.IDLE_HUNT_BACKOFF_MAX))
  end
  return game.tick > order.tick + period
end

------------------------------------------------------------------------------------------
-- Integrity: members that dropped out of the unit group

local function try_teleport(squad, group, soldier)
  if not cache.teleport then return false end
  local surface_index = squad.surface_index
  local group_position = group.position
  local radius = config.PLAYER_VIEW_RADIUS
  if util.seen_by_player(surface_index, soldier.position, radius)
    or util.seen_by_player(surface_index, group_position, radius) then
    return false
  end
  local target = squad.surface.find_non_colliding_position(soldier.name, group_position, config.TELEPORT_SEARCH_RADIUS, 1)
  if target and soldier.teleport(target) then
    group.add_member(soldier)
    return true
  end
  return false
end

--- Sends a misbehaving member back to an assembler on its own.
local function kick_out(squad, fd, unit_number, soldier, squad_position)
  if squad.size > 1 and not (Squad.near_assembler(fd, squad.surface_index, squad_position)
    and Squad.near_assembler(fd, soldier.surface_index, soldier.position)) then
    if Squad.nearest_assembler(fd, soldier.surface_index, soldier.position) then
      Squad.remove(squad, unit_number, true)
      local lone = Squad.create(fd, soldier)
      Squad.add(lone, soldier)
      Squad.order_retreat(lone)
      return true
    end
  end
  squad.readd[unit_number] = 0
  return false
end

--- Members that are now on another surface form or join a squad there.
local function rehome(fd, soldier, squad)
  Squad.remove(squad, soldier.unit_number, true)
  local other = Squad.find_near(fd, soldier.surface_index, soldier.position, config.SQUAD_CHECK_RANGE)
    or Squad.create(fd, soldier)
  Squad.add(other, soldier)
end

--- Checks the unit group and its members. Returns the squad (nil if it is gone) and whether
--- it may be given an order now.
function Squad.validate(squad)
  if squad.deleted or squad.size <= 0 then return nil, false end
  if not squad.surface.valid then
    Squad.delete(squad, true)
    return nil, false
  end
  local fd = storage.forces[squad.force_index]
  local now = game.tick
  local position = copy_position(Squad.position(squad))
  local wander, retreat = false, false

  local group = squad.group
  if not (group and group.valid) then
    if squad.fail_response == RESPONSE.ignore then
      if not Squad.order_due(squad) then return squad, false end
      squad.fail_response = RESPONSE.repeat_order
    end
    group = Squad.ensure_group(squad, position)
    if not group then
      Squad.delete(squad, true)
      return nil, false
    end
    if squad.fail_tick + config.UG_FAILURE_RECENCY_TICKS > now then
      local response = squad.fail_response
      if response == RESPONSE.repeat_order then
        squad.fail_response = RESPONSE.retreat
      elseif response == RESPONSE.retreat then
        retreat = true -- maybe the target cannot be reached
        squad.fail_response = RESPONSE.wander
      elseif response == RESPONSE.wander then
        wander = true -- retreating did not help either
        squad.fail_response = RESPONSE.ignore
      end
    else
      squad.fail_response = RESPONSE.repeat_order
    end
    squad.fail_tick = now
  end

  local group_id = group.unique_id
  local far = config.UNITGROUP_FAILURE_DISTANCE
  local surface_index = squad.surface_index
  for unit_number, soldier in pairs(squad.members) do
    if not soldier.valid then
      Squad.remove(squad, unit_number, true)
    elseif soldier.surface_index ~= surface_index then
      rehome(fd, soldier, squad)
    else
      local commandable = soldier.commandable
      local parent = commandable and commandable.parent_group
      local soldier_distance = distance(position, soldier.position)
      if not (parent and parent.unique_id == group_id) then
        if soldier_distance > far then
          if not try_teleport(squad, group, soldier)
            and not kick_out(squad, fd, unit_number, soldier, position) then
            group.add_member(soldier)
            wander = true -- the whole squad waits for this soldier
          end
        elseif now < (squad.readd[unit_number] or 0) + config.SAFE_READD_TICKS then
          kick_out(squad, fd, unit_number, soldier, position) -- left the group again right away
        else
          group.add_member(soldier)
          squad.readd[unit_number] = now
        end
      elseif soldier_distance > far then
        try_teleport(squad, group, soldier)
      end
    end
    if squad.deleted then return nil, false end
  end
  if squad.deleted or not group.valid then return nil, false end

  if wander then
    if cache.squad_messages then
      util.alert(squad.force, util.leader(squad), util.ICON_STUCK, {"robotarmy-message.squad-stuck", squad.id, squad.size})
    end
    Squad.order_wander(squad, position, squad.mode == MODE.guard or squad.mode == MODE.patrol)
    return squad, false
  elseif retreat and squad.mode == MODE.patrol then
    squad.order.dirty = true -- a patrol picks another chunk
    return squad, false
  elseif retreat then
    if cache.squad_messages then
      util.alert(squad.force, util.leader(squad), util.ICON_STUCK, {"robotarmy-message.squad-unreachable", squad.id, squad.size})
    end
    Squad.order_retreat(squad)
    return squad, false
  end
  return squad, true
end

return Squad
