-- Squad decisions: hunting, retreat and merging, guarding, targeting, quick reaction force,
-- and the nearest-enemy retargeting of distracted droids.
local config = require("script.config")
local cache = require("script.settings_cache")
local util = require("script.util")
local Squad = require("script.squad")
local loot = require("script.loot")

local MODE = Squad.MODE
local distance, distance2, copy_position = util.distance, util.distance2, util.copy_position
local min = math.min
local command, distraction, group_state = defines.command, defines.distraction, defines.group_state

local ai = {}

------------------------------------------------------------------------------------------
-- Targeting

local function nearest_enemy(surface, position, radius, force)
  return surface.find_nearest_enemy({position = position, max_distance = radius, force = force})
end

--- Nearest enemy to an assembler, cached per assembler (keep-radius-clear targeting).
local function assembler_threat(fd, assembler)
  local unit_number = assembler.unit_number
  local threat = fd.threats[unit_number]
  local now = game.tick
  if not threat then
    threat = {}
    fd.threats[unit_number] = threat
  end
  local enemy = threat.enemy
  if not (enemy and enemy.valid) or not threat.tick or now > threat.tick + config.ASSEMBLER_THREAT_REFRESH then
    enemy = nearest_enemy(assembler.surface, assembler.position, config.KEEP_RADIUS_CLEAR, assembler.force)
    threat.enemy = enemy
    threat.tick = now
    threat.distance = enemy and distance(assembler.position, enemy.position) or nil
  end
  return threat
end

local function choose_target(squad, fd)
  local group = squad.group
  local here = group.position
  local surface = squad.surface
  local radius = Squad.hunt_range(fd)
  local mode = cache.targeting

  if mode == cache.TARGET_DEFEND_ASSEMBLER then
    local assembler = Squad.nearest_assembler(fd, squad.surface_index, here)
    return nearest_enemy(surface, assembler and assembler.position or here, radius, squad.force)
  end

  if mode == cache.TARGET_KEEP_RADIUS_CLEAR then
    local assembler = Squad.nearest_assembler(fd, squad.surface_index, here)
    if assembler then
      local threat = assembler_threat(fd, assembler)
      local threat_enemy = threat.enemy
      if threat_enemy and threat_enemy.valid then
        if threat.distance < config.KEEP_RADIUS_CLEAR then
          return threat_enemy
        end
        local own = nearest_enemy(surface, here, radius, squad.force)
        if not own then return threat_enemy end
        -- go back for the assembler's enemy if ours is much farther from the assembler
        if threat.distance * config.HYBRID_BACKTRACK_FACTOR < distance(own.position, assembler.position) then
          return threat_enemy
        end
        return own
      end
    end
  end

  return nearest_enemy(surface, here, radius, squad.force)
end

local function hunt(squad, fd)
  local target = choose_target(squad, fd)
  if target then
    squad.idle_searches = 0
    Squad.order_attack(squad, target.position)
  else
    squad.idle_searches = min(squad.idle_searches + 1, 10)
    Squad.order_wander(squad, squad.group.position)
  end
end

------------------------------------------------------------------------------------------
-- Retreated squads merge at their assembler until they are big enough to hunt.

local function merge_at_assembler(squad, fd)
  local assembler = fd.assemblers[squad.retreat]
  if not (assembler and assembler.valid) or Squad.should_hunt(squad, fd) then
    Squad.leave_retreat(squad)
    squad.order.dirty = true
    return squad
  end
  local range2 = config.MERGE_RANGE * config.MERGE_RANGE
  if distance2(squad.pos, assembler.position) >= range2 then return squad end
  local set = fd.retreats[squad.retreat]
  if not set then return squad end
  for id in pairs(set) do
    local other = storage.squads[id]
    if not other then
      set[id] = nil
    elseif other ~= squad and other.mode == MODE.assemble and not other.qrf and not other.hold
      and other.surface_index == squad.surface_index and distance2(other.pos, squad.pos) < range2 then
      squad = Squad.merge(squad, other) or squad
      if Squad.should_hunt(squad, fd) then
        Squad.leave_retreat(squad)
        squad.order.dirty = true
        return squad
      end
    end
  end
  return squad
end

------------------------------------------------------------------------------------------
-- Behaviours

local function battle(squad, fd)
  local group = squad.group
  if group and group.valid and Squad.is_attacking(group) then
    squad.order.dirty = true -- give a new order once the fight is over
    return
  end
  if squad.mode == MODE.assemble and squad.retreat and not squad.hold then
    squad = merge_at_assembler(squad, fd)
    if squad.deleted then return end
  end
  local order = squad.order
  if not (order.dirty or Squad.order_due(squad)) then return end
  if game.tick < order.tick + config.MIN_ORDER_INTERVAL then return end
  local valid, may_order = Squad.validate(squad)
  if not valid or not may_order then return end
  if Squad.should_hunt(squad, fd) then
    hunt(squad, fd)
  else
    Squad.order_retreat(squad)
  end
end

local function guard(squad)
  local order = squad.order
  local now = game.tick
  if order.dirty then
    local group = Squad.ensure_group(squad)
    if group then Squad.order_guard(squad) end
    return
  end
  if now <= order.tick + config.SANITY_CHECK_PERIOD then return end
  order.tick = now
  local valid, may_order = Squad.validate(squad)
  if not valid or not may_order then return end
  local group = squad.group
  if not Squad.is_attacking(group) and distance(group.position, squad.home) > config.GUARD_HOME_RADIUS then
    Squad.order_guard(squad)
  end
end

------------------------------------------------------------------------------------------
-- Quick reaction force

--- Sends the squad to `position`. A squad already on its way to a QRF target ignores the call;
--- a returning one is retargeted but keeps the state it will return to.
function ai.start_qrf(squad, position)
  local group = squad.group
  if not (group and group.valid) or squad.size <= 0 then return false end
  local qrf = squad.qrf
  if qrf then
    if not qrf.returning then return false end
  else
    qrf = {mode = squad.mode, dest = copy_position(squad.order.dest), origin = copy_position(group.position)}
    squad.qrf = qrf
  end
  qrf.returning = false
  qrf.target = copy_position(position)
  qrf.tick = game.tick
  squad.mode = MODE.hunt
  group.set_command({
    type = command.attack_area,
    destination = position,
    radius = config.QRF_TARGET_RADIUS,
    distraction = distraction.by_anything,
  })
  group.start_moving()
  local order = squad.order
  order.tick = game.tick
  order.dirty = false
  return true
end

local function end_qrf(squad)
  local qrf = squad.qrf
  squad.qrf = nil
  squad.mode = qrf.mode
  squad.order.dest = qrf.dest
  squad.order.dirty = true
  local fd = storage.forces[squad.force_index]
  if fd then
    for _, other in pairs(fd.squads) do
      if other.qrf then return end
    end
    util.clear_alert(fd.force, util.ICON_QRF) -- the last responding squad is back
  end
end

--- Returns true while the QRF owns the squad (normal AI is skipped).
local function qrf_step(squad)
  local qrf = squad.qrf
  local group = squad.group
  if not (group and group.valid) then
    end_qrf(squad)
    return false
  end
  local now = game.tick
  local settled = now >= qrf.tick + config.QRF_MIN_DURATION
  local state = group.state
  local position = group.position
  if not qrf.returning then
    if settled and (state == group_state.finished or state == group_state.gathering
      or (state == group_state.moving and distance(position, qrf.target) < config.QRF_TARGET_REACHED)) then
      group.set_command({type = command.go_to_location, destination = qrf.origin, distraction = distraction.by_anything})
      group.start_moving()
      qrf.returning = true
      qrf.tick = now
      squad.order.tick = now
    end
    return true
  end
  if distance(position, qrf.origin) < config.QRF_HOME_REACHED
    or (settled and (state == group_state.finished or state == group_state.gathering)) then
    end_qrf(squad)
    return false
  end
  return true
end

------------------------------------------------------------------------------------------

--- Periodic update of one squad.
function ai.update(squad)
  if squad.deleted then return end
  if squad.size <= 0 or not squad.surface.valid then
    Squad.delete(squad, true)
    return
  end
  local fd = storage.forces[squad.force_index]
  Squad.position(squad)
  if squad.qrf and qrf_step(squad) then return end
  if squad.mode == MODE.guard then
    guard(squad)
  else
    battle(squad, fd)
  end
  if cache.loot_chest and not squad.deleted then
    loot.collect(squad, fd)
  end
end

local vision = {} -- unit name -> vision distance (prototype data, same on every peer)

--- After a droid finished a distraction, attack the nearest enemy instead of a random one.
function ai.retarget(unit)
  local commandable = unit.commandable
  if not commandable then return end
  local current = commandable.command
  local mode = (current and current.distraction) or distraction.by_enemy
  if mode == distraction.none then return end
  local name = unit.name
  local radius = vision[name]
  if not radius then
    radius = prototypes.entity[name].vision_distance
    vision[name] = radius
  end
  local params = {position = unit.position, max_distance = radius, force = unit.force}
  local surface = unit.surface
  local enemy = surface.find_nearest_enemy(params)
    or (mode == distraction.by_anything and surface.find_nearest_enemy_entity_with_owner(params))
  if enemy then
    commandable.set_distraction_command({type = command.attack, target = enemy})
  end
end

return ai
