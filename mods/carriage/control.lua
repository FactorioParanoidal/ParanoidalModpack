require "util"
require "logic/carriage_api"
require "logic/carriage_placement"
require "logic/blueprint_fix"


is_route = util.list_to_map {
  "route",
  "straight-route",
  "half-diagonal-route",
  "curved-route-a",
  "curved-route-b",
  "legacy-straight-route",
  "legacy-curved-route"
}

is_rail = util.list_to_map {
  "rail",
  "straight-rail",
  "half-diagonal-rail",
  "curved-rail-a",
  "curved-rail-b",
  "legacy-straight-rail",
  "legacy-curved-rail",
  "rail-ramp",
}


-- spawn additional invisible entities
local function OnEntityBuilt(event)
  local entity = event.entity or event.destination
  local surface = entity.surface
  local quality = entity.quality
  local force = entity.force
  local player = (event.player_index and game.players[event.player_index]) or nil

  --log("Event happened:"..serpent.block(event))

  -- check ghost entities first
  if entity.name == "entity-ghost" then
    if is_route[entity.ghost_name] then
      -- Attempt to revive the route ghost
      -- If this fails, then it is waiting for a tile to be deconstructed under it.
      -- A robot will come later and revive it after the tiles are removed (no item required)
      if not entity.silent_revive { raise_revive = true } then
        -- route could not be revived, add to list to revive later
        -- look for colliding entities and tile deconstruction markers
        local found_entities = entity.surface.find_entities_filtered { area = entity.bounding_box, to_be_deconstructed = true }
        storage.route_ghosts = storage.route_ghosts or {}
        for i, e in pairs(found_entities) do
          script.register_on_object_destroyed(e)
          local e_num = e.unit_number or 0
          storage.route_ghosts[e_num] = storage.route_ghosts[e_num] or {}
          table.insert(storage.route_ghosts[e_num], entity)
        end
      end
    end
  elseif (entity.type == "cargo-wagon" or entity.type == "fluid-wagon" or
        entity.type == "locomotive" or entity.type == "artillery-wagon") then
    local engine = nil
    if storage.carriage_bodies[entity.name] then
      local carriage_data = storage.carriage_bodies[entity.name]
      if carriage_data.engine then
        local engine_loc = localizeEngine(entity)
        --game.print("looking for engine ghost at "..util.positiontostr(engine_loc.pos).." pointing "..tostring(engine_loc.dir))
        -- see if there is an engine ghost from a blueprint behind us
        local ghost = surface.find_entities_filtered { ghost_name = carriage_data.engine, position = engine_loc.pos, force = force, limit = 1 }
            [1]
        if ghost then
          --game.print("found ghost at "..util.positiontostr(ghost.position).." pointing "..tostring(ghost.orientation)..", reviving")
          local dummy
          dummy, engine = ghost.revive()
          -- If couldn't revive engine, destroy ghost
          if not engine then
            --game.print("couldn't revive ghost at "..util.positiontostr(newghost.position))
            ghost.destroy()
          end
        end
        if not engine then
          --game.print("Creating "..carriage_data.engine.." for "..entity.name)
          engine = surface.create_entity {
            name = carriage_data.engine,
            quality = quality,
            position = engine_loc.pos,
            direction = engine_loc.dir,
            force = force
          }
        end
      end
    end
    -- check placement in next tick after wagons connect
    table.insert(storage.check_placement_queue,
      { entity = entity, engine = engine, player = player, robot = event.robot })
    RegisterPlacementOnTick()
  end
end

local function OnMarkedForDeconstruction(event)
  local entity = event.entity
  if is_route[entity.name] then
    -- Instantly deconstruct routes
    entity.destroy()
  elseif storage.carriage_bodies[entity.name] or storage.carriage_engines[entity.name] then
    -- If a carriage or carriage engine is marked for deconstruction, make sure its coupled pair is too
    if entity.train then
      local otherstock
      -- Find attached engine or body
      otherstock = entity.get_connected_rolling_stock(defines.rail_direction.front) or
          entity.get_connected_rolling_stock(defines.rail_direction.back)
      if otherstock and not otherstock.to_be_deconstructed() then
        -- Copy deconstruction order
        local player = game.players[event.player_index]
        local force = (player and player.force) or entity.force
        otherstock.order_deconstruction(force, player)
      end
    end
  end
end

local function OnCancelledDeconstruction(event)
  local entity = event.entity
  if storage.carriage_bodies[entity.name] or storage.carriage_engines[entity.name] then
    -- If a carriage or carriage engine is cancelled for deconstruction, make sure its coupled pair is too
    if entity.train then
      local otherstock
      -- Find attached engine or body
      otherstock = entity.get_connected_rolling_stock(defines.rail_direction.front) or
          entity.get_connected_rolling_stock(defines.rail_direction.back)
      if otherstock and otherstock.to_be_deconstructed() then
        -- Copy deconstruction order
        local player = event.player_index and game.players[event.player_index]
        local force = (player and player.force) or entity.force
        otherstock.cancel_deconstruction(force, player)
      end
    end
  end
end

local function OnGiveRoute(event)
  local player = game.get_player(event.player_index)
  local cleared = player.clear_cursor()
  if cleared then
    player.cursor_ghost = { name = "route" }
  end
end

-- delete invisible entities if master entity is destroyed
local function OnEntityDeleted(event)
  local entity = event.entity
  if (entity and entity.valid) then
    if storage.carriage_bodies[entity.name] then
      if entity.train then
        if entity.train.back_stock then
          if storage.carriage_engines[entity.train.back_stock.name] then
            entity.train.back_stock.destroy()
          end
        end
        if entity.train.front_stock then
          if storage.carriage_engines[entity.train.front_stock.name] then
            entity.train.front_stock.destroy()
          end
        end
      end
    elseif storage.carriage_engines[entity.name] then
      if entity.train then
        if entity.train.front_stock then
          if storage.carriage_bodies[entity.train.front_stock.name] then
            entity.train.front_stock.destroy()
          end
        end
        if entity.train.back_stock then
          if storage.carriage_bodies[entity.train.back_stock.name] then
            entity.train.back_stock.destroy()
          end
        end
      end
    elseif entity.name == "entity-ghost" then
      if storage.carriage_bodies[entity.ghost_name] then
        -- Delete any carriage engine ghost in the area
        DestroyCarriageGhost(entity)
      end
    end
  end
end

-- Robots can try to mine it, but get sent away with something else if there is still cargo
local function OnRobotPreMined(event)
  if (event.entity and event.entity.valid) then
    local entity = event.entity
    if storage.carriage_bodies[entity.name] or storage.carriage_engines[entity.name] then
      -- Find attached engine or body
      local otherstock = entity.get_connected_rolling_stock(defines.rail_direction.front) or
          entity.get_connected_rolling_stock(defines.rail_direction.back)
      if otherstock then
        local save_inventory
        -- Get the correct inventory from the attached engine or body
        -- Ignore engines with recover_fuel=false because they don't have fuel items to recover
        if storage.carriage_engines[otherstock.name] and storage.carriage_engines[otherstock.name].recover_fuel then
          save_inventory = otherstock.get_fuel_inventory()
          -- If not an engine, then it must be a body because we already checked it's one or the other
        elseif otherstock.type == "cargo-wagon" then
          save_inventory = otherstock.get_inventory(defines.inventory.cargo_wagon)
        elseif otherstock.type == "artillery-wagon" then
          save_inventory = otherstock.get_inventory(defines.inventory.artillery_wagon_ammo)
        end
        if save_inventory and not save_inventory.is_empty() then
          -- Give contents of inventory to robot
          local robotInventory = event.robot.get_inventory(defines.inventory.robot_cargo)
          local robotSize = 1 + event.robot.force.worker_robots_storage_bonus
          if robotInventory.is_empty() then
            -- Find something to give to the robot. Otherwise the robot remains empty when the event returns, and it will finish mining the entity
            for index = 1, #save_inventory do
              local stack = save_inventory[index]
              if stack.valid_for_read then
                --game.print("Giving robot cargo stack: "..stack.name.." : "..stack.count)
                local inserted = robotInventory.insert { name = stack.name, quality = stack.quality, count = math.min(stack.count, robotSize) }
                save_inventory.remove { name = stack.name, quality = stack.quality, count = inserted }
                if not robotInventory.is_empty() then
                  break
                end
              end
            end
          end
        end
      end
    end
  end
end

-- Robot mining the actually carriage/engine (after both are empty).
-- If one half of a carriage is mined, also mine the other half into the same robot. Only one of them will be the actual item.
local function OnRobotMinedEntity(event)
  if event.entity and event.entity.valid then
    local entity = event.entity
    if storage.carriage_bodies[entity.name] or storage.carriage_engines[entity.name] then
      -- Find attached engine or body to mine
      local otherstock = entity.get_connected_rolling_stock(defines.rail_direction.front) or
          entity.get_connected_rolling_stock(defines.rail_direction.back)
      if otherstock then
        otherstock.mine { inventory = event.robot.get_inventory(defines.inventory.robot_cargo), force = true, raise_destroyed = false, ignore_minable = true }
      end
    end
  end
end

-- When the player mines a carriage or engine, also make the player mine the coupled entity
-- Unfortunately the API won't let us combine them into one undo action yet
local function OnPlayerMinedEntity(event)
  local entity = event.entity
  local player = game.players[event.player_index]
  if entity and entity.valid then
    storage.currently_mining = storage.currently_mining or {}
    if not storage.currently_mining[entity.unit_number] then
      if storage.carriage_bodies[entity.name] or storage.carriage_engines[entity.name] then
        -- Find attached engine or body to mine
        local otherstock = entity.get_connected_rolling_stock(defines.rail_direction.front) or
            entity.get_connected_rolling_stock(defines.rail_direction.back)
        if otherstock then
          storage.currently_mining[otherstock.unit_number] = entity
          player.mine_entity(otherstock, true)
          -- This mining operation completes before returning
          -- Now merge the undo actions.  Most recent is entity, second-most-recent is otherstock
          local item1 = player.undo_redo_stack.get_undo_item(1)
          if #item1 == 1 and item1[1].type == "removed-entity" and storage.carriage_engines[item1[1].target.name] then
            -- otherstock was an engine that we can safely remove from the undo stack
            --game.print("Removing engine from undo stack")
            player.undo_redo_stack.remove_undo_item(1)
          end
        end
      end
    else
      -- This mining operation was started by script, don't start another one and clear the flag
      storage.currently_mining[entity.unit_number] = nil
    end
  end
end

-- Check if this undo created a lone carriage engine ghost, because that's not allowed
local function OnUndoApplied(event)
  local actions = event.actions
  local action = actions[1]
  --game.print(serpent.block(action))
  if #actions == 1 and action.type == "removed-entity" and storage.carriage_engines[action.target.name] then
    -- Find the ghost at the action coordinates
    local surface = game.surfaces[action.surface_index]
    local found = surface and
        surface.find_entities_filtered { ghost_name = action.target.name, position = action.target.position, limit = 1 }

    if found and found[1] then
      found[1].destroy()
      --game.print("Destroyed engine ghost from undo action")
    else
      --game.print("Couldn't find ghost engine from undo action")
    end
  end
end

-- Register conditional events based on mod settting
function init_events()
  -- entity created, check placement and create invisible elements
  local entity_filters = {
    { filter = "ghost",        ghost_name = "straight-route" },
    { filter = "ghost",        ghost_name = "half-diagonal-route" },
    { filter = "ghost",        ghost_name = "curved-route-a" },
    { filter = "ghost",        ghost_name = "curved-route-b" },
    { filter = "ghost",        ghost_name = "legacy-straight-route" },
    { filter = "ghost",        ghost_name = "legacy-curved-route" },
    { filter = "rolling-stock" },
    { filter = "rail" }
  }
  script.on_event(defines.events.on_built_entity, OnEntityBuilt, entity_filters)
  script.on_event(defines.events.on_robot_built_entity, OnEntityBuilt, entity_filters)
  script.on_event(defines.events.on_entity_cloned, OnEntityBuilt, entity_filters)
  script.on_event(defines.events.script_raised_built, OnEntityBuilt, entity_filters)
  script.on_event(defines.events.script_raised_revive, OnEntityBuilt, entity_filters)

  -- delete invisible carriage elements
  local deleted_filters = {}
  if storage.carriage_bodies then
    for name, _ in pairs(storage.carriage_bodies) do
      table.insert(deleted_filters, { filter = "name", name = name })
      table.insert(deleted_filters, { filter = "ghost_name", name = name })
    end
  end
  if storage.carriage_engines then
    for name, _ in pairs(storage.carriage_engines) do
      table.insert(deleted_filters, { filter = "name", name = name })
    end
  end
  script.on_event(defines.events.on_entity_died, OnEntityDeleted, deleted_filters)
  script.on_event(defines.events.script_raised_destroy, OnEntityDeleted, deleted_filters)

  -- recover fuel from mined carriages
  local mined_filters = {}
  if storage.carriage_bodies then
    for name, _ in pairs(storage.carriage_bodies) do
      table.insert(mined_filters, { filter = "name", name = name })
    end
  end
  if storage.carriage_engines then
    for name, _ in pairs(storage.carriage_engines) do
      table.insert(mined_filters, { filter = "name", name = name })
    end
  end
  script.on_event(defines.events.on_robot_pre_mined, OnRobotPreMined, mined_filters)
  script.on_event(defines.events.on_player_mined_entity, OnPlayerMinedEntity, mined_filters)
  script.on_event(defines.events.on_robot_mined_entity, OnRobotMinedEntity, mined_filters)

  script.on_event(defines.events.on_undo_applied, OnUndoApplied)
  script.on_event(defines.events.on_redo_applied, OnUndoApplied)

  local deconstructed_filters = {
    { filter = "name", name = "straight-route" },
    { filter = "name", name = "half-diagonal-route" },
    { filter = "name", name = "curved-route-a" },
    { filter = "name", name = "curved-route-b" },
    { filter = "name", name = "legacy-straight-route" },
    { filter = "name", name = "legacy-curved-route" },
  }
  if storage.carriage_bodies then
    for name, _ in pairs(storage.carriage_bodies) do
      table.insert(deconstructed_filters, { filter = "name", name = name })
    end
  end
  if storage.carriage_engines then
    for name, _ in pairs(storage.carriage_engines) do
      table.insert(deconstructed_filters, { filter = "name", name = name })
    end
  end
  script.on_event(defines.events.on_marked_for_deconstruction, OnMarkedForDeconstruction, deconstructed_filters)

  local cancel_decon_filters = {}
  if storage.carriage_bodies then
    for name, _ in pairs(storage.carriage_bodies) do
      table.insert(cancel_decon_filters, { filter = "name", name = name })
    end
  end
  if storage.carriage_engines then
    for name, _ in pairs(storage.carriage_engines) do
      table.insert(cancel_decon_filters, { filter = "name", name = name })
    end
  end
  script.on_event(defines.events.on_cancelled_deconstruction, OnCancelledDeconstruction, cancel_decon_filters)

  -- update carriage placement
  RegisterPlacementOnTick()

  -- pipette
  script.on_event(defines.events.on_player_pipette, FixPipette)

  -- rolling stock connect (this logic was too buggy to use)
  script.on_event(defines.events.on_train_created, OnTrainCreated)

  -- custom-input and shortcut button
  script.on_event({ defines.events.on_lua_shortcut, "give-route" },
    function(event)
      if event.prototype_name and event.prototype_name ~= "give-route" then return end
      OnGiveRoute(event)
    end
  )
end

local function init()
  -- Init storage variables
  storage.check_placement_queue = storage.check_placement_queue or {}
  storage.currently_mining = storage.currently_mining or {}

  init_carriage_globals() -- Init database of carriage parameters

  -- Register conditional events
  init_events()
end

---- Register Default Events ----
-- init
script.on_load(function()
  init_events()
end)
script.on_init(function()
  init()
end)
script.on_configuration_changed(function()
  init()
end)

-- Console commands
commands.add_command("carriage-dump", "Dump storage to log", function() log(serpent.block(storage)) end)

------------------------------------------------------------------------------------
--                    FIND LOCAL VARIABLES THAT ARE USED GLOBALLY                 --
--                              (Thanks to eradicator!)                           --
------------------------------------------------------------------------------------
setmetatable(_ENV, {
  __newindex = function(self, key, value) --locked_global_write
    error('\n\n[ER Global Lock] Forbidden global *write*:\n'
      .. serpent.line { key = key or '<nil>', value = value or '<nil>' } .. '\n')
  end,
  --[[__index   =function (self,key) --locked_global_read
    error('\n\n[ER Global Lock] Forbidden global *read*:\n'
      .. serpent.line{key=key or '<nil>'}..'\n')
    end ,]]
})
