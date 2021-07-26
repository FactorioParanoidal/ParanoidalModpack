Event = require('scripts/event')

min_attrition_rate = 0.0011
tickskip = 10

function is_system_force(force_name)
  return force_name == "enemy"
    or force_name == "neutral"
    or force_name == "capture"
    or force_name == "conquest"
    or force_name == "ignore"
    or force_name == "friendly"
end

function get_attrition_rate_for_surface(surface_index)
  -- use cache
  if global.suface_attrition_rates[surface_index] then
    return global.suface_attrition_rates[surface_index]
  end
  -- or load
  local rate = nil
  local default_rate = settings.global["robot-attrition-factor"].value
  for interface, functions in pairs(remote.interfaces) do
    if functions["robot_attrition_for_surface"] then
      local returned_rate = remote.call(interface, "robot_attrition_for_surface", {default_rate = default_rate, surface_index = surface_index})
      if rate == nil or returned_rate > rate then
        rate = returned_rate
      end
    end
  end
  if rate == nil then
    rate = default_rate
  end
  global.suface_attrition_rates[surface_index] = rate
  --game.print("Robot attrition rate for surface " .. surface_index .. " ("..game.surfaces[surface_index].name..") is " .. rate)

  return rate
end

function get_crash_item(bot)
  if global.crash_items[bot.name] then
    if global.crash_items[bot.name] ~= "none" then
      return global.crash_items[bot.name]
    else
      return nil
    end
  else
    if bot.prototype.mineable_properties.products and bot.prototype.mineable_properties.products[1] then
      local name = bot.prototype.mineable_properties.products[1].name.."-crashed"
      if game.item_prototypes[name] then
        global.crash_items[bot.name] = name
        return name
      end
    end
  end
  global.crash_items[bot.name] = "none"
end

function get_bot_speed(name)
  if not global.bot_speed then global.bot_speed = {} end
  if not global.bot_speed[name] then
    global.bot_speed[name] = game.entity_prototypes[name].speed
  end
  return global.bot_speed[name]
end

function get_bot_slow_speed_multiplier(name)
  if not global.bot_slow_speed_multiplier then global.bot_slow_speed_multiplier = {} end
  if not global.bot_slow_speed_multiplier[name] then
    global.bot_slow_speed_multiplier[name] = game.entity_prototypes[name].speed_multiplier_when_out_of_energy
  end
  return global.bot_slow_speed_multiplier[name]
end

function bot_crash(bot, n_bots)
  local inventory = bot.get_inventory(defines.inventory.robot_cargo)
  local contents = inventory.get_contents()
  --[[if global.robot_repair_setting == "Repair75" then
    local item = get_crash_item(bot)
    if item then
      bot.surface.spill_item_stack(bot.position, {name=item, count=1}, false, bot.force, false) --Spill, mark for decon, disallow belts
    end
  end]]
  for name, count in pairs(contents) do
    --bot.surface.spill_item_stack(bot.position, {name=name, count=count}, false, bot.force, false) --Spill, mark for decon, disallow belts
    local drop = bot.surface.create_entity{
      name = "logistic-robot-dropped-cargo",
      position = {x = bot.position.x, y = bot.position.y + 1},
      force = bot.force
    }
    drop.insert({name=name, count=count})
    drop.order_deconstruction(bot.force)
  end
  bot.get_inventory(defines.inventory.robot_cargo).clear()
  bot.force.kill_count_statistics.on_flow(bot.name, -1) --Track bot's death.
  if global.forcedata and global.forcedata[bot.force.name] and global.forcedata[bot.force.name]["robot-attrition-explosion-safety"]
    and n_bots <= 500 * global.forcedata[bot.force.name]["robot-attrition-explosion-safety"] then
      --game.print("Skip explosion, n_bots "..n_bots.."<= ".. 500 * global.forcedata[bot.force.name]["robot-attrition-explosion-safety"])
  else
    bot.surface.create_entity{name = "robot-explosion", position=bot.position}
  end
  if bot.valid then
    bot.force = "neutral" -- change force so that it does not cause death alerts
    bot.die()
  end
  global.bots_crashed = (global.bots_crashed or 0) + 1 -- used as an achievement metric

end

function process_bot(bot, n_bots)
    local force_speed_multiplier = 1 + bot.force.worker_robots_speed_modifier
    local speed = get_bot_speed(bot.name) * force_speed_multiplier
    local held_item_count = 0
    if bot.energy > 0 then
      local inventory = bot.get_inventory(defines.inventory.robot_cargo)
      held_item_count = inventory.get_item_count()
    else
      speed = 0.5 * speed * get_bot_slow_speed_multiplier(bot.name)
    end
    local speed_items = speed * (held_item_count + 0.5) -- carrying itself counts as 0.5 items
    local crash_score = speed_items
    bot_crash(bot, n_bots)
    return crash_score
end

function on_tick(event)
  --[[
  slowest funtions is by far: network.logistic_robots[i]
  so only do that once per explosion.
  which means that if a robot is selected it must die.
  but risk factors should still be speed * items carried
  so add these factors to the probability of the next selection round
  factors apply multiplier to next selection phase
  ]]--
  if not global.force_surfaces then return end
  if game.tick % tickskip ~= 0 then return end

  --game.forces[force].logistic_networks[network].logistic_robots :: array of LuaEntity
  --for _, force in pairs(game.forces) do
  for force_name, force_surfaces in pairs(global.force_surfaces) do
    local force = game.forces[force_name]
    if not force then
      global.force_surfaces[force_name] = nil
    else
      local i = randint
      --for surface_name, networks in pairs(force.logistic_networks) do
      local force_logistic_networks = force.logistic_networks -- array of surface_name, networks
      for surface_name, _ in pairs(force_surfaces) do
        local surface = game.surfaces[surface_name]
        if not surface then
          force_surfaces[surface_name] = nil
        else
          local networks = force_logistic_networks[surface_name]
          if networks then
            local surface_attrition_rate = get_attrition_rate_for_surface(game.surfaces[surface_name].index)
            if surface_attrition_rate > min_attrition_rate then
              for _, network in pairs(networks) do
                local n_bots = network.all_logistic_robots - network.available_logistic_robots
                if n_bots > 50 then -- ignore small networks
                  if not global.forces[force.name] then global.forces[force.name] = {} end
                  if not global.forces[force.name][surface_name] then global.forces[force.name][surface_name] = { crash = 0, crash_rate = 0.1 } end
                  local crash_rate = global.forces[force.name][surface_name].crash_rate * tickskip * surface_attrition_rate / 1000000
                  local crash = global.forces[force.name][surface_name].crash + crash_rate * n_bots
                  if crash >= 1 then
                    local logistic_robots = network.logistic_robots
                    local to_crash = math.min(math.ceil(#logistic_robots/2), 1 + math.random(math.floor(crash))) -- don't crash all
                    local i = math.random(#logistic_robots) -- choose a starting bot
                    local crashed = 0
                    while crashed < to_crash do
                      -- then step through bots
                      i = (i % #logistic_robots) + 1
                      if logistic_robots[i] and logistic_robots[i].valid then
                        global.forces[force.name][surface_name].crash_rate = global.forces[force.name][surface_name].crash_rate * 0.9 + 0.1 * process_bot(logistic_robots[i], n_bots)
                      end -- if invalid bots were found just skip them anyway
                      crashed = crashed + 1
                    end
                    crash = crash - crashed
                  end
                  global.forces[force.name][surface_name].crash = crash
                end
              end
            end
          end
        end
      end
    end
  end
end

function on_init(event)
  global.forces = {}
  global.bot_speed = {}
  global.bot_slow_speed_multiplier = {}
  global.suface_attrition_rates = {}

  global.robot_repair_setting = settings.startup["robot-attrition-repair"].value
  global.crash_items = {}
end

function on_configuration_changed(event)
  global.forces = {}
  global.bot_speed = {}
  global.bot_slow_speed_multiplier = {}
  global.suface_attrition_rates = {} -- clear
  if not global.force_surfaces then
    for _, force in pairs(game.forces) do
      if not is_system_force(force.name) then
        for surface_name, networks in pairs(force.logistic_networks) do
          for _, network in pairs(networks) do
            if network.all_logistic_robots > 0 then
              add_surface(force, game.surfaces[surface_name])
            end
          end
        end
      end
    end
  end

  global.robot_repair_setting = settings.startup["robot-attrition-repair"].value
  global.crash_items = {}

end
function on_runtime_mod_setting_changed(event)
  if event.setting == "robot-attrition-factor" then
    global.suface_attrition_rates = {} -- clear
  end
end


-- Surface Gathering
function add_surface(force, surface)
  if not is_system_force(force.name) then
    if #force.players > 0 then
      global.force_surfaces = global.force_surfaces or {}
      global.force_surfaces[force.name] = global.force_surfaces[force.name] or {}
      if not global.force_surfaces[force.name][surface.name] then
        global.force_surfaces[force.name][surface.name] = game.tick
      end
    end
  end
end

function on_built_roboport(event)
  if not(event.created_entity and event.created_entity.valid) then return end
  add_surface(event.created_entity.force, event.created_entity.surface)
end
function on_cloned_roboport(event)
  if not(event.destination  and event.destination.valid) then return end
  add_surface(event.destination.force, event.destination.surface)
end
function on_script_built_roboport(event)
  if not(event.entity and event.entity.valid) then return end
  add_surface(event.entity.force, event.entity.surface)
end
script.on_event(defines.events.on_built_entity, on_built_roboport, {{filter = "type", type = "roboport"}})
script.on_event(defines.events.on_robot_built_entity, on_built_roboport, {{filter = "type", type = "roboport"}})
script.on_event(defines.events.on_entity_cloned, on_cloned_roboport, {{filter = "type", type = "roboport"}})
script.on_event(defines.events.script_raised_built, on_script_built_roboport, {{filter = "type", type = "roboport"}})
script.on_event(defines.events.script_raised_revive, on_script_built_roboport, {{filter = "type", type = "roboport"}})

-- if a bot corpse appears on a force's surface then order deconstruction
function on_trigger_created_entity(event)
  if not event.entity and event.entity.valid then return end
  if event.entity.type == "simple-entity" then
    if string.find(event.entity.name, "remnants", 1, true) then
      if global.force_surfaces then
        for force_name, surfaces in pairs(global.force_surfaces) do
          if surfaces[event.entity.surface.name] then
            event.entity.order_deconstruction(force_name)
          end
        end
      end
    end
  end
end
Event.addListener(defines.events.on_trigger_created_entity, on_trigger_created_entity)

-- Swarm safety
function on_research_finished(event)
  local force = event.research.force
  if event.research.name == "robot-attrition-explosion-safety" then
    global.forcedata = global.forcedata or {}
    global.forcedata[force.name] = global.forcedata[force.name] or {}
    global.forcedata[force.name]["robot-attrition-explosion-safety"] = event.research.level - 1
  end
end

Event.addListener(defines.events.on_research_finished, on_research_finished)

-- standard events
Event.addListener(defines.events.on_tick, on_tick)
Event.addListener(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)

Event.addListener("on_init", on_init, true)
Event.addListener("on_configuration_changed", on_configuration_changed, true)
