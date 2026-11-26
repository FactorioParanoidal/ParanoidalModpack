-- Squads of the citadel. New droids join the squad gathering at the muster point (the core plaza);
-- a full squad marches on the player base as one unit group: one command per squad, never one per
-- droid. The heartbeat looks at every attacking squad every POLL heartbeats and gives it the next
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
local ABSORB_RANGE2 = 400 * 400
local RECRUIT_LOOKS = 25    -- droids inspected per recruitment sweep
local FAST_FAIL = 600        -- a march over before this many ticks counts as failed
local MAX_FAILS = 3
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

--- Recruit the local garrison first. At the cap, stranded idle droids must not prevent the
--- foundries from making replacements. Free only the slots missing for the next launch.
function Q.recruit(c, cfg)
  local f = c.forming
  local g = f and f.group
  local recruiting = g and g.valid and not f.defending
  if recruiting then
    f.target, f.count = Q.target_size(c, cfg), #g.members
  end
  local reclaim = recruiting and f.count < launch_size(c, f) and #c.waves < cfg.attack_groups
    and #c.foundries > 0 and P.unit_count(c) == cfg.unit_limit
  local returning
  if recruiting then
    for _, w in ipairs(c.waves) do
      if w.return_members and not w.group.valid then
        returning = returning or {}
        for _, e in ipairs(w.return_members) do
          if e.valid then returning[e.unit_number] = true end
        end
      end
    end
  end
  local strays
  P.sweep_units(c, RECRUIT_LOOKS, function(e)
    if not recruiting or f.count >= f.target or (returning and returning[e.unit_number]) then return end
    local commandable = e.commandable
    if not commandable or commandable.parent_group then return end
    if U.dist2(e.position, g.position) <= ABSORB_RANGE2 then
      g.add_member(e)
      f.count = f.count + 1
    elseif reclaim and not commandable.distraction_command then
      local order = commandable.command
      if not order or order.type == cmd.wander then
        strays = strays or {}
        strays[#strays + 1] = e
      end
    end
  end)
  if not strays then return end
  -- The sweep may already have found recruits or cleaned invalid units from the registry.
  local missing = launch_size(c, f) - f.count - (cfg.unit_limit - P.unit_count(c))
  for _, e in ipairs(strays) do
    if missing <= 0 then break end
    if e.valid then
      local id = e.unit_number
      if e.destroy() then
        P.remove_unit(c, id)
        missing = missing - 1
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Attacks.
---------------------------------------------------------------------------------------------------
function Q.march(c, w, to, level, direct)
  local g = w.group
  local attack = {type = cmd.attack_area, destination = to, radius = 24, distraction = dist.by_enemy}
  if direct and level < 4 then
    g.set_command(attack)
  else
    local commands = {}
    local travel = level >= 4 and dist.none or dist.by_enemy
    for i, p in ipairs(I.route(c, g.position, to, level)) do
      commands[i] = {type = cmd.go_to_location, destination = p, radius = 6, distraction = travel,
        pathfind_flags = {low_priority = true, cache = true, prefer_straight_paths = true}}
    end
    commands[#commands + 1] = attack
    g.set_command({type = cmd.compound, structure_type = compound.logical_and, commands = commands})
  end
  g.start_moving()
  w.phase, w.target, w.march_tick = "march", to, game.tick
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

local function release_return(c, w, arrived)
  -- Unlink only: survivors keep their entities and registry entries. M0 can reclaim them once
  -- ungrouped and idle, without kill credit or loot; this also leaves an active distraction alone.
  if w.group.valid then w.group.destroy() end
  local stat = arrived and "returned" or "retreat_abandoned"
  c.stats[stat] = (c.stats[stat] or 0) + 1
  return false
end

local function order_return(w, to, attempts)
  local g = w.group
  w.phase = "retreat"
  w.return_to, w.return_attempts, w.return_deadline = to, attempts, game.tick + RETURN_TIMEOUT
  w.return_retry = nil
  w.return_members = g.members
  w.still = 0
  g.set_command({type = cmd.go_to_location, destination = to, radius = 10, distraction = dist.by_enemy,
    pathfind_flags = {low_priority = true, cache = attempts == 1}})
  g.start_moving()
end

function Q.retreat(c, w, level)
  local to = home(c, w.group.position, level)
  if not to then return release_return(c, w, false) end
  order_return(w, to, 1)
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
  local members = g.valid and g.members or {}
  local force
  if not g.valid then
    -- Factorio may erase the group on a hard pathfinder failure without killing its droids.
    -- Recover only the surviving, still ungrouped members of this specific return order.
    force = forces.get()
    for _, e in ipairs(w.return_members or {}) do
      if e.valid and e.surface == surface and e.force == force and e.commandable
        and not e.commandable.parent_group then members[#members + 1] = e end
    end
  end
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
  if not g.valid then
    w.group = surface.create_unit_group({position = origin, force = force})
    for _, e in ipairs(members) do w.group.add_member(e) end
  end
  order_return(w, retry_to, w.return_attempts + 1)
  return true
end

--- The squad's attack command is over: next target nearby, the next known target, or home.
--- Returns false when the squad is disbanded.
local function next_step(c, surface, w, level)
  local g = w.group
  -- a march that ends at once has no path (water, walls): after a few such tries the squad goes home
  if w.phase == "march" and w.march_tick and game.tick - w.march_tick < FAST_FAIL then
    w.fails = (w.fails or 0) + 1
  end
  w.steps = (w.steps or 0) + 1
  if w.steps > MAX_STEPS or (w.fails or 0) >= MAX_FAILS then
    return Q.retreat(c, w, level)
  end
  local target = I.local_target(c, surface, g.position, level)
  if target then
    g.set_command({type = cmd.attack_area, destination = target, radius = 16, distraction = dist.by_enemy})
    w.phase = "attack"
    return true
  end
  local p = g.position
  local nt = I.choose_target(c, level, p, {p}, surface)
  if nt and U.dist2(nt, p) > 48 * 48 then
    Q.march(c, w, nt, level)
    return true
  end
  return Q.retreat(c, w, level)
end

local function poll(c, surface, w)
  local g = w.group
  if not g then return false end
  local level = level_of(c)
  if not g.valid then
    return w.phase == "retreat" and poll_return(c, surface, w, level, true)
  end
  local n = #g.members
  if n == 0 then
    g.destroy()
    return w.phase == "retreat" and poll_return(c, surface, w, level, true)
  end
  if level >= 1 and w.phase ~= "retreat" and n < w.size0 * RETREAT_SHARE then
    return Q.retreat(c, w, level)
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
  if ended then
    w.still = 0
    return next_step(c, surface, w, level)
  end
  return true
end

local function new_wave(c, group, target)
  local p = group.position
  local w = {id = c.next_wave, group = group, size0 = #group.members, target = target, phase = "march",
    steps = 0, born = game.tick, last = {x = p.x, y = p.y}, still = 0}
  c.next_wave = c.next_wave + 1
  c.waves[#c.waves + 1] = w
  return w
end

function Q.launch(c, cfg, surface)
  local f = c.forming
  local g = f.group
  local level = level_of(c)
  local origin = g.position
  local nearby = I.raid_target(surface, origin, level)
  local target = nearby or I.choose_target(c, level, origin, nil, surface)
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
    Q.march(c, new_wave(c, group, targets[i]), targets[i], level, nearby ~= nil and targets[i] == target)
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
      g.set_command({type = cmd.compound, structure_type = compound.return_last, commands = {
        {type = cmd.attack_area, destination = alarm.position, radius = 30, distraction = dist.by_enemy},
        {type = cmd.go_to_location, destination = muster, radius = 6},
      }})
      g.start_moving()
      f.defending = game.tick
      c.alarm = nil
    elseif f.defending and (not g.has_command or game.tick - f.defending > 18000) then
      f.defending = nil
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
