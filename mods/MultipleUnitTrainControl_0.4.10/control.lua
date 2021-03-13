--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: control.lua
 * Description: Runtime operation script for replacing locomotives and balancing fuel.
 * Functions:
 *  => On Train Created (any built, destroyed, coupled, or uncoupled rolling stock)
 *  ===> Check if forwards_locomotives and backwards_locomotives contain matching pairs
 *  =====> Replace them with MU locomotives, add to global list of MU pairs, reconnect train, etc.
 *  ===> Check if train contains existing MU pairs, and if those pairs are intact.
 *  =====> Replace any partial MU pairs with normal locomotives, remove from global list, reconnect trains
 *
 *  => On Mod Settings Changed (disabled flag changes to true)
 *  ===> Read through entire global list of MU pairs and replace them with normal locomotives
 
 *  => On Nth Tick (once per ~10 seconds)
 *  ===> Read through entire global list of MU pairs.  
 *  ===> Move among each pair if one has more of any item than the other.
 *
 --]]

replaceCarriage = require("__Robot256Lib__/script/carriage_replacement").replaceCarriage
blueprintLib = require("__Robot256Lib__/script/blueprint_replacement")
filterLib = require("__Robot256Lib__/script/event_filters")


require("script.balanceInventories")
require("script.checkModuleMatching")
require("script.processTrainPurge")
require("script.processTrainBasic")
require("script.processTrainWireless")
require("script.addPairToGlobal")
require("script.purgeLocoFromPairs")


local settings_mode = settings.global["multiple-unit-train-control-mode"].value
local settings_nth_tick = settings.global["multiple-unit-train-control-on_nth_tick"].value
local settings_debug = settings.global["multiple-unit-train-control-debug"].value
local current_nth_tick = settings_nth_tick

local train_queue_semaphore = false


------------------------- GLOBAL TABLE INITIALIZATION ---------------------------------------

-- Interacts with other mods based on what MU locomotives were created
local function CallRemoteInterface()

  -- Make sure FuelTrainStop plays nice with magu's ElectricTrain in the MU versions
  if remote.interfaces["FuelTrainStop"] then
    for std,mu in pairs(global.upgrade_pairs) do
      if std:match("^et%-electric%-locomotive%-%d$") or 
         std:match("^fusion%-locomotive%-%d$") then
        remote.call("FuelTrainStop", "exclude_from_fuel_schedule", mu)
      end
    end
  end
  
  -- Add MU versions of Fluid Trains locomotives to the mod's update list
  if remote.interfaces["fluidTrains_hook"] then
    if global.upgrade_pairs["SteamTrains-locomotive"] then
      remote.call("fluidTrains_hook", "addLocomotive", global.upgrade_pairs["SteamTrains-locomotive"], 20000)
    end
    if global.upgrade_pairs["Diesel-Locomotive-fluid-locomotive"] then
      remote.call("fluidTrains_hook", "addLocomotive", global.upgrade_pairs["Diesel-Locomotive-fluid-locomotive"], 1500)
    end
  end
  
end

-- Set up the mapping between normal and MU locomotives
-- Extract from the game prototypes list what MU locomotives are enabled
local function InitEntityMaps()

  global.upgrade_pairs = {}
  global.downgrade_pairs = {}
  
  -- Retrieve entity names from dummy technology, store in global variable
  for _,effect in pairs(game.technology_prototypes["multiple-unit-train-control-locomotives"].effects) do
    if effect.type == "unlock-recipe" then
      local recipe = game.recipe_prototypes[effect.recipe]
      local std = recipe.products[1].name
      local mu = recipe.ingredients[1].name
      global.upgrade_pairs[std] = mu
      global.downgrade_pairs[mu] = std
      
      ------------
      -- RET Compatibility for this Loco
      local mod_name = ""
      if remote.interfaces["realistic_electric_trains"] then
        -- Check if this is an RET loco, and what fuel the std version uses
        local fuel_item = remote.call("realistic_electric_trains", "get_locomotive_fuel", std)
        if fuel_item then
          -- Add the MU version to RET's global map. Use custom fuel item if specified.
          if recipe.ingredients[2] then fuel_item = recipe.ingredients[2].name end
          remote.call("realistic_electric_trains", "register_locomotive_type", mu, fuel_item)
          mod_name = "Realistic Electric Trains "
        end
      end
      if settings_debug == "info" then
        game.print({"debug-message.mu-mapping-message",mod_name,game.entity_prototypes[std].localised_name,game.entity_prototypes[mu].localised_name})
      elseif settings_debug == "debug" then
        game.print({"debug-message.mu-mapping-message",mod_name,std,mu})
      end
      
    end
  end
  
  -- Mod compatibility setup
  CallRemoteInterface()
  
end


------------------------- FUEL BALANCING CODE --------------------------------------
-- Takes inventories from the queue and process them, one per tick
local function ProcessInventoryQueue()
  local idle = true
  
  if global.inventories_to_balance and next(global.inventories_to_balance) then
    --game.print("Taking from inventory queue, " .. #global.inventories_to_balance .. " remaining")
    local inventories = table.remove(global.inventories_to_balance, 1)
    balanceInventories(inventories[1], inventories[2])
    
    idle = false  -- Tell OnTick that we did something useful
  end

  return idle
end


------------------------- LOCOMOTIVE REPLACEMENT CODE -------------------------------

-- Process replacement order immediately
--   Need to preserve mu_pairs across replacement
local function ProcessReplacement(r)
  if r[1] and r[1].valid then
    -- Replace the locomotive
    local errorString = ""
    if settings_debug == "info" then
      game.print({"debug-message.mu-replacement-message",r[1].localised_name,r[1].backer_name,game.entity_prototypes[r[2]].localised_name})
      errorString = {"debug-message.mu-replacement-failed",r[1].localised_name,r[1].backer_name,r[1].position.x,r[1].position.y}
    elseif settings_debug == "debug" then
      game.print({"debug-message.mu-replacement-message",r[1].name,r[1].backer_name,r[2]})
      errorString = {"debug-message.mu-replacement-failed",r[1].name,r[1].backer_name,r[1].position.x,r[1].position.y}
    end
    
    local newLoco = replaceCarriage(r[1], r[2])
    -- Find which mu_pair the old one was in and put the new one instead
    for _,p in pairs(global.mu_pairs) do
      if p[1] == r[1] then
        p[1] = newLoco
        break
      elseif p[2] == r[1] then
        p[2] = newLoco
        break
      end
    end
    -- Make sure it was actually replaced, show error message if not.
    if not newLoco and (settings_debug ~= "none") then
      game.print(errorString)
    end
  end
end


-- Read train state and determine if it is safe to replace
local function isTrainStopped(train)
  local state = train.state
  return train.speed==0 and (
              (state == defines.train_state.wait_station) or 
              (state == defines.train_state.wait_signal) or 
              (state == defines.train_state.no_path) or 
              (state == defines.train_state.no_schedule) or 
              (state == defines.train_state.manual_control)
      )
end


-- Read the mod settings and technology of the given force to decide what mode we're in
local function getAllowedMode(force)
  if settings_mode ~= "tech-unlock" then
    return settings_mode
  elseif force.technologies["adv-multiple-unit-train-control"] and force.technologies["adv-multiple-unit-train-control"].researched then
    return "advanced"
  elseif force.technologies["multiple-unit-train-control"] and force.technologies["multiple-unit-train-control"].researched then
    return "basic"
  else
    return "disabled"
  end
end


------------
-- Process one valid train. Do replacemnts immediately.
local function ProcessTrain(t)
  local found_pairs = {}
  local upgrade_locos = {}
  local unpaired_locos = {}
  
  local mode = getAllowedMode(t.carriages[1].force)
  if mode=="advanced" then
    found_pairs,upgrade_locos,unpaired_locos = processTrainWireless(t)
  elseif mode=="basic" then
    found_pairs,upgrade_locos,unpaired_locos = processTrainBasic(t)
  else
    -- Mod disabled, go through the process of reverting every engine
    found_pairs,upgrade_locos,unpaired_locos = processTrainPurge(t)
  end
  
  -- Remove pairs involving the now-unpaired locos.
  for _,entry in pairs(unpaired_locos) do
    purgeLocoFromPairs(entry)
  end
  
  -- Add pairs to the pair lists.  (pairs will need to be updated when the replacements are made)
  for _,entry in pairs(found_pairs) do
    addPairToGlobal(entry)
  end
  
  -- Replace locomotives immediately
  for _,entry in pairs(upgrade_locos) do
    ProcessReplacement(entry)
  end
end


----------------------------------------------
------ EVENT HANDLING ---

--== ON_TRAIN_CHANGED_STATE EVENT ==--
-- Fires when train pathfinder changes state, executes if the train is in the update list.
-- Use this to replace locomotives at a safe (stopped) time.
local function OnTrainChangedState(event) 
  local id = event.train.id
      
  --game.print("Train ".. id .. " In OnTrainChangedState!")
  -- Event contains train, old_train_state
  -- If this train is queued for replacement, check state and maybe process now
  if global.moving_trains[id] then
    local t = event.train
    -- We are waitng to process it, check everything!
    if t and t.valid then
      -- Check if this train is in a safe state
      if isTrainStopped(t) then
        -- Immediately replace these locomotives
        --game.print("Train " .. id .. " being processed.")
        if train_queue_semaphore == false then
          train_queue_semaphore = true
          ProcessTrain(t)
          global.moving_trains[id] = nil
          train_queue_semaphore = false
        elseif (settings_debug ~= "none") then
          game.print("OnChange Train " .. id .. " event ignored because semaphore is occupied (this is weird!)")
        end
      end
    end
  end
  if not next(global.moving_trains) then
    script.on_event(defines.events.on_train_changed_state, nil)
  end
  
  --game.print("Train " .. id .. " Exiting OnTrainChangedState")
end

--== ON_NTH_TICK (longer duration) EVENT ==--
-- Periodically purges global.moving_trains because some mods make train ids
-- go invalid while still in motion, that would otherwise never be deleted.
-- This could probably happen if trains get attacked and partially destroyed as well.
local function OnNthTickPurgeMovingList(event)

  local purged = 0
  local saved = 0
  for id,train in pairs(global.moving_trains) do
    if not train or not train.valid then
      global.moving_trains[id] = nil
      purged = purged + 1
    else
      saved = saved + 1
    end
  end
  
  if settings_debug == "debug" then
    if purged > 1 then
      if saved > 0 then
        game.print("MUTC Purged "..tostring(purged).." dead trains from global.moving_trains. "..tostring(saved).." moving trains are still valid.")
      else
        game.print("MUTC Purged "..tostring(purged).." dead trains from global.moving_trains.")
      end
    end
  end
end


-------------
-- Enables the on_train_changed_state event according to current variables
local function StartTrainWatcher()
  if global.moving_trains and next(global.moving_trains) then
    -- Set up the action to process train after it comes to a stop
    script.on_event(defines.events.on_train_changed_state, OnTrainChangedState)
  else
    script.on_event(defines.events.on_train_changed_state, nil)
  end
end


----------
-- Try to process newly created trains immediately
local function ProcessTrainQueue()
  -- Check if we are already processing a train.
  -- Don't execute this again if it was triggered by an intermediate on_train_created event.
  if train_queue_semaphore==false then
    train_queue_semaphore = true
    
    if global.created_trains then
      --game.print("ProcessTrainQueue has a train in the queue")
      -- Keep looping until we discard all the invalid intermediate trains
      while next(global.created_trains) do
        local t = table.remove(global.created_trains,1)
        if t and t.valid then
          -- Check if this train is in a safe state
          if isTrainStopped(t) then
            -- Immediately replace these locomotives
            --game.print("Train " .. id .. " being processed.")
            ProcessTrain(t)
            -- Don't process any more trains this tick
            break
          else
            -- Flag this train to be processed on a ChangedState event
            global.moving_trains[t.id] = t
            --game.print("Train " .. id .. " still moving.")
          end
        end
      end
    end
    
    train_queue_semaphore = false
    return true
  else
    --game.print("Queue already being processed")
    return false
  end
end



--== ONTICK EVENT ==--
-- Process items queued up by other actions
-- Only one action allowed per tick
local function OnTick(event)
  
  -- Process created trains one per tick
  ProcessTrainQueue()
  -- Enable state change handler if we found moving trains
  StartTrainWatcher()
  
  -- Balancing inventories has third priority
  ProcessInventoryQueue()
  
  if (not next(global.inventories_to_balance)) and 
     (not next(global.created_trains)) then
    -- All on_tick queues are empty, unsubscribe from OnTick to save UPS
    --game.print("Turning off OnTick")
    script.on_event(defines.events.on_tick, nil)
  end
  
end


--== ON_TRAIN_CREATED EVENT ==--
-- Record every new train in global queue, so we can process them one at a time.
--   Many of these events will be triggered by our own replacements, and those
--   "intermediate" trains will be invalid by the time we pull them from the queue.
--   This is the desired behavior. 
local function OnTrainCreated(event)
  -- Event contains train, old_train_id_1, old_train_id_2
  local id = event.train.id
  --game.print("Train "..id.." In OnTrainCreated!")

  -- Add this train to the train processing list, wait for it to stop
  table.insert(global.created_trains, event.train)
  
  -- Remove old trains from moving_trains list
  -- When using Renai transportation Train Jumps, this will take care of 99% of the spurious entries 
  --   from long trains that get disconnected and reconnected while in motion.
    if global.moving_trains then
        if event.old_train_id_1 then
            if global.moving_trains[event.old_train_id_1] then
              --game.print("Removed old train "..tostring(event.old_train_id_1).." from moving_trains list")
              global.moving_trains[event.old_train_id_1] = nil
            end
        end
        if event.old_train_id_2 then
            if global.moving_trains[event.old_train_id_2] then
              --game.print("Removed old train "..tostring(event.old_train_id_2).." from moving_trains list")
              global.moving_trains[event.old_train_id_2] = nil
            end
        end
    end
  
  --game.print("Train " .. event.train.id .. " queued.")
  
  -- Try to process it immediately. Will exit if we are already processing stuff
  script.on_event(defines.events.on_tick, OnTick)
  --game.print("Train "..id.." Exiting OnTrainCreated!")
end


--== ON_GUI_CLOSED and ON_PLAYER_FAST_TRANSFERRED ==--
-- Events trigger when player changes module contents of a modular locomotive
local function OnModuleChanged(event)
  local e = event.entity
  if e and e.valid and e.type=="locomotive" then
    table.insert(global.created_trains, e.train)
    script.on_event(defines.events.on_tick, OnTick)
  end
end


--== ON_NTH_TICK EVENT ==--
-- Initiates balancing of fuel inventories in every MU consist
local function OnNthTick(event)
  if global.mu_pairs and next(global.mu_pairs) then
    local numInventories = 0
  
    local n = #global.mu_pairs
    local done = false
    for i=1,n do
      local entry = global.mu_pairs[i]
      if (entry[1] and entry[2] and entry[1].valid and entry[2].valid) then
        -- This pair is good, balance if there are burner fuel inventories (only check one, since they are identical prototypes)
        if entry[1].burner then
          local inventoryOne = entry[1].burner.inventory
          local inventoryTwo = entry[2].burner.inventory
          if inventoryOne.valid and inventoryOne.valid and #inventoryOne > 0 then
            table.insert(global.inventories_to_balance, {inventoryOne, inventoryTwo})
            numInventories = numInventories + 1
            -- if it burns stuff, it might have a result
            inventoryOne = entry[1].burner.burnt_result_inventory
            inventoryTwo = entry[2].burner.burnt_result_inventory
            if inventoryOne.valid and inventoryOne.valid and #inventoryOne > 0 then
              table.insert(global.inventories_to_balance, {inventoryOne, inventoryTwo})
              numInventories = numInventories + 1
            end
          end
        end
      else
        -- This pair has one or more invalid locomotives, or they don't have burners at all, remove it from the list
        global.mu_pairs[i] = nil
      end
    end
    local j=0
    for i=1,n do  -- Condense the list
      if global.mu_pairs[i] ~= nil then
        j = j+1
        global.mu_pairs[j] = global.mu_pairs[i]
      end
    end
    for i=j+1,n do
      global.mu_pairs[i] = nil
    end
      
    -- Set up the on_tick action to process trains
    --game.print("Nth tick starting OnTick")
    if next(global.inventories_to_balance) then
      script.on_event(defines.events.on_tick, OnTick)
      
      -- Update the Nth tick interval to make sure we have enough time to update all the trains
      local newVal = current_nth_tick
      if numInventories+10 > current_nth_tick then
        -- If we have fewer than 10 spare ticks per update cycle, give ourselves 50% margin
        newVal = (numInventories*3)/2
      elseif numInventories < current_nth_tick / 2 then
        -- If we have more than 100% margin, reduce either to the min setting or to just 50% margin
        newVal = math.max((numInventories*3)/2, settings_nth_tick)
      end
      if newVal ~= current_nth_tick then
        --game.print("Changing MU Control Nth Tick duration to " .. newVal)
        if settings_debug == "info" or settings_debug == "debug" then
          game.print({"debug-message.mu-changing-tick-message",newVal})
        end
        current_nth_tick = newVal
        global.current_nth_tick = current_nth_tick
        RefreshNthTickHandlers()
      end
    end
  end
end


-- Made this function global to avoid crash on circular reference?
function RefreshNthTickHandlers()
  script.on_nth_tick(nil)
  if not (settings_nth_tick == 0 or settings_mode == "disabled") then
    script.on_nth_tick(current_nth_tick, OnNthTick)
  end
  script.on_nth_tick(math.max(current_nth_tick*2, 600), OnNthTickPurgeMovingList)
end

--== ON_PLAYER_CONFIGURED_BLUEPRINT EVENT ==--
-- ID 70, fires when you select a blueprint to place
--== ON_PLAYER_SETUP_BLUEPRINT EVENT ==--
-- ID 68, fires when you select an area to make a blueprint or copy
local function OnPlayerSetupBlueprint(event)
  blueprintLib.mapBlueprint(event,global.downgrade_pairs)
end


--== ON_PLAYER_PIPETTE ==--
-- Fires when player presses 'Q'.  We need to sneakily grab the correct item from inventory if it exists,
--  or sneakily give the correct item in cheat mode.
local function OnPlayerPipette(event)
  blueprintLib.mapPipette(event,global.downgrade_pairs)
end


--== ON_PICKED_UP_ITEM ==--
-- When player picks up an item, change -mu to normal loco items.
local function OnPickedUpItem(event)
  if global.downgrade_pairs[event.item_stack.name] then
    game.players[event.player_index].remove_item(event.item_stack)
    game.players[event.player_index].insert({name=global.downgrade_pairs[event.item_stack.name], count=event.item_stack.count})
  end
end
script.on_event(defines.events.on_picked_up_item, OnPickedUpItem)


--== ON_PRE_PLAYER_MINED_ITEM ==--
--== ON_ROBOT_PRE_MINED ==--
-- Before player or robot mines an item on the ground, change -mu to normal loco items.
local function OnPreMined(event)
  if event.entity.name == "item-on-ground" then
    local stack = event.entity.stack
    -- Change item-on-ground to unloaded wagon before robot picks it up
    if stack.valid_for_read and global.downgrade_pairs[stack.name] then
      stack.set_stack({name=global.downgrade_pairs[stack.name], count=stack.count})
    end
  end
end
script.on_event( defines.events.on_robot_pre_mined,
                 OnPreMined,
                 filterLib.generateNameFilter("item-on-ground")
               )
script.on_event( defines.events.on_pre_player_mined_item,
                 OnPreMined,
                 filterLib.generateNameFilter("item-on-ground")
               )


-------------
-- Enables the on_nth_tick event according to the mod setting value
--   Safe to run inside on_load().
--   Also handle the Moving Train List purge timer when settings_nth_tick changes
local function StartBalanceUpdates()
  -- Value of zero disables fuel balancing
  --game.print("Disabling Nth Tick due to setting")
  if not(settings_nth_tick == 0 or settings_mode == "disabled") then
    -- See if we stored a longer update rate in global
    if global.current_nth_tick and global.current_nth_tick > settings_nth_tick then
      current_nth_tick = global.current_nth_tick
    else
      current_nth_tick = settings_nth_tick
    end
    -- Start the event
    --game.print("Enabling Nth Tick with setting " .. settings_nth_tick)
  end
  RefreshNthTickHandlers()
end


-----------
-- Queues all existing trains for updating with new settings
local function QueueAllTrains()
  for _, surface in pairs(game.surfaces) do
    local trains = surface.get_trains()
    for _,train in pairs(trains) do
      -- Pretend this train was just created. Don't worry how long it takes.
      table.insert(global.created_trains, train)
      --game.print("Train " .. train.id .. " queued for scrub.")
    end
  end
  if next(global.created_trains) then
    script.on_event(defines.events.on_tick, OnTick)
  end
end

----------
-- Shows or hides technologies based on runtime setting
local function UpdateTechnologyState()
-- Update technology visible state
  if settings_mode == "tech-unlock" then
    for _,force in pairs(game.forces) do
      if force.technologies["adv-multiple-unit-train-control"] then
        force.technologies["adv-multiple-unit-train-control"].enabled = true
      end
      if force.technologies["multiple-unit-train-control"] then
        force.technologies["multiple-unit-train-control"].enabled = true
      end
    end
  else
    for _,force in pairs(game.forces) do
      if force.technologies["adv-multiple-unit-train-control"] then
        force.technologies["adv-multiple-unit-train-control"].enabled = false
      end
      if force.technologies["multiple-unit-train-control"] then
        force.technologies["multiple-unit-train-control"].enabled = false
      end
    end
  end
end


--== ON_RESEARCH_FINISHED EVENT ==--
-- Forces a scrub after researching MUTC technologies
-- Moving trains will be queued until they stop.
local function OnResearchFinished(event)
  if (event.research.name == "multiple-unit-train-control") or
     (event.research.name == "adv-multiple-unit-train-control") then
    -- Reprocess all trains with the new technology setting
    QueueAllTrains()  -- This will execute some replacements immediately
  end
end


---- Bootstrap ----
do
local function init_events()

  -- Subscribe to Blueprint activity
  script.on_event({defines.events.on_player_setup_blueprint,defines.events.on_player_configured_blueprint}, OnPlayerSetupBlueprint)
  script.on_event(defines.events.on_player_pipette, OnPlayerPipette)
  
  -- Subscribe to Technology activity
  script.on_event(defines.events.on_research_finished, OnResearchFinished)

  -- Subscribe to On_Nth_Tick according to saved global and settings
  StartBalanceUpdates()
  
  -- Subscribe to On_Train_Changed_state according to global queue
  StartTrainWatcher()
  
  -- Subscribe to On_Train_Created according to mod enabled setting
  if settings_mode ~= "disabled" then
    script.on_event(defines.events.on_train_created, OnTrainCreated)
    script.on_event({defines.events.on_gui_closed, defines.events.on_player_fast_transferred}, OnModuleChanged)
  end
  
  -- Set conditional OnTick event handler correctly on load based on global queues, so we can sync with a multiplayer game.
  if (global.inventories_to_balance and next(global.inventories_to_balance)) or
    (global.created_trains and next(global.created_trains)) then
    script.on_event(defines.events.on_tick, OnTick)
  end
  
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  --game.print("in mod_settings_changed!")
  if event.setting == "multiple-unit-train-control-mode" then
    settings_mode = settings.global["multiple-unit-train-control-mode"].value
    
    -- Scrub existing trains according to new settings
    QueueAllTrains()  -- This will execute some replacements immediately
    if settings_mode == "disabled" then
      -- Clean globals when disabled
      global.mu_pairs = {}
      global.inventories_to_balance = {}
    end
    
    -- Update technology visible state
    UpdateTechnologyState()
    
    -- Enable or disable events based on setting state
    init_events()
  
  elseif event.setting == "multiple-unit-train-control-on_nth_tick" then
    -- When interval changes, clear the saved update rate and start over
    settings_nth_tick = settings.global["multiple-unit-train-control-on_nth_tick"].value
    global.current_nth_tick = nil
    StartBalanceUpdates()
    StartTrainWatcher()
  
  elseif event.setting == "multiple-unit-train-control-debug" then
    settings_debug = settings.global["multiple-unit-train-control-debug"].value
    
  end
  
end)

----------
-- When game is loaded (from save or server), only set up events to match previous state
script.on_load(function()
  init_events()
end)

-- When game is created, initialize globals and events
script.on_init(function()
  --game.print("In on_init!")
  global.created_trains = {}
  global.moving_trains = {}
  global.mu_pairs = {}
  global.inventories_to_balance = {}
  InitEntityMaps()
  UpdateTechnologyState()
  init_events()
  
end)

-- When mod list/versions change, reinitialize globals and scrub existing trains
script.on_configuration_changed(function(data)
  --game.print("In on_configuration_changed!")
  global.created_trains = global.created_trains or {}
  global.moving_trains = global.moving_trains or {}
  global.mu_pairs = global.mu_pairs or {}
  global.inventories_to_balance = global.inventories_to_balance or {}
  InitEntityMaps()
  -- On config change, scrub the list of trains
  QueueAllTrains()
  init_events()
  
  -- Migrate by clearing old globals
  global.trains_in_queue = nil
  global.replacement_queue = nil
end)

end



------------------------------------------
-- Debug (print text to player console)
function print_game(...)
  local text = ""
  for _, v in ipairs{...} do
    if type(v) == "table" then
      text = text..serpent.block(v)
    else
      text = text..tostring(v)
    end
  end
  game.print(text)
end

function print_file(...)
  local text = ""
  for _, v in ipairs{...} do
    if type(v) == "table" then
      text = text..serpent.block(v)
    else
      text = text..tostring(v)
    end
  end
  log(text)
end  

-- Debug command
function cmd_debug(params)
  local cmd = params.parameter
  if cmd == "dump" then
    for v, data in pairs(global) do
      print_game(v, ": ", data)
    end
  elseif cmd == "dumplog" then
    for v, data in pairs(global) do
      print_file(v, ": ", data)
    end
    print_game("Dump written to log file")
  end
end
commands.add_command("mutc-debug", "Usage: mutc-debug dump|dumplog", cmd_debug)

------------------------------------------------------------------------------------
--                    FIND LOCAL VARIABLES THAT ARE USED GLOBALLY                 --
--                              (Thanks to eradicator!)                           --
------------------------------------------------------------------------------------
setmetatable(_ENV,{
  __newindex=function (self,key,value) --locked_global_write
    error('\n\n[ER Global Lock] Forbidden global *write*:\n'
      .. serpent.line{key=key or '<nil>',value=value or '<nil>'}..'\n')
    end,
  __index   =function (self,key) --locked_global_read
    error('\n\n[ER Global Lock] Forbidden global *read*:\n'
      .. serpent.line{key=key or '<nil>'}..'\n')
    end ,
  })
