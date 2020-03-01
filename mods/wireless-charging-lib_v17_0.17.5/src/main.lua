local abs = math.abs
local floor = math.floor
local max = math.max
local min = math.min
local sort = table.sort

local chargable_types =
{
  ["locomotive"] = true,
  ["cargo-wagon"] = true, -- Even though cargo wagons can't drive they can hold induction plates to charge their equipment
  ["car"] = true,
  ["character"] = true,
}
local train_types =
{
  ["locomotive"] = true,
  ["cargo-wagon"] = true,
}
-- These need to be checked periodically because we don't get moving/stopped events
local tracked_types =
{
  ["car"] = true,
  ["character"] = true,
}
local search_radius =
{
  ["car"] = 1,
  ["locomotive"] = 3,
  ["cargo-wagon"] = 3,
  ["character"] = 0.5,
}

-- Local function prototypes
local cache_equipment
local check_character_armor
local tracking_tick
local charge_tick
local handle_train_state_change
local on_entity_removed
local on_inductor_placed
local on_inductor_removed
local on_train_removed
local read_equipment
local start_charging
local start_train_charging
local stop_charging
local stop_train_charging
local update_equipment

-- Table utils
-------------------------------------------------------------------------------

local function erase_first_from_array(tbl, v)
  for i = 1, #tbl do
    if(tbl[i] == v) then
      table.remove(tbl, i)
      return i
    end
  end
  return nil
end

-- Local caches
-------------------------------------------------------------------------------

-- Dictionary of only those vehicles that have inductors
-- [unit-number] = array of inductor indices
local inductors_for_unit = { }
-- Dictionary mapping energy interface indices to the unit being charged, if any.
-- [interface-index] = unit-number
local interface_to_unit = { }
-- Dictionary mapping energy interface unit numbers to charger entity unit number
-- [interface-index] = unit-number
local unit_to_interface = { }
-- Dictionary of entities which have induction plates installed and are periodically checked to be above chargers if stationary. This is needed since we don't get moving/stopped events for cars or characters, only trains.
-- [unit] = tick
local tracked_entities = { }

-- Remember entities which were invalid in on_load to remove in the first on_tick
local invalid_entities = { }

function rebuild_caches()
  inductors_for_unit = { }
  interface_to_unit = { }
  unit_to_interface = { }
  tracked_entities = { }
  invalid_entities = { }

  local initial_tick_offset = 2;
  local tick_offset = initial_tick_offset;
  local game_tick = game.tick;

  for unit, grid in pairs(global.grids) do
    local entity = global.entities[unit]
    if(entity.valid and grid.valid) then
      cache_equipment(unit, read_equipment(grid))
      if(tracked_types[entity.type] and inductors_for_unit[unit]) then
        tracked_entities[unit] = tick_offset
        tick_offset = tick_offset + 1;
        if(tick_offset > 60) then
          tick_offset = initial_tick_offset;
        end
      end
    else
      invalid_entities[#invalid_entities + 1] = unit
    end
  end
  for unit, chargers in pairs(global.charging_vehicles) do
    for i = 1, #chargers do
      interface_to_unit[chargers[i]] = unit
    end
  end
  for unit, interface in pairs(global.electric_interfaces) do
    unit_to_interface[interface.unit_number] = unit
  end
end

function validate_prototypes()
  -- Stop doing anything involving a no longer present prototype
  local equipment = game.equipment_prototypes
  local entities = game.entity_prototypes
  for tbl, exists in pairs{[global.induction_equipment] = equipment,
                           [global.induction_prototypes] = entities} do
    for name in pairs(tbl) do
      if(not exists[name]) then
        tbl[name] = nil
        global.automatically_placed_inductors[name] = nil
      end
    end
  end
end

-- Used in the first on_tick to remove an invalid vehicle.
local function remove_invalid_unit(unit)
  global.entities[unit] = nil
  global.grids[unit] = nil
  local chargers = global.charging_vehicles[unit]
  if(chargers) then
    for i = 1, #chargers do
      interface_to_unit[chargers[i]] = nil
    end
    global.charging_vehicles[unit] = nil
  end
  inductors_for_unit[unit] = nil
  unit_to_interface[unit] = nil
  tracked_entities[unit] = nil
  invalid_entities[unit] = nil
end

function validate_entities()
  -- Get rid of deleted chargers
  for unit, entity in pairs(global.induction_entities) do
    if(not entity.valid) then
      global.electric_interfaces[unit].destroy()
      global.electric_interfaces[unit] = nil
      global.induction_entities[unit] = nil
      local unit = interface_to_unit[i]
      local chargers = global.charging_vehicles[unit]
      if(chargers) then
        if(erase_first_from_array(chargers, i) and #chargers == 0) then
          global.charging_vehicles[unit] = nil
        end
        interface_to_unit[i] = nil
      end
    end
  end
  -- If any units were deleted stop processing them
  for unit, entity in pairs(global.entities) do
    local grid = global.grids[unit]
    if(not (entity.valid and grid and grid.valid)) then
      remove_invalid_unit(unit)
    else
      -- In case equipment was deleted
      update_equipment(unit, grid)
    end
  end
  -- Stop regeneration on deleted vehicles and trains
  for _, tbl in pairs{global.braking_vehicles, global.braking_trains} do
    for i, data in pairs(tbl) do
      if(not tbl[i][BRAKING_ENTITY].valid) then
        tbl[i] = nil
      end
    end
  end
end

-- Equipment handling
-------------------------------------------------------------------------------

read_equipment = function(grid)
  local equipment = grid.equipment
  local known_inductors = global.induction_equipment
  local inductors = { }
  for i = 1, #equipment do
    local item = equipment[i]
    if(known_inductors[item.name] and item.prototype.energy_source) then
      inductors[#inductors + 1] = i
    end
  end
  sort(inductors, function(a, b) return equipment[a].prototype.energy_source.output_flow_limit >
                                        equipment[b].prototype.energy_source.output_flow_limit end)
  return inductors
end

cache_equipment = function(unit, inductors)
  inductors_for_unit[unit] = #inductors > 0 and inductors or nil
end

function update_equipment(unit, grid)
  local inductors = read_equipment(grid)
  
  local entity = global.entities[unit]
  if(not entity.valid) then
    return;
  end
  cache_equipment(unit, inductors)

  local tick_offset = 5;

  if(#inductors > 0) then
    if(train_types[entity.type]) then
      handle_train_state_change(entity.train)
    else
      tracked_entities[unit] = (tracked_entities[unit] or (tick_offset))
    end
  else
    tracked_entities[unit] = nil
    stop_charging(entity, unit)
  end
end

check_character_armor = function(character_index)
  local character = game.characters[character_index]
  if(character.connected) then
    local entity = character.character
    if(entity) then
      local item = character.get_inventory(defines.inventory.character_armor)[1]
      local grid = item.valid_for_read and item.grid
      if(grid) then
        local unit = entity.unit_number
        global.entities[unit] = entity
        global.grids[unit] = grid
        update_equipment(unit, grid)
      else
        on_entity_removed(entity)
      end
    end
  end
end

-- on_tick actions
-------------------------------------------------------------------------------

charge_tick = function()
  local grids = global.grids
  local electric_interfaces = global.electric_interfaces
  for unit, chargers in pairs(global.charging_vehicles) do
    local inductors = inductors_for_unit[unit]
    local grid = grids[unit]
    if(grid.valid) then
      local equipment = grid.equipment
      for i = 1, #chargers do
        local charger = electric_interfaces[chargers[i]]
        local inductor = equipment[inductors[i]]
        local inductor_energy = inductor.energy
        local charger_energy = charger.energy
        local transfer = min(inductor.max_energy - inductor_energy, charger_energy)
        inductor.energy = inductor_energy + transfer
        charger.energy = charger_energy - transfer
      end
    else
      stop_charging(global.entities[unit], unit)
      global.entities[unit] = nil
      global.grids[unit] = nil
      inductors_for_unit[unit] = nil
      tracked_entities[unit] = nil
    end
  end
end

tracking_tick = function()
  local game_tick = game.tick
  local entities = global.entities
  for unit, tick in pairs(tracked_entities) do
    local entity = entities[unit]
    if(entity.valid) then
      if(game_tick % tick == 0) then
        start_charging(entity)
        --tracked_entities[unit] = tick + 30
      end
    else
      stop_charging(entity, unit)
      global.entities[unit] = nil
      global.grids[unit] = nil
      inductors_for_unit[unit] = nil
      tracked_entities[unit] = nil
   end
  end
end

-- Charging
-------------------------------------------------------------------------------

start_charging = function(entity)
  local unit = entity.unit_number
  local inductors = inductors_for_unit[unit]
  local induction_entities = global.induction_entities
  if(inductors) then
    local bb = entity.bounding_box
    -- Clear existing chargers in case entity has moved away
    local previous = global.charging_vehicles[unit] or { }
    if(tracked_types[entity.type]) then
      for i = 1, #previous do
        local interface_index = previous[i]
        if(interface_to_unit[interface_index] == unit) then
          interface_to_unit[interface_index] = nil
        end
      end
      -- Allow to charge only if stationary
      if(entity.type == "car" and entity.speed ~= 0) then
        stop_charging(entity)
        return
      end
    end
    -- TODO: The bounding box for trains is pretty weird. It seems it is reported in the vertical direction. So the bounding box always covers a vertical area, penalizing horizontally parked trains. To bypass this we do a two-phase search. First a broad search in a wider radius and then the reverse reverse if the entity is at the position of each found interface. This seems more accurate as the game appears to use the oriented bounding boxes in find_entity().
    local position = entity.position
    local radius = search_radius[entity.type]
    local candidates = entity.surface.find_entities_filtered({
      type = "electric-energy-interface",
      area = {{position.x - radius, position.y - radius},
              {position.x + radius, position.y + radius}},
    })
    for i = 1, #candidates do
      if(not unit_to_interface[candidates[i].unit_number]) then 
        candidates[i] = nil
      end
    end
    local entities = { }
    -- Skip the narrow phase for characters because they have such a tiny collision box
    if(entity.type == "character") then
      for i, candidate in pairs(candidates) do
        entities[#entities + 1] = candidate
      end
    else
      for i, candidate in pairs(candidates) do
        if(entity.surface.find_entity(entity.name, candidate.position) == entity) then
          entities[#entities + 1] = candidate
        end
      end
    end
    
    -- Each  inductor on the ground can charge only one inductor in the vehicle.
    -- Both are sorted by descending input/output flow limits in order to transfer as much as possible.
    sort(entities, function(a, b) return a.electric_input_flow_limit > b.electric_input_flow_limit end)
    local chargers = { }
    local charging_entities = { }
    for i = 1, min(#entities, #inductors) do
      local interface_index = unit_to_interface[entities[i].unit_number]
      if(interface_index and (interface_to_unit[interface_index] == nil or interface_to_unit[interface_index] == unit)) then
        chargers[#chargers + 1] = interface_index
        charging_entities[#charging_entities + 1] = induction_entities[interface_index]
        interface_to_unit[interface_index] = unit
        erase_first_from_array(previous, interface_index)
      end
    end
    -- If any chargers are left that weren't there before notify about them no longer charging
    for i = 1, #previous do
      previous[i] = induction_entities[previous[i]]
    end
    if(#previous > 0) then
      script.raise_event(events.on_charging_stopped, {
        entity = entity,
        grid = global.grids[unit],
        charging_entities = previous,
      })
    end
    if(#chargers > 0) then
      global.charging_vehicles[unit] = chargers
      --
      script.raise_event(events.on_charging_started, {
        entity = entity,
        grid = global.grids[unit],
        charging_entities = charging_entities,
      })
    elseif(global.charging_vehicles[unit]) then
      stop_charging(entity)
    end
  end
end

stop_charging = function(entity, unit)
  unit = unit or entity.unit_number
  local chargers = global.charging_vehicles[unit]
  local induction_entities = global.induction_entities
  if(chargers) then
    local entities = { }
    for i = 1, #chargers do
      interface_to_unit[chargers[i]] = nil
      entities[i] = induction_entities[chargers[i]]
    end
    global.charging_vehicles[unit] = nil
    --
    script.raise_event(events.on_charging_stopped, {
      entity = entity,
      grid = global.grids[unit],
      charging_entities = entities,
    })
  end
end

-- Train specific
-------------------------------------------------------------------------------

start_train_charging = function(train)
  local carriages = train.carriages
  for i = 1, #carriages do
    start_charging(carriages[i])
  end
end

stop_train_charging = function(train)
  local carriages = train.carriages
  for i = 1, #carriages do
    stop_charging(carriages[i])
  end
end

handle_train_state_change = function(train)
  local state = train.state
  local stationary = state == defines.train_state.wait_signal or
                     state == defines.train_state.wait_station or
                     state == defines.train_state.no_path or
                     state == defines.train_state.no_schedule or
                     (state == defines.train_state.manual_control and train.speed == 0)
  if(stationary) then
    start_train_charging(train)
  else
    stop_train_charging(train)
  end
end

-- Entity management
-------------------------------------------------------------------------------

on_inductor_placed = function(entity, data)
  local unit = entity.unit_number
  local grids = global.grids
  if(unit) then
    local interface = entity.surface.create_entity({
      name = data[2],
      position = {entity.position.x + data[3], entity.position.y + data[4]},
      force = entity.force,
    })
    interface.operable = false
    interface.destructible = false
    interface.minable = false
    unit_to_interface[interface.unit_number] = unit
    global.induction_entities[unit] = entity
    global.electric_interfaces[unit] = interface
    
    
    local entities = entity.surface.find_entities_filtered{position = entity.position}
    for i = 1, #entities do
      local vehicle_unit = entities[i].unit_number
      if(vehicle_unit and grids[vehicle_unit]) then
        update_equipment(vehicle_unit, grids[vehicle_unit])
        break
      end
    end
  end
end

on_inductor_removed = function(entity)
  local unit = entity.unit_number
  local induction_entities = global.induction_entities
  if(unit) then
    induction_entities[unit] = nil
    local vehicle_unit = interface_to_unit[unit]
    if(vehicle_unit) then
      interface_to_unit[unit] = nil
      unit_to_interface[global.electric_interfaces[unit].unit_number] = nil
      local chargers = global.charging_vehicles[vehicle_unit]
      if(chargers) then
        local entities = { }
        for i = 1, #chargers do
          entities[i] = induction_entities[chargers[i]] or entity
        end
        if(erase_first_from_array(chargers, unit) and #chargers == 0) then
          global.charging_vehicles[vehicle_unit] = nil
          script.raise_event(events.on_charging_stopped, {
            entity = entity,
            grid = global.grids[unit],
            charging_entities = entities,
          })
        end
      end
    end
    
    local interface = global.electric_interfaces[unit]
    if(interface) then
      interface.destroy()
      global.electric_interfaces[unit] = nil
    end
  end
end

on_entity_removed = function(entity)
  if(global.induction_prototypes[entity.name]) then
    on_inductor_removed(entity)
  elseif(chargable_types[entity.type]) then
    local unit = entity.unit_number
    stop_charging(entity)
    global.entities[unit] = nil
    global.grids[unit] = nil
    inductors_for_unit[unit] = nil
    tracked_entities[unit] = nil
  end
end

-- Event entry points
-------------------------------------------------------------------------------

function on_built_entity(event)
  local entity = event.created_entity
  if(global.automatically_placed_inductors[entity.name]) then
    on_inductor_placed(entity, global.induction_prototypes[entity.name])
  else
    if(chargable_types[entity.type] and entity.grid) then
      local unit = entity.unit_number
      global.entities[unit] = entity
      global.grids[unit] = entity.grid
      update_equipment(unit, entity.grid)
    end
  end
end

function on_entity_died(event)
  on_entity_removed(event.entity)
end

function on_character_armor_inventory_changed(event)
  check_character_armor(event.character_index)
end

function on_character_created(event)
  check_character_armor(event.character_index)
end

function on_character_joined_game(event)
  check_character_armor(event.character_index)
end

function on_character_placed_equipment(event)
  for unit, grid in pairs(global.grids) do
    if(grid == event.grid) then
      update_equipment(unit, grid)
      break
    end
  end
end

function on_character_removed_equipment(event)
  for unit, grid in pairs(global.grids) do
    if(grid == event.grid) then
      update_equipment(unit, grid)
      break
    end
  end
end

function on_pre_character_mined_item(event)
  on_entity_removed(event.entity)
end

function on_robot_built_entity(event)
  local entity = event.created_entity
  if(global.automatically_placed_inductors[entity.name]) then
    on_inductor_placed(entity, global.induction_prototypes[entity.name])
  end
end

function on_robot_pre_mined(event)
  on_entity_removed(event.entity)
end

function on_tick(event)
  local real_on_tick = function(event)
    tracking_tick()
    charge_tick()
  end

  rebuild_caches();
  -- Remove entities that were invalid in on_load
  for _, unit in pairs(invalid_entities) do
    remove_invalid_unit(unit)
  end
  invalid_entities = { }
  real_on_tick();
end

function on_train_changed_state(event)
  handle_train_state_change(event.train)
end

-- Remote interface
-------------------------------------------------------------------------------

function register_inductor_equipment(data)
  assert(type(data.name) == "string", "'name' must be a string")
  assert(game.equipment_prototypes[data.name], string.format("%s is not a valid equipment prototype", name))
  assert(type(data.efficiency or 0) == "number", "'efficiency' must be a number if present")
  global.induction_equipment[data.name] =
  {
    [1] = data.name,
    [2] = data.efficiency or 1,
  }
end

function register_inductor_entity(data)
  assert(type(data.name) == "string", "'name' must be a string")
  assert(game.entity_prototypes[data.name], string.format("%s is not a valid entity prototype", data.name))
  assert(type(data.interface_name) == "string", "'interface_name' must be a string")
  local interface = game.entity_prototypes[data.interface_name]
  assert(interface and interface.type == "electric-energy-interface", string.format("%s is not an electric-energy-interface entity prototype", data.interface_name))
  assert(interface.has_flag("not-blueprintable"), string.format("%s must have the flag not-blueprintable", data.interface_name))
  assert(interface.has_flag("not-deconstructable"), string.format("%s must have the flag not-deconstructable", data.interface_name))
  assert(type(data.offset_x or 0) == "number", "'offset_x' must be a number if present")
  assert(type(data.offset_y or 0) == "number", "'offset_y' must be a number if present")
  assert(type(data.efficiency or 0) == "number", "'efficiency' must be a number if present")
  global.induction_prototypes[data.name] =
  {
    [1] = data.name,
    [2] = data.interface_name,
    [3] = data.offset_x or 0,
    [4] = data.offset_y or 0,
    [5] = data.efficiency or 1,
  }
  global.automatically_placed_inductors[data.name] = true
end

function on_external_inductor_placed(entity, data)
  -- Calling this multiple times on the same owner is an error
  assert(entity.unit_number ~= nil, "inductor entity has no unit_number")
  assert(entity.name == data.name, string.format("placed entity is of type %s but data has name %s", entity.name, data.name))
  assert(global.induction_entities[entity.unit_number] == nil, "an inductor for this entity already exists")
  -- Keep a copy for later reference
  -- But don't enable automatic placement unless already enabled
  local enabled = global.automatically_placed_inductors[data.name]
  register_inductor_entity(data)
  global.automatically_placed_inductors[data.name] = enabled
  on_inductor_placed(entity, global.induction_prototypes[data.name])
end

function on_external_inductor_removed(entity)
  assert(entity.unit_number ~= nil, "inductor entity has no unit_number")
  on_entity_removed(entity)
end
