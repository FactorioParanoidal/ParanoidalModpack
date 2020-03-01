local charging_station_types =
{
  ["wireless-charging-lo-power-induction-station"] = true,
  ["wireless-charging-hi-power-induction-station"] = true,
}
local charging_rail_types =
{
  ["wireless-charging-lo-power-induction-rail"] =
  {
    name = "wireless-charging-lo-power-induction-rail",
    interface_name = "lo-power-induction-rail-interface",
  },
  ["wireless-charging-hi-power-induction-rail"] =
  {
    name = "wireless-charging-hi-power-induction-rail",
    interface_name = "hi-power-induction-rail-interface",
  },
}
local rail_accumulator_types =
{
  ["wireless-charging-lo-power-induction-rail" .. "-horizontal"] = true,
  ["wireless-charging-hi-power-induction-rail" .. "-horizontal"] = true,
  ["wireless-charging-lo-power-induction-rail" .. "-vertical"] = true,
  ["wireless-charging-hi-power-induction-rail" .. "-vertical"] = true,
}

local check_rail_placement
local indicator_tick
local on_accumulator_mined
local on_charging_entity_removed
local on_charging_rail_built
local on_charging_station_built
local on_entity_created
local on_entity_removed
local on_rail_accumulator_killed

-- Charging indicators
-------------------------------------------------------------------------------

function on_charging_started(event)
  if(event.grid and event.grid.valid) then
    local charging_accumulator_grids = global.charging_accumulator_grids
    local accumulators = global.accumulators
    for i, entity in pairs(event.charging_entities) do
      local unit = entity.unit_number
      local accumulator = accumulators[unit]
      if(accumulator) then
        charging_accumulator_grids[unit] = event.grid
      end
    end
  --  script.on_event(defines.events.on_tick, on_tick)
  end
end

function on_charging_stopped(event)
  local charging_accumulator_grids = global.charging_accumulator_grids
  local accumulators = global.accumulators
  local indicators = global.indicators
  for i, entity in pairs(event.charging_entities) do
    local unit = entity.unit_number
    charging_accumulator_grids[unit] = nil
    local accumulator = accumulators[unit]
    if(accumulator) then
      if (accumulator.valid) then
        accumulator.energy = 0
      end
      local indicator = indicators[unit]
      if(indicator) then
          if(indicator.valid) then
            indicator.fluidbox[1] = nil
          end
      end
    end
  end
  if(next(charging_accumulator_grids) == nil) then
   -- script.on_event(defines.events.on_tick, nil)
  end
end

indicator_tick = function()
  local accumulators = global.accumulators
  local indicators = global.indicators
  for unit, grid in pairs(global.charging_accumulator_grids) do
    if(grid.valid) then
      local accumulator = accumulators[unit]
      local indicator = indicators[unit]
      local capacity = grid.battery_capacity
      local ratio = capacity <= 0 and 0 or grid.available_in_batteries / capacity
      if(accumulator.valid) then
        local accumulator_capacity = accumulator.electric_buffer_size;
        accumulator.energy = ratio * accumulator_capacity;
      end
      if(indicator.valid) then
        if(ratio <= 0) then
          indicator.fluidbox[1] = nil;
        else
          local fluidbox_capacity = indicator.fluidbox.get_capacity(1);
          indicator.fluidbox[1] = {name = "lubricant" , amount = ratio * fluidbox_capacity }
        end
      end
    end
  end
end

-- Entity management
-------------------------------------------------------------------------------

on_charging_station_built = function(entity)
  local unit = entity.unit_number
  global.accumulators[unit] = entity
  
  local indicator = entity.surface.create_entity({
    name = "wireless-charging-induction-station-indicator",
    position = {entity.position.x + -1.09375, entity.position.y + 1.71875},
    force = entity.force,
  })
  indicator.operable = false
  indicator.destructible = false
  global.indicators[unit] = indicator
end

on_charging_rail_built = function(entity, data)
  local position = entity.position
  local direction = entity.direction
  local force = entity.force
  local surface = entity.surface
  local accumulator_name
  local indicator_x
  local indicator_y
  if(direction == defines.direction.north or direction == defines.direction.south) then
    accumulator_name = entity.name .. "-vertical"
    indicator_x = 0.7503
    indicator_y = 0.46875
  else
    accumulator_name = entity.name .. "-horizontal"
    indicator_x = 0.3128
    indicator_y = 0.46875
  end
  local accumulator = surface.create_entity{
    name = accumulator_name,
    position = position,
    force = force,
  }
  global.accumulators[entity.unit_number] = accumulator
  
  local indicator = entity.surface.create_entity({
    name = "wireless-charging-induction-station-indicator",
    position = {entity.position.x + indicator_x, entity.position.y + indicator_y},
    force = entity.force,
  })
  indicator.operable = false
  indicator.destructible = false
  entity.destructible = false
  global.indicators[entity.unit_number] = indicator
  
  global.rails[accumulator.unit_number] = entity
  remote.call("wireless-charging-lib", "place-inductor", entity, charging_rail_types[entity.name])
end

on_charging_entity_removed = function(entity)
  -- This is never called for rail accumulators
  local unit = entity.unit_number
  local rail = global.rails[unit]
  if(rail) then
    unit = rail.unit_number
    remote.call("wireless-charging-lib", "remove-inductor", rail)
  end
  local accumulator = global.accumulators[unit]
  if(accumulator and accumulator ~= entity) then
    accumulator.destroy()
  end
  local indicator = global.indicators[unit]
  if(indicator) then
    indicator.destroy()
  end
  global.charging_accumulator_grids[unit] = nil
  global.indicators[unit] = nil
  global.accumulators[unit] = nil
  global.rails[unit] = nil
end

on_accumulator_mined = function(entity)
  -- Only players can pick up accumulators, robots always target the rail.
  local unit = entity.unit_number
  local rail = global.rails[unit]
  if(rail == nil) then
    return -- leftover non existing rail, ignore
  end

  unit = rail.unit_number
  -- If the rail cannot be destroyed then a train is still standing on it and we have to restore the accumulator.
  remote.call("wireless-charging-lib", "remove-inductor", rail)
  if(not rail.destroy()) then
    local accumulator_name = entity.name
    local position = entity.position
    local force = entity.force
    local accumulator_unit = entity.unit_number
    entity.destroy() -- this cancels the player mining action (robots won't mine the rail with a train on it) and allows us to replace the accumulator as if nothing happened
    local accumulator = rail.surface.create_entity{
      name = accumulator_name,
      position = position,
      force = force,
    }
    global.accumulators[unit] = accumulator
    global.rails[accumulator_unit] = nil
    global.rails[accumulator.unit_number] = rail
    remote.call("wireless-charging-lib", "place-inductor", rail, charging_rail_types[rail.name])
  else
    local indicator = global.indicators[unit]
    if(indicator) then
      indicator.destroy()
    end
    global.charging_accumulator_grids[unit] = nil
    global.indicators[unit] = nil
    global.accumulators[unit] = nil
  end
end

on_rail_accumulator_killed = function(entity)
  -- Only the accumulator is destructible otherwise it cannot be targetted by players.
  -- In this case kill the rails manually to create the illusion they were attacking them the whole time.
  local unit = entity.unit_number
  local rail = global.rails[unit]
  unit = rail.unit_number
  local accumulator = global.accumulators[unit]
  if(accumulator and accumulator ~= entity) then
    accumulator.destroy()
  end
  local indicator = global.indicators[unit]
  if(indicator) then
    indicator.destroy()
  end
  global.charging_accumulator_grids[unit] = nil
  global.indicators[unit] = nil
  global.accumulators[unit] = nil
  rail.die()
end

check_rail_placement = function(entity, player_index)
  local name = entity.name
  local direction = entity.direction
  -- TODO: forbid overlapping
  if(name == "entity-ghost" and charging_rail_types[entity.ghost_name]) then
    -- No diagonal rails
    if(direction == defines.direction.northeast or
       direction == defines.direction.northwest or
       direction == defines.direction.southeast or
       direction == defines.direction.southwest) then
      entity.destroy()
      return false
    end
  else
    if(direction == defines.direction.northeast or
       direction == defines.direction.northwest or
       direction == defines.direction.southeast or
       direction == defines.direction.southwest) then
    -- Change the build rotation so the next placement is correct
      entity.destroy()
      local player = game.players[player_index]
      local cursor = player.cursor_stack
      local cursor_name = cursor.name
      local cursor_count = cursor.count
      local item_stack = {name = name, count = 1}
      cursor.set_stack{name = "rail", count = 1}
      player.rotate_for_build()
      cursor.clear()
      cursor.set_stack{name = cursor_name, count = cursor_count}
      player.insert{name = name, count = 1}
      return false
    end
  end
  return true
end

on_entity_created = function(entity, player_index)
  if(charging_station_types[entity.name]) then
    on_charging_station_built(entity)
  else
    local data = charging_rail_types[entity.name]
    if(data and check_rail_placement(entity, player_index)) then
      on_charging_rail_built(entity)
    end
  end
end

on_entity_removed = function(entity, killed)
  if(charging_station_types[entity.name] or charging_rail_types[entity.name]) then
    on_charging_entity_removed(entity, killed)
  end
end

-- Event entry points
-------------------------------------------------------------------------------

function on_built_entity(event)
  on_entity_created(event.created_entity, event.player_index)
end

function on_entity_died(event)
  if(rail_accumulator_types[event.entity.name]) then
    on_rail_accumulator_killed(event.entity)
  else
    on_entity_removed(event.entity)
  end
end

function on_robot_built_entity(event)
  on_entity_created(event.created_entity)
end

function on_pre_player_mined_item(event)
  if(rail_accumulator_types[event.entity.name]) then
    on_accumulator_mined(event.entity)
  else
    on_entity_removed(event.entity)
  end
end

function on_robot_pre_mined(event)
  on_entity_removed(event.entity)
end

function on_tick(event)
  indicator_tick()
end
