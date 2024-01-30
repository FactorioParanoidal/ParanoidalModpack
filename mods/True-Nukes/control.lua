--local Profiler = require('__profiler__/profiler.lua')
local mushroomFunctions = require("MushroomCloudInBuilt.control")

local water = require("scripts.water-system")
local blast_system = require("scripts.blast-system")
local thermal_system = require("scripts.thermal-system")
local crater_system = require("scripts.crater-system")
local crater_system_se = require("scripts.crater-system-se")
local fireball_system = require("scripts.fireball-system")
local building_system = require("scripts.building-system")
local achievement_system = require("scripts.achievement-system")

local createBlastSoundsAndFlash = mushroomFunctions[1]
script.on_init(function()
  global.nuclearTests = {}       -- a map of force-index to maps from atomic-test-pack to count...
  global.thermalBlasts = {}				-- a simple array, with elements: {surface_index, position, force, thermal_max_r, initialDamage, fireball_r, x, y}, each as a key of the map
  global.blastWaves = {}					-- a simple array, with elements:
  --{r = currrent explosion radius, pos = centre position, pow = initial blast multiplier (usually initial r*r)
  -- , max = maximum radius, s = surface index, fire = leave fires (true for thermobarics, false for nukes), damage_init = starting damage, speed = how far to jump every round, fire_rad = the radius to which the fire wave is solid
  -- , blast_min_damage = amount of extra damage to add all the time, itt = the number of itterations done, doItts = whether to time slice the blast, ittframe = keeps track of frame count for time slicing
  -- , force = force of the cause of the explosion - allows allocating kills correctly, cause = allows allocating kills to the originator})

  global.nukeBuildings = {} 				-- array of the LuaEntities for any nukeBuildings
  global.optimisedNukes = {} 				-- has keys:
  --position, surface_index, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, tree_fire_max_r, thermal_max_r, check_craters
  --used for doing chunk-by-chunk loading of detonation results

  global.cratersFast = {} 				-- map: cratersFast[surface index][xposition][yposition] = the highest water height in that area (x, y in units of 10)
  global.cratersFastData = {}				-- map: cratersFastData[surface index] =
  -- {synch =  1-4 making deep water travel slower, xCount = number of x chunks on this surface, xCountSoFar = number of x chunks done so far this round, xDone = all x values done so far this round}
  global.cratersFastItterationCount = 0	-- the counter of ticks for circling x chunks - counts up to 53


  global.cratersSlow = {} 				-- array of {t = time waiting - 20s units, x = xin units of 32, y = y in units of 32, surface = the surface index}
end)


local corpseMap = {}
corpseMap["biter-spawner"] = "biter-spawner-corpse"
corpseMap["spitter-spawner"] = "spitter-spawner-corpse"

corpseMap["small-biter"] = "small-biter-corpse"
corpseMap["medium-biter"] = "medium-biter-corpse"
corpseMap["big-biter"] = "big-biter-corpse"
corpseMap["behemoth-biter"] = "behemoth-biter-corpse"

corpseMap["small-spitter"] = "small-spitter-corpse"
corpseMap["medium-spitter"] = "medium-spitter-corpse"
corpseMap["big-spitter"] = "big-spitter-corpse"
corpseMap["behemoth-spitter"] = "behemoth-spitter-corpse"

corpseMap["small-worm-turret"] = "small-worm-corpse"
corpseMap["medium-worm-turret"] = "medium-worm-corpse"
corpseMap["big-worm-turret"] = "big-worm-corpse"
corpseMap["behemoth-worm-turret"] = "behemoth-worm-corpse"

--not sure this saves THAT much, particularly considering the complexity...Disabled temporarily...
--corpseMap["solar-panel"] = "solar-panel-remnants"
--corpseMap["accumulator"] = "accumulator-remnants"
--corpseMap["transport-belt"] = "transport-belt-remnants"
--corpseMap["fast-transport-belt"] = "fast-transport-belt-remnants"
--corpseMap["express-transport-belt"] = "express-transport-belt-remnants"
--corpseMap["stone-wall"] = "wall-remnants"



local function tickHandler(event)
  mushroomFunctions[2](event)
  if(global.blastWaves ==nil) then
    global.blastWaves = {}
  end
  if(global.nukeBuildings ==nil) then
    global.nukeBuildings = {}
  end
  if(global.thermalBlasts ==nil) then
    global.thermalBlasts = {}
  end
  if(next(global.blastWaves) ~= nil) then
    for i,blast in pairs(global.blastWaves) do
      blast_system.move_blast(i,blast,0, corpseMap)
    end
    --  else
    --    Profiler.Stop(false, "")
  end
  if (#global.thermalBlasts>0) then
    thermal_system.atomic_thermal_blast_move_along(corpseMap)
  end
  water.fastFill(event)

  building_system.checkBuildings()
end
script.on_event(defines.events.on_tick, tickHandler);







local function find_event_position(event)
  if(event.target_position)then
    return event.target_position;
  elseif(event.target_entity and event.target_entity.position) then
    return event.target_entity.position;
  elseif(event.source_position)then
    return event.source_position;
  elseif(event.source_entity and event.source_entity.position) then
    return event.source_entity.position
  else
    return nil;
  end
end

--chunkLoaderStruct: surface_index, blastIndex, blastId, force, source, position, crater_internal_r, crater_external_r, fireball_r, blast_max_r, init_blast, blast_min_damage, thermal_max_r, init_thermal
local function optimisedChunkLoadHandler(chunkPosAndArea, chunkLoaderStruct, killPlanes)
  local x = chunkPosAndArea.x*32
  local y = chunkPosAndArea.y*32
  local originPos = chunkLoaderStruct.position
  local surface_index = chunkLoaderStruct.surface_index
  local r1 = math.sqrt((x-originPos.x)*(x-originPos.x) + (y-originPos.y)*(y-originPos.y))
  local r2 = math.sqrt((x+32-originPos.x)*(x+32-originPos.x) + (y-originPos.y)*(y-originPos.y))
  local r3 = math.sqrt((x-originPos.x)*(x-originPos.x) + (y+32-originPos.y)*(y+32-originPos.y))
  local r4 = math.sqrt((x+32-originPos.x)*(x+32-originPos.x) + (y+32-originPos.y)*(y+32-originPos.y))
  local minR = math.min(r1, r2, r3, r4)
  local maxR = math.max(r1, r2, r3, r4)
  local blastIndex = chunkLoaderStruct.blastIndex
  local blastId = chunkLoaderStruct.blastId
  if  ((minR<chunkLoaderStruct.blast_max_r) or (minR<chunkLoaderStruct.thermal_max_r)) then
    local cause = chunkLoaderStruct.source;
    local force = chunkLoaderStruct.force;
    local blastR = 0
    if(global.blastWaves == nil or global.blastWaves[blastIndex] == nil or global.blastWaves[blastIndex].blastId ~= blastId) then
      blastR = -1
    else
      blastR = global.blastWaves[blastIndex].r
    end

    --fireball
    if(minR<chunkLoaderStruct.fireball_r) then
      fireball_system.partial_fireball(surface_index, chunkLoaderStruct, chunkPosAndArea, originPos, x, y, killPlanes, force, cause, corpseMap)
    end

    -- thermal
    if(minR<chunkLoaderStruct.thermal_max_r) then
      thermal_system.chunk_loaded(chunkLoaderStruct, surface_index, originPos, x, y, chunkPosAndArea, killPlanes, force, cause, corpseMap)
    end

    -- blast
    if((blastR == -1 and minR<chunkLoaderStruct.blast_max_r) or (minR<blastR)) then
      local blastSq = blastR*blastR
      if(blastR == -1) then
        blastSq = math.max(r1*r1, r2*r2, r3*r3, r4*r4)+1
      end
      blast_system.chunk_loaded(chunkLoaderStruct, surface_index, originPos, chunkPosAndArea, x, y, killPlanes, blastSq, force, cause, corpseMap)
    end

    local ang1 = math.atan2(y-originPos.y, x-originPos.x)
    local ang2 = math.atan2(y-originPos.y, x+32-originPos.x)
    local ang3 = math.atan2(y+32-originPos.y, x-originPos.x)
    local ang4 = math.atan2(y+32-originPos.y, x+32-originPos.x)
    if((ang1<-1.5 or ang2<-1.5 or ang3<-1.5 or ang4<-1.5) and (ang1>1.5 or ang2>1.5 or ang3>1.5 or ang4>1.5))then
      if(ang1<0) then
        ang1 = ang1+6.283185307
      end
      if(ang2<0) then
        ang2 = ang2+6.283185307
      end
      if(ang3<0) then
        ang3 = ang3+6.283185307
      end
      if(ang4<0) then
        ang4 = ang4+6.283185307
      end
    end
    local crater_system_to_use = crater_system
    if((game.active_mods["space-exploration"]) and (game.surfaces[surface_index].count_tiles_filtered{position = originPos, radius=2, name = crater_system_se.interesting_tiles, limit=1} ~= 0)) then
      crater_system_to_use = crater_system_se
    end
    if(settings.global["actually-generate-crater"].value) then
      -- crater
      if((minR<chunkLoaderStruct.fireball_r*1.1+4) and (maxR>chunkLoaderStruct.crater_external_r-4) ) then
        crater_system_to_use.chunk_loaded_outer(surface_index, chunkPosAndArea, chunkLoaderStruct, originPos, x, y, ang1, ang2, ang3, ang4, minR, maxR)
      end

      if(minR<chunkLoaderStruct.crater_external_r*1.1+4) then
        crater_system_to_use.chunk_loaded(surface_index, chunkPosAndArea, chunkLoaderStruct, originPos, x, y, ang1, ang2, ang3, ang4, minR, maxR)
      end
    end
    water.check_fill(surface_index, chunkPosAndArea, x, y)
  end
end



local function atomic_weapon_hit_optimised(surface_index, source, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, small_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters)
  -- find forces, positions, etc.
  --  Profiler.Start()

  local force
  if(settings.global["nukes-cause-pollution"].value) then
    game.surfaces[surface_index].pollute(position, polution)
  end
  if(not (source==nil)) then
    force = source.force
  else
    force = "neutral"
  end
  local cause = source;
  
  local buildingCount = 0
  if(force)then
    buildingCount = game.surfaces[surface_index].count_entities_filtered{force = force, type = {"furnace", "assembling-machine"}, limit = 200}
  end
  
  if(not global.blastWaves) then
    global.blastWaves = {};
  end
  local blastId = math.random();
  table.insert(global.blastWaves, {r = fireball_r, pos = position, blastId=blastId, pow = fireball_r*fireball_r, max = blast_max_r, s = surface_index, fire = false, damage_init = 5000.0, speed = 8, fire_rad = 0, blast_min_damage = 0, itt = 1, doItts = true, ittframe = 1, force = force, cause = cause})
  local index = #global.blastWaves
  local chunkData = {surface_index=surface_index, blastIndex=index, blastId=blastId, force=force, source=cause, position=position, crater_internal_r=crater_internal_r,
    crater_external_r=crater_external_r, fireball_r=fireball_r, blast_max_r=blast_max_r, init_blast=5000.0, blast_min_damage=0, thermal_max_r=thermal_max_r, init_thermal=5000.0};
  local chunks = {}
  for chunk in game.surfaces[surface_index].get_chunks() do
    if(game.surfaces[surface_index].is_chunk_generated(chunk)) then
      table.insert(chunks, chunk);
    end
  end
  for _,chunk in pairs(chunks) do
    --local xdiff = chunk.x*32+16-position.x
    --local ydiff = chunk.y*32+16-position.y
    --log(math.sqrt(xdiff*xdiff+ydiff*ydiff));
    optimisedChunkLoadHandler(chunk, chunkData, true);
  end
  if(not global.optimisedNukes) then
    global.optimisedNukes = {}
  end
  table.insert(global.optimisedNukes, chunkData);

  if(force and buildingCount>=1000 and game.surfaces[surface_index].count_entities_filtered{force = force, type = {"furnace", "assembling-machine"}}<20) then
    achievement_system.nukedEverything(force)
  end
end


local function atomic_weapon_hit(surface_index, source, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, small_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters)
  -- find forces, positions, etc.
  --  Profiler.Start()
  local force
  if(settings.global["nukes-cause-pollution"].value) then
    game.surfaces[surface_index].pollute(position, polution)
  end
  if(not (source==nil)) then
    force = source.force
  else
    force = "neutral"
  end
  local cause = source;
  
  local buildingCount = 0
  if(force)then
    buildingCount = game.surfaces[surface_index].count_entities_filtered{force = force, type = {"furnace", "assembling-machine"}, limit = 200}
  end
  
  -- force the map to generate (should be reasonably quick as it is pre-loaded)
  game.surfaces[surface_index].request_to_generate_chunks(position, load_r/32)
  game.surfaces[surface_index].force_generate_chunk_requests()


  for _,f in pairs(game.forces) do
    f.chart(game.surfaces[surface_index], {{position.x-visable_r,position.y-visable_r},{position.x+visable_r,position.y+visable_r}})
  end

  fireball_system.full_fireball(surface_index, position, fireball_r, crater_external_r, force, cause, corpseMap)

  local crater_system_to_use = crater_system
    if((game.active_mods["space-exploration"]) and (game.surfaces[surface_index].count_tiles_filtered{position = originPos, radius=2, name = crater_system_se.interesting_tiles, limit=1} ~= 0)) then
    crater_system_to_use = crater_system_se
  end
  if(settings.global["actually-generate-crater"].value) then
    if(crater_external_r>150) then --use efficient crater generator (ignores height for lakes)
      crater_system_to_use.nukeTileChangesHeightAwareHuge(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
    else
      crater_system_to_use.nukeTileChangesHeightAware(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
    end
  end
  -- light fires as nessesary
  if(flame_proportion>0 and crater_system_to_use.use_fires) then
    for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fire_outer_r}) do
      local rand = math.random(0, fire_outer_r)
      if(math.random(0, 1)+flame_proportion/8>1 and rand*rand>(v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)) then
        if((not(water.waterInCraterGoingOutDepths[v.name] == nil)) and water.waterInCraterGoingOutDepths[v.name] > -10) then
          game.surfaces[surface_index].create_entity{name="thermobaric-wave-fire",position=v.position}
        else
          game.surfaces[surface_index].create_entity{name="nuclear-fire",position=v.position}
        end
      end
    end
  end
  if (settings.global["nuke-random-fires"].value and create_small_fires and crater_system_to_use.use_fires) then
    for i=(fire_outer_r*fire_outer_r/10),(small_fire_max_r*small_fire_max_r/10) do
      local dist = math.random(fire_outer_r, math.random(fire_outer_r, small_fire_max_r))
      local angle = math.random()*3.1416*2
      game.surfaces[surface_index].create_entity{name="thermobaric-wave-fire",position={position.x+dist*math.cos(angle), position.y+dist*math.sin(angle)}}
    end
  end
  thermal_system.atomic_thermal_blast(surface_index, position, force, cause, thermal_max_r, 5000, fireball_r, corpseMap)
  table.insert(global.blastWaves, {r = fireball_r, pos = position, pow = fireball_r*fireball_r, max = blast_max_r, s = surface_index, fire = false, damage_init = 5000.0, speed = 8, fire_rad = 0, blast_min_damage = 0, itt = 1, doItts = true, ittframe = 1, force = force, cause = cause})

  if(force and buildingCount>=200 and game.surfaces[surface_index].count_entities_filtered{force = force, type = {"furnace", "assembling-machine"}}<20) then
    achievement_system.nukedEverything(force)
  end
  
end


local function thermobaric_weapon_hit(surface_index, source, position, explosion_r, blast_max_r, fire_r, load_r, visable_r)
  local force
  local cause = source;
  if(not (source==nil)) then
    force = source.force
  else
    force = "enemy"
  end
  game.surfaces[surface_index].request_to_generate_chunks(position, load_r/32)
  game.surfaces[surface_index].force_generate_chunk_requests()

  for _,f in pairs(game.forces) do
    f.chart(game.surfaces[surface_index], {{position.x-visable_r,position.y-visable_r},{position.x+visable_r,position.y+visable_r}})
  end
  for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=explosion_r}) do
    game.surfaces[surface_index].create_entity{name="fire-flame",position=v.position}
  end
  table.insert(global.blastWaves, {r = explosion_r, pos = position, pow = explosion_r*explosion_r, max = blast_max_r, s = surface_index, fire = true, damage_init = 600.0, speed = 1, fire_rad = fire_r, blast_min_damage = 30, itt = 1, doItts = false, ittframe = 1, force = force, cause = cause})
end



local function nukeFiredScan(event)
  local entity;
  if(event.entity) then
    entity = event.entity
  elseif(event.source_entity) then
    entity = event.source_entity
  end
  if (entity) then
    local position = event.target_entity.position
    if(string.match(entity.prototype.name, ".*-atomic-2-stage-100kt")) then
      if (not settings.global["optimise-100kt"].value) then
        game.surfaces[event.surface_index].request_to_generate_chunks(position, 1500/32)
      else
        game.surfaces[event.surface_index].request_to_generate_chunks(position, 200/32)
      end
    elseif(string.match(entity.prototype.name, ".*-atomic-15kt") or string.match(entity.prototype.name, ".*-atomic-2-stage-15kt")) then
      game.surfaces[event.surface_index].request_to_generate_chunks(position, 1000/32)
    elseif(string.match(entity.prototype.name, ".*-atomic-1kt")) then
      game.surfaces[event.surface_index].request_to_generate_chunks(position, 800/32)
    else
      game.surfaces[event.surface_index].request_to_generate_chunks(position, 400/32)
    end
  end
end

-- calculate polution as 1*tonnage + 1000*uranium input + 100*californium input + 10000*tritium input
-- polution is capped at 500000
--local function atomic_weapon_hit(surface_index, source_entity, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, tree_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters)
script.on_event(defines.events.on_script_trigger_effect, function(event)
  local mult = 25 / settings.global["general-nuke-range-scaledown"].value
  local thermal_mult = 30 / settings.global["general-nuke-range-scaledown"].value
  local position = find_event_position(event);

  local source = event.source_entity

  if(event.effect_id=="Thermobaric Weapon hit small-") then
    thermobaric_weapon_hit(event.surface_index, source, position, 1, 15, 10, 10, 10);
  elseif(event.effect_id=="Thermobaric Weapon hit small") then
    thermobaric_weapon_hit(event.surface_index, source, position, 3, 30, 20, 30, 15);
  elseif(event.effect_id=="Thermobaric Weapon hit small+") then
    thermobaric_weapon_hit(event.surface_index, source, position, 4, 45, 30, 45, 25);
  elseif(event.effect_id=="Thermobaric Weapon hit medium-") then
    thermobaric_weapon_hit(event.surface_index, source, position, 5, 60, 40, 60, 35);
  elseif(event.effect_id=="Thermobaric Weapon hit medium") then
    thermobaric_weapon_hit(event.surface_index, source, position, 6, 80, 50, 80, 50);
  elseif(event.effect_id=="Thermobaric Weapon hit large") then
    thermobaric_weapon_hit(event.surface_index, source, position, 9, 120, 100, 120, 100);
  elseif(event.effect_id=="Atomic Weapon hit 0.1t") then
    atomic_weapon_hit(event.surface_index, source, position, 0, 1, 1, 3, mult*1, 15, thermal_mult*1, 15, 15, 300.1, 8, true, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 60, 100, 200, 700, 10, 0.06);
  elseif(event.effect_id=="Atomic Weapon hit 0.5t") then
    atomic_weapon_hit(event.surface_index, source, position, 0, 3, 3, 5, mult*3, 25, thermal_mult*3, 30, 20, 700.5, 4, true, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 80, 150, 300, 1000, 20, 0.12);
  elseif(event.effect_id=="Atomic Weapon hit 2t") then
    atomic_weapon_hit(event.surface_index, source, position, 0, 5, 5, 15, mult*5, 50, thermal_mult*5, 100, 50, 1302, 3, true, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 100, 250, 500, 2000, 40, 0.25);
  elseif(event.effect_id=="Atomic Weapon hit 4t") then
    atomic_weapon_hit(event.surface_index, source, position, 1, 6, 7, 20, mult*7, 120, thermal_mult*7, 180, 80, 4004, 2, true, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 120, 300, 900, 4000, 70, 0.4);
  elseif(event.effect_id=="Atomic Weapon hit 8t") then
    atomic_weapon_hit(event.surface_index, source, position, 3, 8, 14, 25, mult*14, 200, thermal_mult*14, 180, 100, 9008, 1, true, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 150, 400, 1250, 10000, 100, 0.6);
  elseif(event.effect_id=="Atomic Weapon hit 20t") then
    atomic_weapon_hit(event.surface_index, source, position, 5, 10, 20, 30, mult*20, 320, thermal_mult*20, 180, 150, 30020, 0.5, true, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 250, 600, 1800, 15000, 160, 1);
  elseif(event.effect_id=="Atomic Weapon hit 500t") then
    atomic_weapon_hit(event.surface_index, source, position, 10, 20, 40, 35, mult*40, 400, thermal_mult*40, 400, 300, 75500, 0.25*settings.global["large-nuke-fire-scaledown"].value, true, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 400, 800, 2500, 25000, 300, 2);
  elseif(event.effect_id=="Atomic Weapon hit 1kt") then
    atomic_weapon_hit(event.surface_index, source, position, 20, 40, 80, 75, mult*80/settings.global["large-nuke-range-scaledown"].value, 800, thermal_mult*80/settings.global["large-nuke-range-scaledown"].value, 800, 300, 101000, 0.25*settings.global["large-nuke-fire-scaledown"].value, true, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 600, 1200, 8000, 60000, 600, 4);
  elseif(event.effect_id=="Atomic Weapon hit 15kt") then
    atomic_weapon_hit(event.surface_index, source, position, 50, 100, 200, 150, mult*200/settings.global["huge-nuke-range-scaledown"].value, 1000, thermal_mult*200/settings.global["huge-nuke-range-scaledown"].value, 1000, 500, 315000, 0.125*settings.global["huge-nuke-fire-scaledown"].value, false, true);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 1500, 3000, 20000, 100000, 1500, 8);
  elseif(event.effect_id=="Atomic Weapon hit 100kt") then
    local blastD = mult*500/settings.global["really-huge-nuke-range-scaledown"].value;
    if not settings.global["optimise-100kt"].value then
      atomic_weapon_hit(event.surface_index, source, position, 90, 180, 500, 400, blastD, 2500, thermal_mult*500/settings.global["really-huge-nuke-range-scaledown"].value, 1500, 1000, 450000, 0, false, false);
    else
      atomic_weapon_hit_optimised(event.surface_index, source, position, 90, 180, 500, 400, blastD, 2500, thermal_mult*500/settings.global["really-huge-nuke-range-scaledown"].value, 1500, 1000, 450000, 0, false, false);
    end
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 2700, 5400, 36000, 200000, 2700, 16);
  elseif(event.effect_id=="Atomic Weapon hit 1Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 190, 390, 1200, 1000, mult*1200/settings.global["really-huge-nuke-range-scaledown"].value, 5000, thermal_mult*1200/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 6000, 10000, 60000, 400000, 5000, 32);
  elseif(event.effect_id=="Atomic Weapon hit 5Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 330, 660, 2400, 2000, mult*2400/settings.global["really-huge-nuke-range-scaledown"].value, 10000, thermal_mult*2400/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 12000, 20000, 120000, 800000, 10000, 64);
  elseif(event.effect_id=="Atomic Weapon hit 10Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 420, 830, 3150, 4000, mult*3150/settings.global["really-huge-nuke-range-scaledown"].value, 15000, thermal_mult*3150/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 18000, 30000, 180000, 1200000, 15000, 96);
  elseif(event.effect_id=="Atomic Weapon hit 50Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 710, 1420, 6000, 8000, mult*6000/settings.global["really-huge-nuke-range-scaledown"].value, 30000, thermal_mult*6000/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 36000, 60000, 360000, 2400000, 30000, 192);
  elseif(event.effect_id=="Atomic Weapon hit 100Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 900, 1800, 8000, 12000, mult*8000/settings.global["really-huge-nuke-range-scaledown"].value, 40000, thermal_mult*8000/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 48000, 80000, 480000, 3200000, 40000, 256);
  elseif(event.effect_id=="Atomic Weapon hit 1Gt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 1800, 3600, 16000, 24000, mult*16000/settings.global["really-huge-nuke-range-scaledown"].value, 80000, thermal_mult*16000/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 96000, 160000, 960000, 6400000, 80000, 512);
  elseif(event.effect_id=="Nuke firing") then
    nukeFiredScan(event);
  elseif(event.effect_id=="Mega-nuke built") then
    table.insert(global.nukeBuildings, source)
  end

end)



script.on_nth_tick(1207, water.slowFill)

script.on_event(defines.events.on_chunk_generated, function(event)
  if(global.optimisedNukes == nil) then
    global.optimisedNukes = {}
  end
  if(#global.optimisedNukes>0) then
    for _,chunkData in pairs(global.optimisedNukes) do
      if(chunkData.surface_index == event.surface.index) then
        optimisedChunkLoadHandler({x=event.position.x, y=event.position.y, area=event.area}, chunkData, false);
      end
    end
  end
end)


local function clearAllCraters(surface)
  local l = {};
  for _,t in pairs(surface.find_tiles_filtered({name={"nuclear-deep", "nuclear-deep-shallow-fill", "nuclear-deep-fill"}})) do
    table.insert(l, {position=t.position, name = "deepwater"});
  end
  for _,t in pairs(surface.find_tiles_filtered({name={"nuclear-crater", "nuclear-crater-fill"}})) do
    table.insert(l, {position=t.position, name = "water"});
  end
  for _,t in pairs(surface.find_tiles_filtered({name={"nuclear-shallow"}})) do
    table.insert(l, {position=t.position, name = "water-shallow"});
  end
  surface.set_tiles(l);
end

local function getGlobal()
  return global;
end
local function setGlobal(newglobal)
  global = newglobal;
end
remote.add_interface("True-Nukes Scripts", {
  thermobaricWeaponHit = thermobaric_weapon_hit,
  atomicWeaponHit = atomic_weapon_hit,
  createBlastSoundsAndFlash = createBlastSoundsAndFlash,
  clearAllCraters = clearAllCraters,
  getGlobal = getGlobal,
  setGlobal = setGlobal,
});
