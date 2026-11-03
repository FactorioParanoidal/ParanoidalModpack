-- Every Beast walker: converts infected inserters, keeps them busy, and combines them into compound creatures.
local shared = require("shared")
local infection = require("script.infection")
local train = require("script.train")
local config = require("script.config")
local outbreak = require("script.outbreak")
local contents = require("script.contents")

local units = {}

local force_name = "the-beast"
local think_interval = 15
local thinks_per_interval = 15
local think_period = 2 * 60
local inserter_convert_delay = {min = 5 * 60, max = 12 * 60}
local throw_radius = 12
local wander_radius = 25
local hunt_radius = 80
local touch_radius = 4
local touch_infections = 3
local rock_infect_chance = 0.6
local rail_search_radius = 30
local march_rails = 30
local rail_types = {"straight-rail", "curved-rail-a", "curved-rail-b", "half-diagonal-rail", "elevated-straight-rail", "elevated-curved-rail-a", "elevated-curved-rail-b", "elevated-half-diagonal-rail", "rail-ramp", "legacy-straight-rail", "legacy-curved-rail"}
-- Rocks leave the railway alone, it's how the Beast gets to the rest of the base.
local spared_types = {["rail-signal"] = true, ["rail-chain-signal"] = true, ["train-stop"] = true}
for _, type in pairs(rail_types) do spared_types[type] = true end
local gather_radius = 16
local rally_radius = 32
local wagon_patience = 2 * 60 * 60
-- How long it waits at a body for more to turn up to lift it, and then how long it gets on with other things.
local rally_patience = 30 * 60
local train_rally_patience = 3 * 60 * 60
local rally_rest = 60 * 60
-- How many times it'll try for the same thing and get nowhere, and then how long it leaves that kind of thing be.
local errand_tries = 3
local errand_rest = 60 * 60
local join_distance = 6
local train_join_distance = 9
local gather_timeout = 15 * 60

-- How far out those with an attack of their own look for something to use it on.
local attack_sight = {fire = 28, corruption = 18}
local spawn_hops = {150, 60, 25}
local band_join_radius = 30
local band_gathering_time = 8 * 60
local robots_per_port = 6
local robot_launch_delay = 3 * 67
local robot_scatter = 40
local robot_drift = 30
local robot_chunk_tries = 8
local drill_radius = 2.5
local drill_damage = 30
-- What each attack on a building does to it. It's all done here so that nothing the Beast has infected ever gets hurt.
-- All of it scaled by the startup damage setting, which the prototypes' own attacks are scaled by too.
local corruption_damage = {["beast-corruption"] = 2, ["beast-corruption-beam"] = 6}
local rock_damage = 10
local stomps =
{
  ["beast-stomp"] = {radius = 2, damage = 20},
  ["beast-stomp-big"] = {radius = 2.5, damage = 35}
}
local function scaled(damage)
  return damage * config.startup("damage-multiplier")
end
local wall_grab_radius = 5
local wall_claim_time = 2 * 60
local wall_sight_radius = 20
local wall_sight_limit = 16
local pair_radius = 15
local pair_join_distance = 4

local lone_names = {}
local pair_names = {}

for _, inserter in pairs(shared.inserters) do
  lone_names[shared.lone_name(inserter)] = inserter
  pair_names[shared.pair_name(inserter)] = inserter
end

local function data()
  return storage.units
end

-- What a building would become, and as which kind of creature, if one was made of it (beasts.lua), or nil.
local function lifted_as(name)
  local info = shared.source_info(name)
  return info, info and shared.group_by_name(info.group)
end

local function register(entity)
  local state = data()
  local record = {entity = entity, unit_number = entity.unit_number, next_think = game.tick + math.random(0, think_period), lone = lone_names[entity.name] ~= nil, pair = pair_names[entity.name] ~= nil, walled = shared.is_walled(entity.name), attack = shared.attack_of(entity.name)}
  state.list[#state.list + 1] = record
  state.by_unit_number[entity.unit_number] = record
  return record
end

-- Its own pace, times how far the outbreak's research has got. Whatever pace it had before goes.
function units.set_pace(entity)
  local pace = shared.pace_of(entity.name)
  if not pace then return end
  for _, sticker in pairs(entity.stickers or {}) do
    if sticker.valid and sticker.name:sub(1, 11) == "beast-pace-" then sticker.destroy() end
  end
  entity.surface.create_entity{name = shared.pace_sticker(pace * outbreak.speed()), position = entity.position, target = entity, force = entity.force}
end

outbreak.on_tier = function()
  for _, record in pairs(data().list) do
    if record.entity.valid then units.set_pace(record.entity) end
  end
end

-- cargo: what a compound carries home ({place, quality, samples}), see form_compound.
function units.spawn(surface, name, position, carriers, cargo)
  local entity = surface.create_entity{name = name, position = position, force = force_name}
  if entity then
    local record = register(entity)
    record.carriers = carriers
    record.cargo = cargo
    units.set_pace(entity)
    rendering.draw_light{sprite = "utility/light_small", target = entity, surface = surface, color = {r = 1, g = 0.05, b = 0.3}, intensity = 0.5, scale = 1.5}
  end
  return entity
end

local function convert_inserter(entity)
  local name = shared.lone_name(shared.inserter_for(entity.name))
  local surface, position = entity.surface, entity.position
  surface.create_trivial_smoke{name = "beast-spores", position = position}
  entity.destroy{raise_destroy = true}
  return units.spawn(surface, name, position)
end

infection.conversions["inserter"] =
{
  delay = inserter_convert_delay,
  convert = convert_inserter,
  -- Without it, an infected inserter stays where it is and only passes the infection on.
  enabled = function() return config.get("inserters-awaken") end
}

local function throw_rock(record, target)
  local entity = record.entity
  entity.surface.create_entity{name = "beast-rock", position = entity.position, target = target, source = entity, force = force_name, speed = 0.35, max_range = 30}
end

local function damage_around(surface, position, radius, damage)
  local force = game.forces[force_name]
  local hit = false
  for _, entity in pairs(surface.find_entities_filtered{position = position, radius = radius}) do
    if entity.valid and entity.is_entity_with_health and not spared_types[entity.type] and force.is_enemy(entity.force) and not (entity.unit_number and infection.is_infected(entity)) then
      entity.damage(scaled(damage), force, "impact")
      hit = true
    end
  end
  return hit
end

local function find_player_entity(entity, radius)
  local found = entity.surface.find_entities_filtered{position = entity.position, radius = radius, force = game.forces.player, type = infection.infectable_types, limit = 12}
  local choices = {}
  for _, target in pairs(found) do
    if target.type ~= "character" and target.is_entity_with_health and not spared_types[target.type] and not infection.is_infected(target) then choices[#choices + 1] = target end
  end
  if #choices > 0 then return choices[math.random(#choices)] end
end

local function carriers_of(entity, record)
  return record.carriers or {entity.name}
end

-- Whether these inserters can carry this: a strict one wants its own type of inserter and nothing else.
local function carriers_suit(carriers, group)
  if not group.strict then return true end
  for _, name in pairs(carriers) do
    if lone_names[name] ~= group.leg_inserter then return false end
  end
  return true
end

-- Who could help carry this, and how many inserters that comes to: loose ones first, then pairs, as the two inserters they
-- are. Anything already carrying something has settled on what it is, and stays that way.
local function nearby_carriers(entity, radius, group)
  local result, total = {}, 0
  for _, other in pairs(entity.surface.find_entities_filtered{position = entity.position, radius = radius, type = "spider-unit", force = force_name}) do
    local record = data().by_unit_number[other.unit_number]
    if record and not record.gathering and not record.walled and (record.lone or record.pair) then
      local carriers = carriers_of(other, record)
      if carriers_suit(carriers, group) then
        result[#result + 1] = {entity = other, count = #carriers}
        total = total + #carriers
      end
    end
  end
  table.sort(result, function(a, b)
    if a.count ~= b.count then return a.count < b.count end
    return a.entity.unit_number < b.entity.unit_number
  end)
  return result, total
end

-- There's something for them to do here after all, so it's every creature for itself again.
local function break_band(band)
  for _, member in pairs(band.members) do
    local record = member.valid and data().by_unit_number[member.unit_number]
    if record then record.band = nil end
  end
  band.members = {}
  if band.group.valid then band.group.destroy() end
end

-- Looks for an infected body enough inserters are near, and calls them over to pick it up.
-- A wagon leaves the inserters for its locomotive for a while, so the locomotive gets to go first.
local function waiting_for_locomotive(body, group)
  if not group.train then return false end
  if not train.can_lift(body) then return true end
  if body.type == "locomotive" then return false end
  if game.tick - infection.infected_tick(body) > wagon_patience then return false end
  for _, carriage in pairs(body.train.carriages) do
    if carriage.type == "locomotive" then return true end
  end
  return false
end

local function reach_of(group)
  return group.train and train_join_distance or join_distance
end

-- Walks over to just outside the body on its own side, as there's no path onto a train, or it stays put if close enough.
local function approach(entity, body, reach)
  local position, target = entity.position, body.position
  local dx, dy = position.x - target.x, position.y - target.y
  local distance = math.sqrt(dx * dx + dy * dy)
  if distance <= reach - 1 then return end
  local stop_at = (reach - 2) / distance
  entity.commandable.set_command{type = defines.command.go_to_location, destination = {x = target.x + dx * stop_at, y = target.y + dy * stop_at}, radius = 1, distraction = defines.distraction.none}
end

local function try_gather(record)
  if not config.get("compounds") then return false end
  local entity = record.entity
  local rally
  -- Only what's infected, which is all the Beast's, and of those only what a creature was made of.
  local bodies = {}
  for _, body in pairs(entity.surface.find_entities_filtered{position = entity.position, radius = rally_radius, type = shared.source_types, force = force_name}) do
    if shared.source_info(body.name) then bodies[#bodies + 1] = body end
  end
  -- Power first, as it's what an outbreak lives on, then what it attacks with. Then the biggest, or a wagon would always
  -- get to the inserters before the locomotive could.
  local function rank(body)
    return shared.is_energy_type[body.type] and 2 or shared.is_assault_type[body.type] and 1 or 0
  end
  table.sort(bodies, function(a, b)
    local rank_a, rank_b = rank(a), rank(b)
    if rank_a ~= rank_b then return rank_a > rank_b end
    return shared.source_info(a.name).legs > shared.source_info(b.name).legs
  end)
  for _, body in pairs(bodies) do
    local info, group = lifted_as(body.name)
    local legs = info.legs
    local waiting = group and infection.is_infected(body) and waiting_for_locomotive(body, group)
    -- Stays by a wagon that's waiting for its locomotive to go first, or there'd be nobody left when its turn came.
    if waiting and train.can_lift(body) and not rally then rally = body end
    if group and not waiting and infection.is_infected(body) and not data().gatherings[body.unit_number] then
      local helpers, total = nearby_carriers(body, gather_radius, group)
      local counts = (record.lone or record.pair) and carriers_suit(carriers_of(entity, record), group)
      -- Only worth waiting at if it's nearly there, or they'd stand around for ones that never come. A train is always
      -- worth it, as it's being held there for them.
      if counts and total < legs and (group.train or total * 2 >= legs) and not rally then rally = body end
      if total >= legs then
        local chosen, chosen_total = {}, 0
        for _, helper in pairs(helpers) do
          if chosen_total >= legs then break end
          local helper_record = data().by_unit_number[helper.entity.unit_number]
          if helper_record.band then break_band(helper_record.band) end
          helper_record.gathering = body.unit_number
          chosen[#chosen + 1] = helper.entity
          chosen_total = chosen_total + helper.count
          approach(helper.entity, body, reach_of(group))
        end
        data().gatherings[body.unit_number] = {body = body, group = group.name, legs = legs, as = info.as, samples = info.samples, inserters = chosen, timeout = game.tick + gather_timeout}
        return true
      end
    end
  end
  return false, rally
end

local group_by_name = shared.group_by_name

local function release(gathering)
  for _, inserter in pairs(gathering.inserters) do
    if inserter.valid then
      local record = data().by_unit_number[inserter.unit_number]
      if record then record.gathering = nil end
    end
  end
end

function units.destroy_unit(entity)
  data().by_unit_number[entity.unit_number] = nil
  entity.destroy{raise_destroy = true}
end

local function let_go(surface, names, position)
  for i, name in pairs(names) do
    local angle = 2 * math.pi * i / #names
    -- Anything from an older save that no longer exists counts as whichever it's most like.
    if not prototypes.entity[name] then name = shared.lone_name(shared.inserter_for(name)) end
    units.spawn(surface, name, {x = position.x + math.cos(angle) * 1.5, y = position.y + math.sin(angle) * 1.5})
  end
end

-- It's drawn with the one type of inserter for all its legs, so that's whichever there's most of.
local function most_common_inserter(carriers, group)
  if group.strict then return group.leg_inserter end
  local counts = {}
  for _, name in pairs(carriers) do
    local inserter = lone_names[name] or shared.inserter_for(name)
    counts[inserter] = (counts[inserter] or 0) + 1
  end
  local best, best_count = "inserter", 0
  for _, inserter in pairs(shared.inserters) do
    if (counts[inserter] or 0) > best_count then best, best_count = inserter, counts[inserter] end
  end
  return best
end

-- The hands grab hold and the whole thing stands up.
local function form_compound(gathering)
  local body = gathering.body
  local group = group_by_name(gathering.group)
  -- A gathering from an older save has neither, and was for a base game building.
  local legs, source = gathering.legs or group.legs, gathering.as or body.name
  local surface, position = body.surface, body.position
  local orientation = (group.train or group.vehicle) and body.orientation
  local carriers, spare = {}, {}
  for _, helper in pairs(gathering.inserters) do
    for _, carrier in pairs(carriers_of(helper, data().by_unit_number[helper.unit_number])) do
      local names = #carriers < legs and carriers or spare
      names[#names + 1] = carrier
    end
    units.destroy_unit(helper)
  end
  surface.create_trivial_smoke{name = "beast-spores", position = position}
  local name = shared.compound_name(group, source, most_common_inserter(carriers, group))
  if not prototypes.entity[name] then name = shared.compound_name(group, source) end
  -- What it takes home: the building it's drawn as (a ranked turret loses its rank, a lit pole is just its lamp), and
  -- the samples it gives (a lit pole gives the pole as well).
  local owner = infection.previous_force(body)
  local cargo = {place = source, quality = body.quality.name, samples = gathering.samples, owner = owner and owner.name or "player", contents = contents.pack(body)}
  body.destroy{raise_destroy = true}
  let_go(surface, spare, position)
  local compound = units.spawn(surface, name, position, carriers, cargo)
  if compound and orientation then compound.orientation = orientation end
  return compound
end

-- The body is gone, but the inserters holding it let go and carry on, and what was in what it carried falls out.
local function on_entity_died(event)
  local entity = event.entity
  local record = data().by_unit_number[entity.unit_number]
  if not (record and record.carriers) then return end
  data().by_unit_number[entity.unit_number] = nil
  for _, cargo in pairs{record.cargo, record.carried} do
    contents.spill(entity.surface, entity.position, cargo.contents)
    cargo.contents = nil
  end
  let_go(entity.surface, record.carriers, entity.position)
end

local function check_gatherings()
  local state = data()
  for key, gathering in pairs(state.gatherings) do
    local alive = gathering.body.valid
    local arrived = 0
    local reach = reach_of(group_by_name(gathering.group))
    for _, inserter in pairs(gathering.inserters) do
      if not inserter.valid then
        alive = false
      elseif alive then
        local dx, dy = inserter.position.x - gathering.body.position.x, inserter.position.y - gathering.body.position.y
        if dx * dx + dy * dy <= reach * reach then arrived = arrived + 1 end
      end
    end
    if not alive or game.tick > gathering.timeout then
      release(gathering)
      state.gatherings[key] = nil
    elseif arrived == #gathering.inserters then
      state.gatherings[key] = nil
      form_compound(gathering)
    end
  end
end

-- Anything a creature brushes past turns too.
local function infect_what_it_touches(entity)
  local nearby = entity.surface.find_entities_filtered{position = entity.position, radius = touch_radius, type = infection.infectable_types, force = infection.target_forces(), limit = touch_infections}
  for _, target in pairs(nearby) do
    infection.infect(target)
  end
end

local function find_prey(entity, radius)
  local found = entity.surface.find_entities_filtered{position = entity.position, radius = radius, type = infection.infectable_types, force = infection.target_forces(), limit = 16}
  for _, target in pairs(found) do
    if infection.can_infect(target) then return target.position end
  end
end

-- Towards somewhere a bit at a time, as a path all the way there could be too long to be found, and somewhere that can be
-- walked to, as a path into a lake isn't found at all. What takes a wall can take a foot.
local function hop_towards(entity, goal, shortest)
  local position = entity.position
  local dx, dy = goal.x - position.x, goal.y - position.y
  local distance = math.sqrt(dx * dx + dy * dy)
  for i = shortest or 1, #spawn_hops do
    local hop = spawn_hops[i]
    if hop < distance then
      local at = {x = position.x + dx * hop / distance + math.random(-15, 15), y = position.y + dy * hop / distance + math.random(-15, 15)}
      local land = entity.surface.find_non_colliding_position("stone-wall", at, 20, 2)
      if land then return land end
    end
  end
  return entity.surface.find_non_colliding_position("stone-wall", goal, 20, 2) or goal
end

-- 2.1: LuaRailEnd, get_rail_end and move_natural are unchanged. Only the rail and its direction are kept in storage, as
-- in 2.0, so nothing here needs changing.
local function advance(rail_end)
  local moved = 0
  for _ = 1, march_rails do
    if not rail_end.move_natural() then break end
    moved = moved + 1
  end
  return moved
end

-- Picks the way along the track that ends up nearest the player's spawn.
local function start_march(entity)
  local rail = entity.surface.find_entities_filtered{position = entity.position, radius = rail_search_radius, type = rail_types, force = game.forces.player, limit = 1}[1]
  if not rail then return end
  local spawn = game.forces.player.get_spawn_position(entity.surface)
  local best, best_distance
  for _, direction in pairs{defines.rail_direction.front, defines.rail_direction.back} do
    local rail_end = rail.get_rail_end(direction)
    local ahead = rail_end.make_copy()
    advance(ahead)
    local position = ahead.location.position
    local distance = (position.x - spawn.x) ^ 2 + (position.y - spawn.y) ^ 2
    if not best or distance < best_distance then best, best_distance = rail_end, distance end
  end
  return best
end

-- The next stretch of the railway to walk. Once it's run out of track it's done with railways, and heads on overland.
-- Where it's got to is kept as the rail and which end of it, as those are plain entity references in the save.
local function march_goal(record)
  if record.off_the_rails then return end
  local march, rail_end = record.march
  if march and march.rail and march.rail.valid then rail_end = march.rail.get_rail_end(march.direction) end
  if not rail_end then rail_end = start_march(record.entity) end
  record.march = nil
  if not rail_end then return end
  if advance(rail_end) == 0 then
    record.off_the_rails = true
    return
  end
  record.march = {rail = rail_end.rail, direction = rail_end.direction}
  return rail_end.location.position
end

-- On down the railway, then whatever's further off, and then the heart of the factory. Once it's there and there's nothing
-- left, whoever's still out there. A band goes the same way as one creature, with one of its members to go by.
local function find_destination(record)
  local entity = record.entity
  if record.goal then return hop_towards(entity, record.goal, record.shortest_hop) end
  local goal = march_goal(record) or (not record.stuck and find_prey(entity, hunt_radius))
  if goal then return goal end
  local position = entity.position
  local spawn = game.forces.player.get_spawn_position(entity.surface)
  local dx, dy = spawn.x - position.x, spawn.y - position.y
  local distance = math.sqrt(dx * dx + dy * dy)
  if distance > hunt_radius then
    -- A bit at a time, as a path all the way there could be too long to be found, and somewhere that can be walked to, as a
    -- path into a lake isn't found at all. What takes a wall can take a foot.
    for i = record.shortest_hop or 1, #spawn_hops do
      local hop = spawn_hops[i]
      local goal = {x = position.x + dx * hop / distance + math.random(-15, 15), y = position.y + dy * hop / distance + math.random(-15, 15)}
      local land = entity.surface.find_non_colliding_position("stone-wall", goal, 20, 2)
      if land then return land end
    end
  end
  for _, player in pairs(game.forces.player.connected_players) do
    if player.character and player.surface == entity.surface then return player.character.position end
  end
  return {x = position.x + math.random(-30, 30), y = position.y + math.random(-30, 30)}
end

-- With nothing around to do, a lone inserter looks for another to clamp hands with, as they cover ground better that way.
local function try_pair(record)
  local entity = record.entity
  local position = entity.position
  for _, other in pairs(entity.surface.find_entities_filtered{position = position, radius = pair_radius, type = "spider-unit", force = force_name}) do
    local other_record = data().by_unit_number[other.unit_number]
    -- Only with its own kind, as a pair is drawn as being all the one kind.
    if other ~= entity and other.name == entity.name and other_record and other_record.lone and not other_record.gathering then
      local dx, dy = other.position.x - position.x, other.position.y - position.y
      if dx * dx + dy * dy > pair_join_distance * pair_join_distance then
        -- One waits and the other walks over, or they swap places and can overshoot each other altogether.
        if entity.unit_number < other.unit_number then
          entity.commandable.set_command{type = defines.command.stop, ticks_to_wait = 3 * 60, distraction = defines.distraction.none}
        else
          approach(entity, other, pair_join_distance + 1)
        end
        return true
      end
      local surface, carriers = entity.surface, {entity.name, other.name}
      local name = shared.pair_name(lone_names[entity.name])
      units.destroy_unit(entity)
      units.destroy_unit(other)
      units.spawn(surface, name, {x = position.x + dx / 2, y = position.y + dy / 2}, carriers)
      return true
    end
  end
  return false
end

local function given_up(record)
  return record.no_errands_until and game.tick < record.no_errands_until
end

-- Being back here with the same thing to do means it got nowhere, as there's no way there, likely across water.
local function in_vain(record, position)
  local last = record.errand
  if last and last.x == position.x and last.y == position.y then
    record.errand_count = record.errand_count + 1
  else
    record.errand = position
    record.errand_count = 1
  end
  if record.errand_count <= errand_tries then return false end
  record.errand = nil
  record.no_errands_until = game.tick + errand_rest
  return true
end

local function legs_needing_walls(entity, record)
  if record.walled then return nil end
  if record.lone or record.pair then return 2 end
  local compound = shared.creature_info(entity.name)
  local group = compound and group_by_name(compound.group)
  return group and not (group.train or group.vehicle) and compound.legs or nil
end

-- One piece of wall for each leg to stand on, and up it goes. It comes back down without them if it dies.
local function climb_walls(record, walls)
  local entity = record.entity
  local surface, position, name = entity.surface, entity.position, shared.walled_name(entity.name)
  local health, orientation = entity.get_health_ratio(), entity.orientation
  local carriers = carriers_of(entity, record)
  for _, wall in pairs(walls) do
    surface.create_trivial_smoke{name = "beast-spores", position = wall.position}
    wall.destroy{raise_destroy = true}
  end
  local cargo, carried = record.cargo, record.carried
  record.cargo, record.carried = nil, nil
  units.destroy_unit(entity)
  local walled = units.spawn(surface, name, position, carriers, cargo)
  if walled then
    walled.health = walled.max_health * health
    walled.orientation = orientation
    local walled_record = data().by_unit_number[walled.unit_number]
    walled_record.carried, walled_record.rode = carried, record.rode
  else
    for _, lost in pairs{cargo or {}, carried or {}} do contents.spill(surface, position, lost.contents) end
  end
end

-- Takes what's in reach, or goes over if there's enough to be had. True if that's what it's doing now.
local function try_walls(record)
  if not (config.get("wall-climbing") and config.get("infect-walls")) then return false end
  local entity = record.entity
  local needed = legs_needing_walls(entity, record)
  if not needed then return false end
  local surface, position = entity.surface, entity.position
  -- It has to have made them its own before it can take them, and you get to see that happen.
  local infected = {}
  for _, wall in pairs(surface.find_entities_filtered{position = position, radius = wall_grab_radius, type = "wall"}) do
    if not infection.is_infected(wall) then
      infection.infect(wall)
    elseif game.tick - infection.infected_tick(wall) >= wall_claim_time then
      infected[#infected + 1] = wall
    end
    if #infected >= needed then
      climb_walls(record, infected)
      return true
    end
  end
  local command = entity.commandable.command
  if command and command.type ~= defines.command.wander then return false end
  if given_up(record) then return false end
  -- Only over to enough of them together, as there's no use going to ones too far apart to take.
  for _, wall in pairs(surface.find_entities_filtered{position = position, radius = wall_sight_radius, type = "wall", limit = wall_sight_limit}) do
    if surface.count_entities_filtered{position = wall.position, radius = wall_grab_radius - 1, type = "wall"} >= needed then
      if in_vain(record, wall.position) then return false end
      entity.commandable.set_command{type = defines.command.go_to_location, destination = wall.position, radius = 3}
      return true
    end
  end
  return false
end

-- A random chunk with the player's factory in it somewhere between here and the heart of it, going by its pollution and its
-- buildings. Failing that, off in some random direction with a bit of a pull towards the heart of it.
local function diffuse(entity)
  local surface, position = entity.surface, entity.position
  local spawn = game.forces.player.get_spawn_position(surface)
  local dx, dy = spawn.x - position.x, spawn.y - position.y
  local distance = math.max(math.sqrt(dx * dx + dy * dy), 1)
  for _ = 1, robot_chunk_tries do
    local angle, reach = math.random() * 2 * math.pi, math.random() * (distance + 64)
    local chunk_x, chunk_y = math.floor((spawn.x + math.cos(angle) * reach) / 32), math.floor((spawn.y + math.sin(angle) * reach) / 32)
    local area = {{chunk_x * 32, chunk_y * 32}, {chunk_x * 32 + 32, chunk_y * 32 + 32}}
    if surface.is_chunk_generated{chunk_x, chunk_y} and (surface.get_pollution(area[1]) > 0 or surface.count_entities_filtered{area = area, force = game.forces.player, limit = 1} > 0) then
      return {x = chunk_x * 32 + math.random(0, 31), y = chunk_y * 32 + math.random(0, 31)}
    end
  end
  local pull = math.min(robot_drift, distance) / distance
  return {x = position.x + dx * pull + math.random(-robot_scatter, robot_scatter), y = position.y + dy * pull + math.random(-robot_scatter, robot_scatter)}
end

local function send_robot_off(entity, distraction)
  entity.commandable.set_command{type = defines.command.go_to_location, destination = diffuse(entity), radius = 5, distraction = distraction}
end

-- The engine has them go for anything they come across on the way, and their attack does the infecting.
local function think_robot(record)
  local command = record.entity.commandable.command
  if command and command.type ~= defines.command.wander then return end
  send_robot_off(record.entity, defines.distraction.by_anything)
end

-- Nothing left around here to turn, so they move on together, rather than each making its own way there. key: where
-- they're going in an outbreak (home, or which raid), as only those going the same way go together.
local function join_band(record, key)
  local entity = record.entity
  local state = data()
  local position = entity.position
  for _, band in pairs(state.bands) do
    if not band.moving and band.key == key and band.group.valid and band.group.surface == entity.surface then
      local at = band.group.position
      if (at.x - position.x) ^ 2 + (at.y - position.y) ^ 2 <= band_join_radius * band_join_radius then
        band.group.add_member(entity)
        band.members[#band.members + 1] = entity
        record.band = band
        return
      end
    end
  end
  local group = entity.surface.create_unit_group{position = position, force = force_name}
  group.add_member(entity)
  local band = {group = group, members = {entity}, moving_at = game.tick + band_gathering_time, key = key}
  state.bands[#state.bands + 1] = band
  record.band = band
end

local function update_bands()
  local bands = data().bands
  for i = #bands, 1, -1 do
    local band = bands[i]
    local leader
    for _, member in pairs(band.members) do
      if member.valid then
        leader = member
        break
      end
    end
    if not leader or not band.group.valid then
      break_band(band)
      table.remove(bands, i)
    elseif game.tick >= band.moving_at then
      local state = band.group.state
      -- In an outbreak, where the one they go by is headed. Once that's nowhere they're there, and split up.
      local goal = true
      if band.key then
        local leader_record = data().by_unit_number[leader.unit_number]
        goal = leader_record and outbreak.goal(leader_record, leader)
        band.goal = goal or nil
      end
      if not goal then
        break_band(band)
        table.remove(bands, i)
      elseif not band.moving or state == defines.group_state.finished or not band.group.has_command then
        band.moving = true
        band.entity = leader
        -- If that got it nowhere there was no path there, likely across water, so it tries somewhere closer.
        local at, from = leader.position, band.from
        local stuck = from and (at.x - from.x) ^ 2 + (at.y - from.y) ^ 2 < 25
        band.stuck = stuck
        band.shortest_hop = stuck and math.min((band.shortest_hop or 1) + 1, #spawn_hops) or 1
        band.from = at
        band.group.set_command{type = defines.command.go_to_location, destination = find_destination(band), radius = 6}
        -- A command can be the end of it, if the game finds it has nobody left to carry it out.
        if band.group.valid then band.group.start_moving() end
      end
    end
  end
end

-- It only waits for so long, as the rest might never come.
local function still_rallying(record, rally)
  if record.no_rally_until and game.tick < record.no_rally_until then return nil end
  if not rally then
    record.rally_started = nil
    return nil
  end
  record.rally_started = record.rally_started or game.tick
  local _, group = lifted_as(rally.name)
  local patience = group and group.train and train_rally_patience or rally_patience
  if game.tick - record.rally_started < patience then return rally end
  record.rally_started = nil
  record.no_rally_until = game.tick + rally_rest
  return nil
end

local function prey_near(record)
  if given_up(record) then return nil end
  return find_prey(record.entity, wander_radius)
end

-- Home with what it carried: the core unpacks it beside itself and takes its samples, and the inserters carrying it let
-- go. A train can't be set down without rails, so it stays a creature, but its sample is taken all the same.
local function unpack(record)
  if not outbreak.has_core() then return end
  local entity = record.entity
  local cargo = record.cargo
  record.cargo = nil
  outbreak.add_samples(cargo)
  local info = shared.creature_info(entity.name)
  local group = info and group_by_name(info.group)
  local surface, position = entity.surface, entity.position
  -- A carriage goes into the lair's depot once it has a platform to grow trains on (lair_rails.lua).
  if group and group.train and outbreak.store_carriage and outbreak.store_carriage(cargo) then
    local carriers = carriers_of(entity, record)
    units.destroy_unit(entity)
    let_go(surface, carriers, position)
    return
  end
  -- Otherwise rolling stock and vehicles stay creatures, to raid with, and hold on to what they were for the end.
  if not group or group.train or group.vehicle then
    record.carried = cargo
    return
  end
  if not outbreak.place_cargo(surface, cargo, position) then
    record.cargo = cargo
    return
  end
  local carriers = carriers_of(entity, record)
  units.destroy_unit(entity)
  let_go(surface, carriers, position)
end

-- Where it stands, as a building of its owner's with what was in it, or spilled as its item with what was in it if it
-- can't stand there (rolling stock off the rails, no room).
local function set_down(surface, name, position, force, quality, pack)
  local prototype = prototypes.entity[name]
  if not prototype then return contents.spill(surface, position, pack) end
  quality = quality and prototypes.quality[quality] and quality or nil
  local spot = surface.find_non_colliding_position(name, position, 8, 0.5)
  local built = spot and surface.create_entity{name = name, position = spot, force = force, quality = quality, raise_built = true, create_build_effect_smoke = false}
  if built then return contents.restore(built, pack) end
  local items = prototype.items_to_place_this
  local item = items and items[1]
  if item then
    surface.spill_item_stack{position = position, stack = {name = item.name, count = item.count or 1, quality = quality}, enable_looted = true, force = force}
  end
  contents.spill(surface, position, pack)
end

-- When the outbreak is over, whatever a creature had taken is set down where it stands: what it carried, and the
-- inserters it was made of, each with a random defect (shared.random_defect). Corrupted robots were never anyone's. An
-- inserter of another mod comes back as the base game's one it walked as.
outbreak.put_down = function(record)
  local entity = record.entity
  if record.attack == "robot" or not entity.valid then return end
  local surface, position = entity.surface, entity.position
  local cargo = record.cargo or record.carried
  record.cargo, record.carried = nil, nil
  if not cargo then
    -- A compound from before an outbreak has no cargo.
    local info = shared.creature_info(entity.name)
    if info then cargo = {place = info.source, owner = "player"} end
  end
  if cargo then set_down(surface, cargo.place, position, cargo.owner or "player", shared.random_defect(cargo.place) or cargo.quality, cargo.contents) end
  for _, carrier in pairs(carriers_of(entity, record)) do
    local name = shared.is_walled(carrier) and carrier:sub(1, -8) or carrier
    local count = 1
    local inserter = lone_names[name]
    if not inserter and pair_names[name] then inserter, count = pair_names[name], 2 end
    for _ = 1, inserter and count or 0 do set_down(surface, inserter, position, "player", shared.random_defect(inserter)) end
  end
end

local function band_key(record, kind)
  return kind == "raid" and ("raid-" .. record.raid) or kind
end

local function think(record)
  local entity = record.entity
  if record.attack == "robot" then return think_robot(record) end
  if record.gathering then return end
  local commandable = entity.commandable
  -- In an outbreak: home with nothing to do, or on its way somewhere with whoever's going the same way.
  local goal, kind = outbreak.goal(record, entity)
  if kind == "idle" then
    if record.band then break_band(record.band) end
    if record.cargo then return unpack(record) end
    if record.lone then try_pair(record) end
    return
  end
  if goal then
    local key = band_key(record, kind)
    if record.band and (record.band.key ~= key or not record.band.group.valid) then break_band(record.band) end
    if not record.band then join_band(record, key) end
    return
  end
  infect_what_it_touches(entity)
  local rally
  if record.lone or record.pair then
    local gathered
    gathered, rally = try_gather(record)
    if gathered then return end
    rally = still_rallying(record, rally)
  end
  if record.band then
    if not record.band.group.valid or rally or prey_near(record) then
      break_band(record.band)
    else
      local band_target = record.attack == "rock" and outbreak.may_fight() and find_player_entity(entity, throw_radius)
      if band_target then throw_rock(record, band_target) end
      return
    end
  end
  if not rally and try_walls(record) then return end
  if record.lone and not rally and not prey_near(record) and try_pair(record) then return end
  if record.attack == "drill" and outbreak.may_fight() and damage_around(entity.surface, entity.position, drill_radius, drill_damage) then
    entity.surface.create_trivial_smoke{name = "smoke-building", position = entity.position}
  end
  local target = record.attack == "rock" and outbreak.may_fight() and find_player_entity(entity, throw_radius)
  if target then throw_rock(record, target) end
  -- Again if it's back to doing nothing, as its way there can fail, and then it'd stand there waiting for good.
  if rally and (record.rallying ~= rally.unit_number or (commandable.command and commandable.command.type == defines.command.wander)) then
    record.rallying = rally.unit_number
    local _, group = lifted_as(rally.name)
    approach(entity, rally, reach_of(group))
    return
  end
  if not rally then record.rallying = nil end
  -- A unit with no orders is given a wander by the game, so that counts as having nothing to do. Nor is there anything more
  -- to do to something it's infected, which is its own now.
  local command = commandable.command
  local finished = command and command.type == defines.command.attack and command.target and command.target.valid and command.target.unit_number and infection.is_infected(command.target)
  if command and command.type ~= defines.command.wander and not finished then return end
  if rally then return end
  -- Early in an outbreak it keeps out of fights.
  if not given_up(record) and outbreak.may_fight() then
    local sight = attack_sight[record.attack]
    local victim = (sight and find_player_entity(entity, sight)) or entity.surface.find_nearest_enemy{position = entity.position, max_distance = wander_radius, force = force_name}
    if victim then
      if not in_vain(record, victim.position) then
        commandable.set_command{type = defines.command.attack, target = victim}
        return
      end
    else
      local prey = find_prey(entity, wander_radius)
      if prey and not in_vain(record, prey) then
        commandable.set_command{type = defines.command.go_to_location, destination = prey, radius = 3}
        return
      end
    end
  elseif not given_up(record) then
    local prey = find_prey(entity, wander_radius)
    if prey and not in_vain(record, prey) then
      commandable.set_command{type = defines.command.go_to_location, destination = prey, radius = 3, distraction = defines.distraction.none}
      return
    end
  end
  -- In an outbreak it stays in its zone until that closes, and then goes home.
  if outbreak.active() then return end
  join_band(record)
end

infection.on_infected["roboport"] = function(entity)
  data().ports[entity.unit_number] = {entity = entity, robots = {}, next_launch = game.tick + robot_launch_delay}
end

-- For as long as it's infected, and it keeps replacing the ones that get shot down.
local function launch_robots()
  local state = data()
  for unit_number, port in pairs(state.ports) do
    if not port.entity.valid or not infection.is_infected(port.entity) then
      state.ports[unit_number] = nil
    elseif game.tick >= port.next_launch then
      port.next_launch = game.tick + robot_launch_delay
      local alive = {}
      for _, robot in pairs(port.robots) do
        if robot.valid then alive[#alive + 1] = robot end
      end
      port.robots = alive
      if #alive < robots_per_port then
        local robot = units.spawn(port.entity.surface, shared.robot_name(shared.robots[math.random(#shared.robots)]), port.entity.position)
        if robot then
          alive[#alive + 1] = robot
          -- Clear of the port first, or it'd be the first thing they went for.
          send_robot_off(robot, defines.distraction.none)
        end
      end
    end
  end
end

local function on_think_tick()
  check_gatherings()
  launch_robots()
  update_bands()
  local state = data()
  local list = state.list
  for _ = 1, math.min(thinks_per_interval, #list) do
    local index = state.cursor
    if index > #list then index = 1 end
    local record = list[index]
    if not record or not record.entity.valid or state.by_unit_number[record.unit_number] ~= record then
      if record and state.by_unit_number[record.unit_number] == record then state.by_unit_number[record.unit_number] = nil end
      if record and not record.entity.valid then
        for _, cargo in pairs{record.cargo or {}, record.carried or {}} do
          contents.discard(cargo.contents)
          cargo.contents = nil
        end
      end
      list[index] = list[#list]
      list[#list] = nil
      if #list == 0 then break end
      state.cursor = index
    else
      if game.tick >= record.next_think then
        record.next_think = game.tick + think_period
        think(record)
      end
      state.cursor = index + 1
    end
  end
end

local function stomp(event, parameters)
  local target = event.target_entity
  local position = event.target_position or (target and target.valid and target.position)
  if position then damage_around(game.get_surface(event.surface_index), position, parameters.radius, parameters.damage) end
end

local function on_script_trigger_effect(event)
  if corruption_damage[event.effect_id] then
    local victim = event.target_entity
    if victim and victim.valid and victim.is_entity_with_health and not spared_types[victim.type] and not (victim.unit_number and infection.is_infected(victim)) then
      victim.damage(scaled(corruption_damage[event.effect_id]), game.forces[force_name], "acid")
      if victim.valid then infection.infect(victim) end
    end
    -- It's done its job here, and would otherwise keep hitting the same thing.
    local source = event.source_entity
    if source and source.valid and shared.attack_of(source.name) == "robot" then send_robot_off(source, defines.distraction.none) end
    return
  end
  if stomps[event.effect_id] then
    stomp(event, stomps[event.effect_id])
    return
  end
  if event.effect_id ~= "beast-rock-hit" then return end
  local target = event.target_entity
  if not (target and target.valid and target.is_entity_with_health) then return end
  if target.unit_number and infection.is_infected(target) then return end
  target.damage(scaled(rock_damage), game.forces[force_name], "physical")
  if target.valid and math.random() < rock_infect_chance then infection.infect(target) end
end

-- Aboard one of its trains (lair_rails.lua): the creature goes, and what's needed to bring it back is kept.
function units.board(record)
  local entity = record.entity
  local passenger = {name = entity.name, carriers = record.carriers, cargo = record.cargo, carried = record.carried, rode = record.rode, health = entity.get_health_ratio()}
  record.cargo, record.carried = nil, nil
  if record.band then break_band(record.band) end
  entity.surface.create_trivial_smoke{name = "beast-spores", position = entity.position}
  units.destroy_unit(entity)
  return passenger
end

-- Out again, as it was, near the position. Its record, or nil if there was nowhere for it (what it carried falls out).
function units.disembark(surface, passenger, position)
  local spot = surface.find_non_colliding_position(passenger.name, position, 10, 0.5) or position
  local entity = units.spawn(surface, passenger.name, spot, passenger.carriers, passenger.cargo)
  if not entity then
    for _, lost in pairs{passenger.cargo or {}, passenger.carried or {}} do contents.spill(surface, position, lost.contents) end
    return nil
  end
  local record = data().by_unit_number[entity.unit_number]
  record.carried, record.rode = passenger.carried, passenger.rode
  if passenger.health then entity.health = entity.max_health * math.max(0.05, passenger.health) end
  return record
end

-- Its body taken apart where it stands: its inserters let go, and what it carried is handed over (a carriage into the
-- lair's depot, lair_rails.lua).
function units.take_apart(record)
  local entity = record.entity
  local cargo = record.cargo or record.carried
  record.cargo, record.carried = nil, nil
  local surface, position = entity.surface, entity.position
  local carriers = carriers_of(entity, record)
  if record.band then break_band(record.band) end
  surface.create_trivial_smoke{name = "beast-spores", position = position}
  units.destroy_unit(entity)
  let_go(surface, carriers, position)
  return cargo
end

-- For the libraries on top of the outbreak, which can't require this file without a loop.
outbreak.spawn_unit = units.spawn
outbreak.board = units.board
outbreak.disembark = units.disembark
outbreak.take_apart = units.take_apart

local function setup()
  storage.units = storage.units or {list = {}, by_unit_number = {}, gatherings = {}, cursor = 1}
  storage.units.ports = storage.units.ports or {}
  storage.units.bands = storage.units.bands or {}
end

units.on_init = setup
units.on_configuration_changed = setup

units.on_nth_tick =
{
  [think_interval] = on_think_tick
}

units.events =
{
  [defines.events.on_script_trigger_effect] = on_script_trigger_effect,
  [defines.events.on_entity_died] = on_entity_died
}

return units
