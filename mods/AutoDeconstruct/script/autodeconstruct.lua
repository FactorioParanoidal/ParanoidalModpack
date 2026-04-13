beltutil = require("beltutil")
pipeutil = require("pipeutil")
autodeconstruct = {}

local math2d = require("math2d")

local blacklist_surface_prefixes = {"BPL_TheLab", "bpsb%-lab"}
local RESOURCE_CHECK_TIME = 15
local RESOURCE_EJECT_TIME = 30
local DECONSTRUCT_TIMEOUT = 1800
local BELT_CHECK_TIME = 15
local BELT_INACTIVITY_TIME = 180
local BELT_TIMEOUT = 1800


local function map_to_string(t)
  local s = "{"
  for k,_ in pairs(t) do
    s = s..tostring(k)..","
  end
  s = s.."}"
  return s
end

local function find_all_entities(entity_type)
  local entities = {}
  for _, surface in pairs(game.surfaces) do
    if surface and surface.valid then
      for _,entity in pairs(surface.find_entities_filtered{type = entity_type}) do
        table.insert(entities, entity)
      end
    end
  end
  return entities
end


local function check_drill(drill)
  if storage.blacklist[drill.name] then return end

  if drill.mining_target ~= nil and drill.mining_target.valid and drill.mining_target.amount > 0 then
    return -- this should also filter out pumpjacks and infinite resources
  end
  
  if drill.to_be_deconstructed() then
    return
  end
  
  -- Queue every drill within range of the depleted resource, check for resources in a few ticks
  table.insert(storage.drill_queue, {tick=game.tick+RESOURCE_CHECK_TIME, check_drill=drill})
end


function autodeconstruct.init_globals()
  -- Update the blacklist with the current setting value (whitespace, comma, and semicolon are valid separators)
  storage.blacklist = {}
  for token in string.gmatch(settings.global["autodeconstruct-blacklist"].value,"([^%s,;]+)") do
    if prototypes.entity[token] then
      storage.blacklist[token] = true
    end
  end
  
  -- Update the ore blacklist with the current setting value (whitespace, comma, and semicolon are valid separators)
  storage.ore_blacklist = {}
  for token in string.gmatch(settings.global["autodeconstruct-ore-blacklist"].value,"([^%s,;]+)") do
    if prototypes.entity[token] then
      storage.ore_blacklist[token] = true
    end
  end
  
  -- Find largest-range miner in the game (only check drills not on the blacklist)
  -- New in 2.0.57: Check quality-provided bonus to mining radius
  local max_quality_radius_bonus = -math.huge
  local max_quality = nil
  for _,q in pairs(prototypes.quality) do
    if q.mining_drill_mining_radius_bonus > max_quality_radius_bonus then
      max_quality_radius_bonus = q.mining_drill_mining_radius_bonus
      max_quality = q
    end
  end
  log("Found quality mining radius bonus of "..tostring(max_quality_radius_bonus))
  local new_max_radius = 1
  local drill_prototypes = prototypes.get_entity_filtered{{filter="type",type="mining-drill"}}
  for _, p in pairs(drill_prototypes) do
    if not storage.blacklist[p.name] then
      if p.mining_drill_radius then
        local this_offset = p.radius_visualisation_specification.offset
        local this_max_offset = math.max(math.abs(this_offset.x or this_offset[1]), math.abs(this_offset.y or this_offset[2]))
        local this_max_radius = p.get_mining_drill_radius(max_quality) + this_max_offset
        if this_max_radius > new_max_radius then
          new_max_radius = this_max_radius
          log("New max radius found with radius "..tostring(p.get_mining_drill_radius(max_quality)).." and offset "..serpent.line(this_offset).." for total radius of "..tostring(this_max_radius))
        end
      end
    end
  end
  storage.max_radius = math.ceil(new_max_radius*2)+1
  log("storage.max_radius updated to " .. tostring(storage.max_radius))
  if storage.debug then msg_all({"autodeconstruct-debug", "init_globals", "storage.max_radius updated to " .. storage.max_radius}) end

  -- Find the largest drop-distance in the game to search for targeting entities
  local new_target_radius = 1
  local targeter_prototypes = prototypes.get_entity_filtered{{filter="type",type={"mining-drill","inserter","assembling-machine","furnace","loader","loader-1x1"}}}
  for _,p in pairs(targeter_prototypes) do
    local drop_distance = 0
    if p.type == "inserter" then
      local drop_pos = p.inserter_drop_position or {0,0}
      drop_distance = math.max(math.abs(drop_pos.x or drop_pos[1]), math.abs(drop_pos.y or drop_pos[2]))
    elseif p.type == "loader" or p.type == "loader-1x1" then
      drop_distance = math.abs(p.container_distance)
    else
      local drop_pos = p.vector_to_place_result or {0,0}
      drop_distance = math.max(math.abs(drop_pos.x or drop_pos[1]), math.abs(drop_pos.y or drop_pos[2]))
    end
    if drop_distance > new_target_radius then
      new_target_radius = drop_distance
      log("New target found of "..p.name.." for radius of "..tostring(new_target_radius))
    end
  end
  storage.target_radius = math.ceil(new_target_radius*2)+1
  log("storage.target_radius updated to " .. tostring(storage.target_radius))
  if storage.debug then msg_all({"autodeconstruct-debug", "init_globals", "storage.target_radius updated to " .. storage.target_radius}) end

  pipeutil.cache_pipe_categories()
  
  -- Clear existing deconstruction queue_deconstruction
  storage.drill_queue = {}

  -- Look for existing depleted miners based on current settings, and re-add them to the queue
  local drill_entities = find_all_entities('mining-drill')
  for _, drill_entity in pairs(drill_entities) do
    check_drill(drill_entity)
  end
end


-- Find the target entity the miner is dropping in, if any
local function find_target(entity)
  if entity.drop_target then  -- works when target is a chest
    if storage.debug then msg_all({"autodeconstruct-debug", "find_target", "found " .. entity.drop_target.name .. " at " .. util.positiontostr(entity.drop_target.position)}) end
    return entity.drop_target
  else
    local entities = entity.surface.find_entities_filtered{position=entity.drop_position, limit=1}  -- works when target is a belt, or when entity is a ghost or hasn't started dropping in chest yet
    if #entities > 0 then
      if storage.debug then msg_all({"autodeconstruct-debug", "find_target", "found " .. entities[1].name .. " at " .. util.positiontostr(entities[1].position)}) end
      return entities[1]
    end
  end
end

local function find_targeting(entity, types)
  local targeting = {}
  local found_entities = entity.surface.find_entities_filtered{area=math2d.bounding_box.create_from_centre(entity.position, storage.target_radius), type=types}
  for _, e in pairs(found_entities) do
    if find_target(e) == entity then
      table.insert(targeting, e)
    end
  end
  local found_ghosts = entity.surface.find_entities_filtered{area=math2d.bounding_box.create_from_centre(entity.position, storage.target_radius), ghost_type=types}
  for _, e in pairs(found_ghosts) do
    if find_target(e) == entity then
      table.insert(targeting, e)
    end
  end

  if storage.debug then msg_all({"autodeconstruct-debug", "find_targeting", "found " .. #targeting .. " targeting"}) end

  return targeting
end

local function find_extracting(entity)
  local extracting = {}

  for _, e in pairs(entity.surface.find_entities_filtered{area=math2d.bounding_box.create_from_centre(entity.position, storage.target_radius), type="inserter"}) do
    if e.pickup_target == entity then
      table.insert(extracting, e)
    end
  end

  if storage.debug then msg_all({"autodeconstruct-debug", "find_extracting", "found " .. #extracting .. " extracting"}) end

  return extracting
end

local function queue_deconstruction(drill)
  storage.drill_queue = storage.drill_queue or {}
  local decon_tick = game.tick + RESOURCE_EJECT_TIME  -- by default, wait just long enough to eject the last item
  local timeout_tick = decon_tick + DECONSTRUCT_TIMEOUT  -- wait at most 30 seconds for items to clear out
  -- Drill to deconstruct
  local target = find_target(drill)
  -- Belt to deconstruct
  local target_line = beltutil.find_target_line(drill, target)
  if target_line then
    target = nil  -- Don't look for chest stuff if we have a transport line
  end
  local lp = nil
  -- Chest to deconstruct
  if target then
    if target.type == "logistic-container" then
      lp = target.get_logistic_point(defines.logistic_member_index.logistic_container)  -- logistic container means keep target and store logistic point
    elseif target.type ~= "container" and target.type ~= "linked-container" then
      target = nil  -- not logistic container and not container means don't keep target, it's something we can't deconstruct
    end
  end
  if target and not lp and #find_extracting(target) == 0 then
    target = nil  -- No inserters removing from this chest and no logistics, so no point in waiting to deconstruct
  end
  table.insert(storage.drill_queue, {tick=decon_tick, timeout=timeout_tick, drill=drill, target=target, target_lp=lp, target_line=target_line})
end


function autodeconstruct.on_resource_depleted(event)
  local resource = event.entity
  if storage.ore_blacklist[resource.name] or resource.prototype.infinite_resource then
    if storage.debug then
      msg_all({"autodeconstruct-debug", "on_resource_depleted tick=".. tostring(game.tick) .. ", amount=" .. resource.amount .. ", resource_category=" .. resource.prototype.resource_category .. ", infinite_resource=" .. tostring(resource.prototype.infinite_resource) .. ", ore blacklist=" .. tostring(storage.ore_blacklist[resource.name])})
    end
    return
  end
  local drills = resource.surface.find_entities_filtered{area=math2d.bounding_box.create_from_centre(resource.position, storage.max_radius), type='mining-drill'}
  
  if storage.debug then msg_all({"autodeconstruct-debug", "on_resource_depleted tick=".. tostring(game.tick) .. ", found " .. #drills  .. " drills"}) end

  for _, drill in pairs(drills) do
    check_drill(drill)
  end
end

function autodeconstruct.on_cancelled_deconstruction(event)
  if event.player_index ~= nil then return end  -- Don't override player commands to cancel deconstruction

  if storage.debug then msg_all({"autodeconstruct-debug", "on_cancelled_deconstruction", util.positiontostr(event.entity.position) .. " deconstruction timed out, checking again"}) end
  -- If another mod cancelled deconstruction of a miner, check this miner again
  check_drill(event.entity)
end


local function deconstruct_tiles(entity)
  if settings.global["autodeconstruct-remove-tiles"].value then
    entity.surface.deconstruct_area{area=entity.bounding_box, force=entity.force, super_forced=true}
  end
end


local function deconstruct_beacons(drill)
  local beacons = drill.get_beacons()
  if beacons == nil then return end   -- Drills that don't accept beacons return nil intead of empty list
  local beacon_busy = false
  for _,beacon in pairs(drill.get_beacons()) do
    if not beacon.to_be_deconstructed() and not storage.blacklist[beacon.name] then
      -- Receiving entities still show up if they are marked for deconstruction, so we have to check them all
      for _,receiver in pairs(beacon.get_beacon_effect_receivers()) do
        if receiver ~= drill then
          if not receiver.to_be_deconstructed() then
            beacon_busy = true
            break
          end
        end
      end
      if not beacon_busy then
        local ent_dat = {name=beacon.name, position=beacon.position}
        if beacon.order_deconstruction(beacon.force) then
          deconstruct_tiles(beacon)
          if beacon and beacon.valid then
            debug_message_with_position(beacon, "marked for deconstruction")
          else
            debug_message_with_position(ent_dat, "instantly deconstructed")
          end
        end
      end
    end
  end
end


-- Returns true if the belt is safe to deconstruct and the only targeter (if any) is the to-be-deconstructed drill
local function check_is_belt_deconstructable(target, drill, deconstruct_wired)
  if target ~= nil and target.minable and target.prototype.selectable_in_game and 
     (not storage.blacklist[target.name]) and beltutil.belt_type_check[target.type] and 
     (deconstruct_wired or not target.get_control_behavior()) then
    -- This belt is safe to deconstruct if necessary
    local targeting = find_targeting(target, {'mining-drill', 'inserter', 'assembling-machine', 'furnace'})
    
    if #targeting == 0 then
      debug_message_with_position(target, "checked "..tostring(target.unit_number).." for targeting entities, found "..tostring(#targeting)..". Not targeted by anything.")
      return true
    else
    
      for _,targeter in pairs(targeting) do
        if targeter ~= drill and not targeter.to_be_deconstructed() then
          debug_message_with_position(target, "checked "..tostring(target.unit_number).." for targeting entities, found "..tostring(#targeting)..". At least one is new, so belt is targeted.")
          return false  -- targeted by a different drill or inserter that is not marked for deconstruction, so it is in use
        end
      end
      
      debug_message_with_position(target, "checked "..tostring(target.unit_number).." for targeting entities, but the only one is the OLD miner.")
      return true
    end
  else
    return false
  end
end


local function belt_string(belt)
  return string.format("[%d] %s %s",belt.unit_number, belt.name , util.positiontostr(belt.position))
end

local function log_belts(belts, label)
  local log_list = {}
  for k=1,#belts do
    log_list[k] = belt_string(belts[k])
  end
  log(label..":\n"..serpent.block(log_list))
end

local function deconstruct_belts(drill)
  local to_deconstruct_list = {}
  local to_deconstruct_map = {}
  local deconstruct_wired = settings.global["autodeconstruct-remove-wired-belts"].value
  
  -- 1. Check if the target of this drill is a belt
  local target = find_target(drill)
  if not target or not target.valid or not (target.type == "transport-belt" or target.type == "underground-belt" or target.type == "splitter") then
    return
  end
  local starting_belt = target
  
  --    Start at the first belt and deconstruct and its upstream belts it if possible.
  --    Then check the belt downstream of that one in case it has another upstream path, and so on.
  --    Luckily, once a belt is marked for deconstruction, it no longer appears in belt_neighbours for anything
  
  -- 3. Go to each downstream belt and see if everything upstream of it can be removed
  local downstream_belts_to_check = {starting_belt}
  local loopcounter = 0
  while table_size(downstream_belts_to_check) > 0 do
    loopcounter = loopcounter + 1
    if #downstream_belts_to_check > 1 then
      --log_belts(downstream_belts_to_check, "Loop "..tostring(loopcounter).." START downstream_belts_to_check")
    end
    local next_start_belt = table.remove(downstream_belts_to_check)
    --log(string.format("Loop %d Checking next_start_belt = %s", loopcounter, belt_string(next_start_belt)))
    if check_is_belt_deconstructable(next_start_belt, drill, deconstruct_wired) then
      local upstream_belts_to_check = beltutil.get_belt_inputs(next_start_belt, to_deconstruct_map)  -- List of belts upstream of the first safe belt
      local upstream_belts_to_deconstruct = {}
      local upstream_belts_checked = {}
      upstream_belts_checked[next_start_belt.unit_number] = true
      
      -- 3a. Check if deconstructing this belt will interfere with sideloading downstream
      --  v
      -- >>>  bad to remove leftmost but okay to remove upper (input count = 2)  type 2A
      --
      --  v
      -- >>>  okay to remove any one belt  (input count = 3)  type 3
      --  ^ 
      --
      -- >>>  okay to remove any one belt (input count = 1)  type 1A
      --
      --  v
      --  >>  okay to remove any one belt (input count = 1)  type1B
      --
      --  v
      --  >>  bad to remove any belt (input count = 2)  type 2B
      --  ^
      --
      -- Conclusion: If input_count == 2, to be safe don't remove the last belt. It may be removed safely once more miners in the patch are exhausted.
      local sideload_safe = true
      local next_start_outputs = beltutil.get_belt_outputs(next_start_belt, to_deconstruct_map)
      for _,belt in pairs(next_start_outputs) do
        if belt.type == "transport-belt" and #belt.belt_neighbours.inputs == 2 then
          -- Check if it's type 2A or 2B
          -- If the other input belt is directly opposite from the original belt, then it is side-load unsafe
          for _,input in pairs(belt.belt_neighbours.inputs) do
            if input ~= next_start_belt then
              if input.position.x == next_start_belt.position.x or input.position.y == next_start_belt.position.y then
                sideload_safe = false  -- one of the output belts from this is side-loaded and might reconnect incorrectly if this start_belt were removed
                break
              end
            end
          end
          if not sideload_safe then
            break
          end
        end
      end
      if sideload_safe then
        table.insert(upstream_belts_to_deconstruct, next_start_belt)
      else
        debug_message_with_position(next_start_belt, "NOT SIDELOAD SAFE")
      end
      
      -- 3b. Follow the tree upstream, make a list of all the belts we travel and stop if we find another dropping entity
      local belt_in_use = false
      local upstreamloops = 0
      while table_size(upstream_belts_to_check) > 0 do
        upstreamloops = upstreamloops + 1
        local next_belt = table.remove(upstream_belts_to_check)
        --log(string.format("Loop %d checking upstream belt %s",loopcounter,belt_string(next_belt)))
        if not check_is_belt_deconstructable(next_belt, drill, deconstruct_wired) then
          -- Found a belt that has another target.  We can't remove any belts up this tree, including this next_start_belt.
          -- Also don't check any belts that are downstream of our current next_start_belt because something upstream is in use
          belt_in_use = true
          break
        end
        
        -- This belt does not have any other targets
        table.insert(upstream_belts_to_deconstruct, next_belt)
        upstream_belts_checked[next_belt.unit_number] = true
      
        -- Check if it has any upstream belts to keep traveling on
        for _,belt in pairs(beltutil.get_belt_inputs(next_belt, to_deconstruct_map)) do
          -- This is a new one, add it to check in a future iteration
          if not upstream_belts_checked[belt.unit_number] then
            table.insert(upstream_belts_to_check, belt)
          end
        end
      end
      
      -- 3c. If no other users were found, deconstruct all the upstream belts, 
      --   including the one we started at if it's sideload-safe, since if we got here we did not find any other users attached
      --   ALSO need to account for any new downstream belts from splitters found upstream
      if not belt_in_use then
        if #upstream_belts_to_deconstruct > 1 then
          --log_belts(upstream_belts_to_deconstruct, string.format("Loop %d upstream_belts_to_deconstruct",loopcounter))
        end
        for _,belt in pairs(upstream_belts_to_deconstruct) do
          if not to_deconstruct_map[belt.unit_number] then
            table.insert(to_deconstruct_list, belt)
            to_deconstruct_map[belt.unit_number] = true
          end
          
        end
        -- Once all the upstream belts are added to the list of already-checked belts,
        -- look at their downstream belts to see if there are any new ones
        
        for _,belt in pairs(upstream_belts_to_deconstruct) do
          local outputs = beltutil.get_belt_outputs(belt, to_deconstruct_map)
          for _,downstreambelt in pairs(outputs) do
            if downstreambelt ~= next_start_belt then
              --log(string.format("Loop %d Adding downstream belt found while adding upstream belts %s",loopcounter,belt_string(downstreambelt)))
              table.insert(downstream_belts_to_check,downstreambelt)
            end
          end
        end
        
        -- SKIP THIS PART since we ALWAYS find the belts downstream of the starting belt (it's included in the upstream belts we look downstream from)
        -- Keep looking downstream, even if this particular isn't sideload safe. If the next belt can be deconstructed then it doesn't matter.
        --for counter,belt in pairs(next_start_outputs) do
        --  if belt ~= next_start_belt then
        --    local found = false
        --    for _,downstreambelt in pairs(downstream_belts_to_check) do
        --      if belt == downstreambelt then
        --        found = true
        --        break
        --      end
        --    end
        --    if found == false then
        --      for _,upstreambelt in pairs(upstream_belts_to_deconstruct) do
        --        if belt == upstreambelt then
        --          found = true
        --          break
        --        end
        --      end
        --    end
        --    if found == false then
        --      log(string.format("Loop %d Adding downstream belt from next_start_outputs %s",loopcounter,belt_string(belt)))
        --      table.insert(downstream_belts_to_check, belt)
        --    end
        --  end
        --end
        
        upstream_belts_checked = {}
        upstream_belts_to_deconstruct = {}
      
      end
      --log_belts(to_deconstruct_list, string.format("Loop %d END to_deconstruct_list",loopcounter))
    end
  end
  
  -- After all that, we have a list of belts we "virtually deconstructed".
  -- Add this to the global queue as an entry that gets checked.
  -- The idea is that we only deconstruct belts before the timeout if they are empty and have no inputs.
  -- If there are loops or items stuck behind underground belts, those will wait for the timeout.
  -- Every time we successfully deconstruct an empty belt, extend the timeout a bit.
  -- Is there any sorting we can do to make it easier to find the next one that will be empty?
  table.insert(storage.drill_queue, {tick=game.tick+BELT_CHECK_TIME, timeout=game.tick+BELT_TIMEOUT, belt_list=to_deconstruct_list})
  
end
  

local function deconstruct_target(drill)
  local target = find_target(drill)

  if target ~= nil and target.minable and target.prototype.selectable_in_game and not storage.blacklist[target.name] then
    if target.type == "logistic-container" or target.type == "container" or target.type == "linked-container" then
      local targeting = find_targeting(target, {'mining-drill', 'inserter', 'assembling-machine', 'furnace'})

      if targeting ~= nil then
        local chest_is_idle = true
        for _, e in pairs(targeting) do
          if not e.to_be_deconstructed(e.force) and e ~= drill then
            chest_is_idle = false
            break
          end
        end

        if chest_is_idle then
          -- we are the only one targeting
          if target.to_be_deconstructed() then
            target.cancel_deconstruction(target.force)
          end
          local ent_dat = {name=target.name, position=target.position}
          if target.order_deconstruction(target.force) then
            deconstruct_tiles(target)
            if target and target.valid then
              debug_message_with_position(target, "marked for deconstruction")
            else
              debug_message_with_position(ent_dat, "instantly deconstructed")
            end
          else
            msg_all({"autodeconstruct-err-specific", "target.order_deconstruction", util.positiontostr(ent_dat.position) .. " failed to order deconstruction on " .. ent_dat.name})
          end
        end
      end
    end
  end
end


local function order_deconstruction(drill)
  if drill.to_be_deconstructed(drill.force) then
    debug_message_with_position(drill, "already marked, skipping")
    return
  end
  
  local surface_name = drill.surface.name
  for _,pfx in pairs(blacklist_surface_prefixes) do
    if string.match(surface_name, pfx) then
      debug_message_with_position(drill, "is on blacklisted surface "..surface_name..", skipping")
      return
    end
  end
  
  
  local has_fluid = false
  local pipeType = nil
  local pipesToBuild = nil
  if drill.fluidbox and #drill.fluidbox > 0 then
    has_fluid = true
    if not settings.global['autodeconstruct-remove-fluid-drills'].value then
      debug_message_with_position(drill, "has a non-empty fluidbox and fluid deconstruction is not enabled, skipping")
      return
    end
    -- Select the pipe to use for replacements, based on connection categories, collision masks, and available logistics inventory
    pipesToBuild = pipeutil.find_pipes_to_build(drill)
    --pipeType = settings.global['autodeconstruct-pipe-name'].value
    pipeType = pipeutil.choose_pipe(drill, pipesToBuild)
    
    if not pipeType then return end
  end

  
  
  if not settings.global['autodeconstruct-remove-wired'].value then
    if drill.get_circuit_network(defines.wire_connector_id.circuit_red) or drill.get_circuit_network(defines.wire_connector_id.circuit_green) then
      debug_message_with_position(drill, "is hooked up to the circuit network and wire deconstruction is not enabled, skipping")
      return
    end
  end

  if not drill.minable then
    debug_message_with_position(drill, "is not minable, skipping")
    return
  end

  if not drill.prototype.selectable_in_game then
    debug_message_with_position(drill, "is not selectable in game, skipping")
    return
  end

  if drill.has_flag("not-deconstructable") then
    debug_message_with_position(drill, "is flagged as not-deconstructable, skipping")
    return
  end

  if settings.global['autodeconstruct-preserve-inserter-chains'].value and drill.burner and #find_extracting(drill)>0 then
    debug_message_with_position(drill, "is part of inserter chain, skipping")
    return
  end

  -- end guards

  if settings.global['autodeconstruct-remove-target'].value then
    deconstruct_target(drill)
  end
  
  if settings.global['autodeconstruct-remove-beacons'].value then
    deconstruct_beacons(drill)
  end

  if settings.global['autodeconstruct-remove-belts'].value then
    deconstruct_belts(drill)
  end
  
  local ent_dat = {name=drill.name, position=drill.position}
  
  local pipe_ghosts = {}
  if has_fluid and settings.global['autodeconstruct-build-pipes'].value then
    debug_message_with_position(drill, "trying to add pipe blueprints")
    pipe_ghosts = pipeutil.build_pipes(drill, pipeType, pipesToBuild)
  end
  
  if drill.order_deconstruction(drill.force) then
    -- tile deconstruction order would also destroy pipe ghosts, so skip fluid drills
    if #pipe_ghosts == 0 then
      deconstruct_tiles(drill)
    end
    
    if drill and drill.valid then
      debug_message_with_position(drill, "marked for deconstruction")
      -- Check for inserters providing fuel to this miner
      if drill.valid and drill.burner then
        local targeting = find_targeting(drill, {'inserter'})
        for _,e in pairs(targeting) do
          e.order_deconstruction(e.force)
          deconstruct_tiles(e)
        end
      end
    else
      msg_all({"autodeconstruct-err-specific", "drill.order_deconstruction", util.positiontostr(ent_dat.position) .. " " .. ent_dat.name .. " instantly deconstructed, nothing else done" })
    end
  else
    -- If deconstruction fails, delete our preemptive pipe ghosts
    for _,g in pairs(pipe_ghosts) do
      g.destroy()
    end
    msg_all({"autodeconstruct-err-specific", "drill.order_deconstruction", util.positiontostr(drill.position) .. " " .. drill.name .. " failed to order deconstruction" })
  end
end


-- Queue contents:
-- Drill: {tick=decon_tick, timeout=timeout_tick, drill=drill, target=target, target_lp=lp, target_line=target_line, pipes={}}
function autodeconstruct.process_queue()
  if storage.drill_queue and next(storage.drill_queue) then
    for i, entry in pairs(storage.drill_queue) do
      
      if entry.check_drill then
        if not entry.check_drill.valid then
          table.remove(storage.drill_queue, i)
          break
        elseif game.tick >= entry.tick then
          if entry.check_drill.status == defines.entity_status.no_minable_resources then
            if storage.debug then msg_all({"autodeconstruct-debug", "process_queue", util.positiontostr(entry.check_drill.position) .. " found no compatible resources, deconstructing"}) end
            queue_deconstruction(entry.check_drill)
          else
            if storage.debug then msg_all({"autodeconstruct-debug", "process_queue", util.positiontostr(entry.check_drill.position) .. " still has resources"}) end
          end
          table.remove(storage.drill_queue, i)
          break
        end
        
      elseif entry.drill then
        local deconstruct_drill = false
        
        if not entry.drill.valid then
          -- no valid drill, or drill still has resources. purge from queue
          table.remove(storage.drill_queue, i)
          break
        
        elseif game.tick >= entry.timeout then
          -- When timeout occurs, deconstruct everything
          deconstruct_drill = true
          
        elseif game.tick >= entry.tick then
          -- Check conditions to see if we can deconstruct early
          if entry.target then
            if entry.target.valid then
              local inv = entry.target.get_inventory(defines.inventory.chest)
              if not inv or inv.is_empty() then
                deconstruct_drill = true  -- chest is empty
              elseif entry.lp and table_size(entry.lp.targeted_items_pickup)==0 then
                deconstruct_drill = true  -- no robots coming to pick up
              end
            else
              -- Target is not valid, deconstruct anyways
              deconstruct_drill = true
            end
          elseif entry.target_line then
            if entry.target_line.valid then
              if #entry.target_line == 0 then
                deconstruct_drill = true  -- belt transport line is empty
              end
            else
              deconstruct_drill = true
            end
          else
            deconstruct_drill = true -- no output chest or belt needs to be checked, deconstruct immediately
          end
        end
        
        if deconstruct_drill then
          order_deconstruction(entry.drill)
          table.remove(storage.drill_queue, i)
          break
        end
      
      elseif entry.belt_list then
        if not settings.global['autodeconstruct-remove-belts'].value then
          -- If belts are disabled, clear the queue of belts to remove.
          entry.belt_list = nil
        else
          -- Check the belt network for any that can be deconstructed
          if game.tick >= entry.timeout then
            -- When timeout hits, deconstruct everything at once
            for _,belt in pairs(entry.belt_list) do
              if belt and belt.valid then
                belt.order_deconstruction(belt.force)
                deconstruct_tiles(belt)
              end
            end
            -- Clear the queue entry
            table.remove(storage.drill_queue, i)
            break
          else
            for k,belt in pairs(entry.belt_list) do
              if not belt or not belt.valid then
                table.remove(storage.drill_queue[i].belt_list, k)
                break
              elseif #beltutil.get_belt_inputs(belt) == 0 and beltutil.is_belt_empty(belt) then
                -- Deconstruct this belt that has no inputs and no relevant contents
                belt.order_deconstruction(belt.force)
                deconstruct_tiles(belt)
                table.remove(storage.drill_queue[i].belt_list, k)
                -- Wait at least 5 seconds after the last empty belt was deconstructed before timing out
                storage.drill_queue[i].timeout = math.max(storage.drill_queue[i].timeout, game.tick + BELT_INACTIVITY_TIME)
                break
              end
            end
            -- If we deconstructed or cleared every belt as it emptied, clear queue entry
            if table_size(storage.drill_queue[i].belt_list) == 0 then
              table.remove(storage.drill_queue, i)
              break
            end
          end
        end
      
      else
        -- Corrupted queue entry
        table.remove(storage.drill_queue, i)
        break
      end
    end
  end
end
