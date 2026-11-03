-- An infected train forgets its schedule and runs flat out whichever way it can, through signals and into whatever's on
-- the line. Once it's gone far enough it slams to a stop among enough inserters, and gets held there so they have time to
-- turn and pick up its carriages. Each carriage is then a creature like any other (units.lua). In an outbreak with its
-- own track, it goes home along that instead, and the lair's own trains out on a raid are looked after by lair_rails.lua.
local shared = require("shared")
local infection = require("script.infection")
local config = require("script.config")
local lair_rails = require("script.lair_rails")

local train = {}

local check_interval = 10
local moving_check_interval = 2
local acceleration = 0.03
-- Checks with no movement before it gives up on this way. Long enough for it to keep ramming something that gives way.
local stalled_checks_to_turn = 6
local inserters_to_hold = 6
local station_radius = 3
-- It stops at the edge of them, so it has to reach a little further than that to get the ones right beside it.
local hold_infect_radius = 4
-- Per check, so it comes out as a stream.
local spew_chance = 1
local spew_distance = {2, 3.5}
local spew_along = 3
local hold_timeout = 4 * 60 * 60
local home_distance = 100
local departure_patience = 2 * 60 * 60

local walking_inserters = {}
for _, inserter in pairs(shared.inserters) do
  walking_inserters[#walking_inserters + 1] = shared.lone_name(inserter)
  walking_inserters[#walking_inserters + 1] = shared.pair_name(inserter)
end

local function data()
  return storage.train
end

local function watch(entity)
  data().carriages[entity.unit_number] = {entity = entity, infected_tick = game.tick, travelled = 0}
end

infection.on_infected["locomotive"] = watch
infection.on_infected["cargo-wagon"] = watch
infection.on_infected["fluid-wagon"] = watch
infection.on_infected["artillery-wagon"] = watch

-- Whichever side they're on, and whether they've come alive yet, as the ones near it soon will have.
local function inserters_nearby(carriage)
  local surface, position = carriage.surface, carriage.position
  return surface.count_entities_filtered{position = position, radius = station_radius, type = "inserter"}
    + surface.count_entities_filtered{position = position, radius = station_radius, name = walking_inserters}
end

local function has_locomotive(the_train)
  local locomotives = the_train.locomotives
  return #locomotives.front_movers + #locomotives.back_movers > 0
end

local function drive(entry, the_train)
  if not has_locomotive(the_train) then return end
  the_train.manual_mode = true
  local speed = the_train.speed
  entry.heading = entry.heading or (#the_train.locomotives.front_movers > 0 and 1 or -1)
  entry.stalled = speed == 0 and (entry.stalled or 0) + 1 or 0
  if entry.stalled >= stalled_checks_to_turn then
    entry.heading = -entry.heading
    entry.stalled = 0
  end
  local top_speed = the_train.max_forward_speed
  the_train.speed = math.max(-top_speed, math.min(top_speed, speed + entry.heading * acceleration))
end

-- Whether inserters could ever carry any of it off. If not, there's no use in it running on once it's got somewhere.
local function liftable(the_train)
  if not config.get("compounds") then return false end
  for _, carriage in pairs(the_train.carriages) do
    if shared.source_info(carriage.name) then return true end
  end
  return false
end

-- Stops dead and stays there, infecting whatever's built around it.
local function park(the_train)
  the_train.manual_mode = true
  the_train.speed = 0
end

-- A ball of it lands beside the line, anywhere along the carriage's length or a bit beyond.
local function spew(carriage, the_train)
  if math.abs(the_train.speed) < 0.1 then return end
  local angle = carriage.orientation * 2 * math.pi
  local side = (math.random() < 0.5 and 1 or -1) * (spew_distance[1] + math.random() * (spew_distance[2] - spew_distance[1]))
  local along = (math.random() * 2 - 1) * spew_along
  local position = carriage.position
  carriage.surface.create_entity
  {
    name = "beast-train-spew",
    position = position,
    force = "the-beast",
    source_position = position,
    target_position =
    {
      x = position.x + math.cos(angle) * side + math.sin(angle) * along,
      y = position.y + math.sin(angle) * side - math.cos(angle) * along
    }
  }
end

local function update_leaving(entry, the_train)
  entry.travelled = (entry.travelled or home_distance) + math.abs(the_train.speed) * check_interval
  if entry.travelled >= home_distance or game.tick - entry.infected_tick > departure_patience or not has_locomotive(the_train) then
    entry.arrived = true
  end
end

local function hold_if_at_a_station(state, entry, the_train)
  if entry.done_holding or inserters_nearby(entry.entity) < inserters_to_hold then return end
  state.holds[the_train.id] = {timeout = game.tick + hold_timeout}
  the_train.manual_mode = true
  the_train.speed = 0
end

local function update_hold(state, entry, the_train)
  local hold = state.holds[the_train.id]
  if hold then
    for _, inserter in pairs(entry.entity.surface.find_entities_filtered{position = entry.entity.position, radius = hold_infect_radius, type = "inserter"}) do
      infection.infect(inserter)
    end
    if game.tick > hold.timeout then
      state.holds[the_train.id] = nil
      for _, carriage in pairs(the_train.carriages) do
        local carriage_entry = state.carriages[carriage.unit_number]
        if carriage_entry then carriage_entry.done_holding = true end
      end
    end
  else
    hold_if_at_a_station(state, entry, the_train)
  end
end

-- Much more often, or at full speed it'd be right past a station between one check and the next.
local function check_moving_trains()
  local state = data()
  for _, entry in pairs(state.carriages) do
    if entry.arrived and entry.entity.valid then
      local the_train = entry.entity.train
      if the_train.speed ~= 0 and not state.holds[the_train.id] and not lair_rails.keeps(the_train) then hold_if_at_a_station(state, entry, the_train) end
    end
  end
end

local function check_trains()
  local state = data()
  local driven = {}
  for unit_number, entry in pairs(state.carriages) do
    if not entry.entity.valid then
      state.carriages[unit_number] = nil
    else
      local the_train = entry.entity.train
      if math.random() < spew_chance then spew(entry.entity, the_train) end
      local kept = lair_rails.keeps(the_train)
      if kept then
        driven[the_train.id] = true
      elseif entry.arrived then
        update_hold(state, entry, the_train)
      else
        update_leaving(entry, the_train)
      end
      if not kept and not state.holds[the_train.id] and not driven[the_train.id] then
        driven[the_train.id] = true
        -- In an outbreak with its own track, the train goes home along it instead, if it can find the way.
        if not lair_rails.route_home(entry, the_train) then
          if entry.arrived and not liftable(the_train) then park(the_train) else drive(entry, the_train) end
        end
      end
    end
  end
end

-- Whether inserters can pick it up yet, as it should carry the infection somewhere first. Never one of the lair's raid
-- trains.
function train.can_lift(carriage)
  if carriage.train and lair_rails.keeps(carriage.train) then return false end
  local entry = data().carriages[carriage.unit_number]
  return not entry or entry.arrived
end

function train.arrived_count()
  local count = 0
  for _, entry in pairs(data().carriages) do
    if entry.arrived then count = count + 1 end
  end
  return count
end

local function setup()
  storage.train = storage.train or {holds = {}}
  local state = storage.train
  state.carriages = state.carriages or {}
  for _, carriage in pairs(state.watched or {}) do
    if carriage.valid then watch(carriage) end
  end
  state.watched = nil
end

train.on_init = setup
train.on_configuration_changed = setup

train.on_nth_tick =
{
  [check_interval] = check_trains,
  [moving_check_interval] = check_moving_trains
}

return train
