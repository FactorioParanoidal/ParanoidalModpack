require("src.main")

local function subscribe_to_lib_events()
  local charging_events = remote.call("wireless-charging-lib", "events")

  script.on_event(charging_events.on_charging_started, on_charging_started)
  script.on_event(charging_events.on_charging_stopped, on_charging_stopped)
end

script.on_init(function()
  -- The "owning enity" is whatever entity was placed by the player and is connected to wireless-charging-lib
  -- In case of stations the owning entity is the accumulator itself. For rails it is the rail segment.
  
  -- Dictionary of all built rails, indexed by the corresponding accumulator's unit number
  -- [unit-number] = entity
  global.rails = { }
  -- Dictionary of all built accumulators, indexed by the owning entity's unit number
  -- [unit-number] = entity
  global.accumulators = { }
  -- List of all active accumulators that need to periodically update information mapped to the equipment grid they are charging, indexed by the owning entity's unit number unit number
  -- [unit-number] = entity
  global.charging_accumulator_grids = { }
  -- Dictionary of all storage tanks misused as charging level indicators at accumulators, indexed by the owning entity's unit number
  -- [unit-number] = entity
  global.indicators = { }

  remote.call("wireless-charging-lib", "register-inductor-equipment", {
    name = "wireless-charging-lo-power-induction-coil",
    efficiency = 1,
  })
  remote.call("wireless-charging-lib", "register-inductor-equipment", {
    name = "wireless-charging-hi-power-induction-coil",
    efficiency = 0.8,
  })

  -- We do not register the rails here because we need to make sure they aren't built diagonally
  remote.call("wireless-charging-lib", "register-inductor-entity", {
    name = "wireless-charging-lo-power-induction-station",
    interface_name = "lo-power-induction-station-interface",
    offset_y = 1,
    efficiency = 1,
  })
  remote.call("wireless-charging-lib", "register-inductor-entity", {
    name = "wireless-charging-hi-power-induction-station",
    interface_name = "hi-power-induction-station-interface",
    offset_y = 1,
    efficiency = 0.8,
  })
  
  subscribe_to_lib_events()
  --subscribe_to_conditional_events()
end)

function on_load()
  subscribe_to_lib_events()
  --subscribe_to_conditional_events()
end

script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_entity_died, on_entity_died)
script.on_event(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)
script.on_event(defines.events.on_robot_built_entity, on_robot_built_entity)
script.on_event(defines.events.on_robot_pre_mined, on_robot_pre_mined)
script.on_event(defines.events.on_tick, on_tick)
script.on_load(on_load)