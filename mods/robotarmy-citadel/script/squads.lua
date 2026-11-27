-- Squads of the citadel. New droids join the squad gathering at the muster point (the core plaza);
-- a full squad marches on the player base as one unit group. The heartbeat looks at every
-- attacking squad every POLL heartbeats and gives it the next
-- step when its command is over: a target nearby, the next known target, or the way home.
local U = require("script.util")
local M = require("script.modules")
local P = require("script.production")
local I = require("script.intel")
local forces = require("script.forces")

local Q = {}

local POLL = 2               -- heartbeats between two looks at a squad
local RETREAT_SHARE = 0.35   -- a disciplined squad turns back below this share of its size
local MAX_STEPS = 30         -- targets one squad takes before it goes home
local STILL_LIMIT = 8        -- looks without moving before a squad gets its step again
local ABSORB_RANGE = 400
local ABSORB_RANGE2 = ABSORB_RANGE * ABSORB_RANGE
local RECRUIT_LOOKS = 25    -- droids inspected per recruitment sweep
local MARCH_NEAR2 = 48 * 48 -- command radius plus room for the formation
local MARCH_WAIT = 7200      -- bound continuous motionless pathfinding/gathering
local REJOIN_RANGE2 = 32 * 32
local RETURN_RADIUS2 = 24 * 24 -- includes the command's arrival radius and group formation
local RETURN_ATTEMPTS = 3
local RETURN_RETRY = 300
local RETURN_TIMEOUT = 36000 -- even a group stuck pathfinding or fighting eventually frees its slot

local cmd, dist, compound = defines.command, defines.distraction, defines.compound_command

---------------------------------------------------------------------------------------------------
-- Muster point and the gathering squad.
---------------------------------------------------------------------------------------------------
local function usable(m)
  return m and m.built and not m.ruined
end

--- Module whose plaza is the muster point: the core, else the first foundry module, else any.
function Q.muster_module(c)
  local m = c.core_key and c.modules[c.core_key]
  if usable(m) then return m end
  local any
  for _, k in ipairs(c.order) do
    local o = c.modules[k]
    if usable(o) then
      if M.types[o.type].cat == "production" then return o end
      any = any or o
    end
  end
  return any
end

function Q.muster(c)
  local m = Q.muster_module(c)
  return m and P.muster_of(m)
end

function Q.target_size(c, cfg)
  local production = 0
  for name, n in pairs(c.alive) do
    local t = M.types[name]
    if t and t.cat == "production" then production = production + n end
  end
  return math.min(cfg.unit_limit, cfg.squad_max, cfg.squad_base + production)
end

local function forming(c, surface)
  local f = c.forming
  if f and f.group and f.group.valid then return f end
  local position = Q.muster(c)
  if not position then return nil end
  c.forming = {group = surface.create_unit_group({position = position, force = forces.get()}), count = 0, target = 1}
  return c.forming
end

--- A new droid: into the gathering squad if it needs one.
function Q.assign(c, e)
  local f = c.forming
  if f and f.group and f.group.valid and not f.defending and f.count < (f.target or 1) then
    f.group.add_member(e)
    f.count = f.count + 1
  end
end

local function level_of(c)
  return c.upgrades.intel or 0
end

local function launch_size(c, f)
  return level_of(c) >= 1 and f.target or math.ceil(f.target * 0.6)
end

local function idle(a)
  return not a.distraction_command and (not a.command or a.command.type == cmd.wander)
end

local function recall_order(e, r)
  local a = e.commandable
  local order = a and a.command
  return not a.distraction_command and order and order.type == cmd.go_to_location and order.destination
    and U.dist2(order.destination, r.to) < 1 and order.radius == 10
end

--- Before retiring anyone, check the whole local garrison, not just this registry slice.
--- Above a newly lowered cap, recall existing droids on foot instead of deleting the surplus.
function Q.recruit(c, cfg)
  local f = c.forming
  local g = f and f.group
  local recruiting = g and g.valid and not f.defending
  if recruiting then
    f.target, f.count = Q.target_size(c, cfg), #g.members
  end
  local looks = math.min(RECRUIT_LOOKS, P.unit_count(c))
  if not recruiting or f.count >= f.target then
    P.sweep_units(c, looks)
    return
  end
  local at_cap = f.count < launch_size(c, f) and #c.waves < cfg.attack_groups
    and #c.foundries > 0 and P.unit_count(c) >= cfg.unit_limit
  local force = forces.get()
  local reserved
  for _, w in ipairs(c.waves) do
    local members = w.return_members or w.raid_members
    if members then
      reserved = reserved or {}
      for _, e in ipairs(members) do
        if e.valid then reserved[e.unit_number] = true end
      end
    end
  end
  local strays
  local function inspect(e, collect)
    if f.count >= f.target then return end -- owned registry slice or force/surface-filtered local search
    local id, a = e.unit_number, e.commandable
    if (reserved and reserved[id]) or not a or a.parent_group then return end
    local r = f.recalls and f.recalls[id]
    if not idle(a) and not (r and recall_order(e, r)) then return end
    if U.dist2(e.position, g.position) <= ABSORB_RANGE2 then
      g.add_member(e)
      f.count = f.count + 1
      if r then f.recalls[id] = nil end
    elseif collect and idle(a) then
      strays = strays or {}
      strays[#strays + 1] = e
    end
  end
  P.sweep_units(c, looks, function(e) inspect(e, at_cap) end)
  if not strays or f.count >= launch_size(c, f) then return end
  local origin = g.position
  for _, e in ipairs(strays[1].surface.find_entities_filtered({position = origin, radius = ABSORB_RANGE,
    force = force, type = "unit"})) do
    if f.count >= f.target then break end
    if c.units.index[e.unit_number] then inspect(e, false) end
  end
  local count, pending = P.unit_count(c), 0
  for id, r in pairs(f.recalls or {}) do
    local e = r.e
    if e.valid and e.force == force and e.surface.index == c.surface and e.commandable and not e.commandable.parent_group
      and r.until_tick > game.tick and recall_order(e, r) then pending = pending + 1
    else f.recalls[id] = nil end
  end
  local missing = launch_size(c, f) - f.count - pending - math.max(0, cfg.unit_limit - count)
  for _, e in ipairs(strays) do
    if missing <= 0 then break end
    if forces.owns(c, e) and idle(e.commandable) then
      local id = e.unit_number
      if count > cfg.unit_limit then
        e.commandable.set_command({type = cmd.go_to_location, destination = origin, radius = 10,
          distraction = dist.by_enemy, pathfind_flags = {low_priority = true, cache = true}})
        f.recalls = f.recalls or {}
        f.recalls[id] = {e = e, to = origin, until_tick = game.tick + RETURN_TIMEOUT}
        missing = missing - 1
      elseif e.destroy() then
        P.remove_unit(c, id)
        missing = missing - 1
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Attacks.
---------------------------------------------------------------------------------------------------
local function traversable(surface, p, layers)
  local x, y = U.chunk_of(p)
  if not surface.is_chunk_generated({x, y}) then return false end
  local tile = surface.get_tile(p)
  for layer in pairs(layers) do
    if tile.collides_with(layer) then return false end
  end
  return true
end

function Q.march(c, surface, w, to, level, nearby, bypass, reason, current_members)
  local g = w.group
  local attack = {type = cmd.attack_area, destination = to, radius = 24, distraction = dist.by_enemy}
  if nearby and level < 4 and not bypass then
    g.set_command(attack)
  else
    local commands = {}
    local travel = level >= 4 and dist.none or dist.by_enemy
    local function go(p, radius)
      commands[#commands + 1] = {type = cmd.go_to_location, destination = p, radius = radius, distraction = travel,
        pathfind_flags = {low_priority = true, cache = not bypass, prefer_straight_paths = not bypass}}
    end
    if not bypass then
      local members = current_members or g.members
      local layers = {}
      for _, e in ipairs(members) do
        for layer in pairs(e.prototype.collision_mask.layers) do layers[layer] = true end
      end
      local points = I.route(c, members[1].position, to, level)
      -- A logical_and route fails when any mandatory stop is unreachable. Test actual unit
      -- layers, not the water_tile label (ground droids can collide via the player layer).
      for i = 1, #points - 1 do
        local p = points[i]
        if traversable(surface, p, layers) then go(p, 6) end
      end
    end
    go(to, 24) -- no exact intermediate stop at the centre of the final attack area
    commands[#commands + 1] = attack
    g.set_command({type = cmd.compound, structure_type = compound.logical_and, commands = commands})
  end
  g.start_moving()
  w.phase, w.target, w.march_bypass = "march", to, bypass or nil
  w.order_reason = reason or "march"
  if not bypass then w.short_target = nil end
  w.still, w.wait_pos, w.wait_tick = 0, nil, nil
end

--- The nearest repair dock plaza (intelligence 6) or the muster point.
local function home(c, from, level)
  if level >= 6 and (c.alive["repair-dock"] or 0) > 0 then
    local best, best_d
    for _, k in ipairs(c.order) do
      local m = c.modules[k]
      if usable(m) and m.type == "repair-dock" then
        local p = P.muster_of(m)
        local d = U.dist2(from, p)
        if not best_d or d < best_d then best, best_d = p, d end
      end
    end
    if best then return best end
  end
  return Q.muster(c)
end

local function recoverable(e, force, surface)
  if not e.valid or e.force ~= force or e.surface ~= surface then return false end
  local a = e.commandable
  if not a or a.parent_group or a.distraction_command then return false end
  local order = a.command
  return not order or order.type == cmd.wander
end

local function send_home(c, e, level)
  local to = home(c, e.position, level)
  if to then
    e.commandable.set_command({type = cmd.go_to_location, destination = to, radius = 10,
      distraction = dist.by_enemy, pathfind_flags = {low_priority = true, cache = true}})
  end
end

local function release_return(c, w, arrived)
  -- Unlink only: survivors keep their entities and registry entries. M0 can reclaim them once
  -- ungrouped and idle, without kill credit or loot; this also leaves an active distraction alone.
  if w.group.valid then w.group.destroy() end
  local stat = arrived and "returned" or "retreat_abandoned"
  c.stats[stat] = (c.stats[stat] or 0) + 1
  return false
end

local function order_return(w, to, attempts, reason)
  local g = w.group
  w.raid_members, w.rejoined, w.march_bypass, w.wait_pos, w.wait_tick = nil, nil, nil, nil, nil
  w.phase, w.short_target = "retreat", nil
  if g.valid then w.order_reason = reason or "return-retry" end
  w.return_to, w.return_attempts, w.return_deadline = to, attempts, game.tick + RETURN_TIMEOUT
  w.return_retry = nil
  if not w.return_members and g.valid then w.return_members = g.members end
  w.still = 0
  if not g.valid then return end -- only busy detached survivors: do not take their orders
  g.set_command({type = cmd.go_to_location, destination = to, radius = 10, distraction = dist.by_enemy,
    pathfind_flags = {low_priority = true, cache = attempts == 1}})
  g.start_moving()
end

function Q.retreat(c, w, level, reason)
  local g = w.group
  local to = home(c, g.position, level)
  if w.raid_members then
    local force, surface = g.force, g.members[1].surface
    for _, e in ipairs(w.raid_members) do
      if recoverable(e, force, surface) then send_home(c, e, level) end
    end
  end
  if not to then return release_return(c, w, false) end
  order_return(w, to, 1, reason or "retreat")
  return true
end

local function poll_return(c, surface, w, level, ended)
  local g = w.group
  if not w.return_attempts then
    if not g.valid then return false end
    -- Old saves: prefer the existing command's destination and do not reissue on load.
    local order = g.command
    w.return_to = order and order.type == cmd.go_to_location and order.destination or home(c, g.position, level)
    w.return_attempts, w.return_deadline = 1, game.tick + RETURN_TIMEOUT
    w.return_members = g.members
  end
  if not (ended or w.return_retry or game.tick >= w.return_deadline) then return true end
  local force = forces.get()
  local members = {}
  for _, e in ipairs(w.return_members or {}) do
    if e.valid and e.surface == surface and e.force == force and e.commandable then
      local owner = e.commandable.parent_group
      if not owner or owner == g then members[#members + 1] = e end
    end
  end
  w.return_members = members -- prune deaths/transfers, never replace survivors with just g.members
  if #members == 0 then
    if g.valid then g.destroy() end
    return false
  end
  -- on_ai_command_completed can also report distractions; the group position during a march is
  -- predicted. Neither is proof of arrival: verify all remaining members at the saved destination.
  local to = w.return_to
  if to then
    local at_home = true
    for _, e in ipairs(members) do
      if U.dist2(e.position, to) > RETURN_RADIUS2 then at_home = false; break end
    end
    if at_home then return release_return(c, w, true) end
  end
  if not w.return_retry then w.return_retry = game.tick + RETURN_RETRY end
  if game.tick < w.return_retry then return true end
  if w.return_attempts >= RETURN_ATTEMPTS then return release_return(c, w, false) end
  local origin = members[1].position
  local retry_to = Q.muster(c) or home(c, origin, level)
  if not retry_to then return release_return(c, w, false) end
  for _, e in ipairs(members) do
    if recoverable(e, force, surface) then
      if not w.group.valid then w.group = surface.create_unit_group({position = e.position, force = force}) end
      w.group.add_member(e)
    end
  end
  order_return(w, retry_to, w.return_attempts + 1)
  return true
end

local function rejoin(c, w, surface, g, members, level)
  local origin, force = members[1].position, g.force
  local roster, n = w.raid_members, 0
  for _, e in ipairs(roster) do
    if e.valid and e.force == force and e.surface == surface then
      local a = e.commandable
      local group = a and a.parent_group
      local keep = not group or group == g
      if not group and recoverable(e, force, surface) then
        w.rejoined = w.rejoined or {}
        local id = e.unit_number
        if not w.rejoined[id] and U.dist2(e.position, origin) <= REJOIN_RANGE2 then
          g.add_member(e)
          w.rejoined[id] = true
        else
          -- Don't drag the squad back for a distant or repeatedly detached droid.
          send_home(c, e, level)
          keep = false
        end
      end
      if keep then
        n = n + 1
        roster[n] = e
      end
    end
  end
  for i = #roster, n + 1, -1 do roster[i] = nil end
end

local function recover_raid(c, surface, w, level)
  if not w.raid_members then return false end -- old save where the group was already gone
  local force = forces.get()
  local members = {}
  for _, e in ipairs(w.raid_members) do
    if recoverable(e, force, surface) then members[#members + 1] = e end
  end
  if #members == 0 then return false end
  w.group = surface.create_unit_group({position = members[1].position, force = force})
  for _, e in ipairs(members) do w.group.add_member(e) end
  -- Keep the same raid and its slot. Do not endlessly rebuild a group on an unreachable route.
  if w.target and not w.march_bypass then
    Q.march(c, surface, w, w.target, level, false, true, "group-rebuilt")
    return true
  end
  return Q.retreat(c, w, level, "bypass-group-lost")
end

--- The squad's attack command is over: next target nearby, the next known target, or home.
local function next_step(c, surface, w, level, members)
  local g = w.group
  if w.phase == "march" and w.target then
    local near = false
    for _, e in ipairs(members) do
      if U.dist2(e.position, w.target) <= MARCH_NEAR2 then near = true; break end
    end
    if not near then
      if w.march_bypass then
        -- A deleted group or a casualty retreat alone is not evidence against its route.
        if w.short_target and U.dist2(w.target, w.short_target) == 0 then I.failed_route(c, w.target) end
        return Q.retreat(c, w, level, "bypass-ended-short")
      end
      w.short_target = w.target
      Q.march(c, surface, w, w.target, level, false, true, "march-ended-short")
      return true
    end
  end
  w.steps = (w.steps or 0) + 1
  if w.steps > MAX_STEPS then
    return Q.retreat(c, w, level, "step-limit")
  end
  local p = members[1].position
  local target, defer = I.local_target(c, surface, p, level)
  local nt
  if defer or not target then nt = I.choose_target(c, level, p, {p}, surface, target) end
  if target and (not defer or nt == target) then
    g.set_command({type = cmd.attack_area, destination = target, radius = 16, distraction = dist.by_enemy})
    w.phase, w.target, w.order_reason = "attack", target, "engage-local"
    return true
  end
  if nt and U.dist2(nt, p) > MARCH_NEAR2 then
    Q.march(c, surface, w, nt, level, false, false, "next-target", members)
    return true
  end
  return Q.retreat(c, w, level, "no-next-target")
end

local function poll(c, surface, w)
  local g = w.group
  if not g then return false end
  local level = level_of(c)
  local members = g.valid and g.members or {}
  if #members == 0 then
    if g.valid then g.destroy() end
    if w.phase == "retreat" then return poll_return(c, surface, w, level, true) end
    return recover_raid(c, surface, w, level)
  end
  -- Track one real member, not the group's predicted position. Replacing the witness is not motion.
  local witness = w.witness
  if not (witness and witness.valid and witness.commandable and witness.commandable.parent_group == g) then
    witness = members[1]
    w.witness, w.witness_pos = witness, witness.position
  elseif U.dist2(witness.position, w.witness_pos) >= 4 then
    w.witness_pos, w.progress_tick = witness.position, game.tick
  end
  if w.phase ~= "retreat" then
    if not w.raid_members then w.raid_members = members end -- lazy upgrade of a live saved raid
    if #members < #w.raid_members then
      rejoin(c, w, surface, g, members, level)
      members = g.members
    end
  end
  if level >= 1 and w.phase ~= "retreat" and #members < w.size0 * RETREAT_SHARE then
    return Q.retreat(c, w, level, "heavy-losses")
  end
  local p = g.position
  local state = g.state
  local gs = defines.group_state
  -- standing still while fighting, waiting for a path or gathering is not being stuck
  local busy = state == gs.attacking_distraction or state == gs.attacking_target or state == gs.pathfinding
    or state == gs.gathering
  if not busy and U.dist2(p, w.last) < 4 then w.still = w.still + 1 else w.still = 0 end
  w.last = {x = p.x, y = p.y}
  local ended = not g.has_command or state == gs.finished or w.still >= STILL_LIMIT
  if w.phase == "retreat" then return poll_return(c, surface, w, level, ended) end
  if w.phase == "march" and (state == gs.pathfinding or state == gs.gathering) then
    local actual = members[1].position
    if not w.wait_pos or U.dist2(actual, w.wait_pos) >= 4 then w.wait_pos, w.wait_tick = actual, game.tick end
    ended = ended or game.tick - w.wait_tick >= MARCH_WAIT
  else
    w.wait_pos, w.wait_tick = nil, nil
  end
  if ended then
    w.still = 0
    return next_step(c, surface, w, level, members)
  end
  return true
end

local function new_wave(c, group, target)
  local p = group.position
  local launched, active = group.members, {}
  for i, e in ipairs(launched) do active[i] = e end -- rejoin prunes active, never the launch snapshot
  local w = {id = c.next_wave, group = group, size0 = #launched, target = target, phase = "march",
    steps = 0, born = game.tick, last = {x = p.x, y = p.y}, still = 0, raid_members = active,
    launch_members = launched}
  c.next_wave = c.next_wave + 1
  c.waves[#c.waves + 1] = w
  return w
end

function Q.launch(c, cfg, surface)
  local f = c.forming
  local g = f.group
  local level = level_of(c)
  local origin = g.position
  local nearby, defer = I.raid_target(surface, origin, level, c)
  local target = (not defer and nearby) or I.choose_target(c, level, origin, nil, surface, nearby)
  if not target then return end
  c.forming = nil
  local groups, targets = {g}, {target}
  if level >= 5 and f.count >= 8 and #c.waves + 2 <= cfg.attack_groups then
    local g2 = surface.create_unit_group({position = origin, force = forces.get()})
    local members = g.members
    for i = 1, math.floor(#members / 2) do g2.add_member(members[i]) end
    groups[2] = g2
    targets[2] = I.choose_target(c, level, origin, {target}, surface) or target
  end
  for i, group in ipairs(groups) do
    local direct = targets[i] == nearby
    local w = new_wave(c, group, targets[i])
    Q.march(c, surface, w, targets[i], level, direct, false,
      direct and "launch-nearby" or "launch-distant", w.launch_members)
  end
  c.stats.launched = c.stats.launched + #groups
end

--- One heartbeat: the gathering squad (defence of the citadel, launch) and a look at the squads.
function Q.step(c, cfg, surface)
  local f = forming(c, surface)
  if f then
    local g = f.group
    f.target = Q.target_size(c, cfg)
    f.count = #g.members
    local alarm = c.alarm
    if alarm and not f.defending and f.count > 0 and game.tick - alarm.tick < 600 then
      local muster = Q.muster(c)
      local defend = {type = cmd.attack_area, destination = alarm.position, radius = 30, distraction = dist.by_enemy}
      if muster then
        g.set_command({type = cmd.compound, structure_type = compound.return_last, commands = {
          defend, {type = cmd.go_to_location, destination = muster, radius = 6}}})
      else
        g.set_command(defend)
        f.await_muster = true
      end
      g.start_moving()
      f.defending = game.tick
      c.alarm = nil
    elseif f.defending and (not g.has_command or game.tick - f.defending > 18000
      or (f.await_muster and g.state == defines.group_state.finished)) then
      if f.await_muster then
        local muster = Q.muster(c)
        if muster then
          g.set_command({type = cmd.go_to_location, destination = muster, radius = 6})
          g.start_moving()
          f.await_muster, f.defending = nil, game.tick
        end
      else
        f.defending = nil
      end
    end
    if not f.defending and f.count >= launch_size(c, f) and #c.waves < cfg.attack_groups then
      Q.launch(c, cfg, surface)
    end
  end
  c.beat_waves = (c.beat_waves or 0) + 1
  for i = #c.waves, 1, -1 do
    local w = c.waves[i]
    if (c.beat_waves + w.id) % POLL == 0 and not poll(c, surface, w) then
      table.remove(c.waves, i)
    end
  end
end

--- Stops every squad (the citadel is destroyed).
function Q.disband_all(c)
  for _, w in pairs(c.waves) do
    if w.group and w.group.valid then w.group.destroy() end
  end
  c.waves = {}
  if c.forming and c.forming.group and c.forming.group.valid then c.forming.group.destroy() end
  c.forming = nil
end

return Q
