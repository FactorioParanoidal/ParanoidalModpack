-- The outbreak's own railway and its trains, on top of outbreak.lua.
--
-- The track. Once it has a sample of rail (from rails in any zone it opened) and has analysed it, it works out a track from
-- the player's rail nearest its lair to the lair, ending in a straight platform, and then lays it from its own end, one
-- piece at a time for energy, clearing trees, rocks and cliffs. The piece that joins the player's line goes in last, and
-- quietly: when nobody is watching that spot (no radar or character sees its chunk), or after a while regardless. The
-- player isn't told unless a setting says so. The pieces are the player's (force "player"), as it copies exactly what it
-- has learnt, and the player can take them up; it lays again whatever goes missing, and the junction after a delay.
--
-- The depot. A train it has taken that gets home, along the track or by being lifted and carried, is taken into the lair:
-- its carriages are kept there with what's in them (contents.lua), not left standing on the track, where they'd hold the
-- player's line at the junction. Its carriages become samples.
--
-- Train raids. With the track joined and a locomotive in the depot, a raid may go by train (outbreak.start_raid): it grows
-- a train on the platform from the depot (a locomotive at each end if it has two), fuels it for mass, puts the raid party
-- aboard and sends it to one of the player's stops that it can get to and back from, the one with the most it wants
-- around it. There the party gets out and raids as usual; what they lift is carried aboard, and when the raid is over
-- whoever's left gets back on and it goes home, where it's taken in again and they unload. If it loses its way it runs on
-- as any infected train does (train.lua), and if it's destroyed whoever's aboard gets out where it stood.
--
-- The lure. From research stage 7, with a sample of a train stop, it puts a stop at the end of the platform under the name
-- of the player's stop nearest the lair, so that the player's trains bound there may come instead: every train that stops
-- at it is infected and taken into the depot.
--
-- The geometry is the engine's: LuaRailEnd.get_rail_extensions with the rail planner gives every piece that could be
-- laid next, and the one heading best towards the lair is taken. Paths are the engine's train pathfinder's.
-- 2.1: get_rail_extensions, RailLocation, request_train_path, schedule records with a rail, is_chunk_visible and
-- can_place_entity are the same in 2.1.24.
local shared = require("shared")
local config = require("script.config")
local infection = require("script.infection")
local outbreak = require("script.outbreak")
local contents = require("script.contents")

local lair_rails = {}

local force_name = "the-beast"
local target_force = "player"
local minute = 60 * 60
local piece_interval = 4 * 60
local piece_energy = 10e6
local search_radii = {200, 400, 800}
local search_limit = 300
-- Of the player's rails nearest the lair, this many are weighed for where to join: unseen, and clear of signals and stops.
local start_candidates = 24
local seen_penalty = 150
local signal_penalty = 300
local signal_clearance = 12
local signal_types = {"rail-signal", "rail-chain-signal", "train-stop"}
-- It heads straight for its core until it's this close, then along an axis, then a straight platform of this many pieces.
local stop_radius = 72
local max_pieces = 400
local align_pieces = 24
local platform_pieces = 14
-- Pieces worked out per update (a second) while planning.
local plan_batch = 50
local blocked_tries = 3
local start_tries = 4
local retry_ticks = 10 * minute
local clear_radius = 5
local clear_types = {"tree", "simple-entity", "cliff"}
-- Joining: nobody within this of the junction and its chunk unseen, or this long since the rest was done.
local watcher_radius = 80
local quiet_patience = 15 * minute
local rejoin_delay = 10 * minute
local repair_interval = minute
-- A train is home once it's this close to the end of the track, or to the core.
local track_reach = 30
local core_reach = 40
local route_patience = 10 * 60
local station_name = "[virtual-signal=signal-skull]"
local rail_directions = {defines.rail_direction.front, defines.rail_direction.back}
-- Train raids.
local max_locomotives = 2
local max_wagons = 3
local stop_candidates = 60
local stop_shortlist = 8
local stop_clearance = 100
local ride_bonus = 5
local ride_reach = 120
local board_radius = 8
local boarding_ticks = 45 * 60
local lost_patience = 10 * 60
local back_timeout = 15 * minute
local wait_ticks = 30 * minute
local fuel_load = 20
local fuel_low = 5
local preferred_fuels = {"coal", "wood", "solid-fuel"}
local depot_interval = 30 * 60
local depot_radius = 40

local function rails_of(state)
  local rails = state.rails
  if not rails then
    rails = {tries = 0, pieces = 0, rides = 0}
    state.rails = rails
  end
  rails.bad = rails.bad or {}
  rails.own = rails.own or {}
  rails.specs = rails.specs or {}
  rails.entities = rails.entities or {}
  rails.depot = rails.depot or {}
  rails.routed = rails.routed or {}
  rails.no_route = rails.no_route or {}
  -- A track from before 2026-11-03's train raids has no plan to keep up: it starts over.
  if (rails.phase == "building" or rails.phase == "joining" or rails.phase == "done") and #rails.specs == 0 then rails.phase = nil end
  if rails.phase == "planning" and not rails.planning then rails.phase = nil end
  return rails
end

local function opposite(direction)
  return direction == defines.rail_direction.front and defines.rail_direction.back or defines.rail_direction.front
end

-- The item that places straight rails: the rail planner whose extensions are asked for. Once per session.
local planner
local function planner_item()
  if planner == nil then
    local prototype = prototypes.entity["straight-rail"]
    local items = prototype and prototype.items_to_place_this
    planner = items and items[1] and items[1].name or false
  end
  return planner
end

local function vector_of(direction)
  local angle = direction / 16 * 2 * math.pi
  return math.sin(angle), -math.cos(angle)
end

-- How far a direction (16 ways) is from the nearest of north, east, south and west, in sixteenths.
local function off_axis(direction)
  local rest = direction % 4
  return math.min(rest, 4 - rest)
end

local function same_position(a, b)
  return math.abs(a.x - b.x) < 0.01 and math.abs(a.y - b.y) < 0.01
end

local function extensions(rail_end)
  local item = planner_item()
  if not item then return {} end
  local ok, list = pcall(rail_end.get_rail_extensions, item)
  return ok and list or {}
end

local function find_piece(surface, spec)
  for _, rail in pairs(surface.find_entities_filtered{position = spec.position, radius = 0.5, name = spec.name}) do
    if rail.direction == spec.direction then return rail end
  end
  return nil
end

-- Lower is better: heading straight at the target. align: going along an axis matters more, for the platform.
local function score(extension, from, target, align)
  local goal = extension.goal
  local hx, hy = vector_of(goal.direction)
  local mx, my = goal.position.x - from.x, goal.position.y - from.y
  if hx * mx + hy * my < 0 then hx, hy = -hx, -hy end
  local tx, ty = target.x - goal.position.x, target.y - goal.position.y
  local length = math.sqrt(tx * tx + ty * ty)
  local value = length < 1 and 0 or 1 - (hx * tx + hy * ty) / length
  if align then value = value + 10 * off_axis(goal.direction) end
  -- A little in favour of straight on, so it doesn't weave.
  if extension.name == "straight-rail" then value = value - 0.02 end
  return value
end

local function placeable(surface, spec)
  return surface.can_place_entity{name = spec.name, position = spec.position, direction = spec.direction, force = target_force, build_check_type = defines.build_check_type.script}
end

-- Trees, rocks and cliffs in its way go; anything else stops it there.
local function clear(surface, spec)
  for _, entity in pairs(surface.find_entities_filtered{position = spec.position, radius = clear_radius, type = clear_types}) do
    if entity.valid then
      if entity.type == "cliff" then
        entity.destroy{do_cliff_correction = true}
      elseif entity.force.name == "neutral" and entity.destructible then
        entity.destroy()
      end
    end
  end
end

local function place(surface, spec)
  if not placeable(surface, spec) then
    clear(surface, spec)
    if not placeable(surface, spec) then return nil end
  end
  return surface.create_entity{name = spec.name, position = spec.position, direction = spec.direction, force = target_force, create_build_effect_smoke = false}
end

local function end_at(rail, position)
  for _, direction in pairs(rail_directions) do
    if same_position(rail.get_rail_end(direction).location.position, position) then return direction end
  end
  return nil
end

-- The best of these that can be laid, trying a few: the new rail and its far end.
local function try_best(surface, list, from, target, align, wanted)
  local choices = {}
  for _, extension in pairs(list) do
    if (not wanted or wanted(extension)) and not find_piece(surface, extension) then
      choices[#choices + 1] = {extension = extension, score = score(extension, from[extension] or from, target, align)}
    end
  end
  table.sort(choices, function(a, b) return a.score < b.score end)
  for i = 1, math.min(3, #choices) do
    local extension = choices[i].extension
    local rail = place(surface, extension)
    if rail then
      local direction = end_at(rail, extension.goal.position)
      if direction then return rail, direction end
      rail.destroy()
    end
  end
  return nil
end

-- Unseen: its chunk isn't watched by the player's radars or characters, and no player is near it.
local function unseen(surface, position)
  local force = game.forces[target_force]
  if not force then return true end
  if force.is_chunk_visible(surface, {x = math.floor(position.x / 32), y = math.floor(position.y / 32)}) then return false end
  for _, player in pairs(force.connected_players) do
    if player.surface.index == surface.index and outbreak.distance_squared(player.position, position) <= watcher_radius * watcher_radius then return false end
  end
  return true
end

-- The player's straight rail to join: near the lair, unseen, and clear of signals and stops, so that the branch doesn't
-- land in the middle of a junction or a station. Never its own.
local function pick_start(rails, surface, core)
  for _, radius in pairs(search_radii) do
    local candidates = {}
    for _, rail in pairs(surface.find_entities_filtered{position = core, radius = radius, type = "straight-rail", force = target_force, limit = search_limit}) do
      if not (rails.bad[rail.unit_number] or rails.own[rail.unit_number]) then
        candidates[#candidates + 1] = {rail = rail, value = math.sqrt(outbreak.distance_squared(rail.position, core))}
      end
    end
    if #candidates > 0 then
      table.sort(candidates, function(a, b) return a.value < b.value end)
      local best
      for i = 1, math.min(start_candidates, #candidates) do
        local candidate = candidates[i]
        local rail = candidate.rail
        local value = candidate.value
        if not unseen(surface, rail.position) then value = value + seen_penalty end
        if surface.count_entities_filtered{position = rail.position, radius = signal_clearance, type = signal_types, limit = 1} > 0 then value = value + signal_penalty end
        if not best or value < best.value then best = {rail = rail, value = value} end
      end
      return best.rail
    end
  end
  return nil
end

-- The track is worked out by laying it, a batch of pieces a second so that a long one costs no single tick much, and
-- taking it all up again once it gets to the lair: the junction, the way there and the platform. The junction goes again
-- at once, so the player's line is joined for no time at all while the rest is worked out. Then it's laid for real from
-- the far end, the junction last.
local function give_up(rails, start, placed)
  for _, rail in pairs(placed) do
    if rail.valid then rail.destroy() end
  end
  if start and start.valid then rails.bad[start.unit_number] = true end
  rails.planning, rails.phase = nil, nil
  rails.next_tick = game.tick + (rails.tries < start_tries and 60 or retry_ticks)
end

local function plan(state, rails)
  local surface = game.get_surface(state.surface)
  local core = state.core.position
  local start = pick_start(rails, surface, core)
  if not start then
    rails.next_tick = game.tick + retry_ticks
    return
  end
  rails.tries = rails.tries + 1
  -- A branch off either end of it, each scored from where it would start.
  local list, from = {}, {}
  for _, direction in pairs(rail_directions) do
    local rail_end = start.get_rail_end(direction)
    for _, extension in pairs(extensions(rail_end)) do
      list[#list + 1] = extension
      from[extension] = rail_end.location.position
    end
  end
  local junction, direction = try_best(surface, list, from, core, false)
  if not junction then return give_up(rails, start, {}) end
  local spec = {name = junction.name, position = junction.position, direction = junction.direction}
  local rail_end = junction.get_rail_end(direction)
  local second, second_direction = try_best(surface, extensions(rail_end), rail_end.location.position, core, false)
  junction.destroy()
  if not second then return give_up(rails, start, {}) end
  rails.planning = {start = start, specs = {spec}, placed = {second}, tip = {rail = second, direction = second_direction}}
  rails.phase = "planning"
end

-- At the lair: the platform straight on along the same axis, as far as it goes; the plan is kept and the pieces go.
local function finish_plan(state, rails)
  local planning = rails.planning
  local surface = game.get_surface(state.surface)
  local core = state.core.position
  local placed, tip = planning.placed, planning.tip
  local heading = tip.rail.get_rail_end(tip.direction).location.direction
  local function straight_on(extension) return extension.name == "straight-rail" and extension.goal.direction == heading end
  for _ = 1, platform_pieces do
    local rail_end = tip.rail.get_rail_end(tip.direction)
    local rail, direction = try_best(surface, extensions(rail_end), rail_end.location.position, core, false, straight_on)
    if not rail then break end
    placed[#placed + 1] = rail
    tip = {rail = rail, direction = direction}
  end
  -- The straight run at the end, which is where it keeps its trains.
  local length = 0
  for i = #placed, 1, -1 do
    local piece = placed[i]
    if piece.name == "straight-rail" and piece.direction % 8 == heading % 8 then length = length + 2 else break end
  end
  local specs = planning.specs
  for _, piece in ipairs(placed) do specs[#specs + 1] = {name = piece.name, position = piece.position, direction = piece.direction} end
  for _, piece in pairs(placed) do
    if piece.valid then piece.destroy() end
  end
  rails.specs, rails.entities = specs, {}
  rails.start, rails.heading, rails.end_direction, rails.platform = planning.start, heading, tip.direction, length
  rails.planning = nil
  rails.next_index, rails.blocked = #specs, 0
  rails.phase = "building"
  rails.next_tick = game.tick + piece_interval
end

local function plan_more(state, rails)
  local planning = rails.planning
  if not planning then
    rails.phase = nil
    return
  end
  local surface = game.get_surface(state.surface)
  local core = state.core.position
  local placed = planning.placed
  if not (planning.tip.rail.valid and planning.start.valid) then return give_up(rails, planning.start, placed) end
  for _ = 1, plan_batch do
    local tip = planning.tip
    local rail_end = tip.rail.get_rail_end(tip.direction)
    local location = rail_end.location
    local count = #placed + 1
    local near = outbreak.distance_squared(location.position, core) <= stop_radius * stop_radius
    local long = count >= max_pieces
    if (near or long) and off_axis(location.direction) == 0 and tip.rail.name == "straight-rail" then return finish_plan(state, rails) end
    if count >= max_pieces + align_pieces then return give_up(rails, planning.start, placed) end
    local rail, direction = try_best(surface, extensions(rail_end), location.position, core, near or long)
    if not rail then return give_up(rails, planning.start, placed) end
    placed[#placed + 1] = rail
    planning.tip = {rail = rail, direction = direction}
  end
end

-- Its pieces laid so far go again, and it starts over from another of the player's rails.
local function replan(rails)
  for _, piece in pairs(rails.entities) do
    if piece.valid then piece.destroy() end
  end
  if rails.station and rails.station.valid then rails.station.destroy() end
  if rails.start and rails.start.valid then rails.bad[rails.start.unit_number] = true end
  rails.entities, rails.specs, rails.last, rails.junction, rails.station, rails.lured = {}, {}, nil, nil, nil, nil
  rails.phase = nil
  rails.next_tick = game.tick + 60
end

local function lay_spec(rails, surface, index)
  local spec = rails.specs[index]
  local rail = find_piece(surface, spec) or place(surface, spec)
  if not rail then return nil end
  rails.entities[index] = rail
  rails.own[rail.unit_number] = true
  surface.create_trivial_smoke{name = "beast-spores", position = spec.position}
  return rail
end

local function tell_junction(rail)
  local force = game.forces[target_force]
  if not force then return end
  force.print({"the-beast.rails-junction"}, {color = {r = 1, g = 0.2, b = 0.3}})
  for _, player in pairs(force.players) do
    player.add_custom_alert(rail, {type = "virtual", name = "signal-skull"}, {"the-beast.rails-junction"}, true)
  end
end

-- One piece, from its own end back towards the player's line. free: for admins and tests.
local function build_step(state, rails, free)
  local index = rails.next_index
  if index <= 1 then
    rails.phase, rails.joining_since = "joining", game.tick
    return
  end
  if not free and not outbreak.spend_energy(piece_energy) then return end
  local surface = game.get_surface(state.surface)
  local rail = lay_spec(rails, surface, index)
  if not rail then
    rails.blocked = rails.blocked + 1
    if rails.blocked >= blocked_tries then replan(rails) end
    return
  end
  rails.blocked = 0
  rails.pieces = rails.pieces + 1
  if index == #rails.specs then rails.last = rail end
  rails.next_index = index - 1
  if rails.next_index <= 1 then rails.phase, rails.joining_since = "joining", game.tick end
end

local function join(state, rails, free)
  local surface = game.get_surface(state.surface)
  if not free and game.tick < rails.joining_since + quiet_patience and not unseen(surface, rails.specs[1].position) then return end
  if not free and not outbreak.spend_energy(piece_energy) then return end
  local rail = lay_spec(rails, surface, 1)
  if not rail then
    rails.blocked = rails.blocked + 1
    if rails.blocked >= blocked_tries then replan(rails) end
    return
  end
  rails.blocked = 0
  rails.junction = rail
  rails.phase, rails.joined = "done", game.tick
  if config.get("junction-warning") then tell_junction(rail) end
end

-- Whatever of it the player has taken up is laid again, one piece a time; the junction quietly, after a while.
local function repair(state, rails)
  local surface = game.get_surface(state.surface)
  -- The player's rail it branched off is gone: it all goes, and it starts over somewhere else.
  if not (rails.start and rails.start.valid) then return replan(rails) end
  if not (rails.junction and rails.junction.valid) then
    rails.junction = nil
    rails.phase, rails.joining_since = "joining", game.tick + rejoin_delay
    rails.next_tick = game.tick + rejoin_delay
    return
  end
  for index = #rails.specs, 2, -1 do
    local piece = rails.entities[index]
    if not (piece and piece.valid) then
      if outbreak.state().energy < piece_energy then return end
      local rail = lay_spec(rails, surface, index)
      if rail then
        outbreak.spend_energy(piece_energy)
        if index == #rails.specs then rails.last = rail end
      end
      return
    end
  end
end

-- The player's stop nearest the lair, other than its own, whose name it takes.
local function nearest_stop(state, rails)
  local surface = game.get_surface(state.surface)
  local core = state.core.position
  local best, best_distance
  for _, stop in pairs(game.train_manager.get_train_stops{force = target_force, surface = surface}) do
    if stop ~= rails.station then
      local distance = outbreak.distance_squared(stop.position, core)
      if not best or distance < best_distance then best, best_distance = stop, distance end
    end
  end
  return best
end

-- A stop beside the end of the platform, facing the way trains come in, bound to one of its last pieces.
local function place_station(rails, surface, name)
  local last = rails.last
  local hx, hy = vector_of(rails.heading)
  local rx, ry = -hy, hx
  local position = last.position
  local stop_name = prototypes.entity[outbreak.stop_sample] and outbreak.stop_sample
  if not stop_name then return nil end
  local platform = {}
  for index = math.max(2, #rails.specs - 6), #rails.specs do
    local piece = rails.entities[index]
    if piece and piece.valid then platform[piece.unit_number] = true end
  end
  for _, along in pairs{0, -2, -4} do
    for _, side in pairs{1, -1} do
      for _, direction in pairs{rails.heading, (rails.heading + 8) % 16} do
        local at = {x = position.x + side * 2 * rx + along * hx, y = position.y + side * 2 * ry + along * hy}
        if surface.can_place_entity{name = stop_name, position = at, direction = direction, force = target_force, build_check_type = defines.build_check_type.script} then
          local stop = surface.create_entity{name = stop_name, position = at, direction = direction, force = target_force, create_build_effect_smoke = false}
          local rail = stop and stop.connected_rail
          if rail and platform[rail.unit_number] and stop.connected_rail_direction == rails.end_direction then
            stop.backer_name = name
            return stop
          end
          if stop then stop.destroy() end
        end
      end
    end
  end
  return nil
end

local function lure(state, rails)
  if not (rails.last and rails.last.valid and outbreak.analysed(outbreak.stop_sample)) then return end
  local best = nearest_stop(state, rails)
  if not best then return end
  if not (rails.station and rails.station.valid) then
    rails.station = place_station(rails, game.get_surface(state.surface), best.backer_name)
    if not rails.station then return end
  end
  rails.station.backer_name = best.backer_name
  rails.lured = best.backer_name
end

-- The lair's trains -----------------------------------------------------------------------------------------------------

local function locomotives_in_depot(rails)
  local count = 0
  for _, pack in pairs(rails.depot) do
    local prototype = prototypes.entity[pack.name]
    if prototype and prototype.type == "locomotive" then count = count + 1 end
  end
  return count
end

-- Taken in: each carriage is kept with what's in it, and given as a sample.
local function absorb(rails, the_train)
  local carriages = the_train.carriages
  for _, carriage in pairs(carriages) do
    if carriage.valid then
      outbreak.add_samples{place = carriage.name, quality = carriage.quality.name}
      local owner = infection.previous_force(carriage)
      rails.depot[#rails.depot + 1] =
      {
        name = carriage.name, quality = carriage.quality.name, owner = owner and owner.name or target_force, color = carriage.color,
        health = carriage.get_health_ratio(), contents = contents.pack(carriage)
      }
      carriage.surface.create_trivial_smoke{name = "beast-spores", position = carriage.position}
    end
  end
  for _, carriage in pairs(carriages) do
    if carriage.valid then carriage.destroy{raise_destroy = true} end
  end
  rails.taken = (rails.taken or 0) + 1
end

-- How much track a carriage takes, joint to coupling: 7 tiles for the base game's.
local function length_of(name)
  local prototype = prototypes.entity[name]
  return (prototype and prototype.joint_distance or 4) + (prototype and prototype.connection_distance or 3)
end

-- Along the platform from its end: the centre of the next carriage after one centred at along of length previous, or nil
-- if it doesn't fit.
local function next_spot(rails, along, previous, name)
  local length = length_of(name)
  local at = previous and along + (previous + length) / 2 or length / 2
  if at + length / 2 > (rails.platform or 0) then return nil end
  local position = rails.last.get_rail_end(rails.end_direction).location.position
  local hx, hy = vector_of(rails.heading)
  return {x = position.x - hx * at, y = position.y - hy * at}, at, length
end

-- Centres for these carriages one after another from the end of the platform, or nil if they don't all fit.
local function platform_spots(rails, names)
  local spots, along, previous = {}, 0, nil
  for k, name in ipairs(names) do
    local spot
    spot, along, previous = next_spot(rails, along, previous, name)
    if not spot then return nil end
    spots[k] = spot
  end
  return spots
end

-- A train grown on the platform from the depot, the lair's own and infected: a locomotive at the front facing out, and
-- one at the back if there's a second. Nil if there's no room or no locomotive.
local function regrow(rails, surface)
  if not (rails.last and rails.last.valid) then return nil end
  local locomotives, wagons = {}, {}
  for index, pack in ipairs(rails.depot) do
    local prototype = prototypes.entity[pack.name]
    if prototype and prototype.type == "locomotive" then
      if #locomotives < max_locomotives then locomotives[#locomotives + 1] = index end
    elseif prototype and #wagons < max_wagons then
      wagons[#wagons + 1] = index
    end
  end
  if #locomotives == 0 then return nil end
  -- As many as fit on the platform, wagons left behind first.
  local order, spots
  while true do
    order = {}
    if #locomotives == 2 then order[1] = {index = locomotives[2], back = true} end
    for _, index in ipairs(wagons) do order[#order + 1] = {index = index} end
    order[#order + 1] = {index = locomotives[1]}
    local names = {}
    for k, item in ipairs(order) do names[k] = rails.depot[item.index].name end
    spots = platform_spots(rails, names)
    if spots then break end
    if #wagons > 0 then
      table.remove(wagons)
    elseif #locomotives > 1 then
      table.remove(locomotives)
    else
      return nil
    end
  end
  local outward = (rails.heading + 8) % 16
  local made = {}
  local function undo()
    for _, entry in pairs(made) do
      if entry.entity.valid then entry.entity.destroy() end
    end
  end
  for k, item in ipairs(order) do
    local pack = rails.depot[item.index]
    local carriage = surface.create_entity
    {
      name = pack.name, position = spots[k], direction = item.back and rails.heading or outward, force = target_force,
      quality = prototypes.quality[pack.quality or ""] and pack.quality or nil, snap_to_train_stop = false, create_build_effect_smoke = false
    }
    if not carriage then
      undo()
      return nil
    end
    made[#made + 1] = {entity = carriage, pack = pack, index = item.index}
  end
  for _, entry in pairs(made) do
    entry.entity.connect_rolling_stock(defines.rail_direction.front)
    entry.entity.connect_rolling_stock(defines.rail_direction.back)
  end
  local the_train = made[1].entity.train
  if not (the_train and #the_train.carriages == #made) then
    undo()
    return nil
  end
  local used = {}
  for _, entry in pairs(made) do used[entry.index] = true end
  local depot = {}
  for index, pack in ipairs(rails.depot) do
    if not used[index] then depot[#depot + 1] = pack end
  end
  rails.depot = depot
  local carriages = {}
  for _, entry in pairs(made) do
    local carriage, pack = entry.entity, entry.pack
    contents.restore(carriage, pack.contents)
    if pack.color then carriage.color = pack.color end
    if pack.health then carriage.health = carriage.max_health * math.max(0.1, pack.health) end
    carriages[#carriages + 1] = carriage
  end
  for _, carriage in pairs(carriages) do
    if not infection.infect(carriage, true) then
      absorb(rails, carriage.train)
      return nil
    end
  end
  return the_train, carriages
end

-- Fuel for a locomotive: coal or wood if it burns them, otherwise the first fuel it takes. Once per name for the session.
local fuel_for = {}
local function fuel_of(entity)
  local name = entity.name
  if fuel_for[name] ~= nil then return fuel_for[name] end
  local burner = entity.prototype.burner_prototype
  local found = {}
  local first
  for category in pairs(burner and burner.fuel_categories or {}) do
    for item_name, item in pairs(prototypes.get_item_filtered{{filter = "fuel-category", ["fuel-category"] = category}}) do
      if not item.hidden and item.fuel_value > 0 then
        found[item_name] = true
        if not first or item.order < first.order then first = item end
      end
    end
  end
  local best = first and first.name or false
  for _, preferred in ipairs(preferred_fuels) do
    if found[preferred] then
      best = preferred
      break
    end
  end
  fuel_for[name] = best
  return best
end

-- free: as it's grown, so it can always set off.
local function refuel(carriages, free)
  for _, carriage in pairs(carriages) do
    if carriage.valid and carriage.type == "locomotive" then
      local fuel = fuel_of(carriage)
      local inventory = fuel and carriage.get_fuel_inventory()
      if inventory and inventory.get_item_count() < fuel_low and (free or outbreak.spend_mass(1)) then inventory.insert{name = fuel, count = fuel_load} end
    end
  end
end

local function raider_train(raider)
  for _, carriage in pairs(raider.carriages) do
    if carriage.valid then return carriage.train, carriage end
  end
  return nil
end

-- Beside a carriage, on either side, for whoever gets out.
local function beside(carriage, i)
  local angle = carriage.orientation * 2 * math.pi
  local side = (i % 2 == 0 and 1 or -1) * (3 + math.floor(i / 2) % 3)
  local along = (math.floor(i / 6) % 3 - 1) * 2
  local position = carriage.position
  return {x = position.x + math.cos(angle) * side + math.sin(angle) * along, y = position.y + math.sin(angle) * side - math.cos(angle) * along}
end

-- Whoever's aboard gets out beside the carriage nearest the place, or where it last stood if it's gone. raid: they join it.
local function unload(raider, surface, near, raid)
  local carriage
  if near then
    for _, candidate in pairs(raider.carriages) do
      if candidate.valid and (not carriage or outbreak.distance_squared(candidate.position, near) < outbreak.distance_squared(carriage.position, near)) then carriage = candidate end
    end
  end
  carriage = carriage or select(2, raider_train(raider))
  for i, passenger in ipairs(raider.passengers) do
    local position = carriage and beside(carriage, i) or raider.position
    local record = outbreak.disembark and outbreak.disembark(surface, passenger, position)
    if record and raid then
      record.raid, record.rode = raid.id, raid.id
      raid.members[#raid.members + 1] = record.unit_number
    end
  end
  raider.passengers = {}
end

local function boardable(record)
  if record.attack == "robot" or record.gathering or not record.entity.valid then return false end
  local info = shared.creature_info(record.entity.name)
  local group = info and shared.group_by_name(info.group)
  return not (group and (group.train or group.vehicle))
end

-- Where a creature should go to get aboard, if it should: anything lifted at a raid by train, and once the raid is over,
-- whoever came by it.
local function ride(record, entity)
  local state = outbreak.state()
  local raider = state and state.rails and state.rails.raider
  if not (raider and raider.position and (raider.phase == "waiting" or raider.phase == "boarding")) then return nil end
  if not (record.cargo or (raider.phase == "boarding" and record.rode == raider.raid)) then return nil end
  if not boardable(record) or entity.surface.index ~= state.surface then return nil end
  local to_train = outbreak.distance_squared(entity.position, raider.position)
  if to_train > ride_reach * ride_reach then return nil end
  -- Nearer home than the train: it walks.
  local home = outbreak.home()
  if home and outbreak.distance_squared(entity.position, home) < to_train then return nil end
  return raider.position
end
outbreak.ride = ride
outbreak.can_board = boardable

local function board_nearby(raider)
  local units = storage.units
  if not units then return end
  for _, carriage in pairs(raider.carriages) do
    if carriage.valid then
      for _, unit in pairs(carriage.surface.find_entities_filtered{position = carriage.position, radius = board_radius, type = "spider-unit", force = force_name}) do
        local record = units.by_unit_number[unit.unit_number]
        if record and ride(record, unit) and outbreak.board then raider.passengers[#raider.passengers + 1] = outbreak.board(record) end
      end
    end
  end
end

local function send_home(rails, raider, the_train)
  raider.phase, raider.since, raider.lost_since = "back", game.tick, nil
  -- Its end of the track is gone: it'll find its own way, or not (update_raider lets it loose).
  if not (rails.last and rails.last.valid) then
    the_train.manual_mode = true
    return
  end
  the_train.schedule = {current = 1, records = {{rail = rails.last, rail_direction = rails.end_direction, temporary = true, wait_conditions = {{type = "time", ticks = wait_ticks}}}}}
  the_train.manual_mode = false
end

-- It lost its way: whoever's aboard gets out here, and it's an infected train like any other (train.lua).
local function let_loose(state, rails, raider, the_train, carriage)
  local raid = state.raid
  unload(raider, carriage.surface, nil, raider.phase == "out" and raid and raid.id == raider.raid and raid or nil)
  if raider.phase == "out" and raid and raid.id == raider.raid and raid.ride then raid.ride.landed = game.tick end
  the_train.manual_mode = true
  rails.no_route[the_train.id] = true
  rails.raider = nil
  rails.lost = (rails.lost or 0) + 1
end

local function is_lost(raider, the_train)
  local train_state = the_train.state
  if train_state == defines.train_state.no_path or train_state == defines.train_state.no_schedule then
    raider.lost_since = raider.lost_since or game.tick
    return game.tick - raider.lost_since > lost_patience
  end
  raider.lost_since = nil
  return raider.phase == "back" and game.tick - raider.since > back_timeout
end

local function near_any(raider, position, reach)
  for _, carriage in pairs(raider.carriages) do
    if carriage.valid and outbreak.distance_squared(carriage.position, position) <= reach * reach then return true end
  end
  return false
end

local function tell_arrival(the_train, stop_name)
  local force = game.forces[target_force]
  if not (force and the_train.front_stock) then return end
  for _, player in pairs(force.players) do
    player.add_custom_alert(the_train.front_stock, {type = "virtual", name = "signal-skull"}, {"the-beast.ride-arrived", stop_name}, true)
  end
end

local function update_raider(state, rails)
  local raider = rails.raider
  local the_train, carriage = raider_train(raider)
  local surface = game.get_surface(state.surface)
  if not the_train then
    -- Destroyed: whoever was aboard gets out where it stood.
    local raid = state.raid
    local joining = raider.phase == "out" and raid and raid.id == raider.raid and raid or nil
    unload(raider, surface, nil, joining)
    if joining and joining.ride then joining.ride.landed = game.tick end
    rails.raider = nil
    return
  end
  local middle = raider.carriages[math.ceil(#raider.carriages / 2)]
  raider.position = (middle and middle.valid and middle or carriage).position
  refuel(raider.carriages)
  local raid = state.raid
  local ours = raid and raid.id == raider.raid and raid or nil
  if raider.phase == "out" then
    if not ours then return send_home(rails, raider, the_train) end
    local stop = raider.stop
    local arrived = the_train.state == defines.train_state.wait_station
      or (the_train.speed == 0 and stop.valid and near_any(raider, stop.position, 14))
    if arrived then
      the_train.manual_mode = true
      the_train.speed = 0
      raider.phase = "waiting"
      unload(raider, carriage.surface, stop.valid and stop.position or nil, ours)
      if ours.ride then ours.ride.landed = game.tick end
      tell_arrival(the_train, raider.stop_name)
    elseif is_lost(raider, the_train) then
      let_loose(state, rails, raider, the_train, carriage)
    end
  elseif raider.phase == "waiting" or raider.phase == "boarding" then
    the_train.manual_mode = true
    the_train.speed = 0
    board_nearby(raider)
    if raider.phase == "boarding" and game.tick >= raider.leave_at then send_home(rails, raider, the_train) end
  elseif raider.phase == "back" then
    local home = outbreak.home()
    local last = rails.last and rails.last.valid and rails.last
    if (last and near_any(raider, last.position, track_reach)) or near_any(raider, home, core_reach) then
      the_train.manual_mode = true
      the_train.speed = 0
      unload(raider, carriage.surface, home, nil)
      absorb(rails, the_train)
      rails.raider = nil
    elseif is_lost(raider, the_train) then
      let_loose(state, rails, raider, the_train, carriage)
    end
  end
end

-- A raid by train, for outbreak.start_raid: one of the player's stops it can get to and back from, with the best target
-- around it. Nil and why not otherwise.
local function plan_ride(state)
  if not (config.get("rail-raids") and config.get("infect-trains")) then return nil, "off" end
  local rails = state.rails
  if not (rails and rails.phase == "done" and rails.last and rails.last.valid and rails.junction and rails.junction.valid) then return nil, "no-track" end
  if rails.raider then return nil, "busy" end
  local locomotives = locomotives_in_depot(rails)
  if locomotives == 0 then return nil, "no-train" end
  local surface = game.get_surface(state.surface)
  local pool = {}
  for _, stop in pairs(game.train_manager.get_train_stops{force = target_force, surface = surface}) do
    if stop ~= rails.station and stop.connected_rail and outbreak.distance_squared(stop.position, rails.last.position) > stop_clearance * stop_clearance then
      pool[#pool + 1] = stop
    end
  end
  -- A random handful of them, however many the player has.
  for i = 1, math.min(stop_candidates, #pool) do
    local j = math.random(i, #pool)
    pool[i], pool[j] = pool[j], pool[i]
  end
  local types = outbreak.liftable_types()
  local radius = config.get("raid-radius")
  local scored = {}
  for i = 1, math.min(stop_candidates, #pool) do
    local stop = pool[i]
    local best, best_value
    for _, entity in pairs(surface.find_entities_filtered{position = stop.position, radius = radius, type = types, force = target_force, limit = 30}) do
      local value = outbreak.score(state, surface, entity, {target_force})
      if value and (not best or value > best_value) then best, best_value = entity, value end
    end
    if best then scored[#scored + 1] = {stop = stop, target = best, score = best_value} end
  end
  if #scored == 0 then return nil, "no-target" end
  table.sort(scored, function(a, b) return a.score > b.score end)
  while #scored > stop_shortlist do table.remove(scored) end
  local goals = {}
  for i, candidate in ipairs(scored) do goals[i] = {train_stop = candidate.stop} end
  local manager = game.train_manager
  local out = manager.request_train_path{starts = {{rail = rails.last, direction = opposite(rails.end_direction), is_front = true}}, goals = goals, type = "all-goals-accessible"}
  for i, candidate in ipairs(scored) do
    if out.accessible[i] then
      local stop = candidate.stop
      local starts = {{rail = stop.connected_rail, direction = stop.connected_rail_direction, is_front = true}}
      if locomotives >= 2 then starts[2] = {rail = stop.connected_rail, direction = opposite(stop.connected_rail_direction), is_front = true} end
      local back = manager.request_train_path{starts = starts, goals = {{rail = rails.last, direction = rails.end_direction}}, type = "any-goal-accessible"}
      if back.found_path then return {target = candidate.target, score = candidate.score + ride_bonus, stop = stop} end
    end
  end
  return nil, "no-path"
end
outbreak.plan_ride = plan_ride

-- The party gets aboard a train grown from the depot, and off it goes. False if it couldn't be grown.
outbreak.board_ride = function(state, raid, party, plan)
  local rails = state.rails
  local stop = plan.stop
  if not (stop.valid and stop.connected_rail and outbreak.board) then return false end
  local the_train, carriages = regrow(rails, game.get_surface(state.surface))
  if not the_train then return false end
  refuel(carriages, true)
  local raider = {raid = raid.id, carriages = carriages, units = {}, passengers = {}, phase = "out", stop = stop, stop_name = stop.backer_name, since = game.tick}
  for _, carriage in pairs(carriages) do raider.units[carriage.unit_number] = true end
  for _, record in pairs(party) do raider.passengers[#raider.passengers + 1] = outbreak.board(record) end
  raider.position = carriages[1].position
  raid.members = {}
  raid.ride = {stop = stop.backer_name}
  the_train.schedule = {current = 1, records = {{rail = stop.connected_rail, rail_direction = stop.connected_rail_direction, temporary = true, wait_conditions = {{type = "time", ticks = wait_ticks}}}}}
  the_train.manual_mode = false
  rails.raider = raider
  rails.rides = rails.rides + 1
  return true
end

table.insert(outbreak.on_raid_end, function(state, raid)
  local rails = state.rails
  local raider = rails and rails.raider
  if not (raider and raider.raid == raid.id) then return end
  if raider.phase == "waiting" then
    raider.phase, raider.leave_at = "boarding", game.tick + boarding_ticks
  elseif raider.phase == "out" then
    local the_train = raider_train(raider)
    if the_train then send_home(rails, raider, the_train) end
  end
end)

-- A lifted carriage carried home goes into the depot once there's a platform to grow trains on; until then it stays a
-- creature. True if it was taken.
outbreak.store_carriage = function(cargo)
  local state = outbreak.state()
  local rails = state and state.rails
  if not (rails and (rails.phase == "joining" or rails.phase == "done") and prototypes.entity[cargo.place]) then return false end
  rails.depot[#rails.depot + 1] = {name = cargo.place, quality = cargo.quality, owner = cargo.owner or target_force, contents = cargo.contents}
  return true
end

-- Carriage creatures left from before there was a platform, idle at home: into the depot with them.
local function take_in_creatures(state)
  local units = storage.units
  local home = outbreak.home()
  if not (units and home and outbreak.take_apart) then return end
  -- Found first and taken apart after, as taking one apart lets its inserters go, which adds to the list.
  local found = {}
  for _, record in pairs(units.list) do
    local entity = record.entity
    if entity.valid and units.by_unit_number[record.unit_number] == record and not record.raid and not record.gathering
      and entity.surface.index == state.surface and outbreak.distance_squared(entity.position, home) <= depot_radius * depot_radius then
      local info = shared.creature_info(entity.name)
      local group = info and shared.group_by_name(info.group)
      if group and group.train then found[#found + 1] = {record = record, source = info.source} end
    end
  end
  for _, entry in pairs(found) do
    local cargo = outbreak.take_apart(entry.record) or {place = entry.source, owner = target_force}
    if not outbreak.store_carriage(cargo) then contents.discard(cargo.contents) end
  end
end

local function update(state)
  if state.phase ~= "lair" or not (state.core and state.core.valid) then return end
  local rails = rails_of(state)
  if rails.raider then update_raider(state, rails) end
  if not config.get("lair-rails") then return end
  if rails.phase == "done" or rails.phase == "joining" then
    if state.effects.lure and config.get("lure-station") and not rails.lured then lure(state, rails) end
    if game.tick >= (rails.next_depot or 0) then
      rails.next_depot = game.tick + depot_interval
      take_in_creatures(state)
    end
  end
  if rails.phase == "failed" or game.tick < (rails.next_tick or 0) then return end
  if rails.phase == "done" then
    rails.next_tick = game.tick + repair_interval
    return repair(state, rails)
  end
  if not outbreak.analysed(outbreak.rail_sample) then return end
  rails.next_tick = game.tick + piece_interval
  if rails.phase == "building" then
    build_step(state, rails)
  elseif rails.phase == "joining" then
    join(state, rails)
  elseif rails.phase == "planning" then
    rails.next_tick = game.tick
    plan_more(state, rails)
  else
    plan(state, rails)
  end
end

table.insert(outbreak.on_update, update)

-- Whether a train it has infected is taken care of here: taken in if it's home, sent home if there's a way. False leaves
-- it to train.lua as before.
function lair_rails.route_home(entry, the_train)
  if not outbreak.has_core() then return false end
  local state = outbreak.state()
  local rails = rails_of(state)
  local home = outbreak.home()
  local front = the_train.front_stock
  local last = rails.last and rails.last.valid and rails.last
  local at_home = front and front.surface.index == state.surface
    and (outbreak.distance_squared(front.position, home) <= core_reach * core_reach
      or (last and outbreak.distance_squared(front.position, last.position) <= track_reach * track_reach))
  if at_home then
    absorb(rails, the_train)
    return true
  end
  if not (rails.phase == "done" and last) or rails.no_route[the_train.id] then return false end
  local route = rails.routed[the_train.id]
  if not route then
    the_train.schedule = {current = 1, records = {{rail = last, rail_direction = rails.end_direction, temporary = true, wait_conditions = {{type = "inactivity", compare_type = "or", ticks = 60 * 60}}}}}
    the_train.manual_mode = false
    rails.routed[the_train.id] = {tick = game.tick}
    entry.done_holding = true
    return true
  end
  local train_state = the_train.state
  local lost = train_state == defines.train_state.no_path or train_state == defines.train_state.no_schedule
    or (game.tick - route.tick > route_patience and not the_train.has_path and the_train.speed == 0)
  if lost then
    rails.no_route[the_train.id] = true
    rails.routed[the_train.id] = nil
    rails.lost = (rails.lost or 0) + 1
    the_train.manual_mode = true
    return false
  end
  return true
end

-- A train out on one of its raids, which this looks after rather than train.lua.
function lair_rails.keeps(the_train)
  local state = outbreak.state()
  local raider = state and state.rails and state.rails.raider
  if not raider then return false end
  for _, carriage in pairs(the_train.carriages) do
    if raider.units[carriage.unit_number] then return true end
  end
  return false
end

-- Every train that stops at its station is infected there, whoever's it was, and taken in.
local function on_train_changed_state(event)
  local the_train = event.train
  if not (the_train.valid and the_train.state == defines.train_state.wait_station and outbreak.active()) then return end
  local rails = outbreak.state().rails
  if not (rails and rails.station and rails.station.valid and the_train.station == rails.station) then return end
  local taken = 0
  for _, carriage in pairs(the_train.carriages) do
    if infection.infect(carriage, true) then taken = taken + 1 end
  end
  if taken > 0 then
    the_train.manual_mode = true
    rails.captured = (rails.captured or 0) + 1
  end
end

-- Over: whoever's aboard its train gets out (to be set down with the rest of its creatures), the train stops where it is
-- (it's given back as infected), the depot's carriages are set down on the platform for the player, or as items with what
-- was in them if there's no room, and its station stops luring.
table.insert(outbreak.on_end, function(state)
  local rails = state.rails
  if not rails then return end
  local surface = game.get_surface(state.surface)
  -- A track still being worked out goes.
  if rails.planning then
    for _, piece in pairs(rails.planning.placed) do
      if piece.valid then piece.destroy() end
    end
    rails.planning, rails.phase = nil, nil
  end
  local raider = rails.raider
  if raider then
    local the_train = raider_train(raider)
    unload(raider, surface, nil, nil)
    if the_train then
      the_train.schedule = nil
      the_train.manual_mode = true
      the_train.speed = 0
    end
    rails.raider = nil
  end
  local platform = rails.last and rails.last.valid
  local fallback = platform and rails.last.position or outbreak.home() or {x = 0, y = 0}
  local along, previous = 0, nil
  for _, pack in ipairs(rails.depot) do
    local carriage
    local spot, at, length
    if platform then spot, at, length = next_spot(rails, along, previous, pack.name) end
    if spot then
      local owner = game.forces[pack.owner] and pack.owner or target_force
      carriage = surface.create_entity
      {
        name = pack.name, position = spot, direction = (rails.heading + 8) % 16, force = owner,
        quality = prototypes.quality[pack.quality or ""] and pack.quality or nil, snap_to_train_stop = false, raise_built = true,
        create_build_effect_smoke = false
      }
      if carriage then along, previous = at, length end
    end
    if carriage then
      contents.restore(carriage, pack.contents)
      if pack.color then carriage.color = pack.color end
      if carriage.train then carriage.train.manual_mode = true end
    else
      local prototype = prototypes.entity[pack.name]
      local items = prototype and prototype.items_to_place_this
      local item = items and items[1]
      if item then surface.spill_item_stack{position = fallback, stack = {name = item.name, count = item.count or 1, quality = pack.quality}, enable_looted = true, drop_full_stack = true} end
      contents.spill(surface, fallback, pack.contents)
    end
  end
  rails.depot = {}
  if rails.station and rails.station.valid then rails.station.backer_name = station_name end
end)

-- For admins and tests: the rest of the track at once, joined at once, without paying for it.
outbreak.hurry_hooks["rails"] = function(state)
  if state.phase ~= "lair" or not (state.core and state.core.valid) then return "no-core" end
  local rails = rails_of(state)
  if not outbreak.analysed(outbreak.rail_sample) then return "no-sample" end
  for _ = 1, start_tries do
    if not rails.phase then plan(state, rails) end
    for _ = 1, math.ceil((max_pieces + align_pieces) / plan_batch) + 1 do
      if rails.phase ~= "planning" then break end
      plan_more(state, rails)
    end
    if rails.phase then break end
  end
  for _ = 1, #rails.specs + 1 do
    if rails.phase ~= "building" then break end
    build_step(state, rails, true)
  end
  if rails.phase == "joining" then join(state, rails, true) end
  return rails.phase or "no-start"
end

-- For admins and tests: a raid by train now, if there can be one. true, or why not.
outbreak.hurry_hooks["ride"] = function(state)
  if state.phase ~= "lair" or not outbreak.has_core() then return "no-core" end
  if state.raid then return "busy" end
  local plan, why = plan_ride(state)
  if not plan then return why end
  return outbreak.start_raid(state, plan)
end

table.insert(outbreak.status_hooks, function(state, status)
  local rails = state.rails
  if not rails then return end
  local routed = 0
  for _ in pairs(rails.routed or {}) do routed = routed + 1 end
  local raider = rails.raider
  status.rails =
  {
    phase = rails.phase, pieces = rails.pieces or 0, planned = #(rails.specs or {}), tries = rails.tries,
    junction = rails.junction and rails.junction.valid and rails.junction.position or nil,
    station = rails.station and rails.station.valid and rails.station.backer_name or nil,
    station_position = rails.station and rails.station.valid and rails.station.position or nil,
    last = rails.last and rails.last.valid and rails.last.position or nil, platform = rails.platform, lured = rails.lured,
    captured = rails.captured or 0, routed = routed, lost = rails.lost or 0, taken = rails.taken or 0, depot = #(rails.depot or {}),
    rides = rails.rides or 0,
    raider = raider and {phase = raider.phase, raid = raider.raid, stop = raider.stop_name, passengers = #raider.passengers, position = raider.position, carriages = #raider.carriages} or nil
  }
end)

lair_rails.events =
{
  [defines.events.on_train_changed_state] = on_train_changed_state
}

return lair_rails
