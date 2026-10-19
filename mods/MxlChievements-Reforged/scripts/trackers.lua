-- Trackers of scripted achievements. A tracker serves the entries of prototypes/scripted.lua with
-- the same `tracker` name and may define:
--   prepare(runtime)          at load: caches from prototypes; false deactivates the entry
--   events[name](event, entries, core), filters[name](entries) -> event filter list
--   poll = {every = ticks (multiple of 60), run(entries, core)}
--   setup(entries, core)      on_init and on_configuration_changed (game is available)
--   custom() -> {[event id] = fn(event, entries, core)} for events of other mods (on_init, on_load)
--   inputs[name](event, entries, core) for custom inputs of other mods
-- Runtime entry: {id, params, amounts, names[tier]}. Core API: see control.lua.
-- Trackers only read the game and other mods; they never change entities or other mods' data.

local trackers = {}

local MINUTE = 3600

local BELT_TYPES = {["transport-belt"] = true, ["underground-belt"] = true, ["splitter"] = true,
  ["lane-splitter"] = true, ["loader"] = true, ["loader-1x1"] = true, ["linked-belt"] = true}
local ROLLING_STOCK = {["locomotive"] = true, ["cargo-wagon"] = true, ["fluid-wagon"] = true,
  ["artillery-wagon"] = true}

local function set_of(list)
  local result = {}
  for _, value in ipairs(list or {}) do result[value] = true end
  return result
end

local function each(entries, fn)
  for _, entry in ipairs(entries) do fn(entry) end
end

-- Entity prototype names by pattern, as in the data stage (prototypes/util.lua).
local function entity_names(spec)
  local types = spec.types and set_of(spec.types)
  local found = {}
  local function accept(name, prototype)
    if prototype and not prototype.hidden and (not types or types[prototype.type])
      and not (spec.exclude and name:find(spec.exclude)) then
      found[name] = true
    end
  end
  for _, name in ipairs(spec.names or {}) do accept(name, prototypes.entity[name]) end
  if spec.patterns then
    for name, prototype in pairs(prototypes.entity) do
      for _, pattern in ipairs(spec.patterns) do
        if name:find(pattern) then accept(name, prototype) break end
      end
    end
  end
  local result = {}
  for name in pairs(found) do table.insert(result, name) end
  table.sort(result)
  return result
end

local function name_filters(names)
  local result = {}
  for _, name in ipairs(names) do table.insert(result, {filter = "name", name = name}) end
  return result
end

local function has_remote(interface, method)
  local functions = remote.interfaces[interface]
  return functions ~= nil and functions[method] == true
end

local function player_of(event)
  local player = event.player_index and game.get_player(event.player_index)
  if player and player.valid then return player end
end

local function add(data, key, amount)
  data[key] = (data[key] or 0) + (amount or 1)
  return data[key]
end

---------------------------------------------------------------------------------------------------
-- Start and crafting

local wreck_set
local function wreck_names()
  local names = entity_names({patterns = {"^crash%-site%-spaceship", "ship%-wreck"}})
  wreck_set = set_of(names)
  return names
end

trackers["wreck"] = {
  prepare = function() wreck_names() end,
  events = {
    on_player_mined_entity = function(event, entries, core)
      if not (event.entity.valid and wreck_set[event.entity.name]) then return end
      local player = player_of(event)
      each(entries, function(entry) core.unlock(player, entry) end)
    end,
  },
  filters = {on_player_mined_entity = function() return name_filters(wreck_names()) end},
}

trackers["handcraft"] = {
  events = {
    on_player_crafted_item = function(event, entries, core)
      local stack = event.item_stack
      if not (stack and stack.valid_for_read) then return end
      local total = add(core.player_data(event.player_index), "crafted", stack.count)
      local player = player_of(event)
      each(entries, function(entry) core.progress(player, entry, total) end)
    end,
  },
}

trackers["handcraft-variety"] = {
  events = {
    on_player_crafted_item = function(event, entries, core)
      local stack = event.item_stack
      if not (stack and stack.valid_for_read) then return end
      local data = core.player_data(event.player_index)
      data.crafted_kinds = data.crafted_kinds or {}
      if data.crafted_kinds[stack.name] then return end
      data.crafted_kinds[stack.name] = true
      local total = add(data, "crafted_kind_count")
      local player = player_of(event)
      each(entries, function(entry) core.progress(player, entry, total) end)
    end,
  },
}

---------------------------------------------------------------------------------------------------
-- Defect workshop of ic-more-qualities: crafts finished by every workshop since it was seen.

local WORKSHOP = "ic-refine-workshop"

local function remember_workshop(entity, core)
  if not (entity and entity.valid and entity.name == WORKSHOP and entity.unit_number) then return end
  local world = core.world()
  world.workshops = world.workshops or {}
  if not world.workshops[entity.unit_number] then
    world.workshops[entity.unit_number] = {entity = entity, last = entity.products_finished}
  end
end

local function on_workshop_built(event, _, core) remember_workshop(event.entity, core) end
local function workshop_filter() return {{filter = "name", name = WORKSHOP}} end

trackers["workshop"] = {
  events = {
    on_built_entity = on_workshop_built,
    on_robot_built_entity = on_workshop_built,
    script_raised_built = on_workshop_built,
    script_raised_revive = on_workshop_built,
  },
  filters = {
    on_built_entity = workshop_filter,
    on_robot_built_entity = workshop_filter,
    script_raised_built = workshop_filter,
    script_raised_revive = workshop_filter,
  },
  setup = function(_, core)
    for _, surface in pairs(game.surfaces) do
      for _, entity in pairs(surface.find_entities_filtered({name = WORKSHOP})) do remember_workshop(entity, core) end
    end
  end,
  poll = {every = MINUTE, run = function(entries, core)
    local world = core.world()
    local changed = {}
    for unit, record in pairs(world.workshops or {}) do
      local entity = record.entity
      if entity and entity.valid then
        local finished = entity.products_finished
        if finished > record.last then
          add(core.force_data(entity.force.index), "refined", finished - record.last)
          changed[entity.force.index] = entity.force
        end
        record.last = finished
      else
        world.workshops[unit] = nil
      end
    end
    for index, force in pairs(changed) do
      local total = core.force_data(index).refined
      each(entries, function(entry) core.progress(force, entry, total) end)
    end
  end},
}

---------------------------------------------------------------------------------------------------
-- Entity counts of a force (LuaForce.get_entity_count is O(1)).

trackers["count"] = {
  prepare = function(runtime)
    local names = entity_names(runtime.params)
    local min_area = runtime.params.min_area
    if min_area then
      local large = {}
      for _, name in ipairs(names) do
        local w, h = name:match("(%d+)x(%d+)$")
        if w and tonumber(w) * tonumber(h) >= min_area then table.insert(large, name) end
      end
      names = large
    end
    if #names == 0 then return false end
    runtime.entity_names = names
  end,
  poll = {every = MINUTE, run = function(entries, core)
    for _, force in ipairs(core.player_forces()) do
      for _, entry in ipairs(entries) do
        if not core.is_done(force, entry, #entry.amounts) then
          local total = 0
          for _, name in ipairs(entry.entity_names) do total = total + force.get_entity_count(name) end
          core.progress(force, entry, total)
        end
      end
    end
  end},
}

---------------------------------------------------------------------------------------------------
-- Wind of Wind-Turbines-Reforged: share of full power = power_production / electric_buffer_size of a turbine.

local function turbine_count(force, names)
  local total = 0
  for _, name in ipairs(names) do
    if prototypes.entity[name] then total = total + force.get_entity_count(name) end
  end
  return total
end

local function wind_share(core, names)
  local world = core.world()
  local turbine = world.turbine
  if not (turbine and turbine.valid) then
    turbine = nil
    if (world.turbine_search or -MINUTE) + MINUTE <= game.tick then
      world.turbine_search = game.tick
      local present = {}
      for _, name in ipairs(names) do
        if prototypes.entity[name] then table.insert(present, name) end
      end
      for _, surface in pairs(game.surfaces) do
        turbine = surface.find_entities_filtered({name = present, limit = 1})[1]
        if turbine then break end
      end
    end
    world.turbine = turbine
  end
  if not turbine then return nil end
  local buffer = turbine.electric_buffer_size
  if not buffer or buffer <= 0 then return nil end
  return turbine.power_production / buffer
end

local function any_turbines(core, names)
  for _, force in ipairs(core.player_forces()) do
    if turbine_count(force, names) > 0 then return true end
  end
  return false
end

trackers["wind-calm"] = {
  poll = {every = 600, run = function(entries, core)
    for _, entry in ipairs(entries) do
      local names = entry.params.names
      if any_turbines(core, names) then
        local share = wind_share(core, names)
        if share and share <= 0.001 then
          for _, force in ipairs(core.player_forces()) do
            if turbine_count(force, names) >= entry.amounts[1] then core.unlock(force, entry) end
          end
        end
      end
    end
  end},
}

trackers["wind-storm"] = {
  poll = {every = 600, run = function(entries, core)
    local world = core.world()
    for _, entry in ipairs(entries) do
      local names = entry.params.names
      local share = any_turbines(core, names) and wind_share(core, names)
      if share and share >= 0.999 then
        world.storm_ticks = (world.storm_ticks or 0) + 600
      else
        world.storm_ticks = 0
      end
      if world.storm_ticks >= entry.amounts[1] * 60 then
        for _, force in ipairs(core.player_forces()) do
          if turbine_count(force, names) > 0 then core.unlock(force, entry) end
        end
      end
    end
  end},
}

---------------------------------------------------------------------------------------------------
-- Trains

trackers["mu-train"] = {
  events = {
    on_train_created = function(event, entries, core)
      local train = event.train
      if not (train and train.valid) then return end
      for _, list in pairs(train.locomotives) do
        for _, locomotive in ipairs(list) do
          if locomotive.name:sub(-3) == "-mu" then
            each(entries, function(entry) core.unlock(locomotive.force, entry) end)
            return
          end
        end
      end
    end,
  },
}

trackers["overload"] = {
  events = {
    on_train_changed_state = function(event, entries, core)
      local train = event.train
      if not (train and train.valid) or train.state ~= defines.train_state.on_the_path then return end
      for _, entry in ipairs(entries) do
        local need = entry.amounts[1]
        if #train.carriages >= need then
          local wagons = train.cargo_wagons
          if #wagons >= need and not core.is_done(wagons[1].force, entry) then
            local loaded = 0
            for _, wagon in ipairs(wagons) do
              local inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
              if inventory and not inventory.is_empty() then loaded = loaded + 1 end
            end
            if loaded >= need then core.unlock(wagons[1].force, entry) end
          end
        end
      end
    end,
  },
}

---------------------------------------------------------------------------------------------------
-- Factorissimo

local function is_factory_surface(surface)
  if surface.name:find("%-factory%-floor$") then return true end
  if has_remote("factorissimo", "is_factorissimo_surface") then
    local ok, result = pcall(remote.call, "factorissimo", "is_factorissimo_surface", surface.index)
    return ok and result == true
  end
  return false
end

trackers["factory-floor"] = {
  events = {
    on_player_changed_surface = function(event, entries, core)
      local player = player_of(event)
      if player and is_factory_surface(player.surface) then
        each(entries, function(entry) core.unlock(player, entry) end)
      end
    end,
  },
}

local factory_set
local function factory_names()
  local names = entity_names({patterns = {"^factory%-%d$", "^space%-factory%-%d$"}})
  factory_set = set_of(names)
  return names
end

local function on_factory_built(event, entries, core)
  local entity = event.entity
  if entity.valid and factory_set[entity.name] and is_factory_surface(entity.surface) then
    each(entries, function(entry) core.unlock(entity.force, entry) end)
  end
end

trackers["factory-nest"] = {
  prepare = function() factory_names() end,
  events = {on_built_entity = on_factory_built, on_robot_built_entity = on_factory_built},
  filters = {
    on_built_entity = function() return name_filters(factory_names()) end,
    on_robot_built_entity = function() return name_filters(factory_names()) end,
  },
}

-- Longest streaks of factories of the force, measured by Factorissimo itself (once per second for every
-- factory): "clean" without releasing pollution, "uptime" without power shortage, both while machines work.
local HOUR = 216000

local function factory_records_poll(key)
  return {every = MINUTE, run = function(entries, core)
    if not has_remote("factorissimo", "get_force_records") then return end
    for _, force in ipairs(core.player_forces()) do
      local ok, records = pcall(remote.call, "factorissimo", "get_force_records", force.index)
      if ok and type(records) == "table" and type(records[key]) == "number" then
        local hours = records[key] / HOUR
        each(entries, function(entry) core.progress(force, entry, hours) end)
      end
    end
  end}
end

trackers["factory-clean"] = {poll = factory_records_poll("clean")}
trackers["factory-uptime"] = {poll = factory_records_poll("uptime")}

---------------------------------------------------------------------------------------------------
-- Movement: the step since the last position is computed once per event for all movement trackers.

local step_event, step_player, step_distance

local function step(event, core)
  if step_event == event then return step_player, step_distance end
  step_event, step_player, step_distance = event, nil, nil
  local player = player_of(event)
  if not player then return end
  local data = core.player_data(player.index)
  local position, surface = player.position, player.surface_index
  local last = data.last_position
  if last and last.surface == surface then
    local dx, dy = position.x - last.x, position.y - last.y
    step_player, step_distance = player, math.sqrt(dx * dx + dy * dy)
  end
  if last then
    last.x, last.y, last.surface = position.x, position.y, surface
  else
    data.last_position = {x = position.x, y = position.y, surface = surface}
  end
  return step_player, step_distance
end

trackers["walk"] = {
  events = {
    on_player_changed_position = function(event, entries, core)
      local player, distance = step(event, core)
      if not player or distance > 3 or player.vehicle or not player.character then return end
      local total = add(core.player_data(player.index), "walked", distance)
      each(entries, function(entry) core.progress(player, entry, total) end)
    end,
  },
}

trackers["fly"] = {
  prepare = function(runtime) runtime.planes = set_of(runtime.params.names) end,
  events = {
    on_player_changed_position = function(event, entries, core)
      local player, distance = step(event, core)
      if not player or distance > 8 then return end
      local vehicle = player.vehicle
      if not (vehicle and vehicle.valid) then return end
      for _, entry in ipairs(entries) do
        if entry.planes[vehicle.name] then
          local total = add(core.player_data(player.index), "flown", distance)
          core.progress(player, entry, total)
        end
      end
    end,
  },
}

trackers["teleport"] = {
  events = {
    on_player_changed_position = function(event, entries, core)
      local player, distance = step(event, core)
      if not player or distance < 20 or player.vehicle then return end
      local near = player.surface.count_entities_filtered({name = "teleporter", position = player.position,
        radius = 8, limit = 1})
      if near == 0 then return end
      local total = add(core.player_data(player.index), "teleports")
      each(entries, function(entry) core.progress(player, entry, total) end)
    end,
  },
}

trackers["speed"] = {
  poll = {every = 60, run = function(entries, core)
    for _, player in pairs(game.connected_players) do
      local vehicle = player.vehicle
      if vehicle and vehicle.valid and vehicle.type == "car" then
        local kmh = math.abs(vehicle.speed) * 216
        each(entries, function(entry) core.progress(player, entry, kmh) end)
      end
    end
  end},
}

---------------------------------------------------------------------------------------------------
-- Robots and production statistics

trackers["robot-crash"] = {
  events = {
    on_entity_died = function(event, entries, core)
      local entity = event.entity
      if event.cause or not entity.valid or entity.force.name ~= "neutral" then return end
      if entity.type ~= "logistic-robot" and entity.type ~= "construction-robot" then return end
      local total = add(core.world(), "robot_crashes")
      each(entries, function(entry) core.progress("world", entry, total) end)
    end,
  },
  filters = {on_entity_died = function()
    return {{filter = "type", type = "logistic-robot"}, {filter = "type", type = "construction-robot"}}
  end},
}

local gas_list
local function gases()
  if gas_list then return gas_list end
  local produced = {}
  for _, recipe in pairs(prototypes.recipe) do
    for _, product in pairs(recipe.products) do
      if product.type == "fluid" then produced[product.name] = true end
    end
  end
  gas_list = {}
  for name, fluid in pairs(prototypes.fluid) do
    if name:find("^angels%-gas%-") and not fluid.hidden and produced[name] then table.insert(gas_list, name) end
  end
  table.sort(gas_list)
  return gas_list
end

trackers["gases"] = {
  poll = {every = 10 * MINUTE, run = function(entries, core)
    local list = gases()
    if #list == 0 then return end
    for _, force in ipairs(core.player_forces()) do
      local data = core.force_data(force.index)
      data.gases = data.gases or {}
      for _, surface in pairs(game.surfaces) do
        local statistics = force.get_fluid_production_statistics(surface)
        for _, gas in ipairs(list) do
          if not data.gases[gas] and statistics.get_input_count(gas) > 0 then data.gases[gas] = true end
        end
      end
      local seen = 0
      for _, gas in ipairs(list) do
        if data.gases[gas] then seen = seen + 1 end
      end
      if seen >= #list then each(entries, function(entry) core.unlock(force, entry) end) end
    end
  end},
}

---------------------------------------------------------------------------------------------------
-- Time of day, seasons of NightBrightness, evolution

local SEASONS = {"spring", "summer", "fall", "winter"}

trackers["season"] = {
  poll = {every = MINUTE, run = function(entries, core)
    if not has_remote("NightBrightness", "get_state") then return end
    local ok, state = pcall(remote.call, "NightBrightness", "get_state")
    if not ok or type(state) ~= "table" or state.disabled or type(state.season) ~= "string" then return end
    local world = core.world()
    world.seasons = world.seasons or {}
    world.seasons[state.season] = true
    for _, entry in ipairs(entries) do
      if entry.params.season == state.season then core.unlock("world", entry) end
      if entry.params.all then
        local all = true
        for _, season in ipairs(SEASONS) do all = all and world.seasons[season] == true end
        if all then core.unlock("world", entry) end
      end
    end
  end},
}

local function main_surface()
  return game.get_surface("nauvis") or game.get_surface(1)
end

-- Midnight (daytime 0.5) passed on the main surface since the last look.
trackers["nights"] = {
  poll = {every = 600, run = function(entries, core)
    local surface = main_surface()
    if not surface or surface.always_day then return end
    local world = core.world()
    local now, last = surface.daytime, world.last_daytime
    world.last_daytime = now
    if not last then return end
    local passed = (last < 0.5 and now >= 0.5) or (now < last and (last < 0.5 or now >= 0.5))
    if passed then
      local total = add(world, "nights")
      each(entries, function(entry) core.progress("world", entry, total) end)
    end
  end},
}

trackers["evolution"] = {
  poll = {every = MINUTE, run = function(entries, core)
    local enemy, surface = game.forces.enemy, main_surface()
    if not (enemy and surface) then return end
    local percent = enemy.get_evolution_factor(surface) * 100
    each(entries, function(entry) core.progress("world", entry, percent) end)
  end},
}

trackers["night-build"] = {
  events = {
    on_built_entity = function(event, entries, core)
      local entity = event.entity
      if not entity.valid or entity.type == "entity-ghost" or entity.type == "tile-ghost" then return end
      local surface = entity.surface
      if surface.always_day then return end
      local time = surface.daytime
      if time <= surface.evening or time >= surface.morning then return end
      local player = player_of(event)
      if not player then return end
      local total = add(core.player_data(player.index), "night_builds")
      each(entries, function(entry) core.progress(player, entry, total) end)
    end,
  },
}

---------------------------------------------------------------------------------------------------
-- Ruins of AbandonedRuins-paranoidal: number of different ruins found by the force.

trackers["ruins"] = {
  poll = {every = MINUTE, run = function(entries, core)
    if not has_remote("AbandonedRuins-paranoidal", "get_stats") then return end
    local ok, stats = pcall(remote.call, "AbandonedRuins-paranoidal", "get_stats")
    if not ok or type(stats) ~= "table" or type(stats.found) ~= "table" then return end
    local total = 0
    for _, count in pairs(stats.types or {}) do total = total + (tonumber(count) or 0) end
    for _, force in ipairs(core.player_forces()) do
      local found = tonumber(stats.found[force.index]) or 0
      for _, entry in ipairs(entries) do
        if entry.params.all then
          if total > 0 and found >= total then core.unlock(force, entry) end
        else
          core.progress(force, entry, found)
        end
      end
    end
  end},
}

---------------------------------------------------------------------------------------------------
-- Rockets

local function silo_force(event)
  local silo = event.rocket_silo
  if silo and silo.valid then return silo.force end
  if event.rocket and event.rocket.valid then return event.rocket.force end
end

trackers["cargo"] = {
  events = {
    on_rocket_launch_ordered = function(event, entries, core)
      local rocket = event.rocket
      local pod = rocket and rocket.valid and rocket.attached_cargo_pod
      if not (pod and pod.valid) then return end
      local inventory = pod.get_inventory(defines.inventory.cargo_unit)
      local force = silo_force(event)
      if not (inventory and force) then return end
      for _, entry in ipairs(entries) do
        for _, item in ipairs(entry.params.items) do
          if prototypes.item[item] and inventory.get_item_count(item) > 0 then
            core.unlock(force, entry)
            break
          end
        end
      end
    end,
  },
}

trackers["launches"] = {
  events = {
    on_rocket_launched = function(event, entries, core)
      local force = silo_force(event)
      if not force then return end
      local own = add(core.force_data(force.index), "launches")
      local total = math.max(own, force.rockets_launched)
      each(entries, function(entry) core.progress(force, entry, total) end)
    end,
  },
}

trackers["launch-rate"] = {
  events = {
    on_rocket_launched = function(event, entries, core)
      local force = silo_force(event)
      if not force then return end
      local data = core.force_data(force.index)
      local recent = {}
      for _, tick in ipairs(data.launch_ticks or {}) do
        if tick > event.tick - 216000 then table.insert(recent, tick) end
      end
      table.insert(recent, event.tick)
      data.launch_ticks = recent
      each(entries, function(entry) core.progress(force, entry, #recent) end)
    end,
  },
}

-- Players of the launching force whose deaths are counted from the start and who never died.
trackers["immortal"] = {
  events = {
    on_rocket_launched = function(event, entries, core)
      local force = silo_force(event)
      if not force then return end
      for _, player in pairs(force.players) do
        local data = core.player_data(player.index)
        if data.deaths_known and (data.deaths or 0) == 0 then
          each(entries, function(entry) core.unlock(player, entry) end)
        end
      end
    end,
  },
}

trackers["silo-lost"] = {
  events = {
    on_entity_died = function(event, entries, core)
      local entity = event.entity
      if entity.valid and entity.type == "rocket-silo" and #entity.force.players > 0 then
        each(entries, function(entry) core.unlock(entity.force, entry) end)
      end
    end,
  },
  filters = {on_entity_died = function() return {{filter = "type", type = "rocket-silo"}} end},
}

---------------------------------------------------------------------------------------------------
-- Deaths (the counter itself is kept by control.lua for every player)

trackers["deaths"] = {
  events = {
    on_pre_player_died = function(event, entries, core)
      local player = player_of(event)
      if not player then return end
      local deaths = core.player_data(player.index).deaths or 0
      each(entries, function(entry) core.progress(player, entry, deaths) end)
    end,
  },
}

trackers["deja-vu"] = {
  events = {
    on_pre_player_died = function(event, entries, core)
      local player = player_of(event)
      if not player then return end
      local data = core.player_data(player.index)
      local position, surface = player.position, player.surface_index
      local last = data.last_death
      if last and last.surface == surface then
        local dx, dy = position.x - last.x, position.y - last.y
        if dx * dx + dy * dy <= 25 then each(entries, function(entry) core.unlock(player, entry) end) end
      end
      data.last_death = {x = position.x, y = position.y, surface = surface}
    end,
  },
}

trackers["own-goal"] = {
  events = {
    on_pre_player_died = function(event, entries, core)
      local player = player_of(event)
      local cause, character = event.cause, player and player.character
      if cause and cause.valid and character and character.valid and cause == character then
        each(entries, function(entry) core.unlock(player, entry) end)
      end
    end,
  },
}

trackers["car-death"] = {
  events = {
    on_pre_player_died = function(event, entries, core)
      local player = player_of(event)
      local cause = event.cause
      if player and cause and cause.valid and cause.type == "car" then
        each(entries, function(entry) core.unlock(player, entry) end)
      end
    end,
  },
}

---------------------------------------------------------------------------------------------------
-- Research

trackers["infinite-research"] = {
  events = {
    on_research_finished = function(event, entries, core)
      local research = event.research
      if not (research and research.valid) or research.prototype.max_level < 4294967295 then return end
      local finished = research.researched and research.level or research.level - 1
      each(entries, function(entry) core.progress(research.force, entry, finished) end)
    end,
  },
}

---------------------------------------------------------------------------------------------------
-- PM RPG System: custom events from its remote interface "RPG".

trackers["rpg-level"] = {
  custom = function()
    if not has_remote("RPG", "get_on_player_level_up") then return nil end
    return {[remote.call("RPG", "get_on_player_level_up")] = function(event, entries, core)
      local player, level = player_of(event), tonumber(event.player_level)
      if player and level then each(entries, function(entry) core.progress(player, entry, level) end) end
    end}
  end,
}

trackers["rpg-attribute"] = {
  custom = function()
    if not has_remote("RPG", "get_on_player_updated_status") then return nil end
    return {[remote.call("RPG", "get_on_player_updated_status")] = function(event, entries, core)
      local player = player_of(event)
      if not (player and type(event.attribute) == "string") then return end
      local data = core.player_data(player.index)
      data.rpg_attributes = data.rpg_attributes or {}
      local total = add(data.rpg_attributes, event.attribute)
      each(entries, function(entry) core.progress(player, entry, total) end)
    end}
  end,
}

---------------------------------------------------------------------------------------------------
-- Small actions of players and other mods

trackers["rename"] = {
  events = {
    on_entity_renamed = function(event, entries, core)
      local player = player_of(event)
      if not player then return end
      local total = add(core.player_data(player.index), "renames")
      each(entries, function(entry) core.progress(player, entry, total) end)
    end,
  },
}

trackers["paint"] = {
  events = {
    on_entity_color_changed = function(event, entries, core)
      local entity = event.entity
      if not (entity.valid and ROLLING_STOCK[entity.type]) then return end
      local total = add(core.force_data(entity.force.index), "paints")
      each(entries, function(entry) core.progress(entity.force, entry, total) end)
    end,
  },
}

trackers["belt-reverse"] = {
  inputs = {
    ["ReverseEntireBelt"] = function(event, entries, core)
      local player = player_of(event)
      local selected = player and player.selected
      if not (selected and selected.valid and BELT_TYPES[selected.type]) then return end
      local total = add(core.player_data(player.index), "reverses")
      each(entries, function(entry) core.progress(player, entry, total) end)
    end,
  },
}

trackers["chunks"] = {
  events = {
    on_chunk_deleted = function(event, entries, core)
      local total = add(core.world(), "deleted_chunks", #event.positions)
      each(entries, function(entry) core.progress("world", entry, total) end)
    end,
  },
}

-- Drills marked for deconstruction by a script (AutoDeconstruct) rather than by a player.
trackers["auto-deconstruct"] = {
  events = {
    on_marked_for_deconstruction = function(event, entries, core)
      local entity = event.entity
      if event.player_index or not entity.valid or entity.type ~= "mining-drill" then return end
      local total = add(core.force_data(entity.force.index), "auto_deconstructed")
      each(entries, function(entry) core.progress(entity.force, entry, total) end)
    end,
  },
  filters = {on_marked_for_deconstruction = function() return {{filter = "type", type = "mining-drill"}} end},
}

-- The "unstuck" button of TimedSpawnControl.
trackers["unstuck"] = {
  events = {
    on_gui_click = function(event, entries, core)
      local element = event.element
      if not (element and element.valid and element.name == "unstuck") then return end
      if element.get_mod() ~= "TimedSpawnControl" then return end
      local player = player_of(event)
      each(entries, function(entry) core.unlock(player, entry) end)
    end,
  },
}

---------------------------------------------------------------------------------------------------
-- Big Monsters bosses: one of each kind killed by the force.

local BOSS_KINDS = {
  {"^biterzilla%d+$", "biterzilla"},
  {"^bm%-motherbiterzilla%d+$", "mother"},
  {"^bm%-volcano$", "volcano"},
  {"^bm%-worm%-boss", "worm"},
  {"^bm_fake_human_boss_", "human"},
}

local boss_kind_of, boss_kinds_total
local function boss_names()
  boss_kind_of, boss_kinds_total = {}, 0
  local names = {}
  for _, kind in ipairs(BOSS_KINDS) do
    local list = entity_names({patterns = {kind[1]}})
    if #list > 0 then boss_kinds_total = boss_kinds_total + 1 end
    for _, name in ipairs(list) do
      boss_kind_of[name] = kind[2]
      table.insert(names, name)
    end
  end
  return names
end

trackers["bosses"] = {
  prepare = function()
    if #boss_names() == 0 then return false end
  end,
  events = {
    on_entity_died = function(event, entries, core)
      local kind = event.entity.valid and boss_kind_of[event.entity.name]
      local force = event.force
      if not (kind and force and force.valid) or #force.players == 0 then return end
      local data = core.force_data(force.index)
      data.bosses = data.bosses or {}
      if data.bosses[kind] then return end
      data.bosses[kind] = true
      local killed = 0
      for _ in pairs(data.bosses) do killed = killed + 1 end
      if killed >= boss_kinds_total then each(entries, function(entry) core.unlock(force, entry) end) end
    end,
  },
  filters = {on_entity_died = function() return name_filters(boss_names()) end},
}

return trackers
