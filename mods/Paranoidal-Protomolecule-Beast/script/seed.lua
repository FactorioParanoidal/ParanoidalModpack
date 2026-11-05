-- The seed: the protomolecule before it has a core (the user's decision of 2026-11-05). A landing that gives it no
-- carrier, or whose carriers all die, doesn't end of itself: it lives on in what it infected and grows, weak and hidden
-- at first, until it has a carrier to take it to its lair. Only the player curing or destroying the last of it ends it
-- (outbreak.lua: "repelled" or "extinct").
--
-- It grows slowly on its own (seed-minutes to a carrier) and faster on power, which it draws from the player's network
-- through a hidden consumer of the player's own that the network's statistics list as "Wire resistance". That draw creeps
-- up on what the network can spare until the network can't keep up and the lights flicker; then it gives some back, lies
-- low for a while and creeps up again. Power speeds its growth, but a body takes matter, which it has to find as well.
-- In order, as it grows:
--   it lies low, and whatever is built against what it infected is taken (its zone at the outpost);
--   it sucks the ore from under its drills, beside what they mine, for mass;
--   it taps the player's network (above);
--   its zone and how far it senses widen;
--   it creeps one building at a time along belts and copper wires and into what a pole powers, towards an inserter it
--   can turn into a carrier, else a power building, which it would carry home as its first sample, else the base, and
--   keeps clear of turrets while it still keeps out of fights;
--   short of matter with no ore left to suck, it eats the outpost's buildings it doesn't need;
--   grown and with the mass for it, it raises one of its buildings on legs of its own, with no inserters in them, which
--   walks to the lair's site as a carrier. If that dies on the way, it grows another.
-- Once there is a core the seed is done, but the draw on the player's network stays and taps whatever it has infected,
-- wherever that is: it fills the lair's energy store and counts as stolen power for its research (outbreak.lua).
-- 2.1: LuaEntity.electric_network (a LuaElectricSubNetwork), its parent_network.flow_last_tick and the writable
-- power_usage and electric_buffer_size of an electric energy interface are 2.1.24 API; a consumer of another force than
-- a pole's, and a pole or a building moved to another force, stay on the pole's network (probe
-- test-runs/beastpower-probe1-20261105).
local shared = require("shared")
local config = require("script.config")
local infection = require("script.infection")
local contents = require("script.contents")
local outbreak = require("script.outbreak")

local seed = {}

local leech_name = "beast-wire-resistance"
local target_force = "player"
local minute = 60 * 60

-- How grown it is: 0 when it lands, 1 when it can raise a carrier. It taps the network from leech_from, widens from
-- widen_from, creeps from creep_from and gets hungry from hunger_from. Growth is seed-minutes to 1 on its own, faster on
-- power drawn: twice as fast at half_power, at most max_speed times. Raising a carrier sets it back to regrow.
local leech_from = 0.1
local widen_from = 0.2
local creep_from = 0.3
local hunger_from = 0.6
local half_power = 5e6
local max_speed = 6
local regrow = 0.5

-- Its zone at the outpost: the outpost's radius and a little, widening by zone_growth tiles as it grows. Kept open from
-- one update to the next, so it closes by itself if the seed stops.
local zone_key = "seed"
local zone_extra = 4
local zone_growth = 32
local zone_ticks = 3 * 60
local sense_min, sense_max = 48, 160

-- Creeping: one building every crawl_ticks at its own pace, faster on power, the best of what the crawl_tips buildings
-- nearest its goal that still touch something new are in contact with (of at most tips_scan nearest). A goal it gets no
-- closer to in stuck_steps steps, or can't reach at all, it leaves be for give_up_ticks.
local crawl_ticks = 90 * 60
local crawl_tips = 6
local tips_scan = 60
-- What's infected comes oldest first, so the crawl looks at many more of it, or its newest tips would drop out of sight;
-- the rest only need the outpost's.
local crawl_scan = 2000
local body_scan = 400
local stuck_steps = 8
local give_up_ticks = 10 * minute
local turret_types = {"ammo-turret", "electric-turret", "fluid-turret"}
local turret_sight = 24
local is_prey = {["inserter"] = true, ["roboport"] = true}
-- While it keeps out of fights it keeps quiet as well: an infected belt or pipe stops what runs along it, as the player's
-- and its own don't join, and that would be noticed, while an infected pole carries the power on as before. So it takes
-- one only where nothing quieter is in reach, and goes near turrets only where nothing else is: each of those counts as a
-- whole tier further off.
local is_loud = {["transport-belt"] = true, ["underground-belt"] = true, ["splitter"] = true, ["pipe"] = true, ["pipe-to-ground"] = true}
local tier_value = 1e12

-- Feeding: ore units a second from under each of its drills, and how many make a tile of mass.
local ore_per_second = 1
local ore_per_mass = 50
local feeding_drills = 40

-- Eating the outpost: one of these a minute at its own pace, nearest where it landed first, a drill only when nothing else
-- is left and never its last one. Never a pole, which its draw may hang on and which carries the player's power on.
local absorb_ticks = 60 * 60
local absorbable =
{
  ["transport-belt"] = true, ["underground-belt"] = true, ["splitter"] = true, ["wall"] = true, ["container"] = true,
  ["logistic-container"] = true, ["lamp"] = true, ["pipe"] = true, ["pipe-to-ground"] = true, ["mining-drill"] = true
}
-- A body takes this much mass a tile.
local mass_per_tile = 2

-- The draw: it starts at leech_start and never goes below leech_floor. While the network keeps up it creeps up each
-- second by creep_own of itself, creep_network of what the network can produce and creep_floor; when the network falls
-- short it drops to back_off of itself and lies low for quiet ticks. One on each of at most leech_max networks.
local leech_start = 20e3
local leech_floor = 10e3
local creep_own = 0.001
local creep_network = 0.0002
local creep_floor = 1e3
local back_off = 0.8
local quiet = {min = 90 * 60, max = 240 * 60}
local full = 0.999
local leech_max = 3
local attach_ticks = 10 * 60
local host_scan = 200
local bad_host_ticks = 10 * minute

local function clamp(value)
  return math.max(0, math.min(1, value))
end

local function area(name)
  local prototype = prototypes.entity[name]
  return prototype and math.max(1, prototype.tile_width * prototype.tile_height) or 1
end

local function speed(power)
  return 1 + (max_speed - 1) * power / (power + half_power)
end

local function get(state)
  local s = state.seed
  if not s then
    s =
    {
      growth = 0, mass = 0, energy = 0, power = 0, leeches = {}, bad = {}, given_up = {}, ore = 0, fed = 0, crawled = 0,
      absorbed = 0, raised = 0, flickers = 0, last = game.tick, next_attach = game.tick,
      next_crawl = game.tick + crawl_ticks, next_absorb = game.tick + absorb_ticks
    }
    state.seed = s
  end
  return s
end

-- Without the timed-out entries, so that the tables don't grow for good.
local function prune(list)
  if table_size(list) < 100 then return end
  for key, until_tick in pairs(list) do
    if game.tick >= until_tick then list[key] = nil end
  end
end

local function remove_leech(s, index)
  local leech = s.leeches[index]
  if leech.entity.valid then leech.entity.destroy() end
  table.remove(s.leeches, index)
end

local function clear_leeches(s)
  for index = #s.leeches, 1, -1 do remove_leech(s, index) end
end

-- Where a consumer on the host's network stands in a pole's supply area: on a pole's own spot. Its own if it's a pole.
local function tap_point(host, network)
  if host.type == "electric-pole" then return host.position end
  for _, pole in pairs(host.surface.find_entities_filtered{position = host.position, radius = host.get_radius() + 10, type = "electric-pole"}) do
    if pole.electric_network_id == network then return pole.position end
  end
end

-- One more draw on a network it hasn't tapped yet, from something it has infected, a pole first, as it lives in the
-- copper. How many it put on.
local function attach(s, surface)
  if #s.leeches >= leech_max then return 0 end
  prune(s.bad)
  local taken = {}
  for _, leech in pairs(s.leeches) do taken[leech.network] = true end
  local poles, others = {}, {}
  for _, host in pairs(infection.infected_on(surface.index, host_scan)) do
    local list = host.type == "electric-pole" and poles or others
    list[#list + 1] = host
  end
  local attached = 0
  for _, list in ipairs{poles, others} do
    for _, host in pairs(list) do
      if #s.leeches >= leech_max then return attached end
      local bad = s.bad[host.unit_number]
      local network = not (bad and game.tick < bad) and host.electric_network_id
      if network and not taken[network] then
        local position = tap_point(host, network)
        if not position then s.bad[host.unit_number] = game.tick + bad_host_ticks end
        local entity = position and surface.create_entity{name = leech_name, position = position, force = target_force}
        if entity then
          entity.destructible = false
          entity.power_usage = leech_start / 60
          entity.electric_buffer_size = leech_start / 60 * 2
          s.leeches[#s.leeches + 1] = {entity = entity, host = host, network = network, watts = leech_start, since = game.tick}
          taken[network] = true
          attached = attached + 1
        end
      end
    end
  end
  return attached
end

-- Each draw creeps up on what its network can spare while the network keeps up; once the network falls short (the
-- lights flicker) it gives some back and lies low a while. What they drew (J) and draw now (W). A draw whose host is
-- cured or gone, or that is off any network, comes off; two on one network (networks joined) become one.
local function draw(s, ticks)
  local seconds = ticks / 60
  local cap = config.get("leech-max-mw") * 1e6
  local drawn, power, seen = 0, 0, {}
  for index = #s.leeches, 1, -1 do
    local leech = s.leeches[index]
    local entity, host = leech.entity, leech.host
    local sub = entity.valid and host.valid and infection.is_infected(host) and entity.electric_network or nil
    local network = sub and entity.electric_network_id
    if not network then
      if host.valid then s.bad[host.unit_number] = game.tick + bad_host_ticks end
      remove_leech(s, index)
    elseif seen[network] then
      remove_leech(s, index)
    else
      seen[network] = true
      leech.network = network
      local flow = sub.parent_network.flow_last_tick
      local satisfaction = flow.consumption_satisfaction
      if not (satisfaction == satisfaction) then satisfaction = 0 end
      satisfaction = math.max(0, math.min(1, satisfaction))
      local got = leech.watts * satisfaction
      drawn = drawn + got * seconds
      power = power + got
      local watts = leech.watts
      if satisfaction < full then
        if game.tick >= (leech.quiet_until or 0) then s.flickers = s.flickers + 1 end
        watts = watts * back_off
        leech.quiet_until = game.tick + math.random(quiet.min, quiet.max)
      elseif game.tick >= (leech.quiet_until or 0) then
        watts = watts + (watts * creep_own + flow.maximum_production * 60 * creep_network + creep_floor) * seconds
      end
      leech.watts = math.max(leech_floor, math.min(cap, watts))
      entity.power_usage = leech.watts / 60
      entity.electric_buffer_size = leech.watts / 60 * 2
    end
  end
  return drawn, power
end

-- The ore under its drills, for mass, beside what the drills mine. Never an infinite resource, and never the last of a
-- patch. How many drills fed it.
local function feed(s, surface, ticks)
  local take = math.max(1, math.floor(ore_per_second * ticks / 60 + 0.5))
  local drills, fed = 0, 0
  for _, entity in pairs(infection.infected_on(surface.index, body_scan)) do
    if entity.type == "mining-drill" then
      drills = drills + 1
      if drills > feeding_drills then break end
      local ore = entity.mining_target
      if ore and ore.valid and ore.type == "resource" and not ore.prototype.infinite_resource and ore.amount > take + 1 then
        ore.amount = ore.amount - take
        s.ore = s.ore + take
        s.mass = s.mass + take / ore_per_mass
        fed = fed + 1
      end
    end
  end
  return fed
end

local function given_up(s, key)
  local until_tick = s.given_up[key]
  return until_tick ~= nil and game.tick < until_tick
end

-- What it creeps towards: an inserter it can turn into a carrier (a roboport if inserters don't come alive), else a power
-- building, its first sample, else the base. Kept until it's reached, gone or given up on.
local function goal_of(state, s, surface, from)
  local goal = s.goal
  if goal then
    if not given_up(s, goal.key) and (not goal.entity or (goal.entity.valid and not infection.is_infected(goal.entity))) then return goal end
    s.goal, s.best_distance, s.stuck = nil, nil, 0
  end
  prune(s.given_up)
  local sense = sense_min + (sense_max - sense_min) * clamp(s.growth)
  local forces = infection.target_forces()
  local function nearest(types)
    local best, best_distance
    for _, entity in pairs(surface.find_entities_filtered{position = from, radius = sense, type = types, force = forces, limit = 60}) do
      if not given_up(s, entity.unit_number) and infection.can_infect(entity, true) then
        local distance = outbreak.distance_squared(entity.position, from)
        if not best or distance < best_distance then best, best_distance = entity, distance end
      end
    end
    return best
  end
  local prey = config.get("inserters-awaken") and {"inserter", "roboport"} or {"roboport"}
  local target = nearest(prey) or nearest(shared.energy_types)
  if target then
    goal = {entity = target, position = target.position, key = target.unit_number}
  elseif not given_up(s, "base") then
    goal = {position = game.forces[target_force].get_spawn_position(surface), key = "base"}
  end
  s.goal, s.best_distance, s.stuck = goal, nil, 0
  return goal
end

local function guarded(surface, position)
  return surface.count_entities_filtered{position = position, radius = turret_sight, type = turret_types, force = target_force, limit = 1} > 0
end

-- One step: whatever the buildings of it nearest its goal are in contact with (infection.contacts), the one nearest the
-- goal, or a carrier it can have at once. true, or why not.
local function crawl(state, s, surface)
  local goal = goal_of(state, s, surface, s.tip or state.landing)
  if not goal then return "no-goal" end
  local body = infection.infected_on(surface.index, crawl_scan)
  if #body == 0 then return "no-body" end
  local at = goal.position
  local distance = {}
  for _, entity in pairs(body) do distance[entity.unit_number] = outbreak.distance_squared(entity.position, at) end
  table.sort(body, function(a, b) return distance[a.unit_number] < distance[b.unit_number] end)
  local wary = not state.effects.fight
  local best, best_value
  local tips = 0
  for index = 1, math.min(tips_scan, #body) do
    local touched = false
    for _, target in pairs(infection.contacts(body[index])) do
      if target.valid and target.unit_number and infection.can_infect(target, true) then
        touched = true
        local tier = 0
        if wary and is_loud[target.type] then tier = tier + 1 end
        if wary and guarded(surface, target.position) then tier = tier + 2 end
        local value = tier * tier_value + (is_prey[target.type] and -1 or outbreak.distance_squared(target.position, at))
        if not best or value < best_value then best, best_value = target, value end
      end
    end
    if touched then tips = tips + 1 end
    if tips >= crawl_tips then break end
  end
  if not (best and infection.infect(best, true)) then
    s.given_up[goal.key] = game.tick + give_up_ticks
    s.goal = nil
    return "stuck"
  end
  s.crawled = s.crawled + 1
  s.tip = best.position
  local now = outbreak.distance_squared(best.position, at)
  if not s.best_distance or now < s.best_distance - 1 then
    s.best_distance, s.stuck = now, 0
  else
    s.stuck = (s.stuck or 0) + 1
    if s.stuck >= stuck_steps then
      s.given_up[goal.key] = game.tick + give_up_ticks
      s.goal = nil
    end
  end
  return true
end

-- What it rises as: power first, which its lair lives on, then what it attacks with, then a drill; the biggest of those,
-- nearest the lair's site. Only what it can take by now and has a creature, and not rolling stock, which needs rails.
local function rank(entity)
  if shared.is_energy_type[entity.type] then return 3 end
  if shared.is_assault_type[entity.type] then return 2 end
  if entity.type == "mining-drill" then return 1 end
  return 0
end

local function body_for(state, surface)
  local liftable = {}
  for _, type in pairs(outbreak.liftable_types()) do liftable[type] = true end
  local best, best_name, best_rank, best_area, best_distance
  for _, entity in pairs(infection.infected_on(surface.index, body_scan)) do
    local info = liftable[entity.type] and shared.source_info(entity.name)
    local group = info and shared.group_by_name(info.group)
    local name = group and not group.train and shared.compound_name(group, info.as)
    if name and prototypes.entity[name] then
      local entity_rank, entity_area = rank(entity), area(entity.name)
      local distance = outbreak.distance_squared(entity.position, state.site)
      if not best or entity_rank > best_rank or (entity_rank == best_rank and (entity_area > best_area or (entity_area == best_area and distance < best_distance))) then
        best, best_name, best_rank, best_area, best_distance = entity, name, entity_rank, entity_area, distance
      end
    end
  end
  return best, best_name
end

-- It stands up by itself: the building becomes the creature it would be lifted as, carrying itself home, on legs of its
-- own (no inserters in them, so none are let go when it dies or set down at the end).
local function raise(s, surface, body, name)
  local info = shared.source_info(body.name)
  local group = shared.group_by_name(info.group)
  local owner = infection.previous_force(body)
  local position, orientation = body.position, body.orientation
  local cargo = {place = info.as, quality = body.quality.name, samples = info.samples, owner = owner and owner.name or target_force, contents = contents.pack(body)}
  surface.create_trivial_smoke{name = "beast-spores", position = position}
  body.destroy{raise_destroy = true}
  local creature = outbreak.spawn_unit and outbreak.spawn_unit(surface, name, position, {}, cargo)
  if not creature then
    contents.spill(surface, position, cargo.contents)
    return false
  end
  if group.vehicle then creature.orientation = orientation end
  s.raised = s.raised + 1
  return true
end

-- What it doesn't need of the outpost, for its mass: what was in it falls out.
local function absorb(state, s, surface, keep)
  local hosts = {}
  for _, leech in pairs(s.leeches) do
    if leech.host.valid then hosts[leech.host.unit_number] = true end
  end
  local body = infection.infected_on(surface.index, body_scan)
  local drills = 0
  for _, entity in pairs(body) do
    if entity.type == "mining-drill" then drills = drills + 1 end
  end
  local best, best_value
  for _, entity in pairs(body) do
    if absorbable[entity.type] and entity ~= keep and not hosts[entity.unit_number] and not (entity.type == "mining-drill" and drills <= 1) then
      local value = outbreak.distance_squared(entity.position, state.landing) + (entity.type == "mining-drill" and tier_value or 0)
      if not best or value < best_value then best, best_value = entity, value end
    end
  end
  if not best then return false end
  local position = best.position
  contents.spill(surface, position, contents.pack(best))
  s.mass = s.mass + area(best.name)
  s.absorbed = s.absorbed + 1
  surface.create_trivial_smoke{name = "beast-spores", position = position}
  best.destroy{raise_destroy = true}
  return true
end

-- Once it has a core: what it gathered as a seed goes to the lair, and from now on its draw fills the lair's store.
local function hand_over(state, s)
  s.handed = true
  outbreak.close_zone(zone_key)
  state.energy = math.min(state.capacity, (state.energy or 0) + s.energy)
  state.mass = (state.mass or 0) + s.mass
  s.energy, s.mass, s.goal = 0, 0, nil
end

local function update(state)
  local s = get(state)
  local surface = game.get_surface(state.surface)
  if not surface then return end
  local ticks = math.max(0, game.tick - (s.last or game.tick))
  s.last = game.tick
  local leech_on = config.get("power-leech")
  if not leech_on and #s.leeches > 0 then clear_leeches(s) end
  local drawn, power = 0, 0
  if #s.leeches > 0 then drawn, power = draw(s, ticks) end
  state.leech_power, s.power = power, power
  if state.phase == "lair" then
    if not s.handed then hand_over(state, s) end
    state.energy = math.min(state.capacity, (state.energy or 0) + drawn)
    if leech_on and game.tick >= s.next_attach then
      s.next_attach = game.tick + attach_ticks
      attach(s, surface)
    end
    return
  end
  s.energy = s.energy + drawn
  local pace = speed(power)
  s.growth = s.growth + ticks / (config.get("seed-minutes") * minute) * pace
  s.fed = feed(s, surface, ticks)
  if leech_on and s.growth >= leech_from and game.tick >= s.next_attach then
    s.next_attach = game.tick + attach_ticks
    attach(s, surface)
  end
  -- While it lands, the landing's own zone is open.
  if state.phase ~= "founding" then return end
  local radius = config.get("outpost-radius") + zone_extra + zone_growth * clamp((s.growth - widen_from) / (1 - widen_from))
  outbreak.keep_zone(zone_key, surface, state.landing, radius, zone_ticks)
  -- A carrier is on its way to the lair's site.
  if #outbreak.creatures(state) > 0 then return end
  if s.growth >= creep_from and game.tick >= s.next_crawl then
    s.next_crawl = game.tick + math.floor(crawl_ticks / pace)
    crawl(state, s, surface)
  end
  if s.growth < hunger_from then return end
  local body, name = body_for(state, surface)
  -- Nothing it could stand up as yet: it keeps creeping.
  if not body then return end
  local need = area(body.name) * mass_per_tile
  if s.growth >= 1 and s.mass >= need then
    if raise(s, surface, body, name) then
      s.mass = s.mass - need
      s.growth = regrow
    end
    return
  end
  if s.mass < need and (s.fed == 0 or s.growth >= 1) and game.tick >= s.next_absorb then
    s.next_absorb = game.tick + math.floor(absorb_ticks / pace)
    absorb(state, s, surface, body)
  end
end

table.insert(outbreak.on_every_update, update)

-- Over: its draws come off the player's network.
table.insert(outbreak.on_end, function(state)
  if state.seed then clear_leeches(state.seed) end
  state.leech_power = 0
end)

-- For tests and admins: "seed" grows it at once and gives it the mass for a body, "crawl" takes one step now, "absorb"
-- eats one building now, "leech" taps the networks it can now. true or a count, or why not.
outbreak.hurry_hooks["seed"] = function(state)
  if state.phase == "lair" then return "has-core" end
  local s = get(state)
  s.growth = math.max(s.growth, 1)
  s.mass = math.max(s.mass, 100)
  return true
end

outbreak.hurry_hooks["crawl"] = function(state)
  if state.phase == "lair" then return "has-core" end
  local surface = game.get_surface(state.surface)
  return surface and crawl(state, get(state), surface) or "no-surface"
end

outbreak.hurry_hooks["absorb"] = function(state)
  if state.phase == "lair" then return "has-core" end
  local surface = game.get_surface(state.surface)
  if not surface then return "no-surface" end
  local s = get(state)
  return absorb(state, s, surface, (body_for(state, surface))) or "nothing"
end

outbreak.hurry_hooks["leech"] = function(state)
  local surface = game.get_surface(state.surface)
  if not (surface and config.get("power-leech")) then return "off" end
  local s = get(state)
  s.next_attach = game.tick + attach_ticks
  return attach(s, surface)
end

table.insert(outbreak.status_hooks, function(state, status)
  local s = state.seed
  if not s then return end
  local watts = {}
  for _, leech in pairs(s.leeches) do watts[#watts + 1] = leech.watts end
  status.seed =
  {
    growth = s.growth, mass = s.mass, energy = s.energy, power = s.power or 0, leeches = #s.leeches, watts = watts,
    flickers = s.flickers, ore = s.ore, fed = s.fed, crawled = s.crawled, absorbed = s.absorbed, raised = s.raised, tip = s.tip,
    goal = s.goal and s.goal.position or nil, goal_key = s.goal and s.goal.key or nil, handed = s.handed or false
  }
  status.leech_power = state.leech_power or 0
end)

-- Draws whose prototype has gone (the mod changed) or whose host has gone come off; the rest stay.
seed.on_configuration_changed = function()
  local state = storage.outbreak
  local s = state and state.seed
  if not s then return end
  for index = #s.leeches, 1, -1 do
    local leech = s.leeches[index]
    if not (leech.entity.valid and leech.host.valid) then remove_leech(s, index) end
  end
end

return seed
