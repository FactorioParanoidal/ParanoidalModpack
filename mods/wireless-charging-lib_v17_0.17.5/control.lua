require("src.main")
require("remote")

local function on_init()
  -- Working set
  
  -- List of all entities recognized as inductors. These are the ones placed by players or robots.
  -- [unit-number] = entity
  global.induction_entities = { }
  -- List of all energy interfaces. Indexed by the unit number of "induction_entities".
  -- [unit-number] = entity
  global.electric_interfaces = { }
  -- Dictionary mapping unit indices to an array of energy interfaces currently being located over induction plates and potentially being charged
  -- [unit-number] = array of interface-index
  global.charging_vehicles = { }
  -- List of all trains currently slowing down. Used for regenerative braking.
  -- [*] = braking data
  global.braking_trains = { }
  -- Dictinary of all non-train vehicles currently slowing down. Used for regenerative braking.
  -- [unit-number] = braking data
  global.braking_vehicles = { }
  -- Map of unit numbers to entity objects
  -- [unit-number] = entity
  global.entities = { }
  -- Maps each unit number to the equipment grid used for charging. Required for players as their active equipment can change.
  global.grids = { }
  
  -- Passive prototype data
  
  -- Dictionary of registered inductor equipment
  global.induction_equipment = { }
   -- Dictionary of recognized induction entities placed on the ground for vehicles to drive over.
  -- See remote interface for table layout.
  -- [name] = data
  global.induction_prototypes = { }
  -- Only these entity prototypes cause an automatically placed electric interface
  -- [name] = true
  global.automatically_placed_inductors = { }
end

local function on_load()
  --rebuild_caches()
end

local function on_configuration_changed(data)
  validate_prototypes()
  validate_entities()
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)

script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_entity_died, on_entity_died)
script.on_event(defines.events.on_player_armor_inventory_changed, on_player_armor_inventory_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
script.on_event(defines.events.on_player_placed_equipment, on_player_placed_equipment)
script.on_event(defines.events.on_player_removed_equipment, on_player_removed_equipment)
script.on_event(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)
script.on_event(defines.events.on_robot_built_entity, on_robot_built_entity)
script.on_event(defines.events.on_robot_pre_mined, on_robot_pre_mined)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_train_changed_state, on_train_changed_state)
