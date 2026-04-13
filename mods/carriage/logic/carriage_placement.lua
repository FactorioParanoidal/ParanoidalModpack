local math2d = require("math2d")

function localizeEngine(entity, carriage_name)
  --game.print("entity orientation = "..tostring(entity.orientation))
  local carriage_dir = (math.floor((entity.orientation*16)+0.5))%16  -- Direction-value dependent, updated for 16-way rails
  --game.print("carriage_dir = "..tostring(carriage_dir))
  local carriage_data = storage.carriage_bodies[carriage_name or entity.name]
  --game.print("carriage_data = "..serpent.line(carriage_data))
  local eng_pos = math2d.position.add(entity.position, carriage_data.engine_offset[carriage_dir])
  --game.print("eng_pos = "..serpent.line(eng_pos))
  local eng_dir = (carriage_data.engine_orientation and carriage_data.engine_orientation[carriage_dir]) or carriage_dir
  --game.print("eng_dir = "..tostring(eng_dir))
  return {pos=eng_pos, dir=eng_dir}
end

local function hasCorrectConnectedStock(wagon)
  local train = wagon.train
  local carriage_data = storage.carriage_bodies[wagon.name]
  if carriage_data then
    -- Look for engine in the correct direction
    local engine = wagon.get_connected_rolling_stock(carriage_data.coupled_engine)
    if engine and engine.name == carriage_data.engine then
      -- Now make sure the engine is facing the right way
      local engine_data = storage.carriage_engines[carriage_data.engine]
      if engine_data and engine.get_connected_rolling_stock(engine_data.coupled_carriage) == wagon then
          -- If this is the engine we expect, then we're good
        return true
      end
    end
  end
  local engine_data = storage.carriage_engines[wagon.name]
  if engine_data then
    -- Look for body in front of engine (carriage)
    local carriage = wagon.get_connected_rolling_stock(engine_data.coupled_carriage)
    -- If this is the engine we expect, then we're good
    if carriage and engine_data.compatible_carriages[carriage.name] then
      local carriage_data = storage.carriage_bodies[carriage.name]
      if carriage_data and carriage.get_connected_rolling_stock(carriage_data.coupled_engine) == engine then
        return true
      end
    end
  end
  --game.print("didn't find matching entity for "..wagon.name.." in train of "..#train.carriages.." wagons")
  return false
end

local function cancelPlacement(entity, player, robot)
  if not storage.carriage_engines[entity.name] then
    if player and player.valid then
      player.insert{name=entity.name, count=1}
      if storage.carriage_bodies[entity.name] then
        player.create_local_flying_text{text={"cargo-carriage-message.error-carriage-no-space", entity.localised_name}, create_at_cursor=true}
      else
        player.create_local_flying_text{text={"cargo-carriage-message.error-train-on-route", entity.localised_name}, create_at_cursor=true}
      end
    elseif robot and robot.valid then
      -- Give the robot back the thing
      local return_item = prototypes.entity[entity.name].items_to_place_this[1]
      robot.get_inventory(defines.inventory.robot_cargo).insert(return_item)
      if storage.carriage_bodies[entity.name] then
        game.print{"cargo-carriage-message.error-carriage-no-space", entity.localised_name}
      else
        game.print{"cargo-carriage-message.error-train-on-route", entity.localised_name}
      end
    else
      game.print{"cargo-carriage-message.error-canceled", entity.localised_name}
    end
  end
  entity.destroy()
end


-- checks placement of rolling stock, and returns the placed entities to the player if necessary
function processPlacementQueue()
  --if #storage.check_placement_queue > 0 then
  --  game.print(tostring(game.tick)..": checking placement "..tostring(#storage.check_placement_queue).." entities")
  --end
  for _, entry in pairs(storage.check_placement_queue) do
    local entity = entry.entity
    local engine = entry.engine
    local player = entry.player
    local robot = entry.robot
    
    --game.print("checking "..entity.name.." "..tostring(entity.unit_number))

    if entity and entity.valid then
      if storage.carriage_bodies[entity.name] then
        local carriage_data = storage.carriage_bodies[entity.name]
        -- check for too many connections
        -- check for correct engine placement
        if carriage_data.engine and not engine then
          -- See if there is already an engine connected to this carriage
          if not hasCorrectConnectedStock(entity) then
            --game.print("incorrectly coupled carriage / no engine")
            cancelPlacement(entity, player, robot)
          else
            --game.print("Correct stock coupled but wasn't given by creator")
          end
        elseif carriage_data.engine and entity.orientation ~= engine.orientation then
          --game.print("engine is wrong orientation")
          cancelPlacement(entity, player, robot)
          cancelPlacement(engine, player)
        elseif entity.train then
          -- check if connected to too many carriages
          if ((carriage_data.engine and #entity.train.carriages > 2) or
              (not carriage_data.engine and #entity.train.carriages > 1)) then
            --game.print("too many carriages connected together")
            cancelPlacement(entity, player, robot)
            cancelPlacement(engine, player)
          end
          -- Carriages can now be placed on both routes and normal rails
        end

      elseif storage.carriage_engines[entity.name] then
        if not hasCorrectConnectedStock(entity) then
          game.print{"cargo-carriage-message.error-unlinked-engine", entity.localised_name}
          cancelPlacement(entity, player)
        end

      -- else: trains
      elseif entity.train then
        -- check if on routes
        if entity.train.front_end then
          if is_route[entity.train.front_end.rail.name] then
            cancelPlacement(entity, player, robot)
          end
        elseif entity.train.back_end.rail then
          if is_route[entity.train.back_end.rail.name] then
            cancelPlacement(entity, player, robot)
          end
        end
      end
    end
  end
  storage.check_placement_queue = {}
  RegisterPlacementOnTick()
end

-- Disconnects/reconnects rolling stocks if they get wrongly connected/disconnected
function OnTrainCreated(event)
  local contains_carriage_engine = false
  local parts = event.train.carriages
  -- check if rolling stock contains any carriages (engines)
  for i = 1, #parts do
    if storage.carriage_engines[parts[i].name] then
      contains_carriage_engine = true
      break
    end
  end
  --if no carriages involved return
  if contains_carriage_engine == false then
    return
  end
  --game.print("Checking train "..tostring(event.train.id).." with carriage engine in it")
  -- if carriage  has been split reconnect
  if #parts == 1 then
    -- reconnect!
    local engine = parts[1]
    -- Connect engine in the direction of the expected carriage body
    local connected = engine.connect_rolling_stock(storage.carriage_engines[engine.name].coupled_carriage)
    --game.print("Tried connecting lonely "..engine.name.." at "..util.positiontostr(engine.position)..", result: "..tostring(connected))

  -- else if carriage has been overconnected, split again
  elseif #parts > 2 then
    for i = 1, #parts do
      local name = parts[i].name
      local right_direction = ((storage.carriage_bodies[name] and storage.carriage_bodies[name].coupled_engine) or 
                               (storage.carriage_engines[name] and storage.carriage_engines[name].coupled_carriage)) or nil
      if right_direction ~= nil then
        -- This is a carriage or engine that is supposed to connected in right_direction
        -- Check if it's also connected in the wrong_direction
        local wrong_direction = right_direction == defines.rail_direction.front and defines.rail_direction.back or defines.rail_direction.front
        local stock = parts[i]
        if stock.get_connected_rolling_stock(wrong_direction) then
          --game.print("Cargo carriages disconnecting rolling stock from "..(wrong_direction==defines.rail_direction.front and "front" or "back").." of "..name.." #"..tostring(stock.unit_number))
          if stock.disconnect_rolling_stock(wrong_direction) then 
            break
          end
        end
      end
    end
  end
end

function DestroyCarriageGhost(ghost)
  local engine_name = storage.carriage_bodies[ghost.ghost_name].engine
  local engine_loc = localizeEngine(ghost, ghost.ghost_name)
  local engine_ghosts = ghost.surface.find_entities_filtered{
    ghost_name = engine_name,
    position = engine_loc.position,
    radius = 1
  }
  for _,engine_ghost in pairs(engine_ghosts) do
    engine_ghost.destroy()
  end

end

function RegisterPlacementOnTick()
  if storage.check_placement_queue and next(storage.check_placement_queue) then
    script.on_event(defines.events.on_tick, processPlacementQueue)
  else
    script.on_event(defines.events.on_tick, nil)
  end
end
