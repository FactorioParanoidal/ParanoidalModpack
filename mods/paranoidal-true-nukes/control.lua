local mushroomFunctions = require("MushroomCloudInBuilt.control")

local water = require("scripts.water-system")
local blast_system = require("scripts.blast-system")
local thermal_system = require("scripts.thermal-system")
local crater_system = require("scripts.crater-system")
local fireball_system = require("scripts.fireball-system")
local detonation_jobs = require("scripts.detonation-jobs")
local building_system = require("scripts.building-system")
local achievement_system = require("scripts.achievement-system")

local createBlastSoundsAndFlash = mushroomFunctions[1]
local function init_storage()
  storage.nuclearTests = storage.nuclearTests or {}       -- a map of force-index to maps from atomic-test-pack to count...
  storage.thermalBlasts = storage.thermalBlasts or {}				-- a simple array, with elements: {surface_index, position, force, thermal_max_r, initialDamage, fireball_r, x, y}, each as a key of the map
  storage.blastWaves = storage.blastWaves or {}					-- a simple array, with elements:
  --{r = currrent explosion radius, pos = centre position, pow = initial blast multiplier (usually initial r*r)
  -- , max = maximum radius, s = surface index, fire = leave fires (true for thermobarics, false for nukes), damage_init = starting damage, speed = how far to jump every round, fire_rad = the radius to which the fire wave is solid
  -- , blast_min_damage = amount of extra damage to add all the time, itt = the number of itterations done, doItts = whether to time slice the blast, ittframe = keeps track of frame count for time slicing
  -- , force = force of the cause of the explosion - allows allocating kills correctly, cause = allows allocating kills to the originator})

  storage.nukeBuildings = storage.nukeBuildings or {} 				-- array of the LuaEntities for any nukeBuildings
  storage.optimisedNukes = storage.optimisedNukes or {} 				-- has keys:
  --position, surface_index, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, tree_fire_max_r, thermal_max_r, check_craters
  --used for doing chunk-by-chunk loading of detonation results

  storage.cratersFast = storage.cratersFast or {} 				-- map: cratersFast[surface index][xposition][yposition] = the highest water height in that area (x, y in units of 10)
  storage.cratersFastData = storage.cratersFastData or {}				-- map: cratersFastData[surface index] =
  -- {synch =  1-4 making deep water travel slower, xCount = number of x chunks on this surface, xCountSoFar = number of x chunks done so far this round, xDone = all x values done so far this round}
  storage.cratersFastItterationCount = storage.cratersFastItterationCount or 0	-- the counter of ticks for circling x chunks - counts up to 53


  storage.cratersSlow = storage.cratersSlow or {} 				-- array of {t = time waiting - 20s units, x = xin units of 32, y = y in units of 32, surface = the surface index}
  storage.chunkJobs = storage.chunkJobs or {}         -- queued chunk work of large detonations (9.0.0)
  storage.TN_lightEffects = storage.TN_lightEffects or {}
end
script.on_init(init_storage)
script.on_configuration_changed(init_storage)


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



local function new_blast_id()
  storage.blastNextId = (storage.blastNextId or 0) + 1
  return storage.blastNextId
end

-- Large detonations: their generated chunks are queued and handled a few per tick (9.0.0; True Nukes
-- did every generated chunk of the surface in the detonation tick). Budget per tick, checked after each
-- chunk: deaths in the fireball (about 0.2 ms each with the build's mods: 32 chunks of a dense base took
-- 1.1 s), entities hit by the heat and blast, chunks with crater tiles (about 6 ms each), chunks.
local CHUNK_JOB_DEATH_BUDGET = 300
local CHUNK_JOB_HIT_BUDGET = 1500
local CHUNK_JOB_CRATER_BUDGET = 6
local CHUNK_JOB_MAX_CHUNKS = 32
local optimisedChunkLoadHandler -- defined below

local function run_chunk_jobs()
  local id, job = next(storage.chunkJobs)
  if not id then return end
  local killed, hit, craters, chunks = 0, 0, 0, 0
  while job.i <= #job.chunks and killed < CHUNK_JOB_DEATH_BUDGET and hit < CHUNK_JOB_HIT_BUDGET
    and craters < CHUNK_JOB_CRATER_BUDGET and chunks < CHUNK_JOB_MAX_CHUNKS do
    local c = job.chunks[job.i]
    job.i = job.i + 1
    chunks = chunks + 1
    local f, k, cr = optimisedChunkLoadHandler(c, job.data, true)
    hit, killed = hit + (f or 0), killed + (k or 0)
    if cr then craters = craters + 1 end
  end
  if job.i > #job.chunks then
    storage.chunkJobs[id] = nil
    local force, surface = job.data.force, game.surfaces[job.data.surface_index]
    if surface and type(force) ~= "string" and force.valid and (job.building_count or 0) >= 1000
      and surface.count_entities_filtered{force = force, type = {"furnace", "assembling-machine"}} < 20 then
      achievement_system.nukedEverything(force)
    end
  end
end

local function tickHandler(event)
  mushroomFunctions[2](event)
  if(storage.blastWaves ==nil) then
    storage.blastWaves = {}
  end
  if(storage.nukeBuildings ==nil) then
    storage.nukeBuildings = {}
  end
  if(storage.thermalBlasts ==nil) then
    storage.thermalBlasts = {}
  end
  if(next(storage.blastWaves) ~= nil) then
    for i,blast in pairs(storage.blastWaves) do
      blast_system.move_blast(i,blast,0, corpseMap)
    end
    --  else
    --    Profiler.Stop(false, "")
  end
  if next(storage.chunkJobs) then
    run_chunk_jobs()
  end
  detonation_jobs.tick(corpseMap)
  if next(storage.thermalBlasts) then
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
-- Returns the entities hit by the heat and blast, the entities killed in the fireball and whether crater
-- tiles were changed (the budget of run_chunk_jobs).
optimisedChunkLoadHandler = function(chunkPosAndArea, chunkLoaderStruct, killPlanes)
  local found, killed, crater = 0, 0, false
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
    if(storage.blastWaves == nil or storage.blastWaves[blastIndex] == nil or storage.blastWaves[blastIndex].blastId ~= blastId) then
      blastR = -1
    else
      blastR = storage.blastWaves[blastIndex].r
    end

    --fireball
    if(minR<chunkLoaderStruct.fireball_r) then
      killed = fireball_system.partial_fireball(surface_index, chunkLoaderStruct, chunkPosAndArea, originPos, x, y, killPlanes, force, cause, corpseMap) or 0
    end

    -- thermal
    if(minR<chunkLoaderStruct.thermal_max_r) then
      found = found + (thermal_system.chunk_loaded(chunkLoaderStruct, surface_index, originPos, x, y, chunkPosAndArea, killPlanes, force, cause, corpseMap) or 0)
    end

    -- blast
    if((blastR == -1 and minR<chunkLoaderStruct.blast_max_r) or (minR<blastR)) then
      local blastSq = blastR*blastR
      if(blastR == -1) then
        blastSq = math.max(r1*r1, r2*r2, r3*r3, r4*r4)+1
      end
      found = found + (blast_system.chunk_loaded(chunkLoaderStruct, surface_index, originPos, chunkPosAndArea, x, y, killPlanes, blastSq, force, cause, corpseMap) or 0)
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
    if(settings.global["actually-generate-crater"].value) then
      -- crater
      if((minR<chunkLoaderStruct.fireball_r*1.1+4) and (maxR>chunkLoaderStruct.crater_external_r-4) ) then
        crater_system_to_use.chunk_loaded_outer(surface_index, chunkPosAndArea, chunkLoaderStruct, originPos, x, y, ang1, ang2, ang3, ang4, minR, maxR)
      end

      if(minR<chunkLoaderStruct.crater_external_r*1.1+4) then
        crater_system_to_use.chunk_loaded(surface_index, chunkPosAndArea, chunkLoaderStruct, originPos, x, y, ang1, ang2, ang3, ang4, minR, maxR)
        crater = true
      end
    end
    water.check_fill(surface_index, chunkPosAndArea, x, y)
  end
  return found, killed, crater
end



-- Quality of the charge (Paranoidal 9.0.0, user decision 2026-11-15): linear in the step of the quality up to
-- the highest quality of the game (steps = the positive qualities ordered by level, as the quality caps of
-- ic-more-qualities): heat and blast damage up to x2, heat and blast radius up to x1.25 (the fireball and crater
-- stay: every fireball tile costs time in the detonation), fallout and pollution down to x0.5. Normal and
-- defective qualities (level 0) change nothing.
local NO_BOOST = {damage = 1, radius = 1, fallout = 1, pollution = 1}
local quality_step, quality_steps
local function quality_boost(quality)
  if not quality or quality == "normal" then return NO_BOOST end
  if not quality_step then
    local list = {}
    for name, p in pairs(prototypes.quality) do
      if not p.hidden and p.level > 0 then list[#list + 1] = {name = name, level = p.level} end
    end
    table.sort(list, function(a, b) if a.level ~= b.level then return a.level < b.level end return a.name < b.name end)
    quality_step, quality_steps = {}, math.max(1, #list)
    for i, q in ipairs(list) do quality_step[q.name] = i end
  end
  local step = quality_step[quality]
  if not step then return NO_BOOST end
  local t = step / quality_steps
  return {damage = 1 + t, radius = 1 + 0.25 * t, fallout = 1 - 0.5 * t, pollution = 1 - 0.5 * t}
end

-- Fallout: the radiation cloud projectiles that the prototypes used to throw (moved from the prototypes
-- to keep the amount adjustable), 40% of True Nukes' count: 100 overlapping clouds in a 50-tile circle
-- added damage and work, not coverage.
local FALLOUT_SHARE = 0.4
local function create_fallout(surface, position, effect_id, boost, force)
  local md = prototypes.mod_data["paranoidal-true-nukes-fallout"]
  local specs = md and md.data[effect_id]
  if not specs then return end
  for _, spec in pairs(specs) do
    local n = spec.count
    if n > 1 then n = math.max(1, math.floor(n * FALLOUT_SHARE * boost.fallout + 0.5)) end
    for _ = 1, n do
      local angle = math.random() * 2 * math.pi
      local dist = spec.radius * math.sqrt(math.random())
      surface.create_entity{name = spec.projectile, position = position, force = force,
        target = {position.x + dist * math.cos(angle), position.y + dist * math.sin(angle)}, speed = 0.0001}
    end
  end
end

local function charge_force(source)
  if source and source.valid then return source.force end
  return "neutral"
end

local function count_factories(surface, force)
  if type(force) == "string" then return 0 end
  return surface.count_entities_filtered{force = force, type = {"furnace", "assembling-machine"}, limit = 1000}
end

local function atomic_weapon_hit_optimised(surface_index, source, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, small_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters, boost)
  boost = boost or NO_BOOST
  local surface = game.surfaces[surface_index]
  if(settings.global["nukes-cause-pollution"].value) then
    surface.pollute(position, polution * boost.pollution)
  end
  local force = charge_force(source)
  local cause = source
  blast_max_r, thermal_max_r = blast_max_r * boost.radius, thermal_max_r * boost.radius
  local damage = 5000.0 * boost.damage
  local buildingCount = count_factories(surface, force)

  local blastId = new_blast_id()
  storage.blastWaves[blastId] = {r = fireball_r, pos = position, blastId=blastId, pow = fireball_r*fireball_r, max = blast_max_r, s = surface_index, fire = false, damage_init = damage, speed = 8, fire_rad = 0, blast_min_damage = 0, itt = 1, doItts = true, ittframe = 1, force = force, cause = cause}
  local chunkData = {surface_index=surface_index, blastIndex=blastId, blastId=blastId, force=force, source=cause, position=position, crater_internal_r=crater_internal_r,
    crater_external_r=crater_external_r, fireball_r=fireball_r, blast_max_r=blast_max_r, init_blast=damage, blast_min_damage=0, thermal_max_r=thermal_max_r, init_thermal=damage}
  -- generated chunks within reach, nearest first; handled by run_chunk_jobs a budget per tick
  local reach = math.max(blast_max_r, thermal_max_r) + 46
  local chunks = {}
  for chunk in surface.get_chunks() do
    local dx, dy = chunk.x*32+16-position.x, chunk.y*32+16-position.y
    local d2 = dx*dx + dy*dy
    if d2 <= reach*reach and surface.is_chunk_generated(chunk) then
      table.insert(chunks, {x = chunk.x, y = chunk.y, area = chunk.area, d2 = d2})
    end
  end
  table.sort(chunks, function(a, b) return a.d2 < b.d2 end)
  storage.chunkJobs[blastId] = {data = chunkData, chunks = chunks, i = 1, building_count = buildingCount}
  table.insert(storage.optimisedNukes, chunkData)
end


local function atomic_weapon_hit(surface_index, source, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, small_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters, boost)
  boost = boost or NO_BOOST
  local surface = game.surfaces[surface_index]
  if(settings.global["nukes-cause-pollution"].value) then
    surface.pollute(position, polution * boost.pollution)
  end
  local force = charge_force(source)
  local cause = source
  blast_max_r, thermal_max_r = blast_max_r * boost.radius, thermal_max_r * boost.radius
  local damage = 5000.0 * boost.damage

  -- 9.0.0: request the map asynchronously instead of force_generate_chunk_requests(), which generated
  -- up to ~4000 chunks (with every mod's on_chunk_generated handler) inside the detonation tick.
  -- Chunks generated later get the heat and blast from the lazy record registered below.
  surface.request_to_generate_chunks(position, math.ceil(load_r/32))
  for _,f in pairs(game.forces) do
    if #f.players > 0 then -- 9.0.0: enemy, neutral and other player-less forces were charted too
      f.chart(surface, {{position.x-visable_r,position.y-visable_r},{position.x+visable_r,position.y+visable_r}})
    end
  end

  -- fireball, crater and fires: detonation-jobs.lua (over several ticks for large fireballs)
  detonation_jobs.create({surface_index = surface_index, position = position, crater_internal_r = crater_internal_r,
    crater_external_r = crater_external_r, fireball_r = fireball_r, fire_outer_r = fire_outer_r, small_fire_max_r = small_fire_max_r,
    flame_proportion = flame_proportion, create_small_fires = create_small_fires, force = force, cause = cause,
    building_count = count_factories(surface, force)}, corpseMap)

  thermal_system.atomic_thermal_blast(surface_index, position, force, cause, thermal_max_r, damage, fireball_r, corpseMap)
  local blastId = new_blast_id()
  storage.blastWaves[blastId] = {r = fireball_r, pos = position, blastId = blastId, pow = fireball_r*fireball_r, max = blast_max_r, s = surface_index, fire = false, damage_init = damage, speed = 8, fire_rad = 0, blast_min_damage = 0, itt = 1, doItts = true, ittframe = 1, force = force, cause = cause}
  -- chunks inside the heat/blast radius that are generated in the next minutes get the effect then
  table.insert(storage.optimisedNukes, {surface_index=surface_index, blastIndex=blastId, blastId=blastId, force=force, source=cause, position=position, crater_internal_r=crater_internal_r,
    crater_external_r=crater_external_r, fireball_r=fireball_r, blast_max_r=blast_max_r, init_blast=damage, blast_min_damage=0, thermal_max_r=thermal_max_r, init_thermal=damage,
    expires = game.tick + 36000})
end


local function thermobaric_weapon_hit(surface_index, source, position, explosion_r, blast_max_r, fire_r, load_r, visable_r, boost)
  boost = boost or NO_BOOST
  local surface = game.surfaces[surface_index]
  local force = charge_force(source) -- 9.0.0: "neutral" without a source, as the atomic charges (was "enemy")
  local cause = source
  surface.request_to_generate_chunks(position, math.ceil(load_r/32)) -- asynchronous (9.0.0)
  for _,f in pairs(game.forces) do
    if #f.players > 0 then -- 9.0.0: enemy, neutral and other player-less forces were charted too
      f.chart(surface, {{position.x-visable_r,position.y-visable_r},{position.x+visable_r,position.y+visable_r}})
    end
  end
  for _,v in pairs(surface.find_tiles_filtered{position=position, radius=explosion_r}) do
    surface.create_entity{name="fire-flame",position=v.position}
  end
  local blastId = new_blast_id()
  storage.blastWaves[blastId] = {r = explosion_r, pos = position, blastId = blastId, pow = explosion_r*explosion_r, max = blast_max_r * boost.radius, s = surface_index, fire = true, damage_init = 600.0 * boost.damage, speed = 1, fire_rad = fire_r, blast_min_damage = 30, itt = 1, doItts = false, ittframe = 1, force = force, cause = cause}
end



-- calculate polution as 1*tonnage + 1000*uranium input + 100*californium input + 10000*tritium input
-- polution is capped at 500000
--local function atomic_weapon_hit(surface_index, source_entity, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, tree_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters)
script.on_event(defines.events.on_script_trigger_effect, function(event)
  local mult = 25 / settings.global["general-nuke-range-scaledown"].value
  local thermal_mult = 30 / settings.global["general-nuke-range-scaledown"].value
  local position = find_event_position(event);

  local source = event.source_entity
  local boost = quality_boost(event.quality)
  if string.sub(event.effect_id, 1, 18) == "Atomic Weapon hit " or string.sub(event.effect_id, 1, 18) == "Thermobaric Weapon" then
    -- last detonation, for support and the autotests (overwritten each time)
    storage.lastDetonation = {effect_id = event.effect_id, quality = event.quality, damage = boost.damage, tick = event.tick}
  end

  if(event.effect_id=="Thermobaric Weapon hit small-") then
    thermobaric_weapon_hit(event.surface_index, source, position, 1, 15, 10, 10, 10, boost);
  elseif(event.effect_id=="Thermobaric Weapon hit small") then
    thermobaric_weapon_hit(event.surface_index, source, position, 3, 30, 20, 30, 15, boost);
  elseif(event.effect_id=="Thermobaric Weapon hit small+") then
    thermobaric_weapon_hit(event.surface_index, source, position, 4, 45, 30, 45, 25, boost);
  elseif(event.effect_id=="Thermobaric Weapon hit medium-") then
    thermobaric_weapon_hit(event.surface_index, source, position, 5, 60, 40, 60, 35, boost);
  elseif(event.effect_id=="Thermobaric Weapon hit medium") then
    thermobaric_weapon_hit(event.surface_index, source, position, 6, 80, 50, 80, 50, boost);
  elseif(event.effect_id=="Thermobaric Weapon hit large") then
    thermobaric_weapon_hit(event.surface_index, source, position, 9, 120, 100, 120, 100, boost);
  elseif(event.effect_id=="Atomic Weapon hit 0.1t") then
    atomic_weapon_hit(event.surface_index, source, position, 0, 1, 1, 3, mult*1, 15, thermal_mult*1, 15, 15, 300.1, 8, true, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 60, 100, 200, 700, 10, 0.06);
  elseif(event.effect_id=="Atomic Weapon hit 0.5t") then
    atomic_weapon_hit(event.surface_index, source, position, 0, 3, 3, 5, mult*3, 25, thermal_mult*3, 30, 20, 700.5, 4, true, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 80, 150, 300, 1000, 20, 0.12);
  elseif(event.effect_id=="Atomic Weapon hit 2t") then
    atomic_weapon_hit(event.surface_index, source, position, 0, 5, 5, 15, mult*5, 50, thermal_mult*5, 100, 50, 1302, 3, true, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 100, 250, 500, 2000, 40, 0.25);
  elseif(event.effect_id=="Atomic Weapon hit 4t") then
    atomic_weapon_hit(event.surface_index, source, position, 1, 6, 7, 20, mult*7, 120, thermal_mult*7, 180, 80, 4004, 2, true, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 120, 300, 900, 4000, 70, 0.4);
  elseif(event.effect_id=="Atomic Weapon hit 8t") then
    atomic_weapon_hit(event.surface_index, source, position, 3, 8, 14, 25, mult*14, 200, thermal_mult*14, 180, 100, 9008, 1, true, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 150, 400, 1250, 10000, 100, 0.6);
  elseif(event.effect_id=="Atomic Weapon hit 20t") then
    atomic_weapon_hit(event.surface_index, source, position, 5, 10, 20, 30, mult*20, 320, thermal_mult*20, 180, 150, 30020, 0.5, true, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 250, 600, 1800, 15000, 160, 1);
  elseif(event.effect_id=="Atomic Weapon hit 500t") then
    atomic_weapon_hit(event.surface_index, source, position, 10, 20, 40, 35, mult*40, 400, thermal_mult*40, 400, 300, 75500, 0.25*settings.global["large-nuke-fire-scaledown"].value, true, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 400, 800, 2500, 25000, 300, 2);
  elseif(event.effect_id=="Atomic Weapon hit 1kt") then
    atomic_weapon_hit(event.surface_index, source, position, 20, 40, 80, 75, mult*80/settings.global["large-nuke-range-scaledown"].value, 800, thermal_mult*80/settings.global["large-nuke-range-scaledown"].value, 800, 300, 101000, 0.25*settings.global["large-nuke-fire-scaledown"].value, true, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 600, 1200, 8000, 60000, 600, 4);
  elseif(event.effect_id=="Atomic Weapon hit 15kt") then
    atomic_weapon_hit(event.surface_index, source, position, 50, 100, 200, 150, mult*200/settings.global["huge-nuke-range-scaledown"].value, 1000, thermal_mult*200/settings.global["huge-nuke-range-scaledown"].value, 1000, 500, 315000, 0.125*settings.global["huge-nuke-fire-scaledown"].value, false, true, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 1500, 3000, 20000, 100000, 1500, 8);
  elseif(event.effect_id=="Atomic Weapon hit 100kt") then
    local blastD = mult*500/settings.global["really-huge-nuke-range-scaledown"].value;
    if not settings.global["optimise-100kt"].value then
      atomic_weapon_hit(event.surface_index, source, position, 90, 180, 500, 400, blastD, 2500, thermal_mult*500/settings.global["really-huge-nuke-range-scaledown"].value, 1500, 1000, 450000, 0, false, false, boost);
    else
      atomic_weapon_hit_optimised(event.surface_index, source, position, 90, 180, 500, 400, blastD, 2500, thermal_mult*500/settings.global["really-huge-nuke-range-scaledown"].value, 1500, 1000, 450000, 0, false, false, boost);
    end
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 2700, 5400, 36000, 200000, 2700, 16);
  elseif(event.effect_id=="Atomic Weapon hit 1Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 190, 390, 1200, 1000, mult*1200/settings.global["really-huge-nuke-range-scaledown"].value, 5000, thermal_mult*1200/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 6000, 10000, 60000, 400000, 5000, 32);
  elseif(event.effect_id=="Atomic Weapon hit 5Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 330, 660, 2400, 2000, mult*2400/settings.global["really-huge-nuke-range-scaledown"].value, 10000, thermal_mult*2400/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 12000, 20000, 120000, 800000, 10000, 64);
  elseif(event.effect_id=="Atomic Weapon hit 10Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 420, 830, 3150, 4000, mult*3150/settings.global["really-huge-nuke-range-scaledown"].value, 15000, thermal_mult*3150/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 18000, 30000, 180000, 1200000, 15000, 96);
  elseif(event.effect_id=="Atomic Weapon hit 50Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 710, 1420, 6000, 8000, mult*6000/settings.global["really-huge-nuke-range-scaledown"].value, 30000, thermal_mult*6000/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 36000, 60000, 360000, 2400000, 30000, 192);
  elseif(event.effect_id=="Atomic Weapon hit 100Mt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 900, 1800, 8000, 12000, mult*8000/settings.global["really-huge-nuke-range-scaledown"].value, 40000, thermal_mult*8000/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 48000, 80000, 480000, 3200000, 40000, 256);
  elseif(event.effect_id=="Atomic Weapon hit 1Gt") then
    atomic_weapon_hit_optimised(event.surface_index, source, position, 1800, 3600, 16000, 24000, mult*16000/settings.global["really-huge-nuke-range-scaledown"].value, 80000, thermal_mult*16000/settings.global["really-huge-nuke-range-scaledown"].value, 3200, 2000, 500000, 0, false, false, boost);
    createBlastSoundsAndFlash(position, game.surfaces[event.surface_index], 96000, 160000, 960000, 6400000, 80000, 512);
  elseif(event.effect_id=="Mega-nuke built") then
    table.insert(storage.nukeBuildings, source)
  end

  if string.sub(event.effect_id, 1, 18) == "Atomic Weapon hit " and position then
    create_fallout(game.surfaces[event.surface_index], position, event.effect_id, boost, charge_force(source))
  end
end)



script.on_nth_tick(1207, water.slowFill)

script.on_event(defines.events.on_chunk_generated, function(event)
  if(storage.optimisedNukes == nil) then
    storage.optimisedNukes = {}
  end
  if(#storage.optimisedNukes>0) then
    local list = storage.optimisedNukes
    for i = #list, 1, -1 do
      local chunkData = list[i]
      if chunkData.expires and chunkData.expires < event.tick then
        table.remove(list, i) -- lazy record of a normal detonation, older than 10 minutes
      elseif(chunkData.surface_index == event.surface.index) then
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
  return storage -- 1.1 "global"; the 2.x port still returned the nil global
end
local function setGlobal(newglobal)
  for k in pairs(storage) do storage[k] = nil end
  for k, v in pairs(newglobal) do storage[k] = v end
end
-- count of a detonation (item name) set off in test sites by a force; used by paranoidal-achievements
local function getDetonationCount(force_index, detonation_name)
  local f = storage.nuclearTests and storage.nuclearTests[force_index]
  return f and f[detonation_name] or 0
end
remote.add_interface("True-Nukes Scripts", {
  getDetonationCount = getDetonationCount,
  thermobaricWeaponHit = thermobaric_weapon_hit,
  atomicWeaponHit = atomic_weapon_hit,
  createBlastSoundsAndFlash = createBlastSoundsAndFlash,
  clearAllCraters = clearAllCraters,
  getGlobal = getGlobal,
  setGlobal = setGlobal,
});
